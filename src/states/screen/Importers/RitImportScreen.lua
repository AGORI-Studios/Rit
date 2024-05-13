local RitImportScreen = state()
local os = love.system.getOS()
local sep = os == "Windows" and "\\" or "/"
local songsFolder = love.filesystem.getSaveDirectory() .. sep .. "songs"
local frame = 0 

function RitImportScreen:enter(arg)
    self.arg = arg
    print("Importing " .. self.arg)
    --[[ if self.arg:endsWith(".rit") then
        local name = self.arg:sub(1, -5)
        -- It's a chart
        -- use lovefs to copy the file to the songs folder
        importer:copy(self.arg, songsFolder .. sep .. name .. ".rit")
    end ]]
    frame = 0
end

function RitImportScreen:update(dt)
    frame = frame + 1
    
    if frame == 2 then

    end
end

function RitImportScreen:draw()
end

return RitImportScreen