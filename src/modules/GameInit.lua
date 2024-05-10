local GI = {}

function GI.LoadLibraries()
    Object = require("lib.class")
    Timer = require("lib.timer")
    json = require("lib.json")
    state = require("lib.state")
    tinyyaml = require("lib.tinyyaml")
    ini = require("lib.ini")
    clone = require("lib.clone")
    threadLoader = require("lib.loveloader")
    xml = require("lib.xml")
    require("lib.lovefs.lovefs")
    require("lib.luafft")
    if love.system.getOS() ~= "NX" then
        Video = require("lib.aqua.Video")

        if Steam then
            noobhub = require("lib.networking.noobhub")
            networking = {
                latencies = {},
                hub = noobhub.new({
                    server = "127.0.0.1", -- Localhost
                    port = 1337
                }),
                frameCount = 0,
                connected = false,
                currentServerID = 0,
                currentServerData = {},
                inMultiplayerGame = false
            }

            networking.connected = networking.hub:subscribe({
                channel = "main-channel",
                callback = function(message)
                    --print("Received message: " .. json.encode(message))
                    print(message.action)

                    if message.action == "ping" then
                        print("Sending test pong")
                        networking.hub:publish({
                            message = {
                                action = "pong",
                                id = message.id,
                                original_timestamp = message.timestamp,
                                timestamp = love.timer.getTime()
                            }
                        })
                    elseif message.action == "pong" then
                        print("Pong id " .. message.id .. " took " .. love.timer.getTime() - message.original_timestamp .. " seconds")
                        table.insert(networking.latencies, love.timer.getTime() - message.original_timestamp)
                        local sum, count = 0, 0
                        for i, latency in ipairs(networking.latencies) do
                            sum = sum + latency
                            count = count + 1
                        end

                        print("Average latency: " .. sum / count)
                    elseif message.action == "gotServers" then
                        print("Got servers: " .. json.encode(message.servers))
                        -- we don't want it to affect everyone, so only affect the person with the SteamID that matches
                        if message.user.steamID == tostring(SteamID) then
                            states.menu.Multiplayer.ServerMenu.serverList = message.servers
                            state.switch(states.menu.Multiplayer.ServerMenu)
                            --print(#states.menu.Multiplayer.ServerMenu.serverList)
                        end
                    elseif message.action == "updateServerInfo_USERJOINED" then
                        if message.user.steamID == tostring(SteamID) then
                            print("User joined: " .. message.user.steamID)
                            networking.currentServerData = message.server
                            state.switch(states.menu.Multiplayer.LobbyMenu, networking.currentServerData)
                        end
                    elseif message.action == "getPlayersInfo_INGAME" then
                        if message.user.steamID == tostring(SteamID) then
                            -- no state switch
                            networking.currentServerData = message.server
                            print("Got players info: " .. json.encode(message.server))
                        end
                    elseif message.action == "startGame" then
                        -- if user is in lobby (message.id)
                        if message.id == networking.currentServerData.id then
                            networking.inMultiplayerGame = true
                            local song = getSongFromNameAndDiff(networking.currentServerData.currentSong.songName, networking.currentServerData.currentSong.songDiff)
                            local songPath = song.path
                            local chartVer = song.type
                            local folderPath = song.folderPath
                            local filename = song.filename
                            local diffName = song.difficultyName
                            local mode = song.mode

                            love.filesystem.mount("songs/" .. filename, "song")
                            states.game.Gameplay.chartVer = chartVer
                            states.game.Gameplay.songPath = songPath
                            states.game.Gameplay.folderpath = folderPath
                            states.game.Gameplay.difficultyName = diffName
                            switchState(states.game.Gameplay, 0.3, nil)
                        end
                    elseif message.action == "resultScreen_NEWENTRY" then
                        if message.id == networking.currentServerData.id then
                            networking.currentServerData = message.server
                            -- states.screens.Multiplayer.ResultsScreen.isEveryoneFinished
                            states.screens.Multiplayer.ResultsScreen.isEveryoneFinished = true
                            for i, player in ipairs(networking.currentServerData.players) do
                                if not player.completed then
                                    states.screens.Multiplayer.ResultsScreen.isEveryoneFinished = false
                                    return
                                end
                            end
                        end
                    end
                end
            })

            if networking.connected then
                networking.hub:publish({
                    message = {
                        action = "updateServerInfo_FORCEREMOVEUSER",
                        user = {
                            steamID = tostring(SteamID),
                            name = tostring(SteamUserName)
                        }
                    }
                })
            end
        end
    end
end

function GI.LoadClasses()
    Group = require("modules.Classes.Group")
    Cache = require("modules.Classes.Cache")
    Point = require("modules.Classes.Point")
    Sprite = require("modules.Classes.Sprite")
    SoundManager = require("modules.Classes.SoundManager")
    require("modules.Game.SongHandler")
    require("modules.Game.Input")
    Modscript = require("modules.Game.Modscript")
    Settings = require("modules.Game.Settings")
    Settings.loadOptions()
    Popup = require("modules.Popup")
    skin = require("modules.Game.SkinHandler")
    localize = require("modules.Game.Localize")

    localize.loadLocale(Settings.options["General"].language)
end

function GI.LoadShaders()
    return {
        backgroundEffects = love.graphics.newShader("shaders/backgroundEffects.glsl"),
    }
end

function GI.ClearOSModule()
    for k, v in pairs(os) do
        if k ~= "clock" and k ~= "date" and k ~= "difftime" and 
            k ~= "time" and k ~= "tmpname" and k ~= "getenv" and
            k ~= "setlocale" then
            os[k] = nil
        end
    end
end

function GI.LoadObjects()
    StrumObject = require("modules.Objects.game.StrumObject")
    HitObject = require("modules.Objects.game.HitObject")
    Playfield = require("modules.Objects.game.Playfield")
    TimingLine = require("modules.Objects.game.TimingLine")

    SongButton = require("modules.Objects.menu.SongButton")
    ServerButton = require("modules.Objects.menu.ServerButton")
    Spectrum = require("modules.Objects.menu.Spectrum")
end

function GI.LoadParsers()
    Parsers = {
        ["Quaver"] = require("modules.Parsers.Quaver"),
        ["osu!"] = require("modules.Parsers.Osu"),
        ["Stepmania"] = require("modules.Parsers.Stepmania"),
        ["Malody"] = require("modules.Parsers.Malody"),
        ["Rit"] = require("modules.Parsers.Rit"),
        ["CloneHero"] = require("modules.Parsers.Clone")
    }
end

function GI.LoadDefaultFonts()
    Cache.members.font["default"] = love.graphics.newFont("assets/fonts/Montserrat-Light.ttf", 16)
    Cache.members.font["defaultBold"] = love.graphics.newFont("assets/fonts/Montserrat-Medium.ttf", 16)
    Cache.members.font["menu"] = love.graphics.newFont("assets/fonts/Montserrat-Medium.ttf", 32)
    Cache.members.font["menuBold"] = love.graphics.newFont("assets/fonts/Montserrat-Bold.ttf", 22)
    Cache.members.font["menuExtraBold"] = love.graphics.newFont("assets/fonts/Montserrat-ExtraBold.ttf", 22)
    Cache.members.font["menuBig"] = love.graphics.newFont("assets/fonts/Montserrat-Light.ttf", 64)
    Cache.members.font["menuBigBold"] = love.graphics.newFont("assets/fonts/Montserrat-Medium.ttf", 64)
    Cache.members.font["menuMedium"] = love.graphics.newFont("assets/fonts/Montserrat-Light.ttf", 48)
    Cache.members.font["menuMediumBold"] = love.graphics.newFont("assets/fonts/Montserrat-Medium.ttf", 48)

    -- some font functions
    function setFont(font)
        local font = font or "default"
        love.graphics.setFont(Cache.members.font[font])
    end
    function fontWidth(font, text)
        local font, text = font or "default", text or "A"
        return Cache.members.font[font]:getWidth(text)
    end
    function fontHeight(font, text)
        local font, text = font or "default", text or "A"
        return Cache.members.font[font]:getHeight(text)
    end
end

function GI.LoadStates()
    return {
        game = {
            Gameplay = require("states.game.Gameplay"),
        },
        menu = {
            StartMenu = require("states.menu.StartMenu"),
            SongMenu = require("states.menu.SongMenu"),
            Multiplayer = {
                ServerMenu = require("states.menu.Multiplayer.ServerMenu"),
                LobbyMenu = require("states.menu.Multiplayer.LobbyMenu"),
            },
        },
        screens = {
            PreloaderScreen = require("states.screen.PreloaderScreen"),
            SplashScreen = require("states.screen.SplashScreen"),
            MapEditorScreen = require("states.screen.MapEditorScreen"),
            Importers = {
                QuaverImportScreen = require("states.screen.Importers.QuaverImportScreen"),
                OsuImportScreen = require("states.screen.Importers.OsuImportScreen"),
            },
            Jukebox = require("states.screen.JukeboxScreen"),
            Multiplayer = {
                ResultsScreen = require("states.screen.Multiplayer.ResultsScreen"),
            }
        }
    }
end

function GI.LoadSubstates()
    return {
        game = {
            Pause = require("substates.game.Pause"),
        },
        menu = {
            Options = require("substates.menu.Options")
        }
    }
end

function GI.InitSteam()
    if Steam then -- Steam initailization
        if not Steam.init() or not Steam.isRunning() then
            print("Steam is not running.")
            Steam = nil
        else
            SteamUser = Steam.getUser()
            SteamID = Steam.getUserId()
            SteamUserName = SteamUser:getName()
            local SteamUserImgSteamData, width, height = SteamUser:getAvatar("small")
            if SteamUserImgSteamData then
                SteamUserAvatarSmall = love.graphics.newImage(love.image.newImageData(width, height, "rgba8", SteamUserImgSteamData))
            end
        end
    end 
end

function GI.UpdateDiscord()
    if discordRPC then
        if love.timer.getTime() or 0 > discordRPC.nextPresenceUpdate then
            if discordRPC.presence then
                discordRPC.updatePresence(discordRPC.presence)
            end
            discordRPC.nextPresenceUpdate = love.timer.getTime() + 2.0
        end
        discordRPC.runCallbacks()
    end
end

function GI.CreateFolders()
    if not love.filesystem.getInfo("songs") then
        love.filesystem.createDirectory("songs")
    end
    if not love.filesystem.getInfo("replays") then
        love.filesystem.createDirectory("replays")
    end
end 

-- Love Functions
function love.wheelmoved(x, y)
    if imgui then
        imgui.love.WheelMoved(x, y)
        if imgui.love.GetWantCaptureMouse() then return end
    end
    state.wheelmoved(x, y)

    if love.keyboard.isDown("lalt") then
        masterVolume = masterVolume + y * 5
    end
    masterVolume = math.clamp(masterVolume, 0, 100)
    Settings.options["General"].globalVolume = masterVolume / 100
end

function love.mousepressed(x, y, b)
    if imgui then
        imgui.love.MousePressed(b)
        if imgui.love.GetWantCaptureMouse() then return end
    end
    state.mousepressed(x, y, b)
end

function love.mousereleased(x, y, b)
    if imgui then
        imgui.love.MouseReleased(b)
        if imgui.love.GetWantCaptureMouse() then return end
    end
    state.mousereleased(x, y, b)
end

function love.textinput(t)
    if imgui then
        imgui.love.TextInput(t)
        if imgui.love.GetWantCaptureKeyboard() then return end
    end
    state.textinput(t)
end

function love.keyreleased(key)
    if imgui then
        imgui.love.KeyReleased(key)
        if imgui.love.GetWantCaptureKeyboard() then return end
    end
    state.keyreleased(key)
end

function love.mousemoved(x, y, dx, dy, istouch)
    if imgui then
        imgui.love.MouseMoved(x, y)
        if imgui.love.GetWantCaptureMouse() then return end
    end
    state.mousemoved(x, y, dx, dy, istouch)
end

-- imgui doesn't support touch, so simulate mouse
function love.touchpressed(id, x, y, dx, dy, pressure)
    
    if imgui then
        love.mouse.setPosition(x, y)
        imgui.love.MousePressed(1)
        if imgui.love.GetWantCaptureMouse() then return end
    end
    state.touchpressed(id, x, y, dx, dy, pressure)
end

function love.touchreleased(id, x, y, dx, dy, pressure)
    if imgui then
        love.mouse.setPosition(x, y)
        imgui.love.MouseReleased(1)
        if imgui.love.GetWantCaptureMouse() then return end
    end
    state.touchreleased(id, x, y, dx, dy, pressure)
end

function love.touchmoved(id, x, y, dx, dy, pressure)
    if imgui then
        love.mouse.setPosition(x, y)
        imgui.love.MouseMoved(x, y)
        if imgui.love.GetWantCaptureMouse() then return end
    end
    state.touchmoved(id, x, y, dx, dy, pressure)
end

local utf8 = require("utf8")

local function error_printer(msg, layer)
	print((debug.traceback("Error: " .. tostring(msg), 1+(layer or 1)):gsub("\n[^\n]+$", "")))
end

function love.errorhandler(msg)
    msg = tostring(msg)

	error_printer(msg, 2)

	if not love.window or not love.graphics or not love.event then
		return
	end

	if not love.graphics.isCreated() or not love.window.isOpen() then
		local success, status = pcall(love.window.setMode, 800, 600)
		if not success or not status then
			return
		end
	end

    if Steam and networking.connected and networking.currentServerData then
        networking.hub:publish({
            message = {
                action = "updateServerInfo_FORCEREMOVEUSER",
                user = {
                    steamID = tostring(SteamID),
                    name = tostring(SteamUserName)
                }
            }
        })
    end

	-- Reset state.
	if love.mouse then
		love.mouse.setVisible(true)
		love.mouse.setGrabbed(false)
		love.mouse.setRelativeMode(false)
		if love.mouse.isCursorSupported() then
			love.mouse.setCursor()
		end
	end
	if love.joystick then
		-- Stop all joystick vibrations.
		for i,v in ipairs(love.joystick.getJoysticks()) do
			v:setVibration()
		end
	end
	if love.audio then love.audio.stop() end

	love.graphics.reset()
	local font = love.graphics.setNewFont(14)

	love.graphics.setColor(1, 1, 1)

	local trace = debug.traceback()

	love.graphics.origin()

	local sanitizedmsg = {}
	for char in msg:gmatch(utf8.charpattern) do
		table.insert(sanitizedmsg, char)
	end
	sanitizedmsg = table.concat(sanitizedmsg)

	local err = {}

	table.insert(err, "Error\n")
	table.insert(err, sanitizedmsg)

	if #sanitizedmsg ~= #msg then
		table.insert(err, "Invalid UTF-8 string in error message.")
	end

	table.insert(err, "\n")

	for l in trace:gmatch("(.-)\n") do
		if not l:match("boot.lua") then
			l = l:gsub("stack traceback:", "Traceback\n")
			table.insert(err, l)
		end
	end

	local p = table.concat(err, "\n")

	p = p:gsub("\t", "")
	p = p:gsub("%[string \"(.-)\"%]", "%1")

    love.filesystem.write("error.log", p)

    local bg = love.graphics.newImage("assets/images/ui/menu/BGsongList.png")

    local buttons = {
        {
            text = "Quit",
            func = function()
                love.event.quit()
            end
        },
        {
            text = "Restart",
            func = function()
                love.event.quit("restart")
            end
        },
        {
            text = "Go to GitHub",
            func = function()
                love.system.openURL("https://github.com/AGORI-Studios/Rit/issues")
            end
        }
    }

    local _buttonWidth = 0
    local _height = 0

	local function draw()
		if not love.graphics.isActive() then return end
		local pos = 70
        -- scale to window
        love.graphics.push()
            love.graphics.scale(love.graphics.getWidth()/1280, love.graphics.getHeight()/720)
            love.graphics.draw(bg, 0, 0, 0, 1280/bg:getWidth(), 720/bg:getHeight())
            love.graphics.setColor(0, 0, 0, 0.5)
            
            -- get length of sanitizedmsg
            local length = font:getWidth(p)
            local lines = #(string.split(p, "\n"))
            local height = (font:getHeight() * lines)*1.85
            _height = height

            love.graphics.rectangle("fill", pos-15, pos-15, length+35, height+35, 10)
            love.graphics.setColor(1, 1, 1)
            love.graphics.printf(p, pos, pos, 1280 - pos)

            love.graphics.setColor(0, 0, 0, 0.5)
            love.graphics.rectangle("fill", pos + length+50, pos-15, 1280 - pos - length - 100, height+35, 10)
            love.graphics.setColor(1, 1, 1)

            love.graphics.printf("Press Ctrl+C to copy this error", pos+15 + length+50, pos+5, 1280 - pos - length - 100)
            love.graphics.printf("Log saved to " .. love.filesystem.getSaveDirectory() .. "/error.log", pos+15 + length+50, pos + 45, 1280 - pos - length - 100)

            -- buttons (tab at the bottom (stretches to the two top tabs)
            local width = 1280 - pos*2 + 35
            -- 3 buttons: Quit, Restart, Goto github
            local buttonWidth = (width-75)/3
            _buttonWidth = buttonWidth
            love.graphics.setColor(0, 0, 0, 0.5)
            love.graphics.rectangle("fill", pos-15, height+pos+35, width, 60, 10)
            love.graphics.setColor(1, 1, 1)

            love.graphics.push()
                love.graphics.translate(pos-15, height+pos+40)
                for i, v in ipairs(buttons) do
                    love.graphics.setColor(51/255, 10/255, 41/255, 0.75)
                    local mx, my = love.mouse.getPosition()
                    local buttonIsHovered = false
                    -- same code as above, but account for scaling
                    local scaleX = love.graphics.getWidth()/1280
                    local scaleY = love.graphics.getHeight()/720
                    buttonIsHovered = (
                        mx > ((buttonWidth+15)*(i-1)+20)*scaleX and mx < ((buttonWidth+15)*(i-1)+20+buttonWidth)*scaleX and
                        my > (height+pos+40)*scaleY and my < (height+pos+40+50)*scaleY
                    )
                    if buttonIsHovered then
                        love.graphics.setColor(51/255, 10/255, 41/255, 1)
                    end
                    love.graphics.rectangle("fill", (buttonWidth+15)*(i-1)+20, 0, buttonWidth, 50, 10)
                    --[[ love.graphics.setColor(1, 1, 1)
                    love.graphics.printf(v.text, (buttonWidth+10)*(i-1)+20, 10+5, buttonWidth, "center") ]]
                    for x = -1, 1 do
                        for y = -1, 1 do
                            love.graphics.setColor(0, 0, 0)
                            love.graphics.printf(v.text, (buttonWidth+15)*(i-1)+20+x, 10+5+y, buttonWidth, "center")
                        end
                    end
                    love.graphics.setColor(1, 1, 1)
                    love.graphics.printf(v.text, (buttonWidth+15)*(i-1)+20, 10+5, buttonWidth, "center")
                    --[[ if buttonIsHovered and love.mouse.isDown(1) then
                        v.func()
                    end ]]
                end
            love.graphics.pop()

            love.graphics.present()
        love.graphics.pop()
	end

	local fullErrorText = p
    local copied = false
	local function copyToClipboard()
		if not love.system then return end
        if copied then return end -- only copy once, doesn't fill the screen with "Copied to clipboard!"
        copied = true
		love.system.setClipboardText(fullErrorText)
		p = p .. "\nCopied to clipboard!"
	end

	return function()
		love.event.pump()

		for e, a, b, c in love.event.poll() do
			if e == "quit" then
				return 1
			elseif e == "keypressed" and a == "escape" then
				return 1
			elseif e == "keypressed" and a == "c" and love.keyboard.isDown("lctrl", "rctrl") then
				copyToClipboard()
            elseif e == "mousepressed" then
                local mx, my = love.mouse.getPosition()
                for i, v in ipairs(buttons) do
                    --[[ local buttonIsHovered = mx > (_buttonWidth+15)*(i-1)+75 and mx < (_buttonWidth+15)*(i-1)+75+_buttonWidth and my > _height+70+35 and my < _height+70+35+50 ]]
                    local buttonIsHovered = false
                    -- same code as above, but account for scaling
                    local scaleX = love.graphics.getWidth()/1280
                    local scaleY = love.graphics.getHeight()/720
                    buttonIsHovered = (
                        mx > ((_buttonWidth+15)*(i-1)+20)*scaleX and mx < ((_buttonWidth+15)*(i-1)+20+_buttonWidth)*scaleX and
                        my > (_height+70+40)*scaleY and my < (_height+70+40+50)*scaleY
                    )
                    if buttonIsHovered then
                        v.func()
                    end
                end
			elseif e == "touchpressed" then
				local name = love.window.getTitle()
				if #name == 0 or name == "Untitled" then name = "Game" end
				local buttons = {"OK", "Cancel"}
				if love.system then
					buttons[3] = "Copy to clipboard"
				end
				local pressed = love.window.showMessageBox("Quit "..name.."?", "", buttons)
				if pressed == 1 then
					return 1
				elseif pressed == 3 then
					copyToClipboard()
				end
			end
		end

		draw()

		if love.timer then
			love.timer.sleep(0.1)
		end
	end

end
-- End of Love Functions

return GI