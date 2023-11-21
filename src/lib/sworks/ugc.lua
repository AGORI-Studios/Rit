local ffi = require("ffi")
local reg = debug.getregistry()
local steam = reg.Portal
local api = steam.api

--- The Steam Workshop is designed as a place for your fans and community members to participate in the creation of content for your game.
-- The form of this creation by community members can vary depending on the nature of the game and what kind of control you wish to have over the content in your game.
-- @module ugc
-- @alias UGC
-- @inherit Handle
local UGC = {}
setmetatable(UGC, { __index = reg.Handle })
reg.UGC = UGC

--- This is an internal function.
-- Please use @{steam.getUGC} instead.
-- @tparam string id ID of an existing user-generated item 
-- @param[opt] appid AppID if different from the base game
-- @see steam.getUGC
function UGC:init(id, appid)
  assert(not self.handle)
  self.handle = id
  self.appid = appid or api.Utils.GetAppID()
end

local kinds =
{
  community = 0,
  micro = 1,
  collection = 2,
  art = 3,
  video = 4,
  screenshot = 5,
  game = 6,
  software = 7,
  concept = 8,
  webguide = 9,
  guide = 10,
  merch = 11,
  binding = 12,
  accessinvite = 13,
  steamvideo = 14,
  managed = 15,
}
--- This is an internal function.
-- Please use @{steam.newUGC} instead.
-- @tparam[opt="community"] string kind Type of object: "community", "micro", "collection", "art", "video", "screenshot", "game", "software", "concept", "webguide", "guide", "merch", "binding", "accessinvite", "steamvideo" or "managed".
-- @param[opt] appid AppID if different from the base game
-- @tparam[opt] function func Callback function triggered when the item is created
-- @see steam.newUGC
function UGC:create(kind, appid, func)
  kind = kinds[kind or "community"]
  appid = appid or api.Utils.GetAppID()
  assert(kind and not self.handle)
  return api.UGC.CreateItem(function(q)
    local res = q and q.m_eResult or 0
    if res == 1 then
      self.handle = q.m_nPublishedFileId
      --self.owner = api.User.GetSteamID()
      self.appid = appid
    end
    self:callback(func or "onCreate", res)
  end, appid, kind)
end

--- Callback triggered when the user-generated item is created.
-- @see steam.newUGC
function UGC:onCreate()
end

--- Subscribe to a workshop item. This will also downloaded and install the item as soon as possible.
-- This is an asynchronous request so please use @{UGC:onSubscribe} or provide a callback function.
-- @tparam[opt] function func Callback function triggered after subscribing
-- @see UGC:onSubscribe
-- @see steam.getSubscribedUGC
function UGC:subscribe(func)
  return api.UGC.SubscribeItem(function(q)
    if self.handle then
      local res = q and q.m_eResult or 0
      self:callback(func or "onSubscribe", res)
    end
  end, self.handle)
end

--- Callback triggered after subscribing to the user-generated item.
-- @see UGC:subscribe
function UGC:onSubscribe()
end

--- Requests a download or update for a workshop item.
-- If the user is not subscribed to the item,
-- the workshop item will be downloaded and cached temporarily.
-- @treturn boolean True if the download was started
-- @see UGC:getDownloadInfo
function UGC:download()
  return api.UGC.DownloadItem(self.handle, true)
end

local download = ffi.new("uint64[1]")
local total = ffi.new("uint64[1]")
--- Get info about the pending download of a workshop item.
-- @treturn number Downloaded bytes
-- @treturn number Total bytes
-- @see UGC:download
function UGC:getDownloadInfo()
  if api.UGC.GetItemDownloadInfo(self.handle, download, total) then
    return tonumber(download[0]), tonumber(total[0])
  end
end

--- Checks if this workshop item is downloaded and installed on the client.
-- @treturn boolean True if installed
-- @see UGC:getInstallInfo
function UGC:isInstalled()
  return api.UGC.GetItemState(self.handle) == 4
end

