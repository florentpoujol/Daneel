
if Daneel == nil then
    Daneel = {}
end


----------------------------------------------------------------------------------
-- GUI

Daneel.GUI = { elements = {} }

--- Get the GUI element of the provoded name.
-- @param name (string) The name.
-- @return (Daneel.GUI.Text) The element or nil if none is found
function Daneel.GUI.Get(name)
    Daneel.Debug.StackTrace.BeginFunction("Daneel.GUI.Get", name)
    Daneel.Debug.CheckArgType(name, "name", "string", "Daneel.GUI.Get(name) : ")
    Daneel.Debug.StackTrace.EndFunction()
    return Daneel.GUI.elements[name]
end

--- Destroy the provided element.
-- @param element (Daneel.GUI.Text) The element.
function Daneel.GUI.Destroy(element)
    Daneel.Debug.StackTrace.BeginFunction("Daneel.GUI.Destroy", element)
    local errorHead = "Daneel.GUI.Destroy(element) : "
    Daneel.Debug.CheckArgType(element, "element", Daneel.config.guiTypes, errorHead)
    element.gameObject:Destroy()
    Daneel.Debug.StackTrace.EndFunction()
end


----------------------------------------------------------------------------------
-- Common

Daneel.GUI.Common = {} -- common functions for GUI Elements
Daneel.GUI.Common.__index = Daneel.GUI.Common
    

--- Set the element's scale which is actually the gameObject's local scale.
-- @param element (Daneel.GUI.Text) The element.
-- @param scale (number or Vector3) The local scale.
function Daneel.GUI.Common.SetScale(element, scale)
    Daneel.Debug.StackTrace.BeginFunction("Daneel.GUI.Common.SetScale", element)
    local errorHead = "Daneel.GUI.Common.SetScale(element, scale) : "
    Daneel.Debug.CheckArgType(element, "element", Daneel.config.guiTypes, errorHead)
    Daneel.Debug.CheckArgType(scale, "scale", {"number", "Vector3"}, errorHead)

    if type(scale) == "number" then
        scale = Vector3:New(scale)
    end
    element.gameObject.transform.localScale = scale
    Daneel.Debug.StackTrace.EndFunction()
end

--- Get the element's scale.
-- @param element (Daneel.GUI.Text) The element.
-- @param returnAsNumber [optional default=false] (boolean) Return the scale as a number (scale.x) instead of a Vector3.
-- @return (Vector3 or number) The scale.
function Daneel.GUI.Common.GetScale(element, returnAsNumber)
    Daneel.Debug.StackTrace.BeginFunction("Daneel.GUI.Common.GetScale", element, returnAsNumber)
    local errorHead = "Daneel.GUI.Common.GetScale(element[, returnAsNumber]) : "
    Daneel.Debug.CheckArgType(element, "element", Daneel.config.guiTypes, errorHead)
    Daneel.Debug.CheckOptionalArgType(returnAsNumber, "returnAsNumber", "boolean", errorHead)

    local scale = element.gameObject.transform.localScale
    if returnAsNumber == true then
        scale = scale.x
    end
    Daneel.Debug.StackTrace.EndFunction()
    return scale
end


--- Set the element's opacity which is actually the mapRenderer's opacity.
-- @param element (Daneel.GUI.Text) The element.
-- @param opacity (number) The opacity (between 0.0 and 1.0).
function Daneel.GUI.Common.SetOpacity(element, opacity)
    Daneel.Debug.StackTrace.BeginFunction("Daneel.GUI.Common.SetOpacity", element)
    local errorHead = "Daneel.GUI.Common.SetOpacity(element, opacity) : "
    Daneel.Debug.CheckArgType(element, "element", Daneel.config.guiTypes, errorHead)
    Daneel.Debug.CheckArgType(opacity, "opacity", "number", errorHead)

    if element.gameObject.modelRenderer ~= nil then
        element.gameObject.modelRenderer.opacity = math.clamp(opacity, 0.0, 1.0)
    end
    if element.gameObject.mapRenderer ~= nil then
        element.gameObject.mapRenderer.opacity = math.clamp(opacity, 0.0, 1.0)
    end
    Daneel.Debug.StackTrace.EndFunction()
end

--- Get the elements's opacity which is actually the component's opacity.
-- @param element (Daneel.GUI.Text) The element.
-- @return (number) The opacity (between 0.0 and 1.0).
function Daneel.GUI.Common.GetOpacity(element)
    Daneel.Debug.StackTrace.BeginFunction("Daneel.GUI.Common.GetOpacity", element)
    local errorHead = "Daneel.GUI.Common.GetOpacity(element) : "
    Daneel.Debug.CheckArgType(element, "element", Daneel.config.guiTypes, errorHead)

    local opacity = nil
    if element.gameObject.modelRenderer ~= nil then
        opacity = element.gameObject.modelRenderer.opacity
    end
    if element.gameObject.mapRenderer ~= nil then
        opacity = element.gameObject.mapRenderer.opacity
    end
    Daneel.Debug.StackTrace.EndFunction()
    return opacity
