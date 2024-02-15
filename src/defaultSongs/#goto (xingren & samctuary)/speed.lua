local t = Def.ActorFrame {}

-- if you delete this nothing works.
-- dont ask questions
t[#t+1] = Def.ActorFrame {
    Name = "sped",
    InitCommand = function(self)
        self:xy(SCREEN_CENTER_X, SCREEN_CENTER_Y)
    end,
    Def.Actor {
        Name = "speeed",
        InitCommand = function(self)
            self:sleep(9999999)
        end
    }
}

local timespace = GAMESTATE:GetPlayerState(PLAYER_1):GetPlayerOptions("ModsLevel_Current"):TimeSpacing()
local cmodbpm = GAMESTATE:GetPlayerState(PLAYER_1):GetPlayerOptions("ModsLevel_Current"):ScrollBPM()
local musicrate = GAMESTATE:GetSongOptionsObject("ModsLevel_Current"):MusicRate()

local cm = GAMESTATE:GetPlayerState(PLAYER_1):GetPlayerOptions("ModsLevel_Current"):CMod()
local truesppeed = math.round(cmodbpm * 100 / (135 * musicrate)) / 100


local function DOIDOIT()
    local pos = GAMESTATE:GetSongPosition()
    local beet = pos:GetSongBeat()

    local lbr = 0
    local hbr = 2532

    if beet > lbr and beet < hbr then return true end

    return false
end

-- this should reset mods to default and if it doesnt im not sorry
local function YEEHAW(self)
    local doit = DOIDOIT()
    if doit then
        local mods = GAMESTATE:GetPlayerState(PLAYER_1):GetPlayerOptions("ModsLevel_Current")
        local mods2 = GAMESTATE:GetPlayerState(PLAYER_1):GetPlayerOptions("ModsLevel_Song")
	if cm then
            mods:XMod(1)
            mods2:XMod(1)
            mods:ScrollSpeed(truesppeed)
            mods2:ScrollSpeed(truesppeed)
	end
    else
        local mods = GAMESTATE:GetPlayerState(PLAYER_1):GetPlayerOptions("ModsLevel_Current")
        local mods2 = GAMESTATE:GetPlayerState(PLAYER_1):GetPlayerOptions("ModsLevel_Song")
        if cm then
            mods:CMod(cm)
            mods2:CMod(cm)
        end
        mods:ScrollBPM(cmodbpm)
        mods2:ScrollBPM(cmodbpm)
        mods:TimeSpacing(timespace)
        mods2:TimeSpacing(timespace)
    end
end

t[#t+1] = Def.ActorFrame {
    Name = "oop",
    InitCommand = function(self)
        self:visible(false)
        self:SetUpdateFunction(YEEHAW)
    end,

}

return t