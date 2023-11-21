local ffi = require("ffi")
local reg = debug.getregistry()
local steam = reg.Portal
local api = steam.api

--- User objects handle avatars, stats, achievements and other personal data.
-- @module user
-- @alias User
-- @inherit Handle
local User = {}
setmetatable(User, { __index = reg.Handle })
reg.User = User

--- This is an internal function.
-- Please use @{steam.getUser} instead.
-- @tparam[opt] string id User ID in decimal format
-- @see steam.getUser
function User:init(id)
  self:setId(id)
end

--- Returns the persona name of the user.
-- The persona name can be changed and can contain UTF-8 characters.
-- @treturn string Persona name
-- @see User:setName
-- @see User:requestName
function User:getName()
  local n = api.Friends.GetFriendPersonaName(self.handle)
  return (n == ffi.NULL) and "" or ffi.string(n)
end

--- Sets the persona name of the owner.
-- @tparam string name New persona name
-- @see User:getName
-- @see User:requestName
function User:setName(name)
  assert(self:isOwner())
  api.Friends.SetPersonaName(name)
end

--- This is an internal function.
-- Requests that the user's persona name is fetched and cached locally.
-- @treturn boolean False if the persona name is already cached
-- @see User:getName
-- @see User:setName
function User:requestName()
  return api.Friends.RequestUserInformation(self.handle, true)
end

--- Checks the user's status among friends.
-- @treturn boolean True if currently visible among friends
-- @see User:getGamePlayed
function User:isOnline()
  return api.Friends.GetFriendPersonaState(self.handle) > 0
end

--- Checks the user is friends with the owner.
-- @treturn boolean True if friends with the owner
-- @see steam.getFriends
function User:isFriend()
  return api.Friends.GetFriendRelationship(self.handle) == 3
end

--- Gets the user's Steam level if available, otherwise it queues the Steam level for download.
-- @treturn number Steam level or 0 if unavailable
function User:getLevel()
  return api.Friends.GetFriendSteamLevel(self.handle)
end

--- Invites a friend or clan member to the current game using a special invite string.
-- If the target user accepts the invite then the invite string gets added to the command-line when launching the game.
-- @tparam string msg Invitation message
-- @treturn boolean True if the invite was successfully sent
-- @see Lobby:invite
function User:inviteToGame(s)
  return api.Friends.InviteUserToGame(self.handle, s)
end

--- Checks if the user is the current owner.
-- @treturn boolean True if the user is the owner
function User:isOwner()
  return self.handle == api.User.GetSteamID()
end

local width = ffi.new("uint32[1]")
local height = ffi.new("uint32[1]")
--- Returns an avatar if it's cached.
-- Avatars are usually cached for the owner and his friends,
-- but you may need to call @{User:requestAvatar} for other users.
-- @tparam[opt="medium"] string size Image size: "small", "medium" or "large"
-- @treturn string Encoded image data of the avatar or nil
-- @see User:requestAvatar
function User:getAvatar(size)
  size = size or "medium"
  local index = 0
  if size == "large" then
    index = api.Friends.GetLargeFriendAvatar(self.handle)
  elseif size == "small" then
    index = api.Friends.GetSmallFriendAvatar(self.handle)
  else
    index = api.Friends.GetMediumFriendAvatar(self.handle)
  end
  if index > 0 and api.Utils.GetImageSize(index, width, height) then
    local w, h = width[0], height[0]
    local n = w*h*4
    local b = ffi.new("char[?]", n)
    api.Utils.GetImageRGBA(index, b, n)
    return (b == ffi.NULL) and "" or ffi.string(b, n), w, h
  end
end

--- Requests the avatar for caching.
-- It's a lot slower to download avatars and churns the local cache, so if you don't need avatars, don't request them.
-- @treturn boolean False if the avatar is already cached
-- @see User:getAvatar
function User:requestAvatar()
  return api.Friends.RequestUserInformation(self.handle, false)
end

