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
    self.offset = {x = 0, y = 0, scale = {x = 1, y = 1}}
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
        love.graphics.translate(1920/2, 1080)
        love.graphics.scale(scale, scale)
        love.graphics.translate(-1920/2, -1080)
        love.graphics.push()
            love.graphics.scale(self.offset.scale.x, self.offset.scale.y)
            love.graphics.translate(self.x, self.y)
            love.graphics.translate(self.offset.x, self.offset.y)
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
                        if states.game.Gameplay.ableToModscript then
                            local pos = Modscript:getPos(0, 0, 0, states.game.Gameplay.soundManager:getBeat("music"), receptor.data, self.id, receptor, {})
                            Modscript:updateObject(states.game.Gameplay.soundManager:getBeat("music"), receptor, pos, self.id)
                            receptor.x, receptor.y = pos.x, pos.y
                            receptor.z = pos.z * 200
                        end
                        receptor:draw()
                    end
                end
                for _, note in ipairs(notes) do
                    if note.draw then
                        if states.game.Gameplay.ableToModscript then
                            if note.time - musicTime > 15000 then
                                break
                            end
                            local vis = -((musicTime - note.time) * __getScrollspeed(Settings.options["General"].scrollspeed))
                            if not note.moveWithScroll then
                                vis = 0
                            end
                            local pos = Modscript:getPos(note.time, vis, note.time - musicTime, 
                                states.game.Gameplay.soundManager:getBeat("music"), note.data, self.id, note, {}, Point()
                            )
                            Modscript:updateObject(states.game.Gameplay.soundManager:getBeat("music"), note, pos, self.id)
                            note.x, note.y = pos.x, pos.y
                            note.z = pos.z * 200

                            if #note.children > 0 then
                                local vis = -((musicTime - note.endTime) * __getScrollspeed(Settings.options["General"].scrollspeed))
                                local pos2 = Modscript:getPos(note.time, vis, note.endTime - musicTime, 
                                    states.game.Gameplay.soundManager:getBeat("music"), note.data, self.id, note.children[1], {}
                                )
                                
                                note.children[1].x = pos.x
                                note.children[1].y = pos.y + 100
                                note.children[1].z = pos.z * 200
                                local endY = pos2.y

                                note.children[1].dimensions = {width = 200, height = endY - pos.y - 95}
                                note.children[2].dimensions = {width = 200, height = 95}
                                
                                note.children[2].x = pos.x
                                note.children[2].y = pos.y + note.children[1].dimensions.height
                                note.children[2].z = pos.z * 200
                                note.children[2].offset.y = -95
                                note.children[2].flipY = true
                            end
                        end
                        note:draw(Settings.options["General"].noteSize * scale)
                    end
                end
            love.graphics.pop()
        love.graphics.pop()
    love.graphics.pop()
    love.graphics.setCanvas(lastCanvas)
end

return Playfield