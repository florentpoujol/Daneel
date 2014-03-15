-- Draw.lua
-- Module adding the Draw components.
--
-- Last modified for v1.4.0
-- Copyright © 2013-2014 Florent POUJOL, published under the MIT license.

Draw = {}
Daneel.modules.Draw = Draw

local functionsDebugInfo = {}
local s = "string"
local b = "boolean"
local n = "number"
local t = "table"
local v = "Vector3"
local _go = { "gameObject", "GameObject" }
local _p = { "params", t, defaultValue = {} }
local _l = { "line", "LineRenderer"}
local _c = { "circle", "CircleRenderer"}
local _d = { "draw", b, defaultValue = true }


----------------------------------------------------------------------------------
-- LineRenderer

Draw.LineRenderer = {}

functionsDebugInfo[ "Draw.LineRenderer.New" ] = { _go, _p }
--- Creates a new LineRenderer component.
-- @param gameObject (GameObject) The game object.
-- @param params (table) A table of parameters.
-- @return (LineRenderer) The new component.
function Draw.LineRenderer.New( gameObject, params )
    local line = {
        origin = gameObject.transform:GetPosition(),
        _direction = Vector3:Left(),
        _length = 1,
        _width = 1,
        gameObject = gameObject
    }
    line._endPosition = line.origin
    gameObject.lineRenderer = line

    setmetatable( line, Draw.LineRenderer )
    
    params = table.merge( Draw.Config.lineRenderer, params )
    if params.endPosition ~= nil then
        params.length = nil
        params.direction = nil
    end
    line:Set( params )

    return line
end

functionsDebugInfo[ "Draw.LineRenderer.Set" ] = { _l, _p }
--- Apply the content of the params argument to the provided line renderer.
-- Overwrite Component.Set().
-- @param line (LineRenderer) The line renderer.
-- @param params (table) A table of parameters.
function Draw.LineRenderer.Set( line, params )
    if params.endPosition and (params.length or params.direction) then
        if Daneel.Config.debug.enableDebug then
            local text = "Draw.LineRenderer.Set( line, params ) : The 'endPosition' property is set."
            if params.length then
                text = text.." The 'length' property with value '"..tostring( params.length ).."' has been ignored."
            end
            if params.direction then
                text = text.." The 'direction' property with value '"..tostring( params.direction ).."' has been ignored."
            end
            print( text )
        end
        params.length = nil
        params.direction = nil
    end

    local draw = false
    for key, value in pairs( params ) do
        local funcName = "Set"..string.ucfirst( key )
        if Draw.LineRenderer[ funcName ] ~= nil then
            draw = true
            if funcName == "SetDirection" then
                Draw.LineRenderer[ funcName ]( line, value, nil, false )
            else
                Draw.LineRenderer[ funcName ]( line, value, false )
            end
        else
            line[ key ] = value
        end
    end
    if draw then
        line:Draw()
    end
end

functionsDebugInfo[ "Draw.LineRenderer.Draw" ] = { _l }
--- Draw the line renderer. Updates the game object based on the line renderer's properties.
-- Fires the OnDraw event on the line renderer.
-- @param line (LineRenderer) The line renderer.
function Draw.LineRenderer.Draw( line )
    line.gameObject.transform:LookAt( line._endPosition )
    line.gameObject.transform:SetLocalScale( Vector3:New( line._width, line._width, line._length ) )
    Daneel.Event.Fire( line, "OnDraw", line )
end

functionsDebugInfo[ "Draw.LineRenderer.SetEndPosition" ] = { _l, { "endPosition", v }, _d }
--- Set the line renderer's end position.
-- It also updates the line renderer's direction and length.
-- @param line (LineRenderer) The line renderer.
-- @param endPosition (Vector3) The end position.
-- @param draw (boolean) [default=true] Tell whether to re-draw immediately the line renderer.
function Draw.LineRenderer.SetEndPosition( line, endPosition, draw )
    line._endPosition = endPosition
    line._direction = (line._endPosition - line.origin)
    line._length = line._direction:Length()
    if draw == nil or draw then
        line:Draw()
    end
