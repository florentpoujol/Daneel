
Asset = {}
Asset.__index = Asset

function Asset.__tostring(asset)
    return tostring(asset.inner):sub(31, 60)
end


-- Alias of CraftStudio.FindAsset(assetName, assetType)
-- Get the asset of the specified name and type.
-- @param assetName (string) The full asset name.
-- @param assetType [optionnal] (string) The asset type (Model, Map, TileSet, ModelAnimation, Scene, Sound, Script).
function Asset.Get(assetName, assetType)
    Daneel.StackTrace.BeginFunction("Asset.Get", assetName, assetType)
    local errorHead = "Asset.Get(assetName[, assetType]) : "

    local argType = type(assetName)
    if argType ~= "string" then
        error(errorHead.."Argument 'assetName' is of type '"..argType.."' with value '"..tostring(assetName).."' instead of 'string'. Must the fully-qualified asset name.")
    end

    argType = type(assetType)
    if assetType ~= nil and argType ~= "string" then
        error(errorHead.."Argument 'assetType' is of type '"..argType.."' with value '"..tostring(assetType).."' instead of 'string'. Must the asset type.")
    end

    if assetType ~= nil then
        local assetTypes = Daneel.config.assetTypes
        assetType = Daneel.Utilities.CaseProof(assetType, assetTypes)

        if not table.containsvalue(assetTypes, assetType) then
            error(errorHead.."Argument 'assetType' with value '"..assetType.."' is not one of the valid asset types : "..table.concat(assetTypes, ", "))
        end
    end

    local asset = CraftStudio.FindAsset(assetName, assetType)

    if asset ~= nil then
        asset = setmetatable(asset, Asset)
    end

    Daneel.StackTrace.EndFunction("Asset.Get", asset)
    return asset
end

-- Get the script asset of the specified name.
-- @param assetName (string) The full asset name.
function Asset.GetScript(assetName)
    Daneel.StackTrace.BeginFunction("Asset.GetScript", assetName)
    local errorHead = "Asset.GetScript(assetName) : "

    local argType = type(assetName)
    if argType ~= "string" then
        error(errorHead.."Argument 'assetName' is of type '"..argType.."' with value '"..tostring(assetName).."' instead of 'string'. Must the fully-qualified script name.")
    end

    local asset = Asset.Get(assetName, "Script")
    Daneel.StackTrace.EndFunction("Asset.GetScript", asset)
    return asset
end

-- Get the model asset of the specified name.
-- @param assetName (string) The full asset name.
function Asset.GetModel(assetName)
    Daneel.StackTrace.BeginFunction("Asset.GetModel", assetName)
    local errorHead = "Asset.GetModel(assetName) : "

    local argType = type(assetName)
    if argType ~= "string" then
        error(errorHead.."Argument 'assetName' is of type '"..argType.."' with value '"..tostring(assetName).."' instead of 'string'. Must the fully-qualified model name.")
    end

    local asset = Asset.Get(assetName, "Model")
    Daneel.StackTrace.EndFunction("Asset.GetModel", asset)
    return asset
end

-- Get the ModelAnimation asset of the specified name.
-- @param assetName (string) The full asset name.
function Asset.GetModelAnimation(assetName)
    Daneel.StackTrace.BeginFunction("Asset.GetModelAnimation", assetName)
    local errorHead = "Asset.GetModelAnimation(assetName) : "

    local argType = type(assetName)
    if argType ~= "string" then
        error(errorHead.."Argument 'assetName' is of type '"..argType.."' with value '"..tostring(assetName).."' instead of 'string'. Must the fully-qualified ModelAnimation name.")
    end

    local asset = Asset.Get(assetName, "ModelAnimation")
    Daneel.StackTrace.EndFunction("Asset.GetModelAnimation", asset)
    return asset
end

-- Get the Map asset of the specified name.
-- @param assetName (string) The full asset name.
function Asset.GetMap(assetName)
    Daneel.StackTrace.BeginFunction("Asset.GetMap", assetName)
    local errorHead = "Asset.GetMap(assetName) : "

    local argType = type(assetName)
    if argType ~= "string" then
        error(errorHead.."Argument 'assetName' is of type '"..argType.."' with value '"..tostring(assetName).."' instead of 'string'. Must the fully-qualified map name.")
    end

    local asset = Asset.Get(assetName, "Map")
    Daneel.StackTrace.EndFunction("Asset.GetMap", asset)
    return asset
end

-- Get the TileSet asset of the specified name.
-- @param assetName (string) The full asset name.
function Asset.GetTileSet(assetName)
    Daneel.StackTrace.BeginFunction("Asset.GetTileSet", assetName)
    local errorHead = "Asset.GetTileSet(assetName) : "

    local argType = type(assetName)
    if argType ~= "string" then
        error(errorHead.."Argument 'assetName' is of type '"..argType.."' with value '"..tostring(assetName).."' instead of 'string'. Must the fully-qualified TileSet name.")
    end

    local asset = Asset.Get(assetName, "TileSet")
    Daneel.StackTrace.EndFunction("Asset.GetTileSet", asset)
    return asset
