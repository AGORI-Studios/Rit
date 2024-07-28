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
    self.offsets = {x = 0, y = 0, scale = {x = 1, y = 1}}
    self.alpha = 1
    self.canvas = love.graphics.newCanvas(1920, 1080)
    for i = 1, states.game.Gameplay.mode do
        self.lanes[i] = {x = 0, y = 0}
    end

    return self
end

function Playfield:update(dt)

end

function Playfield:draw(notes, timingLines, scale)
    local lastCanvas = love.graphics.getCanvas()
    love.graphics.setCanvas(self.canvas)
    love.graphics.clear()
    love.graphics.push()
        love.graphics.translate(1920/2, 1080/2)
        love.graphics.scale(scale, scale)
        love.graphics.rotate(math.rad(Modscript.cam.angle or 0))
        love.graphics.translate(-1920/2, -1080/2)
        love.graphics.translate(Modscript.cam.x or 0, Modscript.cam.y or 0)
        love.graphics.push()
            love.graphics.scale(self.offsets.scale.x, self.offsets.scale.y)
            love.graphics.translate(self.x, self.y)
            love.graphics.translate(self.offsets.x, self.offsets.y)
            love.graphics.scale(1, self.reversed and -1 or 1)
            if not states.game.Gameplay.ableToModscript then
                love.graphics.setColor(0,0,0, self.alpha * Settings.options["General"].scrollUnderlayAlpha)
            
                love.graphics.rectangle("fill", states.game.Gameplay.bgLane.x, -200*(scale+1), states.game.Gameplay.bgLane.width+30, 1080*(scale+1))
            end

            love.graphics.setColor(1,1,1, self.alpha)
            
            love.graphics.push()
                love.graphics.translate(self.lanes[1].x, self.lanes[1].y)
                for _, receptor in ipairs(states.game.Gameplay.strumLineObjects.members) do
                    if receptor.draw then
                        receptor:draw()
                    end
                end
                for _, note in ipairs(notes) do
                    if note.draw then
                        note:draw(Settings.options["General"].noteSize * scale)
                    end
                end
            love.graphics.pop()
        love.graphics.pop()
    love.graphics.pop()
    love.graphics.setCanvas(lastCanvas)
end

return Playfield