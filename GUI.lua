
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
    

--- Set the element's name.
-- @param element (Daneel.GUI.Text, Daneel.GUI.Checkbox) The element.
-- @param name (string) The local name.
function Daneel.GUI.Common.SetName(element, name)
    Daneel.Debug.StackTrace.BeginFunction("Daneel.GUI.Common.SetName", element)
    local errorHead = "Daneel.GUI.Common.SetName(element, name) : "
    Daneel.Debug.CheckArgType(element, "element", Daneel.config.guiTypes, errorHead)
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
    Daneel.Debug.CheckArgType(element, "element", Daneel.config.guiTypes, errorHead)
    Daneel.Debug.StackTrace.EndFunction()
    return element._name
end


--- Set the element's scale which is actually the gameObject's local scale.
-- @param element (Daneel.GUI.Text, Daneel.GUI.Checkbox) The element.
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
-- @param element (Daneel.GUI.Text, Daneel.GUI.Checkbox) The element.
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
-- @param element (Daneel.GUI.Text, Daneel.GUI.Checkbox) The element.
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
-- @param element (Daneel.GUI.Text, Daneel.GUI.Checkbox) The element.
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
-- @param element (Daneel.GUI.Text, Daneel.GUI.Checkbox) The element.
-- @param label (mixed) Something to display.
function Daneel.GUI.Common.SetLabel(element, label)
    Daneel.Debug.StackTrace.BeginFunction("Daneel.GUI.Common.SetLabel", element, label, replacements)
    local errorHead = "Daneel.GUI.Common.SetLabel(element, label[, replacements]) : "
    Daneel.Debug.CheckArgType(element, "element", Daneel.config.guiTypes, errorHead)
    
    label = tostring(label)
    element._label = label

    local map = Map.LoadFromPackage(Daneel.config.emptyTextMapPath)
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

    element.gameObject:SendMessage("OnLabelChange", {element = element})
    if type(element.onLabelChange) == "function" then
        element:onLabelChange()
    end

    Daneel.Debug.StackTrace.EndFunction()
end

--- Get the label of the provided element.
-- @param element (Daneel.GUI.Text, Daneel.GUI.Checkbox) The element.
-- @return (string) The label.
function Daneel.GUI.Common.GetLabel(element)
    Daneel.Debug.StackTrace.BeginFunction("Daneel.GUI.Common.GetLabel", element)
    local errorHead = "Daneel.GUI.Common.GetLabel(element) : "
    Daneel.Debug.CheckArgType(element, "element", Daneel.config.guiElementsTypes, errorHead)
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
    Daneel.GUI.pixelUnit = pixelUnit
    
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
-- @param element (Daneel.GUI.Text, Daneel.GUI.Checkbox) The element.
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
    Daneel.Debug.StackTrace.EndFunction()
    return element._position
end


--- Set the element's color which is actually the tile set used to render the label.
-- @param element (Daneel.GUI.Text, Daneel.GUI.Checkbox, Daneel.GUI.Input) The element.
-- @param color (TileSet) An entry in Danel.GUI.colors.
function Daneel.GUI.Common.SetColor(element, color)
    Daneel.Debug.StackTrace.BeginFunction("Daneel.GUI.Common.SetColor", element)
    local errorHead = "Daneel.GUI.Common.SetColor(element, color) : "
    Daneel.Debug.CheckArgType(element, "element", Daneel.config.guiTypes, errorHead)
    Daneel.Debug.CheckOptionalArgType(color, "color", "TileSet", errorHead)

    if color ~= nil then
        element.gameObject.mapRenderer.tileSet = color
        element._color = color
    elseif element._color ~= nil then
        element.gameObject.mapRenderer.tileSet = element._color
        element._color = element._color
    elseif Daneel.config.textDefaultColorName ~= nil then
        local color = Daneel.GUI.colors[Daneel.config.textDefaultColorName]
        element.gameObject.mapRenderer.tileSet = color
        element._color = color
    end

    Daneel.Debug.StackTrace.EndFunction()
end


