local Playfield = Object:extend()

Playfield.id = 0
Playfield.x = 0
Playfield.y = 0
Playfield.reversed = false
function Playfield:new(x, y, reversed)
    self.x = x or 0
    self.y = y or 0
    self.reversed = (reversed == nil and false or reversed)
    self.id = #states.game.Gameplay.playfields + 1

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
            receptor:draw()
        end
    end
    for i, note in ipairs(notes) do
        if note.draw then
            note:draw()
        end
    end
    love.graphics.pop()
end

return Playfield