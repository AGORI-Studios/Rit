local allSettings

return {
    enter = function(self)
        -- load all of da settings into a table
        --[[ -- settings layout
            ["Game"] = {
                ["Downscroll"] = true,
                ["Scroll speed"] = 1.0,
                ["Scroll Velocities"] = true,
                ["Start Time"] = true,
                ["Note Spacing"] = 200,
                ["Autoplay"] = false,
                ["Audio Offset"] = 0
            },
            ["Graphics"] = {
                ["Width"] = 1280,
                ["Height"] = 720,
                ["Fullscroll"] = false,
                ["Vsync"] = false
            },
            ["Audio"] = {
                ["Volume"] = 1.0
            },
            ["System"] = {
                ["Version"] = "settingsVer1/0.0.3-beta"
            }
        --]] -- this table is called "settings"

        allSettings = {}
        for k,v in pairs(settings) do
            table.insert(allSettings, k)
        end

        curSetting = 1
        curOption = ""
    end,

    update = function(self, dt)
        if input:pressed("down") then
            if curOption == "" then
                curSetting = curSetting + 1
                if curSetting > #allSettings then
                    curSetting = 1
                end
            elseif curOption == "Game" then

            elseif curOption == "Graphics" then

            elseif curOption == "Audio" then

            end
        elseif input:pressed("up") then
            if curOption == "" then
                curSetting = curSetting - 1
                if curSetting < 1 then
                    curSetting = #allSettings
                end
            elseif curOption == "Game" then

            elseif curOption == "Graphics" then

            elseif curOption == "Audio" then

            end
        end

        if input:pressed("confirm") then 
            if curOption == "" then
                curOption = allSettings[curSetting]
            elseif curOption == "Game" then
                
            elseif curOption == "Graphics" then
                
            elseif curOption == "Audio" then
                
            end
        end
    end,

    draw = function(self)
    end
}