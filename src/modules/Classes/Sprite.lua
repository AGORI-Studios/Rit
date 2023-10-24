local Sprite = Object:extend()

Sprite.frame = 1
Sprite.frameWidth = 0
Sprite.frameHeight = 0
Sprite.frames = nil
Sprite.graphic = nil
Sprite.alpha = 1.0
Sprite.flipX, Sprite.flipY = false, false

Sprite.origin = Point()
Sprite.offset = Point()
Sprite.scale = Point(1, 1)
Sprite.shear = Point(0, 0)

Sprite.color = {1, 1, 1}

Sprite.clipRect = nil

Sprite.x, Sprite.y = 0, 0

local Stencil = {
    sprite = {},
    x = 0,
    y = 0
}
local function stencilFunc()
    if Stencil.sprite then
        love.graphics.push()
            love.graphics.translate(Stencil.x + Stencil.clipRect.x + Stencil.clipRect.width / 2, Stencil.y + Stencil.clipRect.y + Stencil.clipRect.height / 2)
            love.graphics.rotate(math.rad(Stencil.angle or 0))
            love.graphics.translate(-Stencil.clipRect.width / 2, -Stencil.clipRect.height / 2)
            love.graphics.rectangle("fill", -Stencil.clipRect.width /2, -Stencil.clipRect.height / 2, Stencil.clipRect.width, Stencil.clipRect.height)
        love.graphics.pop()
    end
end

function Sprite:new(x, y, graphic)
    self.x, self.y = x or 0, y or 0

    self.graphic = nil
    self.width, self.height = 0, 0

    self.alive, self.exists, self.visible = true, true, true

    self.origin = Point()
    self.offset = Point()
    self.scale = Point(1, 1)
    self.shear = Point(0, 0)

    self.clipRect = nil
    self.flipX, self.flipY = false, false

    self.alpha = 1
    self.color = {1, 1, 1}
    self.angle = 0 -- in degrees

    self.frames = nil -- todo.
    self.animations = nil -- todo.

    self.curAnim = nil
    self.curFrame = nil
    self.animFinished = false
    self.indexFrame = 1

    if graphic then self:load(graphic) end

    return self
end

function Sprite:load(graphic, animated, frameWidth, frameHeight)
    local graphic = graphic or nil
    local animated = animated or false
    local frameWidth = frameWidth or 0
    local frameHeight = frameHeight or 0

    if type(graphic) == "string" then
        graphic = Cache:loadImage(graphic)
    end
    self.graphic = graphic

    self.width = self.graphic:getWidth()
    self.height = self.graphic:getHeight()

    return self
end

function Sprite:getMidpoint()
    return Point(self.x + self.width / 2, self.y + self.height / 2)
end

function Sprite:update(dt)
end

function Sprite:play()
end

function Sprite:getFrameWidth()
    local frame = self:getCurrentFrame()
    if frame then
        return frame:getWidth()
    end
    return self.width
end

function Sprite:getFrameHeight()
    local frame = self:getCurrentFrame()
    if frame then
        return frame:getHeight()
    end
    return self.height
end

function Sprite:getFrameDimensions()
    return self:getFrameWidth(), self:getFrameHeight()
end

function Sprite:getCurrentFrame()
    if self.curAnim then
        return self.curAnim:getFrame(self.indexFrame)
    end
    return self.graphic
end

function Sprite:setGraphicSize(w, h)
    local w = w or 0
    local h = h or 0

    self.scale.x = w / self:getFrameWidth()
    self.scale.y = h / self:getFrameHeight()

    if w <= 0 then
        self.scale.x = self.scale.y
    elseif h <= 0 then
        self.scale.y = self.scale.x
    end

    return self
end

function Sprite:updateHitbox()
    local w, h = self:getFrameDimensions()

    self.width = math.abs(self.scale.x) * w
    self.height = math.abs(self.scale.y) * h

    self.offset = Point(-0.5 * (self.width - w), -0.5 * (self.height - h))
    self:centerOrigin()

    return self
end

function Sprite:centerOffsets()
    self.offset = Point(
        self:getFrameWidth() - self.width / 2,
        self:getFrameHeight() - self.height / 2
    )

    return self
end 

function Sprite:centerOrigin()
    self.origin = Point(self.width / 2, self.height / 2)

    return self
end

function Sprite:setScale(x, y)
    local x = x or 1
    local y = y or x or 1

    self.scale = Point(x, y)

    return self
end

function Sprite:kill()
    self.alive = false
    self.exists = false
end

function Sprite:revive()
    self.alive = true
    self.exists = true
end

function Sprite:destroy()
    self.exists = false
    self.graphic = nil

    self.origin = {x = 0, y = 0}
    self.offset = {x = 0, y = 0}
    self.scale = {x = 1, y = 1}
    
    self.frames = nil
    self.animations = nil
    
    self.curAnim = nil
    self.curFrame = nil
    self.animFinished = false
    self.animPaused = false
end

function Sprite:isHovered(x, y)
    local x = x or love.mouse.getX()
    local y = y or love.mouse.getY()

    -- account for the offset
    x = x - self.offset.x
    y = y - self.offset.y

    local width, height = self:getFrameDimensions()
    width = width * self.scale.x
    height = height * self.scale.y

    return x >= self.x and x <= self.x + width and y >= self.y and y <= self.y + height
end

function Sprite:draw()
    if self.exists and self.alive and self.visible and self.graphic then
        local frame = self:getCurrentFrame()

        if self.clipRect then
            love.graphics.setStencilTest("greater", 0)
        end
        local x, y = self.x, self.y
        local angle = math.rad(self.angle)
        local sx, sy = self.scale:get()
        local ox, oy = self.origin:get()
        
        sx = sx * (self.flipX and -1 or 1)
        sy = sy * (self.flipY and -1 or 1)

        local lastColor = {love.graphics.getColor()}
        love.graphics.setColor(self.color[1], self.color[2], self.color[3], self.alpha)
        x, y = x + ox - self.offset.x, y + oy - self.offset.y

        love.graphics.push()
            if self.clipRect then
                Stencil = {
                    sprite = self,
                    x = x,
                    y = y,
                    clipRect = self.clipRect,
                    func = Stencil.func
                }
                love.graphics.stencil(stencilFunc, "replace", 1, false)
            end
            love.graphics.draw(self.graphic, x, y, angle, sx, sy, ox, oy, self.shear.x, self.shear.y)
        love.graphics.pop()

        if self.clipRect then
            love.graphics.setStencilTest()
        end
        love.graphics.setColor(lastColor)
    end
end

return Sprite