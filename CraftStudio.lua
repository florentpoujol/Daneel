
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
    
    -- check asset type
    if assetType ~= nil then
        Daneel.Debug.CheckArgType(assetType, "assetType", "string", errorHead)
        assetType = Daneel.Debug.CheckArgValue(assetType, "assetType", config.assetTypes, errorHead)
    end
    Daneel.Debug.CheckOptionalArgType(errorIfAssetNotFound, "errorIfAssetNotFound", "boolean", errorHead)

    -- check if assetName is a script alias
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
    if componentType == "CheckBox" then
        local isChecked = params.isChecked
        params.isChecked = nil
        for key, value in pairs(params) do
            component[key] = value
        end
        if isChecked ~= nil then
            component:Check(isChecked)
        end        
        
    elseif componentType == "ProgressBar" then
        local progress = params.progress
        params.progress = nil
        if progress == nil then
            progress = component.progress
        end
        for key, value in pairs(params) do
            component[key] = value
        end
        component.progress = progress

    elseif componentType == "Slider" then
        local value = params.value
        params.value = nil
        if value == nil then
            value = component.value
        end
        for key, value in pairs(params) do
            component[key] = value
        end
        component.value = value
        
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
-- Transform

--- Set the transform's global scale.
-- @param transform (Transform) The transform component.
-- @param scale (Vector3) The global scale.
function Transform.SetScale(transform, scale)
    Daneel.Debug.StackTrace.BeginFunction("Transform.SetScale", transform, scale)
    local errorHead = "Transform.SetScale(transform, scale) : "
    Daneel.Debug.CheckArgType(transform, "transform", "Transform", errorHead)
    Daneel.Debug.CheckArgType(scale, "scale", "Vector3", errorHead)

    local parent = transform.gameObject.parent
    if parent ~= nil then
        scale = scale / parent.transform.scale
    end
    transform.localScale = scale
    Daneel.Debug.StackTrace.EndFunction()
end

--- Get the transform's global scale.
-- @param transform (Transform) The transform component.
-- @return (Vector3) The global scale.
function Transform.GetScale(transform)
    Daneel.Debug.StackTrace.BeginFunction("Transform.GetScale", transform)
    local errorHead = "Transform.GetScale(transform) : "
    Daneel.Debug.CheckArgType(transform, "transform", "Transform", errorHead)

    local scale = transform.localScale
    local parent = transform.gameObject.parent
    if parent ~= nil then
        scale = scale * parent.transform.scale
    end
    Daneel.Debug.StackTrace.EndFunction()
    return scale
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
    Daneel.Debug.StackTrace.EndFunction()
end

--- Set the gameObject's scale. Shortcut for transform:SetLocalScale().
-- @param textRenderer (TextRenderer) The textRenderer.
-- @param scale (number, Vector2 or Vector3) The text's scale.
function TextRenderer.SetScale(textRenderer, scale)
    Daneel.Debug.StackTrace.BeginFunction("TextRenderer.SetScale", textRenderer, scale)
    local errorHead = "TextRenderer.SetScale(textRenderer, scale) : "
    Daneel.Debug.CheckArgType(textRenderer, "textRenderer", "TextRenderer", errorHead)
    local argType = Daneel.Debug.CheckArgType(scale, "scale", {"number", "Vector2", "Vector3"}, errorHead)

    if argType == "number" then
        scale = Vector3:New(scale)
    elseif argType == "Vector2" then
        scale = Vector3:New(scale.x, scale.y, 1)
    end
    textRenderer.gameObject.transform:SetScale( scale )
    Daneel.Debug.StackTrace.EndFunction()
end