--- Set the element's background which is a MapRenderer or ModelRenderer.
-- @param element (Daneel.GUI.Text, Daneel.GUI.Checkbox, Daneel.GUI.Input) The element.
-- @param background (string) The model or map path or asset.
function Daneel.GUI.Common.SetBackground(element, background)
    Daneel.Debug.StackTrace.BeginFunction("Daneel.GUI.Common.SetBackground", element)
    local errorHead = "Daneel.GUI.Common.SetBackground(element, background) : "
    Daneel.Debug.CheckArgType(element, "element", Daneel.config.guiTypes, errorHead)
    Daneel.Debug.CheckOptionalArgType(background, "background", {"string", "Model", "Map"}, errorHead)

    local assetType = Daneel.Debug.GetType(background)
    local asset = background
    if assetType == "string" then
        assetType = "Model"
        asset = Asset.Get(background, assetType)

        if asset == nil then
            assetType = "Map"
            asset = Asset.Get(background, assetType)
            if asset == nil then
                error(errorHead.."Argument 'background' : asset with path '"..background.."' is not a Model nor a Map.")
            end
        end
    end
    local assettype = assetType:lower()

    if element._background == nil then
        element._background = GameObject.New(element._name.."Background", {
            parent = element.gameObject,
            [assettype.."Renderer"] = {},
            --transform = { localPosition = Vector3.New(0,0,-5) }, -- put the gameObject "behind" the element
        })
        -- local position above causes error (the same as if the transform was not passed to SetLocalPosition)
        element._background.transform.localPosition = Vector3:New(0,0,-1)
    end

    -- delete the other, old component if it exists
    if assetType == "Model" and element._background.mapRenderer ~= nil then
        element._background.mapRenderer:Destroy()
    elseif assetType == "Map" and element._background.modelRenderer ~= nil then
        element._background.modelRenderer:Destroy()
    end

    -- create the new component if needed then set the new background asset
    element._background:Set({
        [assettype.."Renderer"] = {
            [assettype] = asset
        }
    })

    Daneel.Debug.StackTrace.EndFunction()
end

--- Get the element's background component.
-- @param element (Daneel.GUI.Text, Daneel.GUI.Checkbox, Daneel.GUI.Input) The element.
-- @param (ModelRender or MapRenderer) The background's component.
function Daneel.GUI.Common.GetBackground(element)
    Daneel.Debug.StackTrace.BeginFunction("Daneel.GUI.Common.GetBackground", element)
    local errorHead = "Daneel.GUI.Common.GetBackground(element) : "
    Daneel.Debug.CheckArgType(element, "element", Daneel.config.guiTypes, errorHead)
    Daneel.Debug.StackTrace.EndFunction()
    return element._background
end


--- Destroy the provided element.
-- @param element (Daneel.GUI.Text, Daneel.GUI.Checkbox) The element.
function Daneel.GUI.Common.Destroy(element)
    Daneel.Debug.StackTrace.BeginFunction("Daneel.GUI.Destroy", element)
    local errorHead = "Daneel.GUI.Destroy(element) : "
    Daneel.Debug.CheckArgType(element, "element", Daneel.config.guiTypes, errorHead)
    element.gameObject:Destroy()
    Daneel.Debug.StackTrace.EndFunction()
end

----------------------------------------------------------------------------------
-- Text

Daneel.GUI.Text = {}
setmetatable(Daneel.GUI.Text, Daneel.GUI.Common)
GUIText = Daneel.GUI.Text


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


-- Create a new GUI.Text.
-- @param name (string) The element name.
-- @param params [optional] (table) A table with initialisation parameters.
-- @return (Daneel.GUI.Text) The new element.
function Daneel.GUI.Text.New(name, params)
    Daneel.Debug.StackTrace.BeginFunction("Daneel.GUI.Text.New", name, params)
    local errorHead = "Daneel.GUI.Text.New(name[, params]) : "
    Daneel.Debug.CheckArgType(name, "name", "string", errorHead)
    Daneel.Debug.CheckOptionalArgType(params, "params", "table", errorHead)

    local element = {
        _name = name,
        gameObject = GameObject.New(name, {
            parent = Daneel.config.hudCamera,
            mapRenderer = {},
        }),
    }

    setmetatable(element, Daneel.GUI.Text)
    element.name = name
    element.position = Vector2.New(100)
    element.label = name
    element.scale = Daneel.config.hudElementDefaultScale
    element:SetColor()
    
    if params ~= nil then
        if params.wordWrap ~= nil then
            element.wordWrap = params.wordWrap
            params.wordWrap = nil
        end

        for key, value in pairs(params) do
            if key == "scriptedBehaviors" then
                element.gameObject:Set({scriptedBehaviors = value})
            elseif key == "isButton" and value == true then
                element.gameObject:AddScriptedBehavior("Daneel/Behaviors/MousehoverableGameObject")
                element.gameObject:AddScriptedBehavior("Daneel/Behaviors/GUIText", {element = element})
            elseif key == "backgroundIsButton" and value == true then
                if element._background == nil and params.background ~= nil then
                    element.background = params.background
                    params.background = nil
                end 
                element._background:AddScriptedBehavior("Daneel/Behaviors/MousehoverableGameObject")
                element._background:AddScriptedBehavior("Daneel/Behaviors/GUIText", {element = element})
            else
                element[key] = value
            end
        end
    end

    Daneel.Debug.StackTrace.EndFunction()
    return element
