local Container = Group:extend("Container")

function Container:new(x, y)
    Group.new(self)

    self.padding = 0
    self.rounding = 0 -- rounded rectangle radius
    self.colour = {1, 1, 1, 1}
    self.x, self.y = x or 0, y or 0
    self.visible = true
end

function Container:update(dt)
    Group.update(self, dt)
end

function Container:draw()
    if self.visible then
        love.graphics.push()
        love.graphics.translate(self.x, self.y)
        local lastColour = {love.graphics.getColor()}
        love.graphics.setColor(self.colour)
        -- determine width and height based on children
        
        local width, height = 0, 0
        local x, y = 0, 0
        --local childWidth, childHeight = child.width * child.scale.x * child.windowScale.x, child.height * child.scale.y * child.windowScale.y

        local maxChildWidth, maxChildHeight = 0, 0
        local minChildX, minChildY = 0, 0

        for _, child in ipairs(self.objects) do
            if child.visible then
                local childWidth, childHeight = child.width * child.scale.x * child.windowScale.x, child.height * child.scale.y * child.windowScale.y
                if child.x < minChildX then
                    minChildX = child.x
                end
                if child.y < minChildY then
                    minChildY = child.y
                end
                if childWidth > maxChildWidth then
                    maxChildWidth = childWidth
                end
                if childHeight > maxChildHeight then
                    maxChildHeight = childHeight
                end
            end
        end

        width = maxChildWidth - minChildX
        height = maxChildHeight - minChildY

        width = width + self.padding
        height = height + self.padding
        
        love.graphics.rectangle("fill", 0, 0, width, height, self.rounding, self.rounding)

        love.graphics.setColor(lastColour)

        Group.draw(self)
        love.graphics.pop()
    end
end

return Container