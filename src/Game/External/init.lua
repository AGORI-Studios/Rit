local path = ... .. "."

DiscordRPC = nil --require(path .. "DiscordRPC")
if DiscordRPC then
    DiscordRPC:initialize("785717724906913843", true)
end
