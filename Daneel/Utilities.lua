
if Daneel == nil then Daneel = {} end

Daneel.Utilities = {}


-- Make sure that the case of the provided name is correct.
-- by checking against value in the provided set.
-- @param name (string) The name to check the case.
-- @param set (table) A table of value to check the name against.
-- @param scriptProof [optionnal] (boolean=false) Check that Script is converted to ScriptedBehavior.
function Daneel.Utilities.CaseProof(name, set, scriptProof)
    local errorHead = "Daneel.Utilities.CaseProof(name, set, scriptProof) : "
    
    local argType = type(name)
    if argType ~= "string" then
        error(errorHead.."Argument 'name' is of type '"..argType.."' instead of 'string'.")
    end

    argType = type(set)
    if argType ~= "table" then
        error(errorHead.."Argument 'set' is of type '"..argType.."' instead of 'table'.")
    end

    argType = type(scriptProof)
    if scriptProof ~= nil and argType ~= "boolean" then
        error(errorHead.."Argument 'scriptProof' is of type '"..argType.."' instead of 'boolean'.")
    end

    for i, setItem in ipairs(set) do
        if name:lower() == setItem:lower() then
            name = setItem
        end
    end
    
    if scriptProof then
        name = Daneel.Utilities.ScriptProof(name)
    end

    return name
end

-- If the provided name is 'Script', returns 'ScriptedBehavior'.
-- @param name (string) The name to check.
-- @return (string) The new name.
function Daneel.Utilities.ScriptProof(name)
    local argType = type(name)
    if argType ~= "string" then
        error("Daneel.Utilities.ScriptProof(name) : Argument 'name' is of type '"..argType.."' instead of 'string'.")
    end

    if name:lower() == "script" then
        name = "ScriptedBehavior"
    end

    return name
end

-- Tell wether the provided name is 'script' or 'scriptedbehavior', case-insensitive.
-- @param name (string) The name to check.
-- @return (boolean) True if the provided name is either 'script' or 'scriptedbehavior', false otherwise.
function Daneel.Utilities.IsScript(name)
    local argType = type(name)
    if argType ~= "string" then
        error("Daneel.Utilities.IsScript(name) : Argument 'name' is of type '"..argType.."' instead of 'string'.")
    end

    if name:lower() == "script" or name:lower() == "scriptedbehavior" then
        return true
    end

    return false
end


-- 
function Daneel.Utilities.GetAllCraftStudioTypesAndObjects()
    local t = Daneel.config.allCraftStudioTypesAndObjects

    if t ~= nil then
        return t
    end

    t = table.new()
    t = t:join(table.combine(Daneel.config.assetTypes, Daneel.config.assetObjects))
    t = t:join(table.combine(Daneel.config.craftStudioCoreTypes, Daneel.config.craftStudioCoreObjects))
    t = t:join(table.combine(Daneel.config.daneelTypes, Daneel.config.daneelObjects))

    Daneel.config.allCraftStudioTypesAndObjects = t

    return t
end

-- Return the craftStudio Type of the provided argument
-- @param The argument to get the type
function cstype(arg)
    argType = type(arg)

    if argType == "table" then
        local mt = getmetatable(arg)

        if mt ~= nil then
            local csto = Daneel.Utilities.GetAllCraftStudioTypesAndObjects()

            for csType, csObject in pairs(csto) do
                if mt == csObject then
                    return csType
                end
            end
        end

        -- Assets don't have metatable
        local assetType = Asset.GetType(arg)

        if assetType ~= nil then
            return assetType
        end
    end

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

    local msg = "-"*Daneel.StackTrace.depth.." Call to "..functionName.."("

    if #arg > 0 then
        for argument in iparis(arg) do
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

    local msg = "-"*Daneel.StackTrace.depth..functionName.."() returns "

    if #arg > 0 then
        for argument in iparis(arg) do
            msg = msg..tostring(argument)..", "
        end

        msg = msg:sub(1, #msg-2)
    end

    table.insert(Daneel.StackTrace.messages, msg)
    Daneel.StackTrace.depth = Daneel.StackTrace.depth - 1
end


function Daneel.StackTrace.Print(length)
    --if #Daneel.StackTrace.messages <= 0 then return end

    if length == nil then
        length = Daneel.config.stackTraceLength
    end
    
    print("~~~~~ Daneel.StackTrace ~~~~~ Begin ~~~~~")

    for i = length, 1, -1 do
        local traceText = Daneel.StackTrace.messages[i]
        
        if traceText ~= nil then
            print(traceText)
        end
    end

    print("~~~~~ Daneel.StackTrace ~~~~~ End ~~~~~")
end


local OriginalError = error

function error(text)
    Daneel.StackTrace.Print()
    OriginalError(text)
end
