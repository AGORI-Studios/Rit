love.format = love.format or {}

function love.format.commaSeperateNumbers(number)
    local form = tostring(number)
    while true do
        form, k = string.gsub(form, "^(-?%d+)(%d%d%d)", "%1,%2")
        if k == 0 then break end
    end

    return form
end