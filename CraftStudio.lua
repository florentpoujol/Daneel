
----------------------------------------------------------------------------------
-- Assets

Asset = {}
Asset.__index = Asset

--- Alias of CraftStudio.FindAsset(assetName[, assetType]).
-- Get the asset of the specified name and type.
-- The first argument may be an asset object, so that you can check if a variable was an asset object or name (and get the corresponding object).
-- @param assetName (string or one of the asset types) The fully-qualified asset name or asset object.
-- @param assetType [optional] (string) The asset type as a case-insensitive string or the asset object.
-- @param errorIfAssetNotFound [optional default=false] Throw an error if the asset was not found (instead of returning nil).
-- @return (Script, Model, ModelAnimation, Map, TileSet, Scene, Sound or Font) The asset, or nil if none is found.
function Asset.Get(assetName, assetType, errorIfAssetNotFound)
    Daneel.Debug.StackTrace.BeginFunction("Asset.Get", assetName, assetType, errorIfAssetNotFound)
    local errorHead = "Asset.Get(assetName[, assetType, errorIfAssetNotFound]) : "
    -- just return the asset if assetName is already an object
    if type(assetName) == "table" and Daneel.Debug.GetType(assetName):isoneof(config.assetTypes) then
        Daneel.Debug.StackTrace.EndFunction()
        return assetName
    end
    Daneel.Debug.CheckArgType(assetName, "assetName", "string", errorHead)
    if assetType ~= nil then
        assetType = Daneel.Debug.CheckAssetType(assetType)
    end
    Daneel.Debug.CheckOptionalArgType(errorIfAssetNotFound, "errorIfAssetNotFound", "boolean", errorHead)

    if assetType == "Script" and config.scriptPaths[assetName] ~= nil then
        assetName = config.scriptPaths[assetName]
    end
    local asset = CraftStudio.FindAsset(assetName, assetType)
    if asset == nil and errorIfAssetNotFound == true then
        if assetType == nil then
            assetType = "asset"
        end
        error(errorHead.."Argument 'assetName' : "..assetType.." with name '"..assetName.."' was not found.")
    end
    Daneel.Debug.StackTrace.EndFunction()
    return asset
end

--- Get the Script asset with the specified name.
-- @param assetName (string) The fully-qualified asset name.
-- @return (Script) The asset, or nil if none is found.
function Asset.GetScript(assetName) end

--- Get the Model asset with the specified name.
-- @param assetName (string) The fully-qualified asset name.
-- @return (Model) The asset, or nil if none is found.
function Asset.GetModel(assetName) end

--- Get the ModelAnimation asset with the specified name.
-- @param assetName (string) The fully-qualified asset name.
-- @return (ModelAnimation) The asset, or nil if none is found.
function Asset.GetModelAnimation(assetName) end

--- Get the Map asset with the specified name
-- @param assetName (string) The fully-qualified asset name.
-- @return (Map) The asset, or nil if none is found.
function Asset.GetMap(assetName) end

--- Get the TileSet asset with the specified name
-- @param assetName (string) The fully-qualified asset name.
-- @return (TileSet) The asset, or nil if none is found.
function Asset.GetTileSet(assetName) end

--- Get the Scene asset with the specified name.
-- @param assetName (string) The fully-qualified asset name.
-- @return (Scene) The asset, or nil if none is found.
function Asset.GetScene(assetName) end

--- Get the Sound asset with the specified name.
-- @param assetName (string) The fully-qualified asset name.
-- @return (Sound) The asset, or nil if none is found.
function Asset.GetSound(assetName) end

--- Get the Font asset with the specified name.
-- @param assetName (string) The fully-qualified asset name.
-- @return (Font) The asset, or nil if none is found.
function Asset.GetFont(assetName) end


----------------------------------------------------------------------------------
-- Components

Component = {}
Component.__index = Component

--- Apply the content of the params argument to the provided component.
-- @param component (Scriptedbehavior, ModelRenderer, MapRenderer, Camera, Transform or Physics) The component.
-- @param params (table) A table of parameters to set the component with.
function Component.Set(component, params)
    Daneel.Debug.StackTrace.BeginFunction("Component.Set", component, params)
    local errorHead = "Component.Set(component, params) : "
    Daneel.Debug.CheckArgType(component, "component", config.componentTypes, errorHead)
    Daneel.Debug.CheckArgType(params, "params", "table", errorHead)

    local componentType = Daneel.Debug.GetType(component)
    if componentType == "ProgressBar" then
        local progress = params.progress
        params.progress = nil
        if progress == nil then
            progress = component.progress
        end
        for key, value in pairs(params) do
            component[key] = value
        end
        component.progress = progress
    else
        for key, value in pairs(params) do
            component[key] = value
        end
    end
    Daneel.Debug.StackTrace.EndFunction()
