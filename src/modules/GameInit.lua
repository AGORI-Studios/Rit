io.stdout:setvbuf("no")
jit.on()
local GI = {}

function GI.LoadLibraries()
    Object = require("lib.class")
    Timer = require("lib.timer")
    json = require("lib.jsonhybrid")
    state = require("lib.state")
    tinyyaml = require("lib.tinyyaml")
    ini = require("lib.ini")
    clone = require("lib.clone")
    threads = {
        assets = require("lib.loveloader")
    }
    xml = require("lib.xml")
    require("lib.lovefs.lovefs")
    require("lib.luafft")
    if love.system.getOS() == "Windows" then
        windowUtil = require("lib.windows.window")
        windowUtil.setDarkMode(true)
    end
    if love.system.getOS() ~= "NX" then
        Video = require("lib.aqua.Video")

        if Steam then
            noobhub = require("lib.networking.noobhub")
            networking = {
                latencies = {},
                hub = noobhub.new({
                    server = "server.rit.agori.dev",
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
                    if message and (type(message) == "string" or type(message) == "number" or type(message) == "boolean") then
                        return
                    end
                    --print("Received message: " .. json.encode(message))
                    if message.action == "ping" then
                        networking.hub:publish({
                            message = {
                                action = "pong",
                                id = message.id,
                                original_timestamp = message.timestamp,
                                timestamp = love.timer.getTime()
                            }
                        })
                    elseif message.action == "pong" then
                        --print("Pong id " .. message.id .. " took " .. love.timer.getTime() - message.original_timestamp .. " seconds")
                        table.insert(networking.latencies, love.timer.getTime() - message.original_timestamp)
                        local sum, count = 0, 0
                        for i, latency in ipairs(networking.latencies) do
                            sum = sum + latency
                            count = count + 1
                        end

                        --print("Average latency: " .. sum / count)
                    elseif message.action == "gotServers" then
                        --print("Got servers: " .. json.encode(message.servers))
                        -- we don't want it to affect everyone, so only affect the person with the SteamID that matches
                        if message.user.steamID == tostring(SteamID) then
                            states.menu.Multiplayer.ServerMenu.serverList = message.servers
                            state.switch(states.menu.Multiplayer.ServerMenu)
                            --print(#states.menu.Multiplayer.ServerMenu.serverList)
                        end
                    elseif message.action == "updateServerInfo_USERJOINED" then
                        if networking.currentServerID and message.id == networking.currentServerData.id then
                            networking.currentServerData = message.server
                            networking.currentServerID = message.id

                            if discordRPC and networking.currentServerData then
                                discordRPC.presence = {
                                    details = "In a multiplayer lobby",
                                    state = "Lobby: " .. networking.currentServerData.name .. " - " .. #networking.currentServerData.players .. "/" .. networking.currentServerData.maxPlayers,
                                    largeImageKey = "totallyreallogo",
                                    largeImageText = "Rit" .. (__DEBUG__ and " DEBUG MODE" or "")
                                }
                                GI.UpdateDiscord()
                            end
                        end
                        if message.user.steamID == tostring(SteamID) then
                            --print("User joined: " .. message.user.steamID)
                            state.switch(states.menu.Multiplayer.LobbyMenu, networking.currentServerData)
                        end
                    elseif message.action == "updateServerInfo_FORCEREMOVEUSER" then
                        if networking.currentServerID and message.id == networking.currentServerData.id then
                            networking.currentServerData = nil
                            networking.currentServerID = nil
                        end
                    elseif message.action == "getPlayersInfo_INGAME" then
                        if message.user.steamID == tostring(SteamID) then
                            -- no state switch
                            networking.currentServerData = message.server
                            --print("Got players info: " .. json.encode(message.server))
                        end
                    elseif message.action == "startGame" then
                        -- if user is in lobby (message.id)
                        if networking.currentServerID and message.id == networking.currentServerData.id then
                            networking.inMultiplayerGame = true
                            local song = getSongFromNameAndDiff(networking.currentServerData.currentSong.songName, networking.currentServerData.currentSong.songDiff)
                            --print("Starting game with song: " .. tostring(song))
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

                            networking.hub:publish({
                                message = {
                                    action = "updateServerInfo_INGAME_STARTEND",
                                    user = {
                                        steamID = tostring(SteamID),
                                        name = tostring(SteamUserName)
                                    },
                                    id = networking.currentServerData.id,
                                    started = true
                                }
                            })
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
                    elseif message.action == "serverLobby_CHATMESSAGE" then
                        if message.id == networking.currentServerData.id then
                            networking.currentServerData = message.server -- update the server data and adds the message
                        end
                    end
                end
            })

            if networking.connected then
                networking.hub:publish({
                    message = {
                        action = "updateServerInfo_FORCEREMOVEUSER",
                        id = networking.currentServerID or 0,
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
    VertSprite = require("modules.Classes.VertSprite")
    SoundManager = require("modules.Classes.SoundManager")
    require("modules.Game.SongHandler")
    NoteHelper = require("modules.Game.NoteHelper")
    Modscript = require("modules.Game.Modscript")
    SearchAlgorithm = require("modules.Game.Helpers.SearchAlgorithm")
    Settings = require("modules.Game.Settings")
    Settings.loadOptions()
    require("modules.Game.Input")
    Popup = require("modules.Popup")
    skin = require("modules.Game.SkinHandler")
    localize = require("modules.Game.Localize")
    VirtualController = (require("modules.VirtualController"))
    menuController = VirtualController({
        {
            text = "",
            key = "return",
            x = Inits.GameWidth - 325,
            y = Inits.GameHeight - 325,
            width = 250,
            height = 250,
            color = {0.5, 1, 0.5}
        },
        {
            text = "",
            key = "down",
            x = 75,
            y = Inits.GameHeight - 225,
            width = 125,
            height = 125,
            color = {0.5, 0.5, 1}
        },
        {
            text = "",
            key = "up",
            x = 75,
            y = Inits.GameHeight - 375,
            width = 125,
            height = 125,
            color = {0.5, 0.5, 1}
        },
        {
            text = "",
            key = "escape",
            x = 75,
            y = 75,
            width = 75,
            height = 75,
            color = {1, 0.5, 0.5}
        }
    })
    currentController = menuController

    -- only do 4k and 7k for now,,,
    local keybinds = Settings.options["Keybinds"]["4kBinds"]:splitAllCharacters()

    -- each key is a width of 1920/4 = 480
    local keys = {
        {
            text = "",
            key = "escape",
            x = 75,
            y = 75,
            width = 75,
            height = 75,
            color = {1, 0.5, 0.5}
        }
    }
    for i = 1, 4 do
        table.insert(keys, {
            text = "",
            key = keybinds[i],
            x = 480 * (i-1),
            y = Inits.GameHeight - 250,
            width = 480,
            height = 250,
            color = {0.5, 0.5, 0.5},
            downAlpha = 0.5,
        })
    end
    
    gameController = VirtualController(keys)
    
    -- API Stuff
    RequestJsonData = require("modules.API.RequestJsonData")

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

    HeaderButton = require("modules.Objects.menu.HeaderButton")
    Header = require("modules.Objects.menu.Header")
    Switch = require("modules.Objects.menu.options.Switch")
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
    Cache.members.font["defaultBoldX1.25"] = love.graphics.newFont("assets/fonts/Montserrat-Medium.ttf", 20)
    Cache.members.font["defaultBoldX1.5"] = love.graphics.newFont("assets/fonts/Montserrat-Medium.ttf", 24)
    Cache.members.font["menu"] = love.graphics.newFont("assets/fonts/Montserrat-Medium.ttf", 32)
    Cache.members.font["menuBold"] = love.graphics.newFont("assets/fonts/Montserrat-Bold.ttf", 22)
    Cache.members.font["menuExtraBold"] = love.graphics.newFont("assets/fonts/Montserrat-ExtraBold.ttf", 22)
    Cache.members.font["menuExtraBoldX1.5"] = love.graphics.newFont("assets/fonts/Montserrat-ExtraBold.ttf", 33)
    Cache.members.font["menuExtraBoldX2"] = love.graphics.newFont("assets/fonts/Montserrat-ExtraBold.ttf", 44)
    Cache.members.font["menuExtraBoldX2.5"] = love.graphics.newFont("assets/fonts/Montserrat-ExtraBold.ttf", 55)
    Cache.members.font["menuExtraBoldX3"] = love.graphics.newFont("assets/fonts/Montserrat-ExtraBold.ttf", 66)
    Cache.members.font["menuX1.5"] = love.graphics.newFont("assets/fonts/Montserrat-Light.ttf", 33)
    Cache.members.font["menuBoldX1.5"] = love.graphics.newFont("assets/fonts/Montserrat-Medium.ttf", 33)
    Cache.members.font["menuBig"] = love.graphics.newFont("assets/fonts/Montserrat-Light.ttf", 64)
    Cache.members.font["menuBigBold"] = love.graphics.newFont("assets/fonts/Montserrat-Medium.ttf", 64)
    Cache.members.font["menuMedium"] = love.graphics.newFont("assets/fonts/Montserrat-Light.ttf", 48)
    Cache.members.font["menuMediumBold"] = love.graphics.newFont("assets/fonts/Montserrat-Medium.ttf", 48)
    Cache.members.font["NatsRegular26"] = love.graphics.newFont("assets/fonts/NATS-Regular.otf", 26)
    Cache.members.font["NatsRegular16"] = love.graphics.newFont("assets/fonts/NATS-Regular.otf", 16)

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
            CreditsMenu = require("states.menu.CreditsMenu"),
            OptionsMenu = require("states.menu.OptionsMenu"),
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
                SteamUserImgSteamData = love.image.newImageData(width, height, "rgba8", SteamUserImgSteamData)
                SteamUserAvatarSmall = love.graphics.newImage(SteamUserImgSteamData)
            end
        end
    end 
end

function GI.UpdateDiscord()
    if discordRPC then
        if discordRPC.presence then
            discordRPC.updatePresence(discordRPC.presence)
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
    state.wheelmoved(x, y)

    if love.keyboard.isDown("lalt") then
        masterVolume = masterVolume + y * 5
    end
    masterVolume = math.clamp(masterVolume, 0, 100)
    Settings.options["General"].globalVolume = masterVolume / 100
end

function love.mousepressed(x, y, b)
    state.mousepressed(x, y, b)
    --currentController:touchpressed(0, x, y, 0, 0, 0)
end

function love.mousereleased(x, y, b)
    state.mousereleased(x, y, b)
    --currentController:touchreleased(0, x, y, 0, 0, 0)
end

function love.mousemoved(x, y, dx, dy, istouch)
    state.mousemoved(x, y, dx, dy, istouch)
    --currentController:touchmoved(0, x, y, dx, dy, 0)
end

function love.touchpressed(id, x, y, dx, dy, pressure)
    state.touchpressed(id, x, y, dx, dy, pressure)
    currentController:touchpressed(id, x, y, dx, dy, pressure)
end

function love.touchreleased(id, x, y, dx, dy, pressure)
    state.touchreleased(id, x, y, dx, dy, pressure)
    currentController:touchreleased(id, x, y, dx, dy, pressure)
end

function love.touchmoved(id, x, y, dx, dy, pressure)
    state.touchmoved(id, x, y, dx, dy, pressure)
    currentController:touchmoved(id, x, y, dx, dy, pressure)
end

function love.textinput(t)
    state.textinput(t)
end

function love.keyreleased(key)
    state.keyreleased(key)
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
                id = networking.currentServerData.id,
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
    ---@diagnostic disable-next-line: cast-local-type
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

    local bg = love.graphics.newImage("assets/images/ui/menu/playBG.png")

    local gitURL = "https://github.com/AGORI-Studios/Rit/issues/new"
    -- automatically format an issue with os, renderer, version, and error
    local gitIssueFormat = [[
**OS**: %s
**Renderer Info**: %s
**Version**: %s
**Error**:
```lua
%s
```

Please describe what you were doing when this error occurred.
|INSERT DESCRIPTION HERE|

    ]]

    local function encodeToURL(str)
        return str:gsub("\n", "%%0A"):gsub(" ", "%%20")
    end

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
                local namer, versionr, vendorr, devicer = love.graphics.getRendererInfo( )
                local versionStr = "LOVE: " .. love._version .. " (" .. love._version_codename .. ")"
                versionStr = versionStr .. " | Game Version " .. __VERSION__
                local issue = string.format(gitIssueFormat, love.system.getOS(), (namer .. ", " .. versionr .. ", " .. vendorr .. ", " .. devicer), versionStr, p)
                love.system.openURL(gitURL .. "?body=" .. encodeToURL(issue))
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
            ---@diagnostic disable-next-line: param-type-mismatch
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
                    for x = -1, 1 do
                        for y = -1, 1 do
                            love.graphics.setColor(0, 0, 0)
                            love.graphics.printf(v.text, (buttonWidth+15)*(i-1)+20+x, 10+5+y, buttonWidth, "center")
                        end
                    end
                    love.graphics.setColor(1, 1, 1)
                    love.graphics.printf(v.text, (buttonWidth+15)*(i-1)+20, 10+5, buttonWidth, "center")
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

local ChannelEvent = love.thread.getChannel("EventThread")
local ChannelActive = love.thread.getChannel("EventThreadActive")
local EventThread

local dt, fps = 0, 0

function love.run()
    EventThread = love.thread.newThread("modules/EventThread.lua")
	if love.load then love.load(love.arg.parseGameArguments(arg), arg) end

	-- We don't want the first frame's dt to include time taken by love.load.
	if love.timer then love.timer.step() end
    collectgarbage()

	local focused, clock, nextDraw, cap = true, 0, 0, 0 
    local prevFpsUpdate, sinceLastFps, frames = 0, 0, 0
    local t = {}
    local a = true

    local function doEvent(name, a, ...)
        if name == "quit" and not love.quit() then
            ChannelEvent:clear()
            ChannelActive:clear()
            ChannelActive:push(0)
            return a or 0, ...
        end

        if type(a) == "string" then
            return love.handlers[name](...)
        else
            return love.handlers[name](a, ...)
        end
    end

	-- Main loop time.
	return function()
        if EventThread:isRunning() then
            ChannelActive:clear()
            ChannelActive:push(1)
            out = ChannelEvent:pop()
            while out do
                clock, v = ChannelEvent:demand(), ChannelEvent:demand()
                for i = 1, v do
                    t[i] = ChannelEvent:demand()
                end
                n, out, v = v, doEvent(out, unpack(t, 1, v))
                if out then
                    love.event.pump()
                    return out, v
                end
            end
        elseif a then
            EventThread:start()
            ChannelEvent:clear()
            ChannelActive:clear()
        end

        love.event.pump()
        for name, a, b, c, d, e, f in love.event.poll() do
            a, b = doEvent(name, a, b, c, d, e, f)
            if a then return a, b end
        end

        cap, b = 1 / (love._fps_cap or 60), false
        dt, clock = love.timer.step(), love.timer.getTime()

		if love.update then 
            love.update(dt)
        end
        if love.graphics.isActive() and (b or clock > nextDraw - dt) then
            love.graphics.origin()
            love.graphics.clear(0, 0, 0)
            if love.draw then love.draw() end
            love.graphics.present()
            nextDraw, sinceLastFps, frames = clock + cap, clock - prevFpsUpdate, frames + 1
            if sinceLastFps > .5 then
                fps, prevFpsUpdate, frames = math.round(frames / sinceLastFps), clock, 0
            end
        end

        if love.window.hasFocus() then
            if b then
                love.timer.sleep(cap - dt)
            else
                love.timer.sleep(dt < 0.001 and 0.001 or 0)
            end
            focused = true
        else
            if focused then
                collectgarbage()
                collectgarbage()
            else
                collectgarbage("step")
            end
            focused = love.timer.sleep(cap)
        end
	end
end

function love.setFpsCap(fps)
    love._fps_cap = fps or 60
end

-- End of Love Functions

return GI