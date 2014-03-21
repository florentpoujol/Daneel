-- CraftStudio.lua
-- Contains extensions of CraftStudio's API.
--
-- Last modified for v1.4.0
-- Copyright © 2013-2014 Florent POUJOL, published under the MIT license.

-- debug info
local s = "string"
local b = "boolean"
local n = "number"
local t = "table"
local go = "GameObject"
local v = "Vector3"
local _p = { "params", t }


setmetatable( Vector3, { __call = function(Object, ...) return Object:New(...) end } )
setmetatable( Quaternion, { __call = function(Object, ...) return Object:New(...) end } )
setmetatable( Plane, { __call = function(Object, ...) return Object:New(...) end } )

-- fix
Plane.__tostring = function( p )
    return "Plane: { normal="..tostring(p.normal)..", distance="..tostring(p.distance).." }"
    -- tostring() to prevent a "p.normal is not defined" error
end


----------------------------------------------------------------------------------
-- Assets

Asset = {}
Asset.__index = Asset
setmetatable( Asset, { __call = function(Object, ...) return Object.Get(...) end } )

local assetPathTypes = { "string" }
--- Alias of CraftStudio.FindAsset( assetPath[, assetType] ).
-- Get the asset of the specified name and type.
-- The first argument may be an asset object, so that you can check if a variable was an asset object or name (and get the corresponding object).
-- @param assetPath (string or one of the asset type) The fully-qualified asset name or asset object.
-- @param assetType [optional] (string) The asset type as a case-insensitive string.
-- @param errorIfAssetNotFound [default=false] Throw an error if the asset was not found (instead of returning nil).
-- @return (One of the asset type) The asset, or nil if none is found.
function Asset.Get( assetPath, assetType, errorIfAssetNotFound )
    local errorHead = "Asset.Get( assetPath[, assetType, errorIfAssetNotFound] ) : "

    if assetPath == nil then
        if Daneel.Config.debug.enableDebug then
            error( errorHead.."Argument 'assetPath' is nil." )
        end
        return nil
    end

    if #assetPathTypes == 1 then
        assetPathTypes = table.merge( assetPathTypes, Daneel.Config.assetTypes )
        -- the assetPath can be an asset or the asset path (string)
        -- this is done here because there is no garantee that Daneel.Config.assetTypes will already exist in the global scope
    end
    local argType = Daneel.Debug.CheckArgType( assetPath, "assetPath", assetPathTypes, errorHead )
    
    if assetType ~= nil then
        Daneel.Debug.CheckArgType( assetType, "assetType", "string", errorHead )
        assetType = Daneel.Debug.CheckArgValue( assetType, "assetType", Daneel.Config.assetTypes, errorHead )
    end

    -- just return the asset if assetPath is already an object
    if table.containsvalue( Daneel.Config.assetTypes, argType ) then
        if assetType ~= nil and argType ~= assetType then 
            error( errorHead.."Provided asset '"..assetPath.."' has a different type '"..argType.."' than the provided 'assetType' argument '"..assetType.."'." )
        end
        return assetPath
    end
    -- else assetPath is always an actual asset path as a string
    
    Daneel.Debug.CheckOptionalArgType( errorIfAssetNotFound, "errorIfAssetNotFound", "boolean", errorHead )

    -- check if assetPath is a script alias
    local scriptAlias = assetPath
    if Daneel.Config.scriptPaths[ scriptAlias ] ~= nil then 
        assetPath = Daneel.Config.scriptPaths[ scriptAlias ]
        assetType = "Script"
    end

    -- get asset
    local asset = nil
    if assetType == nil then
        asset = CraftStudio.FindAsset( assetPath )
    else
        asset = CraftStudio.FindAsset( assetPath, assetType )
    end

    if asset == nil and errorIfAssetNotFound then
        if assetType == nil then
            assetType = "asset"
        end
        error( errorHead .. "Argument 'assetPath' : " .. assetType .. " with name '" .. assetPath .. "' was not found." )
    end

    return asset
end

--- Returns the path of the provided asset.
-- Alias of Map.GetPathInPackage().
-- @param asset (One of the asset types) The asset instance.
-- @return (string) The fully-qualified asset path.
function Asset.GetPath( asset )
    return Map.GetPathInPackage( asset )
end

--- Returns the name of the provided asset.
-- @param asset (One of the asset types) The asset instance.
-- @return (string) The name (the last segment of the fully-qualified path).
function Asset.GetName( asset )
    local name = rawget( asset, "name" )
    if name == nil then
        name = Asset.GetPath( asset ):gsub( "^(.*/)", "" ) 
        rawset( asset, "name", name )
    end
    return name
end

--- Returns the asset's internal unique identifier.
-- @param asset (any asset type) The asset.
-- @return (number) The id.
function Asset.GetId( asset )
    return Daneel.Cache.GetId( asset )
end


----------------------------------------------------------------------------------
-- Component ("mother" object of components)

Component = {}
Component.__index = Component

