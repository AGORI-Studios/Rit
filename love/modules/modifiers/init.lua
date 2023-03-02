-- Based off of https://github.com/KadeDev/Hex-The-Weekend-Update/blob/main/assets/preload/data/songs/detected/mod-backend.lua

local pow = math.pow
local sin = math.sin
local cos = math.cos
local pi = math.pi
local sqrt = math.sqrt
local abs = math.abs
local asin = math.asin

local ease = require "modules.modifiers.easings"

local mod = {}

mod.modList = {
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
}

for i = 1, 4 do 
    mod.modList['movex'..i] = 0
    mod.modList['movey'..i] = 0
    mod.modList['amovex'..i] = 0
    mod.modList['amovey'..i] = 0
    mod.modList['dark'..i] = 0
    mod.modList['stealth'..i] = 0
    mod.modList['confusion'..i] = 0
    mod.modList['reverse'..i] = 0
    mod.modList['xmod'..i] = 0
end

mod.activeMods = {}

mod.storedMods = {}
mod.targetMods = {}
mod.isTweening = {}
mod.tweenStart = {}
mod.tweenLen = {}
mod.tweenCurve = {}
mod.tweenEx1 = {}
mod.tweenEx2 = {}
mod.modnames = {}

function mod.definemod(t)
	local k,v = t[1],t[2]
	if not v then v = 0 end

	mod.storedMods[k] = v
	mod.targetMods[k] = v
	mod.isTweening[k] = false
	mod.tweenStart[k] = 0
	mod.tweenLen[k] = 0
	mod.tweenCurve[k] = ease.linear
	mod.tweenEx1[k] = nil
	mod.tweenEx2[k] = nil
	table.insert(mod.modnames,k)
end

function mod.flicker()
    if (musicTime * 0.001 * 60) % 2 < 1 then
        return -1
    else
        return 1
    end
end