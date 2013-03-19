
----------------------------------------------------------------------------------
-- Assets


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
            return tostring(asset.inner):sub(31, 60)
        end
        
    end
end



----------------------------------------------------------------------------------
-- Components


Component = {}
Component.__index = Component


function Component.Init()
    local components = Daneel.config.componentObjects
    for componentType, object in pairs(components) do
        if componentType ~= "ScriptedBehavior" then
            -- Dynamic Getters
            object["__index"] = function(component, key) 
                local funcName = "Get"..key:ucfirst()
                
                if object[funcName] ~= nil then
                    return object[funcName](component)
                elseif object[key] ~= nil then
                    return object[key] -- have to return the function here, not the function return value !
                end

                if Component[funcName] ~= nil then
                    return Component[funcName](component)
                elseif Component[key] ~= nil then
                    return Component[key] -- have to return the function here, not the function return value !
                end
                
                return nil
            end

            -- Dynamic Setters
            object["__newindex"] = function(component, key, value)
                local funcName = "Set"..key:ucfirst()
                
                if object[funcName] ~= nil then
                    return object[funcName](component, value)
                end
                
                return rawset(component, key, value)
            end
        end

        object["__tostring"] = function(component)
            -- returns something like "ModelRenderer: 123456789"
            -- component.inner is "?: [some ID]"
            return Daneel.Debug.GetType(component)..tostring(component.inner):sub(2, 20) -- leave 2 as the starting index, only the transform ahave an extra space
        end
    end

    -- Dynamic getters and setter on Scripts
    for i, path in pairs(Daneel.config.scripts) do
        local script = Asset.Get(path, "Script")

        if script ~= nil then
            -- Dynamic getters
            function script.__index(scriptedBehavior, key)
                local funcName = "Get"..key:ucfirst()
                              
                if script[funcName] ~= nil then
                    return script[funcName](scriptedBehavior)
                elseif script[key] ~= nil then
                    return script[key]
                end

                if Script[funcName] ~= nil then
                    return Script[funcName](scriptedBehavior)
                elseif Script[key] ~= nil then
                    return Script[key]
                end

                if Component[funcName] ~= nil then
                    return Component[funcName](scriptedBehavior)
                elseif Component[key] ~= nil then
                    return Component[key]
                end
                
                return nil
            end

            -- Dynamic setters
            function script.__newindex(scriptedBehavior, key, value)
                local funcName = "Set"..key:ucfirst()
                              
                if script[funcName] ~= nil then
                    return script[funcName](scriptedBehavior, value)
                end
                
                return rawset(scriptedBehavior, key, value)
            end
        else
            print("WARNING : item with key '"..i.."' and value '"..path.."' in Daneel.config.scripts is not a valid script path.")
        end
    end
end

--- Apply the content of the params argument to the component in argument.
-- @param component (Scriptedbehavior, ModelRenderer, MapRenderer, Camera or Transform) The component.
-- @param params (table) A table of parameters to set the component with.
function Component.Set(component, params)
    Daneel.Debug.StackTrace.BeginFunction("Component.Set", component, params)
    local errorHead = "Component.Set(component, params) : "
    Daneel.Debug.CheckArgType(component, "component", Daneel.config.componentTypes, errorHead)
    Daneel.Debug.CheckArgType(params, "params", "table", errorHead)

    for key, value in pairs(params) do
        component[key] = value
    end

    Daneel.Debug.StackTrace.EndFunction("Component.Set", component)
end

--- Destory the provided component, removing it from the gameObject.
-- @param component (ScriptedBehavior, ModelRenderer, MapRenderer, Camera or Transform) The component.
function Component.Destroy(component)
    Daneel.Debug.StackTrace.BeginFunction("Component.Destroy", component)
    local errorHead = "Component.Destroy(component) : "
    Daneel.Debug.CheckArgType(component, "component", Daneel.config.componentTypes, errorHead)
    CraftStudio.Destroy(component)
    Daneel.Debug.StackTrace.EndFunction("Component.Destroy")
end



----------------------------------------------------------------------------------
-- ModelRenderer


local OriginalSetModel = ModelRenderer.SetModel

--- Attach the provided model to the provided modelRenderer.
-- @param modelRenderer (ModelRenderer) The modelRenderer.
-- @param modelNameOrAsset (string or Model) The model name or asset.
function ModelRenderer.SetModel(modelRenderer, modelNameOrAsset)
    Daneel.Debug.StackTrace.BeginFunction("ModelRenderer.SetModel", modelRenderer, modelNameOrAsset)
    local errorHead = "ModelRenderer.SetModel(modelRenderer, modelNameOrAsset) : "
    Daneel.Debug.CheckArgType(modelRenderer, "modelRenderer", "ModelRenderer", errorHead)
    Daneel.Debug.CheckArgType(modelNameOrAsset, "modelNameOrAsset", {"string", "Model"}, errorHead)

    local model = modelNameOrAsset
    if type(modelNameOrAsset) == "string" then
        model = Asset.Get(modelNameOrAsset, "Model")
        if model == nil then
            Daneel.Debug.PrintError(errorHead.."Argument 'modelNameOrAsset' : model with name '"..modelNameOrAsset.."' was not found.")
        end
    end

    OriginalSetModel(modelRenderer, model)
    Daneel.Debug.StackTrace.EndFunction("ModelRenderer.SetModel")
