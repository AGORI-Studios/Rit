local HUD = Group:extend("HUD")

function HUD:new(instance)
    self.screen = instance
    Group.new(self)
    self.elements = {}

    for name, elements in pairs(Skin.HUD) do
        self.elements[name] = Group()

        for k, element in ipairs(elements.members) do
            if element.type == "Text" then
                self.elements[name]:add(Text("", element.x, element.y, element.size, element.color, element.font, element.format, element.value, self.screen))
                self.elements[name].data = element
            end
        end

        self:add(self.elements[name])
    end
end

return HUD