--- Apply the content of the params argument to the provided component.
-- @param component (any component's type) The component.
-- @param params (table) A table of parameters to set the component with.
function Component.Set( component, params )
    for key, value in pairs( params ) do
        component[key] = value
    end
end

--- Destroy the provided component, removing it from the game object.
-- Note that the component is removed only at the end of the current frame.
-- @param component (any component type) The component.
function Component.Destroy( component )
    table.removevalue( component.gameObject, component )    
    CraftStudio.Destroy( component )
end

--- Returns the component's internal unique identifier.
-- @param component (any component type) The component.
-- @return (number) The id.
function Component.GetId( component )
    -- no Debug because is used in __tostring
    return Daneel.Cache.GetId( component )
end

table.mergein( Daneel.functionsDebugInfo, {
    ["Asset.Get"] = { { "assetPath" }, { "assetType", isOptional = true }, { "errorIfAssetNotFound", defaultValue = false } },
    ["Asset.GetPath"] = { { "asset", Daneel.Config.assetTypes } },
    ["Asset.GetName"] = { { "asset", Daneel.Config.assetTypes } },

    ["Component.Set"] = { { "component", Daneel.Config.componentTypes }, { "params", defaultValue = {} } },
    ["Component.Destroy"] = { { "component", Daneel.Config.componentTypes } },
} )


----------------------------------------------------------------------------------
-- fix for Map.GetPathInPackage() that returns an error when the asset was dynamically loaded

Map.oGetPathInPackage = Map.GetPathInPackage

function Map.GetPathInPackage( asset )
    local path = rawget( asset, "path" )
    if path == nil then
        path = Map.oGetPathInPackage( asset )
    end
    return path
end

Map.oLoadFromPackage = Map.LoadFromPackage

function Map.LoadFromPackage( path, callback )
    Map.oLoadFromPackage( path, function( map )
        if map ~= nil then
            rawset( map, "path", path )
            map.isDynamicallyLoaded = true
        end
        callback( map )
    end )
end


----------------------------------------------------------------------------------
-- Transform

Transform.oSetLocalScale = Transform.SetLocalScale

--- Set the transform's local scale.
-- @param transform (Transform) The transform component.
-- @param scale (number or Vector3) The global scale.
function Transform.SetLocalScale(transform, scale)
    if type( scale ) == "number" then
        scale = Vector3:New(scale)
    end
    Transform.oSetLocalScale(transform, scale)
end

--- Set the transform's global scale.
-- @param transform (Transform) The transform component.
-- @param scale (number or Vector3) The global scale.
function Transform.SetScale(transform, scale)
    if type( scale ) == "number" then
        scale = Vector3:New(scale)
    end
    local parent = transform.gameObject:GetParent()
    if parent ~= nil then
        scale = scale / parent.transform:GetScale()
    end
    transform:SetLocalScale( scale )
end

--- Get the transform's global scale.
-- @param transform (Transform) The transform component.
-- @return (Vector3) The global scale.
function Transform.GetScale(transform)
    local scale = transform:GetLocalScale()
    local parent = transform.gameObject:GetParent()
    if parent ~= nil then
        scale = scale * parent.transform:GetScale()
    end
    return scale
end


----------------------------------------------------------------------------------
-- ModelRenderer

ModelRenderer.oSetModel = ModelRenderer.SetModel

--- Attach the provided model to the provided modelRenderer.
-- @param modelRenderer (ModelRenderer) The modelRenderer.
-- @param modelNameOrAsset (string or Model) [optional] The model name or asset, or nil.
function ModelRenderer.SetModel( modelRenderer, modelNameOrAsset )
    local model = nil
    if modelNameOrAsset ~= nil then
        model = Asset.Get( modelNameOrAsset, "Model", true )
    end
    ModelRenderer.oSetModel( modelRenderer, model )
end

ModelRenderer.oSetAnimation = ModelRenderer.SetAnimation

--- Set the specified animation for the modelRenderer's current model.
-- @param modelRenderer (ModelRenderer) The modelRenderer.
-- @param animationNameOrAsset (string or ModelAnimation) [optional] The animation name or asset, or nil.
function ModelRenderer.SetAnimation( modelRenderer, animationNameOrAsset )
    local animation = nil 
    if animationNameOrAsset ~= nil then
        animation = Asset.Get( animationNameOrAsset, "ModelAnimation", true )
    end
    ModelRenderer.oSetAnimation( modelRenderer, animation )
end

--- Apply the content of the params argument to the provided model renderer.
-- @param modelRenderer (ModelRenderer) The model renderer.
-- @param params (table) A table of parameters to set the component with.
function ModelRenderer.Set( modelRenderer, params )
    if params.model ~= nil then
        modelRenderer:SetModel( params.model )
        params.model = nil
    end
    if params.animationTime ~= nil and params.animation ~= nil then
        modelRenderer:SetAnimation( params.animation )
        params.animation = nil
    end
    Component.Set( modelRenderer, params )
end


----------------------------------------------------------------------------------
-- MapRenderer

MapRenderer.oSetMap = MapRenderer.SetMap

--- Attach the provided map to the provided map renderer.
-- @param mapRenderer (MapRenderer) The map renderer.
-- @param mapNameOrAsset (string or Map) [optional] The map name or asset, or nil.
-- @param replaceTileSet (boolean) [default=true] Replace the current TileSet by the one set for the provided map in the map editor. 
function MapRenderer.SetMap( mapRenderer, mapNameOrAsset, replaceTileSet )
    local map = nil
    if mapNameOrAsset ~= nil then
        map = Asset.Get( mapNameOrAsset, "Map", true )
    end
    if replaceTileSet ~= nil then
        MapRenderer.oSetMap(mapRenderer, map, replaceTileSet)
    else
        MapRenderer.oSetMap(mapRenderer, map)
    end
end

MapRenderer.oSetTileSet = MapRenderer.SetTileSet

--- Set the specified tileSet for the mapRenderer's map.
-- @param mapRenderer (MapRenderer) The mapRenderer.
-- @param tileSetNameOrAsset (string or TileSet) [optional] The tileSet name or asset, or nil.
function MapRenderer.SetTileSet( mapRenderer, tileSetNameOrAsset )
    local tileSet = nil
    if tileSetNameOrAsset ~= nil then
        tileSet = Asset.Get( tileSetNameOrAsset, "TileSet", true )
    end
    MapRenderer.oSetTileSet( mapRenderer, tileSet )
end

--- Apply the content of the params argument to the provided map renderer.
-- @param mapRenderer (MapRenderer) The map renderer.
-- @param params (table) A table of parameters to set the component with.
function MapRenderer.Set( mapRenderer, params )
    if params.map ~= nil then
        mapRenderer:SetMap( params.map )
        -- set the map here in case of the tileSet property is set too
        params.map = nil
    end
    Component.Set( mapRenderer, params )
end


----------------------------------------------------------------------------------
-- TextRenderer

TextRenderer.oSetFont = TextRenderer.SetFont

--- Set the provided font to the provided text renderer.
-- @param textRenderer (TextRenderer) The text renderer.
-- @param fontNameOrAsset (string or Font) [optional] The font name or asset, or nil.
function TextRenderer.SetFont( textRenderer, fontNameOrAsset )
    local font = nil
    if fontNameOrAsset ~= nil then
        font = Asset.Get( fontNameOrAsset, "Font", true )
    end
    TextRenderer.oSetFont( textRenderer, font )
end

TextRenderer.oSetAlignment = TextRenderer.SetAlignment

--- Set the text's alignment.
-- @param textRenderer (TextRenderer) The textRenderer.
-- @param alignment (string or TextRenderer.Alignment) The alignment. Values (case-insensitive when of type string) may be "left", "center", "right", TextRenderer.Alignment.Left, TextRenderer.Alignment.Center or TextRenderer.Alignment.Right.
function TextRenderer.SetAlignment(textRenderer, alignment)
    if type( alignment ) == "string" then
        local default = "Center"
        if Daneel.Config.textRenderer ~= nil and Daneel.Config.textRenderer.alignment ~= nil then
            default = Daneel.Config.textRenderer.alignment
        end
        local errorHead = "TextRenderer.SetAlignment( textRenderer, alignment ) : "
        alignment = Daneel.Debug.CheckArgValue( alignment, "alignment", {"Left", "Center", "Right"}, errorHead, default )
        alignment = TextRenderer.Alignment[ alignment ]
    end
    TextRenderer.oSetAlignment( textRenderer, alignment )
end

--- Update the game object's scale to make the text appear the provided width.
-- @param textRenderer (TextRenderer) The textRenderer.
-- @param width (number) The text's width in scene units.
function TextRenderer.SetTextWidth( textRenderer, width )
    local widthScaleRatio = textRenderer:GetTextWidth() / textRenderer.gameObject.transform:GetScale()
    textRenderer.gameObject.transform:SetScale( width / widthScaleRatio )
end


----------------------------------------------------------------------------------
-- Camera

Camera.oSetProjectionMode = Camera.SetProjectionMode

--- Sets the camera projection mode.
-- @param camera (Camera) The camera.
-- @param projectionMode (string or Camera.ProjectionMode) The projection mode. Possible values are "perspective", "orthographic" (as a case-insensitive string), Camera.ProjectionMode.Perspective or Camera.ProjectionMode.Orthographic.
function Camera.SetProjectionMode( camera, projectionMode )
    if type( projectionMode ) == "string" then
        local default = "Perspective"
        if Daneel.Config.camera ~= nil and Daneel.Config.camera.projectionMode ~= nil then
            default = Daneel.Config.camera.projectionMode
        end
        projectionMode = Daneel.Debug.CheckArgValue( projectionMode, "projectionMode", {"Perspective", "Orthographic"}, "Camera.SetProjectionMode( camera[, projectionMode] ) : ", default )
        projectionMode = Camera.ProjectionMode[ projectionMode ]
    end
    Camera.oSetProjectionMode( camera, projectionMode )
end

--- Apply the content of the params argument to the provided camera.
-- @param camera (Camera) The camera.
-- @param params (table) A table of parameters to set the component with.
function Camera.Set( camera, params )
    if params.projectionMode ~= nil then
        camera:SetProjectionMode( params.projectionMode )
        params.projectionMode = nil
    end
    Component.Set( camera, params )
end

--- Returns the pixels to scene units multiplier.
-- PixelsToUnits = orthographic scale / smallest screen size.
-- Only works for orthographic cameras. Returns nil for perspective cameras.
-- @return (number) The camera's PixelsToUnits ratio.
function Camera.GetPixelsToUnits( camera )
    if camera:GetProjectionMode() == Camera.ProjectionMode.Orthographic then
        local screenSize = CS.Screen.GetSize()
        local smallestSideSize = screenSize.y
        if screenSize.x < screenSize.y then
            smallestSideSize = screenSize.x
        end
        return camera:GetOrthographicScale() / smallestSideSize
    end
    return nil
end

--- Returns the scene units to pixels multiplier.
-- UnitsToPixels = smallest screen size / orthographic scale.
-- Only works for orthographic cameras. Returns nil for perspective cameras.
-- @return (number) The camera's UnitsToPixels ratio.
function Camera.GetUnitsToPixels( camera )
    local pixelsToUnits = camera:GetPixelsToUnits()
    if pixelsToUnits ~= nil and pixelsToUnits ~= 0 then
        return 1 / pixelsToUnits
    end
    return nil
end

--- Tell whether the provided position is inside the camera's frustum.
-- @parap camera (Camera) The camera component.
-- @param position (Vector3) The position.
-- @return (boolean) True if the position is insode the camera's frustum.
function Camera.IsPositionInFrustum( camera, position )
    local camPosition = camera.gameObject.transform:GetPosition()
    local screenSize = CS.Screen.GetSize()

    if camera:GetProjectionMode() == Camera.ProjectionMode.Orthographic then
        local relPosition = position - camPosition
        local range = screenSize * camera:GetPixelsToUnits() / 2
        
        if 
            relPosition.x >= -range.x and relPosition.x <= range.x and
            relPosition.y >= - range.y and relPosition.y <= range.y and
            relPosition.z <= 0 
        then
            return true
        else
            return false
        end
    else -- perspective
        return nil
    end
end

--- Translate a position in the scene to an on-screen position.
-- @parap camera (Camera) The camera component.
-- @param position (Vector3) The position.
-- @return (Vector2) The screen position
function Camera.WorldToScreenPoint( camera, position )
    local camPosition = camera.gameObject.transform:GetPosition()
    local unitsToPixels = camera:GetUnitsToPixels()
    local relPosition = position - camPosition
    local screenSize = CS.Screen.GetSize()
    local screenPosition = Vector2.New(0)

    if camera:GetProjectionMode() == Camera.ProjectionMode.Orthographic then
        screenPosition.x = relPosition.x * unitsToPixels - screenSize.x / 2
        screenPosition.y = - relPosition.y * unitsToPixels + screenSize.y / 2
        return screenPosition
    end
end


table.mergein( Daneel.functionsDebugInfo, {
    ["Transform.SetLocalScale"] = { { "transform", "Transform" }, { "number", { n, v } } },
    ["Transform.SetScale"] =      { { "transform", "Transform" }, { "number", { n, v } } },
    ["Transform.GetScale"] =      { { "transform", "Transform" } },

    ["ModelRenderer.SetModel"] =     { { "modelRenderer", "ModelRenderer" }, { "modelNameOrAsset", { s, "Model" }, isOptional = true } },
    ["ModelRenderer.SetAnimation"] = { { "modelRenderer", "ModelRenderer" }, { "animationNameOrAsset", { s, "ModelAnimation" }, isOptional = true } },
    ["ModelRenderer.Set"] =          { { "modelRenderer", "ModelRenderer" }, _p },

    ["MapRenderer.SetMap"] = { 
        { "mapRenderer", "MapRenderer" },
        { "mapNameOrAsset", { s, "Map" }, isOptional = true },
        { "replaceTileSet", defaultValue = true },
    },
    ["MapRenderer.SetTileSet"] = { { "mapRenderer", "MapRenderer" }, { "tileSetNameOrAsset", { s, "TileSet" } } },
    ["MapRenderer.Set"] =        { { "mapRenderer", "MapRenderer" }, _p },

    ["TextRenderer.SetFont"] =      { { "textRenderer", "TextRenderer" }, { "fontNameOrAsset", { s, "Font" } } },
    ["TextRenderer.SetAlignment"] = { { "textRenderer", "TextRenderer" }, { "alignment", {s, "userdata", n} } }, -- number because enum returns a number in the webplayer
    ["TextRenderer.SetTextWidth"] = { { "textRenderer", "TextRenderer" }, { "width", n } },

    ["Camera.SetProjectionMode"] =   { { "camera", "Camera" }, { "projectionMode", {s, "userdata", n} } },
    ["Camera.Set"] =                 { { "camera", "Camera" }, _p },
    ["Camera.GetPixelsToUnits"] =    { { "camera", "Camera" } },
    ["Camera.GetUnitsToPixels"] =    { { "camera", "Camera" } },
    ["Camera.IsPositionInFrustum"] = { { "camera", "Camera" }, { "position", "Vector3" } },
    ["Camera.WorldToScreenPoint"] =  { { "camera", "Camera" }, { "position", "Vector3" } },
} )


----------------------------------------------------------------------------------
-- Vector2

Vector2 = {}
Vector2.__index = Vector2
setmetatable( Vector2, { __call = function(Object, ...) return Object.New(...) end } )

function Vector2.__tostring(vector2)
    return "Vector2: { x="..vector2.x..", y="..vector2.y.." }"
end

--- Creates a new Vector2 intance.
-- @param x (number, string or Vector2) The vector's x component.
-- @param y [optional] (number or string) The vector's y component. If nil, will be equal to x.
-- @return (Vector2) The new instance.
function Vector2.New(x, y)
    Daneel.Debug.StackTrace.BeginFunction("Vector2.New", x, y)
    local errorHead = "Vector2.New(x, y) : "
    local argType = Daneel.Debug.CheckArgType(x, "x", {"string", "number", "Vector2"}, errorHead)
    Daneel.Debug.CheckOptionalArgType(y, "y", {"string", "number"}, errorHead)

    if y == nil then y = x end
    local vector = setmetatable({ x = x, y = y }, Vector2)
    if argType == "Vector2" then
        vector.x = x.x
        vector.y = x.y
    end
    Daneel.Debug.StackTrace.EndFunction()
    return vector
end

--- Return the length of the vector.
-- @param vector (Vector2) The vector.
-- @return (number) The length.
function Vector2.GetLength( vector )
    Daneel.Debug.StackTrace.BeginFunction( "Vector2.GetLength", vector )
    local errorHead = "Vector2.GetLength( vector ) : "
    Daneel.Debug.CheckArgType( vector, "vector", "Vector2", errorHead )

    local length = math.sqrt( vector.x^2 + vector.y^2 )
    Daneel.Debug.StackTrace.EndFunction()
    return length
end

--- Return the squared length of the vector.
-- @param vector (Vector2) The vector.
-- @return (number) The squared length.
function Vector2.GetSqrLength( vector )
    Daneel.Debug.StackTrace.BeginFunction( "Vector2.GetSqrLength", vector )
    local errorHead = "Vector2.GetSqrLength( vector ) : "
    Daneel.Debug.CheckArgType( vector, "vector", "Vector2", errorHead )

    local length = vector.x^2 + vector.y^2
    Daneel.Debug.StackTrace.EndFunction()
    return length
end

--- Return a copy of the provided vector, normalized.
-- @param vector (Vector2) The vector to normalize.
-- @return (Vector2) A copy of the vector, normalized.
function Vector2.Normalized( vector )
    Daneel.Debug.StackTrace.BeginFunction( "Vector2.Normalized", vector )
    local errorHead = "Vector2.Normalized( vector ) : "
    Daneel.Debug.CheckArgType( vector, "vector", "Vector2", errorHead )

    local nv = Vector2.New( vector.x, vector.y ):Normalize()
    Daneel.Debug.StackTrace.EndFunction()
    return nv
end

--- Normalize the provided vector in place (makes its length equal to 1).
-- @param vector (Vector2) The vector to normalize.
function Vector2.Normalize( vector )
    Daneel.Debug.StackTrace.BeginFunction( "Vector2.Normalize", vector )
    local errorHead = "Vector2.Normalize( vector ) : "
    Daneel.Debug.CheckArgType( vector, "vector", "Vector2", errorHead )

    local length = vector:GetLength()
    if length ~= 0 then
        vector = vector / length
    end
    Daneel.Debug.StackTrace.EndFunction()
end

--- Allow to add two Vector2 by using the + operator.
-- Ie : vector1 + vector2
-- @param a (Vector2) The left member.
-- @param b (Vector2) The right member.
-- @return (Vector2) The new vector.
function Vector2.__add(a, b)
    Daneel.Debug.StackTrace.BeginFunction("Vector2.__add", a, b)
    local errorHead = "Vector2.__add(a, b) : "
    Daneel.Debug.CheckArgType(a, "a", "Vector2", errorHead)
    Daneel.Debug.CheckArgType(b, "b", "Vector2", errorHead)
    a = Vector2.New(a.x + b.x, a.y + b.y)
    Daneel.Debug.StackTrace.EndFunction()
    return a
end

--- Allow to substract two Vector2 by using the - operator.
-- Ie : vector1 - vector2
-- @param a (Vector2) The left member.
-- @param b (Vector2) The right member.
-- @return (Vector2) The new vector.
function Vector2.__sub(a, b)
    Daneel.Debug.StackTrace.BeginFunction("Vector2.__sub", a, b)
    local errorHead = "Vector2.__sub(a, b) : "
    Daneel.Debug.CheckArgType(a, "a", "Vector2", errorHead)
    Daneel.Debug.CheckArgType(b, "b", "Vector2", errorHead)
    a = Vector2.New(a.x - b.x, a.y - b.y)
    Daneel.Debug.StackTrace.EndFunction()
    return a
end

--- Allow to multiply two Vector2 or a Vector2 and a number by using the * operator.
-- @param a (Vector2 or number) The left member.
-- @param b (Vector2 or number) The right member.
-- @return (Vector2) The new vector.
function Vector2.__mul(a, b)
    Daneel.Debug.StackTrace.BeginFunction("Vector2.__mull", a, b)
    local errorHead = "Vector2.__mul(a, b) : "
    Daneel.Debug.CheckArgType(a, "a", {"Vector2", "number"}, errorHead)
    Daneel.Debug.CheckArgType(b, "b", {"Vector2", "number"}, errorHead)
    local newVector = nil
    if type(a) == "number" then
        newVector = Vector2.New(a * b.x, a * b.y)
    elseif type(b) == "number" then
        newVector = Vector2.New(a.x * b, a.y * b)
    else
        newVector = Vector2.New(a.x * b.x, a.y * b.y)
    end
    Daneel.Debug.StackTrace.EndFunction()
    return newVector
end

--- Allow to divide two Vector2 or a Vector2 and a number by using the / operator.
-- @param a (Vector2 or number) The numerator.
-- @param b (Vector2 or number) The denominator. Can't be equal to 0.
-- @return (Vector2) The new vector.
function Vector2.__div(a, b)
    Daneel.Debug.StackTrace.BeginFunction("Vector2.__div", a, b)
    local errorHead = "Vector2.__div(a, b) : "
    Daneel.Debug.CheckArgType(a, "a", {"Vector2", "number"}, errorHead)
    Daneel.Debug.CheckArgType(b, "b", {"Vector2", "number"}, errorHead)
    local newVector = nil
    if type(a) == "number" then
        if b.x == 0 or b.y == 0 then
            error(errorHead.."One of the components of the denominator is equal to 0. Can't divide by 0 ! a="..a..", b.x="..b.x..", b.y="..b.y)
        end
        newVector = Vector2.New(a / b.x, a / b.y)
    elseif type(b) == "number" then
        if b == 0 then
            error(errorHead.."The denominator is equal to 0 ! Can't divide by 0 ! a.x="..a.x..", a.y="..a.y..", b=0")
        end
        newVector = Vector2.New(a.x / b, a.y / b)
    else
        if b.x == 0 or b.y == 0 then
            error(errorHead.."One of the components of the denominator is equal to 0. Can't divide by 0 ! a.x="..a.x..", a.y="..a.y..", b.x="..b.x..", b.y="..b.y)
        end
        newVector = Vector2.New(a.x / b.x, a.y / b.y)
    end
    Daneel.Debug.StackTrace.EndFunction()
    return newVector
end

--- Allow to inverse a vector2 using the - operator.
-- @param vector (Vector2) The vector.
-- @return (Vector2) The new vector.
function Vector2.__unm(vector)
    Daneel.Debug.StackTrace.BeginFunction("Vector2.__unm", vector)
    local errorHead = "Vector2.__unm(vector) : "
    Daneel.Debug.CheckArgType(vector, "vector", "Vector2", errorHead)
    local vector = Vector2.New(-vector.x, -vector.y)
    Daneel.Debug.StackTrace.EndFunction()
    return vector
end

--- Allow to raise a Vector2 to a power using the ^ operator.
-- @param vector (Vector2) The vector.
-- @param exp (number) The power to raise the vector to.
-- @return (Vector2) The new vector.
function Vector2.__pow(vector, exp)
    Daneel.Debug.StackTrace.BeginFunction("Vector2.__pow", vector, exp)
    local errorHead = "Vector2.__pow(vector, exp) : "
    Daneel.Debug.CheckArgType(vector, "vector", "Vector2", errorHead)
    Daneel.Debug.CheckArgType(exp, "exp", "number", errorHead)
    vector = Vector2.New(vector.x ^ exp, vector.y ^ exp)
    Daneel.Debug.StackTrace.EndFunction()
    return vector
end

--- Allow to check for the equality between two Vector2 using the == comparison operator.
-- @param a (Vector2) The left member.
-- @param b (Vector2) The right member.
-- @return (boolean) True if the same components of the two vectors are equal (a.x=b.x and a.y=b.y)
function Vector2.__eq(a, b)
    Daneel.Debug.StackTrace.BeginFunction("Vector2.__eq", a, b)
    local errorHead = "Vector2.__eq(a, b) : "
    Daneel.Debug.CheckArgType(a, "a", "Vector2", errorHead)
    Daneel.Debug.CheckArgType(b, "b", "Vector2", errorHead)
    local eq = ((a.x == b.x) and (a.y == b.y))
    Daneel.Debug.StackTrace.EndFunction()
    return eq
end


----------------------------------------------------------------------------------

CraftStudio.Input.oGetMousePosition = CraftStudio.Input.GetMousePosition

--- Return the mouse position on screen coordinates {x, y}
-- @return (Vector2) The on-screen mouse position.
function CraftStudio.Input.GetMousePosition()
    return setmetatable( CraftStudio.Input.oGetMousePosition(), Vector2 )
end

CraftStudio.Input.oGetMouseDelta = CraftStudio.Input.GetMouseDelta

--- Return the mouse delta (the variation of position) since the last frame.
-- Positive x is right, positive y is bottom.
-- @return (Vector2) The position's delta.
function CraftStudio.Input.GetMouseDelta()
    return setmetatable( CraftStudio.Input.oGetMouseDelta(), Vector2 )
end

CraftStudio.Input.oGetSize = CraftStudio.Screen.GetSize

--- Return the size of the screen, in pixels.
-- @return (Vector2) The screen's size.
function CraftStudio.Screen.GetSize()
    return setmetatable( CraftStudio.Input.oGetSize(), Vector2 )
end


----------------------------------------------------------------------------------
-- RaycastHit

RaycastHit = {}
RaycastHit.__index = RaycastHit
setmetatable( RaycastHit, { __call = function(Object, ...) return Object.New(...) end } )
Daneel.Config.objects.RaycastHit = RaycastHit

function RaycastHit.__tostring( instance )
    local msg = "RaycastHit: { "
    local first = true
    for key, value in pairs( instance ) do
        if first then
            msg = msg..key.."="..tostring( value )
            first = false
        else
            msg = msg..", "..key.."="..tostring( value )
        end
    end
    return msg.." }"
end

Daneel.functionsDebugInfo["RaycastHit.New"] = { { "params", defaultValue = {} } }
--- Create a new RaycastHit
-- @return (RaycastHit) The raycastHit.
function RaycastHit.New( params )
    if params == nil then params = {} end
    return setmetatable( params, RaycastHit )
end


----------------------------------------------------------------------------------
-- Ray

setmetatable( Ray, { __call = function(Object, ...) return Object:New(...) end } )

--- Check the collision of the ray against the provided set of game objects.
-- @param ray (Ray) The ray.
-- @param gameObjects (table) The set of game objects to cast the ray against.
-- @param sortByDistance [default=false] (boolean) Sort the raycastHit by increasing distance in the returned table.
-- @return (table) A table of RaycastHits (will be empty if the ray didn't intersects anything).
function Ray.Cast( ray, gameObjects, sortByDistance )
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
    return hits
end

--- Check if the ray intersect the specified game object.
-- @param ray (Ray) The ray.
-- @param gameObjectNameOrInstance (string or GameObject) The game object instance or name.
-- @return (RaycastHit) A raycastHit with the if there was a collision, or nil.
function Ray.IntersectsGameObject( ray, gameObjectNameOrInstance )
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
    return raycastHit
end

Ray.oIntersectsPlane = Ray.IntersectsPlane

-- Check if the ray intersects the provided plane and returns the distance of intersection or a raycastHit.
-- @param ray (Ray) The ray.
-- @param plane (Plane) The plane.
-- @param returnRaycastHit (boolean) [default=false] Tell if the hit infos must be returned as a raycastHit.
-- @return (number or RaycastHit) The distance of intersection (if any) or a raycastHit with the 'distance' and 'hitLocation' properties (if any).
function Ray.IntersectsPlane( ray, plane, returnRaycastHit )
    local distance = Ray.oIntersectsPlane( ray, plane )
    if returnRaycastHit and distance ~= nil then
        return RaycastHit.New({
            distance = distance,
            hitLocation = ray.position + ray.direction * distance,
            hitObject = plane,
        })
    end
    return distance
end

Ray.oIntersectsModelRenderer = Ray.IntersectsModelRenderer

-- Check if the ray intersects the provided modelRenderer.
-- @param ray (Ray) The ray.
-- @param modelRenderer (ModelRenderer) The modelRenderer.
-- @param returnRaycastHit (boolean) [default=false] Tell if the hit infos must be returned as a raycastHit.
-- @return (number or RaycastHit) The distance of intersection (if any) or a raycastHit with the 'distance', 'normal' and 'hitLocation' properties (if any).
-- @return (Vector3) If 'returnRaycastHit' argument is false : the normal of the hit face, or nil
function Ray.IntersectsModelRenderer( ray, modelRenderer, returnRaycastHit )
    local distance, normal = Ray.oIntersectsModelRenderer( ray, modelRenderer )
    if returnRaycastHit and distance ~= nil then
        return RaycastHit.New({
            distance = distance,
            normal = normal,
            hitLocation = ray.position + ray.direction * distance,
            hitObject = modelRenderer,
            gameObject = modelRenderer.gameObject,
        })
    end
    return distance, normal
end

Ray.oIntersectsMapRenderer = Ray.IntersectsMapRenderer

-- Check if the ray intersects the provided mapRenderer.
-- @param ray (Ray) The ray.
-- @param mapRenderer (MapRenderer) The mapRenderer.
-- @param returnRaycastHit (boolean) [default=false] Tell if the hit infos must be returned as a raycastHit.
-- @return (number or RaycastHit) The distance of intersection (if any) or a raycastHit with the 'distance', 'normal', 'hitBlockLocation', 'adjacentBlockLocation' and 'hitLocation' properties (if any).
-- @return (Vector3) If 'returnRaycastHit' argument is false : the normal of the hit face, or nil
-- @return (Vector3) If 'returnRaycastHit' argument is false : the location of the block hit, or nil
-- @return (Vector3) If 'returnRaycastHit' argument is false : the location of the adjacent block, or nil
function Ray.IntersectsMapRenderer( ray, mapRenderer, returnRaycastHit )
    local distance, normal, hitBlockLocation, adjacentBlockLocation = Ray.oIntersectsMapRenderer( ray, mapRenderer )
    if hitBlockLocation ~= nil then
        setmetatable( hitBlockLocation, Vector3 )
    end
    if adjacentBlockLocation ~= nil then
        setmetatable( adjacentBlockLocation, Vector3 )
    end
    if returnRaycastHit and distance ~= nil then
        return RaycastHit.New({
            distance = distance,
            normal = normal,
            hitBlockLocation = hitBlockLocation,
            adjacentBlockLocation = adjacentBlockLocation,
            hitLocation = ray.position + ray.direction * distance,
            hitObject = mapRenderer,
            gameObject = mapRenderer.gameObject,
        })
    end
    return distance, normal, hitBlockLocation, adjacentBlockLocation
end

Ray.oIntersectsTextRenderer = Ray.IntersectsTextRenderer

-- Check if the ray intersects the provided textRenderer.
-- @param ray (Ray) The ray.
-- @param textRenderer (TextRenderer) The textRenderer.
-- @param returnRaycastHit (boolean) [default=false] Tell if the hit infos must be returned as a raycastHit.
-- @return (number or RaycastHit) The distance of intersection (if any) or a raycastHit with the 'distance', 'normal' and 'hitLocation' properties (if any).
-- @return (Vector3) If 'returnRaycastHit' argument is false : the normal of the hit face, or nil
function Ray.IntersectsTextRenderer( ray, textRenderer, returnRaycastHit )
    local distance, normal = Ray.oIntersectsTextRenderer( ray, textRenderer )
    if returnRaycastHit and distance ~= nil then
        return RaycastHit.New({
            distance = distance,
            normal = normal,
            hitLocation = ray.position + ray.direction * distance,
            hitObject = textRenderer,
            gameObject = textRenderer.gameObject,
        })
    end
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
    CraftStudio.LoadScene( sceneNameOrAsset )
end

CraftStudio.oLoadScene = CraftStudio.LoadScene

--- Schedules loading the specified scene after the current tick (1/60th of a second) has completed.
-- When the new scene is loaded, all of the current scene's game objects will be removed.
-- Calling this function doesn't immediately stops the calling function. As such, you might want to add a return statement afterwards. 
-- @param sceneNameOrAsset (string or Scene) The scene name or asset.
function CraftStudio.LoadScene( sceneNameOrAsset )
    local scene = Asset.Get( sceneNameOrAsset, "Scene", true )  
    Daneel.Event.Fire( "OnSceneLoad", scene )
    Daneel.Event.events = {} -- do this here to make sure that any events that might be fired from OnSceneLoad-catching function are indeed fired
    Scene.current = scene
    CraftStudio.oLoadScene( scene )
end

--- Alias of CraftStudio.AppendScene().
-- Appends the specified scene to the game by instantiating all of its game objects. Contrary to CraftStudio.LoadScene, this doesn't unload the current scene nor waits for the next tick: it happens right away.
-- You can optionally specify a parent game object which will be used as a root for adding all game objects. 
-- Returns the game object appended if there was only one root game object in the provided scene.
-- @param sceneNameOrAsset (string or Scene) The scene name or asset.
-- @param parentNameOrInstance (string or GameObject) [optional] The parent game object name or instance.
-- @return (GameObject) The appended game object, or nil.
function Scene.Append( sceneNameOrAsset, parentNameOrInstance )
    local scene = Asset.Get( sceneNameOrAsset, "Scene", true )
    local parent = nil
    if parentNameOrInstance ~= nil then
        parent = GameObject.Get( parentNameOrInstance, true )
    end
    return CraftStudio.AppendScene( scene, parent )
end


----------------------------------------------------------------------------------

CraftStudio.oDestroy = CraftStudio.Destroy

--- Removes the specified game object (and all of its descendants) or the specified component from its game object.
-- You can also optionally specify a dynamically loaded asset for unloading (See Map.LoadFromPackage ).
-- Sets the 'isDestroyed' property to 'true' and fires the 'OnDestroy' event on the object.
-- @param object (GameObject, a component or a dynamically loaded asset) The game object, component or a dynamically loaded asset (like a map loaded with Map.LoadFromPackage).
function CraftStudio.Destroy( object )
    if type( object ) == "table" then
        Daneel.Event.Fire( object, "OnDestroy", object )
        Daneel.Event.StopListen( object ) -- remove from listener list
        object.isDestroyed = true
    end
    CraftStudio.oDestroy( object )
end

local _ray = { "ray", "Ray" }
local _returnraycasthit = { "returnRaycastHit", defaultValue = false }

table.mergein( Daneel.functionsDebugInfo, {
    ["Ray.Cast"] =                    { _ray, { "gameObjects", t }, { "sortByDistance", defaultValue = false } },  
    ["Ray.IntersectsGameObject"] =    { _ray, { "gameObjectNameOrInstance", { s, go } }, _returnraycasthit },
    ["Ray.IntersectsPlane"] =         { _ray, { "plane", "Plane" }, _returnraycasthit },
    ["Ray.IntersectsModelRenderer"] = { _ray, { "modelRenderer", "ModelRenderer" }, _returnraycasthit },
    ["Ray.IntersectsMapRenderer"] =   { _ray, { "mapRenderer", "MapRenderer" }, _returnraycasthit },
    ["Ray.IntersectsTextRenderer"] =  { _ray, { "textRenderer", "TextRenderer" }, _returnraycasthit },

    ["Scene.Load"] =            { { "sceneNameOrAsset", { s, "Scene" } } },
    ["CraftStudio.LoadScene"] = { { "sceneNameOrAsset", { s, "Scene" } } },
    ["Scene.Append"] =          { { "sceneNameOrAsset", { s, "Scene" } }, { "parentNameOrInstance", { s, go }, isOptional = true } },

    ["CraftStudio.Destroy"] = { { "object" } },
} )

----------------------------------------------------------------------------------

CraftStudio.Input.isMouseLocked = false

CraftStudio.Input.oLockMouse = CraftStudio.Input.LockMouse
function CraftStudio.Input.LockMouse()
    CraftStudio.Input.isMouseLocked = true
    CraftStudio.Input.oLockMouse()
end

CraftStudio.Input.oUnlockMouse = CraftStudio.Input.UnlockMouse
function CraftStudio.Input.UnlockMouse()
    CraftStudio.Input.isMouseLocked = false
    CraftStudio.Input.oUnlockMouse()
end

--- Toggle the locked state of the mouse, which can be accessed via the CraftStudio.Input.isMouseLocked property.
function CraftStudio.Input.ToggleMouseLock()
    if CraftStudio.Input.isMouseLocked then
        CraftStudio.Input.UnlockMouse()
    else
        CraftStudio.Input.LockMouse()
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
            if GameObject[ funcName ] ~= nil then
                return GameObject[ funcName ]( gameObject )
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
-- @param errorIfGameObjectNotFound [default=false] (boolean) Throw an error if the game object was not found (instead of returning nil).
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

GameObject.oSetParent = GameObject.SetParent

--- Set the game object's parent. 
-- Optionaly carry over the game object's local transform instead of the global one.
-- @param gameObject (GameObject) The game object.
-- @param parentNameOrInstance [optional] (string or GameObject) The parent name or game object (or nil to remove the parent).
-- @param keepLocalTransform [default=false] (boolean) Carry over the game object's local transform instead of the global one.
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
    GameObject.oSetParent(gameObject, parent, keepLocalTransform)
    Daneel.Debug.StackTrace.EndFunction()
end

--- Alias of GameObject.FindChild().
-- Find the first game object's child with the provided name.
-- If the name is not provided, it returns the first child.
-- @param gameObject (GameObject) The game object.
-- @param name [optional] (string) The child name (may be hyerarchy of names separated by dots).
-- @param recursive [default=false] (boolean) Search for the child in all descendants instead of just the first generation.
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

GameObject.oGetChildren = GameObject.GetChildren

--- Get all descendants of the game object.
-- @param gameObject (GameObject) The game object.
-- @param recursive [default=false] (boolean) Look for all descendants instead of just the first generation.
-- @param includeSelf [default=false] (boolean) Include the game object in the children.
-- @return (table) The children.
function GameObject.GetChildren( gameObject, recursive, includeSelf )
    Daneel.Debug.StackTrace.BeginFunction( "GameObject.GetChildren", gameObject, recursive, includeSelf )
    local errorHead = "GameObject.GetChildren( gameObject[, recursive, includeSelf] ) : "
    Daneel.Debug.CheckArgType( gameObject, "gameObject", "GameObject", errorHead )
    Daneel.Debug.CheckOptionalArgType( recursive, "recursive", "boolean", errorHead )
    Daneel.Debug.CheckOptionalArgType( includeSelf, "includeSelf", "boolean", errorHead )

    local allChildren = GameObject.oGetChildren( gameObject )

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

GameObject.oSendMessage = GameObject.SendMessage

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
            GameObject.oSendMessage( gameObject, functionName, data )
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
        GameObject.oSendMessage( gameObject, functionName, data )
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

GameObject.oGetComponent = GameObject.GetComponent
GameObject.oGetScriptedBehavior = GameObject.GetScriptedBehavior

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
            component = GameObject.oGetComponent( gameObject, componentType )
        elseif Daneel.Config.componentObjects[ componentType ] == nil then -- not a custom component either
            local script = Asset.Get( componentType, "Script", true ) -- componentType is the script path or asset
            component = GameObject.oGetScriptedBehavior( gameObject, script )
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
    local component = GameObject.oGetScriptedBehavior( gameObject, script )
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
-- GameObject.Tags is emptied in Tag.Awake() below

--- Returns the game object(s) that have all the provided tag(s).
-- @param tag (string or table) One or several tag(s) (as a string or table of strings).
-- @return (table) The game object(s) (empty if none is found).
function GameObject.GetWithTag( tag )
    local tags = tag
    if type( tags ) == "string" then
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

    return gameObjectsWithTag
end

--- Returns the tag(s) of the provided game object.
-- @param gameObject (GameObject) The game object.
-- @return (table) The tag(s) (empty if the game object has no tag).
function GameObject.GetTags( gameObject )
    local tags = {}
    for tag, gameObjects in pairs( GameObject.Tags ) do
        if table.containsvalue( gameObjects, gameObject ) then
            table.insert( tags, tag )
        end
    end
    return tags
end

--- Add the provided tag(s) to the provided game object.
-- @param gameObject (GameObject) The game object.
-- @param tag (string or table) One or several tag(s) (as a string or table of strings).
function GameObject.AddTag( gameObject, tag )
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
end

--- Remove the provided tag(s) from the provided game object.
-- If the 'tag' argument is not provided, all tag of the game object will be removed.
-- @param gameObject (GameObject) The game object.
-- @param tag [optional] (string or table) One or several tag(s) (as a string or table of strings).
function GameObject.RemoveTag( gameObject, tag )
    local tags = tag
    if type( tags ) == "string" then
        tags = { tags }
    end

    for tag, gameObjects in pairs( GameObject.Tags ) do
        if tags == nil or table.containsvalue( tags, tag ) then
            table.removevalue( GameObject.Tags[ tag ], gameObject )
        end
    end
end

--- Tell whether the provided game object has all (or at least one of) the provided tag(s).
-- @param gameObject (GameObject) The game object.
-- @param tag (string or table) One or several tag (as a string or table of strings).
-- @param atLeastOneTag [default=false] (boolean) If true, returns true if the game object has AT LEAST one of the tag (instead of ALL the tag).
-- @return (boolean) True
function GameObject.HasTag( gameObject, tag, atLeastOneTag )
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

local _t = { "tag", {"string", "table"} }
local _go = { "gameObject", "GameObject" }

table.mergein( Daneel.functionsDebugInfo, {
    ["GameObject.GetWithTag"] = { _t },
    ["GameObject.GetTags"] = { _go },
    ["GameObject.AddTag"] = { _go, _t },
    ["GameObject.RemoveTag"] = { _go, { "tag", {"string", "table"}, isOptional = true } },
    ["GameObject.HasTag"] = { _go, _t, { "atLeastOneTag", defaultValue = false } },
} )

Daneel.modules.Tags = {
    Awake = function()
        GameObject.Tags = {}
    end
}


----------------------------------------------------------------------------------
-- Network

CS.Network.Server.playerIds = {}

NetworkSync.oSendMessageToPlayers = NetworkSync.SendMessageToPlayers

function NetworkSync.SendMessageToPlayers( networkSync, msgName, data, playerIds, deliveryMethod, deliveryChannel )
    if playerIds == nil then
        playerIds = CS.Network.Server.playerIds
    elseif type( playerIds ) == "number" then
        playerIds = { playerIds }
    end
    NetworkSync.oSendMessageToPlayers( networkSync, msgName, data, playerIds, deliveryMethod, deliveryChannel )
end

CS.Network.Server.oOnPlayerJoined = CS.Network.Server.OnPlayerJoined
function CS.Network.Server.OnPlayerJoined( callback )
    CS.Network.Server.oOnPlayerJoined( 
        function( player )
            table.insert( CS.Network.Server.playerIds, player.id )
            if callback ~= nil then
                callback( player )
            end
        end
    )
end
CS.Network.Server.OnPlayerJoined()

CS.Network.Server.oOnPlayerLeft = CS.Network.Server.OnPlayerLeft
function CS.Network.Server.OnPlayerLeft( callback )
    CS.Network.Server.oOnPlayerLeft( 
        function( playerId )
            table.removevalue( CS.Network.Server.playerIds, playerId )
            if callback ~= nil then
                callback( playerId )
            end
        end
    )
end
CS.Network.Server.OnPlayerLeft()
