---@diagnostic disable: need-check-nil
local socket = require("socket")
local json = require("Engine.Format.Json")
require("love.timer")

local messageChannel = love.thread.getChannel("thread.networking.message")
local controlChannel = love.thread.getChannel("thread.networking.control")
local publishChannel = love.thread.getChannel("thread.networking.publish")
--local subscribeChannel = love.thread.getChannel("thread.networking.subscribe")

Client = {}
Client.__index = Client

function Client.new(params)
    params = params or {}
    if (not params.server or not params.port) then
        print("Client requires server and port to be specified")
        return nil
    end

    local self = setmetatable({}, Client)
    self.server = params.server
    self.port = params.port
    self.buffer = ''
    return self
end

function Client:subscribe(params)
    self.channel = params.channel or 'test-channel'
    self.callback = params.callback or function() end
    local error_message
    self.sock, error_message = socket.connect(self.server, self.port)

    if not self.sock then
        print("Client connection error: " .. error_message)
        messageChannel:push("connection_error")
        return false
    end

    print("Client connected to " .. self.server .. ":" .. self.port)

    self.sock:setoption('tcp-nodelay', true)
    self.sock:settimeout(0)
    local _, output = socket.select(nil, { self.sock }, 3)

    for _, v in ipairs(output) do
        v:send("__SUBSCRIBE__" .. self.channel .. "__ENDSUBSCRIBE__")
    end

    return true
end

function Client:publish(message)
    if not self.sock then
        print("Client: Attempt to publish without valid subscription (bad socket)")
        return false
    end

    local send_result, num_bytes = self.sock:send("__JSON__START__" .. json.encode(message.message) .. "__JSON__END__")

    if not send_result then
        print("Client publish error: " .. message .. ' sent ' .. num_bytes .. ' bytes')
        return false
    end

    return true
end

function Client:enterFrame()
    local input = socket.select({ self.sock }, nil, 0)

    for _, v in ipairs(input) do
        local got_something_new = false

        while true do
            local skt, e, p = v:receive()

            if skt then
                self.buffer = self.buffer .. skt
                got_something_new = true
            end
            if p then
                self.buffer = self.buffer .. p
                got_something_new = true
            end
            if not skt or e then
                break
            end
        end

        -- Check if a message is present in the buffer
        while got_something_new do
            local start = string.find(self.buffer, '__JSON__START__')
            local finish = string.find(self.buffer, '__JSON__END__')

            if start and finish then
                local message = string.sub(self.buffer, start + 15, finish - 1)
                self.buffer = string.sub(self.buffer, 1, start - 1) .. string.sub(self.buffer, finish + 13)
                local data = json.decode(message)
                -- Send the message to the main thread
                messageChannel:push(data)
            else
                break
            end
        end
    end
end

setmetatable(Client, {
    __call = function(cls, ...)
        return cls.new(...)
    end
})

-- Maybe I should put the client class in a separate file?
local client = Client({ server = "server.rit.agori.dev", port = 1337 })

client:subscribe({
    channel = "test-channel"
});

while true do
    local controlMessage = controlChannel:pop()
    if controlMessage == "quit" then
        client:unsubscribe()
        break
    end

    local publishMessage = publishChannel:pop()
    if publishMessage then
        client:publish(publishMessage)
    end

    client:enterFrame()

    love.timer.sleep(0.01)
end