end

-- Get the Scene asset of the specified name.
-- @param assetName (string) The full asset name.
function Asset.GetScene(assetName)
    Daneel.StackTrace.BeginFunction("Asset.GetScene", assetName)
    local errorHead = "Asset.GetScene(assetName) : "

    local argType = type(assetName)
    if argType ~= "string" then
        error(errorHead.."Argument 'assetName' is of type '"..argType.."' with value '"..tostring(assetName).."' instead of 'string'. Must the fully-qualified scene name.")
    end

    local asset = Asset.Get(assetName, "Scene")
    Daneel.StackTrace.EndFunction("Asset.GetScene", asset)
    return asset
end

-- Get the Sound asset of the specified name.
-- @param assetName (string) The full asset name.
function Asset.GetSound(assetName)
    Daneel.StackTrace.BeginFunction("Asset.GetSound", assetName)
    local errorHead = "Asset.GetSound(assetName) : "

    local argType = type(assetName)
    if argType ~= "string" then
        error(errorHead.."Argument 'assetName' is of type '"..argType.."' with value '"..tostring(assetName).."' instead of 'string'. Must the fully-qualified Sound name.")
    end

    local asset = Asset.Get(assetName, "Sound")
    Daneel.StackTrace.EndFunction("Asset.GetSound", asset)
    return asset
end

-- Get the Document asset of the specified name.
-- @param assetName (string) The full asset name.
function Asset.GetDocument(assetName)
    Daneel.StackTrace.BeginFunction("Asset.GetDocument", assetName)
    local errorHead = "Asset.GetDocument(assetName) : "

    local argType = type(assetName)
    if argType ~= "string" then
        error(errorHead.."Argument 'assetName' is of type '"..argType.."' with value '"..tostring(assetName).."' instead of 'string'. Must the fully-qualified Document name.")
    end

    local asset = Asset.Get(assetName, "Document")
    Daneel.StackTrace.EndFunction("Asset.GetDocument", asset)
    return asset
end



-- Tell if the specified asset is of the specified type.
-- @param asset (table) The asset.
-- @param assetType (string) The asset type.
-- @return (boolean) True if the specified asset is of the specified type, false otherwise
function Asset.IsOfType(asset, assetType)
    Daneel.StackTrace.BeginFunction("Asset.IsOfType", asset, assetType)
    local errorHead = "Asset.IsOfType(asset, assetType) : "

    local argType = type(asset)
    if argType ~= "table" then
        error(errorHead.."Argument 'asset' is of type '"..argType.."' with value '"..tostring(asset).."' instead of 'table'. Must the asset.")
    end

    argType = type(assetType)
    if argType ~= "string" then
        error(errorHead.."Argument 'assetType' is of type '"..argType.."' with value '"..tostring(assetType).."' instead of 'string'. Must the asset type.")
    end

    local assetTypes = Daneel.config.assetTypes
    assetType = Daneel.Utilities.CaseProof(assetType, assetTypes)

    if not table.containsvalue(assetTypes, assetType) then
        error(errorHead.."Argument 'assetType' with value '"..assetType.."' is not one of the valid asset types : "..table.concat(assetTypes, ", "))
    end

    local isProvidedAssetType = false

    if asset.inner ~= nil and tostring(asset.inner):find("CraftStudioCommon.ProjectData."..assetType) ~= nil then
        isProvidedAssetType = true
    end

    Daneel.StackTrace.EndFunction("Asset.IsOfType", isProvidedAssetType)
    return isProvidedAssetType
end

-- Tell if the specified asset is of type Script.
-- @param asset (table) The asset.
-- @return (boolean) True if the specified asset is of type Script, false otherwise
function Asset.IsScript(asset)
    Daneel.StackTrace.BeginFunction("Asset.IsScript", asset)
    local errorHead = "Asset.IsScript(asset) : "

    local argType = type(asset)
    if argType ~= "table" then
        error(errorHead.."Argument 'asset' is of type '"..argType.."' with value '"..tostring(asset).."' instead of 'table'. Must the asset.")
    end

    local isAsset = Asset.IsOfType(asset, "Script")
    Daneel.StackTrace.EndFunction("Asset.IsScript", isAsset)
    return isAsset
end

-- Tell if the specified asset is of type Model.
-- @param asset (table) The asset.
-- @return (boolean) True if the specified asset is of type Model, false otherwise
function Asset.IsModel(asset)
    Daneel.StackTrace.BeginFunction("Asset.IsModel", asset)
    local errorHead = "Asset.IsModel(asset) : "

    local argType = type(asset)
    if argType ~= "table" then
        error(errorHead.."Argument 'asset' is of type '"..argType.."' with value '"..tostring(asset).."' instead of 'table'. Must the asset.")
    end

    local isAsset = Asset.IsOfType(asset, "Model")
    Daneel.StackTrace.EndFunction("Asset.IsModel", isAsset)
    return isAsset
end

