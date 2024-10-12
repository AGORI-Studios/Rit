local ffi = require "ffi"
local DiscordRPClib = ffi.load("discord-rpc")

ffi.cdef[[
typedef struct DiscordRichPresence {
    const char* state;   /* max 128 bytes */
    const char* details; /* max 128 bytes */
    int64_t startTimestamp;
    int64_t endTimestamp;
    const char* largeImageKey;  /* max 32 bytes */
    const char* largeImageText; /* max 128 bytes */
    const char* smallImageKey;  /* max 32 bytes */
    const char* smallImageText; /* max 128 bytes */
    const char* partyId;        /* max 128 bytes */
    const char* button1_label;  /* max 128 bytes */
    const char* button1_url;    /* max 128 bytes */
    const char* button2_label;  /* max 128 bytes */
    const char* button2_url;    /* max 128 bytes */
    int partySize;
    int partyMax;
    const char* matchSecret;    /* max 128 bytes */
    const char* joinSecret;     /* max 128 bytes */
    const char* spectateSecret; /* max 128 bytes */
    int8_t instance;
} DiscordRichPresence;

typedef struct DiscordUser {
    const char* userId;
    const char* username;
    const char* discriminator;
    const char* avatar;
} DiscordUser;

typedef void (*readyPtr)(const DiscordUser* request);
typedef void (*disconnectedPtr)(int errorCode, const char* message);
typedef void (*erroredPtr)(int errorCode, const char* message);
typedef void (*joinGamePtr)(const char* joinSecret);
typedef void (*spectateGamePtr)(const char* spectateSecret);
typedef void (*joinRequestPtr)(const DiscordUser* request);

typedef struct DiscordEventHandlers {
    readyPtr ready;
    disconnectedPtr disconnected;
    erroredPtr errored;
    joinGamePtr joinGame;
    spectateGamePtr spectateGame;
    joinRequestPtr joinRequest;
} DiscordEventHandlers;

void Discord_Initialize(const char* applicationId,
                        DiscordEventHandlers* handlers,
                        int autoRegister,
                        const char* optionalSteamId);

void Discord_Shutdown(void);

void Discord_RunCallbacks(void);

void Discord_UpdatePresence(const DiscordRichPresence* presence);

void Discord_ClearPresence(void);

void Discord_Respond(const char* userid, int reply);

void Discord_UpdateHandlers(DiscordEventHandlers* handlers);
]]

local DiscordRPC = {} -- module table

-- proxy to detect garbage collection of the module
DiscordRPC.gcDummy = newproxy(true)

local function unpackDiscordUser(request)
    return ffi.string(request.userId), ffi.string(request.username),
        ffi.string(request.discriminator), ffi.string(request.avatar)
end

-- callback proxies
-- note: callbacks are not JIT compiled (= SLOW), try to avoid doing performance critical tasks in them
-- luajit.org/ext_ffi_semantics.html
local ready_proxy = ffi.cast("readyPtr", function(request)
    if DiscordRPC.ready then
        DiscordRPC.ready(unpackDiscordUser(request))
    end
end)

local disconnected_proxy = ffi.cast("disconnectedPtr", function(errorCode, message)
    if DiscordRPC.disconnected then
        DiscordRPC.disconnected(errorCode, ffi.string(message))
    end
end)

local errored_proxy = ffi.cast("erroredPtr", function(errorCode, message)
    if DiscordRPC.errored then
        DiscordRPC.errored(errorCode, ffi.string(message))
    end
end)

local joinGame_proxy = ffi.cast("joinGamePtr", function(joinSecret)
    if DiscordRPC.joinGame then
        DiscordRPC.joinGame(ffi.string(joinSecret))
    end
end)

local spectateGame_proxy = ffi.cast("spectateGamePtr", function(spectateSecret)
    if DiscordRPC.spectateGame then
        DiscordRPC.spectateGame(ffi.string(spectateSecret))
    end
end)

