local setmetatable = setmetatable

-- Löve-specific i/FFT butterfly function implementations
-- zorg @ 2020 § ISC
-- see zorgfft.lua for acknowledgements

-- Virtually no performance loss by having this outside of zorgfft.lua,
-- and this way, we can also require it into zorgfft_thread.lua.

local ffi = require "ffi"
local cos, sin, pi = math.cos, math.sin, math.pi

-- Butterfly functions

local function butterfly2(iRe, iIm, oidx, fstride, twRe, twIm, isInverse, m, p)
    local i1 = oidx
    local i2 = oidx + m
    local tw1 = 0
    local tRe, tIm = ffi.new("double"), ffi.new("double")
    repeat
        -- LuaJIT Numeric Performance Guide recommends not doing manual common subexpression elimination...
        -- However, we can't do that here, because this backs up values into the locals.
        tRe = iRe[i2] * twRe[tw1] - iIm[i2] * twIm[tw1]
        tIm = iRe[i2] * twIm[tw1] + iIm[i2] * twRe[tw1]
        tw1 = tw1 + fstride
        iRe[i2] = iRe[i1] - tRe
        iIm[i2] = iIm[i1] - tIm
        iRe[i1] = iRe[i1] + tRe
        iIm[i1] = iIm[i1] + tIm
        i1 = i1 + 1
        i2 = i2 + 1
        m = m - 1
    until m == 0
end

local function butterfly4(iRe, iIm, oidx, fstride, twRe, twIm, isInverse, m, p)
    local tw1, tw2, tw3 = 0, 0, 0
    local k = m
    local i = oidx
    local m2 = 2 * m
    local m3 = 3 * m
    local scratchRe, scratchIm = ffi.new("double[6]"), ffi.new("double[6]")

    if not isInverse then
        repeat
            scratchRe[0] = iRe[i + m] * twRe[tw1] - iIm[i + m] * twIm[tw1]
            scratchIm[0] = iRe[i + m] * twIm[tw1] + iIm[i + m] * twRe[tw1]
            scratchRe[1] = iRe[i + m2] * twRe[tw2] - iIm[i + m2] * twIm[tw2]
            scratchIm[1] = iRe[i + m2] * twIm[tw2] + iIm[i + m2] * twRe[tw2]
            scratchRe[2] = iRe[i + m3] * twRe[tw3] - iIm[i + m3] * twIm[tw3]
            scratchIm[2] = iRe[i + m3] * twIm[tw3] + iIm[i + m3] * twRe[tw3]

            scratchRe[5] = iRe[i] - scratchRe[1]
            scratchIm[5] = iIm[i] - scratchIm[1]
            iRe[i] = iRe[i] + scratchRe[1]
            iIm[i] = iIm[i] + scratchIm[1]

            scratchRe[3] = scratchRe[0] + scratchRe[2]
            scratchIm[3] = scratchIm[0] + scratchIm[2]
            scratchRe[4] = scratchRe[0] - scratchRe[2]
            scratchIm[4] = scratchIm[0] - scratchIm[2]

            iRe[i + m2] = iRe[i] - scratchRe[3]
            iIm[i + m2] = iIm[i] - scratchIm[3]
            tw1 = tw1 + fstride
            tw2 = tw2 + fstride * 2
            tw3 = tw3 + fstride * 3
            iRe[i] = iRe[i] + scratchRe[3]
            iIm[i] = iIm[i] + scratchIm[3]

            -- part dependent on isInverse
            iRe[i + m] = scratchRe[5] + scratchIm[4]
            iIm[i + m] = scratchIm[5] - scratchRe[4]
            iRe[i + m3] = scratchRe[5] - scratchIm[4]
            iIm[i + m3] = scratchIm[5] + scratchRe[4]
            -- //

            i = i + 1
            k = k - 1
        until k == 0
    else
        repeat
            scratchRe[0] = iRe[i + m] * twRe[tw1] - iIm[i + m] * twIm[tw1]
            scratchIm[0] = iRe[i + m] * twIm[tw1] + iIm[i + m] * twRe[tw1]
            scratchRe[1] = iRe[i + m2] * twRe[tw2] - iIm[i + m2] * twIm[tw2]
            scratchIm[1] = iRe[i + m2] * twIm[tw2] + iIm[i + m2] * twRe[tw2]
            scratchRe[2] = iRe[i + m3] * twRe[tw3] - iIm[i + m3] * twIm[tw3]
            scratchIm[2] = iRe[i + m3] * twIm[tw3] + iIm[i + m3] * twRe[tw3]

            scratchRe[5] = iRe[i] - scratchRe[1]
            scratchIm[5] = iIm[i] - scratchIm[1]
            iRe[i] = iRe[i] + scratchRe[1]
            iIm[i] = iIm[i] + scratchIm[1]

            scratchRe[3] = scratchRe[0] + scratchRe[2]
            scratchIm[3] = scratchIm[0] + scratchIm[2]
            scratchRe[4] = scratchRe[0] - scratchRe[2]
            scratchIm[4] = scratchIm[0] - scratchIm[2]

            iRe[i + m2] = iRe[i] - scratchRe[3]
            iIm[i + m2] = iIm[i] - scratchIm[3]
            tw1 = tw1 + fstride
            tw2 = tw2 + fstride * 2
            tw3 = tw3 + fstride * 3
            iRe[i] = iRe[i] + scratchRe[3]
            iIm[i] = iIm[i] + scratchIm[3]

            -- part dependent on isInverse
            iRe[i + m] = scratchRe[5] - scratchIm[4]
            iIm[i + m] = scratchIm[5] + scratchRe[4]
            iRe[i + m3] = scratchRe[5] + scratchIm[4]
            iIm[i + m3] = scratchIm[5] - scratchRe[4]
            -- //

            i = i + 1
            k = k - 1
        until k == 0
    end
