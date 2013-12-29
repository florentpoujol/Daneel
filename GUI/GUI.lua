-- GUI.lua
-- Module adding the GUI components and Vector2 object
--
-- Last modified for v1.3
-- Copyright © 2013 Florent POUJOL, published under the MIT license.

GUI = { pixelsToUnits = 0 }

--- Convert the provided value (a length) in a number expressed in scene unit.
-- The provided value may be suffixed with "px" (pixels) or "u" (scene units).
-- @param value (string or number) The value to convert.
-- @return (number) The converted value, expressed in scene units.
function GUI.ToSceneUnit( value )
    if type( value ) == "string" then
        value = value:trim()
        if value:find( "px" ) then
            value = tonumber( value:sub( 0, #value-2) ) * GUI.pixelsToUnits
        elseif value:find( "u" ) then
            value = tonumber( value:sub( 0, #value-1) )
        else
            value = tonumber( value )
        end
    end
    return value
end


----------------------------------------------------------------------------------
-- Hud

GUI.Hud = {}
GUI.Hud.__index = GUI.Hud -- __index will be rewritted when Daneel loads (in Daneel.SetComponents()) and enable the dynamic accessors on the components
-- this is just meant to prevent some errors if Daneel is not loaded

--- Transform the 3D position into a Hud position and a layer.
-- @param position (Vector3) The 3D position.
-- @return (Vector2) The hud position.
-- @return (numbe) The layer.
function GUI.Hud.ToHudPosition(position)
    if not Daneel.isAwake then
        Daneel.LateLoad( "GUI.Hud.ToHudPosition" )
    end

    Daneel.Debug.StackTrace.BeginFunction("GUI.Hud.ToHudPosition", position)
    local errorHead = "GUI.Hud.ToHudPosition(hud, position) : "
    Daneel.Debug.CheckArgType(position, "position", "Vector3", errorHead)

    if GUI.Config.originGO == nil then
        error( errorHead.." GUI.Config.originGO is nil because no game object with name '"..GUI.Config.cameraName .."' (value of 'cameraName' in the config) has been found in the scene." )
    end

    local layer = GUI.Config.originGO.transform:GetPosition().z - position.z
    position = position - GUI.Config.originGO.transform:GetPosition()
    position = Vector2(
        position.x / GUI.pixelsToUnits,
        -position.y / GUI.pixelsToUnits
    )
    Daneel.Debug.StackTrace.EndFunction()
    return position, layer
end

--- Convert the provided value (a length) in a number expressed in screen pixel.
-- The provided value may be suffixed with "px" or be expressed in percentage (ie: "10%") or be relative (ie: "s" or "s-10") to the specified screen side size (in which case the 'screenSide' argument is mandatory).
-- @param value (string or number) The value to convert.
-- @param screenSide (string) [optional] "x" (width) or "y" (height)
-- @return (number) The converted value, expressed in pixels.
function GUI.Hud.ToPixel( value, screenSide )
    if type( value ) == "string" then
        value = value:trim()
        local screenSize = CS.Screen.GetSize()

        if value:find( "px" ) then
            value = tonumber( value:sub( 0, #value-2) )

        elseif value:find( "%", 1, true ) and screenSide ~= nil then
            value = screenSize[ screenSide ] * tonumber( value:sub( 0, #value-1) ) / 100

        elseif value:find( "s" ) and screenSide ~= nil then  -- ie: "s-50"  =  "screenSize.x - 50px"
            value = value:sub( 2 ) -- removes the "s" at the beginning
            if value == "" then -- value was just "s"
                value = 0
            end
            value = screenSize[ screenSide ] + tonumber( value )

        else
            value = tonumber( value )
        end
    end
    return value
end

-- Make sure that the components of the provided position are numbers and in pixel,
-- instead of strings or in percentage or relative to the screensize.
-- @param position (Vector2) The position.
-- @return (Vector2) The fixed position.
function GUI.Hud.FixPosition( position )
    return Vector2.New( 
        GUI.Hud.ToPixel( position.x, "x" ),
        GUI.Hud.ToPixel( position.y, "y" )
    )
end

--- Creates a new Hud component instance.
-- @param gameObject (GameObject) The gameObject to add to the component to.
-- @param params (table) [optional] A table of parameters.
-- @return (Hud) The hud component.
function GUI.Hud.New( gameObject, params )
    if not Daneel.isAwake then
        Daneel.LateLoad( "GUI.Hud.New" )
    end

    Daneel.Debug.StackTrace.BeginFunction("GUI.Hud.New", gameObject, params )
    local errorHead = "GUI.Hud.New( gameObject, params ) : "
    if GUI.Config.cameraGO == nil then
        error( errorHead.."Can't create a GUI.Hud component because no game object with name '"..GUI.Config.cameraName.."' (value of 'cameraName' in the config) has been found.")
    end
    Daneel.Debug.CheckArgType(gameObject, "gameObject", "GameObject", errorHead )
    params = Daneel.Debug.CheckOptionalArgType( params, "params", "table", errorHead, {} )

    local hud = setmetatable( {}, GUI.Hud )
    hud.gameObject = gameObject
    hud.id = Daneel.Cache.GetId()
    gameObject.hud = hud

    hud:Set( table.merge( GUI.Config.hud, params ) )
    Daneel.Debug.StackTrace.EndFunction()
    return hud
end

--- Sets the position of the gameObject on screen.
-- With the top-left corner of the screen as origin.
-- @param hud (Hud) The hud component.
-- @param position (Vector2) The position as a Vector2.
function GUI.Hud.SetPosition(hud, position)
    Daneel.Debug.StackTrace.BeginFunction("GUI.Hud.SetPosition", hud, position)
    local errorHead = "GUI.Hud.SetPosition(hud, position) : "
    Daneel.Debug.CheckArgType(hud, "hud", "Hud", errorHead)
    Daneel.Debug.CheckArgType(position, "position", "Vector2", errorHead)
    position = GUI.Hud.FixPosition( position )

    local newPosition = GUI.Config.originGO.transform:GetPosition() +
    Vector3:New(
        position.x * GUI.pixelsToUnits,
        -position.y * GUI.pixelsToUnits,
        0
    )
    newPosition.z = hud.gameObject.transform:GetPosition().z
    hud.gameObject.transform:SetPosition( newPosition )
    Daneel.Debug.StackTrace.EndFunction()
end

--- Get the position of the provided hud on the screen.
-- @param hud (Hud) The hud component.
-- @return (Vector2) The position.
function GUI.Hud.GetPosition(hud)
    Daneel.Debug.StackTrace.BeginFunction("GUI.Hud.GetPosition", hud)
    local errorHead = "GUI.Hud.GetPosition(hud) : "
    Daneel.Debug.CheckArgType(hud, "hud", "Hud", errorHead)

    local position = hud.gameObject.transform:GetPosition() - GUI.Config.originGO.transform:GetPosition()
    position = position / GUI.pixelsToUnits
    position = Vector2.New(math.round(position.x), math.round(-position.y))
    Daneel.Debug.StackTrace.EndFunction()
    return position
end

--- Sets the local position (relative to its parent) of the gameObject on screen .
-- @param hud (Hud) The hud component.
-- @param position (Vector2) The position as a Vector2.
function GUI.Hud.SetLocalPosition(hud, position)
    Daneel.Debug.StackTrace.BeginFunction("GUI.Hud.SetLocalPosition", hud, position)
    local errorHead = "GUI.Hud.SetLocalPosition(hud, position) : "
    Daneel.Debug.CheckArgType(hud, "hud", "Hud", errorHead)
    Daneel.Debug.CheckArgType(position, "position", "Vector2", errorHead)
    position = GUI.Hud.FixPosition( position )

    local parent = hud.gameObject.parent
    if parent == nil then parent = GUI.Config.originGO end
    local newPosition = parent.transform:GetPosition() +
    Vector3:New(
        position.x * GUI.pixelsToUnits,
        -position.y * GUI.pixelsToUnits,
        0
    )
    newPosition.z = hud.gameObject.transform:GetPosition().z
    hud.gameObject.transform:SetPosition( newPosition )
    Daneel.Debug.StackTrace.EndFunction()
end

--- Get the local position (relative to its parent) of the gameObject on screen.
-- @param hud (Hud) The hud component.
-- @return (Vector2) The position.
function GUI.Hud.GetLocalPosition(hud)
    Daneel.Debug.StackTrace.BeginFunction("GUI.Hud.GetLocalPosition", hud)
    local errorHead = "GUI.Hud.GetLocalPosition(hud) : "
    Daneel.Debug.CheckArgType(hud, "hud", "Hud", errorHead)

    local parent = hud.gameObject.parent
    if parent == nil then parent = GUI.Config.originGO end
    local position = hud.gameObject.transform:GetPosition() - parent.transform:GetPosition()
    position = position / GUI.pixelsToUnits
    position = Vector2.New(math.round(position.x), math.round(-position.y))
    Daneel.Debug.StackTrace.EndFunction()
    return position
end

--- Set the gameObject's layer.
-- @param hud (Hud) The hud component.
-- @param layer (number) The layer (a postive number).
function GUI.Hud.SetLayer(hud, layer)
    Daneel.Debug.StackTrace.BeginFunction("GUI.Hud.SetLayer", hud)
    local errorHead = "GUI.Hud.SetLayer(hud, layer) : "
    Daneel.Debug.CheckArgType(hud, "hud", "Hud", errorHead)
    Daneel.Debug.CheckArgType(layer, "layer", "number", errorHead)

    local originLayer = GUI.Config.originGO.transform:GetPosition().z
    local currentPosition = hud.gameObject.transform:GetPosition()
    hud.gameObject.transform:SetPosition( Vector3:New(currentPosition.x, currentPosition.y, originLayer-layer) )
    Daneel.Debug.StackTrace.EndFunction()
end

--- Get the gameObject's layer.
-- @param hud (Hud) The hud component.
-- @return (number) The layer (with one decimal).
function GUI.Hud.GetLayer(hud)
    Daneel.Debug.StackTrace.BeginFunction("GUI.Hud.GetLayer", hud)
    local errorHead = "GUI.Hud.GetLyer(hud) : "
    Daneel.Debug.CheckArgType(hud, "hud", "Hud", errorHead)

    local originLayer = GUI.Config.originGO.transform:GetPosition().z
    local layer = math.round( originLayer - hud.gameObject.transform:GetPosition().z, 1 )
    Daneel.Debug.StackTrace.EndFunction()
    return layer
end

--- Set the huds's local layer.
-- @param hud (Hud) The hud component.
-- @param layer (number) The layer (a postiv number).
function GUI.Hud.SetLocalLayer(hud, layer)
    Daneel.Debug.StackTrace.BeginFunction("GUI.Hud.SetLayer", hud)
    local errorHead = "GUI.Hud.SetLayer(hud, layer) : "
    Daneel.Debug.CheckArgType(hud, "hud", "Hud", errorHead)
    Daneel.Debug.CheckArgType(layer, "layer", "number", errorHead)

    local parent = hud.gameObject.parent
    if parent == nil then parent = GUI.Config.originGO end
    local originLayer = parent.transform:GetPosition().z
    local currentPosition = hud.gameObject.transform:GetPosition()
    hud.gameObject.transform:SetPosition( Vector3:New(currentPosition.x, currentPosition.y, originLayer-layer) )
    Daneel.Debug.StackTrace.EndFunction()
end

--- Get the gameObject's local layer.
-- @param hud (Hud) The hud component.
-- @return (number) The layer (with one decimal).
function GUI.Hud.GetLocalLayer(hud)
    Daneel.Debug.StackTrace.BeginFunction("GUI.Hud.GetLayer", hud)
    local errorHead = "GUI.Hud.GetLyer(hud) : "
    Daneel.Debug.CheckArgType(hud, "hud", "Hud", errorHead)

    local parent = hud.gameObject.parent
    if parent == nil then parent = GUI.Config.originGO end
    local originLayer = parent.transform:GetPosition().z
    local layer = math.round( originLayer - hud.gameObject.transform:GetPosition().z, 1 )
    Daneel.Debug.StackTrace.EndFunction()
    return layer
end


----------------------------------------------------------------------------------
-- Toggle

GUI.Toggle = {}
GUI.Toggle.__index = GUI.Toggle

--- Creates a new Toggle component.
-- @param gameObject (GameObject) The component gameObject.
-- @param params (table) A table of parameters.
-- @return (Toggle) The new component.
function GUI.Toggle.New( gameObject, params )
    if not Daneel.isAwake then
        Daneel.LateLoad( "GUI.Toggle.New" )
    end

    Daneel.Debug.StackTrace.BeginFunction( "GUI.Toggle.New", gameObject, params )
    local errorHead = "GUI.Toggle.New( gameObject, params ) : "
    Daneel.Debug.CheckArgType( gameObject, "gameObject", "GameObject", errorHead )
    params = Daneel.Debug.CheckOptionalArgType( params, "params", "table", errorHead, {} )

    local toggle = table.copy( GUI.Config.toggle )
    toggle.defaultText = toggle.text
    toggle.text = nil
    toggle.gameObject = gameObject
    toggle.id = Daneel.Cache.GetId()
    setmetatable( toggle, GUI.Toggle )

    toggle:Set( params )

    gameObject.toggle = toggle
    gameObject:AddTag( "guiComponent" )

    gameObject.OnNewComponent = function( component )
        if component == nil then return end
        local mt = getmetatable( component )

        if mt == TextRenderer then
            local text = component:GetText()
            if text == nil then
                text = toggle.defaultText
            end
            toggle:SetText( text )

        elseif mt == ModelRenderer and toggle.checkedModel ~= nil then
            if toggle.isChecked and toggle.checkedModel ~= nil then
                component:SetModel( toggle.checkedModel )
            elseif not toggle.isChecked and toggle.uncheckedModel ~= nil then
                component:SetModel( toggle.uncheckedModel )
            end
        end
    end

    gameObject.OnClick = function()
        if not (toggle.group ~= nil and toggle.isChecked) then -- true when not in a group or when in group but not checked
            toggle:Check( not toggle.isChecked )
        end
    end

    if gameObject.textRenderer ~= nil and gameObject.textRenderer:GetText() ~= nil then
        toggle:SetText( gameObject.textRenderer:GetText() )
    end

    if gameObject.modelRenderer ~= nil then
        if toggle.isChecked and toggle.checkedModel ~= nil then
            toggle.gameObject.modelRenderer:SetModel( toggle.checkedModel )
        elseif not toggle.isChecked and toggle.uncheckedModel ~= nil then
            toggle.gameObject.modelRenderer:SetModel( toggle.uncheckedModel )
        end
    end

    toggle:Check( toggle.isChecked, true )

    Daneel.Debug.StackTrace.EndFunction()
    return toggle
end

--- Set the provided toggle's text.
-- Actually set the text of the TextRenderer component on the same gameObject,
-- but add the correct check mark in front of the provided text.
-- @param toggle (Toggle) The toggle component.
-- @param text (string) The text to display.
function GUI.Toggle.SetText( toggle, text )
    Daneel.Debug.StackTrace.BeginFunction( "GUI.Toggle.SetText", toggle, text )
    local errorHead = "GUI.Toggle.SetText( toggle, text ) : "
    Daneel.Debug.CheckArgType( toggle, "toggle", "Toggle", errorHead )
    Daneel.Debug.CheckArgType( text, "text", "string", errorHead )

    if toggle.gameObject.textRenderer ~= nil then
        if toggle.isChecked == true then
            text = Daneel.Utilities.ReplaceInString( toggle.checkedMark, { text = text } )
        else
            text = Daneel.Utilities.ReplaceInString( toggle.uncheckedMark, { text = text } )
        end
        toggle.gameObject.textRenderer:SetText( text )

    else
        if Daneel.Config.debug.enableDebug then
            print( "WARNING : "..errorHead.."Can't set the toggle's text because no TextRenderer component has been found on the gameObject '"..tostring( toggle.gameObject ).."'. Waiting for a TextRenderer to be added." )
        end
        toggle.defaultText = text
    end
    Daneel.Debug.StackTrace.EndFunction()
end

--- Get the provided toggle's text.
-- Actually get the text of the TextRenderer component on the same gameObject but without the check mark.
-- @param toggle (Toggle) The toggle component.
-- @return (string) The text.
function GUI.Toggle.GetText(toggle)
    Daneel.Debug.StackTrace.BeginFunction("GUI.Toggle.GetText", toggle)
    local errorHead = "GUI.Toggle.GetText(toggle, text) : "
    Daneel.Debug.CheckArgType(toggle, "toggle", "Toggle", errorHead)

    local text = nil
    if toggle.gameObject.textRenderer ~= nil then
        text = toggle.gameObject.textRenderer:GetText()
        if text == nil then
            text = toggle.defaultText
        end

        local textMark = toggle.checkedMark
        if not toggle.isChecked then
            textMark = toggle.uncheckedMark
        end

        local start, _end = textMark:find( ":text" )
        if start ~= nil and _end ~= nil then
            local prefix = textMark:sub( 1, start - 1 )
            local suffix = textMark:sub( _end + 1 )
            text = text:gsub(prefix, ""):gsub(suffix, "")
        end

    elseif Daneel.Config.debug.enableDebug then
        print("WARNING : "..errorHead.."Can't get the toggle's text because no TextRenderer component has been found on the gameObject '"..tostring(toggle.gameObject).."'. Returning nil.")
    end
    Daneel.Debug.StackTrace.EndFunction()
    return text
end

--- Check or uncheck the provided toggle and fire the OnUpdate event.
-- You can get the toggle's state via toggle.isChecked.
-- @param toggle (Toggle) The toggle component.
-- @param state [optional default=true] (boolean) The new state of the toggle.
-- @param forceUpdate [optional default=false] (boolean) Tell wether to force the updating of the state.
function GUI.Toggle.Check( toggle, state, forceUpdate )
    Daneel.Debug.StackTrace.BeginFunction( "GUI.Toggle.Check", toggle, state, forceUpdate )
    local errorHead = "GUI.Toggle.Check( toggle[, state, forceUpdate] ) : "
    Daneel.Debug.CheckArgType( toggle, "toggle", "Toggle", errorHead )
    state = Daneel.Debug.CheckOptionalArgType( state, "state", "boolean", errorHead, true )
    forceUpdate = Daneel.Debug.CheckOptionalArgType( forceUpdate, "forceUpdate", "boolean", errorHead, false )

    if forceUpdate or toggle.isChecked ~= state then
        local text = nil
        if toggle.gameObject.textRenderer ~= nil then
            text = toggle:GetText()
        end

        toggle.isChecked = state

        if toggle.gameObject.textRenderer ~= nil then
            toggle:SetText( text ) -- "reload" the check mark based on the new checked state
        end

        if toggle.gameObject.modelRenderer ~= nil then
            if state == true and toggle.checkedModel ~= nil then
                toggle.gameObject.modelRenderer:SetModel( toggle.checkedModel )
            elseif state == false and toggle.uncheckedModel ~= nil then
                toggle.gameObject.modelRenderer:SetModel( toggle.uncheckedModel )
            end
        end

        Daneel.Event.Fire( toggle, "OnUpdate", toggle )

        if toggle.Group ~= nil and state == true then
            local gameObjects = GameObject.GetWithTag( toggle.Group )
            for i, gameObject in ipairs( gameObjects ) do
                if gameObject ~= toggle.gameObject then
                    gameObject.toggle:Check( false, true )
                end
            end
        end
    end

    Daneel.Debug.StackTrace.EndFunction()
end

--- Set the toggle's group.
-- If the toggle was already in a group it will be removed from it.
-- @param toggle (Toggle) The toggle component.
-- @param group [optional] (string) The new group, or nil to remove from its group.
function GUI.Toggle.SetGroup(toggle, group)
    Daneel.Debug.StackTrace.BeginFunction("GUI.Toggle.SetGroup", toggle, group)
    local errorHead = "GUI.Toggle.SetGroup(toggle[, group]) : "
    Daneel.Debug.CheckArgType(toggle, "toggle", "Toggle", errorHead)
    Daneel.Debug.CheckOptionalArgType(group, "group", "string", errorHead)

    if group == nil and toggle.Group ~= nil then
        toggle.gameObject:RemoveTag(toggle.Group)
    else
        if toggle.Group ~= nil then
            toggle.gameObject:RemoveTag(toggle.Group)
        end
        toggle:Check(false)
        toggle.Group = group
        toggle.gameObject:AddTag(toggle.Group)
    end
    Daneel.Debug.StackTrace.EndFunction()
end

-- Get the toggle's group.
-- @param toggle (Toggle) The toggle component.
-- @return (string) The group, or nil.
function GUI.Toggle.GetGroup(toggle)
    Daneel.Debug.StackTrace.BeginFunction("GUI.Toggle.GetGroup", toggle)
    local errorHead = "GUI.Toggle.GetGroup(toggle) : "
    Daneel.Debug.CheckArgType(toggle, "toggle", "Toggle", errorHead)
    Daneel.Debug.StackTrace.EndFunction()
    return toggle.Group
end

--- Apply the content of the params argument to the provided toggle.
-- Overwrite Component.Set() from CraftStudio module.
-- @param toggle (Toggle) The toggle component.
-- @param params (table) A table of parameters to set the component with.
function GUI.Toggle.Set( toggle, params )
    Daneel.Debug.StackTrace.BeginFunction( "GUI.Toggle.Set", toggle, params )
    local errorHead = "GUI.Toggle.Set( toggle, params ) : "
    Daneel.Debug.CheckArgType( toggle, "toggle", "Toggle", errorHead )
    Daneel.Debug.CheckArgType( params, "params", "table", errorHead )

    local group = params.group
    params.group = nil
    local isChecked = params.isChecked
    params.isChecked = nil

    for key, value in pairs( params ) do
        toggle[key] = value
    end

    if group ~= nil then
        toggle:SetGroup( group )
    end
    if isChecked ~= nil then
        toggle:Check( isChecked )
    end

    Daneel.Debug.StackTrace.EndFunction()
end


----------------------------------------------------------------------------------
-- ProgressBar

GUI.ProgressBar = {}
GUI.ProgressBar.__index = GUI.ProgressBar

--- Creates a new GUI.ProgressBar.
-- @param gameObject (GameObject) The component gameObject.
-- @param params (table) A table of parameters.
-- @return (ProgressBar) The new component.
function GUI.ProgressBar.New( gameObject, params )
    if not Daneel.isAwake then
        Daneel.LateLoad( "GUI.ProgressBar.New" )
    end

    Daneel.Debug.StackTrace.BeginFunction( "GUI.ProgressBar.New", gameObject, params )
    local errorHead = "GUI.ProgressBar.New( gameObject, params ) : "
    Daneel.Debug.CheckArgType( gameObject, "gameObject", "GameObject", errorHead )
    params = Daneel.Debug.CheckOptionalArgType( params, "params", "table", errorHead, {} )

    local progressBar = table.copy( GUI.Config.progressBar )
    progressBar.gameObject = gameObject
    progressBar.id = Daneel.Cache.GetId()
    progressBar.value = nil -- remove the property to allow to use the dynamic getter/setter
    setmetatable( progressBar, GUI.ProgressBar )

    if params.value == nil then
        params.value = GUI.Config.progressBar.value
    end
    progressBar:Set( params )

    gameObject.progressBar = progressBar
    Daneel.Debug.StackTrace.EndFunction()
    return progressBar
end

--- Set the value of the progress bar, adjusting its length.
-- Fires the 'OnUpdate' event.
-- @param progressBar (ProgressBar) The progressBar.
-- @param value (number or string) The value as a number (between minVal and maxVal) or as a string and a percentage (between "0%" and "100%").
function GUI.ProgressBar.SetValue(progressBar, value)
    Daneel.Debug.StackTrace.BeginFunction("GUI.ProgressBar.SetValue", progressBar, value)
    local errorHead = "GUI.ProgressBar.SetValue(progressBar, value) : "
    Daneel.Debug.CheckArgType(progressBar, "progressBar", "ProgressBar", errorHead)
    Daneel.Debug.CheckArgType(value, "value", {"string", "number"}, errorHead)

    local minVal = progressBar.minValue
    local maxVal = progressBar.maxValue
    local percentageOfProgress = nil

    if type(value) == "string" then
        if value:endswith("%") then
            percentageOfProgress = tonumber(value:sub(1, #value-1)) / 100

            local oldPercentage = percentageOfProgress
            percentageOfProgress = math.clamp(percentageOfProgress, 0.0, 1.0)
            if percentageOfProgress ~= oldPercentage and Daneel.Config.debug.enableDebug then
                print(errorHead.."WARNING : value in percentage with value '"..value.."' is below 0% or above 100%.")
            end

            value = (maxVal - minVal) * percentageOfProgress + minVal
        else
            value = tonumber(value)
        end
    end

    -- now value is a number and should be a value between minVal and maxVal
    local oldValue = value
    value = math.clamp(value, minVal, maxVal)

    progressBar.minLength = GUI.ToSceneUnit(progressBar.minLength)
    progressBar.maxLength = GUI.ToSceneUnit(progressBar.maxLength)
    local currentValue = progressBar:GetValue()

    if value ~= currentValue then
        if value ~= oldValue and Daneel.Config.debug.enableDebug then
            print(errorHead.." WARNING : value with value '"..oldValue.."' is out of its boundaries : min='"..minVal.."', max='"..maxVal.."'")
        end
        percentageOfProgress = (value - minVal) / (maxVal - minVal)

        progressBar.height = GUI.ToSceneUnit(progressBar.height)

        local newLength = (progressBar.maxLength - progressBar.minLength) * percentageOfProgress + progressBar.minLength
        local currentScale = progressBar.gameObject.transform:GetLocalScale()
        progressBar.gameObject.transform:SetLocalScale( Vector3:New(newLength, progressBar.height, currentScale.z) )
        -- newLength = scale only because the base size of the model is of one unit at a scale of one

        Daneel.Event.Fire(progressBar, "OnUpdate", progressBar)
    end
    Daneel.Debug.StackTrace.EndFunction()
end
function GUI.ProgressBar.SetProgress(progressBar, progress)
    GUI.ProgressBar.SetValue( progressBar, progress )
end

--- Set the value of the progress bar, adjusting its length.
-- Does the same things as SetProgress() by does it faster.
-- Unlike SetProgress(), does not fire the 'OnUpdate' event by default.
-- Should be used when the value is updated regularly (ie : from a Behavior:Update() function).
-- @param progressBar (ProgressBar) The progressBar.
-- @param value (number or string) The value as a number (between minVal and maxVal) or as a string and a percentage (between "0%" and "100%").
-- @param fireEvent [optional default=false] (boolean) Tell wether to fire the 'OnUpdate' event (true) or not (false).
function GUI.ProgressBar.UpdateValue( progressBar, value, fireEvent )
    if value == progressBar._value then return end
    progressBar._value = value

    local minVal = progressBar.minValue
    local maxVal = progressBar.maxValue
    local minLength = progressBar.minLength
    local percentageOfProgress = nil

    if type(value) == "string" then
        local _value = value
        value = tonumber(value)
        if value == nil then -- value in percentage. ie "50%"
            percentageOfProgress = tonumber( _value:sub( 1, #_value-1 ) ) / 100
        end
    end

    if percentageOfProgress == nil then
        percentageOfProgress = (value - minVal) / (maxVal - minVal)
    end
    percentageOfProgress = math.clamp( percentageOfProgress, 0.0, 1.0 )

    local newLength = (progressBar.maxLength - minLength) * percentageOfProgress + minLength
    local currentScale = progressBar.gameObject.transform:GetLocalScale()
    progressBar.gameObject.transform:SetLocalScale( Vector3:New( newLength, progressBar.height, currentScale.z ) )

    if fireEvent == true then
        Daneel.Event.Fire( progressBar, "OnUpdate", progressBar )
    end
end
function GUI.ProgressBar.UpdateProgress( progressBar, value, fireEvent )
    GUI.ProgressBar.UpdateValue( progressBar, value, fireEvent )
end

--- Get the current value of the progress bar.
-- @param progressBar (ProgressBar) The progressBar.
-- @param getAsPercentage [optional default=false] (boolean) Get the value as a percentage (between 0 and 100) instead of an absolute value.
-- @return (number) The value.
function GUI.ProgressBar.GetValue(progressBar, getAsPercentage)
    Daneel.Debug.StackTrace.BeginFunction("GUI.ProgressBar.GetValue", progressBar, getAsPercentage)
    local errorHead = "GUI.ProgressBar.GetValue(progressBar[, getAsPercentage]) : "
    Daneel.Debug.CheckArgType(progressBar, "progressBar", "ProgressBar", errorHead)
    Daneel.Debug.CheckOptionalArgType(getAsPercentage, "getAsPercentage", "boolean", errorHead)

    local scale = progressBar.gameObject.transform:GetLocalScale().x
    local value = (scale - progressBar.minLength) / (progressBar.maxLength - progressBar.minLength)
    if getAsPercentage == true then
        value = value * 100
    else
        value = (progressBar.maxValue - progressBar.minValue) * value + progressBar.minValue
    end
    value = math.round(value)
    Daneel.Debug.StackTrace.EndFunction()
    return value
end
function GUI.ProgressBar.GetProgress(progressBar, getAsPercentage)
    return GUI.ProgressBar.GetValue(progressBar, getAsPercentage)
end

--- Set the height of the progress bar.
-- @param progressBar (ProgressBar) The progressBar.
-- @param height (number or string) Get the height in pixel or scene unit.
function GUI.ProgressBar.SetHeight( progressBar, height )
    Daneel.Debug.StackTrace.BeginFunction( "GUI.ProgressBar.SetHeight", progressBar, height )
    local errorHead = "GUI.ProgressBar.SetHeight( progressBar, height ) : "
    Daneel.Debug.CheckArgType( progressBar, "progressBar", "ProgressBar", errorHead )
    Daneel.Debug.CheckOptionalArgType( height, "height", {"number", "string"}, errorHead )

    height = GUI.ToSceneUnit( height )
    local currentScale = progressBar.gameObject.transform:GetLocalScale()
    progressBar.gameObject.transform:SetLocalScale( Vector3:New( currentScale.x, height, currentScale.z ) )
    Daneel.Debug.StackTrace.EndFunction()
end

--- Get the height of the progress bar (the local scale's y component).
-- @param progressBar (ProgressBar) The progressBar.
-- @return (number) The height.
function GUI.ProgressBar.GetHeight( progressBar )
    Daneel.Debug.StackTrace.BeginFunction( "GUI.ProgressBar.GetHeight", progressBar )
    local errorHead = "GUI.ProgressBar.GetHeight( progressBar ) : "
    Daneel.Debug.CheckArgType( progressBar, "progressBar", "ProgressBar", errorHead )

    local height = progressBar.gameObject.transform:GetLocalScale().y
    Daneel.Debug.StackTrace.EndFunction()
    return height
end

--- Apply the content of the params argument to the provided progressBar.
-- Overwrite Component.Set() from CraftStudio module.
-- @param progressBar (ProgressBar) The progressBar.
-- @param params (table) A table of parameters to set the component with.
function GUI.ProgressBar.Set( progressBar, params )
    Daneel.Debug.StackTrace.BeginFunction( "GUI.ProgressBar.Set", progressBar, params )
    local errorHead = "GUI.ProgressBar.Set( progressBar, params ) : "
    Daneel.Debug.CheckArgType( progressBar, "progressBar", "ProgressBar", errorHead )
    Daneel.Debug.CheckArgType( params, "params", "table", errorHead )

    local value = params.value
    params.value = nil
    if value == nil then
        value = progressBar:GetValue()
    end
    for key, value in pairs(params) do
        progressBar[key] = value
    end
    progressBar:SetValue( value )

    Daneel.Debug.StackTrace.EndFunction()
end


----------------------------------------------------------------------------------
-- Slider

GUI.Slider = {}
GUI.Slider.__index = GUI.Slider

---- Creates a new GUI.Slider.
-- @param gameObject (GameObject) The component gameObject.
-- @param params (table) A table of parameters.
-- @return (Slider) The new component.
function GUI.Slider.New( gameObject, params )
    if not Daneel.isAwake then
        Daneel.LateLoad(  "GUI.Slider.New" )
    end

    Daneel.Debug.StackTrace.BeginFunction( "GUI.Slider.New", gameObject, params )
    local errorHead = "GUI.Slider.New( gameObject, params ) : "
    Daneel.Debug.CheckArgType( gameObject, "gameObject", "GameObject", errorHead )
    params = Daneel.Debug.CheckOptionalArgType( params, "params", "table", errorHead, {} )

    local slider = table.copy( GUI.Config.slider )
    slider.gameObject = gameObject
    slider.id = Daneel.Cache.GetId()
    slider.value = nil
    slider.parent = slider.gameObject:GetParent()
    if slider.parent == nil then
        local go = CS.CreateGameObject( "SliderParent" )
        go.transform:SetPosition( slider.gameObject.transform:GetPosition() )
        slider.gameObject:SetParent( go )
    end
    setmetatable( slider, GUI.Slider )

    gameObject.slider = slider
    gameObject:AddTag( "guiComponent" )

    gameObject.OnDrag = function()
        local mouseDelta = CraftStudio.Input.GetMouseDelta()
        local positionDelta = Vector3:New( mouseDelta.x, 0, 0 )
        if slider.axis == "y" then
            positionDelta = Vector3:New( 0, -mouseDelta.y, 0, 0 )
        end

        gameObject.transform:Move( positionDelta * GUI.pixelsToUnits )

        local goPosition = gameObject.transform:GetPosition()
        local parentPosition = slider.parent.transform:GetPosition()
        if
            (slider.axis == "x" and goPosition.x < parentPosition.x) or
            (slider.axis == "y" and goPosition.y < parentPosition.y)
        then
            slider:SetValue( slider.minValue )
        elseif slider:GetValue() > slider.maxValue then
            slider:SetValue( slider.maxValue )
        else
            Daneel.Event.Fire( slider, "OnUpdate", slider )
        end
    end

    if params.value == nil then
        params.value = GUI.Config.slider.value
    end
    slider:Set( params )

    Daneel.Debug.StackTrace.EndFunction()
    return slider
end

--- Set the value of the slider, adjusting its position.
-- @param slider (Slider) The slider.
-- @param value (number or string) The value as a number (between minVal and maxVal) or as a string and a percentage (between "0%" and "100%").
function GUI.Slider.SetValue( slider, value )
    Daneel.Debug.StackTrace.BeginFunction( "GUI.Slider.SetValue", slider, value )
    local errorHead = "GUI.Slider.SetValue( slider, value ) : "
    Daneel.Debug.CheckArgType( slider, "slider", "Slider", errorHead )
    Daneel.Debug.CheckArgType( value, "value", {"string", "number"}, errorHead )

    local maxVal = slider.maxValue
    local minVal = slider.minValue
    local percentage = nil

    if type( value ) == "string" then
        if value:endswith( "%" ) then
            percentage = tonumber( value:sub( 1, #value-1 ) ) / 100
            value = (maxVal - minVal) * percentage + minVal
        else
            value = tonumber( value )
        end
    end

    -- now value is a number and should be a value between minVal and maxVal
    local oldValue = value
    value = math.clamp( value, minVal, maxVal )
    if value ~= oldValue and Daneel.Config.debug.enableDebug then
        print( errorHead .. "WARNING : Argument 'value' with value '" .. oldValue .. "' is out of its boundaries : min='" .. minVal .. "', max='" .. maxVal .. "'" )
    end
    percentage = (value - minVal) / (maxVal - minVal)

    slider.length = GUI.ToSceneUnit( slider.length )

    local direction = -Vector3:Left()
    if slider.axis == "y" then
        direction = Vector3:Up()
    end
    local orientation = Vector3.Rotate( direction, slider.gameObject.transform:GetOrientation() )
    local newPosition = slider.parent.transform:GetPosition() + orientation * slider.length * percentage
    slider.gameObject.transform:SetPosition( newPosition )

    Daneel.Event.Fire( slider, "OnUpdate", slider )
    Daneel.Debug.StackTrace.EndFunction()
end

--- Get the current slider's value.
-- @param slider (Slider) The slider.
-- @param getAsPercentage [optional default=false] (boolean) Get the value as a percentage (between 0 and 100) instead of an absolute value.
-- @return (number) The value.
function GUI.Slider.GetValue( slider, getAsPercentage )
    Daneel.Debug.StackTrace.BeginFunction( "GUI.Slider.GetValue", slider, getAsPercentage )
    local errorHead = "GUI.Slider.GetValue( slider, value ) : "
    Daneel.Debug.CheckArgType(slider, "slider", "Slider", errorHead)
    Daneel.Debug.CheckOptionalArgType( getAsPercentage, "getAsPercentage", "boolean", errorHead )

    local percentage = Vector3.Distance( slider.parent.transform:GetPosition(), slider.gameObject.transform:GetPosition() ) / slider.length
    local value = percentage * 100
    if getAsPercentage ~= true then
        value = (slider.maxValue - slider.minValue) * percentage + slider.minValue
    end

    Daneel.Debug.StackTrace.EndFunction()
    return value
end

--- Apply the content of the params argument to the provided slider.
-- Overwrite Component.Set() from the core.
-- @param slider (Slider) The slider.
-- @param params (table) A table of parameters to set the component with.
function GUI.Slider.Set( slider, params )
    Daneel.Debug.StackTrace.BeginFunction( "GUI.Slider.Set", slider, params )
    local errorHead = "GUI.Slider.Set( slider, params ) : "
    Daneel.Debug.CheckArgType( slider, "slider", "Slider", errorHead )
    Daneel.Debug.CheckArgType( params, "params", "table", errorHead )

    local value = params.value
    params.value = nil
    if value == nil then
        value = slider:GetValue()
    end
    for key, value in pairs(params) do
        slider[key] = value
    end
    slider:SetValue( value )

    Daneel.Debug.StackTrace.EndFunction()
end


----------------------------------------------------------------------------------
-- Input

GUI.Input = {}
GUI.Input.__index = GUI.Input

--- Creates a new GUI.Input.
-- @param gameObject (GameObject) The component gameObject.
-- @param params (table) A table of parameters.
-- @return (Input) The new component.
function GUI.Input.New( gameObject, params )
    if not Daneel.isAwake then
        Daneel.LateLoad(  "GUI.Input.New" )
    end

    Daneel.Debug.StackTrace.BeginFunction( "GUI.Input.New", gameObject, params )
    local errorHead = "GUI.Input.New( gameObject, params ) : "
    Daneel.Debug.CheckArgType( gameObject, "gameObject", "GameObject", errorHead )
    params = Daneel.Debug.CheckOptionalArgType( params, "params", "table", errorHead, {} )

    local input = table.merge( GUI.Config.input, params )
    input.gameObject = gameObject
    input.id = Daneel.Cache.GetId()
    setmetatable( input, GUI.Input )
    
    -- adapted from Blast Turtles
    if input.OnTextEntered == nil then
        input.OnTextEntered = function( char )
            if input.isFocused then
                local charNumber = string.byte( char )

                if charNumber == 8 then -- Backspace
                    local text = gameObject.textRenderer:GetText()
                    input:Update( text:sub( 1, #text - 1 ), true )

                --elseif charNumber == 13 then -- Enter
                    --Daneel.Event.Fire( input, "OnValidate", input )

                -- Any character between 32 and 127 is regular printable ASCII
                elseif charNumber >= 32 and charNumber <= 127 then
                    if input.characterRange ~= nil and input.characterRange:find( char, 1, true ) == nil then
                        return
                    end
                    input:Update( char )
                end
            end
        end
    end

    local cursorGO = gameObject:GetChild( "Cursor" )
    if cursorGO ~= nil then
        input.cursorGO = cursorGO
        -- make the cursor blink
        cursorGO.tweener = Tween.Timer( 
            input.cursorBlinkInterval,
            function( tweener )
                if tweener.gameObject == nil or tweener.gameObject.inner == nil then
                    tweener:Destroy()
                    return
                end
                local opacity = 1
                if tweener.gameObject.modelRenderer:GetOpacity() == 1 then
                    opacity = 0
                end
                tweener.gameObject.modelRenderer:SetOpacity( opacity )
            end,
            true -- loop
        )
        cursorGO.tweener.isPaused = true
        cursorGO.tweener.gameObject = cursorGO
    end

    local isFocused = input.isFocused
    input.isFocused = nil -- force the state
    input:Focus( isFocused )

    gameObject.input = input
    gameObject:AddTag( "guiComponent" )

    local backgroundGO = gameObject:GetChild( "Background" )
    if backgroundGO ~= nil then
        input.backgroundGO = backgroundGO
        if input.focusOnBackgroundClick then
            backgroundGO:AddTag( "guiComponent" )
        end
    end
    
    input.OnLeftMouseButtonJustPressed = function()
        local focus = gameObject.isMouseOver -- click on the text
        if focus ~= true and input.focusOnBackgroundClick and input.backgroundGO ~= nil then
            focus = input.backgroundGO.isMouseOver
        end
        if focus == nil then
            focus = false
        end
        input:Focus( focus )
    end
    Daneel.Event.Listen( "OnLeftMouseButtonJustPressed", input )

    input.OnValidateInputButtonJustPressed = function()
        if input.isFocused then
            Daneel.Event.Fire( input, "OnValidate", input )
        end
    end
    Daneel.Event.Listen( "OnValidateInputButtonJustPressed", input )

    Daneel.Debug.StackTrace.EndFunction()
    return input
end

--- Set the focused state of the input.
-- @param input (Input) The input component.
-- @param focus (boolean) [optional default=true] The new focus.
function GUI.Input.Focus( input, focus )
    Daneel.Debug.StackTrace.BeginFunction( "GUI.Input.Focus", input, focus )
    local errorHead = "GUI.Input.Focus(input[, focus]) : "
    Daneel.Debug.CheckArgType( input, "input", "Input", errorHead )
    focus = Daneel.Debug.CheckOptionalArgType( focus, "focus", "boolean", errorHead, true )

    if input.isFocused ~= focus then
        input.isFocused = focus
        local text = string.trim( input.gameObject.textRenderer:GetText() )
        if focus == true then
            CS.Input.OnTextEntered( input.OnTextEntered )
            if text == input.defaultValue then
                input.gameObject.textRenderer:SetText( "" )
            end
        else
            CS.Input.OnTextEntered( nil )
            if input.defaultValue ~= nil and input.defaultValue ~= "" and text == "" then
                input.gameObject.textRenderer:SetText( input.defaultValue )
            end
        end

        Daneel.Event.Fire( input, "OnFocus", input )
        input:UpdateCursor()
    end
    Daneel.Debug.StackTrace.EndFunction()
end

--- Update the cursor of the input.
-- @param input (Input) The input component.
function GUI.Input.UpdateCursor( input )
    Daneel.Debug.StackTrace.BeginFunction( "GUI.Input.UpdateCursor", input )
    local errorHead = "GUI.Input.UpdateCursor( input ) : "
    Daneel.Debug.CheckArgType( input, "input", "Input", errorHead )

    if input.cursorGO ~= nil then
        local alignment = input.gameObject.textRenderer:GetAlignment()
        
        if alignment ~= TextRenderer.Alignment.Right then
            local length = input.gameObject.textRenderer:GetTextWidth() -- Left
            if alignment == TextRenderer.Alignment.Center then
                length = length / 2
            end

            input.cursorGO.transform:SetLocalPosition( Vector3:New( length, 0, 0 ) )
        end

        local opacity = 1
        if not input.isFocused then
            opacity = 0
        end
        input.cursorGO.modelRenderer:SetOpacity( opacity )
        input.cursorGO.tweener.isPaused = not input.isFocused
        Daneel.Event.Fire( input.cursorGO, "OnUpdate", input )
    end
    Daneel.Debug.StackTrace.EndFunction()
end

--- Update the text of the input.
-- @param input (Input) The input component.
-- @param text (string) The text (often just one character) to add to the current text.
-- @param replaceText (boolean) [optional default=false] Tell wether the provided text should be added (false) or replace (true) the current text.
function GUI.Input.Update( input, text, replaceText )
    if not type( input ) == "table" or not input.isFocused then
        return
    end

    Daneel.Debug.StackTrace.BeginFunction("GUI.Input.Update", input, text)
    local errorHead = "GUI.Input.Update(input, text) : "
    Daneel.Debug.CheckArgType(input, "input", "Input", errorHead)
    Daneel.Debug.CheckArgType(text, "text", "string", errorHead)
    replaceText = Daneel.Debug.CheckOptionalArgType(replaceText, "replaceText", "boolean", errorHead, false)

    local oldText = input.gameObject.textRenderer:GetText()
    if replaceText == false then
        text = oldText .. text
    end
    if #text > input.maxLength then
        text = text:sub( 1, input.maxLength )
    end
    if oldText ~= text then
        input.gameObject.textRenderer:SetText( text )
        Daneel.Event.Fire( input, "OnUpdate", input )
        input:UpdateCursor()
    end
    Daneel.Debug.StackTrace.EndFunction()
end


----------------------------------------------------------------------------------
-- TextArea

GUI.TextArea = {}
GUI.TextArea.__index = GUI.TextArea

--- Creates a new TextArea component.
-- @param gameObject (GameObject) The game object.
-- @param params (table) A table of parameters.
-- @return (TextArea) The new component.
function GUI.TextArea.New( gameObject, params )
    if not Daneel.isAwake then
        Daneel.LateLoad(  "GUI.TextArea.New" )
    end

    Daneel.Debug.StackTrace.BeginFunction( "GUI.TextArea.New", gameObject, params )
    local errorHead = "GUI.TextArea.New( gameObject, params ) : "
    Daneel.Debug.CheckArgType( gameObject, "gameObject", "GameObject", errorHead )
    params = Daneel.Debug.CheckOptionalArgType( params, "params", "table", errorHead, {} )

    local textArea = {}
    textArea.gameObject = gameObject
    textArea.id = Daneel.Cache.GetId()
    textArea.lineRenderers = {}
    setmetatable( textArea, GUI.TextArea )

    textArea.textRuler = gameObject.textRenderer -- used to store the TextRenderer properties and mesure the lines length in SetText()
    if textArea.textRuler == nil then
        textArea.textRuler = gameObject:CreateComponent( "TextRenderer" ) 
    end
    textArea.textRuler:SetText( "" )
    
    textArea:Set( table.merge( GUI.Config.textArea, params ) )

    gameObject.textArea = textArea
    Daneel.Debug.StackTrace.EndFunction()
    return textArea
end

--- Apply the content of the params argument to the provided textArea.
-- Overwrite Component.Set() from the core.
-- @param textArea (TextArea) The textArea.
-- @param params (table) A table of parameters to set the component with.
function GUI.TextArea.Set( textArea, params )
    Daneel.Debug.StackTrace.BeginFunction( "GUI.TextArea.Set", textArea, params )
    local errorHead = "GUI.TextArea.Set( textArea, params ) : "
    Daneel.Debug.CheckArgType( textArea, "textArea", "TextArea", errorHead )
    Daneel.Debug.CheckArgType( params, "params", "table", errorHead )

    local lineRenderers = textArea.lineRenderers
    textArea.lineRenderers = {} -- prevent the every setters to update the text when they are called
    -- this is done once at the end

    local text = params.text
    params.text = nil

    for key, value in pairs( params ) do
        textArea[ key ] = value
    end
    
    textArea.lineRenderers = lineRenderers
    if text == nil then
        text = textArea.Text
    end
    textArea:SetText( text )

    Daneel.Debug.StackTrace.EndFunction()
end

--- Set the component's text.
-- @param textArea (TextArea) The textArea component.
-- @param text (string) The text to display.
function GUI.TextArea.SetText( textArea, text )
    Daneel.Debug.StackTrace.BeginFunction( "GUI.TextArea.SetText", textArea, text )
    local errorHead = "GUI.TextArea.SetText( textArea, text ) : "
    Daneel.Debug.CheckArgType( textArea, "textArea", "TextArea", errorHead )
    Daneel.Debug.CheckArgType( text, "text", "string", errorHead )

    textArea.Text = text

    local lines = { text }
    if textArea.newLine ~= "" then
        lines = string.split( text, textArea.NewLine )
    end

    local textAreaScale = textArea.gameObject.transform:GetLocalScale()

    -- areaWidth is the max length in units of each line
    local areaWidth = textArea.AreaWidth
    if areaWidth ~= nil and areaWidth > 0 then
        -- cut the lines based on their length
        local tempLines = table.copy( lines )
        lines = {}

        for i = 1, #tempLines do
            local line = tempLines[i]

            if textArea.textRuler:GetTextWidth( line ) * textAreaScale.x > areaWidth then
                line = string.totable( line )
                local newLine = {}

                for j, char in ipairs( line ) do
                    table.insert( newLine, char )

                    if textArea.textRuler:GetTextWidth( table.concat( newLine ) ) * textAreaScale.x > areaWidth then
                        table.remove( newLine )
                        table.insert( lines, table.concat( newLine ) )
                        newLine = { char }

                        if not textArea.WordWrap then
                            newLine = nil
                            break
                        end
                    end
                end

                if newLine ~= nil then
                    table.insert( lines, table.concat( newLine ) )
                end
            else
                table.insert( lines, line )
            end
        end -- end loop on lines
    end

    local linesCount = #lines
    local lineRenderers = textArea.lineRenderers
    local lineRenderersCount = #lineRenderers
    local lineHeight = textArea.LineHeight / textAreaScale.y
    local gameObject = textArea.gameObject
    local textRendererParams = {
        font = textArea.Font,
        alignment = textArea.Alignment,
        opacity = textArea.Opacity,
    }

    -- calculate position offset of the first line based on vertical alignment and number of lines
    -- the offset is decremented by lineHeight after every lines
    local offset = -lineHeight / 2 -- verticalAlignment = "top"
    if textArea.VerticalAlignment == "middle" then
        offset = lineHeight * linesCount / 2 - lineHeight / 2
    elseif textArea.VerticalAlignment == "bottom" then
        offset = lineHeight * linesCount - lineHeight / 2
    end

    for i, line in ipairs( lines ) do
        textRendererParams.text = line

        if lineRenderers[i] ~= nil then
            lineRenderers[i].gameObject.transform:SetLocalPosition( Vector3:New( 0, offset, 0 ) )
            lineRenderers[i]:Set( textRendererParams )
        else
            local newLineGO = GameObject.New( "TextArea" .. textArea.id .. "-Line" .. i, {
                parent = gameObject,
                transform = {
                    localPosition = Vector3:New( 0, offset, 0 ),
                    localScale = Vector3:New(1), -- temporary, fix wrong behavior in the web player
                },
                textRenderer = textRendererParams
            })

            table.insert( lineRenderers, newLineGO.textRenderer )
        end

        offset = offset - lineHeight 
    end

    -- this new text has less lines than the previous one
    if lineRenderersCount > linesCount then
        for i = linesCount + 1, lineRenderersCount do
            lineRenderers[i]:SetText( "" )
        end
    end

    Daneel.Event.Fire( textArea, "OnUpdate", textArea )

    Daneel.Debug.StackTrace.EndFunction()
end

--- Get the component's text.
-- @param textArea (TextArea) The textArea component.
-- @return (string) The component's text.
function GUI.TextArea.GetText( textArea )
    local errorHead = "GUI.TextArea.GetText( textArea ) : "
    Daneel.Debug.CheckArgType( textArea, "textArea", "TextArea", errorHead )
    return textArea.Text
end

--- Set the component's area width (maximum line length).
-- Must be strictly positive to have an effect.
-- Set as a negative value, 0 or nil to remove the limitation.
-- @param textArea (TextArea) The textArea component.
-- @param areaWidth (number or string) The area width in scene units or in pixels as a string suffixed with "px".
function GUI.TextArea.SetAreaWidth( textArea, areaWidth )
    Daneel.Debug.StackTrace.BeginFunction( "GUI.TextArea.SetAreaWidth", textArea, areaWidth )
    local errorHead = "GUI.TextArea.SetAreaWidth( textArea, areaWidth ) : "
    Daneel.Debug.CheckArgType( textArea, "textArea", "TextArea", errorHead )
    areaWidth = Daneel.Debug.CheckOptionalArgType( areaWidth, "areaWidth", {"string", "number"}, errorHead, 0 )
    areaWidth = math.clamp( GUI.ToSceneUnit( areaWidth ), 0, 9999 )
    
    if textArea.AreaWidth ~= areaWidth then
        textArea.AreaWidth = areaWidth
        if #textArea.lineRenderers > 0 then
            textArea:SetText( textArea.Text )
        end
    end
    Daneel.Debug.StackTrace.EndFunction()
end

--- Get the component's area width.
-- @param textArea (TextArea) The textArea component.
-- @return (number) The area width in scene units.
function GUI.TextArea.GetAreaWidth( textArea )
    local errorHead = "GUI.TextArea.GetAreaWidth( textArea ) : "
    Daneel.Debug.CheckArgType( textArea, "textArea", "TextArea", errorHead )
    return textArea.AreaWidth
end

--- Set the component's wordWrap property.
-- Define what happens when the lines are longer then the area width.
-- @param textArea (TextArea) The textArea component.
-- @param wordWrap (boolean) Cut the line when false, or creates new additional lines with the remaining text when true.
function GUI.TextArea.SetWordWrap( textArea, wordWrap )
    Daneel.Debug.StackTrace.BeginFunction( "GUI.TextArea.SetWordWrap", textArea, wordWrap )
    local errorHead = "GUI.TextArea.SetWordWrap( textArea, wordWrap ) : "
    Daneel.Debug.CheckArgType( textArea, "textArea", "TextArea", errorHead )
    Daneel.Debug.CheckArgType( wordWrap, "wordWrap", "boolean", errorHead )

    if textArea.WordWrap ~= wordWrap then
        textArea.WordWrap = wordWrap
        if #textArea.lineRenderers > 0 then
            textArea:SetText( textArea.Text )
        end
    end
    Daneel.Debug.StackTrace.EndFunction()
end

--- Get the component's wordWrap property.
-- @param textArea (TextArea) The textArea component.
-- @return (boolean) True or false.
function GUI.TextArea.GetWordWrap( textArea )
    local errorHead = "GUI.TextArea.GetWordWrap( textArea ) : "
    Daneel.Debug.CheckArgType( textArea, "textArea", "TextArea", errorHead )
    return textArea.WordWrap
end

--- Set the component's newLine string used by SetText() to split the input text in several lines.
-- @param textArea (TextArea) The textArea component.
-- @param newLine (string) The newLine string (one or several character long). Set "\n" to split multiline strings.
function GUI.TextArea.SetNewLine( textArea, newLine )
    Daneel.Debug.StackTrace.BeginFunction( "GUI.TextArea.SetNewLine", textArea, newLine )
    local errorHead = "GUI.TextArea.SetNewLine( textArea, newLine ) : "
    Daneel.Debug.CheckArgType( textArea, "textArea", "TextArea", errorHead )
    Daneel.Debug.CheckArgType( newLine, "newLine", "string", errorHead )

    if textArea.NewLine ~= newLine then
        textArea.NewLine = newLine
        if #textArea.lineRenderers > 0 then
            textArea:SetText( textArea.Text )
        end
    end
    Daneel.Debug.StackTrace.EndFunction()
end

--- Get the component's newLine string.
-- @param textArea (TextArea) The textArea component.
-- @return (string) The newLine string.
function GUI.TextArea.GetNewLine( textArea )
    local errorHead = "GUI.TextArea.GetNewLine( textArea ) : "
    Daneel.Debug.CheckArgType( textArea, "textArea", "TextArea", errorHead )
    return textArea.NewLine
end

--- Set the component's line height.
-- @param textArea (TextArea) The textArea component.
-- @param lineHeight (number or string) The line height in scene units or in pixels as a string suffixed with "px".
function GUI.TextArea.SetLineHeight( textArea, lineHeight )
    Daneel.Debug.StackTrace.BeginFunction( "GUI.TextArea.SetLineHeight", textArea, lineHeight )
    local errorHead = "GUI.TextArea.SetLineHeight( textArea, lineHeight ) : "
    Daneel.Debug.CheckArgType( textArea, "textArea", "TextArea", errorHead )
    Daneel.Debug.CheckArgType( lineHeight, "lineHeight", {"string", "number"}, errorHead )

    local lineHeight = GUI.ToSceneUnit( lineHeight )
    if textArea.LineHeight ~= lineHeight then
        textArea.LineHeight = lineHeight
        if #textArea.lineRenderers > 0 then
            textArea:SetText( textArea.Text )
        end
    end
    Daneel.Debug.StackTrace.EndFunction()
end

--- Get the component's line height.
-- @param textArea (TextArea) The textArea component.
-- @return (number) The line height in scene units.
function GUI.TextArea.GetLineHeight( textArea )
    local errorHead = "GUI.TextArea.GetLineHeight( textArea ) : "
    Daneel.Debug.CheckArgType( textArea, "textArea", "TextArea", errorHead )
    return textArea.LineHeight
end

--- Set the component's vertical alignment.
-- @param textArea (TextArea) The textArea component.
-- @param verticalAlignment (string) "top", "middle" or "bottom". Case-insensitive.
function GUI.TextArea.SetVerticalAlignment( textArea, verticalAlignment )
    Daneel.Debug.StackTrace.BeginFunction( "GUI.TextArea.SetVerticalAlignment", textArea, verticalAlignment )
    local errorHead = "GUI.TextArea.SetVerticalAlignment( textArea, verticalAlignment ) : "
    Daneel.Debug.CheckArgType( textArea, "textArea", "TextArea", errorHead )
    Daneel.Debug.CheckArgType( verticalAlignment, "verticalAlignment", "string", errorHead )
    verticalAlignment = Daneel.Debug.CheckArgValue( verticalAlignment, "verticalAlignment", {"top", "middle", "bottom"}, errorHead, GUI.Config.textArea.verticalAlignment )
    verticalAlignment = string.trim( verticalAlignment:lower() )

    if textArea.VerticalAlignment ~= verticalAlignment then 
        textArea.VerticalAlignment = verticalAlignment
        if #textArea.lineRenderers > 0 then
            textArea:SetText( textArea.Text )
        end
    end
    Daneel.Debug.StackTrace.EndFunction()
end

--- Get the component's vertical alignment property.
-- @param textArea (TextArea) The textArea component.
-- @return (string) The vertical alignment.
function GUI.TextArea.GetVerticalAlignment( textArea )
    local errorHead = "GUI.TextArea.GetVerticalAlignment( textArea ) : "
    Daneel.Debug.CheckArgType( textArea, "textArea", "TextArea", errorHead )
    return textArea.VerticalAlignment
end

--- Set the component's font used to renderer the text.
-- @param textArea (TextArea) The textArea component.
-- @param font (Font or string) The font asset or fully-qualified path.
function GUI.TextArea.SetFont( textArea, font )
    Daneel.Debug.StackTrace.BeginFunction( "GUI.TextArea.SetFont", textArea, font )
    local errorHead = "GUI.TextArea.SetFont( textArea, font ) : "
    Daneel.Debug.CheckArgType( textArea, "textArea", "TextArea", errorHead )
    Daneel.Debug.CheckArgType( font, "font", {"string", "Font"}, errorHead )

    textArea.textRuler:SetFont( font )
    font = textArea.textRuler:GetFont()

    if textArea.Font ~= font then
        textArea.Font = font
        if #textArea.lineRenderers > 0 then
            for i, textRenderer in ipairs( textArea.lineRenderers ) do
                textRenderer:SetFont( textArea.Font )
            end
            textArea:SetText( textArea.Text ) -- reset the text because the size of the text may have changed
        end
    end
    Daneel.Debug.StackTrace.EndFunction()
end

--- Get the component's font used to render the text.
-- @param textArea (TextArea) The textArea component.
-- @return (Font) The font.
function GUI.TextArea.GetFont( textArea )
    local errorHead = "GUI.TextArea.GetFont( textArea ) : "
    Daneel.Debug.CheckArgType( textArea, "textArea", "TextArea", errorHead )
    return textArea.Font
end

--- Set the component's alignment.
-- Works like a TextRenderer alignment.
-- @param textArea (TextArea) The textArea component.
-- @param alignment (TextRenderer.Alignment or string) One of the values in the 'TextRenderer.Alignment' enum (Left, Center or Right) or the same values as case-insensitive string ("left", "center" or "right").
function GUI.TextArea.SetAlignment( textArea, alignment )
    Daneel.Debug.StackTrace.BeginFunction( "GUI.TextArea.SetAlignment", textArea, alignment )
    local errorHead = "GUI.TextArea.SetAlignment( textArea, alignment ) : "
    Daneel.Debug.CheckArgType( textArea, "textArea", "TextArea", errorHead )
    Daneel.Debug.CheckArgType( alignment, "alignment", {"string", "userdata", "number"}, errorHead ) -- "number" is allowed because enums are of type number in the webplayer

    textArea.textRuler:SetAlignment( alignment )
    alignment = textArea.textRuler:GetAlignment()

    if textArea.Alignment ~= alignment then
        textArea.Alignment = alignment
        if #textArea.lineRenderers > 0 then
            for i, textRenderer in ipairs( textArea.lineRenderers ) do
                textRenderer:SetAlignment( textArea.Alignment )
            end
        end
    end
    Daneel.Debug.StackTrace.EndFunction()
end

--- Get the component's horizontal alignment.
-- @param textArea (TextArea) The textArea component.
-- @return (TextRenderer.Alignment or number) The alignment (of type number in the webplayer).
function GUI.TextArea.GetAlignment( textArea )
    local errorHead = "GUI.TextArea.GetAlignment( textArea ) : "
    Daneel.Debug.CheckArgType( textArea, "textArea", "TextArea", errorHead )
    return textArea.Alignment
end

--- Set the component's opacity.
-- @param textArea (TextArea) The textArea component.
-- @param opacity (number) The opacity between 0.0 and 1.0.
function GUI.TextArea.SetOpacity( textArea, opacity )
    Daneel.Debug.StackTrace.BeginFunction( "GUI.TextArea.SetOpacity", textArea, opacity )
    local errorHead = "GUI.TextArea.SetOpacity( textArea, opacity ) : "
    Daneel.Debug.CheckArgType( textArea, "textArea", "TextArea", errorHead )
    Daneel.Debug.CheckArgType( opacity, "opacity", "number", errorHead )

    if textArea.Opacity ~= opacity then
        textArea.Opacity = opacity
        if #textArea.lineRenderers > 0 then
            for i, textRenderer in ipairs( textArea.lineRenderers ) do
                textRenderer:SetOpacity( opacity )
            end
        end
    end
    Daneel.Debug.StackTrace.EndFunction()
end

--- Get the component's opacity.
-- @param textArea (TextArea) The textArea component.
-- @return (number) The opacity between 0.0 and 1.0.
function GUI.TextArea.GetOpacity( textArea )
    local errorHead = "GUI.TextArea.GetOpacity( textArea ) : "
    Daneel.Debug.CheckArgType( textArea, "textArea", "TextArea", errorHead )
    return textArea.Opacity
end


----------------------------------------------------------------------------------
-- Vector 2

Vector2 = {}
Vector2.__index = Vector2
setmetatable( Vector2, { __call = function(Object, ...) return Object.New(...) end } )

function Vector2.__tostring(vector2)
    return "Vector2: { x="..vector2.x..", y="..vector2.y.." }"
end

--- Creates a new Vector2 intance.
-- @param x (number, string or Vector2) The vector's x component.
-- @param y [optional] (number or string) The vector's y component. If nil, will be equal to x.
-- @return (Vector2) The new instance.
function Vector2.New(x, y)
    Daneel.Debug.StackTrace.BeginFunction("Vector2.New", x, y)
    local errorHead = "Vector2.New(x, y) : "
    local argType = Daneel.Debug.CheckArgType(x, "x", {"string", "number", "Vector2"}, errorHead)
    Daneel.Debug.CheckOptionalArgType(y, "y", {"string", "number"}, errorHead)

    if y == nil then y = x end
    local vector = setmetatable({ x = x, y = y }, Vector2)
    if argType == "Vector2" then
        vector.x = x.x
        vector.y = x.y
    end
    Daneel.Debug.StackTrace.EndFunction()
    return vector
end

--- Return the length of the vector.
-- @param vector (Vector2) The vector.
-- @return (number) The length.
function Vector2.GetLength( vector )
    Daneel.Debug.StackTrace.BeginFunction( "Vector2.GetLength", vector )
    local errorHead = "Vector2.GetLength( vector ) : "
    Daneel.Debug.CheckArgType( vector, "vector", "Vector2", errorHead )

    local length = math.sqrt( vector.x^2 + vector.y^2 )
    Daneel.Debug.StackTrace.EndFunction()
    return length
end

--- Return the squared length of the vector.
-- @param vector (Vector2) The vector.
-- @return (number) The squared length.
function Vector2.GetSqrLength( vector )
    Daneel.Debug.StackTrace.BeginFunction( "Vector2.GetSqrLength", vector )
    local errorHead = "Vector2.GetSqrLength( vector ) : "
    Daneel.Debug.CheckArgType( vector, "vector", "Vector2", errorHead )

    local length = vector.x^2 + vector.y^2
    Daneel.Debug.StackTrace.EndFunction()
    return length
end

--- Return a copy of the provided vector, normalized.
-- @param vector (Vector2) The vector to normalize.
-- @return (Vector2) A copy of the vector, normalized.
function Vector2.Normalized( vector )
    Daneel.Debug.StackTrace.BeginFunction( "Vector2.Normalized", vector )
    local errorHead = "Vector2.Normalized( vector ) : "
    Daneel.Debug.CheckArgType( vector, "vector", "Vector2", errorHead )

    local nv = Vector2.New( vector.x, vector.y ):Normalize()
    Daneel.Debug.StackTrace.EndFunction()
    return nv
end

--- Normalize the provided vector in place (makes its length equal to 1).
-- @param vector (Vector2) The vector to normalize.
function Vector2.Normalize( vector )
    Daneel.Debug.StackTrace.BeginFunction( "Vector2.Normalize", vector )
    local errorHead = "Vector2.Normalize( vector ) : "
    Daneel.Debug.CheckArgType( vector, "vector", "Vector2", errorHead )

    local length = vector:GetLength()
    if length ~= 0 then
        vector = vector / length
    end
    Daneel.Debug.StackTrace.EndFunction()
end

--- Allow to add two Vector2 by using the + operator.
-- Ie : vector1 + vector2
-- @param a (Vector2) The left member.
-- @param b (Vector2) The right member.
-- @return (Vector2) The new vector.
function Vector2.__add(a, b)
    Daneel.Debug.StackTrace.BeginFunction("Vector2.__add", a, b)
    local errorHead = "Vector2.__add(a, b) : "
    Daneel.Debug.CheckArgType(a, "a", "Vector2", errorHead)
    Daneel.Debug.CheckArgType(b, "b", "Vector2", errorHead)
    a = Vector2.New(a.x + b.x, a.y + b.y)
    Daneel.Debug.StackTrace.EndFunction()
    return a
end

--- Allow to substract two Vector2 by using the - operator.
-- Ie : vector1 - vector2
-- @param a (Vector2) The left member.
-- @param b (Vector2) The right member.
-- @return (Vector2) The new vector.
function Vector2.__sub(a, b)
    Daneel.Debug.StackTrace.BeginFunction("Vector2.__sub", a, b)
    local errorHead = "Vector2.__sub(a, b) : "
    Daneel.Debug.CheckArgType(a, "a", "Vector2", errorHead)
    Daneel.Debug.CheckArgType(b, "b", "Vector2", errorHead)
    a = Vector2.New(a.x - b.x, a.y - b.y)
    Daneel.Debug.StackTrace.EndFunction()
    return a
end

--- Allow to multiply two Vector2 or a Vector2 and a number by using the * operator.
-- @param a (Vector2 or number) The left member.
-- @param b (Vector2 or number) The right member.
-- @return (Vector2) The new vector.
function Vector2.__mul(a, b)
    Daneel.Debug.StackTrace.BeginFunction("Vector2.__mull", a, b)
    local errorHead = "Vector2.__mul(a, b) : "
    Daneel.Debug.CheckArgType(a, "a", {"Vector2", "number"}, errorHead)
    Daneel.Debug.CheckArgType(b, "b", {"Vector2", "number"}, errorHead)
    local newVector = nil
    if type(a) == "number" then
        newVector = Vector2.New(a * b.x, a * b.y)
    elseif type(b) == "number" then
        newVector = Vector2.New(a.x * b, a.y * b)
    else
        newVector = Vector2.New(a.x * b.x, a.y * b.y)
    end
    Daneel.Debug.StackTrace.EndFunction()
    return newVector
end

--- Allow to divide two Vector2 or a Vector2 and a number by using the / operator.
-- @param a (Vector2 or number) The numerator.
-- @param b (Vector2 or number) The denominator. Can't be equal to 0.
-- @return (Vector2) The new vector.
function Vector2.__div(a, b)
    Daneel.Debug.StackTrace.BeginFunction("Vector2.__div", a, b)
    local errorHead = "Vector2.__div(a, b) : "
    Daneel.Debug.CheckArgType(a, "a", {"Vector2", "number"}, errorHead)
    Daneel.Debug.CheckArgType(b, "b", {"Vector2", "number"}, errorHead)
    local newVector = nil
    if type(a) == "number" then
        if b.x == 0 or b.y == 0 then
            error(errorHead.."One of the components of the denominator is equal to 0. Can't divide by 0 ! a="..a..", b.x="..b.x..", b.y="..b.y)
        end
        newVector = Vector2.New(a / b.x, a / b.y)
    elseif type(b) == "number" then
        if b == 0 then
            error(errorHead.."The denominator is equal to 0 ! Can't divide by 0 ! a.x="..a.x..", a.y="..a.y..", b=0")
        end
        newVector = Vector2.New(a.x / b, a.y / b)
    else
        if b.x == 0 or b.y == 0 then
            error(errorHead.."One of the components of the denominator is equal to 0. Can't divide by 0 ! a.x="..a.x..", a.y="..a.y..", b.x="..b.x..", b.y="..b.y)
        end
        newVector = Vector2.New(a.x / b.x, a.y / b.y)
    end
    Daneel.Debug.StackTrace.EndFunction()
    return newVector
end

--- Allow to inverse a vector2 using the - operator.
-- @param vector (Vector2) The vector.
-- @return (Vector2) The new vector.
function Vector2.__unm(vector)
    Daneel.Debug.StackTrace.BeginFunction("Vector2.__unm", vector)
    local errorHead = "Vector2.__unm(vector) : "
    Daneel.Debug.CheckArgType(vector, "vector", "Vector2", errorHead)
    local vector = Vector2.New(-vector.x, -vector.y)
    Daneel.Debug.StackTrace.EndFunction()
    return vector
end

--- Allow to raise a Vector2 to a power using the ^ operator.
-- @param vector (Vector2) The vector.
-- @param exp (number) The power to raise the vector to.
-- @return (Vector2) The new vector.
function Vector2.__pow(vector, exp)
    Daneel.Debug.StackTrace.BeginFunction("Vector2.__pow", vector, exp)
    local errorHead = "Vector2.__pow(vector, exp) : "
    Daneel.Debug.CheckArgType(vector, "vector", "Vector2", errorHead)
    Daneel.Debug.CheckArgType(exp, "exp", "number", errorHead)
    vector = Vector2.New(vector.x ^ exp, vector.y ^ exp)
    Daneel.Debug.StackTrace.EndFunction()
    return vector
end

--- Allow to check for the equality between two Vector2 using the == comparison operator.
-- @param a (Vector2) The left member.
-- @param b (Vector2) The right member.
-- @return (boolean) True if the same components of the two vectors are equal (a.x=b.x and a.y=b.y)
function Vector2.__eq(a, b)
    Daneel.Debug.StackTrace.BeginFunction("Vector2.__eq", a, b)
    local errorHead = "Vector2.__eq(a, b) : "
    Daneel.Debug.CheckArgType(a, "a", "Vector2", errorHead)
    Daneel.Debug.CheckArgType(b, "b", "Vector2", errorHead)
    local eq = ((a.x == b.x) and (a.y == b.y))
    Daneel.Debug.StackTrace.EndFunction()
    return eq
end


----------------------------------------------------------------------------------

local OriginalGetMousePosition = CraftStudio.Input.GetMousePosition

--- Return the mouse position on screen coordinates {x, y}
-- @return (Vector2) The on-screen mouse position.
function CraftStudio.Input.GetMousePosition()
    Daneel.Debug.StackTrace.BeginFunction("CraftStudio.Input.GetMousePosition")
    local vector = setmetatable( OriginalGetMousePosition(), Vector2 )
    Daneel.Debug.StackTrace.EndFunction()
    return vector
end

local OriginalGetMouseDelta = CraftStudio.Input.GetMouseDelta

--- Return the mouse delta (the variation of position) since the last frame.
-- Positive x is right, positive y is bottom.
-- @return (Vector2) The position's delta.
function CraftStudio.Input.GetMouseDelta()
    Daneel.Debug.StackTrace.BeginFunction("CraftStudio.Input.GetMouseDelta")
    local vector = setmetatable( OriginalGetMouseDelta(), Vector2 )
    Daneel.Debug.StackTrace.EndFunction()
    return vector
end

local OriginalGetSize = CraftStudio.Screen.GetSize

--- Return the size of the screen, in pixels.
-- @return (Vector2) The screen's size.
function CraftStudio.Screen.GetSize()
    Daneel.Debug.StackTrace.BeginFunction("CraftStudio.Screen.GetSize")
    local vector = setmetatable( OriginalGetSize(), Vector2 )
    Daneel.Debug.StackTrace.EndFunction()
    return vector
end


----------------------------------------------------------------------------------
-- Config - loading

if CS.DaneelModules == nil then
    CS.DaneelModules = {}
end
CS.DaneelModules[ "GUI" ] = GUI

function GUI.DefaultConfig()
    local config = {
        cameraName = "HUD Camera",  -- Name of the gameObject who has the orthographic camera used to render the HUD
        cameraGO = nil, -- the corresponding GameObject, set at runtime
        originGO = nil, -- "parent" gameObject for global hud positioning, created at runtime in DaneelModuleGUIAwake

        -- Default GUI components settings
        hud = {
            localPosition = setmetatable({x=0,y=0}, Vector2),
            layer = 1,
        },

        toggle = {
            isChecked = false, -- false = unchecked, true = checked
            text = "Toggle",
            -- ':text' represents the toggle's text
            checkedMark = ":text",
            uncheckedMark = ":text",
            checkedModel = nil,
            uncheckedModel = nil,
        },

        progressBar = {
            height = 1,
            minValue = 0,
            maxValue = 100,
            minLength = 0,
            maxLength = 5, -- in units
            value = "100%",
        },

        slider = {
            minValue = 0,
            maxValue = 100,
            length = 5, -- 5 units
            axis = "x",
            value = "0%",
            OnTextEntered = nil
        },

        input = {
            isFocused = false,
            maxLength = 9999,
            defaultValue = nil,
            characterRange = nil,
            focusOnBackgroundClick = true,
            cursorBlinkInterval = 0.5, -- second
        },

        textArea = {
            areaWidth = 0, -- max line length, in units or pixel as a string (0 = no max length)
            wordWrap = false, -- when a line is longer than the area width: cut the ligne when false, put the rest of the ligne in one or several lines when true
            newLine = "<br>", -- end of line delimiter
            lineHeight = 1, -- in units or pixels
            verticalAlignment = "top",

            font = nil,
            text = "",
            alignment = nil,
            opacity = nil,
        },

        componentObjects = {
            Hud = GUI.Hud,
            Toggle = GUI.Toggle,
            ProgressBar = GUI.ProgressBar,
            Slider = GUI.Slider,
            Input = GUI.Input,
            TextArea = GUI.TextArea,
        },
        componentTypes = {},

        objects = {
            Vector2 = Vector2,
        },
    }

    return config
end
GUI.Config = GUI.DefaultConfig()

function GUI.Load()
    Daneel.GUI = GUI

    if CS.DaneelModules["MouseInput"] == nil and Daneel.Config.debug.enableDebug then
        print( "GUI.Load() : Your project seems to lack the 'Mouse Input' module. It is required for the player to interact with the GUI.Toggle, GUI.Input and GUI.Slider components." )
    end

    --- Update the gameObject's scale to make the text appear the provided width.
    -- Overwrite TextRenderer.SetTextWith() from the Core.
    -- @param textRenderer (TextRenderer) The textRenderer.
    -- @param width (number or string) The text's width in scene units or pixels.
    function TextRenderer.SetTextWidth( textRenderer, width )
        Daneel.Debug.StackTrace.BeginFunction("TextRenderer.SetTextWidth", textRenderer, width)
        local errorHead = "TextRenderer.SetTextWidth( textRenderer, width ) : "
        Daneel.Debug.CheckArgType(textRenderer, "textRenderer", "TextRenderer", errorHead)
        local argType = Daneel.Debug.CheckArgType(width, "width", {"number", "string"}, errorHead)

        if argType == "string" then
            width = GUI.ToSceneUnit( width )
        end

        local widthScaleRatio = textRenderer:GetTextWidth() / textRenderer.gameObject.transform:GetScale()
        textRenderer.gameObject.transform:SetScale( width / widthScaleRatio )
        Daneel.Debug.StackTrace.EndFunction()
    end
end

function GUI.Awake()
    -- get the smaller side of the screen (usually screenSize.y, the height)
    local screenSize = CS.Screen.GetSize()
    local smallSideSize = screenSize.y
    if screenSize.x < screenSize.y then
        smallSideSize = screenSize.x
    end

    GUI.Config.cameraGO = GameObject.Get( GUI.Config.cameraName )

    if GUI.Config.cameraGO ~= nil then
        -- The orthographic scale value (in units) is equivalent to the smallest side size of the screen (in pixel)
        -- pixelsToUnits (in units/pixels) is the correspondance between screen pixels and scene units
        GUI.pixelsToUnits = GUI.Config.cameraGO.camera:GetOrthographicScale() / smallSideSize

        GUI.Config.originGO = CS.CreateGameObject( "HUD Origin" )
        GUI.Config.originGO:SetParent( GUI.Config.cameraGO )

        GUI.Config.originGO.transform:SetLocalPosition( Vector3:New(
            -screenSize.x * GUI.pixelsToUnits / 2,
            screenSize.y * GUI.pixelsToUnits / 2,
            0
        ) )
        -- the HUD Origin is now at the top-left corner of the screen
    end
end
