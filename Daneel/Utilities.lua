
if Daneel == nil then
    Daneel = {}
end

Daneel.Utilities = {}

--- Make sure that the case of the provided name is correct.
-- by checking against value in the provided set.
-- @param name (string) The name to check the case.
-- @param set (table) A table of value to check the name against.
function Daneel.Utilities.CaseProof(name, set)
    Daneel.Debug.StackTrace.BeginFunction("Daneel.Utilities.CaseProof", name, set)
    local errorHead = "Daneel.Utilities.CaseProof(name, set) : " 
    Daneel.Debug.CheckArgType(name, "name", "string", errorHead)
    Daneel.Debug.CheckArgType(set, "set", "table", errorHead)

    for i, setItem in ipairs(set) do
        if name:lower() == setItem:lower() then
            name = setItem
        end
    end

    Daneel.Debug.StackTrace.EndFunction("Daneel.Utilities.CaseProof", name)
    return name
end



----------------------------------------------------------------------------------
-- Debug

Daneel.Debug = {}

--- Check the provided argument's type against the provided type and display error if they don't match
-- @param argument (mixed) The argument to check
-- @param argumentName (string) The argument name
-- @param expectedArgumentTypes (string or table) The expected argument type(s)
-- @param errorHead [optional] (string) The begining of the error message
-- @param errorEnd [optional] (string) The end of the error message
function Daneel.Debug.CheckArgType(argument, argumentName, expectedArgumentTypes, errorHead, errorEnd)
    local _errorHead = "Daneel.Debug.CheckArgType(argument, argumentName, expectedArgumentTypes[, errorHead, errorEnd]) : "
    
    local argType = type(argumentName)
    if argType ~= "string" then
        error(_errorHead.."Argument 'argumentName' is of type '"..argType.."' with value '"..tostring(argumentName).."' instead of 'string'.")
    end

    argType = type(expectedArgumentTypes)
    if argType ~= "string" and argType ~= "table" then
        error(_errorHead.."Argument 'expectedArgumentTypes' is of type '"..argType.."' with value '"..tostring(expectedArgumentTypes).."' instead of 'string' or 'table'.")
    end

    if argType == "string" then
        expectedArgumentTypes = {expectedArgumentTypes}
    end

    argType = type(errorHead)
    if arType ~= nil and argType ~= "string" then
        error(_errorHead.."Argument 'errorHead' is of type '"..argType.."' with value '"..tostring(errorHead).."' instead of 'string'.")
    end

    if errorHead == nil then errorHead = "" end

    argType = type(errorEnd)
    if arType ~= nil and argType ~= "string" then
        error(_errorHead.."Argument 'errorEnd' is of type '"..argType.."' with value '"..tostring(errorEnd).."' instead of 'string'.")
    end

    if errorEnd == nil then errorEnd = "" end

    --

    argType = Daneel.Debug.GetType(argument)
    local isOfExpectedType = false
    for i, expectedType in ipairs(expectedArgumentTypes) do
        if argType == expectedType then
            isOfExpectedType = true
        end
    end
    
    if isOfExpectedType == false then
        Daneel.Debug.PrintError(_errorHead.."Argument '"..argumentName.."' is of type '"..argumentType.."' with value '"..tostring(argument).."' instead of '"..table.concat(expectedArgumentTypes, "', '").."'. "..errorEnd)
    end
end

