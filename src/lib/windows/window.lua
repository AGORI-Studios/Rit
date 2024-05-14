local ffi = require("ffi")
local dwmapi = ffi.load("dwmapi")

local windowUtil = {}

ffi.cdef [[
	typedef int HRESULT;
	typedef unsigned int DWORD;
	typedef const void* PVOID;
	typedef const void* LPCVOID;
	typedef struct HWND HWND;

    HWND GetActiveWindow();

    HRESULT DwmGetWindowAttribute(HWND hwnd, DWORD dwAttribute, PVOID pvAttribute, DWORD cbAttribute);
	HRESULT DwmSetWindowAttribute(HWND hwnd, DWORD dwAttribute, LPCVOID pvAttribute, DWORD cbAttribute);
	HRESULT DwmFlush();
]]

function windowUtil.setDarkMode(bool)
    local bool = bool and 1 or 0
    local curWindow = ffi.C.GetActiveWindow()
    
    local darkMode = ffi.new("int[1]", bool)
    local size = ffi.sizeof(darkMode)

    local result = dwmapi.DwmSetWindowAttribute(curWindow, 19, darkMode, size)
    if result == 0 then
        dwmapi.DwmSetWindowAttribute(curWindow, 20, darkMode, size)
    end

    return result == 0 -- Returns true if successful
end

return windowUtil