--- Set the gameObject's local scale. Shortcut for transform:SetLocalScale().
-- @param textRenderer (TextRenderer) The textRenderer.
-- @param scale (number, Vector2 or Vector3) The text's scale.
function TextRenderer.SetLocalScale(textRenderer, scale)
    Daneel.Debug.StackTrace.BeginFunction("TextRenderer.SetLocalScale", textRenderer, scale)
    local errorHead = "TextRenderer.SetLocalScale(textRenderer, scale) : "
    Daneel.Debug.CheckArgType(textRenderer, "textRenderer", "TextRenderer", errorHead)
    local argType = Daneel.Debug.CheckArgType(scale, "scale", {"number", "Vector2", "Vector3"}, errorHead)

    if argType == "number" then
        scale = Vector3:New(scale)
    elseif argType == "Vector2" then
        scale = Vector3:New(scale.x, scale.y, 1)
    end
    textRenderer.gameObject.transform:SetLocalScale( scale )
    Daneel.Debug.StackTrace.EndFunction()
end


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
    if distance == nil then
        component = gameObject:GetComponent("TextRenderer")
        if component ~= nil then
            distance, normal, hitBlockLocation, adjacentBlockLocation = ray:IntersectsTextRenderer(component)
        end
    end

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
-- Schedules loading the specified scene after the current tick (frame) (1/60th of a second) has completed.
-- When the new scene is loaded, all of the current scene's game objects will be removed.
-- Calling this function doesn't immediately stops the calling function. As such, you might want to add a return statement afterwards. 
-- @param sceneNameOrAsset (string or Scene) The scene name or asset.
function Scene.Load(sceneNameOrAsset)
    Daneel.Debug.StackTrace.BeginFunction("Scene.Load", sceneNameOrAsset)
    local errorHead = "Scene.Load(sceneNameOrAsset) : "
    Daneel.Debug.CheckArgType(sceneNameOrAsset, "sceneNameOrAsset", {"string", "Scene"}, errorHead)

    CraftStudio.LoadScene(sceneNameOrAsset)
    Daneel.Debug.StackTrace.EndFunction()
end

local OriginalLoadScene = CraftStudio.LoadScene

--- Schedules loading the specified scene after the current tick (1/60th of a second) has completed.
-- When the new scene is loaded, all of the current scene's game objects will be removed.
-- Calling this function doesn't immediately stops the calling function. As such, you might want to add a return statement afterwards. 
-- @param sceneNameOrAsset (string or Scene) The scene name or asset.
function CraftStudio.LoadScene(sceneNameOrAsset)
    Daneel.Debug.StackTrace.BeginFunction("CraftStudio.LoadScene", sceneNameOrAsset)
    local errorHead = "CraftStudio.LoadScene(sceneNameOrAsset) : "
    Daneel.Debug.CheckArgType(sceneNameOrAsset, "sceneNameOrAsset", {"string", "Scene"}, errorHead)

    local scene = Asset.Get(sceneNameOrAsset, "Scene", true)
    
    Daneel.Event.Fire("OnSceneLoad", scene)
    Daneel.Event.events = {}
    Daneel.Event.fireAtTime = {}
    Daneel.Event.fireAtRealTime = {}
    Daneel.Event.fireAtFrame = {}

    Daneel.Debug.StackTrace.EndFunction()
    OriginalLoadScene(scene)
end

--- Alias of CraftStudio.AppendScene().
-- Appends the specified scene to the game by instantiating all of its game objects. Contrary to CraftStudio.LoadScene, this doesn't unload the current scene nor waits for the next tick: it happens right away.
-- You can optionally specify a parent game object which will be used as a root for adding all game objects. 
-- Returns the gameObject appended if there was only one root game object in the provided scene.
-- @param sceneNameOrAsset (string or Scene) The scene name or asset.
-- @param parentNameOrInstance [optional] (string or GameObject) The parent gameObject name or instance.
-- @return (GameObject) The appended gameObject, or nil.
function Scene.Append(sceneNameOrAsset, parentNameOrInstance)
    Daneel.Debug.StackTrace.BeginFunction("Scene.Append", sceneNameOrAsset, parentNameOrInstance)
    local errorHead = "Scene.Append(sceneNameOrAsset[, parentNameOrInstance]) : "
    Daneel.Debug.CheckArgType(sceneNameOrAsset, "sceneNameOrAsset", {"string", "Scene"}, errorHead)
    Daneel.Debug.CheckOptionalArgType(parentNameOrInstance, "parentNameOrInstance", {"string", "GameObject"}, errorHead)

    local scene = Asset.Get(sceneNameOrAsset, "Scene", true)
    local parent = GameObject.Get(parentNameOrInstance, true)
    local gameObject = CraftStudio.AppendScene(scene, parent)
    Daneel.Debug.StackTrace.EndFunction()
    return gameObject
