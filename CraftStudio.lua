-- CraftStudio.lua
-- Contains extensions of CraftStudio's API.
--
-- Last modified for v1.4.0
-- Copyright © 2013-2014 Florent POUJOL, published under the MIT license.


setmetatable( Vector3, { __call = function(Object, ...) return Object:New(...) end } )
setmetatable( Quaternion, { __call = function(Object, ...) return Object:New(...) end } )
setmetatable( Plane, { __call = function(Object, ...) return Object:New(...) end } )


----------------------------------------------------------------------------------
-- fix for Map.GetPathInPackage() that returns an error when the asset was dynamically loaded
local OriginalMapGetPathInPackage = Map.GetPathInPackage

function Map.GetPathInPackage( asset )
    local path = rawget( asset, "path" )
    if path == nil then
        path = OriginalMapGetPathInPackage( asset )
    end
    return path
end

local OriginalMapLoadFromPackage = Map.LoadFromPackage

function Map.LoadFromPackage( path, callback )
    OriginalMapLoadFromPackage( path, function( map )
        if map ~= nil then
            rawset( map, "path", path )
        end
        callback( map )
    end )
end


----------------------------------------------------------------------------------
-- Transform

local OriginalSetLocalScale = Transform.SetLocalScale

--- Set the transform's local scale.
-- @param transform (Transform) The transform component.
-- @param scale (number or Vector3) The global scale.
function Transform.SetLocalScale(transform, scale)
    Daneel.Debug.StackTrace.BeginFunction("Transform.SetLocalScale", transform, scale)
    local errorHead = "Transform.SetLocalScale(transform, scale) : "
    Daneel.Debug.CheckArgType(transform, "transform", "Transform", errorHead)
    local argType = Daneel.Debug.CheckArgType(scale, "scale", {"number", "Vector3"}, errorHead)

    if argType == "number" then
        scale = Vector3:New(scale)
    end
    OriginalSetLocalScale(transform, scale)
    Daneel.Debug.StackTrace.EndFunction()
end

--- Set the transform's global scale.
-- @param transform (Transform) The transform component.
-- @param scale (number or Vector3) The global scale.
function Transform.SetScale(transform, scale)
    Daneel.Debug.StackTrace.BeginFunction("Transform.SetScale", transform, scale)
    local errorHead = "Transform.SetScale(transform, scale) : "
    Daneel.Debug.CheckArgType(transform, "transform", "Transform", errorHead)
    local argType = Daneel.Debug.CheckArgType(scale, "scale", {"number", "Vector3"}, errorHead)

    if argType == "number" then
        scale = Vector3:New(scale)
    end

    local parent = transform.gameObject:GetParent()
    if parent ~= nil then
        scale = scale / parent.transform:GetScale()
    end
    transform:SetLocalScale( scale )
    Daneel.Debug.StackTrace.EndFunction()
end

--- Get the transform's global scale.
-- @param transform (Transform) The transform component.
-- @return (Vector3) The global scale.
function Transform.GetScale(transform)
    Daneel.Debug.StackTrace.BeginFunction("Transform.GetScale", transform)
    local errorHead = "Transform.GetScale(transform) : "
    Daneel.Debug.CheckArgType(transform, "transform", "Transform", errorHead)

    local scale = transform:GetLocalScale()
    local parent = transform.gameObject:GetParent()
    if parent ~= nil then
        scale = scale * parent.transform:GetScale()
    end
    Daneel.Debug.StackTrace.EndFunction()
    return scale
end


----------------------------------------------------------------------------------
-- ModelRenderer

local OriginalSetModel = ModelRenderer.SetModel

--- Attach the provided model to the provided modelRenderer.
-- @param modelRenderer (ModelRenderer) The modelRenderer.
-- @param modelNameOrAsset (string or Model) [optional] The model name or asset, or nil.
function ModelRenderer.SetModel( modelRenderer, modelNameOrAsset )
    Daneel.Debug.StackTrace.BeginFunction( "ModelRenderer.SetModel", modelRenderer, modelNameOrAsset )
    local errorHead = "ModelRenderer.SetModel( modelRenderer[, modelNameOrAsset] ) : "
    Daneel.Debug.CheckArgType( modelRenderer, "modelRenderer", "ModelRenderer", errorHead )
    Daneel.Debug.CheckOptionalArgType( modelNameOrAsset, "modelNameOrAsset", {"string", "Model"}, errorHead )

    local model = nil
    if modelNameOrAsset ~= nil then
        model = Asset.Get( modelNameOrAsset, "Model", true )
    end
    OriginalSetModel( modelRenderer, model )
    Daneel.Debug.StackTrace.EndFunction()
end

local OriginalSetAnimation = ModelRenderer.SetAnimation

--- Set the specified animation for the modelRenderer's current model.
-- @param modelRenderer (ModelRenderer) The modelRenderer.
-- @param animationNameOrAsset (string or ModelAnimation) [optional] The animation name or asset, or nil.
function ModelRenderer.SetAnimation( modelRenderer, animationNameOrAsset )
    Daneel.Debug.StackTrace.BeginFunction( "ModelRenderer.SetAnimation", modelRenderer, animationNameOrAsset )
    local errorHead = "ModelRenderer.SetAnimation( modelRenderer[, animationNameOrAsset] ) : "
    Daneel.Debug.CheckArgType( modelRenderer, "modelRenderer", "ModelRenderer", errorHead )
    Daneel.Debug.CheckOptionalArgType( animationNameOrAsset, "animationNameOrAsset", {"string", "ModelAnimation"}, errorHead )

    local animation = nil 
    if animationNameOrAsset ~= nil then
        animation = Asset.Get( animationNameOrAsset, "ModelAnimation", true )
    end
    OriginalSetAnimation( modelRenderer, animation )
    Daneel.Debug.StackTrace.EndFunction()
end

--- Apply the content of the params argument to the provided model renderer.
-- @param modelRenderer (ModelRenderer) The model renderer.
-- @param params (table) A table of parameters to set the component with.
function ModelRenderer.Set( modelRenderer, params )
    Daneel.Debug.StackTrace.BeginFunction( "ModelRenderer.Set", modelRenderer, params )
    local errorHead = "ModelRenderer.Set( modelRenderer, params ) : "
    Daneel.Debug.CheckArgType( modelRenderer, "modelRenderer", "ModelRenderer", errorHead )
    Daneel.Debug.CheckArgType( params, "params", "table", errorHead )

    if params.model ~= nil then
        modelRenderer:SetModel( params.model )
        params.model = nil
    end

    if params.animationTime ~= nil and params.animation ~= nil then
        modelRenderer:SetAnimation( params.animation )
        params.animation = nil
    end

    Component.Set( modelRenderer, params )
    Daneel.Debug.StackTrace.EndFunction()
end


----------------------------------------------------------------------------------
-- MapRenderer

local OriginalSetMap = MapRenderer.SetMap

--- Attach the provided map to the provided map renderer.
-- @param mapRenderer (MapRenderer) The map renderer.
-- @param mapNameOrAsset (string or Map) [optional] The map name or asset, or nil.
-- @param replaceTileSet (boolean) [optional default=true] Replace the current TileSet by the one set for the provided map in the map editor. 
function MapRenderer.SetMap( mapRenderer, mapNameOrAsset, replaceTileSet )
    Daneel.Debug.StackTrace.BeginFunction( "MapRenderer.SetMap", mapRenderer, mapNameOrAsset, replaceTileSet )
    local errorHead = "MapRenderer.SetMap( mapRenderer[, mapNameOrAsset, replaceTileSet] ) : "
    Daneel.Debug.CheckArgType( mapRenderer, "mapRenderer", "MapRenderer", errorHead )
    Daneel.Debug.CheckOptionalArgType( mapNameOrAsset, "mapNameOrAsset", {"string", "Map"}, errorHead )
    Daneel.Debug.CheckOptionalArgType( replaceTileSet, "replaceTileSet", "boolean", errorHead )

    local map = nil
    if mapNameOrAsset ~= nil then
        map = Asset.Get( mapNameOrAsset, "Map", true )
    end

    if replaceTileSet ~= nil then
        OriginalSetMap(mapRenderer, map, replaceTileSet)
    else
        OriginalSetMap(mapRenderer, map)
    end
    Daneel.Debug.StackTrace.EndFunction()
