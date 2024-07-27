local Modscript = {}

Modscript.funcs = require "modules.Game.Modding.ModscriptFunctions"
Modscript.timedFunctions = {}
Modscript.shaders = {}
Modscript.currentShader = ""

Modscript.downscroll = Settings.options["General"].downscroll

require("modules.Ease")

-- MODS BASED OFF OF NOTITG'S MIRIN TEMPLATE

local beat = 0
local beatcutoff = 10

local modlist = {{}}
local enabledMods = {{}}
local storedMods = {{}}
local targetMods = {{}}
local isTweening = {{}}
local tweenStart = {{}}
local tweenLen = {{}}
local tweenCurve = {{}}
local tweenEx1 = {{}}
local tweenEx2 = {{}}
local modnames = {}
local laneSpeeds = {}

activeMods = {{}}

local function scale(x, l1, h1, l2, h2)
    return (((x) - (l1)) * ((h2) - (l2)) / ((h1) - (l1)) + (l2))
end

local function modtable_compare(a, b)
    return a[1] < b[1]
end

local storedScrollSpeed = 1

local function flicker()
    if (musicTime * 0.001 * 60) % 2 < 1 then
        return -1
    else
        return 1
    end
end

local function setLaneScrollspeed(c, scrollSpeed)
    laneSpeeds[c] = scrollSpeed
end

local function strumAlpha(col)
    local alpha = 1

    local m = activeMods[1]

    if m.alpha ~= 1 then
        alpha = alpha * m.alpha
    end
    if m.dark ~= 0 or m["dark" .. col] ~= 0 then
        alpha = alpha * (1 - m.dark) * (1 - m["dark" .. col])
    end

    return alpha
end

local function hitObjectAlpha(yOffset, col)
    local alp = 1

    local m = activeMods[1]

    if m.alpha ~= 1 then
        alp = alp * m.alpha
    end

    if m.stealth ~= 0 or m["stealth" .. col] ~= 0 then
        alp = alp * (1 - m.stealth) * (1 - m["stealth" .. col])
    end

    if m.hidden ~= 0 then
        if yOffset < m.hiddenoffset and yOffset >= m.hidden-200 then
            local hiddenMult = -(yOffset - m.hiddenoffset) / 200
            alp = alp * (1 - hiddenMult) * m.hidden
        elseif yOffset < m.hiddenoffset-100 then
            alp = alp * (1-m.hidden)
        end
    end

    return alp
end

local camTemp = {
    x = 0,
    y = 0,
    angle = 0,
}

Modscript.cam = {
}

function getReverseForCol(col)
    local m = activeMods[1]
    local val = 0

    val = val + m.reverse + m["reverse" .. col]

    if m.split ~= 0 and col > 2 then val = val + m.split end
    if m.cross ~= 0 and col == 2 or col == 3 then val = val + m.cross end
    if m.alternate ~= 0 and col % 2 == 0 then val = val + m.alternate end

    return val
end

function getYAdjust(yOffset, col)
    local m = activeMods[1]

    local yadj = 0
    if m.wave ~= 0 then
        yadj = yadj + m.wave * 20 * math.sin((yOffset+250)/76)
    end

    if m.brake ~= 0 then
        local effectHeight = 500
        local lScale = scale(yOffset, 0, effectHeight, 0, 1)
        local newYOffset = yOffset * lScale
        local brakeYAdjust = m.brake * (newYOffset - yOffset)

        brakeYAdjust = math.clamp(brakeYAdjust, -400, 400)
        yadj = yadj + brakeYAdjust
    end

    yOffset = yOffset + yadj

    return yOffset
end

