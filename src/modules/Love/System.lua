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