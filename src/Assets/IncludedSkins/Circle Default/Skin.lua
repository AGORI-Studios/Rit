-- Skin (not) automatically generated using Rit's skin editor
local Skin = {}

Skin.HUD = {
    TopLeft = {
        members = {
            {
                type = "Text",
                x = 0,
                y = 0,
                format = "{math.floor(%d)}",
                value = "score",
                font = nil,
                size = 12,
                color = {1, 1, 1, 1}
            },
            {
                type = "Text",
                x = 0,
                y = 20,
                format = "{math.floor(%d*100)}",
                value = "accuracy",
                font = nil,
                size = 12,
                color = {1, 1, 1, 1}
            }
        }
    }
}

return Skin