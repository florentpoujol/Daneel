
if Daneel == nil then
    Daneel = {}
end


----------------------------------------------------------------------------------
-- GUI

Daneel.GUI = { elements = {}, colors = {} }

--- Get the GUI element of the provoded name.
-- @param name (string) The name.
-- @return (Daneel.GUI.Text) The element or nil if none is found
function Daneel.GUI.Get(name)
    Daneel.Debug.StackTrace.BeginFunction("Daneel.GUI.Get", name)
    Daneel.Debug.CheckArgType(name, "name", "string", "Daneel.GUI.Get(name) : ")
    Daneel.Debug.StackTrace.EndFunction()
    return Daneel.GUI.elements[name]
end


----------------------------------------------------------------------------------
-- Common

Daneel.GUI.Common = {} -- common functions for GUI Elements
Daneel.GUI.Common.__index = Daneel.GUI.Common


function Daneel.GUI.Common.__index(element, key)
    local funcName = "Get"..key:ucfirst()

    if Daneel.GUI.Common[funcName] ~= nil then
        return Daneel.GUI.Common[funcName](element)
    elseif Daneel.GUI.Common[key] ~= nil then
        return Daneel.GUI.Common[key]
    end

    return nil
end

function Daneel.GUI.Common.__newindex(element, key, value)
    local funcName = "Set"..key:ucfirst()
    if Daneel.GUI.Common[funcName] ~= nil then
        return Daneel.GUI.Common[funcName](element, value)
    end
    return rawset(element, key, value)
end


-- Basic contructor for GUI elements.
-- @param name (string) The element name.
-- @return (Daneel.GUI.Common) The basics of the element, to be completed by the other GUI.[element].New() function.
function Daneel.GUI.Common.New(name, params)
    Daneel.Debug.StackTrace.BeginFunction("Daneel.GUI.Common.New", name, params)
    local errorHead = "Daneel.GUI.Common.New(name[, params]) : "
    Daneel.Debug.CheckArgType(name, "name", "string", errorHead)
    Daneel.Debug.CheckOptionalArgType(params, "params", "table", errorHead)

    local element = {
        _name = name,
        gameObject = GameObject.New(name, {
            parent = Daneel.Config.Get("gui.hudCamera"),
        }),
    }

    setmetatable(element, Daneel.GUI.Common)
    element.name = name
    element.position = Vector2.New(100)
    element.layer = 5
    
    if params ~= nil then
        if type(params.scriptedBehaviors) == "table" then
            element.gameObject:Set({scriptedBehaviors = params.scriptedBehaviors})
            params.scriptedBehaviors = nil
        end
    end

    Daneel.Debug.StackTrace.EndFunction()
    return element
end


--- Set the element's name.
-- @param element (Daneel.GUI.Text, Daneel.GUI.Checkbox) The element.
-- @param name (string) The local name.
function Daneel.GUI.Common.SetName(element, name)
    Daneel.Debug.StackTrace.BeginFunction("Daneel.GUI.Common.SetName", element)
    local errorHead = "Daneel.GUI.Common.SetName(element, name) : "
    Daneel.Debug.CheckArgType(element, "element", config.default.guiTypes, errorHead)
    Daneel.Debug.CheckArgType(name, "name", "string", errorHead)
    if element._name ~= nil then
        Daneel.GUI.elements[element._name] = nil
    end
    element._name = name
    Daneel.GUI.elements[name] = element
    Daneel.Debug.StackTrace.EndFunction()
end

--- Get the element's name.
-- @param element (Daneel.GUI.Text, Daneel.GUI.Checkbox) The element.
-- @return (string) The name.
function Daneel.GUI.Common.GetName(element)
    Daneel.Debug.StackTrace.BeginFunction("Daneel.GUI.Common.GetName", element, returnAsNumber)
    local errorHead = "Daneel.GUI.Common.GetName(element) : "
    Daneel.Debug.CheckArgType(element, "element", config.default.guiTypes, errorHead)
    Daneel.Debug.StackTrace.EndFunction()
    return element._name
end


--- Set the element's scale which is actually the gameObject's local scale.
-- @param element (Daneel.GUI.Text, Daneel.GUI.Checkbox) The element.
-- @param scale (number or Vector3) The local scale.
function Daneel.GUI.Common.SetScale(element, scale)
    Daneel.Debug.StackTrace.BeginFunction("Daneel.GUI.Common.SetScale", element)
    local errorHead = "Daneel.GUI.Common.SetScale(element, scale) : "
    Daneel.Debug.CheckArgType(element, "element", config.default.guiTypes, errorHead)
    Daneel.Debug.CheckArgType(scale, "scale", {"number", "Vector3"}, errorHead)

    if type(scale) == "number" then
        scale = Vector3:New(scale)
    end
    element.gameObject.transform.localScale = scale
    Daneel.Debug.StackTrace.EndFunction()
end

