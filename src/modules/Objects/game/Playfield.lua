---@class Playfield
---@diagnostic disable-next-line: assign-type-mismatch
local Playfield = Object:extend()

function Playfield:new(x, y, reversed)
    self.x = x or 0
    self.y = y or 0
    self.reversed = (reversed == nil and false or reversed)
    self.id = #states.game.Gameplay.playfields + 1
    self.lanes = {}
    self.mods = {}
    for i = 1, states.game.Gameplay.mode do
        self.lanes[i] = {x = 0, y = 0}
    end

    return self
end

function Playfield:update(dt)
end

function Playfield:draw(notes, timingLines, timingLineWidth)
    -- Draw the receptors and notes on the playfield
    love.graphics.push()
    love.graphics.translate(self.x, self.y)
    love.graphics.scale(1, self.reversed and -1 or 1)
    for i, timingLine in ipairs(timingLines) do
        love.graphics.translate(0, timingLine.y)
        timingLine:draw(timingLineWidth)
        love.graphics.translate(0, -timingLine.y)
    end
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
            note:draw()
            love.graphics.translate(-self.lanes[note.data].x, -self.lanes[note.data].y)
        end
    end
    love.graphics.pop()
end

return Playfield