-- CraftStudio.lua
-- Contains most of the objects and functions extending CraftStudio's base API
--
-- Last modified for v1.2.0
-- Copyright © 2013 Florent POUJOL, published under the MIT licence.


if CS.DaneelModules == nil then
    CS.DaneelModules = {}
end
table.insert( CS.DaneelModules, CraftStudio )

function CraftStudio.Config()
    local config = {
        craftStudio = {
            -- List of the Scripts paths as values and optionally the script alias as the keys.
            -- Ie :
            -- "fully-qualified Script path"
            -- or
            -- alias = "fully-qualified Script path"
            --
            -- Setting a script path here allow you to  :
            -- * Use the dynamic getters and setters
            -- * Use component:Set() (for scripted behaviors)
            -- * Use component:GetId() (for scripted behaviors)
            -- * If you defined aliases, dynamically access the scripted behavior on the game object via its alias
            scriptPaths = {},

            -- Default CraftStudio's components settings (except Transform)
            --[[ ie :
            textRenderer = {
                font = "MyFont",
                alignment = "right",
            },
            ]]

            objects = {
                GameObject = GameObject,
                Vector3 = Vector3,
                Quaternion = Quaternion,
                Plane = Plane,
                Ray = Ray,
            },

            componentObjects = {
                ScriptedBehavior = ScriptedBehavior,
                ModelRenderer = ModelRenderer,
                MapRenderer = MapRenderer,
                Camera = Camera,
                Transform = Transform,
                Physics = Physics,
                TextRenderer = TextRenderer,
                NetworkSync = NetworkSync,
            },

            assetObjects = {
                Script = Script,
                Model = Model,
                ModelAnimation = ModelAnimation,
                Map = Map,
                TileSet = TileSet,
                Sound = Sound,
                Scene = Scene,
                --Document = Document,
                Font = Font,
            },
        },
    }

    CS.Config = config.craftStudio

    CS.Config.componentTypes       = table.getkeys( CS.Config.componentObjects )
    CS.Config.assetTypes           = table.getkeys( CS.Config.assetObjects )

    Daneel.Config.allComponentObjects       = table.merge( Daneel.Config.allComponentObjects, CS.Config.componentObjects )
    Daneel.Config.allComponentTypes         = table.merge( Daneel.Config.allComponentTypes, CS.Config.componentObjects )
    
    Daneel.Config.allObjects = table.merge(
        Daneel.Config.allObjects,
        CS.Config.objects,
        CS.Config.componentObjects,
        CS.Config.assetObjects,
    )

    return config
end


