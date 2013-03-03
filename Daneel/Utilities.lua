
if Daneel == nil then
    Daneel = {}
end

Daneel.Utilities = {}

-- Make sure that the case of the provided name is correct.
-- by checking against value in the provided set.
-- @param name (string) The name to check the case.
-- @param set (table) A table of value to check the name against.
-- @param scriptProof [optional default=false] (boolean) Check that Script is converted to ScriptedBehavior.
function Daneel.Utilities.CaseProof(name, set, scriptProof)
    Daneel.StackTrace.BeginFunction("Daneel.Utilities.CaseProof", name, set, scriptProof)
    local errorHead = "Daneel.Utilities.CaseProof(name, set[, scriptProof]) : " 
    Daneel.Debug.CheckArgType(name, "name", "string", errorHead)
    Daneel.Debug.CheckArgType(set, "set", "table", errorHead)
    Daneel.Debug.CheckArgType(scriptProof, "scriptProof", "scriptProof", errorHead)

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
    Daneel.Debug.CheckArgType(name, "name", "string", "Daneel.Utilities.ScriptProof(name) : ")

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
    Daneel.Debug.CheckArgType(name, "name", "string", "Daneel.Utilities.IsScript(name) : ")

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



----------------------------------------------------------------------------------
-- StackTrace

Daneel.StackTrace = { 
    messages = {},
    depth = 1,
}

-- Register a function input in the stack trace
-- @param functionName (string) The function name
-- @param ... [optional] (mixed) Arguments received by the function
function Daneel.StackTrace.BeginFunction(functionName, ...)
    local errorHead = "Daneel.StackTrace.BeginFunction(functionName[, ...]) : "
    Daneel.Debug.CheckArgType(functionName, "functionName", "string", errorHead)

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

-- Register a function output in the stack trace
-- @param functionName (string) The function name
-- @param ... [optional] (mixed) Variable returned by the function
function Daneel.StackTrace.EndFunction(functionName, ...)
    local errorHead = "Daneel.StackTrace.EndFunction(functionName[, ...]) : "
    Daneel.Debug.CheckArgType(functionName, "functionName", "string", errorHead)

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

-- Print Daneel's StackTrace
-- @param length [optional default=Daneel.config.stackTraceLength] (number) The number of StackTrace entries to print
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





----------------------------------------------------------------------------------
-- Debug

Daneel.Debug = {}

-- Check the provided argument's type against the provided type and display error if they don't match
-- @param argument (mixed) The argument to check
-- @param argumentName (string) The argument name
-- @param expectedArgumentTypes (string or table) The expected argument type(s)
-- @param errorHead [optional] (string) The begining of the error message
-- @param errorEnd [optional] (string) The end of the error message
function Daneel.Debug.CheckArgType(argument, argumentName, expectedArgumentTypes, errorHead, errorEnd)
    local _errorHead = "Daneel.Debug.CheckArgType(arg, argName, expectedArgumentTypes[, errorHead, errorEnd]) : "
    Daneel.Debug.CheckArgType(argumentName, "argumentName", "string", _errorHead)
    Daneel.Debug.CheckArgType(expectedArgumentTypes, "expectedArgumentTypes", {"string", "table"}, _errorHead)
    Daneel.Debug.CheckOptionalArgumentType(errorHead, "errorHead", "string", _errorHead)
    Daneel.Debug.CheckOptionalArgumentType(errorEnd, "errorEnd", "string", _errorHead)

    if type(argumentName) == "string" then
        expectedArgumentTypes = {expectedArgumentTypes}
    end

    if _errorHead == nil then errorHead = "" end
    if errorEnd == nil then errorEnd = "" end

    local argType = Daneel.Debug.GetType(arg)
    if not argType:isoneof(expectedArgumentTypes) then
        Daneel.Debug.PrintError(_errorHead.."Argument '"..argumentName.."' is of type '"..argumentType.."' with value '"..tostring(argument).."' instead of '"..table.concat(expectedArgumentTypes, "', '").."'. "..errorEnd)
    end
end

-- Check the provided argument's type against the provided type and display error if they don't match
-- @param argument (mixed) The argument to check
-- @param argumentName (string) The argument name
-- @param expectedArgumentTypes (string) The expected argument type
-- @param errorHead [optional] (string) The begining of the error message
-- @param errorEnd [optional] (string) The end of the error message
function Daneel.Debug.CheckOptionalArgType(argument, argumentName, expectedArgumentTypes, errorHead, errorEnd)
    local _errorHead = "Daneel.Debug.CheckOptionalArgType(arg, argName, expectedArgumentTypes, errorHead, errorEnd) : "
    Daneel.Debug.CheckArgType(argumentName, "argumentName", "string", _errorHead)
    Daneel.Debug.CheckArgType(expectedArgumentTypes, "expectedArgumentTypes", {"string", "table"}, _errorHead)
    Daneel.Debug.CheckOptionalArgumentType(errorHead, "errorHead", "string", _errorHead)
    Daneel.Debug.CheckOptionalArgumentType(errorEnd, "errorEnd", "string", _errorHead)

    if type(argumentName) == "string" then
        expectedArgumentTypes = {expectedArgumentTypes}
    end

    if _errorHead == nil then _errorHead = "" end
    if errorEnd == nil then errorEnd = "" end

    local argType = Daneel.Debug.GetType(argument)
    if argType ~= nil and not argType:isoneof(expectedArgumentTypes) then  
        Daneel.Debug.PrintError(_errorHead.."Optional argument '"..argumentName.."' is of type '"..argumentType.."' with value '"..tostring(argument).."' instead of '"..table.concat(expectedArgumentTypes, "', '").."'. "..errorEnd)
    end
end

-- Return the craftStudio Type of the provided argument
-- @param object (mixed) The argument to get the type
function Daneel.Debug.GetType(object)
    Daneel.StackTrace.BeginFunction("Daneel.Debug.GetType", object)
    local argType = type(object)

    if argType == "table" then
        local mt = getmetatable(object)

        if mt ~= nil then
            local csto = Daneel.Utilities.GetAllCraftStudioTypesAndObjects()
            for csType, csObject in pairs(csto) do
                if mt == csObject then
                    return Daneel.Debug.GetType
                end
            end
        end

        -- the componentType variable on component is set during Component.Init(), 
        -- because the component's metatable is hidden
        if object.componentType ~= nil and table.containsvalue(Daneel.config.componentTypes, object.componentType) then
            return object.componentType
        end
    end

    return argType
end

-- Alias for error() but print Daneel's stack trace first
-- @param message (string) The error message
function Daneel.Debug.PrintError(message)
    Daneel.StackTrace.Print()
    error(message)
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
    Daneel.Debug.CheckArgType(gameObject, "gameObject", "GameObject", errorHead)

    table.insert(Daneel.Trigger.triggerableGameObjects, gameObject)
    Daneel.StackTrace.EndFunction("Ray.RegisterCastableGameObject")
end

