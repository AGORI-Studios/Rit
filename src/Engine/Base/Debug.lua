function debug.error(...)
    local message = {...}
    local errorMessage = ""
    if type(message) == "table" then
        errorMessage = "[ERROR] "
        for key, value in pairs(message) do
            errorMessage = errorMessage .. key .. ": " .. value .. "\n"
        end
    end
    error(errorMessage)
end

function debug.warn(...)
    local message = {...}
    local errorMessage = ""
    if type(message) == "table" then
        errorMessage = "[WARN] "
        for key, value in pairs(message) do
            errorMessage = errorMessage .. key .. ": " .. value .. "\n"
        end
    end
    print(errorMessage)
end

function debug.log(...)
    local message = {...}
    local errorMessage = ""
    if type(message) == "table" then
        errorMessage = "[LOG] "
        for key, value in pairs(message) do
            errorMessage = errorMessage .. key .. ": " .. value .. "\n"
        end
    end
    print(errorMessage)
end

function debug.info(...)
    local message = {...}
    local errorMessage = ""
    if type(message) == "table" then
        errorMessage = "[INFO] "
        for key, value in pairs(message) do
            errorMessage = errorMessage .. key .. ": " .. value .. "\n"
        end
    end
    print(errorMessage)
end