end

local function butterfly3(iRe, iIm, oidx, fstride, twRe, twIm, isInverse, m, p)
    local k = m
    local m2 = m * 2
    local tw1, tw2 = 0, 0
    local epi3Re, epi3Im = twRe[fstride * m], twIm[fstride * m]
    local i = oidx
    local scratchRe, scratchIm = ffi.new("double[4]"), ffi.new("double[4]")

    repeat
        scratchRe[1] = iRe[i + m] * twRe[tw1] - iIm[i + m] * twIm[tw1]
        scratchIm[1] = iRe[i + m] * twIm[tw1] + iIm[i + m] * twRe[tw1]
        scratchRe[2] = iRe[i + m2] * twRe[tw2] - iIm[i + m2] * twIm[tw2]
        scratchIm[2] = iRe[i + m2] * twIm[tw2] + iIm[i + m2] * twRe[tw2]

        scratchRe[3] = scratchRe[1] + scratchRe[2]
        scratchIm[3] = scratchIm[1] + scratchIm[2]
        scratchRe[0] = scratchRe[1] - scratchRe[2]
        scratchIm[0] = scratchIm[1] - scratchIm[2]

        tw1 = tw1 + fstride
        tw2 = tw2 + fstride * 2

        iRe[i + m] = iRe[i] - scratchRe[3] * 0.5
        iIm[i + m] = iIm[i] - scratchIm[3] * 0.5

        scratchRe[0] = scratchRe[0] * epi3Im
        scratchIm[0] = scratchIm[0] * epi3Im
        iRe[i] = iRe[i] + scratchRe[3]
        iIm[i] = iIm[i] + scratchIm[3]

        iRe[i + m2] = iRe[i + m] + scratchIm[0]
        iIm[i + m2] = iIm[i + m] - scratchRe[0]

        iRe[i + m] = iRe[i + m] - scratchIm[0]
        iIm[i + m] = iIm[i + m] + scratchRe[0]

        i = i + 1
        k = k - 1
    until k == 0
end

