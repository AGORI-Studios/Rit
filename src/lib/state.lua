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

local state = {}
state.__index = state
local current = nil -- Current state
local last = nil -- Last state
local substate = nil -- Current substate
local function nop() end -- Called when there is no function to call from the current state

local function switch(newstate, ...) -- (local) Switches to a new state/substate, returns the new state
    if current and current.exit then current:exit() end
    last = current
    current = newstate
    if current.enter then current:enter(...) end
    return current
end

function state.switch(newstate, ...) -- Switches to a new state, returns the new state
    assert(newstate, "Called state.switch with no state")
    assert(type(newstate) == "table", "Called state.switch with invalid state")
    switch(newstate, ...)
    return current
end

function state.current() return current end -- Returns the current state
function state.last() return last end -- Returns the last state
function state.killSubstate(...) -- Kills the current substate and calls current:substateReturn, returns nothing
    if substate and substate.exit then substate:exit() end
    substate = nil
    current:substateReturn(...)
    return
end 
function state.currentSubstate() return substate end -- Returns the current substate

function state.returnToLast() -- Returns to the last state, returns the new state
    assert(last, "Called state.return with no last state")
    switch(last)
    return current
end

function state.substate(newstate, ...) -- Switches to a new substate, returns the new substate
    assert(newstate, "Called state.substate with no state")
    assert(type(newstate) == "table", "Called state.substate with invalid state") -- Make sure the state is valid
    substate = newstate
    if substate.enter then substate:enter(...) end -- Call the enter function if it exists
    return substate
end

function new() -- Creates a new state, returns a table, simply used for nicer syntax
    return setmetatable({}, {})
end

setmetatable(state, { -- Allows you to call state functions as if they were global
    __index = function(_, func)
        --return function(...) return (current[func] or nop)(...) end
        -- call substate and current state (substate calls above current state)
        return function(...)
            local args = {...} -- Allows us to pass arguments to the function
            local function f() -- Allows us to call both current and substate
                if current and current[func] then current[func](current, unpack(args)) end
                if substate and substate[func] then substate[func](substate, unpack(args)) end
            end
            return f()
        end
    end,

    -- when state is called as a function, return new, just makes the state definition look nicer
    __call = function() return new() end
})

return state
