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

function Playfield:draw(notes, timingLines, timingLineWidth, scale, bgLaneX)
    love.graphics.push()
    love.graphics.translate(self.x, self.y)
    love.graphics.scale(1, self.reversed and -1 or 1)
    if scale ~= 1 then -- literally the lazy way out
        local firstReceptorX = states.game.Gameplay.strumLineObjects.members[1].x
        local diff = firstReceptorX - bgLaneX
        love.graphics.translate(-diff*2, 0)
    end
    for i, timingLine in ipairs(timingLines) do
        timingLine:draw(timingLineWidth)
    end
    for i, receptor in ipairs(states.game.Gameplay.strumLineObjects.members) do
        if receptor.draw then
            receptor:draw()
        end
    end
    for i, note in ipairs(notes) do
        if note.draw then
            note:draw(scale)
        end
    end
    love.graphics.pop()
end

return Playfield