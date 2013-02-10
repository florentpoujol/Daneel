
Asset = {}
Asset.__index = Asset


-- Alias of CraftStudio.FindAsset(assetName, assetType)
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
        error(errorHead.."Argument 'assetName' is of type '" .. argType .. "' with value '"..tostring(assetName).."' instead of 'string'. Must the fully-qualified asset name.")
    end

    argType = type(assetType)
    if assetType ~= nil and argType ~= "string" then
        error(errorHead.."Argument 'assetType' is of type '" .. argType .. "' with value '"..tostring(assetType).."' instead of 'string'. Must the asset type.")
    end

    local asset = CraftStudio.FindAsset(assetName, assetType)

    if asset == nil then
        return nil
    end

    return setmetatable(asset, Asset)
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
        error(errorHead.."Argument 'assetName' is of type '" .. argType .. "' with value '"..tostring(assetName).."' instead of 'string'. Must the fully-qualified script name.")
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
        error(errorHead.."Argument 'assetName' is of type '" .. argType .. "' with value '"..tostring(assetName).."' instead of 'string'. Must the fully-qualified model name.")
    end

    return Asset.Get(assetName, "Model")
end

-- Get the ModelAnimation asset of the specified name.
-- @param assetName (string) The full asset name.
function Asset.GetModelAnimation(assetName, g)
    if assetName == Asset then
        assetName = g
    end

    local errorHead = "Asset.GetModelAnimation(assetName) : "

    local argType = type(assetName)
    if argType ~= "string" then
        error(errorHead.."Argument 'assetName' is of type '" .. argType .. "' with value '"..tostring(assetName).."' instead of 'string'. Must the fully-qualified ModelAnimation name.")
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
        error(errorHead.."Argument 'assetName' is of type '" .. argType .. "' with value '"..tostring(assetName).."' instead of 'string'. Must the fully-qualified map name.")
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
        error(errorHead.."Argument 'assetName' is of type '" .. argType .. "' with value '"..tostring(assetName).."' instead of 'string'. Must the fully-qualified TileSet name.")
    end

    return Asset.Get(assetName, "TileSet")
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
        error(errorHead.."Argument 'assetName' is of type '" .. argType .. "' with value '"..tostring(assetName).."' instead of 'string'. Must the fully-qualified scene name.")
    end

    return Asset.Get(assetName, "Scene")
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
        error(errorHead.."Argument 'assetName' is of type '" .. argType .. "' with value '"..tostring(assetName).."' instead of 'string'. Must the fully-qualified Sound name.")
    end

    return Asset.Get(assetName, "Sound")
end

-- Get the Document asset of the specified name.
-- @param assetName (string) The full asset name.
function Asset.GetDocument(assetName, g)
    if assetName == Asset then
        assetName = g
    end

    local errorHead = "Asset.GetDocument(assetName) : "

    local argType = type(assetName)
    if argType ~= "string" then
        error(errorHead.."Argument 'assetName' is of type '" .. argType .. "' with value '"..tostring(assetName).."' instead of 'string'. Must the fully-qualified Document name.")
    end

    return Asset.Get(assetName, "Document")
end





-- Tell if the specified asset is of the specified type.
-- @param asset (table) The asset.
-- @param assetType (string) The asset type.
-- @return (boolean) True if the specified asset is of the specified type, false otherwise
function Asset.IsOfType(asset, assetType, g)
    if asset == Asset then
        asset = assetType
        assetType = g
    end

    local errorHead = "Asset.IsOfType(asset, assetType) : "

    local argType = type(asset)
    if argType ~= "table" then
        error(errorHead.."Argument 'asset' is of type '" .. argType .. "' with value '"..tostring(asset).."' instead of 'table'. Must the asset.")
    end

    argType = type(assetType)
    if argType ~= "string" then
        error(errorHead.."Argument 'assetType' is of type '" .. argType .. "' with value '"..tostring(assetType).."' instead of 'string'. Must the asset type.")
    end

    --

    local assetTypes = Daneel.config.assetTypes
    assetType = Daneel.Utilities.CaseProof(assetType, assetTypes)

    if not table.containsvalue(Daneel.config.assetTypes, assetType) then
        error(errorHead.."Argument 'assetType' ["..assetType.."] is not one of the valid asset types : "..table.concat(assetTypes, ", "))
    end

    if asset.inner ~= nil and tostring(asset.inner):find("CraftStudioCommon.ProjectData."..assetType) ~= nil then
        return true
    end

    return false
end

-- Tell if the specified asset is of type Script.
-- @param asset (table) The asset.
-- @return (boolean) True if the specified asset is of type Script, false otherwise
function Asset.IsScript(asset, g)
    if asset == Asset then
        asset = g
    end

    local errorHead = "Asset.IsScript(asset) : "

    local argType = type(asset)
    if argType ~= "table" then
        error(errorHead.."Argument 'asset' is of type '" .. argType .. "' with value '"..tostring(asset).."' instead of 'table'. Must the asset.")
    end

    return Asset.IsOfType(asset, "Script")