end

--- Destroy the provided component, removing it from the gameObject.
-- Note that the component is removed only at the end of the current frame.
-- @param component (ScriptedBehavior, ModelRenderer, MapRenderer, Camera, Transform or Physics) The component.
function Component.Destroy(component)
    Daneel.Debug.StackTrace.BeginFunction("Component.Destroy", component)
    local errorHead = "Component.Destroy(component) : "
    Daneel.Debug.CheckArgType(component, "component", config.componentTypes, errorHead)
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

    local model = Asset.Get(modelNameOrAsset, "Model", true)
    OriginalSetModel(modelRenderer, model)
    Daneel.Debug.StackTrace.EndFunction("ModelRenderer.SetModel")
end

local OriginalSetAnimation = ModelRenderer.SetAnimation

--- Set the specified animation for the modelRenderer's current model.
-- @param modelRenderer (ModelRenderer) The modelRenderer.
-- @param animationNameOrAsset (string or ModelAnimation) The animation name or asset.
function ModelRenderer.SetAnimation(modelRenderer, animationNameOrAsset)
    Daneel.Debug.StackTrace.BeginFunction("ModelRenderer.SetModelAnimation", modelRenderer, animationNameOrAsset)
    local errorHead = "ModelRenderer.SetModelAnimation(modelRenderer, animationNameOrAsset) : "
    Daneel.Debug.CheckArgType(modelRenderer, "modelRenderer", "ModelRenderer", errorHead)
    Daneel.Debug.CheckArgType(animationNameOrAsset, "animationNameOrAsset", {"string", "ModelAnimation"}, errorHead)

    local animation = Asset.Get(animationNameOrAsset, "ModelAnimation", true)
    OriginalSetAnimation(modelRenderer, animation)
    Daneel.Debug.StackTrace.EndFunction("ModelRenderer.SetModelAnimation")
end


----------------------------------------------------------------------------------
-- MapRenderer

local OriginalSetMap = MapRenderer.SetMap

--- Attach the provided map to the provided mapRenderer.
-- @param mapRenderer (MapRenderer) The mapRenderer.
-- @param mapNameOrAsset (string or Map) The map name or asset.
-- @param keepTileSet [optional default=false] (boolean) Keep the current TileSet.
function MapRenderer.SetMap(mapRenderer, mapNameOrAsset, keepTileSet)
    Daneel.Debug.StackTrace.BeginFunction("MapRenderer.SetMap", mapRenderer, mapNameOrAsset)
    local errorHead = "MapRenderer.SetMap(mapRenderer, mapNameOrAsset) : "
    Daneel.Debug.CheckArgType(mapRenderer, "mapRenderer", "MapRenderer", errorHead)
    Daneel.Debug.CheckArgType(mapNameOrAsset, "mapNameOrAsset", {"string", "Map"}, errorHead)
    Daneel.Debug.CheckOptionalArgType(keepTileSet, "keepTileSet", "boolean", errorHead)

    local map = Asset.Get(mapNameOrAsset, "Map", true)
    if keepTileSet == true then
        OriginalSetMap(mapRenderer, map, true)
    else
        OriginalSetMap(mapRenderer, map)
    end
    Daneel.Debug.StackTrace.EndFunction("MapRenderer.SetMap")
end

local OriginalSetTileSet = MapRenderer.SetTileSet

--- Set the specified tileSet for the mapRenderer's map.
-- @param mapRenderer (MapRenderer) The mapRenderer.
-- @param tileSetNameOrAsset (string or TileSet) The tileSet name or asset.
function MapRenderer.SetTileSet(mapRenderer, tileSetNameOrAsset)
    Daneel.Debug.StackTrace.BeginFunction("MapRenderer.SetTileSet", mapRenderer, tileSetNameOrAsset)
    local errorHead = "MapRenderer.SetTileSet(mapRenderer, tileSetNameOrAsset) : "
    Daneel.Debug.CheckArgType(mapRenderer, "mapRenderer", "MapRenderer", errorHead)
    Daneel.Debug.CheckArgType(tileSetNameOrAsset, "tileSetNameOrAsset", {"string", "TileSet"}, errorHead)

    local tileSet = Asset.Get(tileSetNameOrAsset, "TileSet", true)
    OriginalSetTileSet(mapRenderer, tileSet)
    Daneel.Debug.StackTrace.EndFunction("MapRenderer.SetTileSet")
end