function hitObjectEffects(yOffset, col)
    local m = activeMods[1]

    local xpos, ypos, rotz = 0, 0, 0

    if m["confusion" .. col] ~= 0 or m.confusion ~= 0 then
        rotz = rotz + m["confusion" .. col] + m.confusion 
    end
    if m.dizzy ~= 0 then
        rotz = rotz + m.dizzy * yOffset
    end

    if m.drunk ~= 0 then
        xpos = xpos + m.drunk * ( math.cos( musicTime*0.001 + col*(0.2) + 1*(0.2) + yOffset*(10)/(720*1.5)) * 100 )
    end
    if m.tipsy ~= 0 then
        ypos = ypos + m.tipsy * ( math.cos( musicTime*0.001 *(1.2) + col*(2.0) + 1*(0.2) ) * 200*0.4 )
    end
    if m.adrunk ~= 0 then
        xpos = xpos + m.adrunk * ( math.cos( musicTime*0.001 + col*(0.2) + 1*(0.2) + yOffset*(10)/(720*1.5)) * 100 )
    end
    if m.atipsy ~= 0 then
        ypos = ypos + m.atipsy * ( math.cos( musicTime*0.001 *(1.2) + col*(2.0) + 1*(0.2) ) * 200*0.4 )
    end

    if m['movex'..col] ~= 0 or m.movex ~= 0 then
        xpos = xpos + m['movex'..col] + m.movex
    end
    if m['amovex'..col] ~= 0 or m.amovex ~= 0 then
        xpos = xpos + m['amovex'..col] + m.amovex
    end
    if m['movey'..col] ~= 0 or m.movey ~= 0 then
        ypos = ypos + m['movey'..col] + m.movey
    end
    if m['amovey'..col] ~= 0 or m.amovey ~= 0 then
        ypos = ypos + m['amovey'..col] + m.amovey
    end

    if m['reverse'..col] ~= 0 or m.reverse ~= 0 or m.split ~= 0 or m.cross ~= 0 or m.alternate ~= 0 then
        ypos = ypos + getReverseForCol(col) * 450
    end
    
    if m.flip ~= 0 then
        local fDistance = 200 * 2 * (1.5 - col)
        xpos = xpos + fDistance * m.flip
    end

    if m.invert ~= 0 then
        local fDistance = 200 * (col%2 == 0 and 1 or -1)
        xpos = xpos + fDistance * m.invert
    end

    if m.beat ~= 0 then
        local beatStrength = m.beat
        
        local accelTime = 0.3
        local totalTime = 0.7
        
        -- If the song is really fast, slow down the rate, but speed up the
        -- acceleration to compensate or it'll look weird.
        lBeat = beat + accelTime
        
        local evenBeat = false
        if math.floor(lBeat) % 2 ~= 0 then
            evenBeat = true
        end
        
        lBeat = lBeat-math.floor( lBeat )
        lBeat = lBeat+1
        lBeat = lBeat-math.floor( lBeat )
        
        if lBeat<totalTime then
        
            local amount = 0
            if lBeat < accelTime then
                amount = scale( lBeat, 0.0, accelTime, 0.0, 1.0)
                amount = amount*amount
            else 
                amount = scale( lBeat, accelTime, totalTime, 1.0, 0.0)
                amount = 1 - (1-amount) * (1-amount)
            end

            if evenBeat then
                amount = amount*-1
            end

            local shift = 40.0*amount*math.sin( ((yOffset/30.0)) + (math.pi/2) )
            
            xpos = xpos + beatStrength * shift
        end
    end

    return xpos, ypos, rotz
end

local defaultPositions = {
    {x = 0, y = 0},
    {x = 0, y = 0},
    {x = 0, y = 0},
    {x = 0, y = 0}
}

local mods,curMod = {},1
local perframe = {}
local event,curevent = {},1
local songStarted = false

function Modscript:reset()
    self.downscroll = Settings.options["General"].downscroll
    for i = 1, #states.game.Gameplay.strumLineObjects.members do
        states.game.Gameplay.strumLineObjects.members[i].y = 50
    end
    self.timedFunctions = {}
    self.shaders = {}
    self.currentShader = ""
    modlist = {
        {
            beat = 0,
            flip = 0,
            invert = 0,
            drunk = 0,
            tipsy = 0,
            adrunk = 0, --non conflict accent mod
            atipsy = 0, --non conflict accent mod
            movex = 0,
            movey = 0,
            amovex = 0,
            amovey = 0,
            reverse = 0,
            split = 0,
            cross = 0,
            dark = 0,
            stealth = 0,
            alpha = 1,
            confusion = 0,
            dizzy = 0,
            wave = 0,
            brake = 0,
            hidden = 0,
            hiddenoffset = 0,
            alternate = 0,
            camx = 0,
            camy = 0,
            rotationz = 0,
            camwag = 0,
            xmod = 1, --scrollSpeed
            drawsize = 10 --beatcutoff
        }
    }
    self.cam = {
        x = 0,
        y = 0,
        angle = 0,
    }
    for i = 1, states.game.Gameplay.mode do
        laneSpeeds[i] = Settings.options["General"].scrollspeed
    end
    storedMods = {{}}
    targetMods = {{}}
    isTweening = {{}}
    tweenStart = {{}}
    tweenLen = {{}}
    tweenCurve = {{}}
    tweenEx1 = {{}}
    tweenEx2 = {{}}
    modnames = {{}}

    activeMods = {{}}

    storedScrollSpeed = Settings.options["General"].scrollspeed

    states.game.Gameplay.ableToModscript = false
