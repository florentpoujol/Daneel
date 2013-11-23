
Draw = {}

if CS.DaneelModules == nil then
    CS.DaneelModules = {}
end
CS.DaneelModules[ "Draw" ] = Draw

function Draw.DefaultConfig()
    local config = {
        lineRenderer = {
            direction = Vector3:Left(),
            --length = 2,
            width = 0.1,
            endPosition = nil
        },

        circleRenderer = {

        },

        trailRenderer = {

        },
        
        componentObjects = {
            ["Draw.LineRenderer"] = Draw.LineRenderer,
            ["Draw.CircleRenderer"] = Draw.CircleRenderer,
        },
    }

    return config
end


----------------------------------------------------------------------------------
-- LineRenderer

Draw.LineRenderer = {}

function Draw.LineRenderer.New( gameObject, params )
    
    if params == nil then
        params = {}
    end

    local line = {
        origin = gameObject.transform:GetPosition(),
        Direction = Vector3:Left(),
        Length = 1,
        Width = 1,
        gameObject = gameObject
    }
    line.EndPosition = line.origin
    setmetatable( line, Draw.LineRenderer )
    gameObject.lineRenderer = line


    line:Set( table.merge( Draw.Config.lineRenderer, params ) )

    return line
end

function Draw.LineRenderer.Draw( line )

    line.gameObject.transform:LookAt( line.EndPosition )
    line.gameObject.transform:SetScale( Vector3:New( line.Width, line.Width, line.Length ) )
    Daneel.Event.Fire( line, "OnDraw", line )
end

function Draw.LineRenderer.SetEndPosition( line, endPosition )
    line.EndPosition = endPosition
    line.Direction = (line.EndPosition - line.origin)
    line.Length = line.Direction:Length()
    line:Draw()
end

function Draw.LineRenderer.SetLength( line, length )
    line.Length = length
    line.EndPosition = line.origin + line.Direction * length
    line:Draw()
end

function Draw.LineRenderer.SetDirection( line, direction, useDirectionAsLength )
    line.Direction = direction:Normalized()
    if useDirectionAsLength then
        line.Length = direction:Length()
    end
    line.EndPosition = line.origin + line.Direction * line.Length
    line:Draw()
end

function Draw.LineRenderer.SetWidth( line, width )
    line.Width = width
    line:Draw()
end


----------------------------------------------------------------------------------
-- CircleRenderer

Draw.CircleRenderer = {}

function Draw.CircleRenderer.New( gameObject, params )
    
    if params == nil then
        params = {}
    end
    
    local circle = {
        origin = gameObject.transform:GetPosition(),
        SegmentCount = 6,
        Radius = 1,
        Width = 1,
        lines = {},
        gameObject = gameObject,
    }
    circle.EndPosition = circle.origin
    setmetatable( circle, Draw.CircleRenderer )
    gameObject.circleRenderer = circle


    circle:Set( table.merge( Draw.Config.circleRenderer, params ) )

    return circle
end


function Draw.CircleRenderer.Draw( circle )
    -- coordinatex of a point on a circle
    -- x = center.x + radius * cos( angleInRadian )
    -- y = center.y + radius * sin( angleInRadian )

    local offset = (2*math.pi) / circle.SegmentCount
    local angle = - offset
    
    -- create and position the segments
    for i=1, circle.SegmentCount do
        angle = angle + offset
        local lineStartLocalPosition = Vector3(
            circle.Radius * math.cos( angle ),
            circle.Radius * math.sin( angle ),
            0
        )

        if circle.segments[ i ] == nil then
            local newSegment = CS.CreateGameObject( "Circle", circle.gameObject )
            newSegment:CreateComponent( "ModelRenderer" )
            if circle.Model ~= nil then
                newSegment.modelRenderer:SetModel( circle.Model )
            end
            table.insert( circle.segments[ i ], newSegment )
        end

        circle.segments[ i ].transform:SetLocalPosition( lineStartLocalPosition )
    end

    -- destroy unused gameObjects
    while #circle.segments > circle.SegmentCount do
        table.remove( circle.segments ):Destroy()
    end
    
    circle.SegmentLength = Vector3.Distance( circle.segments[1].transform.position, circle.segments[2].transform.position )
    
    -- scale the segments, setting their width and length
    for i, segment in ipairs( circle.segments ) do
        if circle.segments[ i+1 ] ~= nil then
            segment.transform:LookAt( circle.segments[ i+1 ].transform.position )
        else
            segment.transform:LookAt( circle.segments[1].transform.position )
        end
        segment.transform:SetLocalScale( Vector3:New( circle.Width, circle.Width, circle.SegmentLength ) )
    end
    
    Daneel.Event.Fire( circle, "OnDraw", circle )
end

function Draw.CircleRenderer.SetRadius( circle, radius )
    circle.Radius = radius
    circle:Draw()
end

function Draw.CircleRenderer.SetSegmentCount( circle, count )
    if count < 3 then count = 3 end
    circle.SegmentCount = count
    circle:Draw()
end


function Draw.CircleRenderer.SetWidth( circle, width )
    circle.Width = width
    if #circle.segments > 0 then
        local newScale = Vector3:New( circle.Width, circle.Width, circle.segments[1].transform:GetLocalScale().z )
        for i, line in ipairs( circle.segments ) do
            line.transform:SetLocalScale( newScale )
        end
    end
end

function Draw.CircleRenderer.SetModel( circle, model )
    circle.Model = model
    for i, line in ipairs( circle.segments ) do
        line.modelRenderer:SetModel( circle.Model )
    end
end
