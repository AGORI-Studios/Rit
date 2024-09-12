---@class Tween
local Tween = Class:extend("Tween")

---@param options table
---@param manager TweenManager
function Tween:new(options, manager)
    self.manager = manager
    self.active = false
    self.duration = 0
    local options = options or {}
    self.ease = options.ease
    if self.ease then
        if type(self.ease) == "string" then
            self.ease = Ease[self.ease]
        end
    end
    self.onStart = options.onStart
    self.onUpdate = options.onUpdate
    self.onComplete = options.onComplete
    self.type = options.type or TweenType.ONESHOT
    self.percent = 0
    self.finished = nil
    self.scale = 0
    self.backward = false
    self.time = 0
    self.executions = 0
    self.startDelay = options.startDelay or 0
    self.loopDelay = options.loopDelay or 0
    self._secondsSinceStart = 0
    self._delayToUse = 0
    self._running = false
    self._waitingForRestart = false
    self._chainedTweens = {}
    self._nextTweenInChain = nil
    self._object = nil
end

function Tween:destroy()
    self.onStart = nil
    self.onUpdate = nil
    self.onComplete = nil
    self.ease = nil
    self.manager = nil
    self._chainedTweens = nil
    self._nextTweenInChain = nil
end

---@param tween Tween
function Tween:_then(tween)
    return self:addChainedTween(tween)
end

---@param delay number
function Tween:wait(delay)
    return self:addChainedTween(Tween:new({type = TweenType.ONESHOT}, self.manager))
end

---@param tween Tween
function Tween:addChainedTween(tween)
    tween:setVarsOnEnd()
    tween.manager:remove(tween, false)

    if not self._chainedTweens then
        self._chainedTweens = {}
    end

    table.insert(self._chainedTweens, tween)
    return self
end

---@param dt any
function Tween:update(dt)
    self._secondsSinceStart = self._secondsSinceStart + dt
    local delay = (self.executions > 0) and self.loopDelay or self.startDelay
    if self._secondsSinceStart < delay then
        return
    end
    self.scale = math.max((self._secondsSinceStart - delay), 0) / self.duration
    if self.ease then
        self.scale = self.ease(self.scale)
    end
    if self.backward then
        self.scale = 1 - self.scale
    end
    if self._secondsSinceStart > delay and not self._running then
        self._running = true
        if self.onStart then
            self.onStart(self)
        end
    end
    if self._secondsSinceStart >= self.duration + delay then
        self.scale = (self.backward) and 0 or 1
        self.finished = true
    else
        if self.onUpdate then
            self.onUpdate(self, self._object, self.scale)
        end
    end
end

function Tween:start()
    self._waitingForRestart = false
    self._secondsSinceStart = 0
    self._delayToUse = (self.executions > 0) and self.loopDelay or self.startDelay
    if self.duration == 0 then
        self.active = false
        return self
    end
    self.active = true
    self._running = false
    self.finished = false
    return self
end

function Tween:cancel()
    self:onEnd()
    if self.manager then
        self.manager:remove(self)
    end
end

function Tween:cancelChain()
    if self._nextTweenInChain then
        self._nextTweenInChain:cancelChain()
    end
    if self._chainedTweens then
        self._chainedTweens = nil
    end
    self:cancel()
end

function Tween:finish()
    self.executions = self.executions + 1
    if self.onComplete then
        self.onComplete(self)
    end

    local type = bit.band(self.type, bit.bnot(TweenType.BACKWARD))
    if type == TweenType.PERSIST or type == TweenType.ONESHOT then
        self:onEnd()
        self._secondsSinceStart = self.duration + self.startDelay
        if type == TweenType.ONESHOT and self.manager then
            self.manager:remove(self)
        end
    end
    if type == TweenType.LOOPING or type == TweenType.PINGPONG then
        self._secondsSinceStart = (self._secondsSinceStart - self._delayToUse) % self.duration + self._delayToUse
        self.scale = math.max((self._secondsSinceStart - self._delayToUse), 0) / self.duration
        if self.ease and self.scale > 0 and self.scale < 1 then
            self.scale = self.ease(self.scale)
        end
        if type == TweenType.PINGPONG then
            self.backward = not self.backward
            if self.backward then
                self.scale = 1 - self.scale
            end
        end
        self:restart()
    end
end

function Tween:onEnd()
    self:setVarsOnEnd()
    self:processTweenChain()
end

function Tween:setVarsOnEnd()
    self.active = false
    self._running = false
    self.finished = true
end

function Tween:processTweenChain()
    if not self._chainedTweens or #self._chainedTweens <= 0 then
        return
    end
    self._nextTweenInChain = table.remove(self._chainedTweens, 1)
    self:doNextTween(self._nextTweenInChain)
    self._chainedTweens = nil
end

---@param tween Tween
function Tween:doNextTween(tween)
    if not tween.active then
        tween:start()
        self.manager:add(tween)
    end
    tween:setChain(self._chainedTweens)
end

---@param previousChain table
function Tween:setChain(previousChain)
    if previousChain then
        if not self._chainedTweens then
            self._chainedTweens = previousChain
        else
            for _, t in ipairs(previousChain) do
                table.insert(self._chainedTweens, t)
            end
        end
    end
end

function Tween:restart()
    if self.active then
        self:start()
    else
        self._waitingForRestart = true
    end
end

---@param object any
---@param field any
---@return boolean
function Tween:isTweenOf(object, field)
    return false
end

---@param startDelay number
---@param loopDelay number
---@return Tween
function Tween:setDelays(startDelay, loopDelay)
    self.startDelay = startDelay or 0
    self.loopDelay = loopDelay or 0
    return self
end

---@param value number
---@return number
function Tween:set_startDelay(value)
    local dly = math.abs(value)
    if self.executions == 0 then
        self._delayToUse = dly
    end
    return dly
end

---@param value number
---@return number
function Tween:set_loopDelay(value)
    local dly = math.abs(value)
    if self.executions > 0 then
        self._secondsSinceStart = self.duration * self.percent + math.max((dly - self.loopDelay), 0)
        self._delayToUse = dly
    end
    return dly
end

function Tween:get_time()
    return math.max(self._secondsSinceStart - self._delayToUse, 0)
end

function Tween:get_percent()
    return self:get_time() / self.duration
end

---@param value number
function Tween:set_percent(value)
    self._secondsSinceStart = self.duration * value + self._delayToUse
    return value
end

---@param value number
function Tween:set_type(value)
    if value == 0 then
        value = TweenType.ONESHOT
    elseif value == TweenType.BACKWARD then
        value = bit.bor(TweenType.PERSIST, TweenType.BACKWARD)
    end
    self.backward = bit.band(value, TweenType.BACKWARD) > 0
    self.type = value
    return value
end

---@param value boolean
function Tween:set_active(value)
    self.active = value
    if self._waitingForRestart then
        self:restart()
    end
    return value
end

return Tween
