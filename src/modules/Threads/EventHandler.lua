local channel = love.thread.getChannel("eventChannel")
require("love.event")

while true do
    local events = {}
    if love.event then
        print("YEAh")
        love.event.pump()
        for name, a,b,c,d,e,f in love.event.poll() do
            if name == "quit" then
                if not love.quit or not love.quit() then
                    love.event.quit(a or 0)
                end
            end
            table.insert(events, {name, a, b, c, d, e, f})
        end
    end

    channel:push(events)
    love.timer.sleep(0.01) -- sleep for a short time to prevent 100% CPU usage
end