--- Check the provided argument's type against the provided type and display error if they don't match
-- @param argument (mixed) The argument to check
-- @param argumentName (string) The argument name
-- @param expectedArgumentTypes (string) The expected argument type
-- @param errorHead [optional] (string) The begining of the error message
-- @param errorEnd [optional] (string) The end of the error message
function Daneel.Debug.CheckOptionalArgType(argument, argumentName, expectedArgumentTypes, errorHead, errorEnd)
    if argument == nil then
        return
    end

    local _errorHead = "Daneel.Debug.CheckOptionalArgType(argument, argumentName, expectedArgumentTypes, errorHead, errorEnd) : "
    
    local argType = type(argumentName)
    if argType ~= "string" then
        error(_errorHead.."Argument 'argumentName' is of type '"..argType.."' with value '"..tostring(argumentName).."' instead of 'string'.")
    end

    argType = type(expectedArgTypes)
    if argType ~= "string" and argType ~= "table" then
        error(_errorHead.."Argument 'expectedArgTypes' is of type '"..argType.."' with value '"..tostring(expectedArgTypes).."' instead of 'string' or 'table'.")
    end

    if argType == "string" then
        expectedArgTypes = {expectedArgTypes}
    end

    argType = type(errorHead)
    if arType ~= nil and argType ~= "string" then
        error(_errorHead.."Argument 'errorHead' is of type '"..argType.."' with value '"..tostring(errorHead).."' instead of 'string'.")
    end

    if errorHead == nil then errorHead = "" end

    argType = type(errorEnd)
    if arType ~= nil and argType ~= "string" then
        error(_errorHead.."Argument 'errorEnd' is of type '"..argType.."' with value '"..tostring(errorEnd).."' instead of 'string'.")
    end

    if errorEnd == nil then errorEnd = "" end

    --

    argType = Daneel.Debug.GetType(argument)
    local isOfExpectedType = false
    for i, expectedType in ipairs(expectedArgumentTypes) do
        if argType == expectedType then
            isOfExpectedType = true
        end
    end
    
    if isOfExpectedType == false then
        Daneel.Debug.PrintError(_errorHead.."Optional argument '"..argumentName.."' is of type '"..argumentType.."' with value '"..tostring(argument).."' instead of '"..table.concat(expectedArgumentTypes, "', '").."'. "..errorEnd)
    end
end

--- Return the craftStudio Type of the provided argument
-- @param object (mixed) The argument to get the type of
function Daneel.Debug.GetType(object)
    local argType = type(object)

    if argType == "table" then
        -- the componentType variable on component is set during Component.Init(), 
        -- because the component's metatable is hidden
        if object.componentType ~= nil and table.containsvalue(table.getkeys(Daneel.config.componentsObjects), object.componentType) then
            return object.componentType
        end

        -- for all other times, the type is defined by the object's metatable
        local mt = getmetatable(object)

        if mt ~= nil then
            -- the metatable of the ScriptedBahaviors is the corresponding asset
            -- the metatable of all script assets is Script
            if getmetatable(mt) == Script then
                return "ScriptedBehavior"
            end

            -- other types
            local allObjects = Daneel.config.allObjects
            for type, object in pairs(allObjects) do
                if mt == object then
                    return type
                end
            end
        end
    end

    return argType
end

--- Alias for error() but print Daneel's stack trace first
-- @param message (string) The error message
function Daneel.Debug.PrintError(message)
    Daneel.Debug.StackTrace.Print()
    error(message)
end

--- Check the value of 'componentType' and throw error if it is not one of the valid component types or objects.
-- @param componentType (string, ScriptedBehavior, ModelRenderer, MapRenderer, Camera or Transform)
-- @return (string) The component type as a string with the correct case
function Daneel.Debug.CheckComponentType(componentType)
    Daneel.Debug.StackTrace.BeginFunction("Daneel.Debug.CheckComponentType", componentType)
    local errorHead = "Daneel.Debug.CheckComponentType(componentType) : "
    Daneel.Debug.CheckArgType(componentType, "componentType", {"string", unpack(table.getvalues(Daneel.config.componentObjects))}, errorHead)

    -- if componentType is an object
    if type(componentType) ~= "string" then
        componentType = table.getkey(Daneel.config.componentObjects, componentType)
    end

    local componentTypes = Daneel.config.componentTypes
    componentType = Daneel.Utilities.CaseProof(componentType, componentTypes)
    if not componentType:isoneof(componentTypes) then
        Daneel.Debug.PrintError(errorHead.."Argument 'componentType' with value '"..componentType.."' is not one of the valid component types : "..table.concat(componentTypes, ", "))
    end

    Daneel.Debug.StackTrace.EndFunction("Daneel.Debug.CheckComponentType", componentType)
    return componentType