end


--- Set the label of the provided element.
-- @param element (Daneel.GUI.Text) The element.
-- @param label (mixed) Something to display.
function Daneel.GUI.Common.SetLabel(element, label, replacements)
    Daneel.Debug.StackTrace.BeginFunction("Daneel.GUI.Common.SetLabel", element, label, replacements)
    local errorHead = "Daneel.GUI.Common.SetLabel(element, label[, replacements]) : "
     Daneel.Debug.CheckArgType(element, "element", Daneel.config.guiTypes, errorHead)
    
    label = tostring(label)
    if replacements ~= nil then
        Daneel.Debug.CheckArgType(replacements, "replacements", "table", errorHead)
        label = Daneel.Utilities.ReplaceInString(label, replacements)
    end
    element._label = label

    local map = element.gameObject.mapRenderer.map
    local caracterPosition = 0
    local linePosition = 0
    local skipCharacter = 0
    
    for i = 1, label:len() do
        if skipCharacter > 0 then
            skipCharacter = skipCharacter - 1
        else
            if label:sub(i, i+3) == ":br:" then
                linePosition = linePosition - 1
                caracterPosition = 0
                skipCharacter = 4
            else
                local byte = label:byte(i)
                if byte > 255 then byte = string.byte("?", 1) end -- should be 64
                map:SetBlockAt(caracterPosition, linePosition, 0, byte, Map.BlockOrientation.North)

                caracterPosition = caracterPosition + 1
            end
        end
    end

    Daneel.Debug.StackTrace.EndFunction()
end

--- Get the label of the provided element.
-- @param element (Daneel.GUI.Text) The element.
-- @return (string) The label.
function Daneel.GUI.Common.GetLabel(element)
    Daneel.Debug.StackTrace.BeginFunction("Daneel.GUI.Common.GetLabel", element)
    local errorHead = "Daneel.GUI.Common.GetLabel(element) : "
    Daneel.Debug.CheckArgType(element, "element", Daneel.config.guiElementsTypes, errorHead)
    return element._label
end


--- Set the position of the provided element on the screen.
-- 0, 0 is the top left of the screen.
-- @param element (Daneel.GUI.Text) The element.
-- @param x (Vector2 or number) The x component of the position, the distance in pixel from the left side of the screen or the position as a Vector2.
-- @param y [optional] (number) The y component of the position, the distance in pixel from the top side of the screen.
function Daneel.GUI.Common.SetPosition(element, x, y)
    Daneel.Debug.StackTrace.BeginFunction("Daneel.GUI.Common.SetPosition", element, x, y)
    local errorHead = "Daneel.GUI.Common.SetPosition(element, x[, y]) : "
    Daneel.Debug.CheckArgType(element, "element", Daneel.config.guiTypes, errorHead)
    Daneel.Debug.CheckArgType(x, "x", {"number", "Vector2"}, errorHead)
    Daneel.Debug.CheckOptionalArgType(y, "y", "number", errorHead)

    if type(x) ~= "number" and type(y) == "nil" then
        element._position = x
    elseif type(x) == "number" and type(y) == "number" then
        element._position = Vector2.New(x, y)
    end
            
    local screenSize = CraftStudio.Screen.GetSize() -- screenSize is in pixels
    local orthographicScale = Daneel.config.hudCameraOrthographicScale -- orthographicScale is in 3D world units 
    
    -- get the smaller side of the screen (usually screenSize.y, the height)
    local smallSideSize = screenSize.y
    if screenSize.x < screenSize.y then
        smallSideSize = screenSize.x
    end

    -- The orthographic scale value (in units) is equivalent to the smallest side size of the screen (in pixel)
    -- pixelUnit (in pixels/units) is the correspondance between screen pixels and 3D world units
    local pixelUnit = orthographicScale / smallSideSize
    
    local xFunc = function(pixels)
        local position = pixels * pixelUnit 
        -- position is now in units (3D world units)
        -- but the GUI elements are parented to the HUDCamera, which IS the middle of the screen (without taking split screen into account)
        -- and the origin of the GUI elements position is the top left corner of the screen
        
        -- so the position must be altered to reflect the new point of origin
        -- since the current origin is the middle of the screen and the new origin is the top left corner
        -- the delta is of a half of a screen

        -- for the small side, which size is orthographic scale, half of it is 'orthographicScale / 2'
        -- but the size in units of a side is actually the orthographic scale multiplied by
        -- the ratio of its size in pixel on the smallest side size
        -- On a 1000x500 pixels screens with an orthographic scale of 10 :
        -- 10u <=> 500px    so 1000px <=> 10 * (1000/500) = 20u
        local sideSize = orthographicScale * screenSize.x / smallSideSize
        position = position - sideSize / 2 
        return position
    end
    
    local yFunc = function(pixels)
        return -(pixels * pixelUnit - orthographicScale * screenSize.y / smallSideSize / 2) 
        -- the signs are different here since the progression along the y axis in pixel (to the positiv toward the bottom)
        -- is opposite of it's progression in the 3D worl (to the positiv value toward the top of the scene)
    end

    local position3D = Vector3:New(xFunc(element._position.x), yFunc(element._position.y), -5)
    
    element.gameObject.transform.localPosition = position3D
    Daneel.Debug.StackTrace.EndFunction()
