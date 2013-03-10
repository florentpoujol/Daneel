
if Daneel == nil then 
    Daneel = {}
end

Daneel.GUI = {}


-- create a ray and check its colision with any gui element
function Daneel.GUI.CheckRayFromCamera()
    Daneel.Debug.StackTrace.BeginFunction("Daneel.GUI.CheckRayFromCamera")
    
    local ray = Daneel.config.hudCameraGO:GetComponent("Camera"):CreateRay(CraftStudio.Input.GetMousePosition())
    local guiLabels = Daneel.GUI.labels

    for i, guiLabel in ipairs(guiLabels) do
        if ray:IntersectsMapRenderer(guiLabel.gameObject:GetComponent("MapRenderer")) then
            -- do
        end
    end

    Daneel.Debug.StackTrace.EndFunction("Daneel.GUI.CheckRayFromCamera")
end




----------------------------------------------------------------------------------
-- GUILabel (on screen text)

Daneel.GUI.labels = {}

GUILabel = {}
GUILabel.__index = GUILabel

function GUILabel.__tostring(label) 
    return "GUILabel instance '"..label.name.."'"
end

local guiLabelCallSyntaxError = "Function not called from a GUILabel. Your must use a colon ( : ) between the GUILabel instance and the method name. Ie : guiLabel:"


-- Create a new GUILabel
-- @param name (string) The label name
-- @param params [optional] (table) A table with initialisation position, text and scale
-- @return (GUILabel) The new GUILabel
function GUILabel.New(name, params)
    Daneel.Debug.StackTrace.BeginFunction("GUILabel.New", name, params)
    local errorHead = "GUILabel.New(name, [params]) : "

    local argType = type(name)
    if argType ~= "string" then
        error(errorHead.."Argument 'name' is of type '"..argType.."' with value '"..tostring(name).."' instead of 'string'.")
    end

    local guiLabel = Daneel.GUI.labels[name]

    if guiLabel ~= nil then
        Daneel.Debug.StackTrace.EndFunction("GUILabel.New", guiLabel)
        return guiLabel
    end
    
    local guiTextMap = Asset.Get(Daneel.config.guiTextMapName, "Map")
    if guiTextMap == nil then
        error(errorHead.."Can't find the GUILabel Map asset. Its name should be '"..Daneel.config.guiTextMapName.."' or update the 'guiTextMapName' variable in the config.")
    end

    guiLabel = {
        name = name,
        position = { x = 0, y = 0 },
        text = "",
        scale = 1,
        map = guiLabelMap,
        gameObject = GameObject.New("GUILabel."..name, {
            parent = Daneel.config.hudCameraName,
            map = guiLabelMap,
            localPosition = Vector3:New(0,0,-5) 
        })
    }
    
    argType = type(params)
    if argType ~= nil and argType ~= "table" then
        error(errorHead.."Optional argument 'params' is of type '"..argType.."' with value '"..tostring(params).."' instead of 'table'.")
    end
    
    if params ~= nil then
        if params.position ~= nil then
            guiLabel.position = params.position
        end

        if params.text ~= nil then
            guiLabel.text = params.text
        end

        if params.scale ~= nil then
            guiLabel.scale = params.scale
        end
    end

    guiLabel = setmetatable(guiLabel, GUILabel)
    guiLabel:Refresh()

    Daneel.Debug.StackTrace.EndFunction("GUILabel.New", guiLabel)
    return guiLabel
end


-- Destroy the GUILabel
-- @param guiLabel (GUILabel) The GUILabel
function GUILabel.Destroy(guiLabel)
    Daneel.Debug.StackTrace.BeginFunction("GUILabel.Destroy", guiLabel)
    local errorHead = "GUILabel.Destroy(guiLabel) : "

    local argType = Daneel.Debug.GetType(guiLabel)
    if argType ~= "GUILabel" then
        error(errorHead.."Argument 'guiLabel' is of type '"..argType.."' with value '"..tostring(guiLabel).."' instead of 'GUILabel'.")
    end

    guiLabel.gameObject:Destroy()
    Daneel.Debug.StackTrace.EbndFunction("GUILabel.Destroy")
end


-- Set the stored position, text and scale of the GUILabel
-- @param guiLabel (GUILabel) The GUILabel
function GUILabel.Refresh(guiLabel)
    Daneel.Debug.StackTrace.BeginFunction("GUILabel.Refresh", guiLabel)
    local errorHead = "GUILabel:Refresh() : "

    local argType = Daneel.Debug.GetType(guiLabel)
    if argType ~= "GUILabel" then
        error(errorHead.."Argument 'guiLabel' is of type '"..argType.."' with value '"..tostring(guiLabel).."' instead of 'GUILabel'.")
    end

    guiLabel:SetPosition()
    guiLabel:SetText()
    guiLabel:SetScale()
    Daneel.Debug.StackTrace.EndFunction("GUILabel.Refresh")
