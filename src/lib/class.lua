local class = {
  _NAME = "Class",
  _VERSION = "1.0.0",
  _DESCRIPTION = "A simple class implementation",
  _CREATOR = "GuglioIsStupid",
  _LICENSE = [[
      MIT LICENSE
  ]]
}

class.__index = class

-- Recreate smth like "Table: 0x0000000000000000"
local idChars = "0123456789abcdef"

function class:new() end

function class:extend()
  local cls = {}
  for k, v in pairs(self) do
      if k:find("__") == 1 then
          cls[k] = v
      end
  end
  cls.__index = cls
  cls.super = self
  cls.__ID = "Class: 0x"
  for i = 1, 4 do
      cls.__ID = cls.__ID .. idChars:sub(math.random(1, #idChars), math.random(1, #idChars))
  end
  setmetatable(cls, self)
  return cls
end

function class:implement(...) 
  for _, cls in pairs({...}) do
      for k, v in pairs(cls) do
          if self[k] == nil and type(v) == "function" then
              self[k] = v
          end
      end
  end
end

function class:isInstanceOf(cls)
  local m = getmetatable(self)
  while m do
      if m == cls then return true end
      m = m.super
  end
  return false
end

function class:__tostring()
  return self.__ID
end

function class:__call(...)
  local inst = setmetatable({}, self)
  inst:new(...)
  return inst
end

return class