end

functionsDebugInfo[ "Draw.LineRenderer.GetEndPosition" ] = { _l }
--- Returns the line renderer's end position.
-- @param line (LineRenderer) The line renderer.
-- @return (Vector3) The end position.
function Draw.LineRenderer.GetEndPosition( line )
    return line._endPosition
end

functionsDebugInfo[ "Draw.LineRenderer.SetLength" ] = { _l, { "length", n }, _d }
--- Set the line renderer's length.
-- It also updates line renderer's end position.
-- @param line (LineRenderer) The line renderer.
-- @param length (number) The length (in scene units).
-- @param draw (boolean) [default=true] Tell whether to re-draw immediately the line renderer.
function Draw.LineRenderer.SetLength( line, length, draw )
    line._length = length
    line._endPosition = line.origin + line._direction * length
    if draw == nil or draw then
        line:Draw()
    end
end

functionsDebugInfo[ "Draw.LineRenderer.GetLength" ] = { _l }
--- Returns the line renderer's length.
-- @param line (LineRenderer) The line renderer.
-- @return (number) The length (in scene units).
function Draw.LineRenderer.GetLength( line )
    return line._length
end

functionsDebugInfo[ "Draw.LineRenderer.SetWidth" ] = { _l, { "direction", v },
    { "useDirectionAsLength", b, defaultValue = false }, _d
}
--- Set the line renderer's direction.
-- It also updates line renderer's end position.
-- @param line (LineRenderer) The line renderer.
-- @param direction (Vector3) The direction.
-- @param useDirectionAsLength (boolean) [default=false] Tell whether to update the line renderer's length based on the provided direction's vector length.
-- @param draw (boolean) [default=true] Tell whether to re-draw immediately the line renderer.
function Draw.LineRenderer.SetDirection( line, direction, useDirectionAsLength, draw )
    line._direction = direction:Normalized()
    if useDirectionAsLength then
        line._length = direction:Length()
    end
    line._endPosition = line.origin + line._direction * line._length
    if draw == nil or draw then
        line:Draw()
    end
end

functionsDebugInfo[ "Draw.LineRenderer.GetDirection" ] = { _l }
--- Returns the line renderer's direction.
-- @param line (LineRenderer) The line renderer.
-- @return (Vector3) The direction.
function Draw.LineRenderer.GetDirection( line )
    return line._direction
end

functionsDebugInfo[ "Draw.LineRenderer.SetWidth" ] = { _l, { "width", n }, _d }
--- Set the line renderer's width (and height).
-- @param line (LineRenderer) The line renderer.
-- @param width (number) The width (in scene units).
-- @param draw (boolean) [default=true] Tell whether to re-draw immediately the line renderer.
function Draw.LineRenderer.SetWidth( line, width, draw )
    line._width = width
    if draw == nil or draw then
        line:Draw()
    end
end

functionsDebugInfo[ "Draw.LineRenderer.GetWidth" ] = { _l }
--- Returns the line renderer's width.
-- @param line (LineRenderer) The line renderer.
-- @return (number) The width.
function Draw.LineRenderer.GetWidth( line )
    return line._width
end

----------------------------------------------------------------------------------
-- CircleRenderer

Draw.CircleRenderer = {}

functionsDebugInfo[ "Draw.CircleRenderer.New" ] = { _go, _p }
--- Creates a new circle renderer component.
-- @param gameObject (GameObject) The game object.
-- @param params (table) A table of parameters.
-- @return (CircleRenderer) The new component.
function Draw.CircleRenderer.New( gameObject, params )   
    local circle = {
        gameObject = gameObject,
        origin = gameObject.transform:GetPosition(),
        segments = {}, -- game objects
        _segmentCount = 6,
        _radius = 1,
        _width = 1,
        _model = nil, -- model asset
    }
    circle._endPosition = circle.origin
    gameObject.circleRenderer = circle

    setmetatable( circle, Draw.CircleRenderer )
    circle:Set( table.merge( Draw.Config.circleRenderer, params ) )

    return circle