local boolean = ffi.new("bool[1]")
local stamp = ffi.new("uint32[1]")
--- Gets the achievement status, and the time it was unlocked if unlocked.
-- If the return value is true, but the unlock time is zero, that means it was unlocked before Steam began tracking achievement unlock times (December 2009). The time is provided in Unix epoch format, seconds since January 1, 1970 UTC.
-- @tparam string ach Achievement name
-- @treturn boolean True if unlocked
-- @treturn number Timestamp of when it was unlocked
-- @see User:setAchievement
-- @see User:clearAchievement
function User:getAchievement(k)
  if api.UserStats.GetUserAchievementAndUnlockTime(self.handle, k, boolean, stamp) then
    return boolean[0], stamp[0]
  end
end

--- Unlocks a specific attachment.
-- You must have called @{User:requestCurrentStats} and it needs to return successfully via its callback prior to calling this!
-- @tparam string stat Achievement name
-- @treturn boolean True if successful
-- @see User:getAchievement
-- @see User:clearAchievement
-- @see User:storeStats
function User:setAchievement(k)
  assert(self:isOwner())
  return api.UserStats.SetAchievement(k)
end

--- Resets the unlock status of an achievement.
-- This is primarily only ever used for testing.
-- @tparam string stat Achievement name
-- @treturn boolean True if successful
-- @see User:getAchievement
-- @see User:setAchievement
function User:clearAchievement(k)
  assert(self:isOwner())
  return api.UserStats.ClearAchievement(k)
end

local int = ffi.new("int[1]")
local float = ffi.new("float[1]")
--- Gets the current value of the a stat for the specified user.
-- You must have called @{User:requestCurrentStats} and it needs to return successfully via its callback prior to calling this!
-- @tparam string stat Stat name
-- @treturn number Stat value
-- @see User:setStat
-- @see User:requestStats
-- @see User:requestCurrentStats
function User:getStat(k)
  if api.UserStats.GetUserStatInt32(self.handle, k, int) then
    return int[0]
  elseif api.UserStats.GetUserStatFloat(self.handle, k, float) then
    return float[0]
  end
end

--- Sets or updates the value of a given stat for the current user.
-- You must have called @{User:requestCurrentStats} and it needs to return successfully via its callback prior to calling this!
-- @tparam string stat Stat name
-- @tparam number value Stat value
-- @treturn boolean True if successful
-- @see User:getStat
-- @see User:storeStats
function User:setStat(k, v)
  assert(self:isOwner())
  return api.UserStats.SetStatInt32(k, v) or api.UserStats.SetStatFloat(k, v)
end

--- Asynchronously request the owner's current stats and achievements from the server.
-- The equivalent function for other users is @{User:requestStats}.
-- @treturn boolean False if the avatar is already cached
-- @see User:getStat
-- @see User:requestStats
function User:requestCurrentStats()
  assert(self:isOwner())
  return api.UserStats.RequestCurrentStats()
end

--- Asynchronously request the user's stats and achievements from the server.
-- This function triggers the @{User:onReceiveStats} callback.
-- @tparam function func Callback function triggered when the stats are ready
-- @see User:getStat
-- @see User:requestCurrentStats
-- @see User:onReceiveStats
function User:requestStats(func)
  return api.UserStats.RequestUserStats(function(q)
    if self.handle then
      local res = q and q.m_eResult or 0
      self:callback(func or "onReceiveStats", res)
    end
  end, self.handle)
end

--- Callback triggered when the user stats are received from the server.
-- @see User:requestStats
function User:onReceiveStats()
end

--- Stores the user's stats and achievements on the server.
-- @treturn boolean True if successful
-- @see User:setStat
-- @see User:resetStats
function User:storeStats()
  return api.UserStats.StoreStats()
end

--- Resets all stats and achievements unlocked by the owner.
-- @tparam boolean ach Determines if achievement data should be wiped too
-- @treturn boolean True if successful
-- @see User:storeStats
function User:resetStats(ach)
  return api.UserStats.ResetAllStats(ach == true)
end

