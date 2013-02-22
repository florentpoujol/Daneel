
if Daneel == nil then
    Daneel = {}
end

Daneel.Utilities = {}


-- Make sure that the case of the provided name is correct.
-- by checking against value in the provided set.
-- @param name (string) The name to check the case.
-- @param set (table) A table of value to check the name against.
-- @param scriptProof [optionnal] (boolean=false) Check that Script is converted to ScriptedBehavior.
function Daneel.Utilities.CaseProof(name, set, scriptProof)
    Daneel.StackTrace.BeginFunction("Daneel.Utilities.CaseProof", name, set, scriptProof)
    local errorHead = "Daneel.Utilities.CaseProof(name, set, scriptProof) : "
    
    local argType = type(name)
    if argType ~= "string" then
        error(errorHead.."Argument 'name' is of type '"..argType.."' with value '"..tostring(name).."' instead of 'string'.")
    end

    argType = type(set)
    if argType ~= "table" then
        error(errorHead.."Argument 'set' is of type '"..argType.."' with value '"..tostring(set).."' instead of 'table'.")
    end

    argType = type(scriptProof)
    if scriptProof ~= nil and argType ~= "boolean" then
        error(errorHead.."Argument 'scriptProof' is of type '"..argType.."' with value '"..tostring(scriptProof).."' instead of 'boolean'.")
    end

    for i, setItem in ipairs(set) do
        if name:lower() == setItem:lower() then
            name = setItem
        end
    end
    
    if scriptProof then
        name = Daneel.Utilities.ScriptProof(name)
    end

    Daneel.StackTrace.EndFunction("Daneel.Utilities.CaseProof", name)
    return name
end

-- If the provided name is 'Script', returns 'ScriptedBehavior'.
-- @param name (string) The name to check.
-- @return (string) The new name.
function Daneel.Utilities.ScriptProof(name)
    Daneel.StackTrace.BeginFunction("Daneel.Utilities.ScriptProof", name)

    local argType = type(name)
    if argType ~= "string" then
        error("Daneel.Utilities.ScriptProof(name) : Argument 'name' is of type '"..argType.."' with value '"..tostring(name).."' instead of 'string'.")
    end

    if name:lower() == "script" then
        name = "ScriptedBehavior"
    end

    Daneel.StackTrace.EndFunction("Daneel.Utilities.ScriptProof", name)
    return name
end

-- Tell wether the provided name is 'script' or 'scriptedbehavior', case-insensitive.
-- @param name (string) The name to check.
-- @return (boolean) True if the provided name is either 'script' or 'scriptedbehavior', false otherwise.
function Daneel.Utilities.IsScript(name)
    Daneel.StackTrace.BeginFunction("Daneel.Utilities.IsScript", name)
    
    local argType = type(name)
    if argType ~= "string" then
        error("Daneel.Utilities.IsScript(name) : Argument 'name' is of type '"..argType.."' with value '"..tostring(name).."' instead of 'string'.")
    end

    local isScript = false

    if name:lower() == "script" or name:lower() == "scriptedbehavior" then
        isScript = true
    end

    Daneel.StackTrace.EndFunction("Daneel.Utilities.IsScript", isScript)
    return isScript
end


-- 
function Daneel.Utilities.GetAllCraftStudioTypesAndObjects()
    Daneel.StackTrace.BeginFunction("Daneel.Utilities.GetAllCraftStudioTypesAndObjects")
    local t = Daneel.config.allCraftStudioTypesAndObjects

    if t ~= nil then
        return t
    end

    t = table.new()
    t = t:join(table.combine(Daneel.config.assetTypes, Daneel.config.assetObjects))
    t = t:join(table.combine(Daneel.config.craftStudioCoreTypes, Daneel.config.craftStudioCoreObjects))
    t = t:join(table.combine(Daneel.config.daneelTypes, Daneel.config.daneelObjects))

    Daneel.config.allCraftStudioTypesAndObjects = t

    Daneel.StackTrace.EndFunction("Daneel.Utilities.GetAllCraftStudioTypesAndObjects", t)
    return t
