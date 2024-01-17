local Playfield = Object:extend()

love.graphics.setLineWidth(10)

function Playfield:new(x, y, reversed)
    self.x = x or 0
    self.y = y or 0
    self.reversed = (reversed == nil and false or reversed)
    self.id = #states.game.Gameplay.playfields + 1
    self.lanes = {}
    self.points = {}
    self.beziers = {}
    for i = 1, states.game.Gameplay.mode do
        local endX = states.game.Gameplay.strumXs[i]
        local endY = Settings.options["General"].downscroll and 1080-(__NOTE_OBJECT_WIDTH) or -__NOTE_OBJECT_WIDTH*2
        local midX = love.math.random(0, 1920)
        local midY = love.math.random(0, 1080)
        local startX = states.game.Gameplay.strumXs[i]
        local startY = Settings.options["General"].downscroll and -__NOTE_OBJECT_WIDTH or 1080
        self.points[i] = {startX, startY, midX, midY, endX, endY}

        local bezier = love.math.newBezierCurve(self.points[i])
        table.insert(self.beziers, bezier)
    end
    self.mods = {}
    for i = 1, states.game.Gameplay.mode do
        self.lanes[i] = {x = 0, y = 0}
    end

    return self
end

function Playfield:update(dt)
end

function Playfield:draw(notes) 
    love.graphics.push()
    love.graphics.translate(self.x, self.y)
    love.graphics.scale(1, self.reversed and -1 or 1)
    for i, receptor in ipairs(states.game.Gameplay.strumLineObjects.members) do
        if receptor.draw then
            love.graphics.translate(self.lanes[i].x, self.lanes[i].y)
            receptor:draw()
            love.graphics.translate(-self.lanes[i].x, -self.lanes[i].y)
        end
    end
    for i, note in ipairs(notes) do
        if note.draw then
            love.graphics.translate(self.lanes[note.data].x, self.lanes[note.data].y)
            note:draw(self.beziers[note.data])
            love.graphics.translate(-self.lanes[note.data].x, -self.lanes[note.data].y)
            -- render bezier curve
            --love.graphics.setColor(1, 0, 0, 1)
        end
    end
    love.graphics.pop()
end

return Playfield