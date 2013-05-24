
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


----------------------------------------------------------------------------------
-- Common

Daneel.GUI.Common = {} -- common functions for GUI Elements

-- Basic contructor for GUI elements.
-- @param name (string) The element name.
-- @return (Daneel.GUI.Common) The basics of the element, to be completed by the other GUI.[element].New() function.
function Daneel.GUI.Common.New(name, params)
    Daneel.Debug.StackTrace.BeginFunction("Daneel.GUI.Common.New", name, params)
    local errorHead = "Daneel.GUI.Common.New(name[, params]) : "
    Daneel.Debug.CheckArgType(name, "name", "string", errorHead)
    Daneel.Debug.CheckOptionalArgType(params, "params", "table", errorHead)

    local parent = config.default.gui.hudOrigin
    if params ~= nil and params.group ~= nil then
        if Daneel.Debug.GetType(params.group) == "Daneel.GUI.Group" then
            params.group = params.group.gameObject
        end
        parent = params.group
    end

    local element = {
        _name = name,
        gameObject = GameObject.New(name, {
            parent = parent,
            transform = {
                localPosition = Vector3:New(0,0,0)
            }
        }),
    }

    setmetatable(element, Daneel.GUI.Common)
    element.name = name
    element.layer = 5
    
    Daneel.Debug.StackTrace.EndFunction()
    return element
end


--- Set the element's name.
-- @param element (Daneel.GUI.Text, Daneel.GUI.CheckBox) The element.
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
-- @param element (Daneel.GUI.Text, Daneel.GUI.CheckBox) The element.
-- @return (string) The name.
function Daneel.GUI.Common.GetName(element)
    Daneel.Debug.StackTrace.BeginFunction("Daneel.GUI.Common.GetName", element)
    local errorHead = "Daneel.GUI.Common.GetName(element) : "
    Daneel.Debug.CheckArgType(element, "element", config.default.guiTypes, errorHead)
    Daneel.Debug.StackTrace.EndFunction()
    return element._name
end


--- Set the element's scale which is actually the gameObject's local scale.
-- @param element (Daneel.GUI.Text, Daneel.GUI.CheckBox) The element.
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
-- @param element (Daneel.GUI.Text, Daneel.GUI.CheckBox) The element.
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
-- @param element (Daneel.GUI.Text, Daneel.GUI.CheckBox) The element.
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
-- @param element (Daneel.GUI.Text, Daneel.GUI.CheckBox) The element.
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


local lastLabelUpdateClocks = {}

--- Set the label of the provided element.
-- @param element (Daneel.GUI.Text, Daneel.GUI.CheckBox) The element.
-- @param label (mixed) Something to display.
-- @param refreshRate [optional] (number) The time in seconds between two updates of the label. (Minimum when set is 0.02)
function Daneel.GUI.Common.SetLabel(element, label, refreshRate)
    Daneel.Debug.StackTrace.BeginFunction("Daneel.GUI.Common.SetLabel", element, label, refreshRate)
    local errorHead = "Daneel.GUI.Common.SetLabel(element, label[, refreshRate]) : "
    Daneel.Debug.CheckArgType(element, "element", {"Daneel.GUI.Text", "Daneel.GUI.CheckBox", "Daneel.GUI.Input", "Daneel.GUI.WorldText"}, errorHead)
    
    label = tostring(label)
    if label == element._label then
        Daneel.Debug.StackTrace.EndFunction()
        return 
    end

    if refreshRate ~= nil then
        Daneel.Debug.CheckArgType(refreshRate, "refreshRate", "number", errorHead)
        if refreshRate < 0.02 then refreshRate = 0.02 end
        local name = element.name
        if lastLabelUpdateClocks[name] == nil then
            lastLabelUpdateClocks[name] = 0
        end
        local clock = os.clock() -- time in seconds since the beginning of the program
        if clock < lastLabelUpdateClocks[name] + refreshRate then
            Daneel.Debug.StackTrace.EndFunction()
            return
        end
        lastLabelUpdateClocks[name] = clock
    end
    
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
    if elementType == "Daneel.GUI.CheckBox" then
        if config.default.gui.checkBox.tileSet ~= nil then
            element.gameObject.mapRenderer.tileSet = config.default.gui.checkBox.tileSet
        end
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

    if elementType ~= "Daneel.GUI.CheckBox" then
        element.gameObject:SendMessage("OnChange", {element = element})
        if type(element.onChange) == "function" then
            element:onChange()
        end
    end

    Daneel.Debug.StackTrace.EndFunction()