local joinRequest_proxy = ffi.cast("joinRequestPtr", function(request)
    if DiscordRPC.joinRequest then
        DiscordRPC.joinRequest(unpackDiscordUser(request))
    end
end)

-- helpers
local function checkArg(arg, argType, argName, func, maybeNil)
    assert(type(arg) == argType or (maybeNil and arg == nil),
        string.format("Argument \"%s\" to function \"%s\" has to be of type \"%s\"",
            argName, func, argType))
end

local function checkStrArg(arg, maxLen, argName, func, maybeNil)
    if maxLen then
        assert(type(arg) == "string" and arg:len() <= maxLen or (maybeNil and arg == nil),
            string.format("Argument \"%s\" of function \"%s\" has to be of type string with maximum length %d",
                argName, func, maxLen))
    else
        checkArg(arg, "string", argName, func, true)
    end
end

local function checkIntArg(arg, maxBits, argName, func, maybeNil)
    maxBits = math.min(maxBits or 32, 52) -- lua number (double) can only store integers < 2^53
    local maxVal = 2^(maxBits-1) -- assuming signed integers, which, for now, are the only ones in use
    assert(type(arg) == "number" and math.floor(arg) == arg
        and arg < maxVal and arg >= -maxVal
        or (maybeNil and arg == nil),
        string.format("Argument \"%s\" of function \"%s\" has to be a whole number <= %d",
            argName, func, maxVal))
end

-- function wrappers
function DiscordRPC.initialize(applicationId, autoRegister, optionalSteamId)
    local func = "DiscordRPC.Initialize"
    checkStrArg(applicationId, nil, "applicationId", func)
    checkArg(autoRegister, "boolean", "autoRegister", func)
    if optionalSteamId ~= nil then
        checkStrArg(optionalSteamId, nil, "optionalSteamId", func)
    end

    ---@class DiscordEventHandlers
    ---@diagnostic disable-next-line: assign-type-mismatch
    local eventHandlers = ffi.new("struct DiscordEventHandlers")
    eventHandlers.ready = ready_proxy
    eventHandlers.disconnected = disconnected_proxy
    eventHandlers.errored = errored_proxy
    eventHandlers.joinGame = joinGame_proxy
    eventHandlers.spectateGame = spectateGame_proxy
    eventHandlers.joinRequest = joinRequest_proxy

    DiscordRPClib.Discord_Initialize(applicationId, eventHandlers,
        autoRegister and 1 or 0, optionalSteamId)
end

function DiscordRPC.shutdown()
    DiscordRPClib.Discord_Shutdown()
end

function DiscordRPC.runCallbacks()
    DiscordRPClib.Discord_RunCallbacks()
end
-- http://luajit.org/ext_ffi_semantics.html#callback :
-- It is not allowed, to let an FFI call into a C function (runCallbacks)
-- get JIT-compiled, which in turn calls a callback, calling into Lua again (e.g. DiscordRPC.ready).
-- Usually this attempt is caught by the interpreter first and the C function
-- is blacklisted for compilation.
-- solution:
-- "Then you'll need to manually turn off JIT-compilation with jit.off() for
-- the surrounding Lua function that invokes such a message polling function."
jit.off(DiscordRPC.runCallbacks)