--- Get the element's scale.
-- @param element (Daneel.GUI.Text, Daneel.GUI.Checkbox) The element.
-- @param returnAsNumber [optional default=false] (boolean) Return the scale as a number (scale.x) instead of a Vector3.
-- @return (Vector3 or number) The scale.
function Daneel.GUI.Common.GetScale(element, returnAsNumber)
    Daneel.Debug.StackTrace.BeginFunction("Daneel.GUI.Common.GetScale", element, returnAsNumber)
    local errorHead = "Daneel.GUI.Common.GetScale(element[, returnAsNumber]) : "
    Daneel.Debug.CheckArgType(element, "element", config.default.guiTypes, errorHead)
    Daneel.Debug.CheckOptionalArgType(returnAsNumber, "returnAsNumber", "boolean", errorHead)

    local scale = element.gameObject.transform.localScale
    if returnAsNumber == true then
        scale = scale.x
    end
    Daneel.Debug.StackTrace.EndFunction()
    return scale
end


--- Set the element's opacity which is actually the mapRenderer's opacity.
-- @param element (Daneel.GUI.Text, Daneel.GUI.Checkbox) The element.
-- @param opacity (number) The opacity (between 0.0 and 1.0).
function Daneel.GUI.Common.SetOpacity(element, opacity)
    Daneel.Debug.StackTrace.BeginFunction("Daneel.GUI.Common.SetOpacity", element)
    local errorHead = "Daneel.GUI.Common.SetOpacity(element, opacity) : "
    Daneel.Debug.CheckArgType(element, "element", config.default.guiTypes, errorHead)
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
-- @param element (Daneel.GUI.Text, Daneel.GUI.Checkbox) The element.
-- @return (number) The opacity (between 0.0 and 1.0).
function Daneel.GUI.Common.GetOpacity(element)
    Daneel.Debug.StackTrace.BeginFunction("Daneel.GUI.Common.GetOpacity", element)
    local errorHead = "Daneel.GUI.Common.GetOpacity(element) : "
    Daneel.Debug.CheckArgType(element, "element", config.default.guiTypes, errorHead)

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
-- @param element (Daneel.GUI.Text, Daneel.GUI.Checkbox) The element.
-- @param label (mixed) Something to display.
function Daneel.GUI.Common.SetLabel(element, label)
    Daneel.Debug.StackTrace.BeginFunction("Daneel.GUI.Common.SetLabel", element, label, replacements)
    local errorHead = "Daneel.GUI.Common.SetLabel(element, label[, replacements]) : "
    Daneel.Debug.CheckArgType(element, "element", {"Daneel.GUI.Text", "Daneel.GUI.Checkbox", "Daneel.GUI.Input"}, errorHead)
    
    label = tostring(label)
    element._label = label

    local map = Map.LoadFromPackage(Daneel.Config.Get("gui.emptyTextMapPath"))
    if element.gameObject.mapRenderer == nil then
        element.gameObject:AddMapRenderer()
    end
    element.gameObject.mapRenderer.map = map -- empty the current map
    element:SetColor()

    local characterPosition = 0
    local linePosition = 0
    local skipCharacter = 0

    local elementType = Daneel.Debug.GetType(element)
    if elementType == "Daneel.GUI.Checkbox" then
        label = " "..label
        characterPosition = 1
        if element._checked ~= nil then
            element:SetChecked(element._checked, true) -- reset the first map block with the checked mark (without firing the event)
        end
    elseif elementType == "Daneel.GUI.Input" then
        label = "["..label.."]"
    end
    
    for i = 1, label:len() do
        if skipCharacter > 0 then
            skipCharacter = skipCharacter - 1
        else
            if label:sub(i, i+3) == ":br:" then
                linePosition = linePosition - 1
                characterPosition = 0
                skipCharacter = 4
            else
                if characterPosition == element.wordWrap then
                    linePosition = linePosition - 1
                    characterPosition = 0
                end

                local byte = label:byte(i)
                if byte > 255 then byte = string.byte("?", 1) end -- should be 64
                map:SetBlockAt(characterPosition, linePosition, 0, byte, Map.BlockOrientation.North)

                characterPosition = characterPosition + 1
            end
        end
    end

    if elementType ~= "Daneel.GUI.Checkbox" then
        element.gameObject:SendMessage("OnChange", {element = element})
        if type(element.onChange) == "function" then
            element:onChange()
        end
    end

    Daneel.Debug.StackTrace.EndFunction()
end

--- Get the label of the provided element.
-- @param element (Daneel.GUI.Text, Daneel.GUI.Checkbox) The element.
-- @return (string) The label.
function Daneel.GUI.Common.GetLabel(element)
    Daneel.Debug.StackTrace.BeginFunction("Daneel.GUI.Common.GetLabel", element)
    local errorHead = "Daneel.GUI.Common.GetLabel(element) : "
    Daneel.Debug.CheckArgType(element, "element", {"Daneel.GUI.Text", "Daneel.GUI.Checkbox", "Daneel.GUI.Input"}, errorHead)
    Daneel.Debug.StackTrace.EndFunction()
    return element._label
end


