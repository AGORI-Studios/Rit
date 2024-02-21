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

--@name class.new
--@description Creates a new instance of the class
--@param ... any
--@return table
function class:new(...) end

--@name class.extend
--@description Creates a new class that extends the current class
--@return table
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

--@name class.implement
--@description Implements a class into the current class
--@param ... table
--@return nil
function class:implement(...) 
    for _, cls in pairs({...}) do
        for k, v in pairs(cls) do
            if self[k] == nil and type(v) == "function" then
                self[k] = v
            end
        end
    end
    return nil
end

--@name class.isInstanceOf
--@description Checks if the current class is an instance of the given class
--@param class table
--@return boolean
function class:isInstanceOf(cls)
    local m = getmetatable(self)
    while m do
        if m == cls then return true end
        m = m.super
    end
    return false
end

--@name class.__tostring
--@description Returns the class ID
--@return string
function class:__tostring()
  return self.__ID
end

--@name class.__call
--@description Creates a new instance of the class
--@param ... any
--@return table
function class:__call(...)
  local inst = setmetatable({}, self)
  inst:new(...)
  return inst
end

return class