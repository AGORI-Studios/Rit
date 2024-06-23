if not love.graphics then return end
function love.graphics.getSupportedBlend() -- doesn't actually check anything, just returrns true if user is on mobile or desktop
    return love.system.getSystem() == "Mobile" or love.system.getSystem() == "Desktop"
end

function love.graphics.getSupportedShader() -- Don't use shaders on non-desktops
    return love.system.getSystem() == "Desktop"
end