--- Set the position of the provided element on the screen.
-- 0, 0 is the top left of the screen.
-- @param element (Daneel.GUI.Text, Daneel.GUI.Checkbox) The element.
-- @param x (Vector2 or number) The x component of the position, the distance in pixel from the left side of the screen or the position as a Vector2.
-- @param y [optional] (number) The y component of the position, the distance in pixel from the top side of the screen.
function Daneel.GUI.Common.SetPosition(element, x, y)
    Daneel.Debug.StackTrace.BeginFunction("Daneel.GUI.Common.SetPosition", element, x, y)
    local errorHead = "Daneel.GUI.Common.SetPosition(element, x[, y]) : "
    Daneel.Debug.CheckArgType(element, "element", config.default.guiTypes, errorHead)
    Daneel.Debug.CheckArgType(x, "x", {"number", "Vector2"}, errorHead)
    Daneel.Debug.CheckOptionalArgType(y, "y", "number", errorHead)

    if type(x) ~= "number" and type(y) == "nil" then
        element._position = x
    elseif type(x) == "number" and type(y) == "number" then
        element._position = Vector2.New(x, y)
    end
            
    local screenSize = CraftStudio.Screen.GetSize() -- screenSize is in pixels
    local orthographicScale = Daneel.Config.Get("gui.hudCameraOrthographicScale") -- orthographicScale is in 3D world units 
    
    -- get the smaller side of the screen (usually screenSize.y, the height)
    local smallSideSize = screenSize.y
    if screenSize.x < screenSize.y then
        smallSideSize = screenSize.x
    end
    
    local xFunc = function(pixels)
        local position = pixels * Daneel.GUI.pixelsToUnits 
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
        return -(pixels * Daneel.GUI.pixelsToUnits - orthographicScale * screenSize.y / smallSideSize / 2) 
        -- the signs are different here since the progression along the y axis in pixel (to the positiv toward the bottom)
        -- is opposite of it's progression in the 3D worl (to the positiv value toward the top of the scene)
    end

    local position3D = Vector3:New(xFunc(element._position.x), yFunc(element._position.y), -5)
    
    element.gameObject.transform.localPosition = position3D
    Daneel.Debug.StackTrace.EndFunction()
end

--- Get the position of the provided element on the screen.
-- @param element (Daneel.GUI.Text, Daneel.GUI.Checkbox) The element.
-- @return (Vector2) The position.
function Daneel.GUI.Common.GetPosition(element)
    Daneel.Debug.StackTrace.BeginFunction("Daneel.GUI.Common.GetPosition", element)
    local errorHead = "Daneel.GUI.Common.GetPosition(element) : "
    Daneel.Debug.CheckArgType(element, "element", config.default.guiTypes, errorHead)
    local position = element._position
    if position == nil then
        -- the element's position has not been set
        -- so it is actually at the center of the screen
        local screenSize = CraftStudio.Screen.GetSize()
        element._position = Vector2.New(screenSize.x/2, screenSize.y/2)
    end
    Daneel.Debug.StackTrace.EndFunction()
    return element._position
end


--- Set the element's color which is actually the tile set used to render the label.
-- @param element (Daneel.GUI.Text, Daneel.GUI.Checkbox, Daneel.GUI.Input) The element.
-- @param color (TileSet) An entry in Daneel.GUI.colors.
function Daneel.GUI.Common.SetColor(element, color)
    Daneel.Debug.StackTrace.BeginFunction("Daneel.GUI.Common.SetColor", element)
    local errorHead = "Daneel.GUI.Common.SetColor(element, color) : "
    Daneel.Debug.CheckArgType(element, "element", config.default.guiTypes, errorHead)
    Daneel.Debug.CheckOptionalArgType(color, "color", "TileSet", errorHead)

    if color ~= nil then
        element.gameObject.mapRenderer.tileSet = color
        element._color = color
    -- put the color the text had (before the label was updated)
    elseif element._color ~= nil then
        element.gameObject.mapRenderer.tileSet = element._color
        element._color = element._color
    -- if coor arg is not set, put the default color
    elseif Daneel.Config.Get("gui.textDefaultColorName") ~= nil then
        local color = Daneel.GUI.colors[Daneel.Config.Get("gui.textDefaultColorName")]
        element.gameObject.mapRenderer.tileSet = color
        element._color = color
    end

    Daneel.Debug.StackTrace.EndFunction()
end


--- Set the elements's layer which is actually its local position's z component.
-- @param element (Daneel.GUI.Text, Daneel.GUI.Checkbox) The element.
-- @param layer (number) The layer (a postiv number).
function Daneel.GUI.Common.SetLayer(element, layer)
    Daneel.Debug.StackTrace.BeginFunction("Daneel.GUI.Common.SetLayer", element)
    local errorHead = "Daneel.GUI.Common.SetLayer(element, layer) : "
    Daneel.Debug.CheckArgType(element, "element", config.default.guiTypes, errorHead)
    Daneel.Debug.CheckArgType(layer, "layer", "number", errorHead)
    local pos = element.gameObject.transform.localPosition
    element.gameObject.transform.localPosition = Vector3:New(pos.x, pos.y, -layer)
    Daneel.Debug.StackTrace.EndFunction()
end

--- Get the elements's layer which is actually its local position's z component.
-- @param element (Daneel.GUI.Text, Daneel.GUI.Checkbox) The element.
-- @return (number) The layer.
function Daneel.GUI.Common.GetLayer(element)
    Daneel.Debug.StackTrace.BeginFunction("Daneel.GUI.Common.GetLayer", element)
    local errorHead = "Daneel.GUI.Common.GetLyer(element) : "
    Daneel.Debug.CheckArgType(element, "element", config.default.guiTypes, errorHead)
    return math.abs(element.gameObject.transform.localPosition.z)
end


