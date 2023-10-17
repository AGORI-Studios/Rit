local util = {}

function math.round(num, numDecimalPlaces)
    local mult = 10^(numDecimalPlaces or 0)
    return math.floor(num * mult + 0.5) / mult
end

function string.split(self, sep)
    local sep, fields = sep or ":", {}
    local pattern = string.format("([^%s]+)", sep)
    self:gsub(pattern, function(c) fields[#fields+1] = c end)
    return fields
end

function string.trim(self)
    return self:gsub("^%s*(.-)%s*$", "%1")
end

function Try(f, catch_f)
    local status, exception = pcall(f)
    if not status then
        catch_f(exception)
    end
end

function love.system.getProcessorArchitecture()
    if jit then
        if jit.arch == "x86" then
            return "32"
        elseif jit.arch == "x64" then
            return "64"
        end
    else
        return "32"
    end
end

return util