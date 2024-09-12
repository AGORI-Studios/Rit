local Group = Class:extend("Group")

function Group:new(size)
    self.objects = {}
    self.size = size or 0
end

function Group:add(object)
    if self.size > 0 and #self.objects >= self.size then
        print("Group is full (" .. #self.objects .. "/" .. self.size .. ")")
        return
    end
    table.insert(self.objects, object)
end

function Group:remove(object)
    for i, obj in ipairs(self.objects) do
        if obj == object then
            table.remove(self.objects, i)
            break
        end
    end
end

function Group:clear()
    self.objects = {}
end

-- I Should probably just use a metatable for this
function Group:update(dt)
    for _, obj in ipairs(self.objects) do
        if obj.update then
            obj:update(dt)
        end
    end
end

function Group:draw()
    for _, obj in ipairs(self.objects) do
        if obj.draw then
            obj:draw()
        end
    end
end

function Group:resize(w, h)
    for _, obj in ipairs(self.objects) do
        if obj.resize then
            obj:resize(w, h)
        end
    end
end

function Group:keypressed(key, scancode, isrepeat)
    for _, obj in ipairs(self.objects) do
        if obj.keypressed then
            obj:keypressed(key, scancode, isrepeat)
        end
    end
end

function Group:keyreleased(key, scancode)
    for _, obj in ipairs(self.objects) do
        if obj.keyreleased then
            obj:keyreleased(key, scancode)
        end
    end
end

function Group:mousepressed(x, y, button, istouch, presses)
    for _, obj in ipairs(self.objects) do
        if obj.mousepressed then
            obj:mousepressed(x, y, button, istouch, presses)
        end
    end
end

function Group:mousereleased(x, y, button, istouch, presses)
    for _, obj in ipairs(self.objects) do
        if obj.mousereleased then
            obj:mousereleased(x, y, button, istouch, presses)
        end
    end
end

function Group:mousemoved(x, y, dx, dy, istouch)
    for _, obj in ipairs(self.objects) do
        if obj.mousemoved then
            obj:mousemoved(x, y, dx, dy, istouch)
        end
    end
end

function Group:wheelmoved(x, y)
    for _, obj in ipairs(self.objects) do
        if obj.wheelmoved then
            obj:wheelmoved(x, y)
        end
    end
end

--[[ function Group:__tostring()
    if #self.objects == 0 then
        return "Group (empty)"
    elseif self.size > 0 then
        return "Group (" .. #self.objects .. "/" .. self.size .. " objects)"
    else
        return "Group (" .. #self.objects .. " objects)"
    end
end ]]

function Group:kill()
    for _, obj in ipairs(self.objects) do
        if obj.kill then
            obj:kill()
        end
    end

    self:clear()
end

return Group