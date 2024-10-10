local path = ... .. "."
-- replace all . with / 
path = string.gsub(path, "%.", "/")
local os = love.system.getOS()
local arch = jit.arch

if not love.filesystem.getInfo("DLL") then
    love.filesystem.createDirectory("DLL")
end

if os == "Windows" then
    if arch == "x64" then
        -- copy all files in ./Win64 to DLL/
        local files = love.filesystem.getDirectoryItems(path .. "Win64")
        for _, file in ipairs(files) do
            love.filesystem.write("DLL/" .. file, love.filesystem.read(path .. "Win64/" .. file))
        end
    else
        print("UNSUPPORTED ARCHITECTURE! " .. arch)
    end
elseif os == "OS X" then
    print("MAC OS X NOT CURRENTLY SUPPORTED!")
elseif os == "Linux" then
    print("LINUX NOT CURRENTLY SUPPORTED!")
else
    print("UNSUPPORTED OS! " .. os)
end

love.filesystem.setCRequirePath("DLL/?.dll;DLL/?/init.dll;DLL/?.so;DLL/?/init.so;DLL/?.dylib;DLL/?/init.dylib")

tryExcept(function()
    DLL_Video = require("video")
end)

tryExcept(function()
    DLL_Https = require("https")
end)
