function love.load()
    input = (require "baton").new({ -- Load the input for it to work properly
        controls = {
            gameLeft = {'key:d', 'axis:leftx-', 'button:dpleft'},
            gameRight = {'key:k', 'axis:leftx+', 'button:dpright'},
            gameUp = {'key:j', 'axis:lefty-', 'button:dpup'},
            gameDown = {'key:f', 'axis:lefty+', 'button:dpdown'},
        },
        joystick = love.joystick.getJoysticks()[1]
    })

    receptors = {}
    game = require "game"
    quaverLoader = require "quaverLoader"
    charthits = {}
    for i = 1, 4 do
        charthits[i] = {}
    end
    love.graphics.setDefaultFilter("nearest", "nearest")
    noteEND = love.image.newImageData("skin/note-end.png")
    noteHOLD = love.image.newImageData("skin/note-hold.png")
    noteNORMAL = love.image.newImageData("skin/note.png")
    receptor = love.image.newImageData("skin/receptor-up.png")
    receptorDown = love.image.newImageData("skin/receptor-down.png")

    endnote = love.graphics.newImage(noteEND)

    for i = 1, 4 do
        receptors[i] = {love.graphics.newImage(receptor), love.graphics.newImage(receptorDown)}
    end


    fourkColours = {
        {255, 0, 0},
        {0, 255, 0},
        {0, 0, 255},
        {255, 255, 0}
    }
    sevenkColours = {
        {255, 0, 0},
        {0, 255, 0},
        {0, 0, 255},
        {255, 255, 0},
        {255, 0, 255},
        {0, 255, 255},
        {255, 255, 255}
    }
    game:enter()

    love.window.setMode(1280, 720)

    quaverLoader.load("chart.qua")

    PARTWHERERECEPTORSARE = 100
end

function love.update(dt)
    game:update(dt)
    input:update(dt)
end

function love.draw()
    game:draw()

    love.graphics.print(
        "FPS: " .. love.timer.getFPS() ..
        "\nMusic time: " .. musicTime, 
        10, 10
    )
end