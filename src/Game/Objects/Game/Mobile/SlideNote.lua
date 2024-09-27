---@diagnostic disable: redundant-parameter
local SlideNote = VertexSprite:extend("SlideNote")

local tileWidth = 96

function SlideNote:new(lane, startTime, endTime, width, endWidth, hitsounds, noteVer)
    self.lane = lane
    self.StartTime = startTime
    self.tileWidth = width
    self.hitsounds = hitsounds
    self.noteVer = noteVer or "SLIDE"

    -- Use a bezier curve for the slide note
    -- The curve is down-top
    -- Use startTime, endTime as the y, width, endWidth as the x
    self.curve = love.math.newBezierCurve(
        0, 0,
        width, 0,
        endWidth, endTime-startTime,
        0, endTime-startTime
    )

    -- Create the slide note (x, y, verticeCount)
    VertexSprite.new(self, nil, 0, 0, #self.curve:render(5))
    self.width = width
    self.height = 64
    self.endWidth = endWidth
    self.endTime = endTime

    -- Generate the vertices for the mesh (variable width)
    local rendered = self.curve:render(5)
    self.realVertices = self:generateVertices(rendered)
    
    -- Create a mesh using the vertices
end

-- Linear interpolation function to transition between start and end width
function SlideNote:update(dt)
    self.x = 1000
    VertexSprite.update(self, dt)
end
--[[
for x = 1, #points -1, 2 do 
        local pv = {
            points[x-2], 
            points[x-1]
        }
        local v = {
            points[x], 
            points[x+1]
        }
        local nv = {
            points[x+2], 
            points[x+3]
        }

        local dist, vert

        if x == 1 then
            dist = ((nv[1] - v[1]) ^ 2 + (nv[2] - v[2]) ^ 2) ^ 0.5
            vert = {
                (nv[2] - v[2]) * self.width / (dist * 2),
                -(nv[1] - v[1]) * self.height / (dist * 2)
            }
        elseif x == #points - 1 then
            dist = ((v[1] - pv[1]) ^ 2 + (v[2] - pv[2]) ^ 2) ^ 0.5
            vert = {
                (v[2] - pv[2]) * self.width / (dist * 2),
                -(v[1] - pv[1]) * self.height / (dist * 2)
            }
        else
            dist = ((nv[1] - pv[1]) ^ 2 + (nv[2] - pv[2]) ^ 2) ^ 0.5
            vert = {
                (nv[2] - pv[2]) * self.width / (dist * 2),
                -(nv[1] - pv[1]) * self.height / (dist * 2)
            }
        end

        u = u + dist / self.height / 2

        table.insert(vertices, {
            v[1] + vert[1],
            v[2] - vert[2],
            u, 0
        })
        table.insert(vertices, {
            v[1] - vert[1],
            v[2] + vert[2],
            u, 1
        })
    end

    table.remove(vertices, 1)
    table.remove(vertices, 1)

    -- Create our textured mesh
    if meshMode then
        self.graphic = love.graphics.newMesh(vertices, "strip", meshMode)
    else
        self.graphic = love.graphics.newMesh(vertices, "strip", "fan")
    end]]

local function getNormal(x1, y1, x2, y2)
    local dx, dy = x2 - x1, y2 - y1
    local len = math.sqrt(dx * dx + dy * dy)
    return -dy / len, dx / len
end

function SlideNote:generateVertices(renderedPoints)
    local samples = 20
    local curvePoints = {}
    local leftPoints = {}
    local rightPoints = {}
    for i = 0, samples do
        local t = i / samples
        local x, y = self.curve:evaluate(t)

        local nextT = (i + 1) / samples
        if nextT > 1 then
            nextT = 1
        end
        local nextX, nextY = self.curve:evaluate(nextT)

        local nx, ny = getNormal(x, y, nextX, nextY)

        local width = self.width + (self.endWidth - self.width) * t

        local halfW = (width / 2) * tileWidth
        local leftX = x + nx * halfW
        local leftY = y + ny * halfW
        local rightX = x - nx * halfW
        local rightY = y - ny * halfW

        table.insert(leftPoints, leftX)
        table.insert(leftPoints, leftY)
        table.insert(rightPoints, rightX)
        table.insert(rightPoints, rightY)
    end

    for i = #rightPoints, 1, -2 do
        table.insert(leftPoints, rightPoints[i-1])
        table.insert(leftPoints, rightPoints[i])
    end

    return leftPoints
end

function SlideNote:draw()
    love.graphics.push()
    love.graphics.translate(300, 0)
    love.graphics.polygon("fill", self.realVertices)
    love.graphics.pop()

    love.graphics.rectangle("fill", 600, 600, tileWidth*3, 64)
end

return SlideNote
