
Asset = {}
Asset.__index = Asset


--- Alias of CraftStudio.FindAsset(assetName[, assetType])
-- Get the asset of the specified name and type.
-- @param assetName (string) The fully-qualified asset name.
-- @param assetType [optional] (string, Script, Model, ModelAnimation, Map, TileSet, Scene or Sound) The asset type as a case-insensitive string or the asset object.
-- @return (Script, Model, ModelAnimation, Map, TileSet, Scene or Sound) The asset, or nil if none is found
function Asset.Get(assetName, assetType)
    Daneel.Debug.StackTrace.BeginFunction("Asset.Get", assetName, assetType)
    local errorHead = "Asset.Get(assetName[, assetType]) : "
    Daneel.Debug.CheckArgType(assetName, "assetName", "string", errorHead)

    if assetType ~= nil then
        assetType = Daneel.Debug.CheckAssetType(assetType)
    end

    local asset = CraftStudio.FindAsset(assetName, assetType)
    Daneel.Debug.StackTrace.EndFunction("Asset.Get", asset)
    return asset
end

-- Get helpers are generated in Asset.Init() below

--- Get the Script asset of the specified name
-- @param assetName (string) The fully-qualified asset name.
-- @return (Script) The asset, or nil if none is found
function Asset.GetScript(assetName) end

--- Get the Model asset of the specified name
-- @param assetName (string) The fully-qualified asset name.
-- @return (Model) The asset, or nil if none is found
function Asset.GetModel(assetName) end

--- Get the ModelAnimation asset of the specified name
-- @param assetName (string) The fully-qualified asset name.
-- @return (ModelAnimation) The asset, or nil if none is found
function Asset.GetModelAnimation(assetName) end

--- Get the Map asset of the specified name
-- @param assetName (string) The fully-qualified asset name.
-- @return (Map) The asset, or nil if none is found
function Asset.GetMap(assetName) end

--- Get the TileSet asset of the specified name
-- @param assetName (string) The fully-qualified asset name.
-- @return (TileSet) The asset, or nil if none is found
function Asset.GetTileSet(assetName) end

--- Get the Scene asset of the specified name
-- @param assetName (string) The fully-qualified asset name.
-- @return (Scene) The asset, or nil if none is found
function Asset.GetScene(assetName) end

--- Get the Sound asset of the specified name
-- @param assetName (string) The fully-qualified asset name.
-- @return (Sound) The asset, or nil if none is found
function Asset.GetSound(assetName) end

--- Get the Document asset of the specified name
-- @param assetName (string) The fully-qualified asset name.
-- @return (Document) The asset, or nil if none is found
function Asset.GetDocument(assetName) end



----------------------------------------------------------------------------------

-- Called from Daneel.Awake()
function Asset.Init()
    for assetType, object in pairs(Daneel.config.assetObjects) do
        
        -- Get helpers
        -- GetModelRenderer() ...
        Asset["Get"..assetType] = function(assetName)
            Daneel.Debug.StackTrace.BeginFunction("Asset.Get"..assetType, assetName)
            local errorHead = "Asset.Get"..assetType.."(assetName) : "
            Daneel.Debug.CheckArgType(assetName, "assetName", "string", errorHead)
            local asset = Asset.Get(assetName, assetType)
            Daneel.Debug.StackTrace.EndFunction("Asset.Get"..assetType, asset)
            return asset
        end

        -- tostring
        object["__tostring"] = function(asset)
            -- print something like : "Model: 123456789 - table: 0512A528"
            -- asset.inner is "CraftStudioCommon.ProjectData.[AssetType]: [some ID]"
            -- CraftStudioCommon.ProjectData. is 30 characters long
            return tostring(asset.inner):sub(31, 60).." - ".. tostring(asset)
        end
        
    end
end