end

-- Tell if the specified asset is of type Model.
-- @param asset (table) The asset.
-- @return (boolean) True if the specified asset is of type Model, false otherwise
function Asset.IsModel(asset, g)
    if asset == Asset then
        asset = g
    end

    local errorHead = "Asset.IsModel(asset) : "

    local argType = type(asset)
    if argType ~= "table" then
        error(errorHead.."Argument 'asset' is of type '" .. argType .. "' with value '"..tostring(asset).."' instead of 'table'. Must the asset.")
    end

    return Asset.IsOfType(asset, "Model")
end

-- Tell if the specified asset is of type ModelAnimation.
-- @param asset (table) The asset.
-- @return (boolean) True if the specified asset is of type ModelAnimation, false otherwise
function Asset.IsModelAnimation(asset, g)
    if asset == Asset then
        asset = g
    end

    local errorHead = "Asset.IsModelAnimation(asset) : "

    local argType = type(asset)
    if argType ~= "table" then
        error(errorHead.."Argument 'asset' is of type '" .. argType .. "' with value '"..tostring(asset).."' instead of 'table'. Must the asset.")
    end

    return Asset.IsOfType(asset, "ModelAnimation")
end

-- Tell if the specified asset is of type Map.
-- @param asset (table) The asset.
-- @return (boolean) True if the specified asset is of type Map, false otherwise
function Asset.IsMap(asset, g)
    if asset == Asset then
        asset = g
    end

    local errorHead = "Asset.IsMap(asset) : "

    local argType = type(asset)
    if argType ~= "table" then
        error(errorHead.."Argument 'asset' is of type '" .. argType .. "' with value '"..tostring(asset).."' instead of 'table'. Must the asset.")
    end

    return Asset.IsOfType(asset, "Map")
end

-- Tell if the specified asset is of type TileSet.
-- @param asset (table) The asset.
-- @return (boolean) True if the specified asset is of type TileSet, false otherwise
function Asset.IsTileSet(asset, g)
    if asset == Asset then
        asset = g
    end

    local errorHead = "Asset.IsTileSet(asset) : "

    local argType = type(asset)
    if argType ~= "table" then
        error(errorHead.."Argument 'asset' is of type '" .. argType .. "' with value '"..tostring(asset).."' instead of 'table'. Must the asset.")
    end

    return Asset.IsOfType(asset, "TileSet")
end

-- Tell if the specified asset is of type Scene.
-- @param asset (table) The asset.
-- @return (boolean) True if the specified asset is of type Scene, false otherwise
function Asset.IsScene(asset, g)
    if asset == Asset then
        asset = g
    end

    local errorHead = "Asset.IsScene(asset) : "

    local argType = type(asset)
    if argType ~= "table" then
        error(errorHead.."Argument 'asset' is of type '" .. argType .. "' with value '"..tostring(asset).."' instead of 'table'. Must the asset.")
    end

    return Asset.IsOfType(asset, "Scene")
end

-- Tell if the specified asset is of type Sound.
-- @param asset (table) The asset.
-- @return (boolean) True if the specified asset is of type Sound, false otherwise
function Asset.IsSound(asset, g)
    if asset == Asset then
        asset = g
    end

    local errorHead = "Asset.IsSound(asset) : "

    local argType = type(asset)
    if argType ~= "table" then
        error(errorHead.."Argument 'asset' is of type '" .. argType .. "' with value '"..tostring(asset).."' instead of 'table'. Must the asset.")
    end

    return Asset.IsOfType(asset, "Sound")
end

-- Tell if the specified asset is of type Document.
-- @param asset (table) The asset.
-- @return (boolean) True if the specified asset is of type Document, false otherwise
function Asset.IsDocument(asset, g)
    if asset == Asset then
        asset = g
    end

    local errorHead = "Asset.IsDocument(asset) : "

    local argType = type(asset)
    if argType ~= "table" then
        error(errorHead.."Argument 'asset' is of type '" .. argType .. "' with value '"..tostring(asset).."' instead of 'table'. Must the asset.")
    end

    return Asset.IsOfType(asset, "Document")
end


-- Return the type of the provided asset
-- @param asset (table) The asset
-- @return (string) The asset type or nil
function Asset.GetType(asset, g)
    if asset == Asset then
        asset = g
    end

    local errorHead = "Asset.GetType(asset) : "

    local argType = type(asset)
    if argType ~= "table" then
        error(errorHead.."Argument 'asset' is of type '" .. argType .. "' with value '"..tostring(asset).."' instead of 'table'. Must the asset.")
    end


    local inner = tostring(asset.inner)

    if inner ~= nil then
        for key, assetType in ipairs(Daneel.config.assetTypes) do
            if inner:find(assetType) ~= nil then
                return assetType
            end
        end
    end

    return nil
end
