
Daneel = {}

Daneel.config = {

    componentTypes = {
        "ScriptedBehavior",
        "ModelRenderer",
        "MapRenderer",
        "Camera",
        "Transform"
    },

    assetTypes = {
        "Script",
        "Model",
        "ModelAnimation",
        "Map",
        "TileSet",
        "Sound",
        "Scene",
    },

    -- Correspondance between the component type (the keys) and the asset type (the values)
    componentTypeToAssetType = {
        Script = "Script",
        ScriptedBehavior = "Script",
        ModelRenderer = "Model",
        MapRenderer = "Map",
    }
}



Daneel.utilities = {}


-- Make sure that the case of the provided name is correct
-- by checking against value in the provided set.
-- @param name (string) The name to check the case.
-- @param set (table) A table of value to check the name against.
-- @param scriptProof [optionnal] (boolean=false) Check that Script is converted to ScriptedBehavior.
function Daneel.utilities.CaseProof(name, set, scriptProof)
    local errorHead = "Daneel.utilities.CaseProof(name, set, scriptProof) : "
    
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

    -- TODO ajouter possibilité d'ignorer la case dans table.contains value et key

    for i, setItem in ipairs(set) do
        if name:lower() == setItem:lower() then
            name = setItem
        end
    end
    
    if scriptProof then
        name = Daneel.utilities.ScriptProof(name)
    end

    return name
end

-- If the provided name is 'Script', returns 'ScriptedBehavior'.
-- @param name (string) The name to check.
-- @return (string) The new name.
function Daneel.utilities.ScriptProof(name)
    local argType = type(name)
    if argType ~= "string" then
        error("Daneel.utilities.ScriptProof(name) : Argument 'name' is of type '"..argType.."' instead of 'string'.")
    end

    if name:lower() == "script" then
        name = "ScriptedBehavior"
    end

    return name
end

-- Tell wether the provided name is 'script' or 'scriptedbehavior', case-insensitive.
-- @param name (string) The name to check
-- @return (boolean) True if the provided name is either 'script' or 'scriptedbehavior', false otherwise
function Daneel.utilities.IsScript(name)
    local argType = type(name)
    if argType ~= "string" then
        error("Daneel.utilities.IsScript(name) : Argument 'name' is of type '"..argType.."' instead of 'string'.")
    end

    if name:lower() == "script" or name:lower() == "scriptedbehavior" then
        return true
    end

    return false
end