end


--- Get the label of the provided element.
-- @param element (Daneel.GUI.Text, Daneel.GUI.CheckBox) The element.
-- @return (string) The label.
function Daneel.GUI.Common.GetLabel(element)
    Daneel.Debug.StackTrace.BeginFunction("Daneel.GUI.Common.GetLabel", element)
    local errorHead = "Daneel.GUI.Common.GetLabel(element) : "
    Daneel.Debug.CheckArgType(element, "element", {"Daneel.GUI.Text", "Daneel.GUI.CheckBox", "Daneel.GUI.Input"}, errorHead)
    Daneel.Debug.StackTrace.EndFunction()
    return element._label
end


--- Sets the relative position of the provided element on the screen.
-- The postion is relative to the element's parent which is the HUDOrigin gameObject, 
-- at the top-left corner fo the screen, or a GUI.Group.
-- @param element (Daneel.GUI.Text, Daneel.GUI.CheckBox) The element.
-- @param position (Vector2) The position as a Vector2.
function Daneel.GUI.Common.SetPosition(element, position)
    Daneel.Debug.StackTrace.BeginFunction("Daneel.GUI.Common.SetPosition", element, position)
    local errorHead = "Daneel.GUI.Common.SetPosition(element, position) : "
    Daneel.Debug.CheckArgType(element, "element", config.default.guiTypes, errorHead)
    Daneel.Debug.CheckArgType(position, "position", "Vector2", errorHead)
    
    element._position = position
    local position3D = Vector3:New(
        position.x * Daneel.GUI.pixelsToUnits,
        -position.y * Daneel.GUI.pixelsToUnits,
        element.gameObject.transform.localPosition.z
    )
    element.gameObject.transform.localPosition = position3D
    Daneel.Debug.StackTrace.EndFunction()
end

--- Get the position of the provided element on the screen.
-- @param element (Daneel.GUI.Text, Daneel.GUI.CheckBox) The element.
-- @return (Vector2) The position.
function Daneel.GUI.Common.GetPosition(element)
    Daneel.Debug.StackTrace.BeginFunction("Daneel.GUI.Common.GetPosition", element)
    local errorHead = "Daneel.GUI.Common.GetPosition(element) : "
    Daneel.Debug.CheckArgType(element, "element", config.default.guiTypes, errorHead)
    if element._position == nil then
        -- the element is at a local pos of {0,0,0} from its parent
        element._position = Vector2.New(0, 0)
    end
    Daneel.Debug.StackTrace.EndFunction()
    return element._position
end


--- Set the element's color which is actually the tile set used to render the label.
-- @param element (Daneel.GUI.Text, Daneel.GUI.CheckBox, Daneel.GUI.Input, Daneel.GUI.WorldText) The element.
-- @param color (string) The color name.
function Daneel.GUI.Common.SetColor(element, color)
    Daneel.Debug.StackTrace.BeginFunction("Daneel.GUI.Common.SetColor", element, color)
    local errorHead = "Daneel.GUI.Common.SetColor(element, color) : "
    Daneel.Debug.CheckArgType(element, "element", {"Daneel.GUI.Text", "Daneel.GUI.CheckBox", "Daneel.GUI.Input", "Daneel.GUI.WorldText"}, errorHead)
    Daneel.Debug.CheckOptionalArgType(color, "color", "string", errorHead)

    local defaultColor = Daneel.Config.Get("gui.textDefaultColorName")
    if color == nil and element._color ~= nil then
        color = element._color
    -- if color arg is not set, and color has not already been set once, put the default color
    elseif color == nil and element._color == nil then
        color = defaultColor
    end

    if not table.containskey(config.default.gui.textColorTileSets, color) then
        if DEBUG == true then
            print("WARNING : "..errorHead.." color '"..color.."' is not one of the correct colors. Defaulting to '"..defaultColor.."'.")
        end
        color = defaultColor
    end
    element.gameObject.mapRenderer.tileSet = config.default.gui.textColorTileSets[color]
    element._color = color
    Daneel.Debug.StackTrace.EndFunction()
