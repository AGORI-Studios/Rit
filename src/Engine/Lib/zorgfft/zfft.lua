local math_floor, math_sqrt, require, type, error, assert = math.floor, math.sqrt, require, type, error, assert

-- Löve-specific i/FFT implementation
-- zorg @ 2020 § ISC
-- Mostly based on the lua port of the KissFFT Library (by Mark Borgerding) by Benjamin von Ardenne,
-- as well as KissFFT proper.

-- Currently implements the following:
-- - Recursive complex fft and ifft
-- * Optimized butterfly functions for factors 2,3,4,5 and a generic one otherwise.
-- * Complex types and calculations unrolled.
-- - Utilize LöVE ByteData/SoundData objects with double prec. values through FFI
--   for space, speed optimizations, as well as cross-thread accessibility.

-- TODO:
-- - Fix butterfly functions of radix 5 and the generic one, current implementations show ringing with pure tones.

local current_folder = (...):match("(.-)[^%.]+$")
local ffi = require "ffi"
local cos, sin, pi = math.cos, math.sin, math.pi

-- Define locals for Channels for communicating with Threads, and the Threads themselves.
local fromThread  -- Singleton in current Thread that requires this library.
local toThread = {} -- List of Channels, one for each Thread (Uses named channels so other Threads can also utilize workers.)
local thread = {}
local threadCount = 0
local nextThread = 0

-- Define twiddle factors only once, with the largest window size supported (16384) to hopefully curb memory usage fluctuation.
local maxTwiddleSize = 32
local twiddlesRe = love.data.newByteData(maxTwiddleSize * ffi.sizeof("double"))
local twiddlesIm = love.data.newByteData(maxTwiddleSize * ffi.sizeof("double"))

-- Helper functions

