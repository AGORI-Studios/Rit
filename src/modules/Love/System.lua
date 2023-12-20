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

function love.system.getOS()
    if jit then
        if jit.os == "Windows" then
            return "Windows"
        elseif jit.os == "Linux" then
            return "Linux"
        elseif jit.os == "OSX" then
            return "OSX"
        elseif jit.os == "BSD" then
            return "BSD"
        elseif jit.os == "POSIX" then
            return "POSIX"
        end
    else
        return "Unknown"
    end
end