end

--- Get the position of the provided element on the screen.
-- @param element (Daneel.GUI.Text) The element.
-- @return (Vector2) The position.
function Daneel.GUI.Common.GetPosition(element)
     Daneel.Debug.StackTrace.BeginFunction("Daneel.GUI.Common.GetPosition", element)
    local errorHead = "Daneel.GUI.Common.GetPosition(element) : "
    Daneel.Debug.CheckArgType(element, "element", Daneel.config.guiElementsTypes, errorHead)
    local position = element._position
    if position == nil then
        -- the element's position has not been set
        -- so it is actually at the center of the screen
        local screenSize = CraftStudio.Screen.GetSize()
        element._position = Vector2.New(screenSize.x/2, screenSize.y/2)
    end
    return element._position
end

----------------------------------------------------------------------------------
-- Text

Daneel.GUI.Text = {}
setmetatable(Daneel.GUI.Text, Daneel.GUI.Common)

function Daneel.GUI.Text.__index(element, key)
    local funcName = "Get"..key:ucfirst()

    if Daneel.GUI.Text[funcName] ~= nil then
        return Daneel.GUI.Text[funcName](element)
    elseif Daneel.GUI.Text[key] ~= nil then
        return Daneel.GUI.Text[key]
    end

    if Daneel.GUI.Common[funcName] ~= nil then
        return Daneel.GUI.Common[funcName](element)
    elseif Daneel.GUI.Common[key] ~= nil then
        return Daneel.GUI.Common[key]
    end

    return nil
end

function Daneel.GUI.Text.__newindex(element, key, value)
    local funcName = "Set"..key:ucfirst()

    if Daneel.GUI.Text[funcName] ~= nil then
        return Daneel.GUI.Text[funcName](element, value)
    end

    return rawset(element, key, value)
end

function Daneel.GUI.Text.__tostring(element)
    return "Daneel.GUI."..element.type..": '"..element.name.."'"
end


-- Create a new GUI.Text.
-- @param name (string) The element name
-- @param params [optional] (table) A table with initialisation parameters.
-- @return (Daneel.GUI.Text) The new element.
function Daneel.GUI.Text.New(name, params)
    Daneel.Debug.StackTrace.BeginFunction("Daneel.GUI.Text.New", name, params)
    local errorHead = "Daneel.GUI.Text.New(name[, params]) : "
    Daneel.Debug.CheckArgType(name, "name", "string", errorHead)
    Daneel.Debug.CheckOptionalArgType(params, "params", "table", errorHead)

    local element = {
        type = "Text",
        name = name,
        gameObject = GameObject.New(name, {
            parent = Daneel.config.hudCamera,
            mapRenderer = {
                map = Map.LoadFromPackage(Daneel.config.textMapPath)
            },
        }),
    }

    setmetatable(element, Daneel.GUI.Text)
    element.position = Vector2.New(100)
    element.label = name
    element.scale = Daneel.config.hudElementDefaultScale
    
    if params ~= nil then
        for key, value in pairs(params) do
            element[key] = value
        end
    end

    Daneel.GUI.elements[name] = element
    
    Daneel.Debug.StackTrace.EndFunction()
    return element
end


----------------------------------------------------------------------------------
-- Vector 2

Vector2 = {}
Vector2.__index = Vector2

function Vector2.New(x, y)
    local errorHead = "Vector2.New(x, y) : "
    Daneel.Debug.CheckArgType(x, "x", "number", errorHead)
    Daneel.Debug.CheckOptionalArgType(y, "y", "number", errorHead)
    if y == nil then
        y = x
    end
    return setmetatable({x = x, y = y}, Vector2)
end

function Vector2.__tostring(vector2)
    return "Vector2: { x="..vector2.x..", y="..vector2.y.." }"
end