local info = ffi.new("FriendGameInfo_t[1]")
--- Checks if the specified friend is in a game, and gets info about the game if they are.
-- @treturn number AppID of the game your friend is playing
-- @treturn[opt] Lobby The lobby that your friend has joined, if available
-- @see User:isOnline
function User:getGamePlayed()
  local appid, lobby
  if self:isOwner() then
    appid = steam.getAppId()
  elseif api.Friends.GetFriendGamePlayed(self.handle, info) then
    local q = info[0]
    appid = q.m_gameID.parts.m_nAppID
    local lid = q.m_steamIDLobby.m_steamid.m_unAll64Bits
    if lid ~= api.CSteamID_Invalid then
      lobby = steam.getLobby(lid)
    end
  end
  return appid, lobby
end

local userDialogs = 
{
  steamid = true,
  chat = true,
  jointrade = true,
  stats = true,
  achievements = true,
  friendadd = true,
  friendremove = true,
  friendrequestaccept = true,
  friendrequestignore = true,
}

--- Opens the user's profile in the game overlay.
-- @tparam string dialog Dialog options: "steamid", "chat", "jointrade", "stats", "achievements", "friendadd", "friendremove", "friendrequestaccept" or "friendrequestignore"
-- @see steam.activateOverlay
function User:activateOverlay(dialog)
  assert(userDialogs[dialog], "invalid user dialog")
  api.Friends.ActivateGameOverlayToUser(dialog, self.handle)
end

--- Mark a target user as 'played with'.
-- The current user must be in game with the other player for the association to work.
-- @see User:getPlayedWith
-- @see steam.getPlayedWith
function User:setPlayedWith()
  assert(not self:isOwner())
  api.Friends.SetPlayedWith(self.handle)
end

--- Gets the app ID of the game that user played with someone on their recently-played-with list.
-- @treturn number AppID
-- @treturn number Amount of co-play time
-- @see User:setPlayedWith
function User:getPlayedWith()
  assert(not self:isOwner())
  local appid = api.Friends.GetFriendCoplayGame(self.handle)
  local tstamp = api.Friends.GetFriendCoplayTime(self.handle)
  if appid > 0 and tstamp > 0 then
    return appid, tstamp
  end
end

--- Sets a Rich Presence key/value for the current user that is automatically shared to all friends playing the same game.
-- Each user can have up to 20 keys set.
-- @tparam string key Key string (where "status", "connect", "steam_display", "steam_player_group", "steam_player_group_size" are reserved)
-- @tparam string value Value string
-- @treturn boolean True if successful
-- @see User:clearRichPresence
-- @see User:getRichPresence
function User:setRichPresence(k, v)
  assert(self:isOwner())
  return api.Friends.SetRichPresence(k, v)
end

--- Clears all previously set Rich Presence keys.
-- @see User:getRichPresence
-- @see User:setRichPresence
function User:clearRichPresence()
  assert(self:isOwner())
  api.Friends.ClearRichPresence()
end

--- Sets a Rich Presence value for a key.
-- @tparam string key Key string
-- @treturn string value Value string
-- @see User:setRichPresence
-- @see User:clearRichPresence
-- @see User:requestRichPresence
function User:getRichPresence(k)
  local v = api.Friends.GetFriendRichPresence(self.handle, k)
  v = ffi.string(v)
  return v ~= "" and v
end

--- Requests the rich presence details for users who are not friends.
-- @see User:getRichPresence
function User:requestRichPresence()
  api.Friends.RequestFriendRichPresence(self.handle)
end

local buffer = ffi.new("char[1024]")
local size = ffi.new("int[1]")
--- Retrieve an authentication ticket to be sent to the entity who wishes to authenticate you.
-- @treturn string Authentication ticket
-- @see User:cancelAuthTicket
function User:getAuthTicket()
  api.User.GetAuthSessionTicket(buffer, 1024, size)
  return ffi.string(buffer, size[0])
end

--- Cancels an auth ticket received from @{User:getAuthTicket}.
-- This should be called when no longer playing with the specified entity.
-- @tparam string ticket Authentication ticket
-- @see User:getAuthTicket
function User:cancelAuthTicket(ticket)
  if type(ticket) ~= "cdata" then
    ticket = tostring(ticket)
    ticket = ffi.C.strtoull(ticket, nil, 10)
  end
  api.User.CancelAuthTicket(ticket)
end