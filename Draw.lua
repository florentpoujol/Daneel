-- Draw.lua
-- Module adding the Draw components.
--
-- Last modified for v1.3.1
-- Copyright © 2013-2014 Florent POUJOL, published under the MIT license.

Draw = {}

if CS.DaneelModules == nil then
    CS.DaneelModules = {}
end
CS.DaneelModules[ "Draw" ] = Draw

local functionsDebugData = {}

----------------------------------------------------------------------------------
-- LineRenderer

Draw.LineRenderer = {}

--- Creates a new LineRenderer component.
-- @param gameObject (GameObject) The game object.
-- @param params (table) A table of parameters.
-- @return (LineRenderer) The new component.
function Draw.LineRenderer.New( gameObject, params )
    Daneel.Debug.StackTrace.BeginFunction( "Draw.LineRenderer.New", gameObject, params )
    local errorHead = "Draw.LineRenderer.New( gameObject, params ) : "
    Daneel.Debug.CheckArgType( gameObject, "gameObject", "GameObject", errorHead )
    params = Daneel.Debug.CheckOptionalArgType( params, "params", "table", errorHead, {} )

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
    line:Set( table.merge( Draw.Config.lineRenderer, params ) )

    Daneel.Debug.StackTrace.EndFunction()
    return line
end

--- Apply the content of the params argument to the provided line renderer.
-- Overwrite Component.Set().
-- @param line (LineRenderer) The line renderer.
-- @param params (table) A table of parameters.
function Draw.LineRenderer.Set( line, params )
    Daneel.Debug.StackTrace.BeginFunction( "Draw.LineRenderer.Set", line, params )
    local errorHead = "Draw.LineRenderer.Set( line, params ) : "
    Daneel.Debug.CheckArgType( line, "line", "LineRenderer", errorHead )
    Daneel.Debug.CheckArgType( params, "params", "table", errorHead )

    local draw = false

    if params.endPosition and (params.length or params.direction) then
        if Daneel.Config.debug.enableDebug then
            local text = errorHead.."The 'endPosition' property is set."
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

    for key, value in pairs( params ) do
        local funcName = "Set"..string.ucfirst( key )
        if Draw.LineRenderer[ funcName ] ~= nil then
            draw = true
            if funcName == "SetDirection" then
                Draw.LineRenderer[ funcname ]( line, value, nil, false )
            else
                Draw.LineRenderer[ funcname ]( line, value, false )
            end
        end
    end

    if draw then
        line:Draw()
    end

    Daneel.Debug.StackTrace.EndFunction()
end

--- Draw the line renderer. Updates the game object based on the line renderer's properties.
-- Fires the OnDraw event on the line renderer.
-- @param line (LineRenderer) The line renderer.
function Draw.LineRenderer.Draw( line )
    Daneel.Debug.StackTrace.BeginFunction( "Draw.LineRenderer.Draw", line )
    local errorHead = "Draw.LineRenderer.Draw( line ) : "
    Daneel.Debug.CheckArgType( line, "line", "LineRenderer", errorHead )

    line.gameObject.transform:LookAt( line._endPosition )
    line.gameObject.transform:SetLocalScale( Vector3:New( line._width, line._width, line._length ) )
    Daneel.Event.Fire( line, "OnDraw", line )

    Daneel.Debug.StackTrace.EndFunction()
end

--- Set the line renderer's end position.
-- It also updates the line renderer's direction and length.
-- @param line (LineRenderer) The line renderer.
-- @param endPosition (Vector3) The end position.
-- @param draw (boolean) [optional default=true] Tell whether to re-draw immediately the line renderer.
function Draw.LineRenderer.SetEndPosition( line, endPosition, draw )
    Daneel.Debug.StackTrace.BeginFunction( "Draw.LineRenderer.SetEndPosition", line, endPosition, draw )
    local errorHead = "Draw.LineRenderer.SetEndPosition( line, endPosition, draw ) : "
    Daneel.Debug.CheckArgType( line, "line", "LineRenderer", errorHead )
    Daneel.Debug.CheckArgType( endPosition, "endPosition", "Vector3", errorHead )
    draw = Daneel.Debug.CheckOptionalArgType( draw, "draw", "boolean", errorHead, true )

    line._endPosition = endPosition
    line._direction = (line._endPosition - line.origin)
    line._length = line._direction:Length()
    if draw then
        line:Draw()
    end

    Daneel.Debug.StackTrace.EndFunction()
end

