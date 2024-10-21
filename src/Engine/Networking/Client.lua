local messageChannel = love.thread.getChannel("thread.networking.message")
local controlChannel = love.thread.getChannel("thread.networking.control")
local publishChannel = love.thread.getChannel("thread.networking.publish")
local subscribeChannel = love.thread.getChannel("thread.networking.subscribe")

local Client = {}

function Client:message(message)
    messageChannel:push(message)
end

function Client:control(message)
    controlChannel:push(message)
end

function Client:publish(message)
    publishChannel:push(message)
end

function Client:subscribe(message)
    subscribeChannel:push(message)
end

function Client:getMessage()
    if messageChannel:peek() then
        return messageChannel:pop()
    end
end

return Client