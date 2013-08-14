
Draw = {}

if CS.DaneelModules == nil then
    CS.DaneelModules = {}
end
CS.DaneelModules[ "Draw" ] = {}

function Draw.Config()
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

    config.componentTypes = table.getkeys( config.componentObjects )

    Daneel.Config.allComponentObjects   = table.merge( Daneel.Config.allComponentObjects, config.componentObjects )
    Daneel.Config.allComponentTypes     = table.merge( Daneel.Config.allComponentTypes, config.componentTypes )
    Daneel.Config.allObjects            = table.merge( Daneel.Config.allObjects, config.componentObjects )

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
    -- coordinate of a point on a circle
    -- x = center.x + radius * cos( angleInRadian )
    -- y = center.y + radius * sin( angleInRadian )

    local offset = (2*math.pi) / circle.SegmentCount
    local angle = - offset
    -- create and scale the gameObjects
    for i=1, circle.SegmentCount do
        angle = angle + offset
        local lineStartLocalPosition = Vector3(
            circle.Radius * math.cos( angle ),
            circle.Radius * math.sin( angle ),
            0
        )

        if circle.lines[ i ] == nil then
            local newLine = GameObject( "Circle", {
                parent = circle.gameObject,
                transform = {
                    localPosition = lineStartLocalPosition,
                },
                modelRenderer = {
                    model = circle.Model
                }
            } )

            table.insert( circle.lines, newLine )
        else
            circle.lines[ i ].transform:SetLocalPosition( lineStartLocalPosition )
        end
    end

    
    while #circle.lines > circle.SegmentCount do
        local line = table.remove( circle.lines )
        line:Destroy()
    end

    circle.SegmentLength = Vector3.Distance( circle.lines[1].transform.position, circle.lines[2].transform.position )

    for i, line in ipairs( circle.lines ) do
        if circle.lines[ i+1 ] ~= nil then
            line.transform:LookAt( circle.lines[ i+1 ].transform.position )
        else
            line.gameObject.transform:LookAt( circle.lines[ 1 ] )
        end
        line.transform:SetLocalScale( Vector3:New( circle.Width, circle.Width, circle.SegmentLength ) )
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
    if #circle.lines > 0 then
        local newScale = Vector3:New( circle.Width, circle.Width, circle.lines[1].transform:GetLocalScale().z )
        for i, line in ipairs( circle.lines ) do
            line.transform:SetLocalScale( newScale )
        end
    end
    circle:Draw()
end

function Draw.CircleRenderer.SetModel( circle, model )
    circle.Model = model
    for i, line in ipairs( circle.lines ) do
        line.modelRenderer:SetModel( circle.Model )
    end
end