end


----------------------------------------------------------------------------------
-- Checkbox

Daneel.GUI.Checkbox = {}
setmetatable(Daneel.GUI.Checkbox, Daneel.GUI.Common)
GUICheckbox = Daneel.GUI.Checkbox


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

    local element = {
        _name = name,
        gameObject = GameObject.New(name, {
            parent = Daneel.config.hudCamera,
            mapRenderer = {},
            scriptedBehaviors = {
                "Daneel/Behaviors/MousehoverableGameObject",
                "Daneel/Behaviors/GUICheckbox",
            }
        }),
    }

    setmetatable(element, Daneel.GUI.Checkbox)

    -- default properties
    element.name = name
    element.position = Vector2.New(100)
    element.label = name
    element.scale = Daneel.config.hudElementDefaultScale
    element.checked = false
    element.gameObject:GetScriptedBehavior("Daneel/Behaviors/GUICheckbox").element = element

    -- user-defined properties
    if params ~= nil then
        for key, value in pairs(params) do
            if key == "scriptedBehaviors" then
                element.gameObject:Set({scriptedBehaviors = value})
            elseif key == "backgroundIsButton" and value == true then
                if element._background == nil and params.background ~= nil then
                    element.background = params.background
                    params.background = nil
                end 
                element._background:AddScriptedBehavior("Daneel/Behaviors/MousehoverableGameObject")
                element._background:AddScriptedBehavior("Daneel/Behaviors/GUIText", {element = element})
            else
                element[key] = value
            end
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
-- @param doNotSendEvent [optional default=false] Tell wether firing the event.
function Daneel.GUI.Checkbox.SetChecked(element, state, doNotSendEvent)
    Daneel.Debug.StackTrace.BeginFunction("Daneel.GUI.Checkbox.SetChecked", element, state, doNotSendEvent)
    local errorHead = "Daneel.GUI.Checkbox.SetChecked(element, state[, doNotSendEvent]) : "
    Daneel.Debug.CheckArgType(element, "element", "Daneel.GUI.Checkbox", errorHead)
    Daneel.Debug.CheckArgType(state, "state", "boolean", errorHead)
    Daneel.Debug.CheckOptionalArgType(state, "state", "boolean", errorHead)
    
    element._checked = state
    local byte = 251 -- that's the valid mark
    if state == false then byte = string.byte("X") end
    element.gameObject.mapRenderer.map:SetBlockAt(0, 0, 0, byte, Map.BlockOrientation.North)
    
    if doNotSendEvent == true then -- when called from SetLabel
        element.gameObject:SendMessage("OnStateChange", {element = element})
        if type(element.onStateChange) == "function" then
            element:onStateChange()
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
GUIInput = Daneel.GUI.Input


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

    local element = {
        _name = name,
        gameObject = GameObject.New(name, {
            parent = Daneel.config.hudCamera,
            mapRenderer = {}, -- map is set in SetLabel()
            scriptedBehaviors = {
                "Daneel/Behaviors/MousehoverableGameObject",
                "Daneel/Behaviors/GUIInput",
            }
        }),
    }

    setmetatable(element, Daneel.GUI.Input)

    -- default properties
    element.name = name
    element.position = Vector2.New(100)
    element.label = name
    element.scale = Daneel.config.hudElementDefaultScale
    element._focused = false
    element.gameObject:GetScriptedBehavior("Daneel/Behaviors/GUIInput").element = element
    element.cursorMapRndr = element.gameObject:AddMapRenderer({opacity = 0.7})
    element._cursorPosition = 1

    -- user-defined properties
    if params ~= nil then
        for key, value in pairs(params) do
            if key == "scriptedBehaviors" then
                element.gameObject:Set({scriptedBehaviors = value})
            elseif key == "backgroundIsButton" and value == true then
                if element._background == nil and params.background ~= nil then
                    element.background = params.background
                    params.background = nil
                end 
                element._background:AddScriptedBehavior("Daneel/Behaviors/MousehoverableGameObject")
                element._background:AddScriptedBehavior("Daneel/Behaviors/GUIText", {element = element})
            else
                element[key] = value
            end
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

    if type(element.onChange) == "function" then
        element:onChange()
    end
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
            element.cursorMapRndr.map = Map.LoadFromPackage(Daneel.config.emptyTextMapPath) -- hide the cursor on unfocus
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
    element.cursorMapRndr.map = Map.LoadFromPackage(Daneel.config.emptyTextMapPath)
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
GUIProgressBar = Daneel.GUI.ProgressBar


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


