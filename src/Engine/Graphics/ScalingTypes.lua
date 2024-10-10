---@enum ScalingTypes
local ScalingTypes = {
    STRETCH = 1,
    ASPECT_FIXED = 2,
    WINDOW_FIXED = 4,
    WINDOW_STRETCH = 8,
    STRETCH_Y = 16,
    STRETCH_X = 32,
    WINDOW_LARGEST = 64,
}

return ScalingTypes