--- Set the line renderer's length.
-- It also updates line renderer's end position.
-- @param line (LineRenderer) The line renderer.
-- @param length (number) The length (in scene units).
-- @param draw (boolean) [optional default=true] Tell whether to re-draw immediately the line renderer.
function Draw.LineRenderer.SetLength( line, length, draw )
    Daneel.Debug.StackTrace.BeginFunction( "Draw.LineRenderer.SetEndPosition", line, length, draw )
    local errorHead = "Draw.LineRenderer.SetEndPosition( line, length, draw ) : "
    Daneel.Debug.CheckArgType( line, "line", "LineRenderer", errorHead )
    Daneel.Debug.CheckArgType( length, "length", "number", errorHead )
    draw = Daneel.Debug.CheckOptionalArgType( draw, "draw", "boolean", errorHead, true )

    line._length = length
    line._endPosition = line.origin + line._direction * length
    if draw then
        line:Draw()
    end
    Daneel.Debug.StackTrace.EndFunction()
end

-- functionsDebugData[ "Draw.LineRenderer.SetDirection" ] = {
--     { name = "line", type = "LineRenderer" },
--     { name = "direction", type = "Vector3" }
--     { name = "useDirectionAsLength", type = "boolean", defaultValue = false }
--     { name = "draw", type = "boolean", defaultValue = true }
-- }

--- Set the line renderer's direction.
-- It also updates line renderer's end position.
-- @param line (LineRenderer) The line renderer.
-- @param direction (Vector3) The direction.
-- @param useDirectionAsLength (boolean) [optional default=false] Tell whether to update the line renderer's length based on the provided direction's vector length.
-- @param draw (boolean) [optional default=true] Tell whether to re-draw immediately the line renderer.
function Draw.LineRenderer.SetDirection( line, direction, useDirectionAsLength, draw )
    Daneel.Debug.StackTrace.BeginFunction( "Draw.LineRenderer.SetDirection", line, direction, useDirectionAsLength, draw )
    local errorHead = "Draw.LineRenderer.SetDirection( line, direction, useDirectionAsLength, draw ) : "
    Daneel.Debug.CheckArgType( line, "line", "LineRenderer", errorHead )
    Daneel.Debug.CheckArgType( direction, "direction", "Vector3", errorHead )
    useDirectionAsLength = Daneel.Debug.CheckOptionalArgType( useDirectionAsLength, "useDirectionAsLength", "boolean", errorHead, false )
    draw = Daneel.Debug.CheckOptionalArgType( draw, "draw", "boolean", errorHead, true )

    line._direction = direction:Normalized()
    if useDirectionAsLength then
        line._length = direction:Length()
    end
    line._endPosition = line.origin + line._direction * line._length
    if draw then
        line:Draw()
    end
    Daneel.Debug.StackTrace.EndFunction()
end

--- Set the line renderer's width (and height).
-- @param line (LineRenderer) The line renderer.
-- @param width (number) The width (in scene units).
-- @param draw (boolean) [optional default=true] Tell whether to re-draw immediately the line renderer.
function Draw.LineRenderer.SetWidth( line, width, draw )
    Daneel.Debug.StackTrace.BeginFunction( "Draw.LineRenderer.SetWidth", line, width, draw )
    local errorHead = "Draw.LineRenderer.SetWidth( line, width, draw ) : "
    Daneel.Debug.CheckArgType( line, "line", "LineRenderer", errorHead )
    Daneel.Debug.CheckArgType( width, "width", "number", errorHead )
    draw = Daneel.Debug.CheckOptionalArgType( draw, "draw", "boolean", errorHead, true )

    line._width = width
    if draw then
        line:Draw()
    end
    Daneel.Debug.StackTrace.EndFunction()
end


----------------------------------------------------------------------------------
-- CircleRenderer

Draw.CircleRenderer = {}

functionsDebugData[ "Draw.CircleRenderer.New" ] = {
    { name = "gameObject", type = "GameObject" },
    { name = "params", type = "table", defaultValue = {} }
}
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