end


----------------------------------------------------------------------------------

local OriginalGetMousePosition = CraftStudio.Input.GetMousePosition

--- Return the mouse position on screen coordinates {x, y}
-- @return (Vector2) The on-screen mouse position.
function CraftStudio.Input.GetMousePosition()
    Daneel.Debug.StackTrace.BeginFunction("CraftStudio.Input.GetMousePosition")
    local vector = OriginalGetMousePosition()
    if Daneel.Utilities.GlobalExists("Vector2") then
        setmetatable(vector, Vector2)
    end
    Daneel.Debug.StackTrace.EndFunction()
    return vector
end

local OriginalGetMouseDelta = CraftStudio.Input.GetMouseDelta

--- Return the mouse delta (the variation of position) since the last frame.
-- Positive x is right, positive y is bottom. 
-- @return (Vector2) The position's delta.
function CraftStudio.Input.GetMouseDelta()
    Daneel.Debug.StackTrace.BeginFunction("CraftStudio.Input.GetMouseDelta")
    local vector = OriginalGetMouseDelta()
    if Daneel.Utilities.GlobalExists("Vector2") then
        setmetatable(vector, Vector2)
    end
    Daneel.Debug.StackTrace.EndFunction()
    return vector
end

local OriginalGetSize = CraftStudio.Screen.GetSize

--- Return the size of the screen, in pixels.
-- @return (Vector2) The screen's size.
function CraftStudio.Screen.GetSize()
    Daneel.Debug.StackTrace.BeginFunction("CraftStudio.Screen.GetSize")
    local vector = OriginalGetSize()
    if Daneel.Utilities.GlobalExists("Vector2") then
        setmetatable(vector, Vector2)
    end
    Daneel.Debug.StackTrace.EndFunction()
    return vector
end

local OriginalDestroy = CraftStudio.Destroy

--- Removes the specified game object (and all of its descendants) or the specified component from its game object.
-- You can also optionally specify a dynamically loaded asset for unloading (See Map.LoadFromPackage ).
-- Sets the 'isDestroyed' property to 'true' and fires the OnDestroy event on the object.
-- @param object (GameObject, a component or a dynamically loaded asset) The gameObject, component or a dynamically loaded asset (like a map loaded with Map.LoadFromPackage).
function CraftStudio.Destroy(object)
    Daneel.Debug.StackTrace.BeginFunction("CraftStudio.Destroy", object)
    if object == nil and DEBUG then
        Daneel.Debug.StackTrace.Print()
        print("CraftStudio.Destroy(object) : provided object is nil")
        return
    end
    local Type = Daneel.Debug.GetType(object)

    if Type == "GameObject" then
        object:RemoveTag()

    elseif Type:isoneof(config.componentTypes) then
        if Type:isoneof(config.daneelComponentTypes) then 
            object.inner = nil 
            -- do this here because object.inner is needed by CS.Destroy() to actually removes the CS component
            
            -- if a Daneel component, must ensure that the corresponding Behavior is also removed
            local behavior = object.gameObject:GetScriptedBehavior("Daneel/Behaviors/"..Type)
            if behavior ~= nil then
                table.removevalue(object.gameObject, behavior)
                CraftStudio.Destroy(behavior)
            end
            table.removevalue(object.gameObject, object)
        end
    end

    -- for all objects, remove from listener list
    Daneel.Event.Clean(object)
  
    --setmetatable(object, nil)
    object.isDestroyed = true
    Daneel.Event.Fire(object, "OnDestroy")
    OriginalDestroy(object)
    Daneel.Debug.StackTrace.EndFunction()
end


----------------------------------------------------------------------------------

setmetatable(Vector3, { __call = function(Object, ...) return Object:New(...) end })
setmetatable(Quaternion, { __call = function(Object, ...) return Object:New(...) end })
setmetatable(Plane, { __call = function(Object, ...) return Object:New(...) end })
