--[[----------------------------------------------------------------------------

This file is apart of Rit; a free and open sourced rhythm game made with LÖVE.

Copyright (C) 2022 GuglioIsStupid

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

if love.system.getOS() ~= "NX" then -- show message box doesn't work on Switch, so use the default error handler
	-- modified a slight bit from https://github.com/OverHypedDudes/love2dTemplate/blob/main/modules/errHandler.lua
	function love.errhand(error_message)
		local dialog_message = [[
Rit crashed with the following error:	
%s
]]

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

		local issuebody = [[
Rit has crashed with the following error:
	
%s
	
[If you can, describe what you've been doing when the error occurred]
	
---
Affects: %s
Edition: %s
]]
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
        -- save error to crash.log
        
	end

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
            end
        end
    end

end
