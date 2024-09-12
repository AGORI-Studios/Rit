Input = Class:extend("Input")

-- take note of "Keyboard" input class. This is the class that will be used to then call keyboard ones (to extend onto mouse and joystick in the future)

function Input:new(controls)
    self.controls = controls
    --[[
    Layout:
    {
        name = {"bind1", "bind2", "bind3"}
    }
    ]]
    
    self.keyboardControls = {}

    for control, key in pairs(controls) do
        self.keyboardControls[control] = {}
        for i, k in ipairs(key) do
            table.insert(self.keyboardControls[control], k)
        end
    end

    self.keyboardBase = Keyboard(self.keyboardControls)
end

function Input:update()
    self.keyboardBase:update()
end

function Input:keypressed(key)
    self.keyboardBase:keypressed(key)
end

function Input:keyreleased(key)
    self.keyboardBase:keyreleased(key)
end

function Input:isDown(control)
    if self.keyboardControls[control] then
        return self.keyboardBase:isDown(control)
    end
end

function Input:wasPressed(control)
    if self.keyboardControls[control] then
        return self.keyboardBase:wasPressed(control)
    end
end

function Input:wasReleased(control)
    if self.keyboardControls[control] then
        return self.keyboardBase:wasReleased(control)
    end
end

return Input