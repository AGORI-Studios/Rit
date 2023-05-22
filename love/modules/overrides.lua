--[[----------------------------------------------------------------------------

This file is apart of Rit; a free and open sourced rhythm game made with LÖVE.

Copyright (C) 2023 GuglioIsStupid

This program is free software: you can redistribute it and/or modify
it under the terms of the GNU General Public License as published by
the Free Software Foundation, either version 3 of the License, or
(at your option) any later version.

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU General Public License for more details.

You should have received a copy of the GNU General Public License
along with this program.  If not, see <https://www.gnu.org/licenses/>.

------------------------------------------------------------------------------]]

-- Math Funcs

function math.lerp(a, b, t)
    return a + (b - a) * t
end

function math.clamp(x, min, max)
    return x < min and min or (x > max and max or x)
end

function math.round(x)
    return x >= 0 and math.floor(x + 0.5) or math.ceil(x - 0.5)
end

function math.sign(x)
    return x > 0 and 1 or (x < 0 and -1 or 0)
end

function math.distance(x1, y1, x2, y2)
    return math.sqrt((x2 - x1) ^ 2 + (y2 - y1) ^ 2)
end

function math.angle(x1, y1, x2, y2)
    return math.atan2(y2 - y1, x2 - x1)
end

function math.truncateFloat(x, precision)
    local precision = precision or 2
    local num = x or 0
    num = num * math.pow(10, precision)
    num = math.round(num) / math.pow(10, precision)
    return num
end

-- String Funcs