end


--- Set the elements's layer which is actually its local position's z component.
-- @param element (Daneel.GUI.Text, Daneel.GUI.CheckBox) The element.
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
-- @param element (Daneel.GUI.Text, Daneel.GUI.CheckBox) The element.
-- @return (number) The layer.
function Daneel.GUI.Common.GetLayer(element)
    Daneel.Debug.StackTrace.BeginFunction("Daneel.GUI.Common.GetLayer", element)
    local errorHead = "Daneel.GUI.Common.GetLyer(element) : "
    Daneel.Debug.CheckArgType(element, "element", config.default.guiTypes, errorHead)
    return -element.gameObject.transform.localPosition.z
end


--- Destroy the provided element.
-- @param element (Daneel.GUI.Text, Daneel.GUI.CheckBox) The element.
function Daneel.GUI.Common.Destroy(element)
    Daneel.Debug.StackTrace.BeginFunction("Daneel.GUI.Destroy", element)
    local errorHead = "Daneel.GUI.Destroy(element) : "
    Daneel.Debug.CheckArgType(element, "element", config.default.guiTypes, errorHead)
    element.gameObject:Destroy()
    Daneel.Debug.StackTrace.EndFunction()
end


----------------------------------------------------------------------------------
-- Group

Daneel.GUI.Group = {}
setmetatable(Daneel.GUI.Group, Daneel.GUI.Common)

--- Create a new Daneel.GUI.Group.
-- @param name (string) The element name.
-- @param params [optional] (table) A table with initialisation parameters.
-- @return (Daneel.GUI.Group) The new element.
function Daneel.GUI.Group.New(name, params)
    Daneel.Debug.StackTrace.BeginFunction("Daneel.GUI.Group.New", name, params)
    local errorHead = "Daneel.GUI.Group.New(name[, params]) : "
    Daneel.Debug.CheckArgType(name, "name", "string", errorHead)
    Daneel.Debug.CheckOptionalArgType(params, "params", "table", errorHead)

    local element = Daneel.GUI.Common.New(name, params)
    setmetatable(element, Daneel.GUI.Group)
    if params ~= nil then
        for key, value in pairs(params) do
            element[key] = value
        end
    end
    Daneel.Debug.StackTrace.EndFunction()
    return element
end


----------------------------------------------------------------------------------
-- Text

Daneel.GUI.Text = {}
setmetatable(Daneel.GUI.Text, Daneel.GUI.Common)

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
    element.scale = Daneel.Config.Get("gui.textDefaultScale")

    if params ~= nil then
        if params.interactive == true then
            element.gameObject:AddScriptedBehavior("Daneel/Behaviors/GUI/GUIMouseInteractive", {element = element})
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
        if params.interactive == true then
            element.gameObject:AddScriptedBehavior("Daneel/Behaviors/GUI/GUIMouseInteractive", {element = element})
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
-- CheckBox

Daneel.GUI.CheckBox = {}
setmetatable(Daneel.GUI.CheckBox, Daneel.GUI.Common)