-- Calculates which butterfly functions to use, and how many times.
local function calculateFactors(n)
    local factors = {}
    local i = 1
    local p = 4
    local floorSqrt = math_floor(math_sqrt(n))
    repeat
        while n % p > 0 do
            if p == 4 then
                p = 2
            elseif p == 2 then
                p = 3
            else
                p = p + 2
            end
            if p > floorSqrt then
                p = n
            end
        end
        n = n / p
        factors[i] = p
        factors[i + 1] = n
        i = i + 2
    until n <= 1
    local factorsBD = love.data.newByteData(#factors * ffi.sizeof("double"))
    local factorsPtr = ffi.cast("double *", factorsBD:getFFIPointer())
    for i = 0, #factors - 1 do
        factorsPtr[i] = factors[1 + i]
    end
    return factorsBD, factorsPtr
end

-- Include butterfly functions
local bfyEnum = require(current_folder .. "zfft_butterfly")

-- Computational functions

local function work(iRe, iIm, oRe, oIm, oidx, f, factors, fidx, twRe, twIm, fstride, istride, isInverse)
    local p, m = factors[fidx], factors[fidx + 1]
    fidx = fidx + 2

    local last = oidx + p * m
    local begin = oidx

    if m == 1 then
        repeat
            oRe[oidx], oIm[oidx] = iRe[f], iIm[f]
            f = f + fstride * istride
            oidx = oidx + 1
        until oidx == last
    else
        repeat
            work(iRe, iIm, oRe, oIm, oidx, f, factors, fidx, twRe, twIm, fstride * p, istride, isInverse)
            f = f + fstride * istride
            oidx = oidx + m
        until oidx == last
    end

    oidx = begin

    bfyEnum[p](oRe, oIm, oidx, fstride, twRe, twIm, isInverse, m, p)
end

local function work_t(
    iRe,
    iIm,
    oRe,
    oIm,
    oidx,
    f,
    factors,
    fidx,
    twRe,
    twIm,
    fstride,
    istride,
    isInverse,
    BDiRe,
    BDiIm,
    BDoRe,
    BDoIm,
    BDfactors,
    BDtwRe,
    BDtwIm) -- ByteData objects passable only through channels...
    local p, m = factors[fidx], factors[fidx + 1]
    fidx = fidx + 2

    -- Threaded call (top-level only)
    if fstride == 1 and p <= 5 and m ~= 1 then
        for k = 0, p - 1 do
            -- Request threads to call work with these params (if there are less threads than top level calls, we do round-robin)
            local tid = k % threadCount

            local state = {}
            state[1] = "work" -- Work request
            state[2] = fromThread -- The originator thread where work_t was called
            -- All the parameters to be passed to work
            state[3] = BDiRe
            state[4] = BDiIm
            state[5] = BDoRe
            state[6] = BDoIm
            state[7] = oidx + m * k
            state[8] = f + fstride * istride * k
            state[9] = BDfactors
            state[10] = fidx
            state[11] = BDtwRe
            state[12] = BDtwIm
            state[13] = fstride * p
            state[14] = istride
            state[15] = isInverse

            toThread[tid]:push(state)
        end

        -- Check if all processing completed
        local k = p
        while k ~= 0 do
            if fromThread:pop() then
                k = k - 1
            end
        end
    end

    bfyEnum[p](oRe, oIm, oidx, fstride, twRe, twIm, isInverse, m, p)
end

-- API functions

-- Fast fourier transform (time -> freq domain)
local function fft(inputRe, inputIm, outputRe, outputIm)
    -- Size of input and output arrays
    local n

    -- We use pointers to manipulate the data directly, the LöVE object is only needed for two reasons:
    -- 1. Allows threading (between multiple luaJIT instances, real OS threads)
    -- 2. Side-step luaJIT memory address space limitations (LöVE is written in C++)
    local inputRePtr, inputImPtr

    -- Input type: flat gapless numeric lua table
    if type(inputRe) == "table" then
        -- Input type: FFI double type array
        -- Get array size
        n = #inputRe

        -- Convert to LöVE ByteData with type size of double, fix indexing to 0-based.
        local tempRe = inputRe
        inputRe = love.data.newByteData(n * ffi.sizeof("double"))
        inputRePtr = ffi.cast("double *", inputRe:getFFIPointer())
        for i = 0, n - 1 do
            inputRePtr[i] = tempRe[1 + i]
        end

        -- Check for imaginary input component
        if not inputIm then
            inputIm = love.data.newByteData(n * ffi.sizeof("double"))
            inputImPtr = ffi.cast("double *", inputIm:getFFIPointer())
            for i = 0, n - 1 do
                inputImPtr[i] = 0.0
            end
        else
            if not type(inputIm) == "table" then
                error "Parameter #2 type not the same as parameter #1."
            end
            local tempIm = inputIm
            inputIm = love.data.newByteData(n * ffi.sizeof("double"))
            inputImPtr = ffi.cast("double *", inputIm:getFFIPointer())
            for i = 0, n - 1 do
                inputImPtr[i] = tempIm[1 + i]
            end
        end
    elseif type(inputRe) == "cdata" then
        -- Get array size
        n = ffi.sizeof(inputRe) / ffi.sizeof("double")
        assert(ffi.istype(ffi.typeof("double[" .. n .. "]"), inputRe), "The passed ffi array wasn't of type double.")

        -- Convert to LöVE ByteData with type size of double
        local tempRe = inputRe
        inputRe = love.data.newByteData(n * ffi.sizeof("double"))
        inputRePtr = ffi.cast("double *", inputRe:getFFIPointer())
        for i = 0, n - 1 do
            inputRePtr[i] = tempRe[i]
        end

        -- Check for imaginary input component
        if not inputIm then
            inputIm = love.data.newByteData(n * ffi.sizeof("double"))
            inputImPtr = ffi.cast("double *", inputIm:getFFIPointer())
            for i = 0, n - 1 do
                inputImPtr[i] = 0.0
            end
        else
            if not type(inputIm) == "cdata" then
                error "Parameter #2 type not the same as parameter #1."
            end
            assert(
                ffi.istype(ffi.typeof("double[" .. n .. "]"), inputIm),
                "The passed ffi array wasn't of type double."
            )
            local tempIm = inputIm
            inputIm = love.data.newByteData(n * ffi.sizeof("double"))
            inputImPtr = ffi.cast("double *", inputIm:getFFIPointer())
            for i = 0, n - 1 do
                inputImPtr[i] = tempIm[i]
            end
        end
    elseif love and inputRe and inputRe.type and inputRe:type() == "SoundData" then
        -- Input type: LöVE ByteData through FFI double type pointer
        assert(
            inputRe:getChannelCount() == 1,
            "Input format of parameter #1 not supported, only monaural (mono, 1 channel) SoundData objects supported!\n" ..
                "Please separate non-mono SoundData into two mono ones."
        )

        -- Get array size
        n = inputRe:getSize() / inputRe:getBitDepth() --/ inputRe:getChannelCount()

        -- Input conversion necessary only because the only supported internal representation of a SoundData
        -- are either 8bit or 16bit integers instead of 64bit doubles.
        local tempRe = inputRe
        inputRe = love.data.newByteData(n * ffi.sizeof("double"))
        inputRePtr = ffi.cast("double *", inputRe:getFFIPointer())
        for i = 0, n - 1 do
            inputRePtr[i] = tempRe:getSample(i)
        end

        -- Check for imaginary input component
        if not inputIm then
            inputIm = love.data.newByteData(n * ffi.sizeof("double"))
            inputImPtr = ffi.cast("double *", inputIm:getFFIPointer())
            for i = 0, n - 1 do
                inputImPtr[i] = 0.0
            end
        else
            if not inputIm.type and inputIm:type() == "SoundData" then
                error "Parameter #2 type not the same as parameter #1."
            end
            assert(
                inputIm:getChannelCount() == 1,
                "Input format of parameter #2 not supported, only monaural (mono, 1 channel) SoundData objects supported!\n" ..
                    "Please separate non-mono SoundData into two mono ones."
            )
            local tempIm = inputIm
            inputIm = love.data.newByteData(n * ffi.sizeof("double"))
            inputImPtr = ffi.cast("double *", inputIm:getFFIPointer())
            for i = 0, n - 1 do
                inputImPtr[i] = tempIm:getSample(i)
            end
        end
    elseif love and inputRe and inputRe.type and inputRe:type() == "ByteData" then
        -- Everything else not supported.
        -- Get array size
        n = inputRe:getSize() / ffi.sizeof("double")

        -- Input conversion unneccessary
        inputRePtr = ffi.cast("double *", inputRe:getFFIPointer())

        -- Check for imaginary input component
        if not inputIm then
            inputIm = love.data.newByteData(n * ffi.sizeof("double"))
            inputImPtr = ffi.cast("double *", inputIm:getFFIPointer())
            for i = 0, n - 1 do
                inputImPtr[i] = 0.0
            end
        else
            if not inputIm.type and inputIm:type() == "ByteData" then
                error "Parameter #2 type not the same as parameter #1."
            end
            inputImPtr = ffi.cast("double *", inputIm:getFFIPointer())
        end
    elseif inputRe then
        error "Input format not supported; use lua tables, FFI double arrays or LÖVE ByteData."
    else
        error "Missing parameter #1: No input defined."
    end

    assert(
        n <= maxTwiddleSize,
        ("Detected input size (%d) larger than set size for twiddle arrays (%d)!"):format(n, maxTwiddleSize)
    )

    -- These "twiddle" arrays also need to be LöVE ByteData, so we can pass pointers around across threads.
    local twiddlesRePtr = ffi.cast("double *", twiddlesRe:getFFIPointer())
    local twiddlesImPtr = ffi.cast("double *", twiddlesIm:getFFIPointer())

    for i = 0, n - 1 do
        local phase = -2.0 * pi * i / n
        twiddlesRePtr[i], twiddlesImPtr[i] = cos(phase), sin(phase)
    end

    -- Calculate fft factors
    local factors, factorsPtr = calculateFactors(n)

    -- TESTME: Is the output size guaranteed to be, at most, equal to the input size?
    -- The outputs also need to be LöVE ByteData, so we can pass pointers around across threads.
    -- Optionally, the user can pass the ByteData in themselves to not recreate them each call to this function.
    local outputRe = outputRe or love.data.newByteData(n * ffi.sizeof("double"))
    local outputIm = outputIm or love.data.newByteData(n * ffi.sizeof("double"))

    assert(outputRe.type and outputRe:type() == "ByteData", "Parameter #3 must be a LöVE ByteData object!")
    assert(outputIm.type and outputIm:type() == "ByteData", "Parameter #4 must be a LöVE ByteData object!")
    assert(
        outputRe:getSize() / ffi.sizeof("double") == n,
        "Parameter #3's size isn't correct; must be the same as all other parameters."
    )
    assert(
        outputIm:getSize() / ffi.sizeof("double") == n,
        "Parameter #4's size isn't correct; must be the same as all other parameters."
    )

    local outputRePtr = ffi.cast("double *", outputRe:getFFIPointer())
    local outputImPtr = ffi.cast("double *", outputIm:getFFIPointer())

    -- Define some locals so we know what parameters to the work function are what.
    local outputIndex = 0
    local factorCurrent = 0
    local factorIndex = 0
    local factorStride = 1
    local inputStride = 1

    -- Guts
    work(
        inputRePtr,
        inputImPtr,
        outputRePtr,
        outputImPtr,
        outputIndex,
        factorCurrent,
        factorsPtr,
        factorIndex,
        twiddlesRePtr,
        twiddlesImPtr,
        factorStride,
        inputStride,
        false
    )

    ----
    return outputRe, outputIm
end

-- Inverse fast fourier transform (freq -> time domain)
local function ifft(inputRe, inputIm, outputRe, outputIm)
    -- Size of input and output arrays
    local n

    -- We use pointers to manipulate the data directly, the LöVE object is only needed for two reasons:
    -- 1. Allows threading (between multiple luaJIT instances, real OS threads)
    -- 2. Side-step luaJIT memory address space limitations (LöVE is written in C++)
    local inputRePtr, inputImPtr

    -- Input type: flat gapless numeric lua table
    if type(inputRe) == "table" then
        -- Input type: FFI double type array
        -- Get array size
        n = #inputRe

        -- Convert to LöVE ByteData with type size of double, fix indexing to 0-based.
        local tempRe = inputRe
        inputRe = love.data.newByteData(n * ffi.sizeof("double"))
        inputRePtr = ffi.cast("double *", inputRe:getFFIPointer())
        for i = 0, n - 1 do
            inputRePtr[i] = tempRe[1 + i]
        end

        -- Check for imaginary input component
        if not inputIm then
            inputIm = love.data.newByteData(n * ffi.sizeof("double"))
            inputImPtr = ffi.cast("double *", inputIm:getFFIPointer())
            for i = 0, n - 1 do
                inputImPtr[i] = 0.0
            end
        else
            if not type(inputIm) == "table" then
                error "Parameter #2 type not the same as parameter #1."
            end
            local tempIm = inputIm
            inputIm = love.data.newByteData(n * ffi.sizeof("double"))
            inputImPtr = ffi.cast("double *", inputIm:getFFIPointer())
            for i = 0, n - 1 do
                inputImPtr[i] = tempIm[1 + i]
            end
        end
    elseif type(inputRe) == "cdata" then
        -- Get array size
        n = ffi.sizeof(inputRe) / ffi.sizeof("double")
        assert(ffi.istype(ffi.typeof("double[" .. n .. "]"), inputRe), "The passed ffi array wasn't of type double.")

        -- Convert to LöVE ByteData with type size of double
        local tempRe = inputRe
        inputRe = love.data.newByteData(n * ffi.sizeof("double"))
        inputRePtr = ffi.cast("double *", inputRe:getFFIPointer())
        for i = 0, n - 1 do
            inputRePtr[i] = tempRe[i]
        end

        -- Check for imaginary input component
        if not inputIm then
            inputIm = love.data.newByteData(n * ffi.sizeof("double"))
            inputImPtr = ffi.cast("double *", inputIm:getFFIPointer())
            for i = 0, n - 1 do
                inputImPtr[i] = 0.0
            end
        else
            if not type(inputIm) == "cdata" then
                error "Parameter #2 type not the same as parameter #1."
            end
            assert(
                ffi.istype(ffi.typeof("double[" .. n .. "]"), inputIm),
                "The passed ffi array wasn't of type double."
            )
            local tempIm = inputIm
            inputIm = love.data.newByteData(n * ffi.sizeof("double"))
            inputImPtr = ffi.cast("double *", inputIm:getFFIPointer())
            for i = 0, n - 1 do
                inputImPtr[i] = tempIm[i]
            end
        end
    elseif love and inputRe and inputRe.type and inputRe:type() == "SoundData" then
        -- Input type: LöVE ByteData through FFI double type pointer
        assert(
            inputRe:getChannelCount() == 1,
            "Input format of parameter #1 not supported, only monaural (mono, 1 channel) SoundData objects supported!\n" ..
                "Please separate non-mono SoundData into two mono ones."
        )

        -- Get array size
        n = inputRe:getSize() / inputRe:getBitDepth() --/ inputRe:getChannelCount()

        -- Input conversion necessary only because the only supported internal representation of a SoundData
        -- are either 8bit or 16bit integers instead of 64bit doubles.
        local tempRe = inputRe
        inputRe = love.data.newByteData(n * ffi.sizeof("double"))
        inputRePtr = ffi.cast("double *", inputRe:getFFIPointer())
        for i = 0, n - 1 do
            inputRePtr[i] = tempRe:getSample(i)
        end

        -- Check for imaginary input component
        if not inputIm then
            inputIm = love.data.newByteData(n * ffi.sizeof("double"))
            inputImPtr = ffi.cast("double *", inputIm:getFFIPointer())
            for i = 0, n - 1 do
                inputImPtr[i] = 0.0
            end
        else
            if not inputIm.type and inputIm:type() == "SoundData" then
                error "Parameter #2 type not the same as parameter #1."
            end
            assert(
                inputIm:getChannelCount() == 1,
                "Input format of parameter #2 not supported, only monaural (mono, 1 channel) SoundData objects supported!\n" ..
                    "Please separate non-mono SoundData into two mono ones."
            )
            local tempIm = inputIm
            inputIm = love.data.newByteData(n * ffi.sizeof("double"))
            inputImPtr = ffi.cast("double *", inputIm:getFFIPointer())
            for i = 0, n - 1 do
                inputImPtr[i] = tempIm:getSample(i)
            end
        end
    elseif love and inputRe and inputRe.type and inputRe:type() == "ByteData" then
        -- Everything else not supported.
        -- Get array size
        n = inputRe:getSize() / ffi.sizeof("double")

        -- Input conversion unneccessary
        inputRePtr = ffi.cast("double *", inputRe:getFFIPointer())

        -- Check for imaginary input component
        if not inputIm then
            inputIm = love.data.newByteData(n * ffi.sizeof("double"))
            inputImPtr = ffi.cast("double *", inputIm:getFFIPointer())
            for i = 0, n - 1 do
                inputImPtr[i] = 0.0
            end
        else
            if not inputIm.type and inputIm:type() == "ByteData" then
                error "Parameter #2 type not the same as parameter #1."
            end
            inputImPtr = ffi.cast("double *", inputIm:getFFIPointer())
        end
    elseif inputRe then
        error "Input format not supported; use lua tables, FFI double arrays or LÖVE ByteData."
    else
        error "Missing parameter #1: No input defined."
    end

    assert(
        n <= maxTwiddleSize,
        ("Detected input size (%d) larger than set size for twiddle arrays (%d)!"):format(n, maxTwiddleSize)
    )

    -- These "twiddle" arrays also need to be LöVE ByteData, so we can pass pointers around across threads.
    local twiddlesRePtr = ffi.cast("double *", twiddlesRe:getFFIPointer())
    local twiddlesImPtr = ffi.cast("double *", twiddlesIm:getFFIPointer())

    for i = 0, n - 1 do
        local phase = 2.0 * pi * i / n
        twiddlesRePtr[i], twiddlesImPtr[i] = cos(phase), sin(phase)
    end

    -- Calculate fft factors
    local factors, factorsPtr = calculateFactors(n)

    -- TESTME: Is the output size guaranteed to be, at most, equal to the input size?
    -- The outputs also need to be LöVE ByteData, so we can pass pointers around across threads.
    -- Optionally, the user can pass the ByteData in themselves to not recreate them each call to this function.
    local outputRe = outputRe or love.data.newByteData(n * ffi.sizeof("double"))
    local outputIm = outputIm or love.data.newByteData(n * ffi.sizeof("double"))

    assert(outputRe.type and outputRe:type() == "ByteData", "Parameter #3 must be a LöVE ByteData object!")
    assert(outputIm.type and outputIm:type() == "ByteData", "Parameter #4 must be a LöVE ByteData object!")
    assert(
        outputRe:getSize() / ffi.sizeof("double") == n,
        "Parameter #3's size isn't correct; must be the same as all other parameters."
    )
    assert(
        outputIm:getSize() / ffi.sizeof("double") == n,
        "Parameter #4's size isn't correct; must be the same as all other parameters."
    )

    local outputRePtr = ffi.cast("double *", outputRe:getFFIPointer())
    local outputImPtr = ffi.cast("double *", outputIm:getFFIPointer())

    -- Define some locals so we know what parameters to the work function are what.
    local outputIndex = 0
    local factorCurrent = 0
    local factorIndex = 0
    local factorStride = 1
    local inputStride = 1

    -- Guts
    work(
        inputRePtr,
        inputImPtr,
        outputRePtr,
        outputImPtr,
        outputIndex,
        factorCurrent,
        factorsPtr,
        factorIndex,
        twiddlesRePtr,
        twiddlesImPtr,
        factorStride,
        inputStride,
        true
    )

    ----
    return outputRe, outputIm
end

-- Threaded fast fourier transform (time -> freq domain)
local function fft_t(inputRe, inputIm, outputRe, outputIm)
    assert(threadCount > 0, "No worker threads created, use the setupThreads function to spawn them!")

    -- Size of input and output arrays
    local n

    -- We use pointers to manipulate the data directly, the LöVE object is only needed for two reasons:
    -- 1. Allows threading (between multiple luaJIT instances, real OS threads)
    -- 2. Side-step luaJIT memory address space limitations (LöVE is written in C++)
    local inputRePtr, inputImPtr

    -- Input type: flat gapless numeric lua table
    if type(inputRe) == "table" then
        -- Input type: FFI double type array
        -- Get array size
        n = #inputRe

        -- Convert to LöVE ByteData with type size of double, fix indexing to 0-based.
        local tempRe = inputRe
        inputRe = love.data.newByteData(n * ffi.sizeof("double"))
        inputRePtr = ffi.cast("double *", inputRe:getFFIPointer())
        for i = 0, n - 1 do
            inputRePtr[i] = tempRe[1 + i]
        end

        -- Check for imaginary input component
        if not inputIm then
            inputIm = love.data.newByteData(n * ffi.sizeof("double"))
            inputImPtr = ffi.cast("double *", inputIm:getFFIPointer())
            for i = 0, n - 1 do
                inputImPtr[i] = 0.0
            end
        else
            if not type(inputIm) == "table" then
                error "Parameter #2 type not the same as parameter #1."
            end
            local tempIm = inputIm
            inputIm = love.data.newByteData(n * ffi.sizeof("double"))
            inputImPtr = ffi.cast("double *", inputIm:getFFIPointer())
            for i = 0, n - 1 do
                inputImPtr[i] = tempIm[1 + i]
            end
        end
    elseif type(inputRe) == "cdata" then
        -- Get array size
        n = ffi.sizeof(inputRe) / ffi.sizeof("double")
        assert(ffi.istype(ffi.typeof("double[" .. n .. "]"), inputRe), "The passed ffi array wasn't of type double.")

        -- Convert to LöVE ByteData with type size of double
        local tempRe = inputRe
        inputRe = love.data.newByteData(n * ffi.sizeof("double"))
        inputRePtr = ffi.cast("double *", inputRe:getFFIPointer())
        for i = 0, n - 1 do
            inputRePtr[i] = tempRe[i]
        end

        -- Check for imaginary input component
        if not inputIm then
            inputIm = love.data.newByteData(n * ffi.sizeof("double"))
            inputImPtr = ffi.cast("double *", inputIm:getFFIPointer())
            for i = 0, n - 1 do
                inputImPtr[i] = 0.0
            end
        else
            if not type(inputIm) == "cdata" then
                error "Parameter #2 type not the same as parameter #1."
            end
            assert(
                ffi.istype(ffi.typeof("double[" .. n .. "]"), inputIm),
                "The passed ffi array wasn't of type double."
            )
            local tempIm = inputIm
            inputIm = love.data.newByteData(n * ffi.sizeof("double"))
            inputImPtr = ffi.cast("double *", inputIm:getFFIPointer())
            for i = 0, n - 1 do
                inputImPtr[i] = tempIm[i]
            end
        end
    elseif love and inputRe and inputRe.type and inputRe:type() == "SoundData" then
        -- Input type: LöVE ByteData through FFI double type pointer
        assert(
            inputRe:getChannelCount() == 1,
            "Input format of parameter #1 not supported, only monaural (mono, 1 channel) SoundData objects supported!\n" ..
                "Please separate non-mono SoundData into two mono ones."
        )

        -- Get array size
        n = inputRe:getSize() / inputRe:getBitDepth() --/ inputRe:getChannelCount()

        -- Input conversion necessary only because the only supported internal representation of a SoundData
        -- are either 8bit or 16bit integers instead of 64bit doubles.
        local tempRe = inputRe
        inputRe = love.data.newByteData(n * ffi.sizeof("double"))
        inputRePtr = ffi.cast("double *", inputRe:getFFIPointer())
        for i = 0, n - 1 do
            inputRePtr[i] = tempRe:getSample(i)
        end

        -- Check for imaginary input component
        if not inputIm then
            inputIm = love.data.newByteData(n * ffi.sizeof("double"))
            inputImPtr = ffi.cast("double *", inputIm:getFFIPointer())
            for i = 0, n - 1 do
                inputImPtr[i] = 0.0
            end
        else
            if not inputIm.type and inputIm:type() == "SoundData" then
                error "Parameter #2 type not the same as parameter #1."
            end
            assert(
                inputIm:getChannelCount() == 1,
                "Input format of parameter #2 not supported, only monaural (mono, 1 channel) SoundData objects supported!\n" ..
                    "Please separate non-mono SoundData into two mono ones."
            )
            local tempIm = inputIm
            inputIm = love.data.newByteData(n * ffi.sizeof("double"))
            inputImPtr = ffi.cast("double *", inputIm:getFFIPointer())
            for i = 0, n - 1 do
                inputImPtr[i] = tempIm:getSample(i)
            end
        end
    elseif love and inputRe and inputRe.type and inputRe:type() == "ByteData" then
        -- Everything else not supported.
        -- Get array size
        n = inputRe:getSize() / ffi.sizeof("double")

        -- Input conversion unneccessary
        inputRePtr = ffi.cast("double *", inputRe:getFFIPointer())

        -- Check for imaginary input component
        if not inputIm then
            inputIm = love.data.newByteData(n * ffi.sizeof("double"))
            inputImPtr = ffi.cast("double *", inputIm:getFFIPointer())
            for i = 0, n - 1 do
                inputImPtr[i] = 0.0
            end
        else
            if not inputIm.type and inputIm:type() == "ByteData" then
                error "Parameter #2 type not the same as parameter #1."
            end
            inputImPtr = ffi.cast("double *", inputIm:getFFIPointer())
        end
    elseif inputRe then
        error "Input format not supported; use lua tables, FFI double arrays or LÖVE ByteData."
    else
        error "Missing parameter #1: No input defined."
    end

    assert(
        n <= maxTwiddleSize,
        ("Detected input size (%d) larger than set size for twiddle arrays (%d)!"):format(n, maxTwiddleSize)
    )

    -- These "twiddle" arrays also need to be LöVE ByteData, so we can pass pointers around across threads.
    local twiddlesRePtr = ffi.cast("double *", twiddlesRe:getFFIPointer())
    local twiddlesImPtr = ffi.cast("double *", twiddlesIm:getFFIPointer())

    for i = 0, n - 1 do
        local phase = -2.0 * pi * i / n
        twiddlesRePtr[i], twiddlesImPtr[i] = cos(phase), sin(phase)
    end

    -- Calculate fft factors
    local factors, factorsPtr = calculateFactors(n)

    -- TESTME: Is the output size guaranteed to be, at most, equal to the input size?
    -- The outputs also need to be LöVE ByteData, so we can pass pointers around across threads.
    -- Optionally, the user can pass the ByteData in themselves to not recreate them each call to this function.
    local outputRe = outputRe or love.data.newByteData(n * ffi.sizeof("double"))
    local outputIm = outputIm or love.data.newByteData(n * ffi.sizeof("double"))

    assert(outputRe.type and outputRe:type() == "ByteData", "Parameter #3 must be a LöVE ByteData object!")
    assert(outputIm.type and outputIm:type() == "ByteData", "Parameter #4 must be a LöVE ByteData object!")
    assert(
        outputRe:getSize() / ffi.sizeof("double") == n,
        "Parameter #3's size isn't correct; must be the same as all other parameters."
    )
    assert(
        outputIm:getSize() / ffi.sizeof("double") == n,
        "Parameter #4's size isn't correct; must be the same as all other parameters."
    )

    local outputRePtr = ffi.cast("double *", outputRe:getFFIPointer())
    local outputImPtr = ffi.cast("double *", outputIm:getFFIPointer())

    -- Define some locals so we know what parameters to the work function are what.
    local outputIndex = 0
    local factorCurrent = 0
    local factorIndex = 0
    local factorStride = 1
    local inputStride = 1

    -- Guts
    work_t(
        inputRePtr,
        inputImPtr,
        outputRePtr,
        outputImPtr,
        outputIndex,
        factorCurrent,
        factorsPtr,
        factorIndex,
        twiddlesRePtr,
        twiddlesImPtr,
        factorStride,
        inputStride,
        false,
        inputRe,
        inputIm,
        outputRe,
        outputIm,
        factors,
        twiddlesRe,
        twiddlesIm
    ) -- ByteData objects

    ----
    return outputRe, outputIm
end

-- Threaded inverse fast fourier transform (freq -> time domain)
local function ifft_t(inputRe, inputIm, outputRe, outputIm)
    assert(threadCount > 0, "No worker threads created, use the setupThreads function to spawn them!")

    -- Size of input and output arrays
    local n

    -- We use pointers to manipulate the data directly, the LöVE object is only needed for two reasons:
    -- 1. Allows threading (between multiple luaJIT instances, real OS threads)
    -- 2. Side-step luaJIT memory address space limitations (LöVE is written in C++)
    local inputRePtr, inputImPtr

    -- Input type: flat gapless numeric lua table
    if type(inputRe) == "table" then
        -- Input type: FFI double type array
        -- Get array size
        n = #inputRe

        -- Convert to LöVE ByteData with type size of double, fix indexing to 0-based.
        local tempRe = inputRe
        inputRe = love.data.newByteData(n * ffi.sizeof("double"))
        inputRePtr = ffi.cast("double *", inputRe:getFFIPointer())
        for i = 0, n - 1 do
            inputRePtr[i] = tempRe[1 + i]
        end

        -- Check for imaginary input component
        if not inputIm then
            inputIm = love.data.newByteData(n * ffi.sizeof("double"))
            inputImPtr = ffi.cast("double *", inputIm:getFFIPointer())
            for i = 0, n - 1 do
                inputImPtr[i] = 0.0
            end
        else
            if not type(inputIm) == "table" then
                error "Parameter #2 type not the same as parameter #1."
            end
            local tempIm = inputIm
            inputIm = love.data.newByteData(n * ffi.sizeof("double"))
            inputImPtr = ffi.cast("double *", inputIm:getFFIPointer())
            for i = 0, n - 1 do
                inputImPtr[i] = tempIm[1 + i]
            end
        end
    elseif type(inputRe) == "cdata" then
        -- Get array size
        n = ffi.sizeof(inputRe) / ffi.sizeof("double")
        assert(ffi.istype(ffi.typeof("double[" .. n .. "]"), inputRe), "The passed ffi array wasn't of type double.")

        -- Convert to LöVE ByteData with type size of double
        local tempRe = inputRe
        inputRe = love.data.newByteData(n * ffi.sizeof("double"))
        inputRePtr = ffi.cast("double *", inputRe:getFFIPointer())
        for i = 0, n - 1 do
            inputRePtr[i] = tempRe[i]
        end

        -- Check for imaginary input component
        if not inputIm then
            inputIm = love.data.newByteData(n * ffi.sizeof("double"))
            inputImPtr = ffi.cast("double *", inputIm:getFFIPointer())
            for i = 0, n - 1 do
                inputImPtr[i] = 0.0
            end
        else
            if not type(inputIm) == "cdata" then
                error "Parameter #2 type not the same as parameter #1."
            end
            assert(
                ffi.istype(ffi.typeof("double[" .. n .. "]"), inputIm),
                "The passed ffi array wasn't of type double."
            )
            local tempIm = inputIm
            inputIm = love.data.newByteData(n * ffi.sizeof("double"))
            inputImPtr = ffi.cast("double *", inputIm:getFFIPointer())
            for i = 0, n - 1 do
                inputImPtr[i] = tempIm[i]
            end
        end
    elseif love and inputRe and inputRe.type and inputRe:type() == "SoundData" then
        -- Input type: LöVE ByteData through FFI double type pointer
        assert(
            inputRe:getChannelCount() == 1,
            "Input format of parameter #1 not supported, only monaural (mono, 1 channel) SoundData objects supported!\n" ..
                "Please separate non-mono SoundData into two mono ones."
        )

        -- Get array size
        n = inputRe:getSize() / inputRe:getBitDepth() --/ inputRe:getChannelCount()

        -- Input conversion necessary only because the only supported internal representation of a SoundData
        -- are either 8bit or 16bit integers instead of 64bit doubles.
        local tempRe = inputRe
        inputRe = love.data.newByteData(n * ffi.sizeof("double"))
        inputRePtr = ffi.cast("double *", inputRe:getFFIPointer())
        for i = 0, n - 1 do
            inputRePtr[i] = tempRe:getSample(i)
        end

        -- Check for imaginary input component
        if not inputIm then
            inputIm = love.data.newByteData(n * ffi.sizeof("double"))
            inputImPtr = ffi.cast("double *", inputIm:getFFIPointer())
            for i = 0, n - 1 do
                inputImPtr[i] = 0.0
            end
        else
            if not inputIm.type and inputIm:type() == "SoundData" then
                error "Parameter #2 type not the same as parameter #1."
            end
            assert(
                inputIm:getChannelCount() == 1,
                "Input format of parameter #2 not supported, only monaural (mono, 1 channel) SoundData objects supported!\n" ..
                    "Please separate non-mono SoundData into two mono ones."
            )
            local tempIm = inputIm
            inputIm = love.data.newByteData(n * ffi.sizeof("double"))
            inputImPtr = ffi.cast("double *", inputIm:getFFIPointer())
            for i = 0, n - 1 do
                inputImPtr[i] = tempIm:getSample(i)
            end
        end
    elseif love and inputRe and inputRe.type and inputRe:type() == "ByteData" then
        -- Everything else not supported.
        -- Get array size
        n = inputRe:getSize() / ffi.sizeof("double")

        -- Input conversion unneccessary
        inputRePtr = ffi.cast("double *", inputRe:getFFIPointer())

        -- Check for imaginary input component
        if not inputIm then
            inputIm = love.data.newByteData(n * ffi.sizeof("double"))
            inputImPtr = ffi.cast("double *", inputIm:getFFIPointer())
            for i = 0, n - 1 do
                inputImPtr[i] = 0.0
            end
        else
            if not inputIm.type and inputIm:type() == "ByteData" then
                error "Parameter #2 type not the same as parameter #1."
            end
            inputImPtr = ffi.cast("double *", inputIm:getFFIPointer())
        end
    elseif inputRe then
        error "Input format not supported; use lua tables, FFI double arrays or LÖVE ByteData."
    else
        error "Missing parameter #1: No input defined."
    end

    assert(
        n <= maxTwiddleSize,
        ("Detected input size (%d) larger than set size for twiddle arrays (%d)!"):format(n, maxTwiddleSize)
    )

    -- These "twiddle" arrays also need to be LöVE ByteData, so we can pass pointers around across threads.
    local twiddlesRePtr = ffi.cast("double *", twiddlesRe:getFFIPointer())
    local twiddlesImPtr = ffi.cast("double *", twiddlesIm:getFFIPointer())

    for i = 0, n - 1 do
        local phase = 2.0 * pi * i / n
        twiddlesRePtr[i], twiddlesImPtr[i] = cos(phase), sin(phase)
    end

    -- Calculate fft factors
    local factors, factorsPtr = calculateFactors(n)

    -- TESTME: Is the output size guaranteed to be, at most, equal to the input size?
    -- The outputs also need to be LöVE ByteData, so we can pass pointers around across threads.
    -- Optionally, the user can pass the ByteData in themselves to not recreate them each call to this function.
    local outputRe = outputRe or love.data.newByteData(n * ffi.sizeof("double"))
    local outputIm = outputIm or love.data.newByteData(n * ffi.sizeof("double"))

    assert(outputRe.type and outputRe:type() == "ByteData", "Parameter #3 must be a LöVE ByteData object!")
    assert(outputIm.type and outputIm:type() == "ByteData", "Parameter #4 must be a LöVE ByteData object!")
    assert(
        outputRe:getSize() / ffi.sizeof("double") == n,
        "Parameter #3's size isn't correct; must be the same as all other parameters."
    )
    assert(
        outputIm:getSize() / ffi.sizeof("double") == n,
        "Parameter #4's size isn't correct; must be the same as all other parameters."
    )

    local outputRePtr = ffi.cast("double *", outputRe:getFFIPointer())
    local outputImPtr = ffi.cast("double *", outputIm:getFFIPointer())

    -- Define some locals so we know what parameters to the work function are what.
    local outputIndex = 0
    local factorCurrent = 0
    local factorIndex = 0
    local factorStride = 1
    local inputStride = 1

    -- Guts
    work_t(
        inputRePtr,
        inputImPtr,
        outputRePtr,
        outputImPtr,
        outputIndex,
        factorCurrent,
        factorsPtr,
        factorIndex,
        twiddlesRePtr,
        twiddlesImPtr,
        factorStride,
        inputStride,
        true,
        inputRe,
        inputIm,
        outputRe,
        outputIm,
        factors,
        twiddlesRe,
        twiddlesIm
    ) -- ByteData objects

    ----
    return outputRe, outputIm
end

-- Given a window size, gives back the next size that only uses the optimized butterfly functions.
local function nextFastSize(n)
    local m = n
    while true do
        m = n
        while m % 2 == 0 do
            m = m / 2
        end
        while m % 3 == 0 do
            m = m / 3
        end
        while m % 5 == 0 do
            m = m / 5
        end
        if m <= 1 then
            break
        end
        n = n + 1
    end
    return n
end

-- Pre-define the max size of the twiddle arrays (them being static should not be an issue with any of the API methods)
local function setMaxTwiddleSize(size)
    maxTwiddleSize = size
    twiddlesRe = love.data.newByteData(size * ffi.sizeof("double"))
    twiddlesIm = love.data.newByteData(size * ffi.sizeof("double"))
end

-- Spawns threadCount threads that the threaded functions can utilize.
local function setupThreads(tc)
    -- Store Thread count.
    threadCount = tc

    -- Local to the current thread only, so the channel can be anonymous, since we'll be passing this to the worker threads,
    -- so they know where to return their signals.
    fromThread = love.thread.newChannel()

    -- Worker thread channel are named, so they can be accessed from any thread where we require this library from,
    -- should we need to.
    for i = 0, threadCount - 1 do
        -- Get named channel.
        toThread[i] = love.thread.getChannel(("zorg.fft.procThread_%d"):format(i))
        -- Ask if thread exists, if not, create and start it.
        toThread[i]:performAtomic(
            function(ch)
                ch:push("procThread?")
                ch:push(fromThread)
            end
        )
        thread[i] = fromThread:demand(0.01)
        if not thread[i] then
            -- Clear toThread queue, since the query events never got processed... duh.
            toThread[i]:clear()
            -- Require in the thread code.
            thread[i] = love.thread.newThread(current_folder:gsub("%.", "%/") .. "/zfft_thread.lua")
            -- Start processing (we'll pass fromThread from the work_t function, since calls can originate from other threads.)
            -- We still need to pass the toThread channel though.
            thread[i]:start(toThread[i], current_folder)
        end
    end
end

-- Cleanup threads.
local function freeThreads()
    for i = 0, threadCount - 1 do
        toThread[i]:push("stop")
    end
    -- Safety wait for threads to exit gracefully.
    love.timer.sleep(0.01)
end

----
return {
    fft = fft,
    ifft = ifft,
    fft_t = fft_t,
    ifft_t = ifft_t,
    nextFastSize = nextFastSize,
    setMaxTwiddleSize = setMaxTwiddleSize,
    setupThreads = setupThreads,
    freeThreads = freeThreads
}