end

functionsDebugInfo[ "Draw.CircleRenderer.Set" ] = { _c, _p }
--- Apply the content of the params argument to the provided circle renderer.
-- Overwrite Component.Set().
-- @param circle (CircleRenderer) The circle renderer.
-- @param params (table) A table of parameters.
function Draw.CircleRenderer.Set( circle, params )
    local draw = false
    for key, value in pairs( params ) do
        local funcName = "Set"..string.ucfirst( key )
        if Draw.CircleRenderer[ funcName ] ~= nil then
            draw = true
            Draw.CircleRenderer[ funcName ]( circle, value, false )
        else
            circle[ key ] = value
        end
    end
    if draw then
        circle:Draw()
    end
end

functionsDebugInfo[ "Draw.CircleRenderer.Draw" ] = { _c }
--- Draw the circle renderer. Updates the game object based on the circle renderer's properties.
-- Fires the OnDraw event at the circle renderer.
-- @param circle (CircleRenderer) The circle renderer.
function Draw.CircleRenderer.Draw( circle )
    -- coordinate of a point on a circle
    -- x = center.x + radius * cos( angleInRadian )
    -- y = center.y + radius * sin( angleInRadian )

    local offset = (2*math.pi) / circle._segmentCount
    local angle = -offset
    local circleId = circle:GetId()

    -- create and position the segments
    for i=1, circle._segmentCount do
        angle = angle + offset
        local lineStartLocalPosition = Vector3:New(
            circle._radius * math.cos( angle ),
            circle._radius * math.sin( angle ),
            0
        )

        if circle.segments[ i ] == nil then
            local newSegment = CS.CreateGameObject( "Circle "..circleId.." Segment "..i, circle.gameObject )
            newSegment:CreateComponent( "ModelRenderer" )
            if circle._model ~= nil then
                newSegment.modelRenderer:SetModel( circle._model )
            end
            table.insert( circle.segments, i, newSegment )
        end

        circle.segments[ i ].transform:SetLocalPosition( lineStartLocalPosition )
    end

    -- destroy unused gameObjects
    while #circle.segments > circle._segmentCount do
        table.remove( circle.segments ):Destroy()
    end
    
    local firstSegmentPosition = circle.segments[1].transform:GetPosition()
    local segmentLength = Vector3.Distance( firstSegmentPosition, circle.segments[2].transform:GetPosition() )
    
    -- scale the segments, setting their width and length
    for i, segment in ipairs( circle.segments ) do
        if circle.segments[ i+1 ] ~= nil then
            segment.transform:LookAt( circle.segments[ i+1 ].transform:GetPosition() )
        else
            segment.transform:LookAt( firstSegmentPosition )
        end
        segment.transform:SetLocalScale( Vector3:New( circle._width, circle._width, segmentLength ) )
    end
    
    Daneel.Event.Fire( circle, "OnDraw", circle )
end

functionsDebugInfo[ "Draw.CircleRenderer.SetRadius" ] = { _c, { "radius", n }, _d }
--- Sets the circle renderer's radius.
-- @param circle (CircleRenderer) The circle renderer.
-- @param radius (number) The radius (in scene units).
-- @param draw (boolean) [default=true] Tell whether to re-draw immediately the circle renderer.
function Draw.CircleRenderer.SetRadius( circle, radius, draw )
    circle._radius = radius
    if draw == nil or draw then
        circle:Draw()
    end
end

