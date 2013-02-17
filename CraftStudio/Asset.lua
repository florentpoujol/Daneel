
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


-- Create function Asset.Get[AssetType](asset)
-- ie : Asset.GetScript(name) Asset.GetModel(name)
function Asset.CreateGetHelpers()
    local assetTypes = Daneel.config.assetTypes

    for i, assetType in ipairs(assetTypes) do

        Asset["Get"..assetType] = function(assetName)
            Daneel.StackTrace.BeginFunction("Asset.Get"..assetType, assetName)
            local errorHead = "Asset.Get"..assetType.."(assetName) : "

            local argType = type(assetName)
            if argType ~= "string" then
                error(errorHead.."Argument 'assetName' is of type '"..argType.."' with value '"..tostring(assetName).."' instead of 'string'. Must the fully-qualified "..assetType.." name.")
            end

            local asset = Asset.Get(assetName, assetType)
            Daneel.StackTrace.EndFunction("Asset.Get"..assetType, asset)
            return asset
        end

    end
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


-- Create function Asset.Is[AssetType](asset)
-- ie : Asset.IsScript(asset) Asset.IsModel(asset)
function Asset.CreateIsOfTypeHelpers()
    local assetTypes = Daneel.config.assetTypes

    for i, assetType in ipairs(assetTypes) do

        Asset["Is"..assetType] = function(asset)
            Daneel.StackTrace.BeginFunction("Asset.Is"..assetType, asset)
            local errorHead = "Asset.Is"..assetType.."(asset) : "

            local argType = type(asset)
            if argType ~= "table" then
                error(errorHead.."Argument 'asset' is of type '"..argType.."' with value '"..tostring(asset).."' instead of 'table'. Must the asset.")
            end

            local isAsset = Asset.IsOfType(asset, assetType)
            Daneel.StackTrace.EndFunction("Asset.Is"..assetType, isAsset)
            return isAsset
        end

    end
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