-- Create a new GUI.CheckBox.
-- @param name (string) The element name.
-- @param params [optional] (table) A table with initialisation parameters.
-- @return (Daneel.GUI.CheckBox) The new element.
function Daneel.GUI.CheckBox.New(name, params)
    Daneel.Debug.StackTrace.BeginFunction("Daneel.GUI.CheckBox.New", name, params)
    local errorHead = "Daneel.GUI.CheckBox.New(name[, params]) : "
    Daneel.Debug.CheckArgType(name, "name", "string", errorHead)
    Daneel.Debug.CheckOptionalArgType(params, "params", "table", errorHead)

    local element = Daneel.GUI.Common.New(name, params)
    setmetatable(element, Daneel.GUI.CheckBox)
    element.gameObject:AddScriptedBehavior("Daneel/Behaviors/GUI/GUIMouseInteractive", {element = element})
    element.gameObject:AddScriptedBehavior("Daneel/Behaviors/GUI/CheckBox", {element = element})
    element.label = name
    element.checked = false
    element.scale = Daneel.Config.Get("gui.textDefaultScale")

    if params ~= nil then
        for key, value in pairs(params) do
            element[key] = value
        end
    end

    Daneel.Debug.StackTrace.EndFunction()
    return element
end

--- Switch the checked state of the checkbox.
-- @param element (Daneel.GUI.CheckBox) The element.
function Daneel.GUI.CheckBox.SwitchState(element)
    Daneel.Debug.StackTrace.BeginFunction("Daneel.GUI.CheckBox.SwitchState", element)
    local errorHead = "Daneel.GUI.CheckBox.SwitchState(element) : "
    Daneel.Debug.CheckArgType(element, "element", "Daneel.GUI.CheckBox", errorHead)
    if element._checked == true then
        element.checked = false
    else
        element.checked = true
    end
    Daneel.Debug.StackTrace.EndFunction()
end

--- Set the checked state of the checkbox.
-- Update the _checked variable and the mapRenderer
-- @param element (Daneel.GUI.CheckBox) The element.
-- @param state (boolean) The state.
function Daneel.GUI.CheckBox.SetChecked(element, state, resetMarkAfterSetLabel)
    Daneel.Debug.StackTrace.BeginFunction("Daneel.GUI.CheckBox.SetChecked", element, state)
    local errorHead = "Daneel.GUI.CheckBox.SetChecked(element, state) : "
    Daneel.Debug.CheckArgType(element, "element", "Daneel.GUI.CheckBox", errorHead)
    Daneel.Debug.CheckArgType(state, "state", "boolean", errorHead)
    Daneel.Debug.CheckOptionalArgType(state, "state", "boolean", errorHead)
    if resetMarkAfterSetLabel == true or element._checked ~= state then
        element._checked = state
        local byte = Daneel.Config.Get("gui.checkBox.checkedBlock") -- default is 251, the valid mark
        if state == false then 
            byte = Daneel.Config.Get("gui.checkBox.notCheckedBlock") -- default is "O",
        end
        if type(byte) == "string" then
            byte = string.byte(byte)
        end
        element.gameObject.mapRenderer.map:SetBlockAt(0, 0, 0, byte, Map.BlockOrientation.North)
        
        if resetMarkAfterSetLabel ~= true then
            element.gameObject:SendMessage("OnChange", {element = element})
            if type(element.onChange) == "function" then
                element:onChange()
            end
        end
    end
    Daneel.Debug.StackTrace.EndFunction()
end

--- Get the checked state of the checkbox.
-- @param element (Daneel.GUI.CheckBox) The element.
-- @return (boolean) The state.
function Daneel.GUI.CheckBox.GetChecked(element)
    Daneel.Debug.StackTrace.BeginFunction("Daneel.GUI.CheckBox.GetChecked", element)
    local errorHead = "Daneel.GUI.CheckBox.GetChecked(element) : "
    Daneel.Debug.CheckArgType(element, "element", "Daneel.GUI.CheckBox", errorHead)
    Daneel.Debug.StackTrace.EndFunction()
    return element._checked    
end


----------------------------------------------------------------------------------
-- Input

