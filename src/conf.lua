require "love.window"
local desktopWidth, desktopHeight = love.window.getDesktopDimensions()
function love.conf(t)
    t.identity = "Rit"

    t.window.title = "Rit"
    t.window.width = desktopWidth * 0.8
    t.window.height = desktopHeight * 0.8
    t.window.vsync = 0
    t.window.resizable = true

    t.modules.physics = false

    t.renderers = {"opengl", "vulkan"}
end
