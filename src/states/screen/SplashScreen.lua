local SplashScreen = state()
local timer = 0
local fade = {1}
local progression = 0
local positions = {
    {x=0,y=-100},
    {x=0,y=1090}
}

function SplashScreen:enter()
    Timer.tween(1, positions[1], {y =__inits.__GAME_WIDTH/2-100}, "in-expo")
    Timer.after(1.5, function()
        Timer.tween(1, positions[2], {y =__inits.__GAME_HEIGHT/2}, "in-expo")

        Timer.after(1.5, function()
            Timer.tween(0.75, fade, {0}, "out-quad", function()
                state.switch(states.menu.StartMenu)
            end)
        end)
    end)
end

function SplashScreen:update(dt)
    
end

function SplashScreen:draw()
    love.graphics.setColor(1,1,1,fade[1])
    love.graphics.printf(
        "Rit.",
        positions[1].x, positions[1].y,
       __inits.__GAME_WIDTH/3,
        "center",
        0, 3, 3
    )
    love.graphics.printf(
        "A game by AGORI Studios.",
        positions[2].x, positions[2].y,
       __inits.__GAME_HEIGHT/3,
        "center",
        0, 3, 3
    )
    love.graphics.setColor(1,1,1,1)
end

return SplashScreen