end

local OriginalSetAnimation = ModelRenderer.SetAnimation

--- Set the specified animation for the modelRenderer's current model
-- @param modelRenderer (ModelRenderer) The modelRenderer.
-- @param animationNameOrAsset (string or ModelAnimation) The animation name or asset
function ModelRenderer.SetAnimation(modelRenderer, animationNameOrAsset)
    Daneel.Debug.StackTrace.BeginFunction("ModelRenderer.SetModelAnimation", modelRenderer, animationNameOrAsset)
    local errorHead = "ModelRenderer.SetModelAnimation(modelRenderer, animationNameOrAsset) : "
    Daneel.Debug.CheckArgType(modelRenderer, "modelRenderer", "ModelRenderer", errorHead)
    Daneel.Debug.CheckArgType(animationNameOrAsset, "animationNameOrAsset", {"string", "ModelAnimation"}, errorHead)

    local animation = animationNameOrAsset
    if type(animationNameOrAsset) == "string" then
        animation = Asset.Get(animationNameOrAsset, "ModelAnimation")
        if animation == nil then
            Daneel.Debug.PrintError(errorHead.."Argument 'animationNameOrAsset' : animation with name '"..animationNameOrAsset.."' was not found.")
        end
    end

    OriginalSetModelAnimation(modelRenderer, animation)
    Daneel.Debug.StackTrace.EndFunction("ModelRenderer.SetModelAnimation")
end



----------------------------------------------------------------------------------
-- MapRenderer


local OriginalSetMap = MapRenderer.SetMap

--- Attach the provided map to the provided mapRenderer.
-- @param mapRenderer (MapRenderer) The mapRenderer.
-- @param mapNameOrAsset (string or Map) The map name or asset.
-- @param keepTileSet [optional default=false] (boolean) Keep the currect TileSet
function MapRenderer.SetMap(mapRenderer, mapNameOrAsset, keepTileSet)
    Daneel.Debug.StackTrace.BeginFunction("MapRenderer.SetMap", mapRenderer, mapNameOrAsset)
    local errorHead = "MapRenderer.SetMap(mapRenderer, mapNameOrAsset) : "
    Daneel.Debug.CheckArgType(mapRenderer, "mapRenderer", "MapRenderer", errorHead)
    Daneel.Debug.CheckArgType(mapNameOrAsset, "mapNameOrAsset", {"string", "Map"}, errorHead)
    Daneel.Debug.CheckOptionalArgType(keepTileSet, "keepTileSet", "boolean", errorHead)
 
    local map = mapNameOrAsset
    if type(mapNameOrAsset) == "string" then
        map = Asset.Get(mapNameOrAsset, "Map")
        if map == nil then
            Daneel.Debug.PrintError(errorHead.."Argument 'mapNameOrAsset' : map with name '"..mapNameOrAsset.."' was not found.")
        end
    end

    OriginalSetMap(mapRenderer, map, keepTileSet)
    Daneel.Debug.StackTrace.EndFunction("MapRenderer.SetMap")
end

local OriginalSetTileSet = MapRenderer.SetTileSet

--- Set the specified tileSet for the mapRenderer's map
-- @param mapRenderer (MapRenderer) The mapRenderer.
-- @param tileSetNameOrAsset (string or TileSet) The tileSet name or asset
function MapRenderer.SetTileSet(mapRenderer, tileSetNameOrAsset)
    Daneel.Debug.StackTrace.BeginFunction("MapRenderer.SetTileSet", mapRenderer, tileSetNameOrAsset)
    local errorHead = "MapRenderer.SetTileSet(mapRenderer, tileSetNameOrAsset) : "
    Daneel.Debug.CheckArgType(mapRenderer, "mapRenderer", "MapRenderer", errorHead)
    Daneel.Debug.CheckArgType(tileSetNameOrAsset, "tileSetNameOrAsset", {"string", "TileSet"}, errorHead)

    local tileSet = tileSetNameOrAsset
    if type(tileSetNameOrAsset) == "string" then
        tileSet = Asset.Get(tileSetNameOrAsset, "TileSet")
        if tileSet == nil then
            Daneel.Debug.PrintError(errorHead.."Argument 'tileSetNameOrAsset' : tileSet with name '"..tileSetNameOrAsset.."' was not found.")
        end
    end

    OriginalSetTileSet(mapRenderer, tileSet)
    Daneel.Debug.StackTrace.EndFunction("MapRenderer.SetTileSet")
end



----------------------------------------------------------------------------------
-- Ray


