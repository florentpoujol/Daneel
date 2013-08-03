


DaneelDraw = {}

function DaneelConfigModuleDraw()
    Daneel.Draw = DaneelDraw

    return {
        draw = {
            line = {
                direction = Vector3:Left(),
                length = 2,
                width = 0.1,
                endPosition = nil
            },

        },

        daneelComponentObjects = {
            LineRenderer = Daneel.Draw.LineRenderer,
            CircleRenderer = Daneel.Draw.CircleRenderer,
        },
    }
end

----------------------------------------------------------------------------------

DaneelDraw.LineRenderer = {}

function DaneelDraw.LineRenderer.New( gameObject )

    local line = {
        origin = gameObject.transform:GetPosition(),
        Direction = Vector3:Left(),
        Length = 1,
        Width = 1,
        gameObject = gameObject
    }
    line.EndPosition = line.origin
    setmetatable( line, Daneel.Draw.LineRenderer )
    gameObject.lineRenderer = line

    for key, value in pairs( Daneel.Config.draw.lineRenderer ) do
        line[key] = value
    end

    return line
end

function DaneelDraw.LineRenderer.Draw( line )

    line.gameObject.transform:LookAt( line.EndPosition )
    line.gameObject.transform:SetLocalScale( Vector3:New( line.Width, line.Width, line.Length ) )
    Daneel.Event.Fire( line, "OnDraw", line )
end

function DaneelDraw.LineRenderer.SetEndPosition( line, endPosition )
    line.EndPosition = endPosition
    line.Direction = (line.EndPosition - line.origin)
    line.Length = line.Direction:Length()
    line:Draw()
end

function DaneelDraw.LineRenderer.SetLength( line, length )
    line.Length = length
    line.EndPosition = line.origin + line.Direction * length
    line:Draw()
end

function DaneelDraw.LineRenderer.SetDirection( line, direction )
    line.Direction = direction
    line.EndPosition = line.origin + line.Direction * length
    line:Draw()
end

function DaneelDraw.LineRenderer.SetWidth( line, width )
    line.Width = width
    line:Draw()
end
