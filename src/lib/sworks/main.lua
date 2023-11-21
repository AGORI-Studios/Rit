local ffi = require("ffi")
local path = (...):match("(.-)[^%.]+$")
local api = require(path.."api")
local reg = debug.getregistry()

--- This is the main module used to interact with Steamworks.
-- @module steam
-- @alias steam
local steam = { api = api }
reg.Portal = steam
local isready = false
local users = nil
local clans = nil
local sockets = nil

--- Initializes the Steam client interface.
-- This function will fail if the Steam client is not running or you don't have a valid AppID.
-- Your AppID must be saved as "steam_appid.txt" and placed in your base directory.
-- You will also need to include the correct version of the Steamworks binaries provided by Valve.
-- @treturn boolean True if the interface is initialized
-- @see steam.shutdown
-- @see steam.restart
-- @see steam.update
-- @see steam.isRunning
function steam.init()
  if not isready and api.Init() then
    isready = true
    users = {}
    clans = {}
    sockets = {}
  end
  return isready
end

--- Shuts down the Steam client interface.
-- @see steam.init
-- @see steam.restart
function steam.shutdown()
  users = nil
  clans = nil
  sockets = nil
  api.Shutdown()
end

--- Checks if your Steam client is initialized and running.
-- @treturn boolean True if already running
-- @see steam.init
-- @see steam.shutdown
function steam.isRunning()
  return api.IsSteamRunning()
end

--- Checks if your executable was launched through Steam.
-- Returns true and re-launches your game through Steam if it was not.
-- Returns false when "steam_appid.txt" is present.
-- @param[opt] appid AppID
-- @treturn boolean True if restarting the game is necessary
-- @see steam.shutdown
function steam.restart(appid)
  return api.RestartAppIfNecessary(appid)
end

--- Checks if the owner is connected to Steam.
-- @treturn boolean True if connected or false when offline
function steam.isConnected()
  return api.User.BLoggedOn()
end

--- Checks if the client is running in "Big Picture" mode.
-- @treturn boolean True if "Big Picture" mode is enabled
function steam.isBigPicture()
  return api.Utils.IsSteamInBigPictureMode()
end

--- This function triggers any asynchronous callbacks.
-- You must call steam.update regularly to ensure that your requests are processed.
-- @see steam.init
-- @see steam.isRunning
function steam.update()
  api.Update()
end

--- Retrieves the owner's friends.
-- @treturn table Table of @{User} objects
-- @see User:isFriend
function steam.getFriends()
  local list = {}
  for i = 1, api.Friends.GetFriendCount(0x04) do
    local h = api.Friends.GetFriendByIndex(i - 1, 0x04)
    list[i] = steam.getUser(h)
  end
  return list
end

--- Retrieves other users the owner has recently played with.
-- @treturn table Table of @{User} objects
-- @see User:getPlayedWith
function steam.getPlayedWith()
  local list = {}
  for i = 1, api.Friends.GetCoplayFriendCount() do
    local h = api.Friends.GetCoplayFriend(i - 1)
    list[i] = steam.getUser(h)
  end
  return list
end

--- Finds a specific clan based on ID.
-- @param id Clan ID
-- @treturn Clan Clan object
-- @see steam.getClans
function steam.getClan(id)
  if type(id) ~= "cdata" then
    id = tostring(id)
    id = ffi.C.strtoull(id, nil, 10)
  end
  if id == api.CSteamID_Invalid then
    api.Fail(19)
    return
  end
  local cid = tostring(id)
  local clan = clans[cid]
  if not clan then
    clan = reg.Clan:new()
    clan:init(id)
    clans[cid] = clan
  end
  return clan
end

--- Retrieves clans which the owner has previously joined.
-- @treturn table Table of @{Clan} objects
-- @see steam.getClan
function steam.getClans()
  local list = {}
  for i = 1, api.Friends.GetClanCount() do
    local h = api.Friends.GetClanByIndex(i - 1)
    list[i] = steam.getClan(h)
  end
  return list
end

