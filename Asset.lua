
-- Get the asset of the specified name and type.
-- @param assetName (string) The full asset name.
-- @param assetType [optionnal] (string) The asset type (Model, Map, TileSet, ModelAnimation, Scene, Sound, Script).
function Asset.Get(assetName, assetType, g)
    if assetName == Asset then
        assetName = assetType
        assetType = g
    end

    local errorHead = "Asset.Get(assetName[, assetType]) : "

    local argType = type(assetName)
    if argType ~= "string" then
        error(errorHead.."Argument 'assetName' is of type '" .. argType .. "' instead of 'string'. Must the fully-qualified asset name.")
    end

    argType = type(assetType)
    if assetType ~= nil and argType ~= "string" then
        error(errorHead.."Argument 'assetType' is of type '" .. argType .. "' instead of 'string'. Must the asset type.")
    end

    return CraftSudio.FindAsset(assetName, assetType)
end

-- Get the script asset of the specified name.
-- @param assetName (string) The full asset name.
function Asset.GetScript(assetName, g)
    if assetName == Asset then
        assetName = g
    end

    local errorHead = "Asset.GetScript(assetName) : "

    local argType = type(assetName)
    if argType ~= "string" then
        error(errorHead.."Argument 'assetName' is of type '" .. argType .. "' instead of 'string'. Must the fully-qualified script name.")
    end

    return Asset.Get(assetName, "Script")
end

-- Get the model asset of the specified name.
-- @param assetName (string) The full asset name.
function Asset.GetModel(assetName, g)
    if assetName == Asset then
        assetName = g
    end

    local errorHead = "Asset.GetModel(assetName) : "

    local argType = type(assetName)
    if argType ~= "string" then
        error(errorHead.."Argument 'assetName' is of type '" .. argType .. "' instead of 'string'. Must the fully-qualified model name.")
    end

    return Asset.Get(assetName, "Model")
end

-- Get the ModelAnimation asset of the specified name.
-- @param assetName (string) The full asset name.
function Asset.GetAnimation(assetName, g)
    if assetName == Asset then
        assetName = g
    end

    local errorHead = "Asset.GetAnimation(assetName) : "

    local argType = type(assetName)
    if argType ~= "string" then
        error(errorHead.."Argument 'assetName' is of type '" .. argType .. "' instead of 'string'. Must the fully-qualified model animation name.")
    end

    return Asset.Get(assetName, "ModelAnimation")
end

-- Get the Map asset of the specified name.
-- @param assetName (string) The full asset name.
function Asset.GetMap(assetName, g)
    if assetName == Asset then
        assetName = g
    end

    local errorHead = "Asset.GetMap(assetName) : "

    local argType = type(assetName)
    if argType ~= "string" then
        error(errorHead.."Argument 'assetName' is of type '" .. argType .. "' instead of 'string'. Must the fully-qualified map name.")
    end

    return Asset.Get(assetName, "Map")
end

-- Get the TileSet asset of the specified name.
-- @param assetName (string) The full asset name.
function Asset.GetTileSet(assetName, g)
    if assetName == Asset then
        assetName = g
    end

    local errorHead = "Asset.GetTileSet(assetName) : "

    local argType = type(assetName)
    if argType ~= "string" then
        error(errorHead.."Argument 'assetName' is of type '" .. argType .. "' instead of 'string'. Must the fully-qualified TileSet name.")
    end

    return Asset.Get(assetName, "TileSet")
end

-- Get the Sound asset of the specified name.
-- @param assetName (string) The full asset name.
function Asset.GetSound(assetName, g)
    if assetName == Asset then
        assetName = g
    end

    local errorHead = "Asset.GetSound(assetName) : "

    local argType = type(assetName)
    if argType ~= "string" then
        error(errorHead.."Argument 'assetName' is of type '" .. argType .. "' instead of 'string'. Must the fully-qualified Sound name.")
    end

    return Asset.Get(assetName, "Sound")
end

-- Get the Scene asset of the specified name.
-- @param assetName (string) The full asset name.
function Asset.GetScene(assetName, g)
    if assetName == Asset then
        assetName = g
    end

    local errorHead = "Asset.GetScene(assetName) : "

    local argType = type(assetName)
    if argType ~= "string" then
        error(errorHead.."Argument 'assetName' is of type '" .. argType .. "' instead of 'string'. Must the fully-qualified scene name.")
    end

    return Asset.Get(assetName, "Scene")
end
