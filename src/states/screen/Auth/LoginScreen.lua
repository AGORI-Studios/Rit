local LoginScreen = state()

local alreadyLoggedIn = false
local passwordThing = ""

local typeMode = 0 -- 1 = email, 2 = password. 0 = off

local emailStr, passStr = "", ""

function LoginScreen:enter()
    if API.LoggedInUser.id then
        alreadyLoggedIn = true
    end
end

function LoginScreen:textinput(t)
    if typeMode == 1 then
        emailStr = emailStr .. t
    elseif typeMode == 2 then
        passStr = passStr .. t
    end
end

function LoginScreen:keypressed(k)
    if k == "return" then
        if passStr == "" then
            passwordThing = "none"
        else
            local ok = API:LoginUser(emailStr, passStr, true)
            if not ok then
                passwordThing = "errlogin"
            else
                API.CurrentUserAvatar = love.graphics.newImage(API:GetCurrentUserAvatar())
                switchState(states.menu.StartMenu, 0.3)
            end
        end
    end

    if k == "backspace" and typeMode ~= 0 then
        if typeMode == 1 then
            local byteoffset = utf8.offset(emailStr, -1)
            if byteoffset then
                emailStr = string.sub(emailStr, 1, byteoffset - 1)
            end
        elseif typeMode == 2 then
            local byteoffset = utf8.offset(passStr, -1)
            if byteoffset then
                passStr = string.sub(passStr, 1, byteoffset - 1)
            end
        end
    end

    if k == "escape" then
        switchState(states.menu.StartMenu, 0.3)
    end
end

function LoginScreen:mousepressed(x, y, b)
    local x, y = toGameScreen(x, y)
    if b == 1 then
        if x >= 0 and x <= 100 and y >= 20 and y <= 40 then
            typeMode = 1
        elseif x >= 0 and x <= 100 and y > 40 and y <= 60 then
            typeMode = 2
        else
            typeMode = 0
        end

        if x >= 0 and x <= 200 and y >= 100 and y <= 120 then
            love.system.openURL("https://rit.agori.dev/signup")
        end
    end
end

function LoginScreen:draw()
    setFont("menuBold")
    local replacePassStr = ""

    if alreadyLoggedIn then
        love.graphics.print("NOTE: YOU ARE ALREADY LOGGED IN. LOGGING IN AGAIN WILL FORCE LOG YOU OUT INTO THE NEW ACCOUNT")
    end

    love.graphics.print("Email: " .. emailStr, 0, 20)
    for _ = 1, #passStr do
        replacePassStr = replacePassStr .. "*"
    end
    love.graphics.print("Password: " .. replacePassStr, 0, 40)

    if passwordThing == "none" then
        love.graphics.print("No password was inputted.", 0, 70)
    elseif passwordThing == "errlogin" then
        love.graphics.print("Error with login.", 0, 70)
    end

    love.graphics.print("Create Account", 0, 100)
end

return LoginScreen