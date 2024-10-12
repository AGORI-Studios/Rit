---@diagnostic disable: duplicate-set-field
local defaultGlobals = {}
for k, _ in pairs(_G) do
    table.insert(defaultGlobals, k)
end
jit.on()
jit.opt.start(4,
    "hotloop=1", "hotexit=2", "loopunroll=8", "-sink",
    "-fold", "-cse", "-fuse", "-abc", "-dse", "-loop"
)
love.audio.setVolume(0.25)

require("Engine")
require("Game")

local GENERATE_GLOBALS_LIST = false

function love.load(args)
    if args and (args[1] or "") == "-globals" then
        GENERATE_GLOBALS_LIST = true
    end
    -- disable dangerous os functions
    os.execute = function() end
    os.exit = function() end
    os.remove = function() end
    os.rename = function() end
    os.setlocale = function() end
    os.tmpname = function() end
end

function love.update(dt)
    Input:update()
    Cache:update()
    Game:update(dt)

    if DiscordRPC then
        DiscordRPC.timer = DiscordRPC.timer + dt
        if DiscordRPC.timer >= DiscordRPC.maxTimer then
            DiscordRPC.timer = 0

            DiscordRPC.runCallbacks()
        end
    end
end

function love.resize(w, h)
    Game:resize(w, h)
    Game._windowWidth = w
    Game._windowHeight = h
end

function love.keypressed(key, scancode, isrepeat)
    Input:keypressed(key)
    Game:keypressed(key, scancode, isrepeat)
end

function love.keyreleased(key, scancode)
    Input:keyreleased(key)
    Game:keyreleased(key, scancode)
end

function love.mousepressed(x, y, button, istouch, presses)
    Game:mousepressed(x, y, button, istouch, presses)
    Input:mousepressed(button)

    if VirtualPad and VirtualPad._CURRENT and not istouch then
        VirtualPad._CURRENT:mousepressed(x, y, button)
    end
end

function love.mousereleased(x, y, button, istouch, presses)
    Game:mousereleased(x, y, button, istouch, presses)
    Input:mousereleased(button)

    if VirtualPad and VirtualPad._CURRENT and not istouch then
        VirtualPad._CURRENT:mousereleased(x, y, button)
    end
end

function love.wheelmoved(x, y)
    Game:wheelmoved(x, y)
end

function love.mousemoved(x, y, dx, dy, istouch)
    Game:mousemoved(x, y, dx, dy, istouch)

    if VirtualPad and VirtualPad._CURRENT and not istouch then
        VirtualPad._CURRENT:mousemoved(x, y, dx, dy, istouch)
    end
end

function love.textinput(t)
    Game:textinput(t)
end

function love.draw()
    Game:draw()

    if not love.system.isMobile() then return end
    love.graphics.push()
    love.graphics.scale(Game._windowWidth / Game._gameWidth, Game._windowHeight / Game._gameHeight)
    if VirtualPad and VirtualPad._CURRENT then
        VirtualPad._CURRENT:draw()
    end
    love.graphics.pop()
end

function love.quit()
    if GENERATE_GLOBALS_LIST then
        local globalList = {}
        for k, _ in pairs(_G) do
            table.insert(globalList, k)
        end
        -- remove the default globals
        for _, v in ipairs(defaultGlobals) do
            table.remove(globalList, table.findID(globalList, v))
        end
        table.sort(globalList)

        print("Writing global list to file")

        love.filesystem.write("globalList.txt", table.concat(globalList, "\n"))
    end

    Game:quit()
end