-- Tell if the specified asset is of type ModelAnimation.
-- @param asset (table) The asset.
-- @return (boolean) True if the specified asset is of type ModelAnimation, false otherwise
function Asset.IsModelAnimation(asset)
    Daneel.StackTrace.BeginFunction("Asset.IsModelAnimation", asset)
    local errorHead = "Asset.IsModelAnimation(asset) : "

    local argType = type(asset)
    if argType ~= "table" then
        error(errorHead.."Argument 'asset' is of type '"..argType.."' with value '"..tostring(asset).."' instead of 'table'. Must the asset.")
    end

    local isAsset = Asset.IsOfType(asset, "ModelAnimation")
    Daneel.StackTrace.EndFunction("Asset.IsModelAnimation", isAsset)
    return isAsset
end

-- Tell if the specified asset is of type Map.
-- @param asset (table) The asset.
-- @return (boolean) True if the specified asset is of type Map, false otherwise
function Asset.IsMap(asset)
    Daneel.StackTrace.BeginFunction("Asset.IsMap", asset)
    local errorHead = "Asset.IsMap(asset) : "

    local argType = type(asset)
    if argType ~= "table" then
        error(errorHead.."Argument 'asset' is of type '"..argType.."' with value '"..tostring(asset).."' instead of 'table'. Must the asset.")
    end

    local isAsset = Asset.IsOfType(asset, "Map")
    Daneel.StackTrace.EndFunction("Asset.IsMap", isAsset)
    return isAsset
end

-- Tell if the specified asset is of type TileSet.
-- @param asset (table) The asset.
-- @return (boolean) True if the specified asset is of type TileSet, false otherwise
function Asset.IsTileSet(asset)
    Daneel.StackTrace.BeginFunction("Asset.IsTileSet", asset)
    local errorHead = "Asset.IsTileSet(asset) : "

    local argType = type(asset)
    if argType ~= "table" then
        error(errorHead.."Argument 'asset' is of type '"..argType.."' with value '"..tostring(asset).."' instead of 'table'. Must the asset.")
    end

    local isAsset = Asset.IsOfType(asset, "TileSet")
    Daneel.StackTrace.EndFunction("Asset.IsTileSet", isAsset)
    return isAsset
end

-- Tell if the specified asset is of type Scene.
-- @param asset (table) The asset.
-- @return (boolean) True if the specified asset is of type Scene, false otherwise
function Asset.IsScene(asset)
    Daneel.StackTrace.BeginFunction("Asset.IsScene", asset)
    local errorHead = "Asset.IsScene(asset) : "

    local argType = type(asset)
    if argType ~= "table" then
        error(errorHead.."Argument 'asset' is of type '"..argType.."' with value '"..tostring(asset).."' instead of 'table'. Must the asset.")
    end

    local isAsset = Asset.IsOfType(asset, "Scene")
    Daneel.StackTrace.EndFunction("Asset.IsScene", isAsset)
    return isAsset
end

-- Tell if the specified asset is of type Sound.
-- @param asset (table) The asset.
-- @return (boolean) True if the specified asset is of type Sound, false otherwise
function Asset.IsSound(asset)
    Daneel.StackTrace.BeginFunction("Asset.IsSound", asset)
    local errorHead = "Asset.IsSound(asset) : "

    local argType = type(asset)
    if argType ~= "table" then
        error(errorHead.."Argument 'asset' is of type '"..argType.."' with value '"..tostring(asset).."' instead of 'table'. Must the asset.")
    end

    local isAsset = Asset.IsOfType(asset, "Sound")
    Daneel.StackTrace.EndFunction("Asset.IsSound", isAsset)
    return isAsset
end

-- Tell if the specified asset is of type Document.
-- @param asset (table) The asset.
-- @return (boolean) True if the specified asset is of type Document, false otherwise
function Asset.IsDocument(asset)
    Daneel.StackTrace.BeginFunction("Asset.IsDocument", asset)
    local errorHead = "Asset.IsDocument(asset) : "

    local argType = type(asset)
    if argType ~= "table" then
        error(errorHead.."Argument 'asset' is of type '"..argType.."' with value '"..tostring(asset).."' instead of 'table'. Must the asset.")
    end

    local isAsset = Asset.IsOfType(asset, "Document")
    Daneel.StackTrace.EndFunction("Asset.IsDocument", isAsset)
    return isAsset
end



-- Return the type of the provided asset
-- @param asset (table) The asset
-- @return (string) The asset type or nil
function Asset.GetType(asset)
    Daneel.StackTrace.BeginFunction("Asset.GetType", asset)
    local errorHead = "Asset.GetType(asset) : "

    local argType = type(asset)
    if argType ~= "table" then
        error(errorHead.."Argument 'asset' is of type '"..argType.."' with value '"..tostring(asset).."' instead of 'table'. Must the asset.")
    end

    local inner = tostring(asset.inner)
    local assetType = nil

    if inner ~= nil then
        for key, _assetType in ipairs(Daneel.config.assetTypes) do
            if inner:find("CraftStudioCommon.ProjectData.".._assetType) ~= nil then
                assetType = _assetType
                break
            end
        end
    end

    Daneel.StackTrace.EndFunction("Asset.GetType", assetType)
    return assetType
end
-- Can also do like in __tostring()