local reg = debug.getregistry()
local steam = reg.Portal
local api = steam.api
local ffi = require("ffi")

--- Base class for all Steamworks objects.
-- @module handle
-- @alias Handle
local Handle = {}
reg.Handle = Handle

local metas = {}

--- This is an internal function.
function Handle:new()
  assert(self ~= nil and self ~= Handle)
  local mt = metas[self]
  if not mt then
    mt = { __index = self, __eq = function(a, b)
      if getmetatable(a) ~= getmetatable(b) then
        return false
      end
      return a:getId() == b:getId()
    end }
    metas[self] = mt
  end
  return setmetatable({}, mt)
end

--- This is an internal function.
function Handle:destroy()
  self.handle = nil
end

--- Returns the unique Steam ID as a string.
-- @treturn string Steam ID
function Handle:getId()
  local handle = self.handle
  if handle then
    if ffi.istype("CSteamID", handle) then
      handle = handle.m_steamid.m_unAll64Bits
    end
    local id = tostring(handle)
    return id:sub(1, -4)
  end
end

--- This is an internal function.
-- @param handle Steam ID
function Handle:setId(handle)
  if ffi.istype("CSteamID", handle) then
    handle = handle.m_steamid.m_unAll64Bits
  end
  self.handle = handle
end

--- This is an internal function.
-- @tparam value func Name or function
-- @tparam number result Result status
-- @tparam value ... Variable arguments
-- @see Handle.onError
function Handle:callback(func, res, ...)
  local args = { ... }
  if res ~= 1 then
    local msg = api.Fail(res)
    if type(func) == "string" then
      func = "onFail"
      args = { msg }
    end
  end
  if type(func) == "string" then
    local f = self[func]
    if f then
      f(self, unpack(args))
    end
  else
    func(res == 1, unpack(args))
  end
end

--- This callback is triggered when any requests fails.
-- @tparam string message Error message
function Handle:onError(message)
end