end

--- Check the value of 'assetType' and throw error if it is not one of the valid asset types or objects.
-- @param assetType (string, Script, Model, ModelAnimation, Map, TileSet, Scene, Sound, Document)
-- @return (string) The asset type as a string with the correct case
function Daneel.Debug.CheckAssetType(assetType)
    Daneel.Debug.StackTrace.BeginFunction("Daneel.Debug.CheckAssetType", assetType)
    local errorHead = "Daneel.Debug.CheckAssetType(assetType) : "
    Daneel.Debug.CheckArgType(assetType, "assetType", {"string", unpack(table.getvalues(Daneel.config.assetObjects))}, errorHead)

    -- if assetType is an object
    if type(assetType) ~= "string" then
        assetType = table.getkey(Daneel.config.assetObjects, assetType)
    end

    local assetTypes = Daneel.config.assetTypes
    assetType = Daneel.Utilities.CaseProof(assetType, assetTypes)
    if not assetType:isoneof(assetTypes) then
        Daneel.Debug.PrintError(errorHead.."Argument 'assetType' with value '"..assetType.."' is not one of the valid asset types : "..table.concat(assetTypes, ", "))
    end

    Daneel.Debug.StackTrace.EndFunction("Daneel.Debug.CheckAssetType", assetType)
    return assetType
end



----------------------------------------------------------------------------------
-- StackTrace

Daneel.Debug.StackTrace = { 
    messages = {},
    depth = 1,
}

--- Register a function input in the stack trace
-- @param functionName (string) The function name
-- @param ... [optional] (mixed) Arguments received by the function
function Daneel.Debug.StackTrace.BeginFunction(functionName, ...)
    local errorHead = "Daneel.Debug.StackTrace.BeginFunction(functionName[, ...]) : "
    Daneel.Debug.CheckArgType(functionName, "functionName", "string", errorHead)

    Daneel.Debug.StackTrace.depth = Daneel.Debug.StackTrace.depth + 1

    local msg = "- "*Daneel.Debug.StackTrace.depth.." "..functionName.."("

    if #arg > 0 then
        for i, argument in ipairs(arg) do
            msg = msg..tostring(argument)..", "
        end

        msg = msg:sub(1, #msg-2) -- removes the last coma+space
    end

    msg = msg..")"

    table.insert(Daneel.Debug.StackTrace.messages, msg)
end

--- Register a function output in the stack trace
-- @param functionName (string) The function name
-- @param ... [optional] (mixed) Variable returned by the function
function Daneel.Debug.StackTrace.EndFunction(functionName, ...)
    local errorHead = "Daneel.Debug.StackTrace.EndFunction(functionName[, ...]) : "
    Daneel.Debug.CheckArgType(functionName, "functionName", "string", errorHead)

    local msg = "- "*Daneel.Debug.StackTrace.depth.." "..functionName.."() returns "

    if #arg > 0 then
        for i, argument in ipairs(arg) do
            msg = msg..tostring(argument)..", "
        end

        msg = msg:sub(1, #msg-2)
    end

    Daneel.Debug.StackTrace.messages[Daneel.Debug.StackTrace.depth] = nil
    Daneel.Debug.StackTrace.depth = Daneel.Debug.StackTrace.depth - 1
end

--- Print the StackTrace
function Daneel.Debug.StackTrace.Print() 
    local messages = Daneel.Debug.StackTrace.messages
    
    print("~~~~~ Daneel.Debug.StackTrace ~~~~~ Begin ~~~~~")

    for i, msg in ipairs(messages) do
        if i < 10 then
            i = "0"..i
        end
        print("#"..i.." "..msg)
    end

    print("~~~~~ Daneel.Debug.StackTrace ~~~~~ End ~~~~~")
end
