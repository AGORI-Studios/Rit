local RitmodParser = {}

function string:strip()
    return self:gsub("^%s*(.-)%s*$", "%1")
end

-- Holy crap this is gonna be a LOT of regex.

function RitmodParser.parse(script)
    local parsed = {}

    --- /./ is a comment in the ritmod source (//. Had to put a . due to Better Comments extension)
    -- Functions are defined like this:
    -- Functions CAN be one line.
    --[[
        var val = "Hello World!"; // Variables are defined like this
        SetFunction Start {}// This is a comment
            val += 1; // Supports syntax sugar
            val++;
            val--;
        EndFunction

        /*
            This is a multiline comment
        */

        SetFunction OnBeat {beat}
            log("Beat: " + beat);
        EndFunction
    ]]

    parsed.functions = {}

    function parsed.functions.log(str)
        print(str)
    end
    
    local allFunctions = script:gmatch("SetFunction (.-) {.-}(.-)EndFunction")
    for name, body in allFunctions do
        name = name:strip()
        -- remove the comments
        body = body:gsub("/%*(.-)%*/", "")
        body = body:gsub("//.-\n", "\n")
        body = body:strip()

        parsed.functions[name] = body
    end

    -- Now to parse the variables
    parsed.variables = {}

    --they can also not add spaces between the variable name and the value
    -- like this: var val="Hello World!";
    local allVariables = script:gmatch("var (.-)=(.-);")
    for name, value in allVariables do
        -- strip the spaces
        name = name:strip()
        value = value:strip()
        -- if theres quotes, its a string
        if value:find("\"") or value:find("'") then
            parsed.variables[name] = value:sub(2, -2)
        elseif tonumber(value) then
            parsed.variables[name] = tonumber(value)
        elseif value == "true" or value == "false" then
            parsed.variables[name] = value == "true"
        else
            parsed.variables[name] = value
        end
    end

    parsed.script = script

    --[[ -- Now to parse the actual code in the functions
    for name, body in pairs(parsed.functions) do
        if name ~= "log" then
            local lines = body:gmatch("(.-);")
            for line in lines do
                line = line:strip()
                if line:find("log") then
                    local str = line:match("log%((.-)%)")
                    parsed.functions.log(str)
                end
            end
        end
    end ]]

    return parsed
end

function RitmodParser.callFunction(parsed, name, ...)
    -- Parse the script
    local parsed = parsed
    local name = name:strip()
    local args = {...}
    local env = {}
    for k, v in pairs(parsed.variables) do
        env[k] = v
    end
    for i, v in ipairs(args) do
        env["arg" .. i] = v
    end
    local body = parsed.functions[name]
    local lines = body:gmatch("(.-);")

    for line in lines do
        if not line:find("log") then
            -- operator can be +, -, *, /, +=, -=, *=, /=
            local var, operator, value = line:match("(.-)([%+%-*/]?=)(.+)")
            if (operator == nil or operator == "") or (value == nil or value == "") then
                -- can be val++; or val--;
                var, operator = line:match("(.-)([%+%-])")
                value = 1
            end
            print(var, operator, value)
            var, operator, value = var:strip(), operator:strip(), value:strip()
            if operator == "++" then
                env[var] = env[var] + 1
            elseif operator == "--" then
                env[var] = env[var] - 1
            elseif operator == "+=" or operator == "+" then
                env[var] = env[var] + value
            elseif operator == "-=" or operator == "-" then
                env[var] = env[var] - value
            elseif operator == "*=" or operator == "*" then
                env[var] = env[var] * value
            elseif operator == "/=" or operator == "/" then
                env[var] = env[var] / value
            end
        else
            local str = line:match("log%((.-)%)")
        end
    end

    for k, v in pairs(env) do
        parsed.variables[k] = v
    end

    return parsed
end


return RitmodParser