end

function Modscript:load(script)
    self.downscroll = false
    for i = 1, #states.game.Gameplay.strumLineObjects.members do
        states.game.Gameplay.strumLineObjects.members[i].y = 50
    end
    self.timedFunctions = {}
    self.shaders = {}
    self.currentShader = ""
    modlist = {
        {
            beat = 0,
            flip = 0,
            invert = 0,
            drunk = 0,
            tipsy = 0,
            adrunk = 0, --non conflict accent mod
            atipsy = 0, --non conflict accent mod
            movex = 0,
            movey = 0,
            amovex = 0,
            amovey = 0,
            reverse = 0,
            split = 0,
            cross = 0,
            dark = 0,
            stealth = 0,
            alpha = 1,
            confusion = 0,
            dizzy = 0,
            wave = 0,
            brake = 0,
            hidden = 0,
            hiddenoffset = 0,
            alternate = 0,
            camx = 0,
            camy = 0,
            rotationz = 0,
            camwag = 0,
            xmod = 1, --scrollSpeed
            drawsize = 10 --beatcutoff
        }
    }
    self.cam = {
        x = 0,
        y = 0,
        angle = 0,
    }
    for i = 1, states.game.Gameplay.mode do
        laneSpeeds[i] = Settings.options["General"].scrollspeed
    end
    storedMods = {{}}
    targetMods = {{}}
    isTweening = {{}}
    tweenStart = {{}}
    tweenLen = {{}}
    tweenCurve = {{}}
    tweenEx1 = {{}}
    tweenEx2 = {{}}
    modnames = {{}}

    activeMods = {{}}

    storedScrollSpeed = Settings.options["General"].scrollspeed
    activeMods[1].xmod = storedScrollSpeed
    modlist[1].xmod = storedScrollSpeed

    for i = 1, states.game.Gameplay.mode do
        modlist[1]["movex" .. i] = 0
        modlist[1]["movey" .. i] = 0
        modlist[1]["amovex" .. i] = 0
        modlist[1]["amovey" .. i] = 0
        modlist[1]["dark" .. i] = 0
        modlist[1]["stealth" .. i] = 0
        modlist[1]["confusion" .. i] = 0
        modlist[1]["reverse" .. i] = 0
        modlist[1]["xmod" .. i] = 1

        defaultPositions[i] = {x = 0, y = 0}
    end

    function definemod(t)
        local k, v = t[1], t[2]
        if not v then v = 0 end
        storedMods[Modscript.funcs.currentPlayfield][k] = v
        targetMods[Modscript.funcs.currentPlayfield][k] = v
        isTweening[Modscript.funcs.currentPlayfield][k] = false
        tweenStart[Modscript.funcs.currentPlayfield][k] = 0
        tweenLen[Modscript.funcs.currentPlayfield][k] = 0
        tweenCurve[Modscript.funcs.currentPlayfield][k] = linear
        tweenEx1[Modscript.funcs.currentPlayfield][k] = nil
        tweenEx2[Modscript.funcs.currentPlayfield][k] = nil
        table.insert(modnames[1], k)
    end

    for k, v in pairs(modlist[1]) do
        definemod({k, v})
    end

    Try(
        function()
            chunk = love.filesystem.load(script)()
        end,
        function()
            return false
        end
    )

    -- BASE MODSCRIPTING FUNCTIONS
    function CreateSprite(name, path, x, y)
        local NewPath = states.game.Gameplay.M_folderPath .. "/mod/" .. path
        Try(
            function()
                Modscript.funcs:createSprite(name, NewPath, x, y)
            end,
            function()
                return false
            end
        )
    end

    function AddSpriteAnimation(name, prefix, animName, framerate, looped)
        if Modscript.funcs.sprites[name] then
            Modscript.funcs.sprites[name]:addAnimation(prefix, animName, framerate, looped)
        end
    end

    function PlaySpriteAnimation(name, animName)
        if Modscript.funcs.sprites[name] then
            Modscript.funcs.sprites[name]:playAnimation(animName)
        end
    end

    function SetSpriteProperty(name, property, value)
        if Modscript.funcs.sprites[name] then
            Modscript.funcs.sprites[name][property] = value
        end
    end

    function GetSpriteProperty(name, property)
        if Modscript.funcs.sprites[name] then
            return Modscript.funcs.sprites[name][property]
        end
    end

    function RemoveSprite(name)
        if Modscript.funcs.sprites[name] then
            Modscript.funcs.sprites[name] = nil
        end
    end

    function MovePlayfield(x, y)
        states.game.Gameplay.playfields[Modscript.funcs.currentPlayfield].x = x
        states.game.Gameplay.playfields[Modscript.funcs.currentPlayfield].y = y
    end

    function SetShader(shader)
        Modscript.currentShader = shader
    end

    function AddShader(shader)
        table.insert(Modscript.shaders, shader)
    end

    function SetModifier(modifier)
       
    end

    function EnableModifier(modifier)
        
    end

    function RemoveModifier(modifier)
        
    end

    function SetLastNoteAsFinish(bool)
        states.game.Gameplay.lastNoteIsFinish = bool
    end

    function CreatePlayfield(x, y)
        table.insert(modlist, {}) -- add a new mods table for the new playfield
        table.insert(enabledMods, {})
        states.game.Gameplay:addPlayfield(x, y)
    end

    function SetPlayfield(id)
        Modscript.funcs.currentPlayfield = id
    end

    function MovePlayfield(x, y)
        Modscript.funcs:movePlayfield(x, y)
    end

    function NewShader(name, path)
        Try(
            function()
                Modscript.shaders[name] = love.graphics.newShader(states.game.Gameplay.M_folderPath .. "/mod/" .. path)
            end,
            function()
                return false
            end
        )
    end

    function SetShader(name)
        Modscript.currentShader = name
    end

    function SetShaderProperty(name, property, value)
        if Modscript.shaders[name] then
            Modscript.shaders[name]:send(property, value)
        end
    end

    function CreatePlayfieldVertSprite(id)
        return states.game.Gameplay:createPlayfieldVertSprite(id)
    end

    function GetMainPlayfieldVertSprite()
        return states.game.Gameplay.playfieldVertSprites[1]
    end

    -- SOME BACKEND MODSCRIPTING FUNCTIONS

    -- Init Mods

    for k, v in pairs(modlist[1]) do
        activeMods[1][k] = v
    end

    for k, v in pairs(activeMods[1]) do
        definemod({k, v})
    end

    if #event > 1 then
        table.sort(event, modtable_compare)
    end

    if #mods > 1 then
        table.sort(mods, modtable_compare)
    end

    function me(t)
        table.insert(mods,t)
    end
    
    function m2(t)
        table.insert(event,t)
    end
    
    function mpf(t)
        table.insert(perframe,t)
    end
    
    function set(t)
        table.insert(mods,{t[1],0,linear,t[2],t[3]})
    end

    function setdefault(...)
        -- val, name, val, name, ...
        local args = {...}
        for i = 1, #args, 2 do
            activeMods[1][args[i+1]] = args[i]
        end
    end

    function func(beat, funcToCall)
        table.insert(event, {beat, funcToCall, false})
    end

    for i = 1, states.game.Gameplay.mode do
        local strum = states.game.Gameplay.strumLineObjects.members[i]
        defaultPositions[i] = {x = strum.x, y = strum.y}
    end

    songStarted = true

    return true