end

local OriginalSetTileSet = MapRenderer.SetTileSet

--- Set the specified tileSet for the mapRenderer's map.
-- @param mapRenderer (MapRenderer) The mapRenderer.
-- @param tileSetNameOrAsset (string or TileSet) [optional] The tileSet name or asset, or nil.
function MapRenderer.SetTileSet( mapRenderer, tileSetNameOrAsset )
    Daneel.Debug.StackTrace.BeginFunction("MapRenderer.SetTileSet", mapRenderer, tileSetNameOrAsset )
    local errorHead = "MapRenderer.SetTileSet( mapRenderer[, tileSetNameOrAsset] ) : "
    Daneel.Debug.CheckArgType( mapRenderer, "mapRenderer", "MapRenderer", errorHead )
    Daneel.Debug.CheckOptionalArgType( tileSetNameOrAsset, "tileSetNameOrAsset", {"string", "TileSet"}, errorHead )

    local tileSet = nil
    if tileSetNameOrAsset ~= nil then
        tileSet = Asset.Get( tileSetNameOrAsset, "TileSet", true )
    end
    OriginalSetTileSet( mapRenderer, tileSet )
    Daneel.Debug.StackTrace.EndFunction()
end

--- Apply the content of the params argument to the provided map renderer.
-- @param mapRenderer (MapRenderer) The map renderer.
-- @param params (table) A table of parameters to set the component with.
function MapRenderer.Set( mapRenderer, params )
    Daneel.Debug.StackTrace.BeginFunction( "MapRenderer.Set", mapRenderer, params )
    local errorHead = "MapRenderer.Set( mapRenderer, params ) : "
    Daneel.Debug.CheckArgType( mapRenderer, "mapRenderer", "MapRenderer", errorHead )
    Daneel.Debug.CheckArgType( params, "params", "table", errorHead )

    if params.map ~= nil then
        mapRenderer:SetMap( params.map )
        -- set the map here in case of the tileSet property is set too
        params.map = nil
    end

    Component.Set( mapRenderer, params )
    Daneel.Debug.StackTrace.EndFunction()
end


----------------------------------------------------------------------------------
-- TextRenderer

local OriginalSetFont = TextRenderer.SetFont

--- Set the provided font to the provided text renderer.
-- @param textRenderer (TextRenderer) The text renderer.
-- @param fontNameOrAsset (string or Font) [optional] The font name or asset, or nil.
function TextRenderer.SetFont( textRenderer, fontNameOrAsset )
    Daneel.Debug.StackTrace.BeginFunction( "TextRenderer.SetFont", textRenderer, fontNameOrAsset )
    local errorHead = "TextRenderer.SetFont( textRenderer[, fontNameOrAsset] ) : "
    Daneel.Debug.CheckArgType( textRenderer, "textRenderer", "TextRenderer", errorHead )
    Daneel.Debug.CheckOptionalArgType( fontNameOrAsset, "fontNameOrAsset", {"string", "Font"}, errorHead )

    local font = nil
    if fontNameOrAsset ~= nil then
        font = Asset.Get( fontNameOrAsset, "Font", true )
    end
    OriginalSetFont( textRenderer, font )
    Daneel.Debug.StackTrace.EndFunction()
end

local OriginalSetAlignment = TextRenderer.SetAlignment

--- Set the text's alignment.
-- @param textRenderer (TextRenderer) The textRenderer.
-- @param alignment (string or TextRenderer.Alignment) The alignment. Values (case-insensitive when of type string) may be "left", "center", "right", TextRenderer.Alignment.Left, TextRenderer.Alignment.Center or TextRenderer.Alignment.Right.
function TextRenderer.SetAlignment(textRenderer, alignment)
    Daneel.Debug.StackTrace.BeginFunction("TextRenderer.SetAlignment", textRenderer, alignment)
    local errorHead = "TextRenderer.SetAlignment(textRenderer, alignment) : "
    Daneel.Debug.CheckArgType(textRenderer, "textRenderer", "TextRenderer", errorHead)
    local argType = Daneel.Debug.CheckArgType(alignment, "alignment", {"string", "userdata", "number"}, errorHead) -- number because enum returns a number in the webplayer

    if argType == "string" then
        local default = "Center"
        if Daneel.Config.textRenderer ~= nil and Daneel.Config.textRenderer.alignment ~= nil then
            default = Daneel.Config.textRenderer.alignment
        end
        alignment = Daneel.Debug.CheckArgValue( alignment, "alignment", {"Left", "Center", "Right"}, errorHead, default )
        alignment = TextRenderer.Alignment[ alignment ]
    end
    OriginalSetAlignment( textRenderer, alignment )
    Daneel.Debug.StackTrace.EndFunction()
end

--- Update the game object's scale to make the text appear the provided width.
-- @param textRenderer (TextRenderer) The textRenderer.
-- @param width (number) The text's width in scene units.
function TextRenderer.SetTextWidth( textRenderer, width )
    Daneel.Debug.StackTrace.BeginFunction("TextRenderer.SetTextWidth", textRenderer, width)
    local errorHead = "TextRenderer.SetTextWidth(textRenderer, width) : "
    Daneel.Debug.CheckArgType(textRenderer, "textRenderer", "TextRenderer", errorHead)
    local argType = Daneel.Debug.CheckArgType(width, "width", "number", errorHead)

    local widthScaleRatio = textRenderer:GetTextWidth() / textRenderer.gameObject.transform:GetScale()
    textRenderer.gameObject.transform:SetScale( width / widthScaleRatio )
    Daneel.Debug.StackTrace.EndFunction()
end


----------------------------------------------------------------------------------
-- Camera

local OriginalSetProjectionMode = Camera.SetProjectionMode

--- Sets the camera projection mode.
-- @param camera (Camera) The camera.
-- @param projectionMode (string or Camera.ProjectionMode) The projection mode. Possible values are "perspective", "orthographic" (as a case-insensitive string), Camera.ProjectionMode.Perspective or Camera.ProjectionMode.Orthographic.
function Camera.SetProjectionMode( camera, projectionMode )
    Daneel.Debug.StackTrace.BeginFunction( "Camera.SetProjectionMode", camera, projectionMode )
    local errorHead = "Camera.SetProjectionMode( camera, projectionMode ) : "
    Daneel.Debug.CheckArgType( camera, "camera", "Camera", errorHead)
    local argType = Daneel.Debug.CheckArgType( projectionMode, "projectionMode", {"string", "userdata", "number"}, errorHead )

    if argType == "string" then
        local default = "Perspective"
        if Daneel.Config.camera ~= nil and Daneel.Config.camera.projectionMode ~= nil then
            default = Daneel.Config.camera.projectionMode
        end
        projectionMode = Daneel.Debug.CheckArgValue( projectionMode, "projectionMode", {"Perspective", "Orthographic"}, errorHead, default )
        projectionMode = Camera.ProjectionMode[ projectionMode ]
    end

    OriginalSetProjectionMode( camera, projectionMode )
    Daneel.Debug.StackTrace.EndFunction()
end

--- Apply the content of the params argument to the provided camera.
-- @param camera (Camera) The camera.
-- @param params (table) A table of parameters to set the component with.
function Camera.Set( camera, params )
    Daneel.Debug.StackTrace.BeginFunction( "Camera.Set", camera, params )
    local errorHead = "Camera.Set( camera, params ) : "
    Daneel.Debug.CheckArgType( camera, "camera", "Camera", errorHead )
    Daneel.Debug.CheckArgType( params, "params", "table", errorHead )

    if params.projectionMode ~= nil then
        camera:SetProjectionMode( params.projectionMode )
        params.projectionMode = nil
    end

    Component.Set( camera, params )
    Daneel.Debug.StackTrace.EndFunction()