--- Finds a specific user based on ID.
-- Returns the owner if no id is specified.
-- @tparam[opt] string id User ID in decimal format
-- @treturn User User object
function steam.getUser(id)
  id = id or api.User.GetSteamID()
  if type(id) ~= "cdata" then
    id = tostring(id)
    id = ffi.C.strtoull(id, nil, 10)
  end
  if id == api.CSteamID_Invalid then
    api.Fail(19)
    return
  end
  local cid = tostring(id)
  local user = users[cid]
  if not user then
    user = reg.User:new()
    user:init(id)
    users[cid] = user
  end
  return user
end

--- Requests an existing leaderboard based on name.
-- This is an asynchronous request so the returned @{Board} object cannot be used right away.
-- Please provide a callback function or wait for @{Board:onFind} before making additional requests.
-- @tparam string name Name of an existing leaderboard
-- @tparam[opt] function func Callback function triggered when the board is found
-- @treturn Board Board object
-- @see Board:onFind
-- @see steam.newBoard
function steam.getBoard(name, func)
  local board = reg.Board:new()
  board:init(name, func)
  return board
end

--- Creates or requests an existing leaderboard based on name.
-- This is an asynchronous request so the returned @{Board} object cannot be used right away.
-- Please provide a callback function or wait for @{Board:onCreate} before making additional requests.
-- @tparam string name Leaderboard name
-- @tparam[opt="desc"] string sort Sorting method: "asc" or "desc"
-- @tparam[opt="numeric"] string display Display style: "none", "numeric", "seconds" or "milliseconds"
-- @tparam[opt] function func Callback function triggered when the board is created
-- @treturn Board Board object
-- @see Board:onCreate
-- @see steam.getBoard
function steam.newBoard(name, sort, display, func)
  local board = reg.Board:new()
  board:create(name, sort, display, func)
  return board
end

--- Creates or requests an existing socket via its channel number.
-- @tparam[opt=0] number channel Channel number
-- @tparam[opt="unreliable"] string kind Kind of socket: "unreliable", "nodelay", "reliable" or "buffered"
-- @treturn Socket Socket object
function steam.getSocket(ch, kind)
  ch = tonumber(ch or 0)
  local sock = sockets[ch]
  if not sock then
    sock = reg.Socket:new()
    sockets[ch] = sock
    sock:init(ch, kind)
  end
  return sock
end

--- Creates a new lobby.
-- This is an asynchronous request so the returned @{Lobby} object cannot be used right away.
-- Please provide a callback function or wait for @{Lobby:onCreate} before making additional requests.
-- @tparam[opt=public] string kind Kind of lobby: "private", "friends", "public" or "invisible"
-- @tparam[opt=250] number limit Maximum number of users allowed to join the lobby.
-- @tparam[opt] function func Callback function triggered when the lobby is created
-- @see Lobby:onCreate
-- @see steam.getLobby
function steam.newLobby(kind, limit, func)
  local lobby = reg.Lobby:new()
  lobby:create(kind, limit, func)
  return lobby
end

--- Retrieves an existing lobby based on ID.
-- @tparam string id ID of an existing lobby
-- @treturn Lobby Lobby object
-- @see Lobby:join
-- @see steam.newLobby
-- @see steam.queryLobbies
function steam.getLobby(id)
  if type(id) ~= "cdata" then
    id = tostring(id)
    id = ffi.C.strtoull(id, nil, 10)
  end
  if id == api.CSteamID_Invalid then
    api.Fail(19)
    return
  end
  local lobby = reg.Lobby:new()
  lobby:init(id)
  return lobby
end

--- Searches for existing lobbies for the current game.
-- This is an asynchronous request so please provide a callback function to receive the results.
-- @tparam[opt] table what Table with numerical or string filters
-- @tparam[opt] number limit Maximum number of results
-- @tparam function func Callback function triggered when the search results are ready
-- @see steam.getLobby
function steam.queryLobbies(what, limit, func)
  if what then
    for k, v in pairs(what) do
      if k == "slots" then
        api.Matchmaking.AddRequestLobbyListFilterSlotsAvailable(v)
      elseif type(v) == "number" then
        api.Matchmaking.AddRequestLobbyListNumericalFilter(k, v, 0)        
      else
        api.Matchmaking.AddRequestLobbyListStringFilter(k, v, 0)
      end
    end
  end
  if limit then
    api.Matchmaking.AddRequestLobbyListResultCountFilter(limit)
  end
  api.Matchmaking.RequestLobbyList(function(q)
    local list
    if q then
      list = {}
      for i = 1, q.m_nLobbiesMatching do
        local id = api.Matchmaking.GetLobbyByIndex(i - 1)
        list[i] = steam.getLobby(id)
      end
    end
    func(q ~= nil, list)
  end)
