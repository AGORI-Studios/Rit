local ffi = require("ffi")
local reg = debug.getregistry()
local steam = reg.Portal
local api = steam.api

--- Steam supports persistent leaderboards with automatically ordered entries.
-- These leaderboards can be used to display global and friend leaderboards in your game and on your community webpage.
-- Each Steamworks title can create up to 10,000 leaderboards, and each leaderboard can be retrieved immediately after a player's score has been inserted.
-- For each leaderboard, a player can have one entry.
-- There is no limit on the number of players per leaderboard.
-- @module board
-- @alias Board
-- @inherit Handle
local Board = {}
setmetatable(Board, { __index = reg.Handle })
reg.Board = Board

--- This is an internal function.
-- Please use @{steam.getBoard} instead.
-- @tparam string name Name of an existing leaderboard
-- @tparam[opt] function func Callback function triggered when the board is found
-- @see steam.getBoard
function Board:init(name, func)
  assert(not self.handle)
  self.handle = api.CSteamID_Invalid
  api.UserStats.FindLeaderboard(function(q)
    if self.handle == api.CSteamID_Invalid then
      local res = (q and q.m_bLeaderboardFound > 0) and 1 or 0
      if res == 1 then
        self.handle = q.m_hSteamLeaderboard
      end
      self:callback(func or "onFind", res)
    end
  end, name)
end

--- Callback triggered after the requested leaderboard is found.
-- @see steam.getBoard
function Board:onFind()
end

local sorts = { none = 0, asc = 1, desc = 2 }
local displays = { none = 0, numeric = 1, seconds = 2, milliseconds = 3 }

--- This is an internal function.
-- Please use @{steam.newBoard} instead.
-- @tparam string name Leaderboard name
-- @tparam[opt="desc"] string sort Sorting method: "asc" or "desc"
-- @tparam[opt="numeric"] string display Display style: "none", "numeric", "seconds" or "milliseconds"
-- @tparam[opt] function func Callback function triggered when the board is created
-- @see steam.newBoard
function Board:create(name, sort, display, func)
  assert(not self.handle)
  self.handle = api.CSteamID_Invalid
  sort = sorts[sort or "desc"]
  display = displays[display or "numeric"]
  assert(sort and display)
  api.UserStats.FindOrCreateLeaderboard(function(q)
    if self.handle == api.CSteamID_Invalid then
      local res = (q and q.m_bLeaderboardFound > 0) and 1 or 0
      if res == 1 then
        self.handle = q.m_hSteamLeaderboard
      end
      self:callback(func or "onCreate", res)
    end
  end, name, sort, display)
end

--- Callback triggered after the new leaderboard is created.
-- @see steam.newBoard
function Board:onCreate()
end

--- Invalidates the board so that any subsequent requests will fail.
function Board:destroy()
  self.handle = nil
end

--- Returns the name of the board.
-- @treturn string Board name
function Board:getName()
  local n = api.UserStats.GetLeaderboardName(self.handle)
  return (n == ffi.NULL) and "" or ffi.string(n)
end

--- Returns the total number of entries in the leaderboard.
-- @treturn number Number of entries
function Board:getEntryCount()
  return api.UserStats.GetLeaderboardEntryCount(self.handle)
end

--- Attaches an existing user-generated item (such as a replay) to the owner's leaderboard entry.
-- This is an asynchronous request that triggers the @{Board:onAttach} callback.
-- @tparam UGC ugc User-generated item
-- @tparam function func Callback function triggered when the UGC is attached
-- @see Board:onAttach
function Board:attach(ugc, func)
  api.UserStats.AttachLeaderboardUGC(function(q)
    if self.handle then
      local res = q and q.m_eResult or 0
      self:callback(func or "onAttach", res, ugc)
    end
  end, self.handle, ugc.handle)
end

--- Callback triggered after a user-generated item is attached to the leaderboard.
-- @tparam UGC ugc User-generated item
-- @see steam.newUGC
function Board:onAttach(ugc)
end

local methods = { none = 0, best = 1, latest = 2 }

--- Uploads a new entry on the leaderboard.
-- Uploading scores to Steam is rate limited to 10 uploads per 10 minutes
-- and you may only have one outstanding call to this function at a time.
-- This is an asynchronous request that triggers the @{Board:onUpload} callback.
-- @tparam number score Score to upload
-- @tparam[opt="best"] string method The upload method determines if we want to keep the best scores or the latest. Possible values: "none", "best" or "latest"
-- @tparam[opt] function func Callback function triggered when the entry is uploaded
-- @see Board:onUpload
function Board:upload(score, method, func)
  method = methods[method or "best"]
  assert(method)
  api.UserStats.UploadLeaderboardScore(function(q)
    if self.handle then
      local res = q and 1 or 0
      local changed = nil
      if q then
        changed = (q.m_bScoreChanged > 0) or (q.m_nGlobalRankPrevious ~= q.m_nGlobalRankNew)
      end
      self:callback(func or "onUpload", res, changed)
    end
  end, self.handle, method, score, nil, 0)
end

--- Callback triggered after a score is uploaded to the leaderboard.
-- @tparam boolean changed True if the the leaderboard has changed
-- @see Board:upload
function Board:onUpload(changed)
end

local entry = ffi.new("LeaderboardEntry_t")
local filters = { global = 0, user = 1, friends = 2 }

--- Downloads entries from the loaderboard based on a filter or for a specific user.
-- This is an asynchronous request that triggers the @{Board:onDownload} callback.
-- @tparam[opt="global"] value what User object or filter: "global", "user" or "friends"
-- @tparam[opt=1] number index1 Starting offset used for pagination
-- @tparam[opt] number index2 Ending offset used for pagination
-- @tparam[opt] function func Callback function triggered when the entries are downloaded
-- @see Board:onDownload
function Board:download(what, i, j, func)
  local filter = filters[what or "global"] or 0
  assert(filter)
  
  local fetch = function(q)
    if self.handle then
      local res = q and 1 or 0
      local list, count
      if q then
        count = q.m_cEntryCount
        if filter ~= 2 then
          count = api.UserStats.GetLeaderboardEntryCount(self.handle)
        end
        if (filter == 0) or (filter == 1) or not (i and j) then
          i, j = 1, q.m_cEntryCount
        end
        list = {}
        for k = i, j do
          if api.UserStats.GetDownloadedLeaderboardEntry(q.m_hSteamLeaderboardEntries, k - 1, entry, nil, 0) then
            local v = {}
            v.user = steam.getUser(entry.m_steamIDUser.m_steamid.m_unAll64Bits)
            v.rank = entry.m_nGlobalRank
            v.score = entry.m_nScore
            if entry.m_hUGC ~= api.UGCHandle_Invalid then
              v.ugc = steam.getUGC(entry.m_hUGC)
            end
            table.insert(list, v)
          end
        end
      end
      self:callback(func or "onDownload", res, list, count)
    end
  end
  
  if type(what) == "table" then
    local array = ffi.new("CSteamID[?]", #what)
    for k, v in ipairs(what) do
      array[k - 1] = v.handle
    end
    return api.UserStats.DownloadLeaderboardEntriesForUsers(fetch, self.handle, array, #what)
  else
    return api.UserStats.DownloadLeaderboardEntries(fetch, self.handle, filter, i, j)
  end
end

--- Callback triggered after entries are downloaded from the leaderboard.
-- @tparam table entries Table of leaderboard entries
-- @tparam number count Total number of entries
-- @see Board:download
function Board:onDownload(entries, count)
end