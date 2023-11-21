local ffi = require("ffi")
local path = (...):match("(.-)[^%.]+$")
local callbacks = require(path.."callbacks")

local api = {}

local interfaces =
{
  Apps = "STEAMAPPS_INTERFACE_VERSION008",
  AppList = "STEAMAPPLIST_INTERFACE_VERSION001",
  --AppTicket = "STEAMAPPTICKET_INTERFACE_VERSION001",
  --Client = "SteamClient020",
  Controller = "SteamController007",
  --GameCoordinator = "SteamGameCoordinator001",
  --GameSearch = nil,
  --GameServer = "SteamGameServer013",
  --GameServerStats = "SteamGameServerStats001",
  HTMLSurface = "STEAMHTMLSURFACE_INTERFACE_VERSION_005",
  HTTP = "STEAMHTTP_INTERFACE_VERSION003",
  Input = "SteamInput002",
  Inventory = "STEAMINVENTORY_INTERFACE_V003",
  Friends = "SteamFriends017",
  Matchmaking = "SteamMatchMaking009",
  MatchmakingServers = "SteamMatchMakingServers002",
  Music = "STEAMMUSIC_INTERFACE_VERSION001",
  MusicRemote = "STEAMMUSICREMOTE_INTERFACE_VERSION001",
  Networking = "SteamNetworking006",
  --NetworkingSockets = "SteamNetworkingSockets009",
  ParentalSettings = "STEAMPARENTALSETTINGS_INTERFACE_VERSION001",
  Parties = "SteamParties002",
  RemotePlay = "STEAMREMOTEPLAY_INTERFACE_VERSION001",
  RemoteStorage = "STEAMREMOTESTORAGE_INTERFACE_VERSION014",
  Screenshots = "STEAMSCREENSHOTS_INTERFACE_VERSION003",
  UGC = "STEAMUGC_INTERFACE_VERSION015",
  User = "SteamUser021",
  UserStats = "STEAMUSERSTATS_INTERFACE_VERSION012",
  Utils = "SteamUtils010",
  Video = "STEAMVIDEO_INTERFACE_V002",
}

function api.Init()
  if not api.lib then
    api.lib = require(path.."flat")
    
    api.CSteamID_Invalid = 0
    api.UGCHandle_Invalid = 0xffffffffffffffffULL

    -- include the SteamAPI_ prefix
    setmetatable(api, { __index = function(t, k)
      local raw = rawget(t, k)
      if raw == nil then
        raw = api.lib["SteamAPI_"..k]
        rawset(t, k, raw)
      end
      return raw
    end })
  end
  
  if not api.lib.SteamAPI_Init() then
    api.Fail(3)
    return false
  end
  
  local function ISteam(prefix, inst)
    local q = {}
    setmetatable(q, { __index = function(t, k)
      local raw = rawget(t, k)
      if raw == nil then
        local j = "SteamAPI_ISteam"..prefix.."_"..k
        local e = callbacks[j]
        local f = api.lib[j]
        raw = function(func, ...)
          local res
          if e and type(func) == "function" then
            -- register callbacks per result
            res = f(inst, ...)
            --assert(ffi.istype("SteamAPICall_t", res))
            api.Register(func, e, res)
          elseif func ~= nil then
            res = f(inst, func, ...)
          else
            res = f(inst, ...)
          end
          return res
        end
        -- cache functions
        rawset(t, k, raw)
      end
      return raw
    end })
    return q
  end
  
  --local user = api.GetHSteamUser()
  local pipe = api.GetHSteamPipe()
  local client = api.lib.SteamInternal_CreateInterface("SteamClient020")
  local utils = api.lib.SteamAPI_ISteamClient_GetISteamUtils(client, pipe, "SteamUtils009")
  api.Client = ISteam("Client", client)
  api.Utils = ISteam("Utils", utils)
  -- intefaces
  local user = api.lib.SteamAPI_GetHSteamUser()
  for prefix, ver in pairs(interfaces) do
    if not rawget(api, prefix) then
      -- C interface
      local func = api.lib["SteamAPI_ISteamClient_GetISteam"..prefix]
      local inst = func(client, user, pipe, ver)
      assert(inst and inst ~= 0, ver)
      -- Lua-friendly interface
      api[prefix] = ISteam(prefix, inst)
    end
  end
  -- networking sockets
  --local socks = api.lib.SteamAPI_SteamNetworkingSockets_v009()
  --api.NetworkingSockets = ISteam("NetworkingSockets", socks)

  require(path.."handle")
  require(path.."user")
  require(path.."ugc")
  require(path.."board")
  require(path.."clan")
  require(path.."socket")
  require(path.."lobby")

  local ucall = {}
  local utype = {}
  function api.Register(func, event, res)
    ucall[res] = func
    utype[res] = event
  end
  
  function api.Request(url, opt, func)
    if type(opt) == "function" then
      func = opt
      opt = nil
    end
    local method = opt and 3 or 1
    local req = api.HTTP.CreateHTTPRequest(method, url)
    if req == 0 then
      return false
    end
    if type(opt) == "string" then
      local uint8 = ffi.new("uint8[?]", #opt)
      ffi.copy(uint8, opt)
      if not api.HTTP.SetHTTPRequestRawPostBody(req, "application/x-www-form-urlencoded", uint8, #opt) then
        return false
      end
    end
    if url:match("^https://(.)") then
      api.HTTP.SetHTTPRequestRequiresVerifiedCertificate(req, true)
    end
    local call = ffi.new("SteamAPICall_t[1]")
    if api.HTTP.SendHTTPRequest(req, call) then
      api.Register(function(struct)
        local body
        local n = struct.m_unBodySize
        if n > 0 then
          local buffer = ffi.new("uint8[?]", n)
          api.HTTP.GetHTTPResponseBodyData(req, buffer, n)
          body = ffi.string(buffer, n)
        end
        func(struct.m_bRequestSuccessful, body, struct.m_eStatusCode)
        api.HTTP.ReleaseHTTPRequest(req)
      end, "HTTPRequestCompleted_t", call[0])
      return true
    end
    return false
  end

  -- process callbacks
  local failed = ffi.new("bool[1]")
  function api.Update()
    for res, func in pairs(ucall) do
      if api.Utils.IsAPICallCompleted(res, failed) then
        if failed[0] then
          local c = api.Utils.GetAPICallFailureReason(res)
          api.Fail(c)
        end
        local struct = ffi.new(utype[res])
        local ssize = ffi.sizeof(struct)
        local code = struct.k_iCallback
        if not api.Utils.GetAPICallResult(res, struct, ssize, code, failed) then
          struct = nil
        end
        ucall[res] = nil
        utype[res] = nil
        func(struct)
      end
    end
  end

  return true
end

function api.Shutdown()
  for k, v in pairs(api) do
    if type(v) == "table" then
      api[k] = nil
    end
  end
  if api.lib then
    api.lib.SteamAPI_Shutdown()
    api.lib = nil
  end
end

local errors = require(path.."errors")
function api.Fail(code)
  local msg = errors[code or 0]
  print(msg)
  return msg
end
  
return api