function love.load()
    input = (require "baton").new({ -- Load the input for it to work properly
        controls = {
            one4 = {'key:d', 'axis:leftx-', 'button:dpleft'},
            two4 = {'key:k', 'axis:leftx+', 'button:dpright'},
            three4 = {'key:j', 'axis:lefty-', 'button:dpup'},
            four4 = {'key:f', 'axis:lefty+', 'button:dpdown'},

            one7 = {'key:s', 'axis:leftx-', 'button:dpleft'},
            two7 = {'key:d', 'axis:leftx+', 'button:dpright'},
            three7 = {'key:f', 'axis:lefty-', 'button:dpup'},
            four7 = {'key:space'},
            five7 = {'key:j', 'axis:lefty+', 'button:dpdown'},
            six7 = {'key:k'},
            seven7 = {'key:l'}
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
    musicTimeDo = false
    game:enter()

    love.window.setMode(1280, 720)

    quaverLoader.load("12.qua")

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