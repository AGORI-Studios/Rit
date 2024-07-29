local SubModifier = BaseModifier:extend()

function SubModifier:getOrder()
    return 2
end

function SubModifier:new(name, parent)
    BaseModifier.new(self, parent)
    self.name = name
end

return SubModifier