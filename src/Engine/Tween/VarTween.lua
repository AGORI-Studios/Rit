---@class VarTween : Tween
local VarTween = Tween:extend("VarTween")

local VarTweenProperty = {}
VarTweenProperty.__index = VarTweenProperty

---@param options table
---@param manager TweenManager
function VarTween:new(options, manager)
    Tween.new(self, options, manager)
end

---@param object table
---@param properties table
---@param duration number
function VarTween:tween(object, properties, duration)
    if object == nil then
        error("Cannot tween variables of an object that is nil.")
    elseif properties == nil then
        error("Cannot tween nil properties.")
    end

    self._object = object
    self._properties = properties
    self._propertyInfos = {}
    self.duration = duration
    self:start()
    self:initializeVars()
    return self
end

---@param dt number
function VarTween:update(dt)
    local delay = (self.executions > 0) and self.loopDelay or self.startDelay

    if self._secondsSinceStart < delay then
        Tween.update(self, dt)
    else
        if not self._propertyInfos[1].startValue then
            self:setStartValues()
        end

        Tween.update(self, dt)

        if self.active then
            for _, info in ipairs(self._propertyInfos) do
                info.object[info.field] = info.startValue + info.range * self.scale
            end
        end
    end
end

function VarTween:initializeVars()
    local fieldPaths = {}

    if type(self._properties) == "table" then
        for fieldPath in pairs(self._properties) do
            table.insert(fieldPaths, fieldPath)
        end
    else
        error("Unsupported properties container - use a table containing key/value pairs.")
    end

    for _, fieldPath in ipairs(fieldPaths) do
        local target = self._object
        local path = {}
        for component in fieldPath:gmatch("[^.]+") do
            table.insert(path, component)
        end

        local field = table.remove(path)
        for _, component in ipairs(path) do
            target = target[component]
            if type(target) ~= "table" then
                error('The object does not have the property "' .. component .. '" in "' .. fieldPath .. '"')
            end
        end

        local propertyInfo = {
            object = target,
            field = field,
            startValue = nil,
            range = self._properties[fieldPath]
        }
        table.insert(self._propertyInfos, propertyInfo)
    end
end

function VarTween:setStartValues()
    for _, info in ipairs(self._propertyInfos) do
        if info.object[info.field] == nil then
            error('The object does not have the property "' .. info.field .. '"')
        end

        local value = info.object[info.field]
        if type(value) ~= "number" then
            error('The property "' .. info.field .. '" is not numeric.')
        end

        info.startValue = value
        info.range = info.range - value
    end
end

function VarTween:destroy()
    Tween.destroy(self)
    self._object = nil
    self._properties = nil
    self._propertyInfos = nil
end

---@param object table
---@param field string
function VarTween:isTweenOf(object, field)
    if object == self._object and field == nil then
        return true
    end

    for _, property in ipairs(self._propertyInfos) do
        if object == property.object and (field == property.field or field == nil) then
            return true
        end
    end

    return false
end

return VarTween
