local env = {
    _NAME = "env",
    _VERSION = "1.0.0",
    _DESCRIPTION = "A simple env parser",
    _CREATOR = "GuglioIsStupid",
    _LICENSE = [[
        MIT LICENSE
    ]]
}

function env.read(env)
    local str 

    if love.filesystem.getInfo(env) then
        str = love.filesystem.read(env)
    else
        str = env
    end

    if not str then str = "key=default" end -- The default key.

end