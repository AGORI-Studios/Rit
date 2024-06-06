local desktops = {
    OSNames = {
        "Windows", 
        "Linux", 
        "OS X"
    },
    Name = "Desktop"
}

local mobileDevices = {
    OSNames = {
        "Android", 
        "iOS"
    },
    Name = "Mobile"
}

local gameSystems = {
    OSNames = {
        "NX",
        -- The below ones are just to be funny lol, Rit won't be ported to these (Except vita was already made by a crazy dude)
        -- Well,, If I were to use LOVE-WrapLua, I could port it to these, but I'm not going to do that,.,., that's too much work for a joke lol
        "PSP",
        "PS3",
        "Vita"
    },
    Name = "Console"
}

function love.system.getProcessorArchitecture()
    if jit then
        if jit.arch == "x86" then
            return "32"
        elseif jit.arch == "x64" then
            return "64"
        end
    else
        return "64" -- Hoping and praying that the user has a 64-bit processor (cuz why would they not? and also cuz Rit would probably die at 32-bit)
    end
end

function love.system.getSystem()
    local os = love.system.getOS()
    for _, v in ipairs(desktops.OSNames) do
        if os == v then
            return desktops.Name
        end
    end
    for _, v in ipairs(mobileDevices.OSNames) do
        if os == v then
            return mobileDevices.Name
        end
    end
    for _, v in ipairs(gameSystems.OSNames) do
        if os == v then
            return gameSystems.Name
        end
    end

    return "Unknown System"
end
