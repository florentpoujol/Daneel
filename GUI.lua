
if Daneel == nil then
    Daneel = {}
end


----------------------------------------------------------------------------------
-- GUI

Daneel.GUI = { 
    elements = {
        Text = {},    
    }   
}

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


----------------------------------------------------------------------------------
-- Text

Daneel.GUI.Text = {}
Daneel.GUI.Text.__index = Daneel.GUI.Text
setmetatable(Daneel.GUI.Text, Daneel.GUI.Common)

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
    element:SetLabel(name)
    
    if params ~= nil then
        for key, value in pairs(params) do
            local funcName = "Set"..key:ucfirst()
            if element[funcName] ~= nil then
                element[funcName](element, value)
            else
                element[key] = value
            end
        end
    end

    Daneel.GUI.elements["Text"][name] = element
    
    Daneel.Debug.StackTrace.EndFunction()
    return element
end