-- TODO: This has ringing artefacts with pure sine inputs... if bug, needs fixing.
local function butterfly5(iRe, iIm, oidx, fstride, twRe, twIm, isInverse, m, p)
    local i0, i1, i2, i3, i4 = oidx + 0 * m, oidx + 1 * m, oidx + 2 * m, oidx + 3 * m, oidx + 4 * m
    local yaRe, ybRe = twRe[fstride * m], twRe[fstride * 2 * m]
    local yaIm, ybIm = twIm[fstride * m], twIm[fstride * 2 * m]
    local scratchRe, scratchIm = ffi.new("double[13]"), ffi.new("double[13]")

    for u = 0, m - 1 do
        scratchRe[0] = iRe[i0]
        scratchIm[0] = iIm[i0]

        --print(#twRe, u, u*fstride, 4*u*fstride, fstride*m, fstride*m*2)

        scratchRe[1] = iRe[i1] * twRe[1 * u * fstride] - iIm[i1] * twIm[1 * u * fstride]
        scratchIm[1] = iRe[i1] * twIm[1 * u * fstride] + iIm[i1] * twRe[1 * u * fstride]
        scratchRe[2] = iRe[i2] * twRe[2 * u * fstride] - iIm[i2] * twIm[2 * u * fstride]
        scratchIm[2] = iRe[i2] * twIm[2 * u * fstride] + iIm[i2] * twRe[2 * u * fstride]
        scratchRe[3] = iRe[i3] * twRe[3 * u * fstride] - iIm[i3] * twIm[3 * u * fstride]
        scratchIm[3] = iRe[i3] * twIm[3 * u * fstride] + iIm[i3] * twRe[3 * u * fstride]
        scratchRe[4] = iRe[i4] * twRe[4 * u * fstride] - iIm[i4] * twIm[4 * u * fstride]
        scratchIm[4] = iRe[i4] * twIm[4 * u * fstride] + iIm[i4] * twRe[4 * u * fstride]

        scratchRe[7] = scratchRe[1] + scratchRe[4]
        scratchIm[7] = scratchIm[1] + scratchIm[4]
        scratchRe[10] = scratchRe[1] - scratchRe[4]
        scratchIm[10] = scratchIm[1] - scratchIm[4]
        scratchRe[8] = scratchRe[2] + scratchRe[3]
        scratchIm[8] = scratchIm[2] + scratchIm[3]
        scratchRe[9] = scratchRe[2] - scratchRe[3]
        scratchIm[9] = scratchIm[2] - scratchIm[3]

        iRe[i0] = iRe[i0] + scratchRe[7] + scratchRe[8]
        iIm[i0] = iIm[i0] + scratchIm[7] + scratchIm[8]

        scratchRe[5] = scratchRe[0] + scratchRe[7] * yaRe + scratchRe[8] * ybRe
        scratchIm[5] = scratchIm[0] + scratchIm[7] * yaRe + scratchIm[8] * ybRe

        scratchRe[6] = scratchIm[10] * yaIm + scratchIm[9] * ybIm
        scratchIm[6] = -scratchRe[10] * yaIm + scratchRe[9] * ybIm

        iRe[i1] = scratchRe[5] - scratchRe[6]
        iIm[i1] = scratchIm[5] - scratchIm[6]
        iRe[i4] = scratchRe[5] + scratchRe[6]
        iIm[i4] = scratchIm[5] + scratchIm[6]

        scratchRe[11] = scratchRe[0] + scratchRe[7] * ybRe + scratchRe[8] * yaRe
        scratchIm[11] = scratchIm[0] + scratchIm[7] * ybRe + scratchIm[8] * yaRe

        scratchRe[12] = -scratchIm[10] * ybIm + scratchIm[9] * yaIm
        scratchIm[12] = scratchRe[10] * ybIm - scratchRe[9] * yaIm

        iRe[i2] = scratchRe[11] + scratchRe[12]
        iIm[i2] = scratchIm[11] + scratchIm[12]
        iRe[i3] = scratchRe[11] - scratchRe[12]
        iIm[i3] = scratchIm[11] - scratchIm[12]

        i0 = i0 + 1
        i1 = i1 + 1
        i2 = i2 + 1
        i3 = i3 + 1
        i4 = i4 + 1
    end
end

-- TODO: This has ringing artefacts with pure sine inputs... if bug, needs fixing.
local function butterflyG(iRe, iIm, oidx, fstride, twRe, twIm, isInverse, m, p)
    local n = ffi.sizeof(iRe) / ffi.sizeof("double")
    local scratchRe, scratchIm = ffi.new("double[" .. p .. "]"), ffi.new("double[" .. p .. "]")

    for u = 0, m - 1 do
        local k = u
        for q1 = 0, p - 1 do
            scratchRe[q1] = iRe[oidx + k]
            scratchIm[q1] = iIm[oidx + k]
            k = k + m
        end
        k = u
        for q1 = 0, p - 1 do
            local twidx = 0
            iRe[oidx + k] = scratchRe[0]
            iIm[oidx + k] = scratchIm[0]
            for q = 1, p - 1 do
                twidx = twidx + fstride * k
                --if twidx >= n then twidx = twidx - n end
                --twidx = ((twidx - 1) % n) + 1
                twidx = twidx % n
                --print(u,q1,q, iRe[oidx+k], scratchRe[q], twRe[1+twidx], scratchIm[q], twIm[1+twidx], 1+twidx, #twRe, #twIm, n)

                iRe[oidx + k] = iRe[oidx + k] + (scratchRe[q] * twRe[twidx] - scratchIm[q] * twIm[twidx])
                iIm[oidx + k] = iIm[oidx + k] + (scratchRe[q] * twIm[twidx] + scratchIm[q] * twRe[twidx])
            end
            k = k + m
        end
    end
end

local bfyEnum = {butterflyG, butterfly2, butterfly3, butterfly4, butterfly5}
setmetatable(
    bfyEnum,
    {__index = function(t, k)
            return t[1]
        end}
)

----
return bfyEnum