--- Destroy the provided element.
-- @param element (Daneel.GUI.Text, Daneel.GUI.Checkbox) The element.
function Daneel.GUI.Common.Destroy(element)
    Daneel.Debug.StackTrace.BeginFunction("Daneel.GUI.Destroy", element)
    local errorHead = "Daneel.GUI.Destroy(element) : "
    Daneel.Debug.CheckArgType(element, "element", config.default.guiTypes, errorHead)
    element.gameObject:Destroy()
    Daneel.Debug.StackTrace.EndFunction()
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
    return "Daneel.GUI.Text: '"..element._name.."'"
end


--- Create a new Daneel.GUI.Text.
-- @param name (string) The element name.
-- @param params [optional] (table) A table with initialisation parameters.
-- @return (Daneel.GUI.Text) The new element.
function Daneel.GUI.Text.New(name, params)
    Daneel.Debug.StackTrace.BeginFunction("Daneel.GUI.Text.New", name, params)
    local errorHead = "Daneel.GUI.Text.New(name[, params]) : "
    Daneel.Debug.CheckArgType(name, "name", "string", errorHead)
    Daneel.Debug.CheckOptionalArgType(params, "params", "table", errorHead)

    local element = Daneel.GUI.Common.New(name, params)
    setmetatable(element, Daneel.GUI.Text)
    element.label = name
    element:SetColor()
    element.scale = Daneel.Config.Get("gui.hudLabelDefaultScale")

    if params ~= nil then
        if params.isInteractive == true then
            element.gameObject:AddScriptedBehavior("Daneel/Behaviors/GUI/Interactive", {element = element})
            params.isInteractive = nil
        end

        for key, value in pairs(params) do
            element[key] = value
        end
    end

    Daneel.Debug.StackTrace.EndFunction()
    return element
end


----------------------------------------------------------------------------------
-- Image

Daneel.GUI.Image = {}
setmetatable(Daneel.GUI.Image, Daneel.GUI.Common)


function Daneel.GUI.Image.__index(element, key)
    local funcName = "Get"..key:ucfirst()

    if Daneel.GUI.Image[funcName] ~= nil then
        return Daneel.GUI.Image[funcName](element)
    elseif Daneel.GUI.Image[key] ~= nil then
        return Daneel.GUI.Image[key]
    end

    if Daneel.GUI.Common[funcName] ~= nil then
        return Daneel.GUI.Common[funcName](element)
    elseif Daneel.GUI.Common[key] ~= nil then
        return Daneel.GUI.Common[key]
    end

    return nil
end

function Daneel.GUI.Image.__newindex(element, key, value)
    local funcName = "Set"..key:ucfirst()
    if Daneel.GUI.Image[funcName] ~= nil then
        return Daneel.GUI.Image[funcName](element, value)
    end
    return rawset(element, key, value)
end

function Daneel.GUI.Image.__tostring(element)
    return "Daneel.GUI.Image: '"..element._name.."'"
end


-- Create a new GUI.Image.
-- @param name (string) The element name.
-- @param params [optional] (table) A table with initialisation parameters.
-- @return (Daneel.GUI.Image) The new element.
function Daneel.GUI.Image.New(name, params)
    Daneel.Debug.StackTrace.BeginFunction("Daneel.GUI.Image.New", name, params)
    local errorHead = "Daneel.GUI.Image.New(name[, params]) : "
    Daneel.Debug.CheckArgType(name, "name", "string", errorHead)
    Daneel.Debug.CheckOptionalArgType(params, "params", "table", errorHead)

    local element = Daneel.GUI.Common.New(name, params)
    setmetatable(element, Daneel.GUI.Image)
    
    if params ~= nil then
        if params.isInteractive == true then
            element.gameObject:AddScriptedBehavior("Daneel/Behaviors/GUI/Interactive", {element = element})
            params.isInteractive = nil
        end

        for key, value in pairs(params) do
            element[key] = value
        end
    end

    Daneel.Debug.StackTrace.EndFunction()
    return element
end


--- Set the image renderer.
-- @param element (Daneel.GUI.Image) The element.
-- @param image (string, Model or Map) The image path or asset.
function Daneel.GUI.Image.SetImage(element, image)
    Daneel.Debug.StackTrace.BeginFunction("Daneel.GUI.Common.Image.SetImage", element, image)
    local errorHead = "Daneel.GUI.Common.Image.SetImage(element, image) : "
    Daneel.Debug.CheckArgType(element, "element", config.default.guiTypes, errorHead)
    Daneel.Debug.CheckOptionalArgType(image, "image", {"string", "Model", "Map"}, errorHead)

    local assetType = Daneel.Debug.GetType(image)
    local asset = image
    if assetType == "string" then
        assetType = "Model"
        asset = Asset.Get(image, assetType)

        if asset == nil then
            assetType = "Map"
            asset = Asset.Get(image, assetType)
            if asset == nil then
                error(errorHead.."Argument 'image' : asset with path '"..image.."' is not a Model nor a Map.")
            end
        end
    end
    local assettype = assetType:lower()

    element._image = image

    -- delete the other, old component if it exists
    if assetType == "Model" and element.gameObject.mapRenderer ~= nil then
        element.gameObject.mapRenderer:Destroy()
    elseif assetType == "Map" and element.gameObject.modelRenderer ~= nil then
        element.gameObject.modelRenderer:Destroy()
    end

    -- create the new component if needed then set the new image asset
    element.gameObject:Set({
        [assettype.."Renderer"] = {
            [assettype] = asset
        }
    })


    element.gameObject:SendMessage("OnChange", {element = element})
    if type(element.onChange) == "function" then
        element:onChange()
    end

    Daneel.Debug.StackTrace.EndFunction()
