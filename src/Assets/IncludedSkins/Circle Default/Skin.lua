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
            },
            {
                type = "Sprite",
                x = 1500,
                y = 0,
                path = "Game:Assets/Textures/test.png", -- when prefixed with "Game:", it will look for the file in the game's directory instead of the skin's directory
                scale = 0.15 -- scale can be a number or a table with x and y values
            }
        }
    }
}

Skin.Notes = {}

for laneCount = 1, 10 do
    Skin.Notes[laneCount] = {}
    for curLane = 1, laneCount do
        Skin.Notes[laneCount][curLane] = {
            ["Note"] = "notes/" .. laneCount .. "K/note" .. curLane .. ".png",
            ["Hold"] = "notes/" .. laneCount .. "K/note" .. curLane .. "-hold.png",
            ["End"] = "notes/" .. laneCount .. "K/note" .. curLane .. "-end.png",

            ["Pressed"] = "notes/" .. laneCount .. "K/receptor" .. curLane .. "-pressed.png",
            ["Unpressed"] = "notes/" .. laneCount .. "K/receptor" .. curLane .. "-unpressed.png",
        }
        print(Skin.Notes[laneCount][curLane]["Hold"])
    end
end

Skin.Scripts = {}

Skin.Scripts.States = {
    TitleMenu = "scripts/states/TitleMenu.lua",
    SongListMenu = "scripts/states/SongListMenu.lua",
}

return Skin