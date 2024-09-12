---@class TweenManager
local TweenManager = Class:extend("TweenManager")

TweenManager._tweens = {}

function TweenManager:new()
    self._tweens = {}
    -- Initialization code
end

---@param Object table
---@param Values table
---@param Duration number
---@param Options table
function TweenManager:tween(Object, Values, Duration, Options)
    local tween = VarTween(Options, self)
    tween:tween(Object, Values, Duration)
    return self:add(tween)
end

--[[ function TweenManager:num(FromValue, ToValue, Duration, Options, TweenFunction)
    local tween = NumTween(Options, self)
    tween:tween(FromValue, ToValue, Duration, TweenFunction)
    return self:add(tween)
end

function TweenManager:flicker(basic, duration, period, options)
    local tween = FlickerTween(options, self)
    tween:tween(basic, duration, period)
    return self:add(tween)
end ]]

---@param basic table
function TweenManager:isFlickering(basic)
    return self:containsTweensOf(basic, {"flicker"})
end

---@param basic table
function TweenManager:stopFlickering(basic)
    self:cancelTweensOf(basic, {"flicker"})
end

--[[ function TweenManager:shake(Sprite, Intensity, Duration, Axes, Options)
    local tween = ShakeTween(Options, self)
    tween:tween(Sprite, Intensity, Duration, Axes)
    return self:add(tween)
end

function TweenManager:angle(Sprite, FromAngle, ToAngle, Duration, Options)
    local tween = AngleTween(Options, self)
    tween:tween(FromAngle, ToAngle, Duration, Sprite)
    return self:add(tween)
end

function TweenManager:color(Sprite, Duration, FromColor, ToColor, Options)
    local tween = ColorTween(Options, self)
    tween:tween(Duration, FromColor, ToColor, Sprite)
    return self:add(tween)
end

function TweenManager:linearMotion(Object, FromX, FromY, ToX, ToY, DurationOrSpeed, UseDuration, Options)
    local tween = LinearMotion(Options, self)
    tween:setObject(Object)
    tween:setMotion(FromX, FromY, ToX, ToY, DurationOrSpeed, UseDuration)
    return self:add(tween)
end

function TweenManager:quadMotion(Object, FromX, FromY, ControlX, ControlY, ToX, ToY, DurationOrSpeed, UseDuration, Options)
    local tween = QuadMotion(Options, self)
    tween:setObject(Object)
    tween:setMotion(FromX, FromY, ControlX, ControlY, ToX, ToY, DurationOrSpeed, UseDuration)
    return self:add(tween)
end

function TweenManager:cubicMotion(Object, FromX, FromY, aX, aY, bX, bY, ToX, ToY, Duration, Options)
    local tween = CubicMotion(Options, self)
    tween:setObject(Object)
    tween:setMotion(FromX, FromY, aX, aY, bX, bY, ToX, ToY, Duration)
    return self:add(tween)
end

function TweenManager:circularMotion(Object, CenterX, CenterY, Radius, Angle, Clockwise, DurationOrSpeed, UseDuration, Options)
    local tween = CircularMotion(Options, self)
    tween:setObject(Object)
    tween:setMotion(CenterX, CenterY, Radius, Angle, Clockwise, DurationOrSpeed, UseDuration)
    return self:add(tween)
end

function TweenManager:linearPath(Object, Points, DurationOrSpeed, UseDuration, Options)
    local tween = LinearPath(Options, self)
    for _, point in ipairs(Points) do
        tween:addPoint(point.x, point.y)
    end
    tween:setObject(Object)
    tween:setMotion(DurationOrSpeed, UseDuration)
    return self:add(tween)
end

function TweenManager:quadPath(Object, Points, DurationOrSpeed, UseDuration, Options)
    local tween = QuadPath(Options, self)
    for _, point in ipairs(Points) do
        tween:addPoint(point.x, point.y)
    end
    tween:setObject(Object)
    tween:setMotion(DurationOrSpeed, UseDuration)
    return self:add(tween)
end ]]

function TweenManager:destroy()
    -- Cleanup code
end

---@param dt number
function TweenManager:update(dt)
    local finishedTweens = {}
    for _, tween in ipairs(self._tweens) do
        if not tween.active then
            goto continue
        end
        tween:update(dt)
        if tween.finished then
            table.insert(finishedTweens, tween)
        end
        ::continue::
    end

    for _, tween in ipairs(finishedTweens) do
        tween:finish()
    end
end

---@param Tween Tween
---@param Start? boolean
function TweenManager:add(Tween, Start)
    if not Tween then
        return nil
    end
    table.insert(self._tweens, Tween)
    if Start then
        Tween:start()
    end
    return Tween
end

---@param Tween Tween
---@param Destroy? boolean
function TweenManager:remove(Tween, Destroy)
    if not Tween then
        return nil
    end
    Tween.active = false
    if Destroy then
        Tween:destroy()
    end
    for i, t in ipairs(self._tweens) do
        if t == Tween then
            table.remove(self._tweens, i)
            break
        end
    end
    return Tween
end

function TweenManager:clear()
    for _, tween in ipairs(self._tweens) do
        if tween then
            tween.active = false
            tween:destroy()
        end
    end
    self._tweens = {}
end

---@param Object table
---@param FieldPaths table
function TweenManager:cancelTweensOf(Object, FieldPaths)
    self:forEachTweensOf(Object, FieldPaths, function(tween)
        tween:cancel()
    end)
end

---@param Object table  
---@param FieldPaths table
function TweenManager:completeTweensOf(Object, FieldPaths)
    self:forEachTweensOf(Object, FieldPaths, function(tween)
        if (bit.band(tween.type, TweenType.LOOPING) == 0) and (bit.band(tween.type, TweenType.PINGPONG) == 0) and tween.active then
            tween:update(0)
        end
    end)
end

---@param object table
---@param fieldPaths table
---@param func function
function TweenManager:forEachTweensOf(object, fieldPaths, func)
    if not object then
        error("Cannot cancel tween variables of an object that is null.")
    end
    
    if not fieldPaths or #fieldPaths == 0 then
        for i = #self._tweens, 1, -1 do
            local tween = self._tweens[i]
            if tween:isTweenOf(object) then
                func(tween)
            end
        end
    else
        local propertyInfos = {}
        for _, fieldPath in ipairs(fieldPaths) do
            local target = object
            local path = string.split(fieldPath, ".")
            local field = table.remove(path)
            for _, component in ipairs(path) do
                target = target[component]
                if not target then
                    break
                end
            end
            if target then
                table.insert(propertyInfos, {object = target, field = field})
            end
        end
        
        for i = #self._tweens, 1, -1 do
            local tween = self._tweens[i]
            for _, info in ipairs(propertyInfos) do
                if tween:isTweenOf(info.object, info.field) then
                    func(tween)
                    break
                end
            end
        end
    end
end

---@param object table
---@param fieldPaths table
function TweenManager:containsTweensOf(object, fieldPaths)
    local found = false
    self:forEachTweensOf(object, fieldPaths, function()
        found = true
    end)
    return found
end

function TweenManager:completeAll()
    for _, tween in ipairs(self._tweens) do
        if (bit.band(tween.type, TweenType.LOOPING) == 0) and (bit.band(tween.type, TweenType.PINGPONG) == 0) and tween.active then
            tween:update(0)
        end
    end
end

---@param func function
function TweenManager:forEach(func)
    for _, tween in ipairs(self._tweens) do
        func(tween)
    end
end

return TweenManager