function CraftStudio.Load()
    -- ScriptAlias
    for alias, path in pairs( CS.Config.scriptPaths ) do
        local script = CraftStudio.FindAsset( path, "Script" )

        if script ~= nil then
            Daneel.Utilities.AllowDynamicGettersAndSetters( script, { Script, Component } )

            script["__tostring"] = function( scriptedBehavior )
                return "ScriptedBehavior: " .. tostring( scriptedBehavior.inner ):sub( 2, 20 ) .. ": '" .. path .. "'"
            end
        else
            CS.Config.scriptPaths[ alias ] = nil
            if Daneel.Config.debug.enableDebug then
                print( "Daneel.Load() : WARNING : item with key '" .. alias .. "' and value '" .. path .. "' in 'Daneel.Config.craftStudio.scriptPaths' is not a valid script path." )
            end
        end
    end

    -- Components
    for componentType, componentObject in pairs( Daneel.Config.allComponentObjects ) do
        Daneel.Utilities.AllowDynamicGettersAndSetters( componentObject, { Component } )

        if componentType ~= "ScriptedBehavior" then
            componentObject["__tostring"] = function( component )
                -- returns something like "ModelRenderer: 123456789"    component.inner is "?: [some ID]"
                -- do not use component:GetId() here, it throws a stack overflow when stacktrace is enabled because ST.BeginFunction() uses tostring() on the provided argument(s)
                local id = component.Id
                if id == nil then
                    id = tostring( component.inner ):sub( 5, 20 )
                    component.Id = id
                end
                
                local text = componentType .. ": " .. id
                --[[
                -- uncomment when the getter won't return error when the asset is not set yet
                local path = "[no asset]"
                local pathStart = ": '"
                local pathEnd = "'"
                local asset = nil

                if componentType == "ModelRenderer" then
                    asset = component:GetModel()
                    if asset ~=  nil then
                        path = Map.GetPathInPackage( asset )
                    else
                        path = "[no Map]"
                    end
                    text = text .. pathStart .. path .. pathEnd

                elseif componentType == "MapRenderer" then
                    asset = component:GetMap()
                    if asset ~= nil then
                        path = Map.GetPathInPackage( asset )
                    else
                        path = "[no Map]"
                    end
                    text = text .. pathStart .. path .. pathEnd

                    asset = component:GetTileSet()
                    if asset ~= nil then
                        path = Map.GetPathInPackage( asset )
                    else
                        path = "[no TileSet]"
                    end
                    text = text .. pathStart .. path .. pathEnd

                elseif componentType == "TextRenderer" then
                    asset = component:GetFont()
                    if asset ~= nil then
                        path = Map.GetPathInPackage( asset )
                    else
                        path = "[no Font]"
                    end
                    text = text .. pathStart .. path .. pathEnd

                end
                ]]

                return text
            end
        end
    end

    -- Assets
    for assetType, assetObject in pairs( CS.Config.assetObjects ) do
        Daneel.Utilities.AllowDynamicGettersAndSetters( assetObject )

        assetObject["__tostring"] = function( asset )
            -- print something like : "Model: 123456789"    asset.inner is "CraftStudioCommon.ProjectData.[AssetType]: [some ID]"
            return tostring( asset.inner ):sub( 31, 50 ) .. ": '" .. Map.GetPathInPackage( asset ) .. "'"
        end
    end
end -- end of CrafStudio.Load()


----------------------------------------------------------------------------------
-- Assets

Asset = { 
    -- the key may be :
    -- the asset object itself, the value is true
    -- or the asset name, the value is a table with the asset type as keys and asset object as values
    -- (allows two assets to have the same name)
    cache = { ["ScriptAliases"] = {} },

    pathsCache = {},
}
Asset.__index = Asset

--- Alias of CraftStudio.FindAsset( assetPath[, assetType] ).
-- Get the asset of the specified name and type.
-- The first argument may be an asset object, so that you can check if a variable was an asset object or name (and get the corresponding object).
-- @param assetPath (string or one of the asset type) The fully-qualified asset name or asset object.
-- @param assetType [optional] (string) The asset type as a case-insensitive string.
-- @param errorIfAssetNotFound [optional default=false] Throw an error if the asset was not found (instead of returning nil).
-- @return (One of the asset type) The asset, or nil if none is found.
function Asset.Get( assetPath, assetType, errorIfAssetNotFound )
    -- the key in the cache may be the asset path, the asset Object, or "ScriptAliases"
    local assetByType = Asset.cache[ assetPath ]
    
    if assetByType ~= nil then
        if type( assetByType ) == "boolean" then -- assetPath is an asset  -  can't check if assetByType == true because it is otherwise a table and also returns true            
            return assetPath
        
        elseif assetType ~= nil and assetByType[ assetType ] ~= nil then
            return assetByType[ assetType ]
        end
    end

    if Asset.cache[ "ScriptAliases" ][ assetPath ] ~= nil then
        return Asset.cache[ "ScriptAliases" ][ assetPath ]
    end

    Daneel.Debug.StackTrace.BeginFunction( "Asset.Get", assetPath, assetType, errorIfAssetNotFound )
    local errorHead = "Asset.Get( assetPath[, assetType, errorIfAssetNotFound] ) : "
    
    -- just return the asset if assetPath is already an object
    if type( assetPath ) == "table" and CS.Config.assetObjects[ Daneel.Debug.GetType( assetPath ) ] then
        -- using type() in the first part of the condition just prevent GetType() and containsvalue() to be called every times
        Asset.cache[ assetPath ] = true
        Daneel.Debug.StackTrace.EndFunction()
        return assetPath
    end
    Daneel.Debug.CheckArgType( assetPath, "assetPath", "string", errorHead )
    
    -- check asset type
    if assetType ~= nil then
        Daneel.Debug.CheckArgType( assetType, "assetType", "string", errorHead )
        assetType = Daneel.Debug.CheckArgValue( assetType, "assetType", CS.Config.assetTypes, errorHead )
    end
    Daneel.Debug.CheckOptionalArgType( errorIfAssetNotFound, "errorIfAssetNotFound", "boolean", errorHead )

    -- check if assetPath is a script alias
    local scriptAlias = assetPath
    if CS.Config.scriptPaths[ scriptAlias ] ~= nil then 
        assetPath = CS.Config.scriptPaths[ scriptAlias ]
        assetType = "Script"
    end

    -- get asset
    local asset = CraftStudio.FindAsset( assetPath, assetType )

    if asset == nil then
        if errorIfAssetNotFound == true then
            if assetType == nil then
                assetType = "asset"
            end
            error( errorHead .. "Argument 'assetPath' : " .. assetType .. " with name '" .. assetPath .. "' was not found." )
        end
    else
        -- cache asset
        if assetType == nil then
            assetType = Daneel.Debug.GetType( asset )
        end

        if Asset.cache[ assetPath ] == nil then
            Asset.cache[ assetPath ] = {}
        end
        Asset.cache[ assetPath ][ assetType ] = asset

        if scriptAlias ~= assetPath then -- scriptAlias is indeed a script alias
            Asset.cache[ "ScriptAliases" ][ scriptAlias ] = asset
        end
    end

    Daneel.Debug.StackTrace.EndFunction()
    return asset
