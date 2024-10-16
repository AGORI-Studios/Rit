---@class Keyboard
local Keyboard = Class:extend("Keyboard")

function Keyboard:new(controls)
    self.controls = controls

    self.keys = {}
    self.pressed = {}
    self.released = {}
    self.down = {}
end

function Keyboard:update()
    for control, key in pairs(self.controls) do
        self.pressed[control] = false
        self.released[control] = false
        -- dont reset the down until ALL keys are checked
        local down = false
        for i, k in ipairs(key) do
            if self.keys[k] then
                down = true
            end
            if self.keys[k] and not self.down[control] then
                self.pressed[control] = true
                self.down[control] = true
            end
            if not self.keys[k] and self.down[control] then
                self.released[control] = true
                self.down[control] = false
                self.pressed[control] = false
                self.keys[k] = false
            end
        end
        self.down[control] = down
    end
end

function Keyboard:keypressed(key)
    for control, k in pairs(self.controls) do
        for i, v in ipairs(k) do
            if v == key then
                self.keys[v] = true

                break
            end
        end
    end
end

function Keyboard:keyreleased(key)
    for control, k in pairs(self.controls) do
        for i, v in ipairs(k) do
            if v == key then
                self.keys[v] = false

                break
            end
        end
    end
end

---@param control string
function Keyboard:isDown(control)
    return self.down[control]
end

---@param control string
function Keyboard:wasPressed(control)
    return self.pressed[control]
end

---@param control string
function Keyboard:wasReleased(control)
    return self.released[control]
end

return Keyboard
