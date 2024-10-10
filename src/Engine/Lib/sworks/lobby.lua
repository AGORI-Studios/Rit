local ffi = require("ffi")
local reg = debug.getregistry()
local steam = reg.Portal
local api = steam.api

--- The lobby is an entity that lives on the Steam back-end servers that is a lot like a chat room.
-- Users can create a new lobby; associate data with a lobby; search for lobbies based on that data; join lobbies; and share information with other users in the lobby.
-- A single lobby can have up to 250 users in it, although typically most games have at most 2-16 players.
-- Skill-based matchmaking is built on top of this system.
-- @module lobby
-- @alias Lobby
-- @inherit Handle
local Lobby = {}
setmetatable(Lobby, { __index = reg.Handle })
reg.Lobby = Lobby

local kinds =
{
  private = 0,
  friends = 1,
  public = 2,
  invisible = 3,
}

--- This is an internal function.
-- Please use @{steam.newLobby} instead.
-- @tparam[opt=public] string kind Kind of lobby: "private", "friends", "public" or "invisible"
-- @tparam[opt=250] number limit Maximum number of users allowed to join the lobby.
-- @tparam[opt] function func Callback function triggered when the lobby is created
-- @see steam.newLobby
function Lobby:create(kind, limit, func)
  kind = kinds[kind or "public"]
  limit = limit or 250
  assert(not self.handle and kind)
  self.handle = api.CSteamID_Invalid
  api.Matchmaking.CreateLobby(function(q)
    if self.handle == api.CSteamID_Invalid then
      local res = q and q.m_eResult or 0
      if res == 1 then
        self:init(q.m_ulSteamIDLobby)
      end
      self:callback(func or "onCreate", res)
    end
  end, kind, limit)
end

--- Callback triggered after creating a new lobby.
-- @see steam.newLobby
function Lobby:onCreate()
end

--- This is an internal function.
-- Please use @{steam.getLobby} instead.
-- @tparam string id ID of an existing lobby
-- @see steam.getLobby
function Lobby:init(id)
  self:setId(id)
end

--- Updates the lobby type.
-- "private" means that the only way to join the lobby is from an invite.
-- "friends" means that the lobby is joinable by friends and invitees.
-- "public" means that the lobby will show in search.
-- "invisible" means that the lobby will show in search, but is not visible to other friends.
-- This is useful if you want a user in two lobbies, for example matching groups together.
-- A user can be in only one regular lobby, and up to two invisible lobbies.
-- @tparam[opt=public] string kind Kind of lobby: "private", "friends", "public" or "invisible"
function Lobby:setType(kind)
  kind = kinds[kind]
  return api.Matchmaking.SetLobbyType(self.handle, kind)
end

--- Joins an existing lobby.
-- This is an asynchronous request so please use @{Lobby:onJoin} or provide a callback function.
-- @tparam[opt] function func Callback function triggered after subscribing
-- @see Lobby:onJoin
-- @see Lobby:setJoinable
-- @see Lobby:leave
function Lobby:join(func)
  api.Matchmaking.JoinLobby(function(q)
    if self.handle then
      local res = (q and q.m_EChatRoomEnterResponse == 1) and 1 or 0
      local user
      if res == 1 then
        user = steam.getUser()
      end
      self:callback(func or "onJoin", res, user)
    end
  end, self.handle)
end

--- Callback triggered after joining a lobby.
-- @see Lobby:join
function Lobby:onJoin()
end

--- Sets whether or not a lobby is joinable by other players. This always defaults to enabled for a new lobby.
-- If joining is disabled, then no players can join, even if they are a friend or have been invited.
-- Lobbies with joining disabled will not be returned from a lobby search.
-- @tparam boolean joinable Determines if the lobby can be joined
-- @treturn boolean True if successful
-- @see Lobby:join
function Lobby:setJoinable(ok)
  return api.Matchmaking.SetLobbyJoinable(self.handle, ok)
end

--- Leave a lobby that the user is currently in; this will take effect immediately on the client side.
-- @see Lobby:join
function Lobby:leave()
  api.Matchmaking.LeaveLobby(self.handle)
end

--- Returns the lobby owner
-- @treturn User User object or nil if you aren"t a member of the lobby
-- @see Lobby:setOwner
function Lobby:getOwner()
  local h = api.Matchmaking.GetLobbyOwner(self.handle)
  if h and h ~= api.CSteamID_Invalid then
    return steam.getUser(h)
  end
end

--- Changes the lobby owner.
-- This can only be set by the owner of the lobby.
-- @tparam User owner The new lobby owner
-- @see Lobby:getOwner
function Lobby:setOwner(user)
  return api.Matchmaking.SetLobbyOwner(self.handle, user.handle)
end

