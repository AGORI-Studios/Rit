-- Short and sweet state library for LÖVE. States and substates supported! (Substate draws above the state)
-- GuglioIsStupid - 2023
-- Version: 1.0.0
--[[

The MIT License (MIT)

=====================

Copyright © 2023 GuglioIsStupid

Permission is hereby granted, free of charge, to any person obtaining a copy of this software 
and associated documentation files (the “Software”), to deal in the Software without 
restriction, including without limitation the rights to use, copy, modify, merge, publish,
distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the 
Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or 
substantial portions of the Software.

THE SOFTWARE IS PROVIDED “AS IS”, WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING 
BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND 
NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, 
DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING 
FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

]]

---@class state
local state = {}
state.__index = state
---@type any
local current = nil -- Current state
---@type any
local last = nil -- Last state
---@type any
local substate = nil -- Current substate

local function nop() end -- Called when there is no function to call from the current state

state.inSubstate = false

local function switch(newstate, ...)
    if current and current.exit then current:exit() end 
    last = current
    current = newstate
    if current.enter then current:enter(last, ...) end
    return current
end

---@name state.switch
---@description Switches to a new state, returns the new state
---@param newstate table
---@param ... any
---@return table
function state.switch(newstate, ...)
    assert(newstate, "Called state.switch with no state")
    assert(type(newstate) == "table", "Called state.switch with invalid state")
    switch(newstate, ...)
    return current
end

---@name state.current
---@description Returns the current state
---@return table
function state.current() return current end

---@name state.last
---@description Returns the last state
---@return table
function state.last() return last end

---@name state.killSubstate
---@description Kills the current substate and calls current:substateReturn, returns nothing
---@param ... any
function state.killSubstate(...)
    if substate and substate.exit then substate:exit() end
    substate = nil
    state.inSubstate = false
    if current.substateReturn then current:substateReturn(...) end
    return
end 

---@name state.currentSubstate
---@description Returns the current substate
---@return table
function state.currentSubstate() return substate end


---@name state.returnToLast
---@description Returns to the last state, returns the new state
---@return table
function state.returnToLast()
    assert(last, "Called state.return with no last state")
    switch(last)
    return current
end

---@name state.substate
---@description Switches to a new substate, returns the new substate
---@param newstate table
---@param ... any
---@return table
function state.substate(newstate, ...)
    assert(newstate, "Called state.substate with no state")
    assert(type(newstate) == "table", "Called state.substate with invalid state") 
    substate = newstate -- Set the substate
    state.inSubstate = true
    if substate.enter then substate:enter(...) end
    return substate
end

local function new()
    return setmetatable({}, {})
end

setmetatable(state, { -- Allows you to call state functions as if they were global
    __index = function(_, func)
        --return function(...) return (current[func] or nop)(...) end
        -- call substate and current state (substate calls above current state)
        return function(...)
            local args = {...} -- Allows us to pass arguments to the function
            local function f() -- Allows us to call both current and substate
                if current and current[func] then current[func](current, unpack(args)) end -- Call current state
                if substate and substate[func] then substate[func](substate, unpack(args)) end -- Call substate
            end
            return f()
        end
    end,

    -- when state is called as a function, return new, just makes the state definition look nicer
    __call = function() return new() end
})

return state
