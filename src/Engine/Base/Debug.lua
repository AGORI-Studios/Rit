function debug.error(...)
    ---@type string
    local message = {...}
    local errorMessage = message
    if type(message) == "table" then
        errorMessage = "[ERROR] "
        for key, value in pairs(message) do
            errorMessage = errorMessage .. key .. ": " .. value .. "\n"
        end
    end
    error(errorMessage)
end

function debug.warn(...)
    ---@type string
    local message = {...}
    local errorMessage = message
    if type(message) == "table" then
        errorMessage = "[WARN] "
        for key, value in pairs(message) do
            errorMessage = errorMessage .. key .. ": " .. value .. "\n"
        end
    end
    print(errorMessage)
end

function debug.log(...)
    ---@type string
    local message = {...}
    local errorMessage = message
    if type(message) == "table" then
        errorMessage = "[LOG] "
        for key, value in pairs(message) do
            errorMessage = errorMessage .. key .. ": " .. value .. "\n"
        end
    end
    print(errorMessage)
end

function debug.info(...)
    ---@type string
    local message = {...}
    local errorMessage = message
    if type(message) == "table" then
        errorMessage = "[INFO] "
        for key, value in pairs(message) do
            errorMessage = errorMessage .. key .. ": " .. value .. "\n"
        end
    end
    print(errorMessage)
end
