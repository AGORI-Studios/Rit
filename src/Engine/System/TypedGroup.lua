local TypedGroup = Group:extend("TypedGroup")

function TypedGroup:new(type, size)
    if not type then
        error("TypedGroup:new(type, size) requires a type")
    end
    Group.new(self, size)
    self.type = type
end

function TypedGroup:__tostring()
    if #self.objects == 0 then
        return "TypedGroup<" .. self.type._NAME .. "> (empty)"
    elseif self.size > 0 then
        return "TypedGroup<" .. self.type._NAME .. "> (" .. #self.objects .. "/" .. self.size .. " objects)"
    else
        return "TypedGroup<" .. self.type._NAME .. "> (" .. #self.objects .. " objects)"
    end
end

function TypedGroup:kill()
    for _, obj in ipairs(self.objects) do
        if obj.kill then
            obj:kill()
        end
    end

    self:clear()
end

return TypedGroup