-- Create a new GUI.ProgressBar.
-- @param name (string) The element name.
-- @param params [optional] (table) A table with initialisation parameters.
-- @return (Daneel.GUI.ProgressBar) The new element.
function Daneel.GUI.ProgressBar.New(name, params)
    Daneel.Debug.StackTrace.BeginFunction("Daneel.GUI.ProgressBar.New", name, params)
    local errorHead = "Daneel.GUI.ProgressBar.New(name[, params]) : "
    Daneel.Debug.CheckArgType(name, "name", "string", errorHead)
    Daneel.Debug.CheckOptionalArgType(params, "params", "table", errorHead)

    local element = {
        _name = name,
        gameObject = GameObject.New(name, {
            parent = Daneel.config.hudCamera,
            mapRenderer = {},
        }),
    }
    element.bar = GameObject.New(element._name.."Bar", { 
        parent = element.gameObject,
        --localPosition = Vector3:New(0),
        modelRenderer = {},
    })
    element.bar.transform.localPosition = Vector3:New(0)

    setmetatable(element, Daneel.GUI.ProgressBar)
    element.name = name
    element.position = Vector2.New(100)
    element.label = ""
    element.scale = Daneel.config.hudElementDefaultScale
    element.minValue = 0
    element.maxValue = 100
    element.minLength = 0
    element.maxLength = 100
    element.progress = 100
    local progress = 100 -- default progress
    
    if params ~= nil then
        for key, value in pairs(params) do
            print(key, value)
            if key == "scriptedBehaviors" then
                element.gameObject:Set({scriptedBehaviors = value})
            elseif key == "progress" then
                progress = value
            else
                element[key] = value
            end
        end
    end
    
    element.progress = progress

    Daneel.Debug.StackTrace.EndFunction()
    return element
end


function Daneel.GUI.ProgressBar.SetProgress(element, progress)
    Daneel.Debug.StackTrace.BeginFunction("Daneel.GUI.ProgressBar.SetProgress", element, progress)
    local errorHead = "Daneel.GUI.ProgressBar.SetProgress(element[, progress]) : "
    Daneel.Debug.CheckArgType(element, "element", "Daneel.GUI.ProgressBar", errorHead)
    Daneel.Debug.CheckArgType(progress, "progress", {"string", "number"}, errorHead)

    local minVal = element.minValue
    local maxVal = element.maxValue

    if type(progress) == "string" then
        local percentage = tonumber(progress:sub(1, #progress-1))
        progress = (maxVal - minVal) * percentage / 100 + minval
    end

    local oldProgress = progress
    progress = math.clamp(progress, minVal, maxVal)
    if progress ~= oldProgress then
        print("WARNING : progress with value '"..oldProgress.."' is out of its boundaries : min='"..minVal.."', max='"..maxVal.."'")
    end
    print("progress", progress)
    element._progress = progress
    print("pixelunit", Daneel.GUI.pixelUnit, Daneel.config.hudCameraOrthographicScale, Daneel.config.hudCameraOrthographicScale/500)
    local minLength = element.minLength * Daneel.GUI.pixelUnit
    local maxLength = element.maxLength * Daneel.GUI.pixelUnit --length in units of the bar
    print("minLength", element.minLength, minLength)
    print("maxLength", element.maxLength, maxLength)
    

    local percentageVal = (progress - minVal) / (maxVal - minVal) 
    print("percentageVal", percentageVal)
    
    local currentLength = (maxLength - minLength) * percentageVal + minLength
    print("currentLength", currentLength)
    local currentScale = element.bar.transform.localScale
    element.bar.transform.localScale = Vector3:New(currentLength, currentScale.y, currentScale.z)

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


--- Set the model of the progress bar.
-- @param element (Daneel.GUI.ProgressBar) The element.
-- @param model (string or Model) The model path or asset.
function Daneel.GUI.ProgressBar.SetModel(element, model)
    Daneel.Debug.StackTrace.BeginFunction("Daneel.GUI.ProgressBar.SetModel", element, model)
    local errorHead = "Daneel.GUI.ProgressBar.SetModel(element, model) : "
    Daneel.Debug.CheckArgType(element, "element", "Daneel.GUI.ProgressBar", errorHead)
    Daneel.Debug.CheckArgType(model, "model", {"string", "Model"}, errorHead)
    element.bar.modelRenderer.model = model
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
