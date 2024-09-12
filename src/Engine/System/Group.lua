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

function Group:__tostring()
    if #self.objects == 0 then
        return "Group (empty)"
    elseif self.size > 0 then
        return "Group (" .. #self.objects .. "/" .. self.size .. " objects)"
    else
        return "Group (" .. #self.objects .. " objects)"
    end
end

function Group:kill()
    for _, obj in ipairs(self.objects) do
        if obj.kill then
            obj:kill()
        end
    end

    self:clear()
end

return Group