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
        holdObj.length = self.endTime - self.time -- hold time
        holdObj:updateHitbox()
        holdObj.x = self.x + (200) / 2 - (200) / 2
        holdObj.forcedDimensions = true
        holdObj.dimensions = {width = 200, height = 200}
        holdObj.parent = self
        holdObj.verts = {}
        holdObj.toX = holdObj.parent.x
        holdObj.midOffset = 0--love.math.random(-200, 200)
        for i = 1, 96 do
            table.insert(holdObj.verts, {0, 0, 0, 0})
        end
        holdObj.mesh = nil --[[ love.graphics.newMesh(vertexFormat, #holdObj.verts, "fan") ]]
        function holdObj:draw()
            local lastShader = love.graphics.getShader()
            local defaultShader = VertSprite.defaultShader
            local parent = self.parent
            local endObj = self.endObj

            -- make endObj's x closer to self.toX as self.y gets closer to self.parent.y
            -- percent (going from 1-0)
            -- 1 is not near, 0 is near
            --[[  local percent = (self.y - self.parent.y) / (self.parent.y - self.y)
            endObj.x = endObj.x + (self.toX - endObj.x) * (self.y - self.parent.y) / (self.parent.y - self.y) ]]

            -- curv the holdObj based off the parents xy and the endObj's xy
            local startX, startY = parent.x-self.x, parent.y-self.y
            local endX, endY = endObj.x-self.x, endObj.y-self.y+95/2
            local midX, midY = (startX + endX) / 2 + self.midOffset*(percent or 0), (startY + endY) / 2
            
            local w, h = self.graphic:getWidth(), self.graphic:getHeight()

            -- take self.dimensions into account to make the bezier work properly
            local bezier = love.math.newBezierCurve(startX, startY, midX, midY, endX, endY)
            bezier:translate(self.x+w/2, self.y)

            local verts = {}
            local points = bezier:render(5)
            local v
            for i=1,#points,2 do
                local x, y = points[i] + w/2, points[i+1] + h
                local x2, y2 = points[i] - w/2, points[i+1] - h/2

                v = {x2, y, 0, 0}
                table.insert(verts, v)
                v = {x, y2, 1, 1}
                table.insert(verts, v)
            end

            for i = 1, #verts, 2 do
                verts[i][2] = verts[i+1][2]
                verts[i][2], verts[i+1][2] = verts[i][2] + h, verts[i+1][2] + h
            end

            table.remove(verts, 1)
            table.remove(verts, 1)

            if not self.mesh then
                self.mesh = love.graphics.newMesh(verts, "strip")
            else
                self.mesh:setVertices(verts)
            end
            if self.mesh:getTexture() ~= self.graphic then self.mesh:setTexture(self.graphic) end

            love.graphics.draw(self.mesh, 0, 0, 0)
            --[[ love.graphics.line(bezier:render(5))
            love.graphics.setPointSize(3)
            love.graphics.points(points) ]]
        end
        --holdObj.rotation = Point(love.math.random(-5, 5), love.math.random(-5, 5), love.math.random(-5, 5))

        table.insert(self.children, holdObj)

        local endObj = VertSprite():load(skin:format("notes/" .. tostring(states.game.Gameplay.mode) .. "K/note" .. data .. "-end.png"))
        holdObj.endTime = self.endTime
        endObj:updateHitbox()
        endObj.x = self.x + (200) / 2 - (200) / 2
        if not Modscript.downscroll then
            endObj.flipY = true
        end
        endObj.forcedDimensions = true
        endObj.dimensions = {width = 200, height = 200}
        endObj.parent = self

        endObj.hold = holdObj
        holdObj.endObj = endObj

        self.endObj = endObj

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