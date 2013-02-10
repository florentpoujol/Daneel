
if Daneel == nil then Daneel = {} end

Daneel.GUI = {}


-- create a ray and check its colision with any gui element
function Daneel.GUI.CheckRayFromCamera()
    local ray = Daneel.config.hudCameraGO:GetComponent("Camera"):CreateRay(CraftStudio.Input.GetMousePosition())

    local guiLabels = Daneel.GUI.labels

    for i, guiLabel in ipairs(guiLabels) do
        if ray:IntersectsMapRenderer(guiLabel.gameObject:GetComponent("MapRenderer")) then
            -- do
        end
    end
end







----------------------------------------------------------------------------------
-- GUILabel (on screen text)


Daneel.GUI.labels = table.new()

GUILabel = {}
GUILabel.__index = GUILabel

function GUILabel.__tostring(label) 
    return "GUILabel instance '"..label.name.."'"
end

local guiLabelCallSyntaxError = "Function not called from a GUILabel. Your must use a colon ( : ) between the GUILabel instance and the method name. Ie : guiLabel:"


-- Create a new GUILabel
-- @param [optional] (table) A table with initialisation position, text and scale
-- @return (GUILabel) The new GUILabel
function GUILabel.New(name, params, g)
    if name == GUILabel then
        name = params
        params = g
    end

    local argType = type(name)
    if argType ~= "string" then
        error(errorHead.."Argument 'name' is of type '"..argType.."' with value '"..tostring(name).."' instead of 'string'.")
    end

    if Daneel.GUI.labels:containskey(name) then
        return Daneel.GUI.labels[name]
    end
    
    local errorHead = "GUILabel.New(name, [params]) : "
    local guiTextMap = Asset.Get(Daneel.config.guiTextMapName, "Map")
    if guiTextMap == nil then
        error(errorHead.."Can't find the GUILabel Map asset. Its name should be '"..Daneel.config.guiTextMapName.."' or update the 'guiTextMapName' variable in the config.")
    end

    local guiLabel = {
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
    
    local argType = type(params)
    if argType ~= nil and argType ~= "table" then
        error(errorHead.."Optionnal argument 'params' is of type '"..argType.."' with value '"..tostring(params).."' instead of 'table'.")
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

    return guiLabel
end

-- Destroy the GUILabel
function GUILabel:Destroy()
    local errorHead = "GUILabel:Destroy() : "

    if cstype(self) ~= "GUILabel" then
        error(errorHead..guiLabelCallSyntaxError.."Destroy()")
    end

    self.gameObject:Destroy()
end

-- Set the stored position, text and scale of the GUILabel
function GUILabel:Refresh()
    local errorHead = "GUILabel:Refresh() : "

    if cstype(self) ~= "GUILabel" then
        error(errorHead..guiLabelCallSyntaxError.."SetText()")
    end

    self:SetPosition()
    self:SetText()
    self:SetScale()
end


-- 0, 0 is the middle of the screen
-- @param x (table or number) if table, must have x and y keys
-- @param y [optional] (number) If x is number, y must be number
function GUILabel:SetPosition(x, y)
    local errorHead = "GUILabel:SetPosition([position]) : "

    if cstype(self) ~= "GUILabel" then
        error(errorHead..guiLabelCallSyntaxError.."SetPosition()")
    end
    
    if type(x) == "table" and type(y) == "nil" then
        self.position.x = tonumber(x.x)
        self.position.y = tonumber(x.y)
    elseif type(x) ~= "table" and type(y) ~= "nil" then
        self.position.x = tonumber(x)
        self.position.y = tonumber(y)
    end
        
    local screenSize = Daneel.config.screenSize
    local cameraScale = Daneel.config.hudCameraOrthographicScale -- cameraScale is the with in unit of the camera viewport
    local unitX = screenSize.x / cameraScale -- (pixels/unit) unitX is the size in pixel of one unit in 3D world  (1 3Dunit = unitX pixels)
    local unitY = screenSize.y / cameraScale
    
    local position3D = Vector3:New(self.position.x / unitX, self.position.y / unitY, -5)
    
    self.gameObject.transform:SetPosition(position3D)
end


-- Set the text of the GUILabel
-- @param (mixed) Something to display (converted to string with tostring())
function GUILabel:SetText(text)
    local errorHead = "GUILabel:SetText([text]) : "

    if cstype(self) ~= "GUILabel" then
        error(errorHead..guiLabelCallSyntaxError.."SetText()")
    end

    if text ~= nil then
        self.text = tostring(text)
    end

    for i = 1, self.text:len() do
        local byte = self.text:byte(i)

        if byte > 255 then byte = string.byte("?", 1) end -- should be 64

        self.map:SetBlockAt(i, 0, 0, byte, Map.BlockOrientation.North)
    end
end

-- Set the gameOject's local scale
-- @param scale (number or Vector3) The local scale
function GUILabel:SetScale(scale)
    local errorHead = "GUILabel:SetScale(scale) : "

    if cstype(self) ~= "GUILabel" then
        error(errorHead..guiLabelCallSyntaxError.."SetScale()")
    end

    if argType ~= nil then
        self.scale = scale
    end

    argType = cstype(self.scale)
    if argType ~= "number" and argType ~= "Vector3" then
        error(errorHead.."Argument 'scale' is of type '"..argType.."' with value '"..tostring(scale).."' instead of 'number' or 'Vector3'.")
    end
       
    if argType == "number" then
        self.scale = Vector3:New(self.scale)
    end

    self.gameObject.transform:SetLocalScale(self.scale)
end


