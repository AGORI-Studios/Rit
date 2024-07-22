local love = require("love")
local json = json or require("lib.jsonhybrid")
local RequestJsonData = require("modules.API.RequestJsonData")
local path = "Modules.Threads.API."

local networkConnected = ... or false