end

--- Returns the path of the provided asset.
-- @param asset (One of the asset types) The asset instance.
-- @return (string) The fully-qualified asset path.
function Asset.GetPath( asset )
    if Asset.pathsCache[ asset ] ~= nil then
        return Asset.pathsCache[ asset ]
    end

    Daneel.Debug.StackTrace.BeginFunction( "Asset.GetPath", asset )
    local errorHead = "Asset.GetPath( asset ) : "
    Daneel.Debug.CheckArgType( asset, "asset", CS.Config.assetTypes, errorHead )

    local path = Map.GetPathInPackage( asset )
    Asset.pathsCache[ asset ] = path

    Daneel.Debug.StackTrace.EndFunction()
    return path
end


----------------------------------------------------------------------------------
-- Components

Component = {}
Component.__index = Component

--- Apply the content of the params argument to the provided component.
-- @param component (any component's type) The component.
-- @param params (table) A table of parameters to set the component with.
function Component.Set(component, params)
    Daneel.Debug.StackTrace.BeginFunction("Component.Set", component, params)
    local errorHead = "Component.Set(component, params) : "
    Daneel.Debug.CheckArgType(component, "component", Daneel.Config.allComponentTypes, errorHead)
    Daneel.Debug.CheckArgType(params, "params", "table", errorHead)

    local componentType = Daneel.Debug.GetType(component)
    if componentType == "Toggle" then
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
-- @param component (any component's type) The component.
function Component.Destroy( component )
    Daneel.Debug.StackTrace.BeginFunction( "Component.Destroy", component )
    local errorHead = "Component.Destroy( component ) : "
    Daneel.Debug.CheckArgType( component, "component", Daneel.Config.allComponentTypes, errorHead )

    table.removevalue( component.gameObject, component )
    CraftStudio.Destroy( component )
    Daneel.Debug.StackTrace.EndFunction()
end

--- Returns the component's internal unique identifier.
-- @param component (any component's type) The component.
-- @return (number) The id (-1 if something goes wrong)
function Component.GetId( component )
    Daneel.Debug.StackTrace.BeginFunction( "Component.GetId", component )
    local errorHead = "Component.GetId( component ) : "
    Daneel.Debug.CheckArgType( component, "component", Daneel.Config.allComponentTypes, errorHead )

    if component.Id ~= nil then
        Daneel.Debug.StackTrace.EndFunction()
        return component.Id
    end

    local id = -1
    if component.inner ~= nil then
        id = tostring( component.inner ):sub( 5, 20 )
        rawset( component, "Id", id )
    end
    Daneel.Debug.StackTrace.EndFunction()
    return id
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
-- @param modelNameOrAsset (string or Model) The model name or asset, or nil.
function ModelRenderer.SetModel( modelRenderer, modelNameOrAsset )
    Daneel.Debug.StackTrace.BeginFunction( "ModelRenderer.SetModel", modelRenderer, modelNameOrAsset )
    local errorHead = "ModelRenderer.SetModel( modelRenderer, modelNameOrAsset ) : "
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
-- @param animationNameOrAsset (string or ModelAnimation) The animation name or asset, or nil.
function ModelRenderer.SetAnimation( modelRenderer, animationNameOrAsset )
    Daneel.Debug.StackTrace.BeginFunction( "ModelRenderer.SetModelAnimation", modelRenderer, animationNameOrAsset )
    local errorHead = "ModelRenderer.SetModelAnimation( modelRenderer, animationNameOrAsset ) : "
    Daneel.Debug.CheckArgType( modelRenderer, "modelRenderer", "ModelRenderer", errorHead)
    Daneel.Debug.CheckOptionalArgType( animationNameOrAsset, "animationNameOrAsset", {"string", "ModelAnimation"}, errorHead )

    local animation = nil 
    if animationNameOrAsset ~= nil then
        animation = Asset.Get( animationNameOrAsset, "ModelAnimation", true )
    end
    OriginalSetAnimation( modelRenderer, animation )
    Daneel.Debug.StackTrace.EndFunction()
end


----------------------------------------------------------------------------------
-- MapRenderer

local OriginalSetMap = MapRenderer.SetMap

--- Attach the provided map to the provided mapRenderer.
-- @param mapRenderer (MapRenderer) The mapRenderer.
-- @param mapNameOrAsset (string or Map) The map name or asset.
-- @param keepTileSet [optional default=false] (boolean) Keep the current TileSet.
function MapRenderer.SetMap( mapRenderer, mapNameOrAsset, keepTileSet )
    Daneel.Debug.StackTrace.BeginFunction( "MapRenderer.SetMap", mapRenderer, mapNameOrAsset )
    local errorHead = "MapRenderer.SetMap( mapRenderer, mapNameOrAsset) : "
    Daneel.Debug.CheckArgType( mapRenderer, "mapRenderer", "MapRenderer", errorHead )
    Daneel.Debug.CheckOptionalArgType( mapNameOrAsset, "mapNameOrAsset", {"string", "Map"}, errorHead )
    keepTileSet = Daneel.Debug.CheckOptionalArgType( keepTileSet, "keepTileSet", "boolean", errorHead, false )

    local map = nil
    if mapNameOrAsset ~= nil then
        map = Asset.Get( mapNameOrAsset, "Map", true )
    end
    OriginalSetMap( mapRenderer, map, keepTileSet )
    Daneel.Debug.StackTrace.EndFunction()
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
function TextRenderer.SetFont( textRenderer, fontNameOrAsset )
    Daneel.Debug.StackTrace.BeginFunction( "TextRenderer.SetFont", textRenderer, fontNameOrAsset )
    local errorHead = "TextRenderer.SetFont( textRenderer, fontNameOrAsset ) : "
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
    local argType = Daneel.Debug.CheckArgType(alignment, "alignment", {"string", "userdata"}, errorHead)

    if argType == "string" then
        alignment = Daneel.Debug.CheckArgValue( alignment, "alignment", {"Left", "Center", "Right"}, errorHead, "Left" )
        alignment = TextRenderer.Alignment[ alignment ]
    end
    OriginalSetAlignment( textRenderer, alignment )
    Daneel.Debug.StackTrace.EndFunction()
end

--- Update the gameObject's scale to make the text appear the provided width.
-- @param textRenderer (TextRenderer) The textRenderer.
-- @param width (number or string) The text's width in units or pixels.
function TextRenderer.SetTextWidth( textRenderer, width )
    Daneel.Debug.StackTrace.BeginFunction("TextRenderer.SetTextWidth", textRenderer, width)
    local errorHead = "TextRenderer.SetTextWidth(textRenderer, width) : "
    Daneel.Debug.CheckArgType(textRenderer, "textRenderer", "TextRenderer", errorHead)
    local argType = Daneel.Debug.CheckArgType(width, "width", {"number", "string"}, errorHead)

    if argType == "string" then
        if Daneel.GUI == nil then
            error( errorHead .. "The GUI module is not loaded. Can't convert width in pixels with value '" .. width .. "' to scene units.")
        end
        width = width:sub( 1, #width-2 )
        width = width * Daneel.GUI.pixelsToUnits
    end
    
    local widthScaleRatio = textRenderer:GetTextWidth() / textRenderer.gameObject.transform:GetScale()
    textRenderer.gameObject.transform:SetScale( width / widthScaleRatio )
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
-- @return (RaycastHit) A raycastHit with the if there was a collision, or nil.
function Ray.IntersectsGameObject( ray, gameObjectNameOrInstance )
    Daneel.Debug.StackTrace.BeginFunction( "Ray.IntersectsGameObject", ray, gameObjectNameOrInstance )
    local errorHead = "Ray.IntersectsGameObject( ray, gameObjectNameOrInstance ) : "
    Daneel.Debug.CheckArgType( ray, "ray", "Ray", errorHead )
    Daneel.Debug.CheckArgType( gameObjectNameOrInstance, "gameObjectNameOrInstance", {"string", "GameObject"}, errorHead )
    
    local gameObject = GameObject.Get( gameObjectNameOrInstance, true )
    local raycastHit = nil

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
    Daneel.Debug.StackTrace.BeginFunction( "Ray.IntersectsPlane", ray, plane, returnRaycastHit )
    local errorHead = "Ray.IntersectsPlane( ray, plane[, returnRaycastHit] )"
    Daneel.Debug.CheckArgType( ray, "ray", "Ray", errorHead )
    Daneel.Debug.CheckArgType( plane, "plane", "Plane", errorHead )
    returnRaycastHit = Daneel.Debug.CheckOptionalArgType( returnRaycastHit, "returnRaycastHit", "boolean", errorHead, false )

    local distance = OriginalIntersectsPlane( ray, plane )
    if returnRaycastHit and distance ~= nil then
        local raycastHit = RaycastHit.New()
        raycastHit.distance = distance
        raycastHit.hitLocation = ray.position + ray.direction * distance
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
    local errorHead = "Ray.IntersectsModelRenderer( ray, modelRenderer[, returnRaycastHit] )"
    Daneel.Debug.CheckArgType( ray, "ray", "Ray", errorHead )
    Daneel.Debug.CheckArgType( modelRenderer, "modelRenderer", "ModelRenderer", errorHead )
    returnRaycastHit = Daneel.Debug.CheckOptionalArgType( returnRaycastHit, "returnRaycastHit", "boolean", errorHead, false )

    local distance, normal = OriginalIntersectsModelRenderer( ray, modelRenderer )
    if returnRaycastHit and distance ~= nil then
        local raycastHit = RaycastHit.New()
        raycastHit.distance = distance
        raycastHit.normal = normal
        raycastHit.hitLocation = ray.position + ray.direction * distance

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
    local errorHead = "Ray.IntersectsMapRenderer( ray, mapRenderer[, returnRaycastHit] )"
    Daneel.Debug.CheckArgType( ray, "ray", "Ray", errorHead )
    Daneel.Debug.CheckArgType( mapRenderer, "mapRenderer", "MapRenderer", errorHead )
    returnRaycastHit = Daneel.Debug.CheckOptionalArgType( returnRaycastHit, "returnRaycastHit", "boolean", errorHead, false )

    local distance, normal, hitBlockLocation, adjacentBlockLocation = OriginalIntersectsMapRenderer( ray, mapRenderer )
    if returnRaycastHit and distance ~= nil then
        local raycastHit = RaycastHit.New()
        raycastHit.distance = distance
        raycastHit.normal = normal
        raycastHit.hitBlockLocation = hitBlockLocation
        raycastHit.adjacentBlockLocation = adjacentBlockLocation
        raycastHit.hitLocation = ray.position + ray.direction * distance

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
    local errorHead = "Ray.IntersectsTextRenderer( ray, textRenderer[, returnRaycastHit] )"
    Daneel.Debug.CheckArgType( ray, "ray", "Ray", errorHead )
    Daneel.Debug.CheckArgType( textRenderer, "textRenderer", "TextRenderer", errorHead )
    returnRaycastHit = Daneel.Debug.CheckOptionalArgType( returnRaycastHit, "returnRaycastHit", "boolean", errorHead, false )

    local distance, normal, hitBlockLocation, adjacentBlockLocation  = OriginalIntersectsTextRenderer( ray, textRenderer )
    if returnRaycastHit and distance ~= nil then
        local raycastHit = RaycastHit.New()
        raycastHit.distance = distance
        raycastHit.normal = normal
        raycastHit.hitLocation = ray.position + ray.direction * distance

        distance = raycastHit
        normal = nil
    end

    Daneel.Debug.StackTrace.EndFunction()
    return distance, normal
end


----------------------------------------------------------------------------------
-- RaycastHit

RaycastHit = {}
RaycastHit.__index = RaycastHit
setmetatable( RaycastHit, { __call = function(Object, ...) return Object.New(...) end } )

if CS.DaneelModules == nil then
    CS.DaneelModules = {}
end
table.insert( CS.DaneelModules, RayCastHit )

function RayCastHit.Config()
    Daneel.Config.allObjects.RaycastHit = RaycastHit
end

function RaycastHit.__tostring() 
    return "RaycastHit"
end

--- Create a new RaycastHit
-- @return (RaycastHit) The raycastHit.
function RaycastHit.New( data )
    Daneel.Debug.StackTrace.BeginFunction( "RaycastHit.New" )
    local errorHead = "RaycastHit.New( [data] ) : "
    data = Daneel.Debug.CheckOptionalArgType( data, "data", "table", errorHead, {} )

    local raycastHit = setmetatable( data, RaycastHit )
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
    Daneel.Event.fireAtTime = {}
    Daneel.Event.fireAtRealTime = {}
    Daneel.Event.fireAtFrame = {}

    Scene.current = scene

    Daneel.Debug.StackTrace.EndFunction()
    OriginalLoadScene( scene )
end

--- Alias of CraftStudio.AppendScene().
-- Appends the specified scene to the game by instantiating all of its game objects. Contrary to CraftStudio.LoadScene, this doesn't unload the current scene nor waits for the next tick: it happens right away.
-- You can optionally specify a parent game object which will be used as a root for adding all game objects. 
-- Returns the gameObject appended if there was only one root game object in the provided scene.
-- @param sceneNameOrAsset (string or Scene) The scene name or asset.
-- @param parentNameOrInstance [optional] (string or GameObject) The parent game object name or instance.
-- @return (GameObject) The appended gameObject, or nil.
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
-- @param object (GameObject, a component or a dynamically loaded asset) The gameObject, component or a dynamically loaded asset (like a map loaded with Map.LoadFromPackage).
function CraftStudio.Destroy( object )
    Daneel.Debug.StackTrace.BeginFunction( "CraftStudio.Destroy", object )
    if object == nil and Daneel.Config.debug.enableDebug then
        print( "CraftStudio.Destroy( object ) : provided object is nil" )
        return
    end

    if type( object ) == "table" then
        Daneel.Event.Fire( object, "OnDestroy", object )
        Daneel.Event.Clear( object ) -- remove from listener list
        object.isDestroyed = true
        setmetatable( object, nil )
        OriginalDestroy( object )
    end
    Daneel.Debug.StackTrace.EndFunction()
end


----------------------------------------------------------------------------------

setmetatable(Vector3, { __call = function(Object, ...) return Object:New(...) end })
setmetatable(Quaternion, { __call = function(Object, ...) return Object:New(...) end })
setmetatable(Plane, { __call = function(Object, ...) return Object:New(...) end })