end

-- Return the craftStudio Type of the provided argument
-- @param The argument to get the type
function cstype(arg)
    Daneel.StackTrace.BeginFunction("cstype", arg)
    argType = type(arg)

    if argType == "table" then
        local mt = getmetatable(arg)

        if mt ~= nil then
            local csto = Daneel.Utilities.GetAllCraftStudioTypesAndObjects()

            for csType, csObject in pairs(csto) do
                if mt == csObject then
                    Daneel.StackTrace.EndFunction("cstype", csType)
                    return csType
                end
            end
        end

        -- the csType variable on component is set during Compoenent.Init(), 
        -- because the component's metatable is hidden
        if arg.csType ~= nil and table.containsvalue(Daneel.config.componentTypes, arg.csType) then
            Daneel.StackTrace.EndFunction("cstype", arg.csType)
            return arg.csType
        end
    end

    Daneel.StackTrace.EndFunction("cstype", argType)
    return argType
end




----------------------------------------------------------------------------------
-- StackTrace

Daneel.StackTrace = { 
    messages = {},
    depth = 1,
}


function Daneel.StackTrace.BeginFunction(functionName, ...)
    local errorHead = "Daneel.StackTrace.BeginFunction(functionName[, ...]) : "

    local argType = type(functionName)
    if argType ~= "string" then
        error(errorHead.."Argument 'functionName' is of type '"..argType.."' with value '"..tostring(functionName).."' instead of 'string'. Must the function name.")
    end

    Daneel.StackTrace.depth = Daneel.StackTrace.depth + 1

    local msg = "- "*Daneel.StackTrace.depth.." "..functionName.."("

    if #arg > 0 then
        for argument in ipairs(arg) do
            msg = msg..tostring(argument)..", "
        end

        msg = msg:sub(1, #msg-2) -- removes the last coma+space
    end

    msg = msg..")"

    table.insert(Daneel.StackTrace.messages, msg)
end


function Daneel.StackTrace.EndFunction(functionName, ...)
    local errorHead = "Daneel.StackTrace.EndFunction(functionName[, ...]) : "

    local argType = type(functionName)
    if argType ~= "string" then
        error(errorHead.."Argument 'functionName' is of type '"..argType.."' with value '"..tostring(functionName).."' instead of 'string'. Must the function name.")
    end

    local msg = "- "*Daneel.StackTrace.depth.." "..functionName.."() returns "

    if #arg > 0 then
        for argument in ipairs(arg) do
            msg = msg..tostring(argument)..", "
        end

        msg = msg:sub(1, #msg-2)
    end

    table.insert(Daneel.StackTrace.messages, msg)
    Daneel.StackTrace.depth = Daneel.StackTrace.depth - 1
end


function Daneel.StackTrace.Print(length)
    if length == nil then
        length = Daneel.config.stackTraceLength
    end
    
    local messages = Daneel.StackTrace.messages
    
    print("~~~~~ Daneel.StackTrace ~~~~~ Begin ~~~~~")

    for i = #messages-length, #messages do
        local traceText = messages[i]
        
        if traceText ~= nil then
            print("#"..i.." "..traceText)
        end
    end

    print("~~~~~ Daneel.StackTrace ~~~~~ End ~~~~~")
end


local OriginalError = error

function error(text)
    Daneel.StackTrace.Print()
    OriginalError(text)
end




----------------------------------------------------------------------------------
-- Debug

Daneel.Debug = {}


-- Check the provided argument's type against the provided type and display error if they don't match
-- @param arg (mixed) The argument to check
-- @param argName (string) The argument name
-- @param expectedArgType (string) The expected argument type
-- @param errorStart [optional] (string) The begining of the error message
-- @param errorEnd [optional] (string) The end of the error message
function Daneel.Debug.CheckArgType(arg, argName, expectedArgType, errorStart, errorEnd)
    local errorHead = "Daneel.Debug.CheckArg(arg, argName, expectedArgType, errorStart, errorEnd) : "

    local argType = type(argName)
    if argType ~= "string" then
        error(errorHead.."Argument 'argName' is of type '"..argType.."' with value '"..tostring(argName).."' instead of 'string'.")
    end

    argType = type(expectedArgType)
    if argType ~= "string" then
        error(errorHead.."Argument 'expectedArgType' is of type '"..argType.."' with value '"..tostring(expectedArgType).."' instead of 'string'.")
    end

    argType = type(errorStart)
    if arType ~= nil and argType ~= "string" then
        error(errorHead.."Argument 'errorStart' is of type '"..argType.."' with value '"..tostring(errorStart).."' instead of 'string'.")
    end

    if errorStart == nil then errorStart = "" end

    argType = type(errorEnd)
    if arType ~= nil and argType ~= "string" then
        error(errorHead.."Argument 'errorEnd' is of type '"..argType.."' with value '"..tostring(errorEnd).."' instead of 'string'.")
    end

    if errorEnd == nil then errorEnd = "" end

    argType = cstype(arg)
    if argType ~= expectedArgType then
        error(errorStart.."Argument '"..argName.."' is of type '"..argType.."' with value '"..tostring(arg).."' instead of '"..expectedArgType.."'. "..errorEnd)
    end
end


-- Check the provided argument's type against the provided type and display error if they don't match
-- @param arg (mixed) The argument to check
-- @param argName (string) The argument name
-- @param expectedArgType (string) The expected argument type
-- @param errorStart [optional] (string) The begining of the error message
-- @param errorEnd [optional] (string) The end of the error message
function Daneel.Debug.CheckOptionalArgType(arg, argName, expectedArgType, errorStart, errorEnd)
    local errorHead = "Daneel.Debug.CheckArg(arg, argName, expectedArgType, errorStart, errorEnd) : "

    local argType = type(argName)
    if argType ~= "string" then
        error(errorHead.."Argument 'argName' is of type '"..argType.."' with value '"..tostring(argName).."' instead of 'string'.")
    end

    argType = type(expectedArgType)
    if argType ~= "string" then
        error(errorHead.."Argument 'expectedArgType' is of type '"..argType.."' with value '"..tostring(expectedArgType).."' instead of 'string'.")
    end

    argType = type(errorStart)
    if arType ~= nil and argType ~= "string" then
        error(errorHead.."Argument 'errorStart' is of type '"..argType.."' with value '"..tostring(errorStart).."' instead of 'string'.")
    end

    if errorStart == nil then
        errorStart = ""
    end

    argType = type(errorEnd)
    if arType ~= nil and argType ~= "string" then
        error(errorHead.."Argument 'errorEnd' is of type '"..argType.."' with value '"..tostring(errorEnd).."' instead of 'string'.")
    end

    if errorEnd == nil then
        errorEnd = ""
    end

    --

    argType = cstype(arg)
    if argType ~= nil and argType ~= expectedArgType then
        error(errorStart.."Optional argument '"..argName.."' is of type '"..argType.."' with value '"..tostring(arg).."' instead of '"..expectedArgType.."'. "..errorEnd)
    end
end


----------------------------------------------------------------------------------
-- Triggers    GameObject that check their distance against triggerableGameObject and send

Daneel.Triggers = {}

Daneel.Triggers.triggerableGameObjects = {}

-- Add a gameObject to the castableGameObject list.
-- @param gameObject (GameObject) The gameObject to add to the list.
function Daneel.Triggers.RegisterTriggerableGameObject(gameObject)
    Daneel.StackTrace.BeginFunction("Daneel.Trigger.RegisterTriggerableGameObject", gameObject)
    local errorHead = "Daneel.Trigger.RegisterTriggerableGameObject(gameObject) : "

    local argType = cstype(gameObject)
    if argType ~= "GameObject" then
        error(errorHead.."Argument 'gameObject' is of type '"..argType.."' with value '"..tostring(gameObject).."' instead of 'GameObject'.")
    end

    table.insert(Daneel.Trigger.triggerableGameObjects, gameObject)
    Daneel.StackTrace.EndFunction("Ray.RegisterCastableGameObject")
end