functionsDebugInfo[ "Draw.CircleRenderer.GetRadius" ] = { _c }
--- Returns the circle renderer's radius.
-- @param circle (CircleRenderer) The circle renderer.
-- @return (number) The radius (in scene units).
function Draw.CircleRenderer.GetRadius( circle )
    return circle._radius
end

functionsDebugInfo[ "Draw.CircleRenderer.SetSegmentCount" ] = { _c, { "count", n }, _d }
--- Sets the circle renderer's segment count.
-- @param circle (CircleRenderer) The circle renderer.
-- @param count (number) The segment count (can't be lower than 3).
-- @param draw (boolean) [default=true] Tell whether to re-draw immediately the circle renderer.
function Draw.CircleRenderer.SetSegmentCount( circle, count, draw )
    if count < 3 then count = 3 end
    if circle._segmentCount ~= count then
        circle._segmentCount = count
        if draw == nil or draw then
            circle:Draw()
        end
    end
end

functionsDebugInfo[ "Draw.CircleRenderer.GetSegmentCount" ] = { _c }
--- Returns the circle renderer's number of segments.
-- @param circle (CircleRenderer) The circle renderer.
-- @return (number) The segment count.
function Draw.CircleRenderer.GetSegmentCount( circle )
    return circle._segmentCount
end

functionsDebugInfo[ "Draw.CircleRenderer.SetWidth" ] = { _c, { "width", n } }
--- Sets the circle renderer segment's width.
-- @param circle (CircleRenderer) The circle renderer.
-- @param width (number) The segment's width (and height).
function Draw.CircleRenderer.SetWidth( circle, width )
    if circle._width ~= width then
        circle._width = width
        if #circle.segments > 0 and draw then
            local newScale = Vector3:New( circle._width, circle._width, circle.segments[1].transform:GetLocalScale().z )
            for i, line in pairs( circle.segments ) do
                line.transform:SetLocalScale( newScale )
            end
        end
    end
end

functionsDebugInfo[ "Draw.CircleRenderer.GetWidth" ] = { _c }
--- Returns the circle renderer's segment's width (and height).
-- @param circle (CircleRenderer) The circle renderer.
-- @return (number) The width (in scene units).
function Draw.CircleRenderer.GetWidth( circle )
    return circle._width
end

functionsDebugInfo[ "Draw.CircleRenderer.SetModel" ] = { _c, { "model", {"string", "Model"}, isOptional = true } }
--- Sets the circle renderer segment's model.
-- @param circle (CircleRenderer) The circle renderer.
-- @param model (string or Model) The segment's model name or asset.
function Draw.CircleRenderer.SetModel( circle, model )
    if 
        ( type( model ) == "string" and circle._model ~= nil and circle._model:GetPath() == model ) or
        circle._model ~= model
    then
        if model ~= nil then
            circle._model = Asset.Get( model, "Model", true )
        else
            circle._model = nil
        end
        for i, line in pairs( circle.segments ) do
            line.modelRenderer:SetModel( circle._model )
        end
    end
end

functionsDebugInfo[ "Draw.CircleRenderer.GetModel" ] = { _c }
--- Returns the circle renderer's segment's model.
-- @param circle (CircleRenderer) The circle renderer.
-- @return (Model) The model asset.
function Draw.CircleRenderer.GetModel( circle )
    return circle._model
end


----------------------------------------------------------------------------------

table.mergein( Daneel.functionsDebugInfo, functionsDebugInfo )

function Draw.DefaultConfig()
    local config = {
        lineRenderer = {
            direction = Vector3:Left(),
            length = 2,
            width = 0.1,
            --endPosition = nil -- Vector3
        },

        circleRenderer = {
            segmentCount = 6,
            radius = 1,
            width = 1,
            model = nil, -- model name or asset
        },
        
        componentObjects = {
            LineRenderer = Draw.LineRenderer,
            CircleRenderer = Draw.CircleRenderer,
        },
    }

    return config
end
Draw.Config = Draw.DefaultConfig()
