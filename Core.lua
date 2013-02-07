Daneel = {}

Daneel.core = {}


-- Make sure that the case of the provided name is correct.
-- by checking against value in the provided set.
-- @param name (string) The name to check the case.
-- @param set (table) A table of value to check the name against.
-- @param scriptProof [optionnal] (boolean=false) Check that Script is converted to ScriptedBehavior.
function Daneel.core.CaseProof(name, set, scriptProof)
    local errorHead = "Daneel.core.CaseProof(name, set, scriptProof) : "
    
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
        name = Daneel.core.ScriptProof(name)
    end

    return name
end

-- If the provided name is 'Script', returns 'ScriptedBehavior'.
-- @param name (string) The name to check.
-- @return (string) The new name.
function Daneel.core.ScriptProof(name)
    local argType = type(name)
    if argType ~= "string" then
        error("Daneel.core.ScriptProof(name) : Argument 'name' is of type '"..argType.."' instead of 'string'.")
    end

    if name:lower() == "script" then
        name = "ScriptedBehavior"
    end

    return name
end

-- Tell wether the provided name is 'script' or 'scriptedbehavior', case-insensitive.
-- @param name (string) The name to check.
-- @return (boolean) True if the provided name is either 'script' or 'scriptedbehavior', false otherwise.
function Daneel.core.IsScript(name)
    local argType = type(name)
    if argType ~= "string" then
        error("Daneel.core.IsScript(name) : Argument 'name' is of type '"..argType.."' instead of 'string'.")
    end

    if name:lower() == "script" or name:lower() == "scriptedbehavior" then
        return true
    end

    return false
end


-- 
function Daneel.core.GetAllCraftStudioTypesAndObjects()
    local t = table.new()
    t = t:join(table.combine(Daneel.config.assetTypes, Daneel.config.assetObjects))
    t = t:join(table.combine(Daneel.config.craftStudioCoreTypes, Daneel.config.craftStudioCoreObjects))
    t = t:join(table.combine(Daneel.config.daneelTypes, Daneel.config.daneelObjects))
    return t
end

-- Return the craftStudio Type of the provided argument
-- @param The argument to get the type
local oldTypeFunction = type

function type(arg)
    argType = oldTypeFunction(arg)

    if argType == "table" then
        local mt = getmetatable(arg)

        if mt ~= nil then
            local csto = GetAllCraftStudioTypesAndObjects()

            for csType, csObject in pairs(csto) do
                if mt == csObject then
                    return csType
                end
            end
        end
    end

    return argType
end
