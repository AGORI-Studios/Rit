local SplashScreen = state()

function SplashScreen:enter()
    switchState(states.menu.StartMenu, 0.3)
end

function SplashScreen:update(dt)
    
end

function SplashScreen:draw()
    
end

return SplashScreen