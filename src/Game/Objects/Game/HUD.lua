local HUD = Group:extend("HUD")

function HUD:new(instance)
    self.screen = instance
    Group.new(self)
    self.elements = {}

    for name, elements in pairs(Skin.HUD) do
        self.elements[name] = Group()

        for _, element in ipairs(elements.members) do
            if element.type == "Text" then
                self.elements[name]:add(Text("", element.x, element.y, element.size, element.color, element.font, element.format, element.value, self.screen, false, 1920))
                self.elements[name].data = element
            elseif element.type == "Sprite" then
                local path = element.path:gsub("Game:", "")
                local child = Sprite(path, element.x, element.y)
                self.elements[name]:add(child)
                if element.scale then
                    if type(element.scale) == "number" then
                        child:setScale(element.scale, element.scale)
                    else
                        child:setScale(element.scale.x, element.scale.y)
                    end
                end
                self.elements[name].data = element
            end
        end

        self:add(self.elements[name])
    end
end

return HUD