function string.startsWith(str, start)
    return str:sub(1, #start) == start
end

function string.endsWith(str, ending)
    return ending == "" or str:sub(-#ending) == ending
end

function string.split(str, sep)
    local sep, fields = sep or ":", {}
    local pattern = string.format("([^%s]+)", sep)
    str:gsub(pattern, function(c) fields[#fields + 1] = c end)
    return fields
end

function string.trim(s)
    return s:match("^%s*(.-)%s*$")
end

function string.trimLeft(s)
    return s:match("^%s*(.*)")
end

function string.trimRight(s)
    return s:match("(.-)%s*$")
end

function string.splitAt(str, index)
    return str:sub(1, index), str:sub(index + 1)
end

function string.splitAtLast(str, index)
    return str:sub(1, index), str:sub(index)
end

function string.splitAtFirst(str, index)
    return str:sub(1, index), str:sub(index + 1)
end

function string.title(str)
    return str:gsub("(%a)([%w_']*)", function(first, rest)
        return first:upper() .. rest:lower()
    end)
end

function string.cap(str)
    -- capitalized the first letter of each word
    return str:gsub("(%a)([%w_']*)", function(first, rest)
        return first:upper() .. rest:lower()
    end)
end
-- Table Funcs

function table.contains(table, element)
    for _, value in pairs(table) do
        if value == element then
            return true
        end
    end
    return false
end

function table.find(table, element)
    for i, value in pairs(table) do
        if value == element then
            return i
        end
    end
    return nil
end

function table.removeValue(table, element)
    for i, value in pairs(table) do
        if value == element then
            table.remove(table, i)
            return true
        end
    end
    return false
end

function table.copy(t)
    local t2 = {}
    for k, v in pairs(t) do
        if type(v) == "table" then
            t2[k] = table.copy(v)
        else
            t2[k] = v
        end
    end
    return t2
end

function table.merge(t1, t2)
    for k, v in pairs(t2) do
        if type(v) == "table" then
            if type(t1[k] or false) == "table" then
                table.merge(t1[k] or {}, t2[k] or {})
            else
                t1[k] = v
            end
        else
            t1[k] = v
        end
    end
    return t1
end

function table.print(t, indent)
    indent = indent or 0
    for k, v in pairs(t) do
        if type(v) == "table" then
            print(string.rep(" ", indent) .. k .. ":")
            table.print(v, indent + 2)
        else
            print(string.rep(" ", indent) .. k .. ": " .. tostring(v))
        end
    end
end

-- Love2d Funcs

if love.system.getOS() ~= "NX" then -- show message box doesn't work on Switch, so use the default error handler
	-- modified a slight bit from https://github.com/OverHypedDudes/love2dTemplate/blob/main/modules/errHandler.lua
    -- Gotta fix this shitz!!
    --[[
	function love.errhand(error_message)
		local dialog_message = [[
Rit crashed with the following error:	
%s
]]
--]]
        --[[
		local full_error = debug.traceback(error_message or "")
		local message = string.format(dialog_message, full_error)
		local buttons = {"Report Error", "No thanks"}

		local selected = love.window.showMessageBox("An Error Has Occurred", message, buttons)

		local function url_encode(text)
			text = string.gsub(text, "\n", "%%0A")
			text = string.gsub(text, " ", "%%20")
			text = string.gsub(text, "#", "%%23")
			return text
		end
        --]]

        --[[
		local issuebody = [[
Rit has crashed with the following error:
	
%s
	
[If you can, describe what you've been doing when the error occurred]
	
---
Affects: %s
Edition: %s
]]
--]]
--[[
        love.filesystem.write("crash.log", full_error)
		if selected == 1 then
			-- Surround traceback in ``` to get a Markdown code block
			full_error = table.concat({"```",full_error,"```"}, "\n")
			issuebody = string.format(issuebody, full_error, love.system.getOS())
			issuebody = url_encode(issuebody)
		
			local subject = "Crash for Rit"
			local url = string.format("https://github.com/GuglioIsStupid/Rit/issues/new?title=%s&body=%s", subject, issuebody)
			love.system.openURL(url)
		end
	end
    --]]
    --]]
else
    function love.window.showMessageBox(title, message, buttons, type)
        local buttonString = buttons
        -- make a wannabe messagebox
        drawMessageBox = true
    
        -- pause the game until the user clicks a button
        while drawMessageBox do
            love.event.pump()
            love.graphics.clear(0, 0, 0, 1)
            love.graphics.rectangle("fill", love.graphics.getWidth()/2 - 200, love.graphics.getHeight()/2 - 100, 400, 200)
            love.graphics.setColor(0, 0, 0, 1)
            love.graphics.print(title, love.graphics.getWidth()/2 - 200, love.graphics.getHeight()/2 - 100)
            love.graphics.print(message, love.graphics.getWidth()/2 - 200, love.graphics.getHeight()/2 - 80)
            love.graphics.print(buttonString, love.graphics.getWidth()/2 - 200, love.graphics.getHeight()/2 - 60)
            love.graphics.setColor(1, 1, 1, 1)
            love.graphics.present()
            -- check for button presses
            inputsMoments = {
                "a", "b", "c", "d", "e", "f", "g", "h",
                "i", "j", "k", "l", "m", "n", "o", "p",
                "q", "r", "s", "t", "u", "v", "w", "x",
                "y", "z", "0", "1", "2", "3", "4", "5",
                "6", "7", "8", "9", "kp0", "kp1", "kp2",
                "kp3", "kp4", "kp5", "kp6", "kp7", "kp8",
                "kp9", "kp.", "kp/", "kp*", "kp-", "kp+",
                "kpenter", "kp=", "return", "escape", "tab",
                "space", "backspace", "insert", "home", "pageup",
                "delete", "end", "pagedown", "right", "left",
                "down", "up"
            }
            for i, v in ipairs(inputsMoments) do
                if love.keyboard.isDown(v) then
                    drawMessageBox = false
                    return i
                end
                if love.mouse.isDown(1) or love.mouse.isDown(2) then
                    drawMessageBox = false
                    return 1
                end
                -- check for joystick input
                for i = 1, love.joystick.getJoystickCount() do
                    local joystick = love.joystick.getJoysticks()[i]
                    for i = 1, joystick:getButtonCount() do
                        if joystick:isDown(i) then
                            drawMessageBox = false
                            return 1
                        end
                    end
                end
            end
        end
    end
end

function love.math.randomFloat(min, max, precision)
    -- Generate a random floating point number between min and max
    --[[1]] local range = max - min
    --[[2]] local offset = range * math.random()
    --[[3]] local unrounded = min + offset
    
    -- Return unrounded number if precision isn't given
    if not precision then
        return unrounded
    end
    
    -- Round number to precision and return
    --[[1]] local powerOfTen = 10 ^ precision
    local n
    --[[2]] n = unrounded * powerOfTen
     --[[3]] n = n + 0.5
    --[[4]] n = math.floor(n)
    --[[5]] n = n / powerOfTen
    return n
end

function love.graphics.gradient(dir, ...)
    -- Check for direction
    local isHorizontal = true
    if dir == "vertical" then
        isHorizontal = false
    elseif dir ~= "horizontal" then
        error("bad argument #1 to 'gradient' (invalid value)", 2)
    end

    -- Check for colors
    local colorLen = select("#", ...)
    if colorLen < 2 then
        error("color list is less than two", 2)
    end

    -- Generate mesh
    local meshData = {}
    if isHorizontal then
        for i = 1, colorLen do
            local color = select(i, ...)
            local x = (i - 1) / (colorLen - 1)

            meshData[#meshData + 1] = {x, 1, x, 1, color[1], color[2], color[3], color[4] or (1 )}
            meshData[#meshData + 1] = {x, 0, x, 0, color[1], color[2], color[3], color[4] or (1)}
        end
    else
        for i = 1, colorLen do
            local color = select(i, ...)
            local y = (i - 1) / (colorLen - 1)

            meshData[#meshData + 1] = {1, y, 1, y, color[1], color[2], color[3], color[4] or (1)}
            meshData[#meshData + 1] = {0, y, 0, y, color[1], color[2], color[3], color[4] or (1)}
        end
    end

    -- Resulting Mesh has 1x1 image size
    --return love.graphics.newMesh(meshData, "strip", "static")
    return {
        img = love.graphics.newMesh(meshData, "strip", "static"),

        change = function(self, dir, ...)
            -- Check for direction
            local isHorizontal = true
            if dir == "vertical" then
                isHorizontal = false
            elseif dir ~= "horizontal" then
                error("bad argument #1 to 'gradient' (invalid value)", 2)
            end

            -- Check for colors
            local colorLen = select("#", ...)
            if colorLen < 2 then
                error("color list is less than two", 2)
            end

            -- Generate mesh
            local meshData = {}
            if isHorizontal then
                for i = 1, colorLen do
                    local color = select(i, ...)
                    local x = (i - 1) / (colorLen - 1)

                    meshData[#meshData + 1] = {x, 1, x, 1, color[1], color[2], color[3], color[4] or (1 )}
                    meshData[#meshData + 1] = {x, 0, x, 0, color[1], color[2], color[3], color[4] or (1)}
                end
            else
                for i = 1, colorLen do
                    local color = select(i, ...)
                    local y = (i - 1) / (colorLen - 1)

                    meshData[#meshData + 1] = {1, y, 1, y, color[1], color[2], color[3], color[4] or (1)}
                    meshData[#meshData + 1] = {0, y, 0, y, color[1], color[2], color[3], color[4] or (1)}
                end
            end

            -- Resulting Mesh has 1x1 image size
            --return love.graphics.newMesh(meshData, "strip", "static")
            self.img = love.graphics.newMesh(meshData, "strip", "static")
        end,

        draw = function(self, x, y, r, sx, sy, ox, oy, kx, ky)
            love.graphics.draw(self.img, x, y, r, sx, sy, ox, oy, kx, ky)
        end
    }
end