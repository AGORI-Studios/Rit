local path = (... .. "/"):gsub("%.", "/")

LoadSong = love.thread.newThread(path .. "LoadSong.lua")
