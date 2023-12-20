--[[ local env = require("lib.env")

love.encrypt = {}

love.encrypt.key = env.parse(".env").key

function love.encrypt.encode(str)
    local chars = string.splitAllCharacters(str)
    local encoded = ""


end

function love.encrypt.decode(str)
    
end
 ]]