local size = ffi.new("uint64[1]")
local dest = ffi.new("char[512]")
local stamp = ffi.new("uint32[1]")
--- Gets info about currently installed content on the disc for workshop items.
-- Calling this sets the "used" flag on the workshop item for the current player and adds it to their "used or played" list.
-- @treturn string Directory path to the installed content
-- @treturn number Size in bytes
-- @treturn number Timestamp of when it was installed
-- @see UGC:isInstalled
function UGC:getInstallInfo()
  if self:isInstalled() then
    if api.UGC.GetItemInstallInfo(self.handle, size, dest, 512, stamp) then
      local path = ffi.string(dest)
      path = path:gsub("\\", "/")
      return path, tonumber(size[0]), tonumber(stamp[0])
    end
  end
end

local metadata = ffi.new("char[256]")
local url = ffi.new("char[512]")
local key = ffi.new("char[256]")
local value = ffi.new("char[256]")

local details = ffi.new("SteamUGCDetails_t[1]")

--- This is an internal function.
-- Please use @{UGC:fetch} instead.
-- @tparam cdata query Query object
-- @tparam number index Index number
-- @treturn table Metadata table
function UGC:getDetails(query, index)
  if not api.UGC.GetQueryUGCResult(query, index, details) then
    return
  end
  local d = details[0]
  local data = {}
  data.owner = steam.getUser(d.m_ulSteamIDOwner)
  data.created = d.m_rtimeCreated
  data.updated = d.m_rtimeUpdated
  data.upvotes = d.m_unVotesUp
  data.downvotes = d.m_unVotesDown
  data.title = ffi.string(d.m_rgchTitle)
  data.desc = ffi.string(d.m_rgchDescription)
  data.visible = d.m_eVisibility < 2
  data.accepted = d.m_bAcceptedForUse
  if d.m_rgchTags ~= ffi.NULL then
    data.tags = {}
    local s = ffi.string(d.m_rgchTags)..","
    for tag in s:gmatch("([^,]+)") do
      if tag ~= "" then
        table.insert(data.tags, tag)
      end
    end
    local n = api.UGC.GetQueryUGCNumKeyValueTags(query, index)
    for i = 1, n do
      if api.UGC.GetQueryUGCKeyValueTag(query, index, i - 1, key, 256, value, 256) then
        if key ~= ffi.null and value ~= ffi.null then
          data.tags[ffi.string(key)] = ffi.string(value)
        end
      end
    end
  end
  --data.preview = ffi.string(d.m_hPreviewFile)
  if api.UGC.GetQueryUGCPreviewURL(query, index, url, 512) then
    if url ~= ffi.NULL then
      data.preview = ffi.string(url)
    end
  end
  if api.UGC.GetQueryUGCMetadata(query, 0, metadata, 256) then
    if metadata ~= ffi.NULL then
      data.metadata = ffi.string(metadata)
    end
  end
  return data
end

local array = ffi.new("PublishedFileId_t[1]")
--- Fetches metadata about a user-generated item.
-- This is an asynchronous request so please use @{UGC:onFetch} or provide a callback function to receive the results.
-- @tparam[opt] function func Callback triggered after fetching the item's metadata
-- @see UGC:onFetch
function UGC:fetch(func)
  array[0] = self.handle
  local query = api.UGC.CreateQueryUGCDetailsRequest(array, 1)
  return api.UGC.SendQueryUGCRequest(function(q)
    if self.handle then
      local res = q and q.m_eResult or 0
      local data
      if res == 1 then
        data = self:getDetails(query, 0)
      end
      api.UGC.ReleaseQueryUGCRequest(query)
      self:callback(func or "onFetch", res, data)
    end
  end, query)
end

--- Callback triggered after fetching the item's metadata.
-- @tparam table data Table of fetched metadata
-- @see UGC:fetch
function UGC:onFetch(data)
end

