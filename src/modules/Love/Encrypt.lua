love.encrypt = {}

love.encrypt.key = env.read(".env").key

function love.encrypt.encode(str)
    local chars = string.splitAllCharacters(str)
    local encoded = ""


end

function love.encrypt.decode(str)
    
end
local ss = love.encrypt.encode("Hello, World!")
print(ss, love.encrypt.decode(ss))