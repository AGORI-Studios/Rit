local HitObject = VertSprite:extend()

HitObject.time = 0
HitObject.data = 1
HitObject.canBeHit = false
HitObject.tooLate = false
HitObject.wasGoodHit = false

HitObject.tail = {}
HitObject.parent = nil

HitObject.offsetX = 0
HitObject.offsetY = 0

HitObject.children = {}
HitObject.moveWithScroll = true

function HitObject:new(time, data, endTime) 
    self.super.new(self, 0, 0, 0)

    self.moves = false

    self.x = states.game.Gameplay.strumX + (200) * (data-1)
    self.x = self.x + 25
    self.y = -2000

    self.time = time
    self.endTime = endTime
    self.data = data

    self.children = {}
    self.moveWithScroll = true

    self:load(skin:format("notes/" .. tostring(states.game.Gameplay.mode) .. "K/note" .. data .. ".png"))

    self.forcedDimensions = true
    self.dimensions = {width = 200, height = 200}
    self:updateHitbox()
    _G.__NOTE_OBJECT_WIDTH = 200

    self.x = self.x + (200) * (data-1)

    if self.endTime and self.endTime > self.time then
        local holdObj = VertSprite():load(skin:format("notes/" .. tostring(states.game.Gameplay.mode) .. "K/note" .. data .. "-hold.png"))
        holdObj.endTime = self.endTime
        holdObj:updateHitbox()
        holdObj.x = self.x + (200) / 2 - (200) / 2
        holdObj.forcedDimensions = true
        holdObj.dimensions = {width = 200, height = 200}
        holdObj.parent = self
        --[[ holdObj.mesh = love.graphics.newMesh(vertexFormat, 16, "strip") ]]
        holdObj.verts = {
            {0, 0, 0, 0, 0, 0, 0, 0, 0},
            {0, 0, 0, 0, 0, 0, 0, 0, 0},
            {0, 0, 0, 0, 0, 0, 0, 0, 0},
            {0, 0, 0, 0, 0, 0, 0, 0, 0},
            {0, 0, 0, 0, 0, 0, 0, 0, 0},
            {0, 0, 0, 0, 0, 0, 0, 0, 0},
            {0, 0, 0, 0, 0, 0, 0, 0, 0},
            {0, 0, 0, 0, 0, 0, 0, 0, 0},
            {0, 0, 0, 0, 0, 0, 0, 0, 0},
            {0, 0, 0, 0, 0, 0, 0, 0, 0},
            {0, 0, 0, 0, 0, 0, 0, 0, 0},
            {0, 0, 0, 0, 0, 0, 0, 0, 0},
            {0, 0, 0, 0, 0, 0, 0, 0, 0},
            {0, 0, 0, 0, 0, 0, 0, 0, 0},
            {0, 0, 0, 0, 0, 0, 0, 0, 0},
            {0, 0, 0, 0, 0, 0, 0, 0, 0},
        }
        --holdObj.rotation = Point(love.math.random(-5, 5), love.math.random(-5, 5), love.math.random(-5, 5))
        --[[ 
        function holdObj:draw()
            if self.exists and self.alive and self.visible and self.graphic then
                local lastColor = {love.graphics.getColor()}
                local lastBlend, lastAlphaMode = love.graphics.getBlendMode()

                local fov = self.fov
                local vertLens = 5
                
                local gotVerts
                
                local eox, eoy, eoz, eos = self.parent.children[2].x, self.endY or 0, self.parent.children[2].z, self.parent.children[2].scale
                local gw, gh = self.graphic:getWidth(), self.graphic:getHeight()
                local hfw, fh, uvx, uvy, uvwx, uvh = gw, gh, 0, 0, 1, 1
                local fhs = uvh
                hfw, fh, gotVerts = hfw * eos.x, fh * eos.y, vertLens

                if self.mesh:getTexture() ~= self.graphic then
                    self.mesh:setTexture(self.graphic)
                end
                local vx, vy, vz = worldSpin(
                    eox,
                    eoy,
                    eoz,
                    self.rotation.x,
                    self.rotation.y,
                    self.rotation.z,
                    self.origin.x,
                    self.origin.y,
                    self.origin.z
                )
                local pvx, pvy = toScreen(vx, vy, vz, fov)
                local enduv, vert, aa, as, ac
                for vi = 1, vertLens, 2 do
                    vx, vy, vz = worldSpin(
                        eox,
                        eoy,
                        eoz,
                        self.rotation.x,
                        self.rotation.y,
                        self.rotation.z,
                        self.origin.x,
                        self.origin.y,
                        self.origin.z
                    )

                    vert, vx, vy, vz = self.verts[vi], vx + eox, vy + eoy, vz + eoz
                    aa = -math.atan((pvx - vx) / (pvy - vy))
                    as, ac, pvx, pvy = math.sin(aa) * vx, math.cos(aa) * vy, vx, vy

                    vi, vert[1], vert[2], vert[3], vert[4], vert[5] = vi + 1, vx - hfw * ac, vy - fh * as, uvx * vz, (uvy+uvh)*vz, vz
                    vert[6], vert[7], vert[8], vert[9] = 1, 1, 1, self.alpha

                    vert = self.verts[vi]
                    vi, vert[1], vert[2], vert[3], vert[4], vert[5] = vi + 1, vx + hfw * ac, vy + fh * as, uvx * vz, (uvy+uvh)*vz, vz
                    vert[6], vert[7], vert[8], vert[9] = 1, 1, 1, self.alpha

                    if vi < vertLens then uvh = uvh - fhs end
                    if enduv then
                        gotVerts = vi
                        break
                    end
                end

                self.mesh:setDrawRange(1, gotVerts)
                self.mesh:setVertices(self.verts)
                love.graphics.setColor(self.color[1], self.color[2], self.color[3], self.alpha)
                love.graphics.setShader(self.defaultShader)
                love.graphics.draw(self.mesh, 0, 0, 0)
                love.graphics.setColor(lastColor)
                love.graphics.setBlendMode(lastBlend, lastAlphaMode)
                
                love.graphics.setShader()
            end
        end
        ]]
        table.insert(self.children, holdObj)

        local endObj = VertSprite():load(skin:format("notes/" .. tostring(states.game.Gameplay.mode) .. "K/note" .. data .. "-end.png"))
        holdObj.endTime = self.endTime
        endObj:updateHitbox()
        endObj.x = self.x + (200) / 2 - (200) / 2
        if not Settings.options["General"].downscroll then
            endObj.flipY = true
        end
        endObj.forcedDimensions = true
        endObj.dimensions = {width = 200, height = 200}
        endObj.parent = self

        table.insert(self.children, endObj)
    end

    self.x = self.x + self.offsetX

    return self
end

function HitObject:update(dt)
    self.super.update(self, dt)

    self.canBeHit = self.time > musicTime - safeZoneOffset and self.time < musicTime + safeZoneOffset
    if self.time < musicTime - safeZoneOffset and not self.wasGoodHit then
        self.tooLate = true
    end
    
    if self.tooLate then
        self.alpha = 0.5
    end
end

function HitObject:draw(scale)
    -- Draws our note if it's within the screen's bounds
    if self.y < 1080/scale and self.y > -400 / scale then
        for i, child in ipairs(self.children) do
            child:draw()
        end
        self.super.draw(self)
    end
end

return HitObject