functionsDebugData[ "Draw.CircleRenderer.Draw" ] = { { name = "circle", type = "CircleRenderer" } }
--- Draw the circle renderer. Updates the game object based on the circle renderer's properties.
-- Fires the OnDraw event at the circle renderer.
-- @param circle (CircleRenderer) The circle renderer.
function Draw.CircleRenderer.Draw( circle )
    -- coordinate of a point on a circle
    -- x = center.x + radius * cos( angleInRadian )
    -- y = center.y + radius * sin( angleInRadian )

    local offset = (2*math.pi) / circle._segmentCount
    local angle = -offset
    
    -- create and position the segments
    for i=1, circle._segmentCount do
        angle = angle + offset
        local lineStartLocalPosition = Vector3:New(
            circle._radius * math.cos( angle ),
            circle._radius * math.sin( angle ),
            0
        )

        if circle.segments[ i ] == nil then
            local newSegment = CS.CreateGameObject( "Circle "..circle:GetId().." Segment "..i, circle.gameObject )
            newSegment:CreateComponent( "ModelRenderer" )
            if circle._model ~= nil then
                newSegment.modelRenderer:SetModel( circle._model )
            end
            table.insert( circle.segments[ i ], newSegment )
        end

        circle.segments[ i ].transform:SetLocalPosition( lineStartLocalPosition )
    end

    -- destroy unused gameObjects
    while #circle.segments > circle._segmentCount do
        table.remove( circle.segments ):Destroy()
    end
    
    local firstSegmentPosition = circle.segments[1].transform:GetPosition()
    circle._segmentLength = Vector3.Distance( firstSegmentPosition, circle.segments[2].transform:GetPosition() )
    
    -- scale the segments, setting their width and length
    for i, segment in ipairs( circle.segments ) do
        if circle.segments[ i+1 ] ~= nil then
            segment.transform:LookAt( circle.segments[ i+1 ].transform:GetPosition() )
        else
            segment.transform:LookAt( firstSegmentPosition )
        end
        segment.transform:SetLocalScale( Vector3:New( circle._width, circle._width, circle._segmentLength ) )
    end
    
    Daneel.Event.Fire( circle, "OnDraw", circle )
end

functionsDebugData[ "Draw.CircleRenderer.SetRadius" ] = { 
    { name = "circle", type = "CircleRenderer" },
    { name = "radius", type = "number" },
    { name = "draw", type = "boolean", defaultValue = true },
}
--- Sets the circle renderer's radius.
-- @param circle (LineRenderer) The circle renderer.
-- @param radius (number) The radius (in scene units).
-- @param draw (boolean) [optional default=true] Tell whether to re-draw immediately the circle renderer.
function Draw.CircleRenderer.SetRadius( circle, radius, draw )
    circle._radius = radius
    if draw then
        circle:Draw()
    end
end

functionsDebugData[ "Draw.CircleRenderer.SetSegmentCount" ] = { 
    { name = "circle", type = "CircleRenderer" },
    { name = "count", type = "number" },
    { name = "draw", type = "boolean", defaultValue = true },
}
--- Sets the circle renderer's segment count.
-- @param circle (LineRenderer) The circle renderer.
-- @param count (number) The segment count (can't be lower than 3).
-- @param draw (boolean) [optional default=true] Tell whether to re-draw immediately the circle renderer.
function Draw.CircleRenderer.SetSegmentCount( circle, count, draw )
    if count < 3 then count = 3 end
    if circle._segmentCount ~= count then
        circle._segmentCount = count
        if draw then
            circle:Draw()
        end
    end
end

functionsDebugData[ "Draw.CircleRenderer.SetWidth" ] = { 
    { name = "circle", type = "CircleRenderer" },
    { name = "width", type = "number" },
    { name = "draw", type = "boolean", defaultValue = true },
}
--- Sets the circle renderer segment's width.
-- @param circle (LineRenderer) The circle renderer.
-- @param width (number) The segment's width (and height).
-- @param draw (boolean) [optional default=true] Tell whether to re-draw immediately the circle renderer.
function Draw.CircleRenderer.SetWidth( circle, width, draw )
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

functionsDebugData[ "Draw.CircleRenderer.SetModel" ] = { 
    { name = "circle", type = "CircleRenderer" },
    { name = "model", type = {"string", "Model"} },
    { name = "draw", type = "boolean", defaultValue = true },
}
--- Sets the circle renderer segment's model.
-- @param circle (LineRenderer) The circle renderer.
-- @param model (string or Model) The segment's model name or asset.
-- @param draw (boolean) [optional default=true] Tell whether to re-draw immediately the circle renderer.
function Draw.CircleRenderer.SetModel( circle, model, draw )
    if circle._model ~= model and circle._model:GetPath() ~= model then
        circle._model = Asset.Get( model, "Model", true )
        for i, line in pairs( circle.segments ) do
            line.modelRenderer:SetModel( circle._model )
        end
    end
end



----------------------------------------------------------------------------------

function Draw.DefaultConfig()
    local config = {
        functionsDebugData = functionsDebugData,
        
        lineRenderer = {
            direction = Vector3:Left(),
            --length = 2,
            width = 0.1,
            --endPosition = nil
        },

        circleRenderer = {
            --segmentCount = 6,
            --radius = 1,
            --width = 1,
            --model = nil, -- model name or asset
        },
        
        componentObjects = {
            lineRenderer = Draw.LineRenderer,
            circleRenderer = Draw.CircleRenderer,
        },
    }

    return config
end
Draw.Config = Draw.DefaultConfig()
