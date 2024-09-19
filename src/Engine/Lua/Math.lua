function math.lerp(a, b, t)
    return a + (b - a) * t
end

function math.fpsLerp(a, b, t, dt)
    return a + (b - a) * (1 - math.exp(-t * dt))
end

function math.clamp(x, min, max)
    return x < min and min or (x > max and max or x)
end

local storageUnit = {
    B = 1,
    KB = 1024,
    MB = 1024^2,
    GB = 1024^3,
    TB = 1024^4,
    PB = 1024^5,
    EB = 1024^6,
    ZB = 1024^7,
    YB = 1024^8
}

function math.formatStorage(size)
    size = tonumber(size or 0) or 0
    -- automatically choose the best unit
    local unit = "B"
    local unitSize = storageUnit[unit] or 1
    while (size or 0) >= 1024 and (unitSize or 1) < storageUnit.YB do
        size = size / 1024
        unit = next(storageUnit, unit)
        unitSize = storageUnit[unit]
    end

    return string.format("%.2f %s", size, unit)
end