end

function Modscript:update(dt, beat)
    beat = (musicTime / 1000) * (states.game.Gameplay.soundManager:getBPM("music") / 60)
    beatcutoff = activeMods[1].drawsize
    
    while curMod <= #mods and beat > mods[curMod][1] do
        local v = mods[curMod]
        
        local mn = v[5]
        local dur = v[2]
        if v.timing and v.timing == "end" then
            dur = v[2] - v[1]
        end

        tweenStart[1][mn] = v[1]
        tweenLen[1][mn] = dur
        tweenCurve[1][mn] = v[3]
        if v.startVal then
            storedMods[1][mn] = v.startVal
        else
            storedMods[1][mn] = activeMods[1][mn]
        end
        targetMods[1][mn] = v[4]
        tweenEx1[1][mn] = v.ex1
        tweenEx2[1][mn] = v.ex2
        isTweening[1][mn] = true

        curMod = curMod + 1
    end

    for _, v in pairs(modnames[1]) do
        if isTweening[1][v] then
            local curTime = beat - tweenStart[1][v]
            local duration = tweenLen[1][v]
            local startStrength = storedMods[1][v]
            local diff = targetMods[1][v] - startStrength
            local curve = tweenCurve[1][v]
            local strength = curve(curTime, startStrength, diff, duration, tweenEx1[1][v], tweenEx2[1][v])
            activeMods[1][v] = strength
            if beat > tweenStart[1][v] + duration then
                print(beat, tweenStart[1][v] + duration, v, activeMods[1][v], targetMods[1][v])
                isTweening[1][v] = false
            end
        else
            activeMods[1][v] = targetMods[1][v]
        end
    end

    if #perframe > 0 then
        for i = 1, #perframe do
            local a = perframe[i]
            if beat > a[1] and beat < a[2] then
                a[3](beat)
            end
        end
    end

    while curevent <= #event and beat >= event[curevent][1] do
        if event[curevent][3] or beat < event[curevent][1]+2 then
            event[curevent][2](beat)
        end
        curevent = curevent + 1
    end

    self.cam.angle = activeMods[1].rotationz + activeMods[1].camwag * math.sin(beat * math.pi)
    self.cam.y = activeMods[1].camy
    self.cam.x = activeMods[1].camx

    if songStarted then
        local xmod = activeMods[1].xmod
        for col = 1, 4 do
            local strum = states.game.Gameplay.strumLineObjects.members[col]
        
            local defaultx, defaulty = defaultPositions[col].x, defaultPositions[col].y

            local xp, yp, rz = hitObjectEffects(0, col)
            local alp = strumAlpha(col)

            strum.x, strum.y = defaultx + xp, defaulty + yp
            strum.angle = rz
            strum.alpha = alp

            local scrollSpeed = xmod * activeMods[1]["xmod" .. col] * (1 - 2*getReverseForCol(col))
            setLaneScrollspeed(col, scrollSpeed)
        end

        for _, object in ipairs(states.game.Gameplay.hitObjects.members) do
            local strum = states.game.Gameplay.strumLineObjects.members[object.data]

            if not object.wasGoodHit then
                local xmod = activeMods[1].xmod
                
                local hasHold = #object.children > 0
                local col = object.data
                
                local defaultX, defaultY = defaultPositions[col].x, defaultPositions[col].y
                local scrollSpeed = xmod * activeMods[1]["xmod" .. col] * (1 - 2*getReverseForCol(col))
                local ypos = getYAdjust(defaultY - (musicTime - object.time), col) * scrollSpeed * 0.65

                local xa, ya, rz = hitObjectEffects(ypos-defaultY, col)
                local alp = hitObjectAlpha(ypos-defaultY, col)
                local xa2, ya2, rz2

                object.angle = rz

                object.x = defaultX + xa
                object.y = ypos + ya
                object.alpha = alp

                if hasHold then
                    xa2, ya2, rz2 = hitObjectEffects(defaultY - (musicTime - object.endTime), col)
                    object.children[1].x = defaultX + xa
                    object.children[1].y = ypos + ya + 95
                    local endY = getYAdjust(defaultY - (musicTime - object.endTime), col) * scrollSpeed * 0.65
                    object.children[1].dimensions = {width = 200, height = endY - ypos - 95}
                    object.children[2].dimensions = {width = 200, height = 95}
                    
                    object.children[2].x = defaultX + xa2
                    object.children[2].y = ypos + ya + object.children[1].dimensions.height
                    object.children[2].offset.y = -95
                    object.children[2].flipY = true
                end
            else
                if object and #object.children > 0 then 
                    local ypos = object.y
                    local defaultX, defaultY = defaultPositions[object.data].x, defaultPositions[object.data].y
                    local xa, ya, rz = hitObjectEffects(defaultY, object.data)
                    local xa2, ya2, rz2 = hitObjectEffects(defaultY - (musicTime - object.endTime), object.data)
                    local xmod = activeMods[1].xmod
                    local scrollSpeed = xmod * activeMods[1]["xmod" .. object.data] * (1 - 2*getReverseForCol(object.data))
                    local endY = getYAdjust(defaultY - (musicTime - object.endTime), object.data) * scrollSpeed * 0.65
                    local alp = hitObjectAlpha(defaultY, object.data)

                    object.x = defaultX + xa
                    object.y = strum.y
                    object.angle = rz
                    object.alpha = alp

                    object.children[2].x = defaultX + xa
                    
                    local endY = getYAdjust(defaultY - (musicTime - object.endTime), object.data) * scrollSpeed * 0.65
                    object.children[1].dimensions.height = endY - ypos - 95
                    object.children[1].y = ypos + 95
                    object.children[2].y = ypos + object.children[1].dimensions.height
                end
            end
        end
    end
end

function Modscript:call(func, args)
    if _G[func] then
        return _G[func](unpack(args or {}) or {})
    end
end

function Modscript:endSong()
    self.downscroll = Settings.options["General"].downscroll
end

return Modscript