end


----------------------------------------------------------------------------------
-- Ray

setmetatable( Ray, { __call = function(Object, ...) return Object:New(...) end } )

--- Check the collision of the ray against the provided set of game objects.
-- @param ray (Ray) The ray.
-- @param gameObjects (table) The set of game objects to cast the ray against.
-- @param sortByDistance [optional default=false] (boolean) Sort the raycastHit by increasing distance in the returned table.
-- @return (table) A table of RaycastHits (will be empty if the ray didn't intersects anything).
function Ray.Cast( ray, gameObjects, sortByDistance )
    Daneel.Debug.StackTrace.BeginFunction( "Ray.Cast", ray, gameObjects, sortByDistance )
    local errorHead = "Ray.Cast( ray, gameObjects[, sortByDistance] ) : "
    Daneel.Debug.CheckArgType( ray, "ray", "Ray", errorHead )
    Daneel.Debug.CheckArgType( gameObjects, "gameObjects", "table", errorHead )
    Daneel.Debug.CheckOptionalArgType( sortByDistance, "sortByDistance", "boolean", errorHead )
    
    local hits = {}
    for i, gameObject in pairs( gameObjects ) do
        if gameObject.inner ~= nil then
            local raycastHit = ray:IntersectsGameObject( gameObject )
            if raycastHit ~= nil then
                table.insert( hits, raycastHit )
            end
        end
    end
    if sortByDistance == true then
        hits = table.sortby( hits, "distance" )
    end

    Daneel.Debug.StackTrace.EndFunction()
    return hits
end

--- Check if the ray intersect the specified game object.
-- @param ray (Ray) The ray.
-- @param gameObjectNameOrInstance (string or GameObject) The game object instance or name.
-- @return (RaycastHit) A raycastHit with the if there was a collision, or nil.
function Ray.IntersectsGameObject( ray, gameObjectNameOrInstance )
    Daneel.Debug.StackTrace.BeginFunction( "Ray.IntersectsGameObject", ray, gameObjectNameOrInstance )
    local errorHead = "Ray.IntersectsGameObject( ray, gameObjectNameOrInstance ) : "
    Daneel.Debug.CheckArgType( ray, "ray", "Ray", errorHead )
    Daneel.Debug.CheckArgType( gameObjectNameOrInstance, "gameObjectNameOrInstance", {"string", "GameObject"}, errorHead )
    
    local gameObject = GameObject.Get( gameObjectNameOrInstance, true )
    local raycastHit = nil

    if gameObject.inner == nil then
        -- should not happend since CheckArgType() returns an error when the game object is dead
        return nil
    end

    local component = gameObject.modelRenderer
    if component ~= nil then
        raycastHit = ray:IntersectsModelRenderer( component, true )
    end

    if raycastHit == nil then
        component = gameObject.mapRenderer
        if component ~= nil then
            raycastHit = ray:IntersectsMapRenderer( component, true )
        end
    end

    if raycastHit == nil then
        component = gameObject.textRenderer
        if component ~= nil then
            raycastHit = ray:IntersectsTextRenderer( component, true )
        end
    end

    if raycastHit ~= nil then
        raycastHit.gameObject = gameObject
    end

    Daneel.Debug.StackTrace.EndFunction()
    return raycastHit
end

local OriginalIntersectsPlane = Ray.IntersectsPlane

-- Check if the ray intersects the provided plane and returns the distance of intersection or a raycastHit.
-- @param ray (Ray) The ray.
-- @param plane (Plane) The plane.
-- @param returnRaycastHit (boolean) [optional default=false] Tell if the hit infos must be returned as a raycastHit.
-- @return (number or RaycastHit) The distance of intersection (if any) or a raycastHit with the 'distance' and 'hitLocation' properties (if any).
function Ray.IntersectsPlane( ray, plane, returnRaycastHit )
    -- 08/08/13 removed reference to plane in BeginFunction and CheckArgType
    -- because Plane.__tostring is wrong, causes 'var self is not declared'
    Daneel.Debug.StackTrace.BeginFunction( "Ray.IntersectsPlane", ray, nil, returnRaycastHit )
    local errorHead = "Ray.IntersectsPlane( ray, plane[, returnRaycastHit] ) : "
    Daneel.Debug.CheckArgType( ray, "ray", "Ray", errorHead )
    --Daneel.Debug.CheckArgType( plane, "plane", "Plane", errorHead )
    returnRaycastHit = Daneel.Debug.CheckOptionalArgType( returnRaycastHit, "returnRaycastHit", "boolean", errorHead, false )

    local distance = OriginalIntersectsPlane( ray, plane )
    if returnRaycastHit and distance ~= nil then
        local raycastHit = RaycastHit.New({
            distance = distance,
            hitLocation = ray.position + ray.direction * distance,
            hitObject = plane,
        })

        distance = raycastHit
    end

    Daneel.Debug.StackTrace.EndFunction()
    return distance
end

local OriginalIntersectsModelRenderer = Ray.IntersectsModelRenderer

-- Check if the ray intersects the provided modelRenderer.
-- @param ray (Ray) The ray.
-- @param modelRenderer (ModelRenderer) The modelRenderer.
-- @param returnRaycastHit (boolean) [optional default=false] Tell if the hit infos must be returned as a raycastHit.
-- @return (number or RaycastHit) The distance of intersection (if any) or a raycastHit with the 'distance', 'normal' and 'hitLocation' properties (if any).
-- @return (Vector3) If 'returnRaycastHit' argument is false : the normal of the hit face, or nil
function Ray.IntersectsModelRenderer( ray, modelRenderer, returnRaycastHit )
    Daneel.Debug.StackTrace.BeginFunction( "Ray.IntersectsModelRenderer", ray, modelRenderer, returnRaycastHit )
    local errorHead = "Ray.IntersectsModelRenderer( ray, modelRenderer[, returnRaycastHit] ) : "
    Daneel.Debug.CheckArgType( ray, "ray", "Ray", errorHead )
    Daneel.Debug.CheckArgType( modelRenderer, "modelRenderer", "ModelRenderer", errorHead )
    returnRaycastHit = Daneel.Debug.CheckOptionalArgType( returnRaycastHit, "returnRaycastHit", "boolean", errorHead, false )

    local distance, normal = OriginalIntersectsModelRenderer( ray, modelRenderer )
    if returnRaycastHit and distance ~= nil then
        local raycastHit = RaycastHit.New({
            distance = distance,
            normal = normal,
            hitLocation = ray.position + ray.direction * distance,
            hitObject = modelRenderer,
            gameObject = modelRenderer.gameObject,
        })

        distance = raycastHit
        normal = nil
    end

    Daneel.Debug.StackTrace.EndFunction()
    return distance, normal
end

local OriginalIntersectsMapRenderer = Ray.IntersectsMapRenderer

-- Check if the ray intersects the provided mapRenderer.
-- @param ray (Ray) The ray.
-- @param mapRenderer (MapRenderer) The mapRenderer.
-- @param returnRaycastHit (boolean) [optional default=false] Tell if the hit infos must be returned as a raycastHit.
-- @return (number or RaycastHit) The distance of intersection (if any) or a raycastHit with the 'distance', 'normal', 'hitBlockLocation', 'adjacentBlockLocation' and 'hitLocation' properties (if any).
-- @return (Vector3) If 'returnRaycastHit' argument is false : the normal of the hit face, or nil
-- @return (Vector3) If 'returnRaycastHit' argument is false : the location of the block hit, or nil
-- @return (Vector3) If 'returnRaycastHit' argument is false : the location of the adjacent block, or nil
function Ray.IntersectsMapRenderer( ray, mapRenderer, returnRaycastHit )
    Daneel.Debug.StackTrace.BeginFunction( "Ray.IntersectsMapRenderer", ray, mapRenderer, returnRaycastHit )
    local errorHead = "Ray.IntersectsMapRenderer( ray, mapRenderer[, returnRaycastHit] ) : "
    Daneel.Debug.CheckArgType( ray, "ray", "Ray", errorHead )
    Daneel.Debug.CheckArgType( mapRenderer, "mapRenderer", "MapRenderer", errorHead )
    returnRaycastHit = Daneel.Debug.CheckOptionalArgType( returnRaycastHit, "returnRaycastHit", "boolean", errorHead, false )

    local distance, normal, hitBlockLocation, adjacentBlockLocation = OriginalIntersectsMapRenderer( ray, mapRenderer )
    if hitBlockLocation ~= nil then
        setmetatable( hitBlockLocation, Vector3 )
    end
    if adjacentBlockLocation ~= nil then
        setmetatable( adjacentBlockLocation, Vector3 )
    end

    if returnRaycastHit and distance ~= nil then
        local raycastHit = RaycastHit.New({
            distance = distance,
            normal = normal,
            hitBlockLocation = hitBlockLocation,
            adjacentBlockLocation = adjacentBlockLocation,
            hitLocation = ray.position + ray.direction * distance,
            hitObject = mapRenderer,
            gameObject = mapRenderer.gameObject,
        })

        distance = raycastHit
        normal = nil
        hitBlockLocation = nil
        adjacentBlockLocation = nil
    end

    Daneel.Debug.StackTrace.EndFunction()
    return distance, normal, hitBlockLocation, adjacentBlockLocation
end

local OriginalIntersectsTextRenderer = Ray.IntersectsTextRenderer

-- Check if the ray intersects the provided textRenderer.
-- @param ray (Ray) The ray.
-- @param textRenderer (TextRenderer) The textRenderer.
-- @param returnRaycastHit (boolean) [optional default=false] Tell if the hit infos must be returned as a raycastHit.
-- @return (number or RaycastHit) The distance of intersection (if any) or a raycastHit with the 'distance', 'normal' and 'hitLocation' properties (if any).
-- @return (Vector3) If 'returnRaycastHit' argument is false : the normal of the hit face, or nil
function Ray.IntersectsTextRenderer( ray, textRenderer, returnRaycastHit )
    Daneel.Debug.StackTrace.BeginFunction( "Ray.IntersectsTextRenderer", ray, textRenderer, returnRaycastHit )
    local errorHead = "Ray.IntersectsTextRenderer( ray, textRenderer[, returnRaycastHit] ) : "
    Daneel.Debug.CheckArgType( ray, "ray", "Ray", errorHead )
    Daneel.Debug.CheckArgType( textRenderer, "textRenderer", "TextRenderer", errorHead )
    returnRaycastHit = Daneel.Debug.CheckOptionalArgType( returnRaycastHit, "returnRaycastHit", "boolean", errorHead, false )

    local distance, normal = OriginalIntersectsTextRenderer( ray, textRenderer )
    if returnRaycastHit and distance ~= nil then
        local raycastHit = RaycastHit.New({
            distance = distance,
            normal = normal,
            hitLocation = ray.position + ray.direction * distance,
            hitObject = textRenderer,
            gameObject = textRenderer.gameObject,
        })

        Daneel.Debug.StackTrace.EndFunction()
        return raycastHit
    end

    Daneel.Debug.StackTrace.EndFunction()
    return distance, normal
end


----------------------------------------------------------------------------------
-- Scene

--- Alias of CraftStudio.LoadScene().
-- Schedules loading the specified scene after the current tick (frame) (1/60th of a second) has completed.
-- When the new scene is loaded, all of the current scene's game objects will be removed.
-- Calling this function doesn't immediately stops the calling function. As such, you might want to add a return statement afterwards. 
-- @param sceneNameOrAsset (string or Scene) The scene name or asset.
function Scene.Load( sceneNameOrAsset )
    Daneel.Debug.StackTrace.BeginFunction( "Scene.Load", sceneNameOrAsset )
    local errorHead = "Scene.Load( sceneNameOrAsset ) : "
    Daneel.Debug.CheckArgType( sceneNameOrAsset, "sceneNameOrAsset", {"string", "Scene"}, errorHead )

    CraftStudio.LoadScene( sceneNameOrAsset )
    Daneel.Debug.StackTrace.EndFunction()
end

local OriginalLoadScene = CraftStudio.LoadScene

--- Schedules loading the specified scene after the current tick (1/60th of a second) has completed.
-- When the new scene is loaded, all of the current scene's game objects will be removed.
-- Calling this function doesn't immediately stops the calling function. As such, you might want to add a return statement afterwards. 
-- @param sceneNameOrAsset (string or Scene) The scene name or asset.
function CraftStudio.LoadScene( sceneNameOrAsset )
    Daneel.Debug.StackTrace.BeginFunction( "CraftStudio.LoadScene", sceneNameOrAsset )
    local errorHead = "CraftStudio.LoadScene( sceneNameOrAsset ) : "
    Daneel.Debug.CheckArgType( sceneNameOrAsset, "sceneNameOrAsset", {"string", "Scene"}, errorHead )

    local scene = Asset.Get( sceneNameOrAsset, "Scene", true )
    
    Daneel.Event.Fire( "OnSceneLoad", scene )
    Daneel.Event.events = {} -- do this here to make sure that any events that might be fired from OnSceneLoad-catching function are indeed fired
    Scene.current = scene

    Daneel.Debug.StackTrace.EndFunction()
    OriginalLoadScene( scene )
end

--- Alias of CraftStudio.AppendScene().
-- Appends the specified scene to the game by instantiating all of its game objects. Contrary to CraftStudio.LoadScene, this doesn't unload the current scene nor waits for the next tick: it happens right away.
-- You can optionally specify a parent game object which will be used as a root for adding all game objects. 
-- Returns the game object appended if there was only one root game object in the provided scene.
-- @param sceneNameOrAsset (string or Scene) The scene name or asset.
-- @param parentNameOrInstance [optional] (string or GameObject) The parent game object name or instance.
-- @return (GameObject) The appended game object, or nil.
function Scene.Append( sceneNameOrAsset, parentNameOrInstance )
    Daneel.Debug.StackTrace.BeginFunction( "Scene.Append", sceneNameOrAsset, parentNameOrInstance )
    local errorHead = "Scene.Append( sceneNameOrAsset[, parentNameOrInstance] ) : "
    Daneel.Debug.CheckArgType( sceneNameOrAsset, "sceneNameOrAsset", {"string", "Scene"}, errorHead )
    Daneel.Debug.CheckOptionalArgType( parentNameOrInstance, "parentNameOrInstance", {"string", "GameObject"}, errorHead )

    local scene = Asset.Get( sceneNameOrAsset, "Scene", true )
    local parent = nil
    if parentNameOrInstance ~= nil then
        parent = GameObject.Get( parentNameOrInstance, true )
    end
    local gameObject = CraftStudio.AppendScene( scene, parent )

    Daneel.Debug.StackTrace.EndFunction()
    return gameObject
end


----------------------------------------------------------------------------------

local OriginalDestroy = CraftStudio.Destroy

--- Removes the specified game object (and all of its descendants) or the specified component from its game object.
-- You can also optionally specify a dynamically loaded asset for unloading (See Map.LoadFromPackage ).
-- Sets the 'isDestroyed' property to 'true' and fires the 'OnDestroy' event on the object.
-- @param object (GameObject, a component or a dynamically loaded asset) The game object, component or a dynamically loaded asset (like a map loaded with Map.LoadFromPackage).
function CraftStudio.Destroy( object )
    Daneel.Debug.StackTrace.BeginFunction( "CraftStudio.Destroy", object )
    if type( object ) == "table" then
        Daneel.Event.Fire( object, "OnDestroy", object )
        Daneel.Event.StopListen( object ) -- remove from listener list
        object.isDestroyed = true
    end
    OriginalDestroy( object )
    Daneel.Debug.StackTrace.EndFunction()
end


----------------------------------------------------------------------------------

CS.Input.isMouseLocked = false

local OriginalLockMouse = CS.Input.LockMouse
function CS.Input.LockMouse()
    CS.Input.isMouseLocked = true
    OriginalLockMouse()
end

local OriginalUnlockMouse = CS.Input.UnlockMouse
function CS.Input.UnlockMouse()
    CS.Input.isMouseLocked = false
    OriginalUnlockMouse()
end

--- Toggle the locked state of the mouse, which can be accessed via the CS.Input.isMouseLocked property.
function CS.Input.ToggleMouseLock()
    if CS.Input.isMouseLocked then
        CS.Input.UnlockMouse()
    else
        CS.Input.LockMouse()
    end
end


----------------------------------------------------------------------------------
-- GAMEOBJECT


setmetatable( GameObject, { __call = function(Object, ...) return Object.New(...) end } )

-- returns something like "GameObject: 123456789: 'MyName'"
function GameObject.__tostring( gameObject )
    if rawget( gameObject, "transform" ) == nil then
        return "Destroyed gameObject: " .. Daneel.Debug.ToRawString( gameObject )
        -- the important here was to prevent throwing an error
    end

    return "GameObject: " .. gameObject:GetId() .. ": '" .. gameObject:GetName() .. "'"
end

-- Dynamic getters
function GameObject.__index( gameObject, key )
    if GameObject[ key ] ~= nil then
        return GameObject[ key ]
    end

    -- maybe the key is a script alias
    local path = Daneel.Config.scriptPaths[ key ]
    if path ~= nil then
        local behavior = gameObject:GetScriptedBehavior( path )
        if behavior ~= nil then
            rawset( gameObject, key, behavior )
            return behavior
        end
    end

    if type( key ) == "string" then
        -- or the name of a getter 
        local ucKey = string.ucfirst( key )
        if key ~= ucKey then
            local funcName = "Get" .. ucKey
            
            -- on GameObject
            if GameObject[ funcName ] ~= nil then
                return GameObject[ funcName ]( gameObject )
            end

            if Daneel.Config.allowDynamicComponentFunctionCallOnGameObject then
                -- on a component
                for propName, propValue in pairs( gameObject ) do
                    if type( propValue ) == "table" then
                        local componentObject = getmetatable( propValue )
                        if componentObject ~= nil and table.containsvalue( Daneel.Config.componentObjects, componentObject ) then
                            -- could also check propName, which is the component name (Daneel.Config.componentObjects[ ucfirst( propName ) ] ~= nil)
                            -- propValue is a component instance
                            if componentObject[ funcName ] ~= nil then
                                return componentObject[ funcName ]( propValue )
                            end
                        end
                    end
                end
            end
        end
    end

    return nil
end

-- Dynamic setters
function GameObject.__newindex( gameObject, key, value )
    local ucKey = key
    if type( key ) == "string" then
        ucKey = string.ucfirst( key )
    end
    if key ~= ucKey and key ~= "transform" then -- first letter lowercase
        -- check about Transform is needed because CraftStudio.CreateGameObject() set the transfom variable on new game objects
        -- 26/09/2013 And so what ? If SetTransform() doesn't exist, it's not an issue
        local funcName = "Set" .. ucKey
        -- ie: variable "name" call "SetName"
        if GameObject[ funcName ] ~= nil then
            return GameObject[ funcName ]( gameObject, value )
        end

        if Daneel.Config.allowDynamicComponentFunctionCallOnGameObject then
            -- key could be a setter on a component
            for propName, propValue in pairs( gameObject ) do
                if type( propValue ) == "table" then
                    local componentObject = getmetatable( propValue )
                    if componentObject ~= nil and table.containsvalue( Daneel.Config.componentObjects, componentObject ) then
                        -- propValue is a component instance
                        if componentObject[ funcName ] ~= nil then
                            return componentObject[ funcName ]( propValue, value )
                        end
                    end
                end
            end
        end
    end
    rawset( gameObject, key, value )
end


----------------------------------------------------------------------------------

--- Create a new game object and optionally initialize it.
-- When the first argument is a scene name or asset, the scene may contains only one top-level game object.
-- If it's not the case, the function won't return any game object yet some may have been created (depending on the behavior of CS.AppendScene()).
-- @param name (string or Scene) The game object name or scene name or scene asset.
-- @param params (table) [optional] A table with parameters to initialize the new game object with.
-- @return (GameObject) The new game object.
function GameObject.New( name, params )
    Daneel.Debug.StackTrace.BeginFunction( "GameObject.New", name, params )
    local errorHead = "GameObject.New( name[, params] ) : "
    local argType = Daneel.Debug.CheckArgType( name, "name", {"string", "Scene"}, errorHead )
    Daneel.Debug.CheckOptionalArgType( params, "params", "table", errorHead )
    
    local gameObject = nil
    local scene = Asset.Get( name, "Scene" ) -- scene will be nil if name is a sting ad not a scene path
    if scene ~= nil then
        gameObject = CraftStudio.AppendScene( scene )
    else
        gameObject = CraftStudio.CreateGameObject( name )
    end

    if params ~= nil and gameObject ~= nil then
        gameObject:Set(params)
    end
    Daneel.Debug.StackTrace.EndFunction()
    return gameObject
end

--- Create a new game object with the content of the provided scene and optionally initialize it.
-- @param gameObjectName (string) The game object name.
-- @param sceneNameOrAsset (string or Scene) The scene name or scene asset.
-- @param params [optional] (table) A table with parameters to initialize the new game object with.
-- @return (GameObject) The new game object.
function GameObject.Instantiate(gameObjectName, sceneNameOrAsset, params)
    Daneel.Debug.StackTrace.BeginFunction("GameObject.Instantiate", gameObjectName, sceneNameOrAsset, params)
    local errorHead = "GameObject.Instantiate( gameObjectName, sceneNameOrAsset[, params] ) : "
    Daneel.Debug.CheckArgType(gameObjectName, "gameObjectName", "string", errorHead)
    Daneel.Debug.CheckArgType(sceneNameOrAsset, "sceneNameOrAsset", {"string", "Scene"}, errorHead)
    Daneel.Debug.CheckOptionalArgType(params, "params", "table", errorHead)

    local scene = Asset.Get(sceneNameOrAsset, "Scene", true)
    local gameObject = CraftStudio.Instantiate(gameObjectName, scene)
    if params ~= nil then
        gameObject:Set( params )
    end
    Daneel.Debug.StackTrace.EndFunction()
    return gameObject
end

--- Apply the content of the params argument to the provided game object.
-- @param gameObject (GameObject) The game object.
-- @param params (table) A table of parameters to set the game object with.
function GameObject.Set( gameObject, params )
    Daneel.Debug.StackTrace.BeginFunction( "GameObject.Set", gameObject, params )
    local errorHead = "GameObject.Set( gameObject, params ) : "
    Daneel.Debug.CheckArgType( gameObject, "gameObject", "GameObject", errorHead )
    Daneel.Debug.CheckArgType( params, "params", "table", errorHead )
    local argType = nil
    
    if params.parent ~= nil then
        -- do that first so that setting a local position works
        gameObject:SetParent( params.parent )
        params.parent = nil
    end

    if params.transform ~= nil then
        gameObject.transform:Set( params.transform )
        params.transform = nil
    end
    
    -- components
    for i, componentType in pairs( Daneel.Config.componentTypes ) do
        local component = nil

        if componentType ~= "ScriptedBehavior" then
            componentType = componentType:lower()

            -- check if params has a key for that component
            local componentParams = nil
            for key, value in pairs( params ) do
                if key:lower() == componentType then
                    componentParams = value
                    Daneel.Debug.CheckArgType( componentParams, "params."..key, "table", errorHead )
                    break
                end
            end

            if componentParams ~= nil then
                -- check if gameObject has a key for that component
                for key, value in pairs( gameObject ) do
                    if key:lower() == componentType then
                        component = value
                        break
                    end
                end
                
                if component == nil then -- can work for built-in components when their property on the game object has been unset for some reason
                    component = gameObject:GetComponent( componentType )
                end
                
                if component == nil then
                    component = gameObject:AddComponent( componentType )
                end

                component:Set( componentParams )
                table.removevalue( params, componentParams )
            end
        end
    end

    -- all other keys/values
    for key, value in pairs( params ) do

        -- if key is a script alias or a script path
        if Daneel.Config.scriptPaths[key] ~= nil or table.containsvalue( Daneel.Config.scriptPaths, key ) then
            local scriptPath = key
            if Daneel.Config.scriptPaths[key] ~= nil then
                scriptPath = Daneel.Config.scriptPaths[key]
            end

            local component = gameObject:GetScriptedBehavior( scriptPath )
            if component == nil then
                component = gameObject:AddComponent( scriptPath )
            end
            
            component:Set(value)

        elseif key == "tags"  then
            gameObject:RemoveTag()
            gameObject:AddTag( value )

        else
            gameObject[key] = value
        end
    end
    Daneel.Debug.StackTrace.EndFunction()
end


----------------------------------------------------------------------------------
-- Miscellaneous

--- Alias of CraftStudio.FindGameObject(name).
-- Get the first game object with the provided name.
-- @param name (string) The game object name.
-- @param errorIfGameObjectNotFound [optional default=false] (boolean) Throw an error if the game object was not found (instead of returning nil).
-- @return (GameObject) The game object or nil if none is found.
function GameObject.Get( name, errorIfGameObjectNotFound ) 
    if getmetatable(name) == GameObject then
        return name
    end

    Daneel.Debug.StackTrace.BeginFunction( "GameObject.Get", name, errorIfGameObjectNotFound )
    local errorHead = "GameObject.Get( name[, errorIfGameObjectNotFound] ) : "
    Daneel.Debug.CheckArgType( name, "name", "string", errorHead )
    Daneel.Debug.CheckOptionalArgType( errorIfGameObjectNotFound, "errorIfGameObjectNotFound", "boolean", errorHead )
    

    local gameObject = nil
    local names = string.split( name, "." )
    
    gameObject = CraftStudio.FindGameObject( names[1] )
    if gameObject == nil and errorIfGameObjectNotFound == true then
        error( errorHead.."GameObject with name '" .. names[1] .. "' (from '" .. name .. "') was not found." )
    end

    if gameObject ~= nil then
        local originalName = name
        local fullName = table.remove( names, 1 )

        for i, name in ipairs( names ) do
            gameObject = gameObject:GetChild( name )
            fullName = fullName .. "." .. name

            if gameObject == nil then
                if errorIfGameObjectNotFound == true then
                    error( errorHead.."GameObject with name '" .. fullName .. "' (from '" .. originalName .. "') was not found." )
                end

                break
            end
        end
    end

    Daneel.Debug.StackTrace.EndFunction()
    return gameObject
end

--- Returns the game object's internal unique identifier.
-- @param gameObject (GameObject) The game object.
-- @return (number) The id.
function GameObject.GetId( gameObject )
    return Daneel.Cache.GetId( gameObject )
end

local OriginalSetParent = GameObject.SetParent

--- Set the game object's parent. 
-- Optionaly carry over the game object's local transform instead of the global one.
-- @param gameObject (GameObject) The game object.
-- @param parentNameOrInstance [optional] (string or GameObject) The parent name or game object (or nil to remove the parent).
-- @param keepLocalTransform [optional default=false] (boolean) Carry over the game object's local transform instead of the global one.
function GameObject.SetParent(gameObject, parentNameOrInstance, keepLocalTransform)
    Daneel.Debug.StackTrace.BeginFunction("GameObject.SetParent", gameObject, parentNameOrInstance, keepLocalTransform)
    local errorHead = "GameObject.SetParent(gameObject, [parentNameOrInstance, keepLocalTransform]) : "
    Daneel.Debug.CheckArgType(gameObject, "gameObject", "GameObject", errorHead)
    Daneel.Debug.CheckOptionalArgType(parentNameOrInstance, "parentNameOrInstance", {"string", "GameObject"}, errorHead)
    keepLocalTransform = Daneel.Debug.CheckOptionalArgType(keepLocalTransform, "keepLocalTransform", "boolean", errorHead, false)

    local parent = nil
    if parentNameOrInstance ~= nil then
        parent = GameObject.Get(parentNameOrInstance, true)
    end
    OriginalSetParent(gameObject, parent, keepLocalTransform)
    Daneel.Debug.StackTrace.EndFunction()
end

--- Alias of GameObject.FindChild().
-- Find the first game object's child with the provided name.
-- If the name is not provided, it returns the first child.
-- @param gameObject (GameObject) The game object.
-- @param name [optional] (string) The child name (may be hyerarchy of names separated by dots).
-- @param recursive [optional default=false] (boolean) Search for the child in all descendants instead of just the first generation.
-- @return (GameObject) The child or nil if none is found.
function GameObject.GetChild( gameObject, name, recursive )
    Daneel.Debug.StackTrace.BeginFunction( "GameObject.GetChild", gameObject, name, recursive )
    local errorHead = "GameObject.GetChild( gameObject, name[, recursive] ) : "
    Daneel.Debug.CheckArgType( gameObject, "gameObject", "GameObject", errorHead )
    Daneel.Debug.CheckOptionalArgType( name, "name", "string", errorHead )
    recursive = Daneel.Debug.CheckOptionalArgType( recursive, "recursive", "boolean", errorHead, false )
    
    local child = nil
    if name == nil then
        local children = gameObject:GetChildren()
        child = children[1]
    else
        local names = string.split( name, "." )
        for i, name in ipairs( names ) do
            gameObject = gameObject:FindChild( name, recursive )

            if gameObject == nil then
                break
            end
        end
        child = gameObject
    end
    Daneel.Debug.StackTrace.EndFunction()
    return child
end

local OriginalGetChildren = GameObject.GetChildren

--- Get all descendants of the game object.
-- @param gameObject (GameObject) The game object.
-- @param recursive [optional default=false] (boolean) Look for all descendants instead of just the first generation.
-- @param includeSelf [optional default=false] (boolean) Include the game object in the children.
-- @return (table) The children.
function GameObject.GetChildren( gameObject, recursive, includeSelf )
    Daneel.Debug.StackTrace.BeginFunction( "GameObject.GetChildren", gameObject, recursive, includeSelf )
    local errorHead = "GameObject.GetChildren( gameObject[, recursive, includeSelf] ) : "
    Daneel.Debug.CheckArgType( gameObject, "gameObject", "GameObject", errorHead )
    Daneel.Debug.CheckOptionalArgType( recursive, "recursive", "boolean", errorHead )
    Daneel.Debug.CheckOptionalArgType( includeSelf, "includeSelf", "boolean", errorHead )

    local allChildren = OriginalGetChildren( gameObject )

    if recursive then
        for i, child in ipairs( table.copy( allChildren ) ) do
            allChildren = table.merge( allChildren, child:GetChildren( true ) )
        end
    end

    if includeSelf then
        table.insert( allChildren, 1, gameObject )
    end
    Daneel.Debug.StackTrace.EndFunction()
    return allChildren
end

local OriginalSendMessage = GameObject.SendMessage

--- Tries to call a method with the provided name on all the scriptedBehaviors attached to the game object. 
-- The data argument can be nil or a table you want the method to receive as its first (and only) argument.
-- If none of the scripteBehaviors attached to the game object or its children have a method matching the provided name, nothing happens. 
-- @param gameObject (GameObject) The game object.
-- @param functionName (string) The method name.
-- @param data [optional] (table) The data to pass along the method call.
function GameObject.SendMessage(gameObject, functionName, data)
    Daneel.Debug.StackTrace.BeginFunction("GameObject.SendMessage", gameObject, functionName, data)
    local errorHead = "GameObject.SendMessage(gameObject, functionName[, data]) : "
    Daneel.Debug.CheckArgType(gameObject, "gameObject", "GameObject", errorHead)
    Daneel.Debug.CheckArgType(functionName, "functionName", "string", errorHead)
    Daneel.Debug.CheckOptionalArgType(data, "data", "table", errorHead)
    
    if Daneel.Config.debug.enableDebug then
        -- prevent an error of type "La référence d'objet n'est pas définie à une instance d'un objet." to stops the script that sends the message
        local success = Daneel.Debug.Try( function()
            OriginalSendMessage( gameObject, functionName, data )
        end )

        if not success then
            local dataText = "No data"
            local length = 0
            if data ~= nil then
                length = table.getlength( data )
                dataText = "Data with "..length.." entries"
            end
            print( errorHead.."Error sending message with parameters : ", gameObject, functionName, dataText )
            if length > 0 then
                table.print( data )
            end
        end
    else
        OriginalSendMessage( gameObject, functionName, data )
    end

    Daneel.Debug.StackTrace.EndFunction()
end

--- Tries to call a method with the provided name on all the scriptedBehaviors attached to the game object or any of its descendants. 
-- The data argument can be nil or a table you want the method to receive as its first (and only) argument.
-- If none of the scripteBehaviors attached to the game object or its children have a method matching the provided name, nothing happens. 
-- @param gameObject (GameObject) The game object.
-- @param functionName (string) The method name.
-- @param data [optional] (table) The data to pass along the method call.
function GameObject.BroadcastMessage(gameObject, functionName, data)
    Daneel.Debug.StackTrace.BeginFunction("GameObject.BroadcastMessage", gameObject, functionName, data)
    local errorHead = "GameObject.BroadcastMessage(gameObject, functionName[, data]) : "
    Daneel.Debug.CheckArgType(gameObject, "gameObject", "GameObject", errorHead)
    Daneel.Debug.CheckArgType(functionName, "functionName", "string", errorHead)
    Daneel.Debug.CheckOptionalArgType(data, "data", "table", errorHead)
    
    local allGos = gameObject:GetChildren(true, true) -- the game object + all of its children
    for i, go in ipairs(allGos) do
        go:SendMessage(functionName, data)
    end
    Daneel.Debug.StackTrace.EndFunction()
end


----------------------------------------------------------------------------------
-- Add components

--- Add a component to the game object and optionally initialize it.
-- @param gameObject (GameObject) The game object.
-- @param componentType (string or Script) The component type, or script asset, path or alias (can't be Transform or ScriptedBehavior).
-- @param params [optional] (string, Script or table) A table of parameters to initialize the new component with or, if componentType is 'ScriptedBehavior', the mandatory script name or asset.
-- @return (mixed) The component.
function GameObject.AddComponent( gameObject, componentType, params )
    Daneel.Debug.StackTrace.BeginFunction( "GameObject.AddComponent", gameObject, componentType, params )
    local errorHead = "GameObject.AddComponent( gameObject, componentType[, params] ) : "
    Daneel.Debug.CheckArgType( gameObject, "gameObject", "GameObject", errorHead )
    Daneel.Debug.CheckArgType( componentType, "componentType", {"string", "Script"}, errorHead )
    componentType = Daneel.Debug.CheckArgValue( componentType, "componentType", Daneel.Config.componentTypes, errorHead, componentType )
    Daneel.Debug.CheckOptionalArgType( params, "params", "table", errorHead )    

    local component = nil
    
    if Daneel.Config.componentObjects[ componentType ] == nil then
        -- componentType is not one of the component types
        -- it may be a script path, alias or asset
        local script = Asset.Get( componentType, "Script" )
        if script == nil then
            if Daneel.Config.debug.enableDebug then
                error( errorHead.."Provided component type '"..tostring(componentType).."' in not one of the component types, nor a script asset, path or alias." )
            end
            Daneel.Debug.StackTrace.EndFunction()
            return
        end

        if params == nil then
            params = {}
        end
        component = gameObject:CreateScriptedBehavior( script, params )
        params = nil
    
    elseif Daneel.DefaultConfig().componentObjects[ componentType ] ~= nil then
        -- built-in component type
        if componentType == "Transform" then
            if Daneel.Config.debug.enableDebug then
                print( errorHead.."Can't add a transform component because gameObjects may only have one transform." )
            end
            Daneel.Debug.StackTrace.EndFunction()
            return
        elseif componentType == "ScriptedBehavior" then
            if Daneel.Config.debug.enableDebug then
                print( errorHead.."To add a scripted behavior, pass the script asset, path or alias instead of 'ScriptedBehavior' as argument 'componentType'." )
            end
            Daneel.Debug.StackTrace.EndFunction()
            return
        end

        component = gameObject:CreateComponent( componentType )

        local defaultComponentParams = Daneel.Config[ string.lcfirst( componentType ) ]
        if defaultComponentParams ~= nil then
            params = table.merge( defaultComponentParams, params )
        end

    else
        -- custom component type
        local componentObject = Daneel.Config.componentObjects[ componentType ]

        if componentObject ~= nil and type( componentObject.New ) == "function" then
            component = componentObject.New( gameObject )
        else
            if Daneel.Config.debug.enableDebug then
                error( errorHead.."Custom component of type '"..componentType.."' does not provide a New() function; Can't create the component." )
            end
            Daneel.Debug.StackTrace.EndFunction()
            return
        end
    end
    
    if params ~= nil and component ~= nil then
        component:Set( params )
    end

    Daneel.Event.Fire( gameObject, "OnNewComponent", component )
    Daneel.Debug.StackTrace.EndFunction()
    return component
end


----------------------------------------------------------------------------------
-- Get components

local OriginalGetComponent = GameObject.GetComponent
local OriginalGetScriptedBehavior = GameObject.GetScriptedBehavior

--- Get the first component of the provided type attached to the game object.
-- @param gameObject (GameObject) The game object.
-- @param componentType (string or Script) The component type, or script asset, path or alias.
-- @return (One of the component types) The component instance, or nil if none is found.
function GameObject.GetComponent( gameObject, componentType )
    Daneel.Debug.StackTrace.BeginFunction( "GameObject.GetComponent", gameObject, componentType )
    local errorHead = "GameObject.GetComponent( gameObject, componentType ) : "
    Daneel.Debug.CheckArgType( gameObject, "gameObject", "GameObject", errorHead )
    local argType = Daneel.Debug.CheckArgType( componentType, "componentType", {"string", "Script"}, errorHead )
    componentType = Daneel.Debug.CheckArgValue( componentType, "componentType", Daneel.Config.componentTypes, errorHead, componentType )
    
    local lcComponentType = componentType
    if argType == "string" then
        lcComponentType = string.lcfirst( componentType )
    end
    local component = nil
    if lcComponentType ~= "scriptedBehavior" then
        component = gameObject[ lcComponentType ]
    end
    
    if component == nil then
        if Daneel.DefaultConfig().componentObjects[ componentType ] ~= nil then
            component = OriginalGetComponent( gameObject, componentType )
        elseif Daneel.Config.componentObjects[ componentType ] == nil then -- not a custom component either
            local script = Asset.Get( componentType, "Script", true ) -- componentType is the script path or asset
            component = OriginalGetScriptedBehavior( gameObject, script )
        end
    end

    Daneel.Debug.StackTrace.EndFunction()
    return component
end

--- Get the provided scripted behavior instance attached to the game object.
-- @param gameObject (GameObject) The game object.
-- @param scriptNameOrAsset (string or Script) The script name or asset.
-- @return (ScriptedBehavior) The ScriptedBehavior instance.
function GameObject.GetScriptedBehavior( gameObject, scriptNameOrAsset )
    Daneel.Debug.StackTrace.BeginFunction( "GameObject.GetScriptedBehavior", gameObject, scriptNameOrAsset )
    local errorHead = "GameObject.GetScriptedBehavior( gameObject, scriptNameOrAsset ) : "
    Daneel.Debug.CheckArgType( gameObject, "gameObject", "GameObject", errorHead )
    Daneel.Debug.CheckArgType( scriptNameOrAsset, "scriptNameOrAsset", {"string", "Script"}, errorHead )

    local script = Asset.Get( scriptNameOrAsset, "Script", true )
    local component = OriginalGetScriptedBehavior( gameObject, script )
    Daneel.Debug.StackTrace.EndFunction()
    return component
end


----------------------------------------------------------------------------------
-- Destroy game object

--- Destroy the game object at the end of this frame.
-- @param gameObject (GameObject) The game object.
function GameObject.Destroy( gameObject )
    Daneel.Debug.StackTrace.BeginFunction( "GameObject.Destroy", gameObject )
    local errorHead = "GameObject.Destroy( gameObject ) : "
    Daneel.Debug.CheckArgType( gameObject, "gameObject", "GameObject", errorHead )

    for i, go in pairs( gameObject:GetChildren( true, true ) ) do -- recursive, include self
        go:RemoveTag()
    end

    for key, value in pairs( gameObject ) do
        if key ~= "inner" and type( value ) == "table" then -- in the Webplayer inner is a regular object, considered of type table and not userdata
            Daneel.Event.Fire( value, "OnDestroy", value )
        end
    end

    CraftStudio.Destroy( gameObject )
    Daneel.Debug.StackTrace.EndFunction()
end


----------------------------------------------------------------------------------
-- Tags

GameObject.Tags = {}
-- GameObject.Tags is emptied in Daneel:Awake()

--- Returns the game object(s) that have all the provided tag(s).
-- @param tag (string or table) One or several tag(s) (as a string or table of strings).
-- @return (table) The game object(s) (empty if none is found).
function GameObject.GetWithTag( tag )
    Daneel.Debug.StackTrace.BeginFunction( "GameObject.GetWithTag", tag )
    local errorHead = "GameObject.GetWithTag( tag ) : "
    local argType = Daneel.Debug.CheckArgType( tag, "tag", {"string", "table"}, errorHead )

    local tags = tag
    if argType == "string" then
        tags = { tags }
    end

    local gameObjectsWithTag = {}
    local reindex = false

    for i, tag in pairs( tags ) do
        local gameObjects = GameObject.Tags[ tag ]
        if gameObjects ~= nil then
            for j, gameObject in pairs( gameObjects ) do
                if gameObject.inner ~= nil then
                    if gameObject:HasTag( tags ) and not table.containsvalue( gameObjectsWithTag, gameObject ) then
                        table.insert( gameObjectsWithTag, gameObject )
                    end
                else
                    gameObjects[ j ] = nil
                    reindex = true
                end
            end
            if reindex then
                GameObject.Tags[ tag ] = table.reindex( gameObjects )
                reindex = false
            end
        end
    end

    Daneel.Debug.StackTrace.EndFunction()
    return gameObjectsWithTag
end

--- Returns the tag(s) of the provided game object.
-- @param gameObject (GameObject) The game object.
-- @return (table) The tag(s) (empty if the game object has no tag).
function GameObject.GetTags( gameObject )
    Daneel.Debug.StackTrace.BeginFunction( "GameObject.GetTags", gameObject )
    local errorHead = "GameObject.GetTags( gameObject ) : "
    Daneel.Debug.CheckArgType( gameObject, "gameObject", "GameObject", errorHead )

    local tags = {}

    for tag, gameObjects in pairs( GameObject.Tags ) do
        if table.containsvalue( gameObjects, gameObject ) then
            table.insert( tags, tag )
        end
    end

    Daneel.Debug.StackTrace.EndFunction()
    return tags
end

--- Add the provided tag(s) to the provided game object.
-- @param gameObject (GameObject) The game object.
-- @param tag (string or table) One or several tag(s) (as a string or table of strings).
function GameObject.AddTag( gameObject, tag )
    Daneel.Debug.StackTrace.BeginFunction( "GameObject.AddTag", gameObject, tag )
    local errorHead = "GameObject.AddTag( gameObject, tag ) : "
    Daneel.Debug.CheckArgType( gameObject, "gameObject", "GameObject", errorHead )
    Daneel.Debug.CheckArgType( tag, "tag", {"string", "table"}, errorHead )
    
    local tags = tag
    if type( tags ) == "string" then
        tags = { tags }
    end

    for i, tag in pairs( tags ) do
        if GameObject.Tags[ tag ] == nil then
            GameObject.Tags[ tag ] = { gameObject }
        elseif not table.containsvalue( GameObject.Tags[ tag ], gameObject ) then
            table.insert( GameObject.Tags[ tag ], gameObject )
        end
    end

    Daneel.Debug.StackTrace.EndFunction()
end

--- Remove the provided tag(s) from the provided game object.
-- If the 'tag' argument is not provided, all tag of the game object will be removed.
-- @param gameObject (GameObject) The game object.
-- @param tag [optional] (string or table) One or several tag(s) (as a string or table of strings).
function GameObject.RemoveTag( gameObject, tag )
    Daneel.Debug.StackTrace.BeginFunction( "GameObject.RemoveTag", gameObject, tag )
    local errorHead = "GameObject.RemoveTag( gameObject[, tag] ) : "
    Daneel.Debug.CheckArgType( gameObject, "gameObject", "GameObject", errorHead )
    Daneel.Debug.CheckOptionalArgType( tag, "tag", {"string", "table"}, errorHead )
    
    local tags = tag
    if type( tags ) == "string" then
        tags = { tags }
    end

    for tag, gameObjects in pairs( GameObject.Tags ) do
        if tags == nil or table.containsvalue( tags, tag ) then
            table.removevalue( GameObject.Tags[ tag ], gameObject )
        end
    end
    Daneel.Debug.StackTrace.EndFunction()
end

--- Tell whether the provided game object has all (or at least one of) the provided tag(s).
-- @param gameObject (GameObject) The game object.
-- @param tag (string or table) One or several tag (as a string or table of strings).
-- @param atLeastOneTag [default=false] (boolean) If true, returns true if the game object has AT LEAST one of the tag (instead of ALL the tag).
-- @return (boolean) True
function GameObject.HasTag( gameObject, tag, atLeastOneTag )
    Daneel.Debug.StackTrace.BeginFunction( "GameObject.HasTag", gameObject, tag, atLeastOneTag )
    local errorHead = "GameObject.HasTag( gameObject, tag ) : "
    Daneel.Debug.CheckArgType( gameObject, "gameObject", "GameObject", errorHead )
    Daneel.Debug.CheckArgType( tag, "tag", {"string", "table"}, errorHead )
    Daneel.Debug.CheckOptionalArgType( atLeastOneTag, "atLeastOneTag", "boolean", errorHead )

    local tags = tag
    if type(tags) == "string" then
        tags = { tags }
    end
    local hasTags = false
    if atLeastOneTag == true then
        for i, tag in pairs( tags ) do
            if GameObject.Tags[ tag ] ~= nil and table.containsvalue( GameObject.Tags[ tag ], gameObject ) then
                hasTags = true
                break
            end
        end
    else
        hasTags = true
        for i, tag in pairs( tags ) do
            if GameObject.Tags[ tag ] == nil or not table.containsvalue( GameObject.Tags[ tag ], gameObject ) then
                hasTags = false
                break
            end
        end
    end

    Daneel.Debug.StackTrace.EndFunction()
    return hasTags
end
