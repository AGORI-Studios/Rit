---@diagnostic disable: inject-field
-- Referenced from https://github.com/Stilic/FNF-LOVE/blob/main/loxel/3d/actorsprite.lua
local VertSprite = Object:extend()
VertSprite:implement(Sprite)

vertexFormat = {
    {"VertexPosition", "float", 2},
	{"VertexTexCoord", "float", 3},
	{"VertexColor",    "byte",  4}
}

local width, height = Inits.GameWidth, Inits.GameHeight

function toScreen(x, y, z, fov)
	local hw, hh, z = width / 2, height / 2, math.max(((z / 200) * (fov / 180)) + 1, 0.00001)
	return
		hw + (x - hw) / z,
		hh + (y - hh) / z,
		(1 / z)
end

function worldSpin(x, y, z, ax, ay, az, midx, midy, midz)
	local radx, rady, radz = math.rad(ax), math.rad(ay), math.rad(az)
	local angx0, angx1, angy0, angy1, angz0, angz1 = math.cos(radx), math.sin(radx), math.cos(rady), math.sin(rady), math.cos(radz), math.sin(radz)
	local gapx, gapy, gapz = x - midx, midy - y, midz - z

	local nx = midx + angy0 * angz0 * gapx + (-angz1 * angx0 + angx1 * angy1 * angz0) * gapy + (angx1 * angz1 + angx0 * angy1 * angz0) * gapz
	local ny = midy - angy0 * angz1 * gapx - (angx0 * angz0 + angx1 * angy1 * angz1) * gapy - (-angx1 * angz0 + angx0 * angy1 * angz1) * gapz
	local nz = midz + angy1 * gapx - angx1 * angy0 * gapy - angx0 * angy0 * gapz

	return nx, ny, nz
end

local defaultShader

function VertSprite.init()
    if defaultShader then return end
	defaultShader = love.graphics.newShader [[
		uniform Image MainTex;
		void effect() {
			love_PixelColor = Texel(MainTex, VaryingTexCoord.xy / VaryingTexCoord.z) * VaryingColor;
		}
	]]
	VertSprite.defaultShader = defaultShader
end

function VertSprite:new(x, y, z, graphic)
    self.x, self.y = x or 0, y or 0

    self.graphic = nil
    self.width, self.height = 0, 0

    self.alive, self.exists, self.visible = true, true, true

    self.origin = Point()
    self.offset = Point()
    self.scale = Point(1, 1, 1)
    self.shear = {x = 0, y = 0}

    self.clipRect = nil
    self.flipX, self.flipY = false, false

    self.alpha = 1
    self.color = {1, 1, 1}
    self.angle = 0 -- ! in degrees

    self.frames = nil -- Todo.
    self.animations = nil -- Todo.

    self.curAnim = nil
    self.curFrame = nil
    self.animFinished = false
    self.indexFrame = 1

    self.blend = "alpha"
    self.blendAlphaMode = "alphamultiply"

    self.type = "Image"

    self.z = z or 0
    self.fov = 60
    self.depth = 0
    self.rotation = Point()
    self.init()
    if graphic then self:load(graphic) end

    self.vertices = {
		{0, 0, 0, 0, 0},
		{1, 0, 0, 1, 0},
		{1, 1, 0, 1, 1},
		{0, 1, 0, 0, 1},
	}
	self.__vertices = {
		{0, 0, 0, 0, 1},
		{1, 0, 1, 0, 1},
		{1, 1, 1, 1, 1},
		{0, 1, 0, 1, 1},
	}

    self.mesh = love.graphics.newMesh(vertexFormat, self.vertices, "fan")
    self.mesh:setTexture(self.graphic)

    return self
end

function VertSprite:draw()
    if self.exists and self.alive and self.visible and self.graphic then
        local x = self.x
        local y = self.y
        local z = self.z or 0

        x = x - self.offset.x
        y = y - self.offset.y
        z = (z or 0) - (self.offset.z or 0)
        local rx, ry, rz = self.rotation.x, self.rotation.y, ((self.rotation.z or 0)) - self.angle
        local sx, sy, sz = self.scale.x, self.scale.y, (self.scale.z or 0)
        local ox, oy, oz = self.origin.x, self.origin.y, (self.origin.z or 0)

        if self.forcedDimensions then
            local w, h = self.width, self.height
            sx = self.dimensions.width / w
            sy = self.dimensions.height / h
        end

        x = x + ox
        y = y + oy

        local lastColor = {love.graphics.getColor()}
        local lastBlend, lastAlphaMode 
        if love.graphics.getSupportedBlend() then
            lastBlend, lastAlphaMode = love.graphics.getBlendMode()

            love.graphics.setBlendMode(self.blend, self.blendAlphaMode)
        end
        local gw, gh = self.graphic:getWidth(), self.graphic:getHeight()
        local fw, fh, uvx, uvy, uvw, uvh = gw, gh, 0, 0, 1, 1

        fw, fh = fw*sx, fh*sy
        ox, oy, oz = ox, oy, oz

        if self.flipX then uvx, uvw = uvx + uvw, -uvw end
        if self.flipY then 
            uvy, uvh = uvy + uvh, -uvh 
        end

        local mesh, verts, length = self.mesh, self.__vertices, #self.vertices
        local vert, vx, vy, vz
        for i, v in pairs(self.vertices) do
            vert = verts[i] or {0, 0, 0, 0, 0}
            verts[i] = vert

            vx, vy, vz = worldSpin(v[1] * fw, v[2] * fh, v[3] * sz, rx, ry, rz, ox, oy, oz)
            vert[1], vert[2], vert[5] = toScreen(vx + x - ox, vy + y - oy, vz + z - oz, self.fov)
            vert[3], vert[4] = (v[4] * uvw + uvx) * vert[5], (v[5] * uvh + uvy) * vert[5]
        end
        -- is mesh image same as self.graphic?
        if mesh:getTexture() ~= self.graphic then mesh:setTexture(self.graphic) end
        mesh:setDrawRange(1, length)
        mesh:setVertices(verts)
        love.graphics.setColor(lastColor[1] * self.color[1], lastColor[2] * self.color[2], lastColor[3] * self.color[3], lastColor[4] * self.alpha)
        love.graphics.setShader(defaultShader)

        love.graphics.draw(mesh)

        love.graphics.setColor(lastColor)
        if love.graphics.getSupportedBlend() then
            love.graphics.setBlendMode(lastBlend, lastAlphaMode)
        end
    end

    love.graphics.setShader()
end

--[[ function VertSprite:centerOffsets(w, h, d)
    self.offset = {
        x = ((w or self.graphic:getWidth()) - self.graphic:getWidth()) / 2,
        y = ((h or self.graphic:getHeight()) - self.graphic:getHeight()) / 2,
        z = ((d or self.depth) - self.depth) / 2
    }

    return self
end

function VertSprite:centerOrigin(w, h, d)
    self.origin = {
        x = (w or self.graphic:getWidth()) / 2,
        y = (h or self.graphic:getHeight()) / 2,
        z = (d or self.depth) / 2
    }

    return self
end ]]

return VertSprite