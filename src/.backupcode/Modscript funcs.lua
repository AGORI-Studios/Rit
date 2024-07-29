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
        states.game.Gameplay.playfields[currentPlayfield].x = x
        states.game.Gameplay.playfields[currentPlayfield].y = y
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
        storedMods[#states.game.Gameplay.playfields+1] = {}
        targetMods[#states.game.Gameplay.playfields+1] = {}
        isTweening[#states.game.Gameplay.playfields+1] = {}
        tweenStart[#states.game.Gameplay.playfields+1] = {}
        tweenLen[#states.game.Gameplay.playfields+1] = {}
        tweenCurve[#states.game.Gameplay.playfields+1] = {}
        tweenEx1[#states.game.Gameplay.playfields+1] = {}
        tweenEx2[#states.game.Gameplay.playfields+1] = {}
        activeMods[#states.game.Gameplay.playfields+1] = {}
        activeMods[#states.game.Gameplay.playfields+1].xmod = storedScrollSpeed
        modlist[#states.game.Gameplay.playfields+1].xmod = storedScrollSpeed

        for i = 1, states.game.Gameplay.mode do
            modlist[#states.game.Gameplay.playfields+1]["movex" .. i] = 0
            modlist[#states.game.Gameplay.playfields+1]["movey" .. i] = 0
            modlist[#states.game.Gameplay.playfields+1]["amovex" .. i] = 0
            modlist[#states.game.Gameplay.playfields+1]["amovey" .. i] = 0
            modlist[#states.game.Gameplay.playfields+1]["dark" .. i] = 0
            modlist[#states.game.Gameplay.playfields+1]["stealth" .. i] = 0
            modlist[#states.game.Gameplay.playfields+1]["confusion" .. i] = 0
            modlist[#states.game.Gameplay.playfields+1]["reverse" .. i] = 0
            modlist[#states.game.Gameplay.playfields+1]["xmod" .. i] = 1
        end

        for k, v in pairs(modlist[#states.game.Gameplay.playfields+1]) do
            activeMods[#states.game.Gameplay.playfields+1][k] = v
        end
    
        for k, v in pairs(activeMods[#states.game.Gameplay.playfields+1]) do
            definemod({k, v})
        end

        states.game.Gameplay:addPlayfield(x, y)
    end

    function SetPlayfield(id)
        currentPlayfield = id
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