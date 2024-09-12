---@diagnostic disable: inject-field
local discrpc = ffi.load("discord-rpc")
if not ffi then
    return false
end

ffi.cdef [[
// Discord Rich Presence API
typedef struct DiscordRichPresence {
    const char* state;   
    const char* details; 
    int64_t startTimestamp;
    int64_t endTimestamp;
    const char* largeImageKey; 
    const char* largeImageText; 
    const char* smallImageKey;  
    const char* smallImageText; 
    const char* partyId;        
    const char* button1_label;  
    const char* button1_url;    
    const char* button2_label;  
    const char* button2_url;    

    // UNUSED
    int partySize;
    int partyMax;
    const char* matchSecret;    
    const char* joinSecret;     
    const char* spectateSecret; 
    int8_t instance;
} DiscordRichPresence;

typedef struct DiscordUser {
    const char *userId;
    const char *username;
    const char *discriminator;
    const char *avatar;
} DiscordUser;

typedef void (*ready)(const DiscordUser *request);
typedef void (*disconnected)(int errorCode, const char *message);
typedef void (*errored)(int errorCode, const char *message);
typedef void (*joinGame)(const char *joinSecret);
typedef void (*spectateGame)(const char *spectateSecret);


typedef struct DiscordEventHandlers {
    ready ready;
    disconnected disconnected;
    errored errored;
    joinGame joinGame;
    spectateGame spectateGame;
} DiscordEventHandlers;

void Discord_Initialize(const char *applicationId, DiscordEventHandlers *handlers, int autoRegister, const char *optionalSteamId);
void Discord_Shutdown(void);
void Discord_RunCallbacks(void);
void Discord_UpdatePresence(const DiscordRichPresence *presence);
void Discord_ClearPresence(void);
void Discord_Respond(const char *userId, int reply);
void Discord_UpdateHandlers(DiscordEventHandlers *handlers);
]]

local DiscordRPC = {}
DiscordRPC.timer = 0
DiscordRPC.maxTimer = 1 -- In seconds

local function getUserData(user)
    return {
        userId = ffi.string(user.userId),
        username = ffi.string(user.username),
        discriminator = ffi.string(user.discriminator),
        avatar = ffi.string(user.avatar)
    }
end

local readyCallback = ffi.cast("ready", function(user)
    if not DiscordRPC.ready then return end
    DiscordRPC.ready(getUserData(user))
end)

local disconnectedCallback = ffi.cast("disconnected", function(errorCode, message)
    if not DiscordRPC.disconnected then return end
    DiscordRPC.disconnected(errorCode, ffi.string(message))
end)

local erroredCallback = ffi.cast("errored", function(errorCode, message)
    if not DiscordRPC.errored then return end
    DiscordRPC.errored(errorCode, ffi.string(message))
end)

local joinGameCallback = ffi.cast("joinGame", function(joinSecret)
    if not DiscordRPC.joinGame then return end
    DiscordRPC.joinGame(ffi.string(joinSecret))
end)

local spectateGameCallback = ffi.cast("spectateGame", function(spectateSecret)
    if not DiscordRPC.spectateGame then return end
    DiscordRPC.spectateGame(ffi.string(spectateSecret))
end)

function DiscordRPC:initialize(applicationId, autoRegister, optionalSteamId)
    self.handlers = ffi.new("DiscordEventHandlers") ---@type ffi.cdata*
    self.handlers.ready = readyCallback
    self.handlers.disconnected = disconnectedCallback
    self.handlers.errored = erroredCallback
    self.handlers.joinGame = joinGameCallback
    self.handlers.spectateGame = spectateGameCallback
    
    discrpc.Discord_Initialize(applicationId, self.handlers, autoRegister and 1 or 0, optionalSteamId)
end

function DiscordRPC:updatePresence(presence)
    local cPresence = ffi.new("DiscordRichPresence")
    cPresence.state = presence.state or ""
    cPresence.details = presence.details or ""
    cPresence.startTimestamp = presence.startTimestamp or 0
    cPresence.endTimestamp = presence.endTimestamp or 0
    cPresence.largeImageKey = presence.largeImageKey or ""
    cPresence.largeImageText = presence.largeImageText or ""
    cPresence.smallImageKey = presence.smallImageKey or ""
    cPresence.smallImageText = presence.smallImageText or ""
    
    cPresence.button1_url = presence.button1_url or ""
    cPresence.button2_url = presence.button2_url or ""
    cPresence.button1_label = presence.button1_label or ""
    cPresence.button2_label = presence.button2_label or ""

    cPresence.partyId = presence.partyId or ""
    cPresence.partySize = presence.partySize or 0
    cPresence.partyMax = presence.partyMax or 0
    cPresence.matchSecret = presence.matchSecret or ""
    cPresence.joinSecret = presence.joinSecret or ""
    cPresence.spectateSecret = presence.spectateSecret or ""
    cPresence.instance = presence.instance or 0

    discrpc.Discord_UpdatePresence(cPresence)
end

function DiscordRPC:clearPresence()
    discrpc.Discord_ClearPresence()
end

function DiscordRPC:respond(userId, reply)
    discrpc.Discord_Respond(userId, reply)
end

function DiscordRPC:updateHandlers(handlers)
    self.handlers = ffi.new("DiscordEventHandlers", handlers)
    discrpc.Discord_UpdateHandlers(self.handlers)
end

function DiscordRPC:runCallbacks()
    discrpc.Discord_RunCallbacks()
end

function DiscordRPC:shutdown()
    discrpc.Discord_Shutdown()
end

return DiscordRPC