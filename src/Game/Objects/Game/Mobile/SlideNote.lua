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
        width * tileWidth, 0,
        endWidth * tileWidth, endTime-startTime,
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
    self.vertices = self:generateVertices(rendered)
    -- print our vertices
    for i, v in ipairs(self.vertices) do
        print(i, v[1], v[2], v[3], v[4])
    end
    self.mesh = love.graphics.newMesh(self.vertices, "fan", "dynamic")
    
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


function SlideNote:generateVertices(renderedPoints)
    local u = 0
    local vertices = {}
    local vertexCount = #renderedPoints

    for x = 1, vertexCount -1, 2 do
        local pv = {
            renderedPoints[x-2],
            renderedPoints[x-1]
        }
        local v = {
            renderedPoints[x],
            renderedPoints[x+1]
        }
        local nv = {
            renderedPoints[x+2],
            renderedPoints[x+3]
        }

        local dist, vert
        
        if x == 1 then
            dist = ((nv[1] - v[1]) ^ 2 + (nv[2] - v[2]) ^ 2) ^ 0.5
            vert = {
                (nv[2] - v[2]) * self.width / (dist * 2),
                -(nv[1] - v[1]) * self.height / (dist * 2)
            }
        elseif x == vertexCount - 1 then
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

    return vertices
end

function SlideNote:draw()
    local polyVerts = {}
    for i, v in ipairs(self.vertices) do
        -- push x by 300px
        table.insert(polyVerts, v[1])
        table.insert(polyVerts, v[2])
    end
    love.graphics.line(polyVerts)

    -- render the verts as a polygon
    --love.graphics.polygon("fill", polyVerts)
end

return SlideNote