Daneel.GUI.Input = {}
setmetatable(Daneel.GUI.Input, Daneel.GUI.Common)

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
    element.gameObject:AddScriptedBehavior("Daneel/Behaviors/GUI/GUIMouseInteractive", {element = element})
    element.gameObject:AddScriptedBehavior("Daneel/Behaviors/GUI/Input", {element = element})
    element.label = name
    element.cursorMapRndr = element.gameObject:AddMapRenderer({opacity = 0.9})
    element._cursorPosition = 1
    element.focused = false
    element.scale = Daneel.Config.Get("gui.textDefaultScale")
    
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
        if params.interactive == true then
            element.gameObject:AddScriptedBehavior("Daneel/Behaviors/GUI/GUIMouseInteractive", {element = element})
        end

        if params.vertical == true then
            element.gameObject.transform.eulerAngles = element.gameObject.transform.eulerAngles + Vector3:New(0,0,-90)
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
    Daneel.Debug.StackTrace.BeginFunction("Daneel.GUI.ProgressBar.SetBar", element, model)
    local errorHead = "Daneel.GUI.ProgressBar.SetBar(element, model) : "
    Daneel.Debug.CheckArgType(element, "element", "Daneel.GUI.ProgressBar", errorHead)
    Daneel.Debug.CheckArgType(model, "model", {"string", "Model"}, errorHead)
    element.gameObject.modelRenderer.model = model
    Daneel.Debug.StackTrace.EndFunction()
end


----------------------------------------------------------------------------------
-- Slider

Daneel.GUI.Slider = {}
setmetatable(Daneel.GUI.Slider, Daneel.GUI.Common)

--- Create a new GUI.Slider.
-- @param name (string) The element name.
-- @param params [optional] (table) A table with initialisation parameters.
-- @return (Daneel.GUI.Slider) The new element.
function Daneel.GUI.Slider.New(name, params)
    Daneel.Debug.StackTrace.BeginFunction("Daneel.GUI.Slider.New", name, params)
    local errorHead = "Daneel.GUI.Slider.New(name[, params]) : "
    Daneel.Debug.CheckArgType(name, "name", "string", errorHead)
    Daneel.Debug.CheckOptionalArgType(params, "params", "table", errorHead)

    if params == nil then
        params = {}
    end
    local ProgressBarParams = {
        minLength = 0,
        maxLength = params.length,
        height = params.height,
        progress = "100%",
    }
    
    local element = Daneel.GUI.ProgressBar.New(name.."ProgressBar", ProgressBarParams)
    setmetatable(element, Daneel.GUI.Slider)
    element.name = name
    
    element.handleGO = GameObject.New(name.."Handle", {
        parent = element.gameObject,
        modelRenderer = {},
        scriptedBehaviors = {
            ["Daneel/Behaviors/GUI/GUIMouseInteractive"] = {element = element},
        },
        transform = {
            localPosition = Vector3:New(0)
        }
    })
    element.length = 100
    element.progress = "50%"
    element.handle = "Daneel/SliderHandle"

    if params ~= nil then
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


--- Set the progress of the progress bar, adjusting its position.
-- @param element (Daneel.GUI.Slider) The element.
-- @param pogress (number or string) The progress as a number (between minVal and maxVal) or as a string and a percentage (between "0%" and "100%").
function Daneel.GUI.Slider.SetProgress(element, progress)
    Daneel.Debug.StackTrace.BeginFunction("Daneel.GUI.Slider.SetProgress", element, progress)
    local errorHead = "Daneel.GUI.Slider.SetProgress(element[, progress]) : "
    Daneel.Debug.CheckArgType(element, "element", "Daneel.GUI.Slider", errorHead)
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
    
    local currentDist = element.length * Daneel.GUI.pixelsToUnits * percentageOfProgress
    element.handleGO.transform.localPosition = Vector3:New(currentDist, 0, 0)

    element.gameObject:SendMessage("OnChange", {element = element})
    if type(element.onChange) == "function" then
        element:onChange()
    end
end

--- Get the current progress of the progress bar.
-- @param element (Daneel.GUI.Slider) The element.
-- @param getAsPercentage [optional default=false] (boolean) Get the progress as a percentage instead of an absolute value.
-- @return (number) The progress.
function Daneel.GUI.Slider.GetProgress(element, getAsPercentage)
    Daneel.Debug.StackTrace.BeginFunction("Daneel.GUI.Slider.GetProgress", element, getAsPercentage)
    local errorHead = "Daneel.GUI.Slider.GetProgress(element[, getAsPercentage]) : "
    Daneel.Debug.CheckArgType(element, "element", "Daneel.GUI.Slider", errorHead)
    Daneel.Debug.CheckOptionalArgType(getAsPercentage, "getAsPercentage", "boolean", errorHead)
    local progress = element._progress
    if getAsPercentage == true then
        progress = progress / element.maxValue * 100
    end
    Daneel.Debug.StackTrace.EndFunction()
    return progress