end



----------------------------------------------------------------------------------
-- Checkbox

Daneel.GUI.Checkbox = {}
setmetatable(Daneel.GUI.Checkbox, Daneel.GUI.Common)


function Daneel.GUI.Checkbox.__index(element, key)
    local funcName = "Get"..key:ucfirst()

    if Daneel.GUI.Checkbox[funcName] ~= nil then
        return Daneel.GUI.Checkbox[funcName](element)
    elseif Daneel.GUI.Checkbox[key] ~= nil then
        return Daneel.GUI.Checkbox[key]
    end

    if Daneel.GUI.Common[funcName] ~= nil then
        return Daneel.GUI.Common[funcName](element)
    elseif Daneel.GUI.Common[key] ~= nil then
        return Daneel.GUI.Common[key]
    end

    return nil
end

function Daneel.GUI.Checkbox.__newindex(element, key, value)
    local funcName = "Set"..key:ucfirst()

    if Daneel.GUI.Checkbox[funcName] ~= nil then
        return Daneel.GUI.Checkbox[funcName](element, value)
    end

    return rawset(element, key, value)
end

function Daneel.GUI.Checkbox.__tostring(element)
    return "Daneel.GUI.Checkbox: '"..element._name.."'"
end


-- Create a new GUI.Checkbox.
-- @param name (string) The element name.
-- @param params [optional] (table) A table with initialisation parameters.
-- @return (Daneel.GUI.Checkbox) The new element.
function Daneel.GUI.Checkbox.New(name, params)
    Daneel.Debug.StackTrace.BeginFunction("Daneel.GUI.Checkbox.New", name, params)
    local errorHead = "Daneel.GUI.Checkbox.New(name[, params]) : "
    Daneel.Debug.CheckArgType(name, "name", "string", errorHead)
    Daneel.Debug.CheckOptionalArgType(params, "params", "table", errorHead)

    local element = Daneel.GUI.Common.New(name, params)
    setmetatable(element, Daneel.GUI.Checkbox)
    element.gameObject:AddScriptedBehavior("Daneel/Behaviors/GUI/Interactive", {element = element})
    element.gameObject:AddScriptedBehavior("Daneel/Behaviors/GUI/Checkbox", {element = element})
    element.label = name
    element.checked = false
    element.scale = Daneel.Config.Get("gui.hudLabelDefaultScale")

    if params ~= nil then
        for key, value in pairs(params) do
            element[key] = value
        end
    end

    Daneel.Debug.StackTrace.EndFunction()
    return element
end

--- Switch the checked state of the checkbox.
-- @param element (Daneel.GUI.Checkbox) The element.
function Daneel.GUI.Checkbox.SwitchState(element)
    Daneel.Debug.StackTrace.BeginFunction("Daneel.GUI.Checkbox.SwitchState", element)
    local errorHead = "Daneel.GUI.Checkbox.SwitchState(element) : "
    Daneel.Debug.CheckArgType(element, "element", "Daneel.GUI.Checkbox", errorHead)
    if element._checked == true then
        element.checked = false
    else
        element.checked = true
    end
    Daneel.Debug.StackTrace.EndFunction()
end

-- Set the checked state of the checkbox.
-- Update the _checked variable and the mapRenderer
-- @param element (Daneel.GUI.Checkbox) The element.
-- @param state (boolean) The state.
function Daneel.GUI.Checkbox.SetChecked(element, state)
    Daneel.Debug.StackTrace.BeginFunction("Daneel.GUI.Checkbox.SetChecked", element, state)
    local errorHead = "Daneel.GUI.Checkbox.SetChecked(element, state) : "
    Daneel.Debug.CheckArgType(element, "element", "Daneel.GUI.Checkbox", errorHead)
    Daneel.Debug.CheckArgType(state, "state", "boolean", errorHead)
    Daneel.Debug.CheckOptionalArgType(state, "state", "boolean", errorHead)
    if element._checked == nil or element._checked ~= state then
        element._checked = state
        local byte = 251 -- that's the valid mark
        if state == false then byte = string.byte("X") end
        element.gameObject.mapRenderer.map:SetBlockAt(0, 0, 0, byte, Map.BlockOrientation.North)
        
        element.gameObject:SendMessage("OnChange", {element = element})
        if type(element.onChange) == "function" then
            element:onChange()
        end
    end
    Daneel.Debug.StackTrace.EndFunction()
end

-- Get the checked state of the checkbox.
-- @param element (Daneel.GUI.Checkbox) The element.
-- @return (boolean) The state.
function Daneel.GUI.Checkbox.GetChecked(element)
    Daneel.Debug.StackTrace.BeginFunction("Daneel.GUI.Checkbox.GetChecked", element)
    local errorHead = "Daneel.GUI.Checkbox.GetChecked(element) : "
    Daneel.Debug.CheckArgType(element, "element", "Daneel.GUI.Checkbox", errorHead)
    Daneel.Debug.StackTrace.EndFunction()
    return element._checked    
