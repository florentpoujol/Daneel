
GUI = {}



------------------------------
-- GUIText
------------------------------

GUIText = {}
GUIText.__index = GUIText

local guiTextCallSyntaxError = "Function not called from a GUIText. Your must use a colon ( : ) between the GUIText instance and the method name. Ie : guiText:"


-- Create a new GUIText
-- @param [optionnal] (table) A table with initialisation position, text and scale
-- @return (table) The new GUIText
function GUIText.New(params, g)
    if params == GUIText then
        params = g
    end
    
    local errorHead = "GUIText.New([params]) : "
    local guiTextMap = Asset.GetMap(Daneel.config.guiTextMapName)
    if guiTextMap == nil then
        error(errorHead.."Can't find the GUIText Map asset. Its name should be '"..Daneel.config.guiTextMapName.."' or update the 'guiTextMapName' variabe in the config.")
    end

    local guiText = {
        position = { x = 0, y = 0 },
        text = "",
        scale = 1,
        map = guiTextMap,
        gameObject = GameObject.New("GUIText", {
            parent = Daneel.config.hudCameraName,
            map = guiTextMap,
            localPosition = Vector3:New(0,0,-5) 
        })
    }
    
    local argType = type(params)
    if params ~= nil and argType ~= "table" then
        error(errorHead.."Optionnal argument 'params' is of type '"..argType.."' instead of 'table'.")
    end
    
    if params ~= nil then
        if params.position ~= nil then
            guiText.position = params.position
        end

        if params.text ~= nil then
            guiText.text = params.text
        end

        if params.scale ~= nil then
            guiText.scale = params.scale
        end
    end

    guiText = setmetatable(guiText, GUIText)
    guiText:Refresh()

    return guiText
end

-- Destroy the GUIText
function GUIText:Destroy()
    local errorHead = "GUIText:Destroy() : "

    if getmetatable(self) ~= GUIText then
        error(errorHead..guiTextCallSyntaxError.."Destroy()")
    end

    self.gameObject:Destroy()
end

-- Set the stored position, text and scale of the GUIText
function GUIText:Refresh()
    local errorHead = "GUIText:Refresh() : "

    if getmetatable(self) ~= GUIText then
        error(errorHead..guiTextCallSyntaxError.."SetText()")
    end

    self:SetPosition()
    self:SetText()
    self:SetScale()
end


-- 0, 0 is the middle of the screen
function GUIText:SetPosition(x, y)
    local errorHead = "GUIText:SetPosition([position]) : "

    if getmetatable(self) ~= GUIText then
        error(errorHead..guiTextCallSyntaxError.."SetPosition()")
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
    local unitX = screenSize.x / cameraScale --unitX is the number of pixel that take one unit in 3D world
    local unitY = screenSize.y / cameraScale
    
    local position3D = Vector3:New(self.position.x / unitX, self.position.y / unitY, -5)
    
    self.gameObject.transform:SetPosition(position3D)
end


function GUIText:SetText(text)
    local errorHead = "GUIText:SetText([text]) : "

    if getmetatable(self) ~= GUIText then
        error(errorHead..guiTextCallSyntaxError.."SetText()")
    end

    if text ~= nil then
        self.text = tostring(text)
    end

    for i = 1, self.text:len() do
        self.map:SetBlockAt(i, 0, 0, self.text:byte(i), Map.BlockOrientation.North)
    end
end


function GUIText:SetScale()

end


