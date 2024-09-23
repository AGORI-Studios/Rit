---@class VertexSprite : Sprite
local VertexSprite = Sprite:extend("VertexSprite")

---@param image string|love.Image
---@param x number|nil
---@param y number|nil
---@param verticeCount number
function VertexSprite:new(image, x, y, verticeCount)
    Sprite.new(self, image, x, y)
    
    self.verticeCount = verticeCount
    self.vertices = {}
    
    -- Initialize vertex positions based on vertex count
    for i = 1, verticeCount do
        self.vertices[i] = {0, 0, 0, 0}
    end

    self.mesh = love.graphics.newMesh(self.verticeCount, "fan")

    -- Map the vertices to the mesh depending on the image
    self:mapVertices()

    self.mesh:setTexture(self.image)
    self.mesh:setVertices(self.vertices)
end

function VertexSprite:update(dt)
    Sprite.update(self, dt)
    self.mesh:setVertices(self.vertices)
end

function VertexSprite:mapVertices()
    local width = self.image:getWidth()
    local height = self.image:getHeight()

    local verticesPerEdge = math.floor(self.verticeCount / 4)
    local remainder = self.verticeCount % 4

    local vertexIndex = 1

    for i = 0, verticesPerEdge + (remainder > 0 and 1 or 0) - 1 do
        local x = i * (width / (verticesPerEdge + (remainder > 0 and 1 or 0)))
        self.vertices[vertexIndex] = {x, 0, x / width, 0}
        vertexIndex = vertexIndex + 1
    end
    remainder = math.max(0, remainder - 1)

    for i = 0, verticesPerEdge + (remainder > 0 and 1 or 0) - 1 do
        local y = i * (height / (verticesPerEdge + (remainder > 0 and 1 or 0)))
        self.vertices[vertexIndex] = {width, y, 1, y / height}
        vertexIndex = vertexIndex + 1
    end
    remainder = math.max(0, remainder - 1)

    for i = 0, verticesPerEdge + (remainder > 0 and 1 or 0) - 1 do
        local x = width - i * (width / (verticesPerEdge + (remainder > 0 and 1 or 0)))
        self.vertices[vertexIndex] = {x, height, x / width, 1}
        vertexIndex = vertexIndex + 1
    end
    remainder = math.max(0, remainder - 1)

    for i = 0, verticesPerEdge + (remainder > 0 and 1 or 0) - 1 do
        local y = height - i * (height / (verticesPerEdge + (remainder > 0 and 1 or 0)))
        self.vertices[vertexIndex] = {0, y, 0, y / height}
        vertexIndex = vertexIndex + 1
    end

    self.mesh:setVertices(self.vertices)
end

function VertexSprite:draw()
    if not self.visible or not self.image then return end
    love.graphics.push()
        love.graphics.setBlendMode(self.blendMode, self.blendModeAlpha)
        love.graphics.setColor(self.colour[1], self.colour[2], self.colour[3], self.alpha)
        
        local sx, sy = self.scale.x * self.windowScale.x, self.scale.y * self.windowScale.y
        if self.forcedDimensions then
            sx = self.dimensions[1] / self.baseWidth * self.windowScale.x
            sy = self.dimensions[2] / self.baseHeight * self.windowScale.y
        end
        love.graphics.draw(self.mesh, self.drawX, self.drawY, math.rad(self.angle), sx, sy, self.origin.x, self.origin.y)

        if Game.debug then
            love.graphics.translate(self.drawX, self.drawY)
            love.graphics.rotate(math.rad(self.angle))
            love.graphics.translate(-self.drawX, -self.drawY)
            love.graphics.translate(-self.origin.x * self.windowScale.x * self.scale.x, -self.origin.y * self.windowScale.y * self.scale.y)
            self:__debugDraw()
        end
    love.graphics.pop()
end

return VertexSprite