function DiscordRPC.updatePresence(presence)
    presence = presence or DiscordRPC.presence
    if (#presence.state or "") > 127 then
       presence.state = string.sub(presence.state, 1, 124) .. "..."
    end
    if (#presence.details or "") > 127 then
       presence.details = string.sub(presence.details, 1, 124) .. "..."
    end
    presence.button1Label = presence.button1Label or "GitHub"
    presence.button1Url = presence.button1Url or "https://github.com/AGORI-Studios/Rit"

    local func = "DiscordRPC.updatePresence"
    checkArg(presence, "table", "presence", func)

    -- -1 for string length because of 0-termination
    checkStrArg(presence.state, 127, "presence.state", func, true)
    checkStrArg(presence.details, 127, "presence.details", func, true)

    checkIntArg(presence.startTimestamp, 64, "presence.startTimestamp", func, true)
    checkIntArg(presence.endTimestamp, 64, "presence.endTimestamp", func, true)

    checkStrArg(presence.largeImageKey, 31, "presence.largeImageKey", func, true)
    checkStrArg(presence.largeImageText, 127, "presence.largeImageText", func, true)
    checkStrArg(presence.smallImageKey, 31, "presence.smallImageKey", func, true)
    checkStrArg(presence.smallImageText, 127, "presence.smallImageText", func, true)
    checkStrArg(presence.partyId, 127, "presence.partyId", func, true)

    checkStrArg(presence.button1Label, 127, "presence.button1_label", func, true)
    checkStrArg(presence.button1Url, 127, "presence.button1_url", func, true)
    checkStrArg(presence.button2Label, 127, "presence.button2_label", func, true)
    checkStrArg(presence.button2Url, 127, "presence.button2_url", func, true)

    checkIntArg(presence.partySize, 32, "presence.partySize", func, true)
    checkIntArg(presence.partyMax, 32, "presence.partyMax", func, true)

    checkStrArg(presence.matchSecret, 127, "presence.matchSecret", func, true)
    checkStrArg(presence.joinSecret, 127, "presence.joinSecret", func, true)
    checkStrArg(presence.spectateSecret, 127, "presence.spectateSecret", func, true)

    checkIntArg(presence.instance, 8, "presence.instance", func, true)

    ---@class DiscordRichPresence
    ---@diagnostic disable-next-line: assign-type-mismatch
    local cpresence = ffi.new("struct DiscordRichPresence")
    cpresence.state = presence.state
    cpresence.details = presence.details
    cpresence.startTimestamp = presence.startTimestamp or 0
    cpresence.endTimestamp = presence.endTimestamp or 0
    cpresence.largeImageKey = presence.largeImageKey
    cpresence.largeImageText = presence.largeImageText
    cpresence.smallImageKey = presence.smallImageKey
    cpresence.smallImageText = presence.smallImageText
    cpresence.button1_label = presence.button1Label
    cpresence.button1_url = presence.button1Url
    cpresence.button2_label = presence.button2Label
    cpresence.button2_url = presence.button2Url
    cpresence.partyId = presence.partyId
    cpresence.partySize = presence.partySize or 0
    cpresence.partyMax = presence.partyMax or 0
    cpresence.matchSecret = presence.matchSecret
    cpresence.joinSecret = presence.joinSecret
    cpresence.spectateSecret = presence.spectateSecret
    cpresence.instance = presence.instance or 0

    DiscordRPClib.Discord_UpdatePresence(cpresence)
end

function DiscordRPC.clearPresence()
    DiscordRPClib.Discord_ClearPresence()
end

local replyMap = {
    no = 0,
    yes = 1,
    ignore = 2
}

-- maybe let reply take ints too (0, 1, 2) and add constants to the module
function DiscordRPC.respond(userId, reply)
    checkStrArg(userId, nil, "userId", "DiscordRPC.respond")
    assert(replyMap[reply], "Argument 'reply' to DiscordRPC.respond has to be one of \"yes\", \"no\" or \"ignore\"")
    DiscordRPClib.Discord_Respond(userId, replyMap[reply])
end

-- garbage collection callback
getmetatable(DiscordRPC.gcDummy).__gc = function()
    DiscordRPC.shutdown()
    ready_proxy:free()
    disconnected_proxy:free()
    errored_proxy:free()
    joinGame_proxy:free()
    spectateGame_proxy:free()
    joinRequest_proxy:free()
end

DiscordRPC.timer, DiscordRPC.maxTimer = 0, 2.5

DiscordRPC.presence = {}

return DiscordRPC