local Input = {
    _NAME = "Input",
    _VERSION = "1.0.0",
    _DESCRIPTION = "A simple input library for LÖVE",
    _CREATOR = "GuglioIsStupid",
    _LICENSE = [[
        MIT LICENSE
    ]]
}

local Inputs = {
    __keys = {},
    
    isDown = function(self, name)
        return self.__keys[name].down
    end,
    isUp = function(self, name)
        return self.__keys[name].up
    end,
    isPressed = function(self, name)
        return self.__keys[name].pressed
    end,
    isReleased = function(self, name)
        return self.__keys[name].released
    end,
    rebindControl = function(self, name, controlTab)
        self.__keys[name].keys = controlTab
    end,

    joystick = nil
}

local function SetupKeys(settings)
    for name, keys in pairs(settings.inputs) do
        Inputs.__keys[name] = {
            pressed = false,
            released = false,
            down = false,
            up = false,
            keys = {}
        }
        for _, key in ipairs(keys) do
            -- starts with get if its mouse or key (mouse:1 or key:b)
            local keytype = key:gsub(":.+", "")
            if keytype ~= "mouse" and keytype ~= "key" and keytype ~= "joy" then
                keytype = "key"
            end
            -- get the key name (mouse:1 -> 1)
            local keyname = key:gsub(".+:", "")
            Inputs.__keys[name].keys[keyname] = keytype
        end
    end

    if settings.joystick then
        Inputs.joystick = settings.joystick
    end
end

function Input.Init(settings)
    SetupKeys(settings)
    return Inputs
end

function Inputs:Update()
    for name, keys in pairs(self.__keys) do
        -- minimalistic way to check if a key is pressed

        local pressed = false
        for key, setting in pairs(keys.keys) do
            if setting == "mouse" then
                pressed = pressed or love.mouse.isDown(key)
            elseif setting == "joy" and self.joystick then
                pressed = pressed or self.joystick:isDown(key)
            else
                pressed = pressed or love.keyboard.isDown(key)
            end
        end

        -- update key states
        keys.pressed = pressed and not keys.down
        keys.released = not pressed and keys.down   
        keys.down = pressed
        keys.up = not pressed
    end
end

function Inputs:UpdateControl(name, controlTab)
    -- rebinds a control to a new key
    self.__keys[name].keys = controlTab
end

return Input