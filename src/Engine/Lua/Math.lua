function math.lerp(a, b, t)
    return a + (b - a) * t
end

function math.fpsLerp(a, b, t, dt)
    return a + (b - a) * (1 - math.exp(-t * dt))
end