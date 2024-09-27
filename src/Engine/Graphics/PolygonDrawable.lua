local PolygonDrawable = Drawable:extend("PolygonDrawable")

function PolygonDrawable:new(x, y, width, height)
    Drawable.new(self, x, y, width, height)
    self.vertices = {}
    self.drawableVertices = {}

    -- add vertices based off x, y, width, and height
    self:addVertex(x, y)
    self:addVertex(x + width, y)
    self:addVertex(x + width, y + height)
    self:addVertex(x, y + height)
end

function PolygonDrawable:addVertex(x, y)
    table.insert(self.vertices, x)
    table.insert(self.vertices, y)
end

function PolygonDrawable:updateVertices(verts)
    self.vertices = verts
end

function PolygonDrawable:update(dt)
    if self.scalingType ~= ScalingTypes.STRETCH and self.scalingType ~= ScalingTypes.WINDOW_STRETCH then
        -- we don't use drawX and drawY here, we gotta update the drawable vertices
        for i = 1, #self.vertices, 2 do
            local x = self.vertices[i]
            local y = self.vertices[i + 1]

            x = x + self.offset.x
            y = y + self.offset.y

            if self.addOrigin then
                x = x + self.origin.x
                y = y + self.origin.y
            end

            self.drawableVertices[i] = Game._windowWidth * (x / Game._gameWidth)
            self.drawableVertices[i + 1] = Game._windowHeight * (y / Game._gameHeight)
        end
    end
end

function PolygonDrawable:resize(w, h)
    if self.scalingType == ScalingTypes.STRETCH then
        self.width = w
        self.height = h
        self.windowScale.x = w / self.baseWidth
        self.windowScale.y = h / self.baseHeight

        for i = 1, #self.vertices, 2 do
            self.drawableVertices[i] = w * (self.vertices[i] / self.baseWidth)
            self.drawableVertices[i + 1] = h * (self.vertices[i + 1] / self.baseHeight)
        end
    elseif self.scalingType == ScalingTypes.ASPECT_FIXED then
        local scale = math.min(w / Game._gameWidth, h / Game._gameHeight)
        self.windowScale.x, self.windowScale.y = scale, scale
        self.width = self.baseWidth * scale
        self.height = self.baseHeight * scale

        for i = 1, #self.vertices, 2 do
            self.drawableVertices[i] = w * (self.vertices[i] / Game._gameWidth)
            self.drawableVertices[i + 1] = h * (self.vertices[i + 1] / Game._gameHeight)
        end
    elseif self.scalingType == ScalingTypes.WINDOW_FIXED then
        local scale = math.min(w / self.baseWidth, h / self.baseHeight)
        self.windowScale.x, self.windowScale.y = scale, scale
        self.width = self.baseWidth * scale
        self.height = self.baseHeight * scale

        for i = 1, #self.vertices, 2 do
            self.drawableVertices[i] = w * (self.vertices[i] / self.baseWidth)
            self.drawableVertices[i + 1] = h * (self.vertices[i + 1] / self.baseHeight)
        end
    elseif self.scalingType == ScalingTypes.WINDOW_STRETCH then
        -- Stretches the image to the window size
        self.width = w
        self.height = h

        self.windowScale.x = w / self.baseWidth
        self.windowScale.y = h / self.baseHeight

        for i = 1, #self.vertices, 2 do
            self.drawableVertices[i] = self.vertices[i] * self.windowScale.x
            self.drawableVertices[i + 1] = self.vertices[i + 1] * self.windowScale.y
        end
    elseif self.scalingType == ScalingTypes.STRETCH_Y then
        self.width = w
        self.height = self.baseHeight * self.windowScale.y

        self.windowScale.x = w / self.baseWidth
        self.windowScale.y = h / self.baseHeight

        for i = 1, #self.vertices, 2 do
            self.drawableVertices[i] = self.vertices[i] * self.windowScale.x
            self.drawableVertices[i + 1] = self.vertices[i + 1] * self.windowScale.y
        end
    end

    if self.memoryCenterOrigin then
        self.origin.x = self.width / 2
        self.origin.y = self.height / 2
    end
end

function PolygonDrawable:draw()
    if not self.visible then return end
    love.graphics.push()
        love.graphics.setBlendMode(self.blendMode, self.blendModeAlpha)
        love.graphics.setColor(self.colour[1], self.colour[2], self.colour[3], self.alpha)
        love.graphics.polygon("fill", self.drawableVertices)
    love.graphics.pop()
end

return PolygonDrawable