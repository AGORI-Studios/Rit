---@class Mouse
local Mouse = Class:extend("Mouse")

function Mouse:new(controls)
    self.controls = controls

    self.keys = {}
    self.pressed = {}
    self.released = {}
    self.down = {}
end

function Mouse:update()
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
            end
            if not self.keys[k] and self.down[control] then
                self.released[control] = true
            end
        end
        self.down[control] = down
    end
end

function Mouse:mousepressed(b)
    for control, k in pairs(self.controls) do
        for i, v in ipairs(k) do
            if tonumber(v) == b then
                self.keys[v] = true
                self.down[control] = true

                break
            end
        end
    end
end

function Mouse:mousereleased(b)
    for control, k in pairs(self.controls) do
        for i, v in ipairs(k) do
            if tonumber(v) == b then
                self.keys[v] = false
                self.down[control] = false

                break
            end
        end
    end
end

---@param control string
function Mouse:isDown(control)
    return self.down[control]
end

---@param control string
function Mouse:wasPressed(control)
    return self.pressed[control]
end

---@param control string
function Mouse:wasReleased(control)
    return self.released[control]
end

return Mouse