local ho = Object:extend()
-- ho stands for hitObject

ho.time = 0
ho.type = 0
ho.prevNote = nil
ho.isSustainNote = false
ho.isEndNote = false
ho.sustainLength = 0
ho.width = 225

ho.x = 0
ho.y = 0

ho.stencil = nil

ho.layer = 10

-- layer 10+ is for UI elements

function ho:new(time, type, prevNote, sustainNote)
    self.super.new(self)

    self.isSustainNote = sustainNote or false
    self.time = time
    self.type = type

    self.prevNote = nil
    self.isEndNote = false
    self.sustainLength = 0
    self.width = 225

    self.layer = 10

    self.stencilInfo = nil
    -- stencil info is given like {x = 0, y = 0, width = 0, height = 0}

    self.x = 650 + (self.type * self.width)
    self.y = -2000
    self.scale = {x = 1, y = 1}

    if self.type == 1 then 
        self.spr = noteImgs[1][1]
    elseif self.type == 2 then
        self.spr = noteImgs[2][1]
    elseif self.type == 3 then
        self.spr = noteImgs[3][1]
    elseif self.type == 4 then
        self.spr = noteImgs[4][1]
    end

    if (self.isSustainNote and prevNote) then 
        self.prevNote = prevNote
        self.isEndNote = true

        if self.type == 1 then 
            self.spr = noteImgs[1][3]
        elseif self.type == 2 then
            self.spr = noteImgs[2][3]
        elseif self.type == 3 then
            self.spr = noteImgs[3][3]
        elseif self.type == 4 then
            self.spr = noteImgs[4][3]
        end

        self.layer = 12
        self.spr.offsetY = 100

        if self.prevNote.isEndNote then
            self.prevNote.isEndNote = false

            if self.prevNote.type == 1 then 
                self.prevNote.spr = noteImgs[1][2]
            elseif self.prevNote.type == 2 then
                self.prevNote.spr = noteImgs[2][2]
            elseif self.prevNote.type == 3 then
                self.prevNote.spr = noteImgs[3][2]
            elseif self.prevNote.type == 4 then
                self.prevNote.spr = noteImgs[4][2]
            end

            self.prevNote.layer = 11

            self.prevNote.scale.y = (self.prevNote.width / self.prevNote.spr:getWidth()) * ((beatHandler.stepCrochet / 100) * (1.05)) * speed
            self.prevNote.scale.y = self.prevNote.scale.y + 1 / self.prevNote.spr:getHeight()
            self.prevNote.spr.offsetY = 0
        end
    end

    return self
end

function ho:update(dt)
end

function ho:draw()
    love.graphics.push()
        love.graphics.scale(0.8, 0.8)
        love.graphics.translate(self.x, self.y)
        love.graphics.scale(self.scale.x, not self.isEndNote and self.scale.y or -self.scale.y)

        if self.stencilInfo then 
            love.graphics.stencil(function()
                love.graphics.rectangle("fill", self.stencilInfo.x, self.stencilInfo.y, self.stencilInfo.width, self.stencilInfo.height)
            end, "replace", 1)
            love.graphics.setStencilTest("greater", 0)
        end
        self.spr:draw()
        love.graphics.setStencilTest()
    love.graphics.pop()
end

return ho