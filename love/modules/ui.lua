local ui = {}

-- unused rn cuz i gotta make it work with seperate resolutions and whatnot
function ui.newButton(name, x, y, w, h, setting, value, callback)
    local button = {}

    button.name = name
    button.x = x
    button.y = y
    button.w = w
    button.h = h
    button.setting = setting
    button.value = value
    button.callback = callback

    button.hover = false
    button.pressed = false

    function button.draw()
        love.graphics.setColor(0.5, 0.5, 0.5)
        love.graphics.rectangle("fill", button.x, button.y, button.w, button.h)
        love.graphics.setColor(1, 1, 1)
        love.graphics.print(button.name, button.x + 5, button.y + 5)
        if button.hover then
            love.graphics.setColor(0.5, 0.5, 0.5)
            love.graphics.rectangle("fill", button.x + button.w - 20, button.y + 5, 15, 15)
            love.graphics.setColor(1, 1, 1)
            love.graphics.print(button.value, button.x + button.w - 20, button.y + 5)
        end
    end

    function button.update(dt)
        local mx, my = love.mouse.getPosition()
        if mx > button.x and mx < button.x + button.w and my > button.y and my < button.y + button.h then
            button.hover = true
            if love.mouse.isDown(1) then
                button.pressed = true
            else
                if button.pressed then
                    button.pressed = false
                    button.callback()
                end
            end
        else
            button.hover = false
            button.pressed = false
        end
    end

    function button.setValue(value)
        button.value = value
    end

    function button.getValue()
        return button.value
    end

    return button
end

function ui.newDropdown(name, x, y, w, h, setting, values, callback)
    local dropdown = {}

    dropdown.name = name
    dropdown.x = x
    dropdown.y = y
    dropdown.w = w
    dropdown.h = h
    dropdown.setting = setting
    dropdown.values = values
    dropdown.callback = callback or function() end

    dropdown.hover = false
    dropdown.pressed = false
    dropdown.open = false
    dropdown.selected = 1
    
    dropdown.buttons = {}
    
    for i, v in ipairs(dropdown.values) do
        dropdown.buttons[i] = ui.newButton(v, dropdown.x, dropdown.y + (i * 35), dropdown.w, dropdown.h, dropdown.setting, v, function()
            dropdown.selected = i
            dropdown.open = false
            dropdown.callback()
        end)
    end

    function dropdown.draw()
        love.graphics.setColor(0.5, 0.5, 0.5)
        love.graphics.rectangle("fill", dropdown.x, dropdown.y, dropdown.w, dropdown.h)
        love.graphics.setColor(1, 1, 1)
        love.graphics.print(dropdown.name, dropdown.x + 5, dropdown.y + 5)
        if dropdown.hover then
            love.graphics.setColor(0.5, 0.5, 0.5)
            love.graphics.rectangle("fill", dropdown.x + dropdown.w - 20, dropdown.y + 5, 15, 15)
            love.graphics.setColor(1, 1, 1)
            love.graphics.print(dropdown.values[dropdown.selected], dropdown.x + dropdown.w - 20, dropdown.y + 5)
        end
        if dropdown.open then
            for i, v in ipairs(dropdown.buttons) do
                v.draw()
            end
        end
    end

    function dropdown.update(dt)
        local mx, my = love.mouse.getPosition()
        if mx > dropdown.x and mx < dropdown.x + dropdown.w and my > dropdown.y and my < dropdown.y + dropdown.h then
            dropdown.hover = true
            if love.mouse.isDown(1) then
                dropdown.pressed = true
            else
                if dropdown.pressed then
                    dropdown.pressed = false
                    dropdown.open = not dropdown.open
                end
            end
        else
            dropdown.hover = false
            dropdown.pressed = false
        end
        if dropdown.open then
            for i, v in ipairs(dropdown.buttons) do
                v.update(dt)
            end
        end
    end
end

return ui