end


----------------------------------------------------------------------------------
-- Input

Daneel.GUI.Input = {}
setmetatable(Daneel.GUI.Input, Daneel.GUI.Common)


function Daneel.GUI.Input.__index(element, key)
    local funcName = "Get"..key:ucfirst()

    if Daneel.GUI.Input[funcName] ~= nil then
        return Daneel.GUI.Input[funcName](element)
    elseif Daneel.GUI.Input[key] ~= nil then
        return Daneel.GUI.Input[key]
    end

    if Daneel.GUI.Common[funcName] ~= nil then
        return Daneel.GUI.Common[funcName](element)
    elseif Daneel.GUI.Common[key] ~= nil then
        return Daneel.GUI.Common[key]
    end

    return nil
end

function Daneel.GUI.Input.__newindex(element, key, value)
    local funcName = "Set"..key:ucfirst()
    if Daneel.GUI.Input[funcName] ~= nil then
        return Daneel.GUI.Input[funcName](element, value)
    end
    return rawset(element, key, value)
end

function Daneel.GUI.Input.__tostring(element)
    return "Daneel.GUI.Input: '"..element._name.."'"
end


-- Create a new GUI.Input.
-- @param name (string) The element name.
-- @param params [optional] (table) A table with initialisation parameters.
-- @return (Daneel.GUI.Input) The new element.
function Daneel.GUI.Input.New(name, params)
    Daneel.Debug.StackTrace.BeginFunction("Daneel.GUI.Input.New", name, params)
    local errorHead = "Daneel.GUI.Input.New(name[, params]) : "
    Daneel.Debug.CheckArgType(name, "name", "string", errorHead)
    Daneel.Debug.CheckOptionalArgType(params, "params", "table", errorHead)

    local element = Daneel.GUI.Common.New(name, params)
    setmetatable(element, Daneel.GUI.Input)
    element.gameObject:AddScriptedBehavior("Daneel/Behaviors/GUI/Interactive", {element = element})
    element.gameObject:AddScriptedBehavior("Daneel/Behaviors/GUI/Input", {element = element})
    element.label = name
    element.cursorMapRndr = element.gameObject:AddMapRenderer({opacity = 0.9})
    element._cursorPosition = 1
    element.focused = false
    element.scale = Daneel.Config.Get("gui.hudLabelDefaultScale")
    
    if params ~= nil then
        for key, value in pairs(params) do
            element[key] = value
        end
    end

    Daneel.Debug.StackTrace.EndFunction()
    return element
end


-- Update the label by inserting the provided value to the cursor position.
-- @param element (Daneel.GUI.Input) The element.
-- @param value (string) The value. If value = Delete > remove the character.
function Daneel.GUI.Input.UpdateLabel(element, value)
    Daneel.Debug.StackTrace.BeginFunction("Daneel.GUI.Input.UpdateLabel", element, state)
    local errorHead = "Daneel.GUI.Input.UpdateLabel(element, state) : "
    Daneel.Debug.CheckArgType(element, "element", "Daneel.GUI.Input", errorHead)
    Daneel.Debug.CheckArgType(value, "value", "string", errorHead)

    local cursorPosition = element._cursorPosition
    local label = element._label:totable()
    
    if value ~= "Delete" then
        local value = value:totable()
        for i, character in ipairs(value) do
            table.insert(label, cursorPosition, character)
            cursorPosition = cursorPosition + 1
        end

        element.cursorPosition = cursorPosition
    else
        if cursorPosition == #label+1 then -- the cursor is at the end of string
            cursorPosition = cursorPosition-1
            element.cursorPosition = cursorPosition
        end
        table.remove(label, cursorPosition)
    end

    local newLabel = ""
    for i, character in ipairs(label) do
        if element.maxLength ~= nil and i >= element.maxLength then
            break
        end
        newLabel = newLabel..character
    end
    element.label = newLabel

    Daneel.Debug.StackTrace.EndFunction()
end


-- Set the focused state of the checkbox.
-- Update the _focused variable and the cursor position. 
-- @param element (Daneel.GUI.Input) The element.
-- @param state (boolean) The state.
function Daneel.GUI.Input.SetFocused(element, state)
    Daneel.Debug.StackTrace.BeginFunction("Daneel.GUI.Input.SetFocused", element, state)
    local errorHead = "Daneel.GUI.Input.SetFocused(element, state) : "
    Daneel.Debug.CheckArgType(element, "element", "Daneel.GUI.Input", errorHead)
    Daneel.Debug.CheckArgType(state, "state", "boolean", errorHead)
    if element._focused ~= state then
        element._focused = state

        if state == true then
            element:SetCursorPosition()
        else
            element.cursorMapRndr.map = Map.LoadFromPackage(Daneel.Config.Get("gui.emptyTextMapPath")) -- hide the cursor on unfocus
        end

        element.gameObject:SendMessage("OnFocusChange", {element = element})
        if type(element.onFocusChange) == "function" then
            element:onFocusChange()
        end
    end
    Daneel.Debug.StackTrace.EndFunction()
end

