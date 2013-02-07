
GUI = {}



------------------------------
-- GUIText
------------------------------

GUIText = {}
GUIText.__index = GUIText
GUIText.__tostring = function(go) return "GUIText at position '"..tostring(go.transform:GetPosition()) end

local guiTextCallSyntaxError = "Function not called from a GUIText. Your must use a colon ( : ) between the GUIText instance and the method name. Ie : guiText:"


-- Create a new GUIText
-- @param [optional] (table) A table with initialisation position, text and scale
-- @return (GUIText) The new GUIText
function GUIText.New(params, g)
    if params == GUIText then
        params = g
    end
    
    local errorHead = "GUIText.New([params]) : "
    local guiTextMap = Asset.Get(Daneel.config.guiTextMapName, "Map")
    if guiTextMap == nil then
        error(errorHead.."Can't find the GUIText Map asset. Its name should be '"..Daneel.config.guiTextMapName.."' or update the 'guiTextMapName' variable in the config.")
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
    if argType ~= nil and argType ~= "table" then
        error(errorHead.."Optionnal argument 'params' is of type '"..argType.."' with value '"..tostring(params).."' instead of 'table'.")
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

    if type(self) ~= "GUIText" then
        error(errorHead..guiTextCallSyntaxError.."Destroy()")
    end

    self.gameObject:Destroy()
end

-- Set the stored position, text and scale of the GUIText
function GUIText:Refresh()
    local errorHead = "GUIText:Refresh() : "

    if type(self) ~= "GUIText" then
        error(errorHead..guiTextCallSyntaxError.."SetText()")
    end

    self:SetPosition()
    self:SetText()
    self:SetScale()
end


-- 0, 0 is the middle of the screen
-- @param x (table or number) if table, must have x and y keys
-- @param y [optional] (number) If x is number, y must be number
function GUIText:SetPosition(x, y)
    local errorHead = "GUIText:SetPosition([position]) : "

    if type(self) ~= "GUIText" then
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
    local unitX = screenSize.x / cameraScale -- (pixels/unit) unitX is the size in pixel of one unit in 3D world  (1 3Dunit = unitX pixels)
    local unitY = screenSize.y / cameraScale
    
    local position3D = Vector3:New(self.position.x / unitX, self.position.y / unitY, -5)
    
    self.gameObject.transform:SetPosition(position3D)
end


-- Set the text of the GUIText
-- @param (mixed) Something to display (converted to string with tostring())
function GUIText:SetText(text)
    local errorHead = "GUIText:SetText([text]) : "

    if type(self) ~= "GUIText" then
        error(errorHead..guiTextCallSyntaxError.."SetText()")
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


function GUIText:SetScale()

end


