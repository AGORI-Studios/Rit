local ffi = require("ffi")
local reg = debug.getregistry()
local steam = reg.Portal
local api = steam.api

--- Clans are basically Steam groups.
-- @module clan
-- @alias Clan
-- @inherit Handle
local Clan = {}
setmetatable(Clan, { __index = reg.Handle })
reg.Clan = Clan

--- This is an internal function. Please use @{steam.getClan} instead.
-- @tparam string id Clan ID
-- @see steam.getClan
function Clan:init(id)
  self:setId(id)
end

--- Gets the display name for the specified Steam group; if the local client knows about it.
-- @treturn string Group name
function Clan:getName()
  local n = api.Friends.GetClanName(self.handle)
  return (n == ffi.NULL) and "" or ffi.string(n)
end

--- Checks if the Steam group is public.
-- @treturn boolean True if the group is public
function Clan:isPublic()
  return api.Friends.IsClanPublic(self.handle)
end

--- Checks if the Steam group is an official game group/community hub.
-- @treturn boolean True if the group is official
function Clan:isOfficial()
  return api.Friends.IsClanOfficialGameGroup(self.handle)
end

--- Gets the owner of a Steam Group.
-- @treturn User The user who owns the group
function Clan:getOwner()
  local uid = api.Friends.GetClanOwner(self.handle)
  return steam.getUser(uid)
end

--- Gets a list of the officers of the Steam group.
-- @treturn table Table of User objects
-- @see Clan:requestOfficers
function Clan:getOfficers()
  local n = api.Friends.GetClanOfficerCount(self.handle)
  if n > 0 then
    local list = {}
    for i = 1, n do
      local h = api.Friends.GetClanOfficerByIndex(self.handle, i - 1)
      list[i] = steam.getUser(h)
    end
    return list
  end
end

--- Requests information about Steam group officers (administrators and moderators).
-- You can only ask about Steam groups that a user is a member of.
-- This will NOT download avatars for the officers automatically.
-- This is an asynchronous request so please use @{Clan:onReceiveOfficers} or provide a callback function to receive the results.
-- @tparam function func Callback function triggered when the list of officers is downloaded
-- @see Clan:getOfficers
-- @see Clan:onReceiveOfficers
function Clan:requestOfficers(func)
  api.Friends.RequestClanOfficerList(function(q)
    if self.handle then
      local res = (q and q.m_bSuccess > 0) and 1 or 0
      local list
      if res == 1 then
        list = self:getOfficers()
      end
      self:callback(func or "onReceiveOfficers", res, list)
    end
  end, self.handle)
end

--- Callback triggered when the list of officers is downloaded.
-- @see Clan:requestOfficers
function Clan:onReceiveOfficers()
end

local online = ffi.new("int[1]")
local ingame = ffi.new("int[1]")
local chatting = ffi.new("int[1]")
--- Gets the most recent information we have about what the users in a Steam Group are doing.
-- @treturn number Number of members that are online
-- @treturn number Number of members that are online and in-game
-- @treturn number Number of members in the group chat room
-- @see Clan:requestActivity
function Clan:getActivity()
  if api.Friends.GetClanActivityCounts(self.handle, online, ingame, chatting) then
    return online[0], ingame[0], chatting[0]
  end
end

local array = ffi.new("CSteamID[1]")
--- Refresh the Steam Group activity data or get the data from groups other than one that the current user is a member.
-- This is an asynchronous request so please use @{Clan:onReceiveActivity} or provide a callback function to receive the results.
-- @tparam function func Callback function triggered when the activity stats are downloaded
-- @see Clan:onReceiveActivity
-- @see Clan:getActivity
function Clan:requestActivity(func)
  array[0] = self.handle
  api.Friends.DownloadClanActivityCounts(function(q)
    if self.handle then
      local res = (q and q.m_bSuccess) and 1 or 0
      self:callback(func or "onReceiveActivity", res)
    end
  end, array, 1)
end

--- Callback triggered when the activity stats are downloaded.
-- @see Clan:requestActivity
function Clan:onReceiveActivity()
end

--- Allows the user to join Steam group (clan) chats right within the game.
-- The behavior is somewhat complicated,
-- because the user may or may not be already in the group chat from outside the game or in the overlay.
-- You can activate the Steam client overlay to open the in-game version of the chat.
-- This is an asynchronous request so please use @{Clan:onJoinChat} or provide a callback function to receive the results.
-- @tparam function func Callback function triggered after joining the chat
-- @see Clan:onJoinChat
-- @see Clan:leaveChat
function Clan:joinChat(func)
  api.Friends.JoinClanChatRoom(function(q)
    if self.handle then
      local res = (q and q.m_eChatRoomEnterResponse == 1) and 1 or 0
      self:callback(func or "onJoinChat", res)
    end
  end, self.handle)
end

--- Callback triggered after joining the chat.
-- @see Clan:joinChat
function Clan:onJoinChat()
end

--- Leaves a Steam group chat that the user has previously entered with @{Clan:joinChat}.
-- @treturn boolean True if successful
-- @see Clan:joinChat
function Clan:leaveChat()
  return api.Friends.LeaveClanChatRoom(self.handle)
end

--- Returns a list of all of the members present in the Steam group chat.
-- @treturn table Table of @{User} objects
function Clan:getChatMembers()
  local n = api.Friends.GetClanChatMemberCount(self.handle)
  if n > 0 then
    local list = {}
    for i = 1, n do
      local h = api.Friends.GetChatMemberByIndex(self.handle, i - 1)
      list[i] = steam.getUser(h)
    end
    return list
  end
end

local buffer = ffi.new("unsigned char[8193]")
local bsize = ffi.sizeof(buffer)
local kind = ffi.new("uint32[1]")
local sender = ffi.new("CSteamID[1]")
--- Gets message from the Steam group chat room.
-- Chat messages are indexed by number.
-- @tparam number index Chat message index
-- @treturn string String message
-- @treturn User Message author
-- @see Clan:getChatMessageCount
function Clan:getChatMessage(i)
  assert(i >= 1)
  local n = api.Friends.GetClanChatMessage(self.handle, i - 1, buffer, bsize, kind, sender)
  if n > 0 then
    if kind[0] == 1 then
      return ffi.string(buffer, n), steam.getUser(sender[0])
    end
  end
end

--- Gets the total number of messages in the Steam group chat room.
-- @treturn number Number of messages
-- @see Clan:getChatMessage
function Clan:getChatMessageCount()
  for i = 1, 1024 do
    local n = api.Friends.GetClanChatMessage(self.handle, i - 1, buffer, 1, kind, sender)
    if n == 0 and kind[0] == 0 then
      return i - 1
    end
  end
end

--- Sends a chat message to the Steam group chat room.
-- @tparam string msg Message
-- @treturn boolean True if the message was successfully sent
function Clan:sendChatMessage(msg)
  return api.Friends.SendClanChatMessage(self.handle, msg)
end

--[[
function Clan:isFollowing(func)
  app.portal.api.Friends.IsFollowing(function(q)
    if self.handle then
      local res = q and q.m_eResult or 0
      local follow = q and q.m_bIsFollowing or false
      self:callback(func or "onFollowing", res, follow)
    end
  end, self.handle)
end
]]