end


-- 0, 0 is the middle of the screen
-- @param guiLabel (GUILabel) The GUILabel
-- @param x (table or number) if table, must have x and y keys
-- @param y [optional] (number) If x is number, y must be number
function GUILabel.SetPosition(guiLabel, x, y)
    Daneel.Debug.StackTrace.BeginFunction("GUILabel.SetPosition", guiLabel, x, y)
    local errorHead = "GUILabel.SetPosition(guiLabel, x[, y]) : "

    local argType = Daneel.Debug.GetType(guiLabel)
    if argType ~= "GUILabel" then
        error(errorHead.."Argument 'guiLabel' is of type '"..argType.."' with value '"..tostring(guiLabel).."' instead of 'GUILabel'.")
    end
    
    if type(x) == "table" and type(y) == "nil" then
        guiLabel.position.x = tonumber(x.x)
        guiLabel.position.y = tonumber(x.y)
    elseif type(x) ~= "table" and type(y) ~= "nil" then
        guiLabel.position.x = tonumber(x)
        guiLabel.position.y = tonumber(y)
    end
        
    local screenSize = Daneel.config.screenSize
    local cameraScale = Daneel.config.hudCameraOrthographicScale -- cameraScale is the with in unit of the camera viewport
    local unitX = screenSize.x / cameraScale -- (pixels/unit) unitX is the size in pixel of one unit in 3D world  (1 3Dunit = unitX pixels)
    local unitY = screenSize.y / cameraScale
    
    local position3D = Vector3:New(guiLabel.position.x / unitX, guiLabel.position.y / unitY, -5)
    
    guiLabel.gameObject.transform:SetPosition(position3D)
    Daneel.Debug.StackTrace.EndFunction("GUILabel.SetPosition")
end


-- Set the text of the GUILabel
-- @param guiLabel (GUILabel) The guiLabel
-- @param text [optional] (mixed) Something to display (converted to string with tostring())
function GUILabel.SetText(guiLabeel, text)
    Daneel.Debug.StackTrace.BeginFunction("GUILabel.SetText", guiLabel)
    local errorHead = "GUILabel.SetText(guiLabel[, text]) : "

    local argType = Daneel.Debug.GetType(guiLabel)
    if argType ~= "GUILabel" then
        error(errorHead.."Argument 'guiLabel' is of type '"..argType.."' with value '"..tostring(guiLabel).."' instead of 'GUILabel'.")
    end

    if text ~= nil then
        guiLabel.text = tostring(text)
    end

    for i = 1, guiLabel.text:len() do
        local byte = guiLabel.text:byte(i)

        if byte > 255 then byte = string.byte("?", 1) end -- should be 64

        guiLabel.map:SetBlockAt(i, 0, 0, byte, Map.BlockOrientation.North)
    end

    Daneel.Debug.StackTrace.EndFunction("GUILabel.SetText")
end

-- Set the gameOject's local scale
-- @param guiLabel (GUILabel) The guiLabel
-- @param scale [optional] (number or Vector3) The local scale
function GUILabel.SetScale(guiLabel, scale)
    Daneel.Debug.StackTrace.BeginFunction("GUILabel.SetScale", guiLabel)
    local errorHead = "GUILabel.SetScale(guiLabel[, scale]) : "

    local argType = Daneel.Debug.GetType(guiLabel)
    if argType ~= "GUILabel" then
        error(errorHead.."Argument 'guiLabel' is of type '"..argType.."' with value '"..tostring(guiLabel).."' instead of 'GUILabel'.")
    end

    if argType ~= nil then
        guiLabel.scale = scale
    end

    argType = Daneel.Debug.GetType(guiLabel.scale)
    if argType ~= "number" and argType ~= "Vector3" then
        error(errorHead.."Argument 'scale' is of type '"..argType.."' with value '"..tostring(scale).."' instead of 'number' or 'Vector3'.")
    end
       
    if argType == "number" then
        guiLabel.scale = Vector3:New(guiLabel.scale)
    end

    guiLabel.gameObject.transform:SetLocalScale(guiLabel.scale)
    Daneel.Debug.StackTrace.EndFunction("GUILabel.SetScale")
end


