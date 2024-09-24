---@class TypedGroup : Group
local TypedGroup = Group:extend("TypedGroup")

---@param type table
---@param size? number
function TypedGroup:new(type, size)
    if not type then
        error("TypedGroup:new(type, ?size) requires a type")
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

return TypedGroup