----------------------------------------------------------------------------------
-- TextRenderer
--[[
local OriginalSetFont = TextRenderer.SetFont

--- Set the specified font for the textRenderer.
-- @param textRenderer (TextRenderer) The textRenderer.
-- @param fontNameOrAsset (string or Font) The font name or asset
function TextRenderer.SetFont(textRenderer, fontNameOrAsset)
    Daneel.Debug.StackTrace.BeginFunction("TextRenderer.SetFont", textRenderer, fontNameOrAsset)
    local errorHead = "TextRenderer.SetFont(textRenderer, fontNameOrAsset) : "
    Daneel.Debug.CheckArgType(textRenderer, "textRenderer", "TextRenderer", errorHead)
    Daneel.Debug.CheckArgType(fontNameOrAsset, "fontNameOrAsset", {"string", "Font"}, errorHead)

    local font = Asset.Get(fontNameOrAsset, "Font", true)
    OriginalSetFont(textRenderer, font)
    Daneel.Debug.StackTrace.EndFunction("TextRenderer.SetFont")
end
]]

----------------------------------------------------------------------------------
-- Ray

setmetatable(Ray, { __call = function(Object, ...) return Object:New(...) end })

--- Check the collision of the ray against the provided set of gameObject or if it is nil, against all castable gameObjects.
-- @param ray (Ray) The ray.
-- @param gameObjects (table) The set of gameObjects to cast the ray against.
-- @param sortByDistance [optional default=false] (boolean) Sort the raycastHit by increasing distance in the returned table.
-- @return (table) A table of RaycastHits (will be empty if the ray didn't intersects anything).
function Ray.Cast(ray, gameObjects, sortByDistance)
    Daneel.Debug.StackTrace.BeginFunction("Ray.Cast", ray, gameObjects, sortByDistance)
    local errorHead = "Ray.Cast(ray, gameObjects[, sortByDistance]) : "
    Daneel.Debug.CheckArgType(ray, "ray", "Ray", errorHead)
    Daneel.Debug.CheckArgType(gameObjects, "gameObjects", "table", errorHead)
    Daneel.Debug.CheckOptionalArgType(sortByDistance, "sortByDistance", "boolean", errorHead)
    
    local hits = table.new()
    for i, gameObject in ipairs(gameObjects) do
        local raycastHit = ray:IntersectsGameObject(gameObject)
        if raycastHit ~= nil then
            table.insert(hits, raycastHit)
        end
    end
    if sortByDistance == true then
        hits = table.sortby(hits, "distance")
    end

    Daneel.Debug.StackTrace.EndFunction()
    return hits
end

--- Check if the ray intersect the specified gameObject.
-- @param ray (Ray) The ray.
-- @param gameObjectNameOrInstance (string or GameObject) The gameObject instance or name.
-- @return (RaycastHit) A raycastHit if there was a collision, or nil.
function Ray.IntersectsGameObject(ray, gameObjectNameOrInstance)
    Daneel.Debug.StackTrace.BeginFunction("Ray.IntersectsGameObject", ray, gameObjectNameOrInstance)
    local errorHead = "Ray.IntersectsGameObject(ray, gameObjectNameOrInstance) : "
    Daneel.Debug.CheckArgType(ray, "ray", "Ray", errorHead)
    Daneel.Debug.CheckArgType(gameObjectNameOrInstance, "gameObjectNameOrInstance", {"string", "GameObject"}, errorHead)
    
    local gameObject = GameObject.Get(gameObjectNameOrInstance, true)
    local distance = nil
    local normal = nil
    local hitBlockLocation = nil
    local adjacentBlockLocation = nil
    
    local component = gameObject:GetComponent("ModelRenderer")
    if component ~= nil then
        distance, normal = ray:IntersectsModelRenderer(component)
    end
    if distance == nil then
        component = gameObject:GetComponent("MapRenderer")
        if component ~= nil then
            distance, normal, hitBlockLocation, adjacentBlockLocation = ray:IntersectsMapRenderer(component)
        end
    end
    --[[if distance == nil then
        component = gameObject:GetComponent("TextRenderer")
        if component ~= nil then
            distance, normal, hitBlockLocation, adjacentBlockLocation = ray:IntersectsTextRenderer(component)
        end
    end]]

    if distance == nil then
        Daneel.Debug.StackTrace.EndFunction()
        return nil
    end

    local raycastHit = RaycastHit.New(distance, normal, hitBlockLocation, adjacentBlockLocation, gameObject)
    Daneel.Debug.StackTrace.EndFunction()
    return raycastHit
end


----------------------------------------------------------------------------------
-- RaycastHit

RaycastHit = {}
RaycastHit.__index = RaycastHit
setmetatable(RaycastHit, { __call = function(Object, ...) return Object.New(...) end })

function RaycastHit.__tostring() 
    return "RaycastHit"
end

--- Create a new RaycastHit
-- @param distance (number) The distance between the ray's position and the hit.
-- @param normal (Vector3) The normal of the surface hit.
-- @param hitBlockLocation [optional] (Vector3) The position of the block that has been hit (only if a mapRenderer has been hit).
-- @param adjacentBlockLocation [optional] (Vector3) The position of the adjacent block.
-- @param gameObject (GameObject) The gameObject that has been hit.
-- @return (RaycastHit) The raycastHit.
function RaycastHit.New(distance, normal, hitBlockLocation, adjacentBlockLocation, gameObject)
    Daneel.Debug.StackTrace.BeginFunction("RaycastHit.New", distance, normal, hitBlockLocation, adjacentBlockLocation, gameObject)
    local errorHead = "RaycastHit.New(distance, normal[, hitBlockLocation, adjacentBlockLocation, gameObject]) : "
    Daneel.Debug.CheckArgType(distance, "distance", "number", errorHead)
    Daneel.Debug.CheckArgType(normal, "normal", "Vector3", errorHead)
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
    Daneel.Debug.StackTrace.EndFunction()
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

    local scene = Asset.Get(sceneNameOrAsset, "Scene", true)
    CraftStudio.LoadScene(scene)
    Daneel.Debug.StackTrace.EndFunction("Scene.Load")
end

--- Alias of CraftStudio.AppendScene().
-- Appends the specified scene to the game by instantiating all of its game objects. Contrary to CraftStudio.LoadScene, this doesn't unload the current scene nor waits for the next tick: it happens right away.
-- You can optionally specify a parent game object which will be used as a root for adding all game objects. 
-- @param sceneNameOrAsset (string or Scene) The scene name or asset
-- @param gameObjectNameOrInstance [optional] (string or GameObject) The gameObject name or instance
function Scene.Append(sceneNameOrAsset, gameObjectNameOrInstance)
    Daneel.Debug.StackTrace.BeginFunction("Scene.Append", sceneNameOrAsset, gameObjectNameOrInstance)
    local errorHead = "Scene.Append(sceneNameOrAsset[, gameObjectNameOrInstance]) : "
    Daneel.Debug.CheckArgType(sceneNameOrAsset, "sceneNameOrAsset", {"string", "Scene"}, errorHead)
    Daneel.Debug.CheckOptionalArgType(gameObjectNameOrInstance, "gameObjectNameOrInstance", {"string", "GameObject"}, errorHead)

    local scene = Asset.Get(sceneNameOrAsset, "Scene", true)
    local gameObject = GameObject.Get(gameObjectNameOrInstance, true)
    CraftStudio.AppendScene(scene, gameObject)
    Daneel.Debug.StackTrace.EndFunction("Scene.Append")
end


----------------------------------------------------------------------------------

local OriginalGetMousePosition = CraftStudio.Input.GetMousePosition

--- Return the mouse position on screen coordinates {x, y}
-- @return (Vector2) The on-screen mouse position.
function CraftStudio.Input.GetMousePosition()
    Daneel.Debug.StackTrace.BeginFunction("CraftStudio.Input.GetMousePosition")
    local vector = setmetatable(OriginalGetMousePosition(), Vector2)
    Daneel.Debug.StackTrace.EndFunction()
    return vector
end

local OriginalGetMouseDelta = CraftStudio.Input.GetMouseDelta

--- Return the mouse delta (the variation of position) since the last frame.
-- Positive x is right, positive y is bottom. 
-- @return (Vector2) The position's delta.
function CraftStudio.Input.GetMouseDelta()
    Daneel.Debug.StackTrace.BeginFunction("CraftStudio.Input.GetMouseDelta")
    local vector = setmetatable(OriginalGetMouseDelta(), Vector2)
    Daneel.Debug.StackTrace.EndFunction()
    return vector
end

local OriginalGetSize = CraftStudio.Screen.GetSize

--- Return the size of the screen, in pixels.
-- @return (Vector2) The screen's size.
function CraftStudio.Screen.GetSize()
    Daneel.Debug.StackTrace.BeginFunction("CraftStudio.Screen.GetSize")
    local vector = setmetatable(OriginalGetSize(), Vector2)
    Daneel.Debug.StackTrace.EndFunction()
    return vector
end


----------------------------------------------------------------------------------

setmetatable(Vector3, { __call = function(Object, ...) return Object:New(...) end })
setmetatable(Quaternion, { __call = function(Object, ...) return Object:New(...) end })
setmetatable(Plane, { __call = function(Object, ...) return Object:New(...) end })
