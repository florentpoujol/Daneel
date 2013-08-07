
Draw = {}

if CS.DaneelModules == nil then
    CS.DaneelModules = {}
end
CS.DaneelModules[ "Draw" ] = {}

function Draw.Config()
    local config = {
        
            line = {
                direction = Vector3:Left(),
                length = 2,
                width = 0.1,
                endPosition = nil
            },

            circle = {

            },
            
            componentObjects = {
                ["Draw.LineRenderer"] = Draw.LineRenderer,
                ["Draw.CircleRenderer"] = Draw.CircleRenderer,
            },
        
    }
    Draw.Config = config.draw
    
    Draw.Config.componentTypes = table.getkeys( Draw.Config.componentObjects )

    Daneel.Config.allComponentObjects   = table.merge( Daneel.Config.allComponentObjects, Draw.Config.componentObjects )
    Daneel.Config.allComponentTypes     = table.merge( Daneel.Config.allComponentTypes, Draw.Config.componentTypes )
    Daneel.Config.allObjects            = table.merge( Daneel.Config.allObjects, Draw.Config.componentObjects )

    return config
end

function Draw.Load()
    Daneel.Config.draw = Draw.Config
end


----------------------------------------------------------------------------------
-- LineRenderer

Draw.LineRenderer = {}

function Draw.LineRenderer.New( gameObject, params )

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

    line:Set( table.merge( Daneel.Config.draw.lineRenderer, params ) )

    return line
end

function Draw.LineRenderer.Draw( line )

    line.gameObject.transform:LookAt( line.EndPosition )
    line.gameObject.transform:SetLocalScale( Vector3:New( line.Width, line.Width, line.Length ) )
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

function Draw.LineRenderer.SetDirection( line, direction )
    line.Direction = direction
    line.EndPosition = line.origin + line.Direction * length
    line:Draw()
end

function Draw.LineRenderer.SetWidth( line, width )
    line.Width = width
    line:Draw()
end