--- Invite another user to the lobby.
-- Shows a list of friends if no specific user is provided.
-- @tparam[opt] User friend The user who will be invited
-- @see User:inviteToGame
function Lobby:invite(user)
  if not user or user:isOwner() then
    -- choose which friend to invite
    api.Friends.ActivateGameOverlayInviteDialog(self.handle)
  else
    -- invite specific friend
    api.Matchmaking.InviteUserToLobby(self.handle, user.handle)
  end
end

--- Returns a list of members who have joined the lobby.
-- The current user must be in the lobby to retrieve the Steam IDs of other users in that lobby.
-- @treturn table List of @{User} objects
function Lobby:getMembers()
  local n = api.Matchmaking.GetNumLobbyMembers(self.handle)
  local list = {}
  for i = 1, n do
    local h = api.Matchmaking.GetLobbyMemberByIndex(self.handle, i - 1)
    list[i] = steam.getUser(h)
  end
  return list
end

--- Get the current limit on the number of users who can join the lobby.
-- @treturn number Number of users who can join the lobby
-- @see Lobby:setLimit
function Lobby:getLimit()
  return api.Matchmaking.GetLobbyMemberLimit(self.handle)
end

--- Set the maximum number of players that can join the lobby.
-- @tparam number Number of users who can join the lobby
-- @treturn boolean True if successful
-- @see Lobby:getLimit
function Lobby:setLimit(n)
  return api.Matchmaking.SetLobbyMemberLimit(self.handle, n)
end

--- Set lobby metadata.
-- @tparam string key Key
-- @tparam string value Value
-- @treturn boolean True if successful
-- @see Lobby:getData
-- @see Lobby:deleteData
-- @see Lobby:requestData
function Lobby:setData(k, v)
  local owner = self:getOwner()
  if owner and owner:isOwner() then
    return api.Matchmaking.SetLobbyData(self.handle, k, v)
  else
    api.Matchmaking.SetLobbyMemberData(self.handle, k, v)
    return true
  end
end

--- Get lobby metadata.
-- @tparam string key Key
-- @tparam[opt] User user User for member data
-- @treturn string Value
-- @see Lobby:setData
-- @see Lobby:deleteData
-- @see Lobby:requestData
function Lobby:getData(k, user)
  local s
  if not user then
    s = api.Matchmaking.GetLobbyData(self.handle, k)
  else
    s = api.Matchmaking.GetLobbyMemberData(self.handle, user.handle, k)
  end
  if s and s ~= ffi.null then
    s = ffi.string(s)
    return s ~= "" and s or nil
  end
end

--- Removes lobby metadata.
-- @tparam string key Key
-- @treturn boolean True if successful
-- @see Lobby:setData
-- @see Lobby:getData
-- @see Lobby:requestData
function Lobby:deleteData(k)
  return api.Matchmaking.DeleteLobbyData(self.handle, k)
end

--- Refreshes all of the metadata for a lobby that you're not in right now.
-- You will never do this for lobbies you're a member of, that data will always be up to date.
-- You can use this to refresh lobbies that you have obtained from RequestLobbyList or that are available via friends.
-- @treturn boolean True if successful
-- @see Lobby:getData
-- @see Lobby:setData
-- @see Lobby:deleteData
function Lobby:requestData()
  return api.Matchmaking.RequestLobbyData(self.handle)
end

local buffer = ffi.new("unsigned char[4000]")
local bsize = ffi.sizeof(buffer)
local kind = ffi.new("uint32[1]")
local sender = ffi.new("CSteamID[1]")
--- Gets message from the lobby chat room.
-- Chat messages are indexed by number.
-- @tparam number index Chat message index
-- @treturn string String message
-- @treturn User Message author
-- @see Lobby:getChatMessageCount
function Lobby:getChatMessage(i)
  assert(i >= 1)
  local n = api.Matchmaking.GetLobbyChatEntry(self.handle, i - 1, sender, buffer, bsize, kind)
  if n > 0 then
    if kind[0] == 1 then
      return ffi.string(buffer, n), steam.getUser(sender[0].m_steamid.m_unAll64Bits)
    end
  end
end

--- Gets the total number of messages in the lobby chat room.
-- @treturn number Number of messages
-- @see Lobby:getChatMessage
function Lobby:getChatMessageCount()
  for i = 1, 1024 do
    local n = api.Matchmaking.GetLobbyChatEntry(self.handle, i - 1, sender, buffer, 1, kind)
    if n == 0 and kind[0] == 0 then
      return i - 1
    end
  end
end

--- Sends a chat message to the lobby chat room.
-- @tparam string msg Message
-- @treturn boolean True if the message was successfully sent
function Lobby:sendChatMessage(msg)
  return api.Matchmaking.SendLobbyChatMsg(self.handle, msg, #msg)
end