
Asset = {}
Asset.__index = Asset


-- Alias of CraftStudio.FindAsset(assetName, assetType)
-- Get the asset of the specified name and type.
-- @param assetName (string) The fully-qualified asset name.
-- @param assetType [optional] (string, Script, Model, ModelAnimation, Map, TileSet, Scene, Sound, Document) The asset type as a case-insensitive string or the asset object.
function Asset.Get(assetName, assetType)
    Daneel.StackTrace.BeginFunction("Asset.Get", assetName, assetType)
    local errorHead = "Asset.Get(assetName[, assetType]) : "
    Daneel.Debug.CheckArgType(assetName, "assetName", "string", errorHead)

    local assets = Daneel.config.assetObjects
    local assetTypes = table.getKeys(assets)
    Daneel.Debug.CheckOptionalArgType(assetType, "assetType", {"string", unpack(assetTypes)}, errorHead)
    
    if assetType ~= nil then
        if type(assetType) ~= "string" then
            for _assetType, assetObject in pairs(assets) do
                if assetType == assetObject then
                    assetType = _assetType
                end
            end
        else
            assetType = Daneel.Utilities.CaseProof(assetType, assetTypes)
        end

        if not assetType:isoneof(assetTypes) then
            Daneel.Debug.PrintError(errorHead.."Argument 'assetType' with value '"..assetType.."' is not one of the valid asset types : "..table.concat(assetTypes, ", "))
        end
    end

    local asset = CraftStudio.FindAsset(assetName, assetType)
    Daneel.StackTrace.EndFunction("Asset.Get", asset)
    return asset
end


-- Tell if the specified asset is of the specified type.
-- @param asset (table) The asset.
-- @param assetType (string, Script, Model, ModelAnimation, Map, TileSet, Scene, Sound, Document) The asset type as a case-insensitive string or the asset object.
-- @return (boolean) True if the specified asset is of the specified type, false otherwise
function Asset.IsOfType(asset, assetType)
    Daneel.StackTrace.BeginFunction("Asset.IsOfType", asset, assetType)
    local errorHead = "Asset.IsOfType(asset, assetType) : "
    Daneel.Debug.CheckArgType(asset, "asset", Daneel.config.assetTypes, errorHead)
    Daneel.Debug.CheckArgType(assetType, "assetType", "string", errorHead)

    local assetTypes = Daneel.config.assetTypes
    assetType = Daneel.Utilities.CaseProof(assetType, assetTypes)

    if not assetType:isoneof(assetTypes) then
        Daneel.Debug.PrintError(errorHead.."Argument 'assetType' with value '"..assetType.."' is not one of the valid asset types : "..table.concat(assetTypes, ", "))
    end

    local isProvidedAssetType = (Daneel.Debug.GetType(asset) == assetType)
    Daneel.StackTrace.EndFunction("Asset.IsOfType", isProvidedAssetType)
    return isProvidedAssetType
end


-- Return the type of the provided asset
-- @param asset (Script, Model, ModelAnimation, Map, TileSet, Scene, Sound, Document) The asset
-- @return (string) The asset type or nil
function Asset.GetType(asset)
    Daneel.StackTrace.BeginFunction("Asset.GetType", asset)
    local errorHead = "Asset.GetType(asset) : "
    Daneel.Debug.CheckArgType(asset, "asset", Daneel.config.assetTypes, errorHead)

    local assetType = Daneel.Debug.GetType(asset)
    Daneel.StackTrace.EndFunction("Asset.GetType", assetType)
    return assetType
end



----------------------------------------------------------------------------------

-- Called from Daneel.Awake()
function Asset.Init()
    for assetType, object in pairs(Daneel.config.assetObjects) do
        
        setmetatable(object, Asset)

        -- Get helpers
        -- GetModelRenderer() ...
        Asset["Get"..assetType] = function(assetName)
            Daneel.StackTrace.BeginFunction("Asset.Get"..assetType, assetName)
            local errorHead = "Asset.Get"..assetType.."(assetName) : "

            local argType = type(assetName)
            if argType ~= "string" then
                error(errorHead.."Argument 'assetName' is of type '"..argType.."' with value '"..tostring(assetName).."' instead of 'string'. Must the fully-qualified "..type.." name.")
            end

            local asset = Asset.Get(assetName, assetType)
            Daneel.StackTrace.EndFunction("Asset.Get"..assetType, asset)
            return asset
        end

        -- IsOfType helper   -- not much usefull actually
        -- IsModelRenderer() ...
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


        -- Dynamic Getters   -- is this usefull ??
        object["__index"] = function(t, key) 
            local funcName = "Get"..key:ucfirst()
            
            if object[funcName] ~= nil then
                return object[funcName](t)
            elseif object[key] ~= nil then
                return object[key] -- have to return the function here, not the function return value !
            end
            
            return rawget(t, key)
        end

        -- Dynamic Setters
        object["__newindex"] = function(t, key, value)
            local funcName = "Set"..key:ucfirst()
            
            if object[funcName] ~= nil then
                return object[funcName](t, value)
            end
            
            return rawset(t, key, value)
        end

        -- tostring
        object["__tostring"] = function(asset)
            -- this has the advantage to return the asset ID that follows the asset Type
            -- ie : "Model: 123456789"
            -- asset.inner is "CraftStudioCommon.ProjectData.[AssetType]: [some ID]"
            -- CraftStudioCommon.ProjectData. is 30 characters long
            return tostring(asset.inner):sub(31, 60)
        end
        
    end
end
