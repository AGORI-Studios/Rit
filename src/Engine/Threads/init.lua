local path = (... .. "/"):gsub('%.', '/')

LoadAudio = love.thread.newThread(path .. "LoadAudio.lua")