end

--- Finds an existing user-generated content item based on ID.
-- @tparam string id ID of an existing user-generated item 
-- @param[opt] appid AppID if different from the base game
-- @treturn UGC User-generated item
-- @see steam.newUGC
-- @see steam.queryUGC
-- @see steam.getSubscribedUGC
function steam.getUGC(id, appid)
  if type(id) ~= "cdata" then
    id = tostring(id)
    id = ffi.C.strtoull(id, nil, 16)
  end
  if id == api.UGCHandle_Invalid then
    api.Fail(19)
    return
  end
  local ugc = reg.UGC:new()
  ugc:init(id, appid)
  return ugc
end

--- Creates a new user-generated content item.
-- This is an asynchronous request so the returned @{UGC} object cannot be used right away.
-- Please provide a callback function or wait for @{UGC:onCreate} before making additional requests.
-- @tparam[opt="community"] string kind Type of object: "community", "micro", "collection", "art", "video", "screenshot", "game", "software", "concept", "webguide", "guide", "merch", "binding", "accessinvite", "steamvideo" or "managed".
-- @param[opt] appid AppID if different from the base game
-- @tparam[opt] function func Callback function triggered when the item is created
-- @treturn UGC User-generated item
-- @see UGC:onCreate
-- @see steam.getUGC
function steam.newUGC(kind, appid, func)
  local ugc = reg.UGC:new()
  ugc:create(kind, appid, func)
  return ugc
end

--- Retrives all subscribed user-generated items.
-- @tparam number offset1 Starting offset used for pagination
-- @tparam number offset2 Ending offset used for pagination
-- @treturn table Table of @{UGC} objects
-- @see UGC:subscribe
-- @see steam.getUGC
-- @see steam.queryUGC
function steam.getSubscribedUGC(s, e)
  local limit = api.UGC.GetNumSubscribedItems()
  local array = ffi.new("PublishedFileId_t[?]", limit)
  local n = api.UGC.GetSubscribedItems(array, limit)
  local list = {}
  for i = s or 1, math.min(n, e or n) do
    local ugc = steam.getUGC(array[i - 1])
    table.insert(list, ugc)
  end
  return list, n
end

local queries =
{
  popular = 0,
  recent = 1,
  friends = 5,
  unrated = 8,
}

--- Searches for user-generated content by a specific user or by filter.
-- This is an asynchronous request so please provide a callback function to receive the results.
-- @tparam value what User object or filter: "popular", "recent", "friends" or "unrated"
-- @tparam number offset1 Starting offset used for pagination
-- @tparam number offset2 Ending offset used for pagination
-- @tparam function func Callback function triggered when the search results are ready
-- @tparam[opt] table list Table of @{UGC} objects
-- @see steam.getUGC
-- @see steam.getSubscribedUGC
function steam.queryUGC(what, s, e, func, list)
  if what == "subscribed" then
    local q, total = steam.getSubscribedUGC(s, e)
    func(true, q, total)
    return
  end

  local page = math.ceil(s/50)
  local page2 = math.ceil(e/50)

  local appid = steam.getAppId()
  local query
  if type(what) == "string" then
    assert(queries[what])
    query = api.UGC.CreateQueryAllUGCRequestPage(queries[what], 0, appid, appid, page)
  else
    query = api.UGC.CreateQueryUserUGCRequest(what.handle, 0, 0, 0, appid, appid, page)
  end
  api.UGC.SetReturnOnlyIDs(query, true)
  api.UGC.SendQueryUGCRequest(function(q)
    local res = q and q.m_eResult or 0
    local total
    if res == 1 then
      local d = ffi.new("SteamUGCDetails_t[1]")
      list = list or {}
      local s2 = s - (page - 1)*50
      local e2 = math.min(q.m_unNumResultsReturned, s2 + e - s)
      for p = s2, e2 do
        api.UGC.GetQueryUGCResult(query, p - 1, d)
        local ugc = steam.getUGC(d[0].m_nPublishedFileId, appid)
        table.insert(list, ugc)
      end
      total = q.m_unTotalMatchingResults
    end
    api.UGC.ReleaseQueryUGCRequest(query)
    if res ~= 1 then
      api.Fail(res)
    end
    if page2 > page then
      steam.queryUGC(what, (page2 - 1)*50 + 1, e, func, list)
    else
      func(res == 1, list, total)
    end
  end, query)
