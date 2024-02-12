local ffi = require("ffi")

-- ffi sdl2

ffi.cdef [[
    typedef struct SDL_Window SDL_Window;
    SDL_Window* SDL_GL_GetCurrentWindow(void);
    void* SDL_GL_GetCurrentContext(void);
    
    int SDL_SetWindowOpacity(SDL_Window* window, float opacity);
    void SDL_SetWindowSize(SDL_Window* window, int w, int h);
]]
love.window._sdl = jit.os == "Windows" and ffi.load("SDL2") or ffi.C
love.window._handle = love.window._sdl.SDL_GL_GetCurrentWindow()

function love.window.setWindowOpacity(opacity)
    love.window._sdl.SDL_SetWindowOpacity(love.window._handle, opacity)
end

function love.window.setWindowSize(w, h)
    love.window._sdl.SDL_SetWindowSize(love.window._handle, w, h)
end