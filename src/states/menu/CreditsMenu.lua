local CreditsMenu = state()

local CreditsList = json.decode(love.filesystem.read("assets/data/credits.json"))

function CreditsMenu:enter()

end

function CreditsMenu:update(dt)

end 

function CreditsMenu:mousepressed(x, y, b)
    local x, y = toGameScreen(x, y)

    Header:mousepressed(x, y, b)
end

function CreditsMenu:draw()
    local lastFont = love.graphics.getFont()
    -- 100 padding from the header

    setFont("menuExtraBold")
    for i, person in ipairs(CreditsList) do
        love.graphics.print(person.name, 10, 100 + i * 100)
        love.graphics.print(table.concat(person.roles, ", "), 10, 120 + i * 100)
        love.graphics.print(person.description, 10, 140 + i * 100)

        -- TODO: Implement links (when i get to making a button class and "person" class)
    end

    love.graphics.print("bro. i gotta finished this menu.", 700, 400, 0, 2, 2)

    love.graphics.setFont(lastFont)

    Header:draw()
end

return CreditsMenu