--- Uploads the changes made to an item to the Steam Workshop.
-- @tparam string path Directory path that will be uploaded
-- @tparam table data Metadata associated with the item
-- @tparam[opt] string note Update note
-- @tparam[opt] function func Callback triggered after updating the item
-- @see UGC:onUpdate
function UGC:update(path, data, note, func)
  assert(self.handle)
  local appid = self.appid or api.Utils.GetAppID()
  local query = api.UGC.StartItemUpdate(appid, self.handle)
  if data.title then
    api.UGC.SetItemTitle(query, data.title)
  end
  if data.desc then
    api.UGC.SetItemDescription(query, data.desc)
  end
  if data.metadata then
    api.UGC.SetItemMetadata(query, data.metadata)
  end
  if data.preview then
    api.UGC.SetItemPreview(query, data.preview)
  end
  if data.visible ~= nil then
    api.UGC.SetItemVisibility(query, data.visible and 0 or 2)
  end
  --[[
  if data.lang then
    api.UGC.SetItemUpdateLanguage(query, data.lang)
  end
  ]]
  if type(data.tags) == "table" then
    -- key-value tags
    for k, v in pairs(data.tags) do
      if type(k) == "string" then
        api.UGC.AddItemKeyValueTag(query, k, v)
      end
    end
    -- list of tags
    if #data.tags > 0 then
      local tags = ffi.new("const char*[?]", #data.tags)
      for i, v in ipairs(data.tags) do
        tags[i - 1] = v
      end
      local sa = ffi.new("SteamParamStringArray_t")
      sa.m_ppStrings = tags
      sa.m_nNumStrings = #data.tags
      api.UGC.SetItemTags(query, sa)
    end
  end
  if path then
    api.UGC.SetItemContent(query, path)
  end
  api.UGC.SubmitItemUpdate(function(q)
    if self.handle then
      local res = q and q.m_eResult or 0
      local agree = nil
      if res == 1 then
        agree = q.m_bUserNeedsToAcceptWorkshopLegalAgreement
      end
      self:callback(func or "onUpdate", res, agree)
    end
  end, query, note)
end

--- Callback triggered after updating the item.
-- @tparam boolean agree True if the user needs to accept the workshop legal agreement
-- @see UGC:update
function UGC:onUpdate(agree)
end

--- Deletes the item without prompting the user.
-- @tparam[opt] function func Callback function triggered after deleting the item
-- @see UGC:onDelete
function UGC:delete(func)
  if not self.handle then
    return
  end
  api.UGC.DeleteItem(function(q)
    if self.handle then
      local res = q and q.m_eResult or 0
      if res == 1 then
        self.handle = nil
        --self.owner = nil
      end
      self:callback(func or "onDelete", res)
    end
  end, self.handle)
end

--- Callback triggered after deleting the item.
-- @see UGC:delete
function UGC:onDelete()
end

--- Start tracking playtime on a set of workshop items.
-- When your app shuts down, playtime tracking will automatically stop.
-- @tparam[opt] function func Callback function triggered when starting to track time
-- @see UGC:stopTracking
-- @see UGC:onStartTracking
function UGC:startTracking(func)
  array[0] = self.handle
  api.UGC.StartPlaytimeTracking(function(q)
    if self.handle then
      local res = q and q.m_eResult or 0
      self:callback(func or "onStartTracking", res)
    end
  end, array, 1)
end

--- Stops tracking playtime on a set of workshop items.
-- @tparam[opt] function func Callback function triggered when stopping to track time
-- @see UGC:startTracking
-- @see UGC:onStopTracking
function UGC:stopTracking(func)
  array[0] = self.handle
  return api.UGC.StopPlaytimeTracking(function(q)
    if self.handle then
      local res = q and q.m_eResult or 0
      self:callback(func or "onStopTracking", res)
    end
  end, array, 1)
end

--- Callback triggered when starting to track the user-generated item.
-- @see UGC:startTracking
function UGC:onStartTracking()
end

--- Callback triggered when stopping to track the user-generated item.
-- @see UGC:stopTracking
function UGC:onStopTracking()
end