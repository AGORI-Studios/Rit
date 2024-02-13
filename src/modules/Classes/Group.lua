-- Based off of haxeflixel's FlxGroup class
local Group = Object:extend()

function Group:new()
    self.members = {}
end

function Group:add(n)
    table.insert(self.members, n)
end

function Group:remove(n)
    for i, v in ipairs(self.members) do
        if v == n then
            table.remove(self.members, i)
            break
        end
    end
end

function Group:update(dt)
    for i, v in ipairs(self.members) do
        v:update(dt)
    end
end

function Group:draw()
    for i, v in ipairs(self.members) do
        v:draw()
    end
end

return Group