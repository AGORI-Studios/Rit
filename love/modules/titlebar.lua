titlebar = {
    x = 0, y = 0,
    width = love.graphics.getWidth(),
    height = 20,
    align = "right",

    buttonOrder = {
        -- left to right
        "minimize",
        "maximize",
        "close"
    },

    buttons = {
        minimize = {
            x = 0,
            y = 0,
            width = 20,
            height = 20,
            isHovered = false,
            image = love.graphics.newImage("assets/titlebar/minimize.png"),
            hover = love.graphics.newImage("assets/titlebar/minimize_hover.png"),
            click = love.graphics.newImage("assets/titlebar/minimize_click.png"),
            action = function()
                love.window.minimize()
            end
        },
        maximize = {
            x = 20,
            y = 0,
            width = 20,
            height = 20,
            isHovered = false,
            image = love.graphics.newImage("assets/titlebar/maximize.png"),
            hover = love.graphics.newImage("assets/titlebar/maximize_hover.png"),
            click = love.graphics.newImage("assets/titlebar/maximize_click.png"),
            action = function()
                love.window.maximize()
            end
        },
        close = {
            x = 40,
            y = 0,
            width = 20,
            height = 20,
            isHovered = false,
            image = love.graphics.newImage("assets/titlebar/close.png"),
            hover = love.graphics.newImage("assets/titlebar/close_hover.png"),
            click = love.graphics.newImage("assets/titlebar/close_click.png"),
            action = function()
                love.event.quit()
            end
        }
    },

    update = function(self)
        -- is button clicked ?!
        for _, button in pairs(self.buttons) do
            -- only execute when clicked and mouse ISNT down
            if button.isClicked and not love.mouse.isDown(1) then
                button.action()
                button.isClicked = false
            end

            -- check if mouse is hovering over button
            if love.mouse.getX() >= button.x and love.mouse.getX() <= button.x + button.width and love.mouse.getY() >= button.y and love.mouse.getY() <= button.y + button.height then
                button.isHovered = true
            else
                button.isHovered = false
            end

            -- check if button is clicked
            if button.isHovered and love.mouse.isDown(1) then
                button.isClicked = true
            end
        end
    end,

    draw = function(self)
        -- draw titlebar
        love.graphics.setColor(0.2, 0.2, 0.2)
        love.graphics.rectangle("fill", self.x, self.y, self.width, self.height)

        -- draw buttons
        for _, button in pairs(self.buttonOrder) do
            if self.buttons[button].isHovered then
                love.graphics.draw(self.buttons[button].hover, self.buttons[button].x, self.buttons[button].y)
            else
                love.graphics.draw(self.buttons[button].image, self.buttons[button].x, self.buttons[button].y)
            end
        end
    end
}