end

--- Set the height of the progress bar, in pixels.
-- @param element (Daneel.GUI.Slider) The element.
-- @param height (number) The heigt in pixels.
function Daneel.GUI.Slider.SetHeight(element, height)
    Daneel.Debug.StackTrace.BeginFunction("Daneel.GUI.Slider.SetProgress", element, height)
    local errorHead = "Daneel.GUI.Slider.SetProgress(element[, height]) : "
    Daneel.Debug.CheckArgType(element, "element", "Daneel.GUI.Slider", errorHead)
    Daneel.Debug.CheckArgType(height, "height", "number", errorHead)
    element._height = height
    local unitHeight = height *  Daneel.GUI.pixelsToUnits 
    local currentScale = element.gameObject.transform.localScale
    element.gameObject.transform.localScale = Vector3:New(currentScale.x, unitHeight, currentScale.z)
end

--- Set the model of the progress bar.
-- @param element (Daneel.GUI.Slider) The element.
-- @param model (string or Model) The model path or asset.
function Daneel.GUI.Slider.SetBar(element, model)
    Daneel.Debug.StackTrace.BeginFunction("Daneel.GUI.Slider.SetBar", element, model)
    local errorHead = "Daneel.GUI.Slider.SetBar(element, model) : "
    Daneel.Debug.CheckArgType(element, "element", "Daneel.GUI.Slider", errorHead)
    Daneel.Debug.CheckArgType(model, "model", {"string", "Model"}, errorHead)
    element.gameObject.modelRenderer.model = model
    Daneel.Debug.StackTrace.EndFunction()
end

--- Set the model of the progress bar.
-- @param element (Daneel.GUI.Slider) The element.
-- @param model (string or Model) The model path or asset.
function Daneel.GUI.Slider.SetHandle(element, model)
    Daneel.Debug.StackTrace.BeginFunction("Daneel.GUI.Slider.SetHandle", element, model)
    local errorHead = "Daneel.GUI.Slider.SetHandle(element, model) : "
    Daneel.Debug.CheckArgType(element, "element", "Daneel.GUI.Slider", errorHead)
    Daneel.Debug.CheckArgType(model, "model", {"string", "Model"}, errorHead)
    element.handleGO.modelRenderer.model = model
    Daneel.Debug.StackTrace.EndFunction()
end


----------------------------------------------------------------------------------
-- WorldText

Daneel.GUI.WorldText = {}
setmetatable(Daneel.GUI.WorldText, Daneel.GUI.Common)

-- Create a new Daneel.GUI.WorldText.
-- @param name (ScriptedBehavior) The element's ScriptedBehavior.
-- @return (Daneel.GUI.WorldText) The new element.
function Daneel.GUI.WorldText.New(behavior)
    Daneel.Debug.StackTrace.BeginFunction("Daneel.GUI.WorldText.New", behavior)
    local errorHead = "Daneel.GUI.WorldText.New(behavior) : "
    Daneel.Debug.CheckArgType(behavior, "behavior", "ScriptedBehavior", errorHead)

    local element = {
        _name = behavior.name,
        gameObject = behavior.gameObject
    }
    setmetatable(element, Daneel.GUI.WorldText)
    element.name = behavior.name
    
    if behavior.label == "WorldText" then
        behavior.label = behavior.label.." "..behavior.name
    end
    local oldLabel = behavior.label
    behavior.label = behavior.label:gsub(":lang:", "")
    if behavior.label ~= oldLabel then
        behavior.label = Daneel.Lang.Line(behavior.label)
    end
    element.label = behavior.label

    if behavior.interactive == true then
        element.gameObject:AddScriptedBehavior("Daneel/Behaviors/GUI/GUIMouseInteractive", {element = element})
    end

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