end

--- Retrives all available achievements for the current game.
-- @treturn table Table of achievement names
-- @see User:getAchievement
function steam.getAchievements()
  local n = api.UserStats.GetNumAchievements()
  local list = {}
  for i = 1, n do
    list[i] = ffi.string(api.UserStats.GetAchievementName(i - 1))
  end
  return list
end

local genDialogs =
{
  friends = true,
  community = true,
  players = true,
  settings = true,
  officialgamegroup = true,
  stats = true,
  achievements = true
}

--- Opens the Steam overlay if available to a specific dialog or page.
-- @tparam[opt="friends"] string page Dialog, AppID or URL address. Possible dialog values: "friends", "community", "players", "settings", "officialgamegroup", "stats" or "achievements"
-- @tparam[opt] User user User object
-- @see steam.setNotificationPosition
-- @see User:activateOverlay
function steam.activateOverlay(p1, p2)
  p1 = p1 or "friends"
  if genDialogs[p1] then
    -- dialog
    api.Friends.ActivateGameOverlay(p1)
  elseif tonumber(p1) then
    -- appid
    api.Friends.ActivateGameOverlayToStore(p1, 0)
  else
    -- url
    api.Friends.ActivateGameOverlayToWebPage(p1)
  end
end

local positions =
{
  topleft = 0,
  topright = 1,
  bottomleft = 2,
  bottomright = 3,
}
--- Sets the position and offset of the notification pop-up.
-- @param string pos Target corner: "topleft", "topright", "bottomleft" or "bottomright"
-- @param[opt] number ox Inset from the corner
-- @param[opt] number oy Inset from the corner
-- @see steam.activateOverlay
function steam.setNotificationPosition(pos, ox, oy)
  api.Utils.SetOverlayNotificationPosition(positions[pos])
  if ox and oy then
    api.Utils.SetOverlayNotificationInset(ox, oy)
  end
end

--- Gets the current game's AppID.
-- @treturn number AppID of the current game
function steam.getAppId()
  return tonumber(api.Utils.GetAppID())
end

local langs = require(path.."languages")
--- Gets the selected language code for the current game or the client.
-- @treturn string Language code
-- @see steam.getCountry
function steam.getLanguage()
  return langs[ffi.string(api.Apps.GetCurrentGameLanguage())]
end

--- Gets the owner's geographic location based on IP.
-- @treturn string Country code
-- @see steam.getLanguage
function steam.getCountry()
  return string.lower(ffi.string(api.Utils.GetIPCountry()))
end

--- Makes a new HTTP or HTTPS request.
-- This is an asynchronous request so please provide a callback function to receive the results.
-- @tparam string url URL address
-- @tparam[opt] string post Raw post body
-- @tparam function func Callback function triggered once the request if completed
-- @treturn boolean True if the request parameters are valid
-- @see steam.isConnected
function steam.request(url, opt, func)
  return api.Request(url, opt, func)
end

-- check if we are in a "ready" state
local ignore = { init = true, isRunning = true, restart = true }
for k, v in pairs(steam) do
  if type(v) == "function" and not ignore[k] then
    local w = function(...)
      if not isready then
        api.Fail(3)
        return
      end
      return v(...)
    end
    steam[k] = w
  end
end

return steam