-- Get the focused state of the checkbox.
-- @param element (Daneel.GUI.Input) The element.
-- @return (boolean) The state.
function Daneel.GUI.Input.GetFocused(element)
    Daneel.Debug.StackTrace.BeginFunction("Daneel.GUI.Input.GetFocused", element)
    local errorHead = "Daneel.GUI.Input.GetFocused(element) : "
    Daneel.Debug.CheckArgType(element, "element", "Daneel.GUI.Input", errorHead)
    Daneel.Debug.StackTrace.EndFunction()
    return element._focused    
end


-- Set the cursor position.
-- @param element (Daneel.GUI.Input) The element.
-- @param position [optional] (number) The cursor position (or relative position). If not set, will position the cursor to the end.
-- @param relative [optional default=false] (boolean) Tell wether the provided position is relative to the current cursor's position.
function Daneel.GUI.Input.SetCursorPosition(element, position, relative)
    Daneel.Debug.StackTrace.BeginFunction("Daneel.GUI.Input.SetCursorPosition", element, position, relative)
    local errorHead = "Daneel.GUI.Input.SetCursorPosition(element[, position, relative]) : "
    Daneel.Debug.CheckArgType(element, "element", "Daneel.GUI.Input", errorHead)
    Daneel.Debug.CheckOptionalArgType(position, "position", "number", errorHead)
    Daneel.Debug.CheckOptionalArgType(relative, "relative", "boolean", errorHead)

    local byte = string.byte("_")
    byte = 254 -- pipe verticale sur la gauche
    element.cursorMapRndr.map = Map.LoadFromPackage(Daneel.Config.Get("gui.emptyTextMapPath"))
    local map = element.cursorMapRndr.map

    if position == nil then
        position = #element._label+1
    elseif relative == true and element._cursorPosition ~= nil then
        position = element._cursorPosition + position
        position = math.clamp(position, 1, #element._label+1)
    end

   if element.maxLength ~= nil then
        position = math.clamp(position, 1, element.maxLength)
    end
    
    local offset = 1 -- offset by characters before the label
    -- position-1 because map block IDs begins at 0
    element.cursorMapRndr.map:SetBlockAt(position+offset-1, 0, 1, byte, Map.BlockOrientation.North)
    element._cursorPosition = position
    Daneel.Debug.StackTrace.EndFunction()    
end

-- Get the cursor position.
-- @param element (Daneel.GUI.Input) The element.
function Daneel.GUI.Input.GetCursorPosition(element)
    Daneel.Debug.StackTrace.BeginFunction("Daneel.GUI.Input.GetCursorPosition", element, position, relative)
    local errorHead = "Daneel.GUI.Input.GetCursorPosition(element[, position, relative]) : "
    Daneel.Debug.CheckArgType(element, "element", "Daneel.GUI.Input", errorHead)
    Daneel.Debug.StackTrace.EndFunction()    
    return element._cursorPosition
end


----------------------------------------------------------------------------------
-- ProgressBar

Daneel.GUI.ProgressBar = {}
setmetatable(Daneel.GUI.ProgressBar, Daneel.GUI.Common)


function Daneel.GUI.ProgressBar.__index(element, key)
    local funcName = "Get"..key:ucfirst()

    if Daneel.GUI.ProgressBar[funcName] ~= nil then
        return Daneel.GUI.ProgressBar[funcName](element)
    elseif Daneel.GUI.ProgressBar[key] ~= nil then
        return Daneel.GUI.ProgressBar[key]
    end

    if Daneel.GUI.Common[funcName] ~= nil then
        return Daneel.GUI.Common[funcName](element)
    elseif Daneel.GUI.Common[key] ~= nil then
        return Daneel.GUI.Common[key]
    end

    return nil
end

function Daneel.GUI.ProgressBar.__newindex(element, key, value)
    local funcName = "Set"..key:ucfirst()
    if Daneel.GUI.ProgressBar[funcName] ~= nil then
        return Daneel.GUI.ProgressBar[funcName](element, value)
    end
    return rawset(element, key, value)
end

function Daneel.GUI.ProgressBar.__tostring(element)
    return "Daneel.GUI.ProgressBar: '"..element._name.."'"
end


--- Create a new GUI.ProgressBar.
-- @param name (string) The element name.
-- @param params [optional] (table) A table with initialisation parameters.
-- @return (Daneel.GUI.ProgressBar) The new element.
function Daneel.GUI.ProgressBar.New(name, params)
    Daneel.Debug.StackTrace.BeginFunction("Daneel.GUI.ProgressBar.New", name, params)
    local errorHead = "Daneel.GUI.ProgressBar.New(name[, params]) : "
    Daneel.Debug.CheckArgType(name, "name", "string", errorHead)
    Daneel.Debug.CheckOptionalArgType(params, "params", "table", errorHead)

    local element = Daneel.GUI.Common.New(name, params)
    setmetatable(element, Daneel.GUI.ProgressBar)
    element.gameObject:AddModelRenderer()
    element.minValue = 0
    element.maxValue = 100
    element.minLength = 0
    element.maxLength = 100
    element.progress = 100

    if params ~= nil then
        if params.isInteractive == true then
            element.gameObject:AddScriptedBehavior("Daneel/Behaviors/GUI/Interactive", {element = element})
        end

        if params.isVertical == true then
            self.gameObject.transform.eulerAngles = self.gameObject.transform.eulerAngles + Vector3:New(0,0,-90)
        end

        for key, value in pairs(params) do
            if key ~= "progress" then
                element[key] = value
            end
        end

        if params.progress ~= nil then
            element.progress = params.progress
        end
    end

    Daneel.Debug.StackTrace.EndFunction()
    return element
end


--- Set the progress of the progress bar, adjusting its length.
-- @param element (Daneel.GUI.ProgressBar) The element.
-- @param pogress (number or string) The progress as a number (between minVal and maxVal) or as a string and a percentage (between "0%" and "100%").
function Daneel.GUI.ProgressBar.SetProgress(element, progress)
    Daneel.Debug.StackTrace.BeginFunction("Daneel.GUI.ProgressBar.SetProgress", element, progress)
    local errorHead = "Daneel.GUI.ProgressBar.SetProgress(element[, progress]) : "
    Daneel.Debug.CheckArgType(element, "element", "Daneel.GUI.ProgressBar", errorHead)
    Daneel.Debug.CheckArgType(progress, "progress", {"string", "number"}, errorHead)

    local minVal = element.minValue
    local maxVal = element.maxValue
    local percentageOfProgress = nil
    
    if type(progress) == "string" then
        percentageOfProgress = tonumber(progress:sub(1, #progress-1)) / 100

        local oldPercentage = percentageOfProgress
        percentageOfProgress = math.clamp(percentageOfProgress, 0.0, 1.0)
        if percentageOfProgress ~= oldPercentage then
            print("WARNING : progress in percentage with value '"..progress.."' is below 0% or above 100%.")
        end

        progress = (maxVal - minVal) * percentageOfProgress + minVal
    else
        local oldProgress = progress
        progress = math.clamp(progress, minVal, maxVal)
        if progress ~= oldProgress then
            print("WARNING : progress with value '"..oldProgress.."' is out of its boundaries : min='"..minVal.."', max='"..maxVal.."'")
        end

        percentageOfProgress = (progress - minVal) / (maxVal - minVal)
    end
    
    element._progress = progress
    
    local minLength = element.minLength * Daneel.GUI.pixelsToUnits
    local maxLength = element.maxLength * Daneel.GUI.pixelsToUnits --length in units of the bar
    local currentLength = (maxLength - minLength) * percentageOfProgress + minLength 
    
    local currentScale = element.gameObject.transform.localScale
    element.gameObject.transform.localScale = Vector3:New(currentLength, currentScale.y, currentScale.z)
    -- currentLength = scale only because the base size of the model is of one unit at a scale of one

    element.gameObject:SendMessage("OnChange", {element = element})
    if type(element.onChange) == "function" then
        element:onChange()
    end
end

--- Get the current progress of the progress bar.
-- @param element (Daneel.GUI.ProgressBar) The element.
-- @param getAsPercentage [optional default=false] (boolean) Get the progress as a percentage instead of an absolute value.
-- @return (number) The progress.
function Daneel.GUI.ProgressBar.GetProgress(element, getAsPercentage)
    Daneel.Debug.StackTrace.BeginFunction("Daneel.GUI.ProgressBar.GetProgress", element, getAsPercentage)
    local errorHead = "Daneel.GUI.ProgressBar.GetProgress(element[, getAsPercentage]) : "
    Daneel.Debug.CheckArgType(element, "element", "Daneel.GUI.ProgressBar", errorHead)
    Daneel.Debug.CheckOptionalArgType(getAsPercentage, "getAsPercentage", "boolean", errorHead)
    local progress = element._progress
    if getAsPercentage == true then
        progress = progress / element.maxValue * 100
    end
    Daneel.Debug.StackTrace.EndFunction()
    return progress
end

--- Set the height of the progress bar, in pixels.
-- @param element (Daneel.GUI.ProgressBar) The element.
-- @param height (number) The heigt in pixels.
function Daneel.GUI.ProgressBar.SetHeight(element, height)
    Daneel.Debug.StackTrace.BeginFunction("Daneel.GUI.ProgressBar.SetProgress", element, height)
    local errorHead = "Daneel.GUI.ProgressBar.SetProgress(element[, height]) : "
    Daneel.Debug.CheckArgType(element, "element", "Daneel.GUI.ProgressBar", errorHead)
    Daneel.Debug.CheckArgType(height, "height", "number", errorHead)
    element._height = height
    local unitHeight = height *  Daneel.GUI.pixelsToUnits 
    local currentScale = element.gameObject.transform.localScale
    element.gameObject.transform.localScale = Vector3:New(currentScale.x, unitHeight, currentScale.z)
end

--- Set the model of the progress bar.
-- @param element (Daneel.GUI.ProgressBar) The element.
-- @param model (string or Model) The model path or asset.
function Daneel.GUI.ProgressBar.SetBar(element, model)
    Daneel.Debug.StackTrace.BeginFunction("Daneel.GUI.ProgressBar.SetModel", element, model)
    local errorHead = "Daneel.GUI.ProgressBar.SetModel(element, model) : "
    Daneel.Debug.CheckArgType(element, "element", "Daneel.GUI.ProgressBar", errorHead)
    Daneel.Debug.CheckArgType(model, "model", {"string", "Model"}, errorHead)
    element.gameObject.modelRenderer.model = model
    Daneel.Debug.StackTrace.EndFunction()
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