--- Check the collision of the ray against all castable gameObject or against the provided set of gameObject.
-- @param ray (Ray) The ray.
-- @param gameObjects (table) [optional default=Daneel.config.castableGameObjects] The set of gameObjects to cast the ray against (or if empty, the castable gameObjects)!;
-- @return (table) The table of RaycastHits (will be empty if the ray didn't intersects anything).
function Ray.Cast(ray, gameObjects)
    Daneel.Debug.StackTrace.BeginFunction("Ray.Cast", ray, gameObjects)
    local errorHead = "Ray.Cast(ray) : "
    Daneel.Debug.CheckArgType(ray, "ray", "Ray", errorHead)

    if gameObjects == nil then
        gameObjects = Daneel.config.castableGameObjects
    else
        Daneel.Debug.CheckArgType(gameObjects, "gameObjects", "table", errorHead)
    end

    local hits = table.new()

    for i, gameObject in ipairs(gameObjects) do
        local distance, normal, hitBlockLocation, adjacentBlockLocation = ray:IntersectsGameObject(gameObject)

        if distance ~= nil then
            hits:insert(RaycastHit.New(distance, normal, hitBlockLocation, adjacentBlockLocation, gameObject))
        end
    end

    Daneel.Debug.StackTrace.EndFunction("Ray.Cast", hits)
    return hits
end


--- Check if the ray intersect the specified gameObject.
-- @param ray (Ray) The ray.
-- @param gameObject (string, GameObject) The gameObject instance or name.
-- @return
function Ray.IntersectsGameObject(ray, gameObject)
    Daneel.Debug.StackTrace.BeginFunction("Ray.IntersectsGameObject", ray, gameObject)
    local errorHead = "Ray.IntersectsGameObject(ray, gameObject) : "
    Daneel.Debug.CheckArgType(ray, "ray", "Ray", errorHead)
    Daneel.Debug.CheckArgType(gameObject, "gameObject", {"string", "GameObject"}, errorHead)

    if type(gameObject) == "string" then
        local name = gameObject
        gameObject = GameObject.Get(name)
        if gameObject == nil then
            Daneel.Debug.PrintError(errorHead.."Argument 'gameObject' : gameObject with name '"..name.."' was not found.")
        end
    end

    local component = gameObject:GetComponent("ModelRenderer")
    if component ~= nil then
        local distance, normal = ray:IntersectsModelRenderer(component)
        if distance ~= nil then
            Daneel.Debug.StackTrace.EndFunction("Ray.IntersectsGameObject", distance, normal)
            return distance, normal
        end
    end

    component = gameObject:GetComponent("MapRenderer")
    if component ~= nil then
        local distance, normal, hitBlockLocation, adjacentBlockLocation = ray:IntersectsMapRenderer(component)
        if distance ~= nil then
            Daneel.Debug.StackTrace.EndFunction("Ray.IntersectsGameObject", distance, normal, hitBlockLocation, adjacentBlockLocation)
            return distance, normal, hitBlockLocation, adjacentBlockLocation
        end
    end

    Daneel.Debug.StackTrace.EndFunction("Ray.IntersectsGameObject")
end



----------------------------------------------------------------------------------
-- RaycastHit
-- keys : distance, normal, hitBlockLocation, adjacentBlockLocation, gameObject, component


RaycastHit = {}
RaycastHit.__index = RaycastHit

function RaycastHit.__tostring() 
    return "RaycastHit"
end

function RaycastHit.New(distance, normal, hitBlockLocation, adjacentBlockLocation, gameObject)
    Daneel.Debug.StackTrace.BeginFunction("RaycastHit.New", distance, normal, hitBlockLocation, adjacentBlockLocation, gameObject)

    local raycastHit = {
        distance = distance,
        normal = normal,
        hitBlockLocation = hitBlockLocation,
        adjacentBlockLocation = adjacentBlockLocation,
        gameObject = gameObject,
    }
    setmetatable(raycastHit, RaycastHit)

    if raycastHit.hitBlockLocation ~= nil then
        raycastHit.component = "MapRenderer"
    else
        raycastHit.component = "ModelRenderer"
    end

    Daneel.Debug.StackTrace.EndFunction("RaycastHit.New", raycastHit)
    return raycastHit
end



----------------------------------------------------------------------------------
-- Scene


--- Alias of CraftStudio.LoadScene().
-- Schedules loading the specified scene after the current tick (1/60th of a second) has completed.
-- When the new scene is loaded, all of the current scene's game objects will be removed.
-- Calling this function doesn't immediately stops the calling function. As such, you might want to add a return statement afterwards. 
-- @param sceneNameOrAsset (string or Scene) The scene name or asset
function Scene.Load(sceneNameOrAsset)
    Daneel.Debug.StackTrace.BeginFunction("Scene.Load", sceneNameOrAsset)
    local errorHead = "Scene.Load(sceneNameOrAsset) : "
    Daneel.Debug.CheckArgType(sceneNameOrAsset, "sceneNameOrAsset", {"string", "Scene"}, errorHead)

    local scene = sceneNameOrAsset
    if type(sceneNameOrAsset) == "string" then
        scene = Asset.Get(sceneNameOrAsset, "Scene")
        if scene == nil then
            Daneel.Debug.PrintError(errorHead.."Argument 'sceneNameOrAsset' : scene with name '"..sceneNameOrAsset.."' was not found.")
        end
    end

    CraftStudio.LoadScene(scene)
    Daneel.Debug.StackTrace.EndFunction("Scene.Load")
end
