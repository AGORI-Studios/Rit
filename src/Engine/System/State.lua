---@class State : Group
local State = Group:extend("State")

function State:__tostring()
    return "State<" .. self._NAME ..  "> (" .. #self.objects .. " objects)"
end

return State
