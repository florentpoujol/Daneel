-- GUI.lua
-- Module adding the GUI components and Vector2 object
--
-- Last modified for v1.5.0
-- Copyright © 2013-2014 Florent POUJOL, published under the MIT license.

GUI = {}

-- debug info
local s = "string"
local b = "boolean"
local n = "number"
local t = "table"
local go = "GameObject"
local v2 = "Vector2"
local v3 = "Vector3"
local _go = { "gameObject", go }
local _op = { "params", t, defaultValue = {} }
local _p = { "params", t }

--- Convert the provided value (a length) in a number expressed in scene unit.
-- The provided value may be suffixed with "px" (pixels) or "u" (scene units).
-- @param value (string or number) The value to convert.
-- @param camera (Camera) [optional] The reference camera used to convert from pixels to units. Only needed when the value is in pixels.
-- @return (number) The converted value, expressed in scene units.
function GUI.ToSceneUnit( value, camera )
    if type( value ) == "string" then
        value = value:trim()
        if value:find( "px" ) then
            if camera == nil then
                error( "GUI.ToSceneUnit(value, camera) : Can't convert the value '"..value.."' from pixels to scene units because no camera component has been passed as argument.")
            end
            value = tonumber( value:sub( 0, #value-2) ) * camera:GetPixelsToUnits()
        elseif value:find( "u" ) then
            value = tonumber( value:sub( 0, #value-1) )
        else
            value = tonumber( value )
        end
    end
    return value
end

--- Convert the provided value (a length) in a number expressed in screen pixel.
-- The provided value may be suffixed with "px" or be expressed in percentage (ie: "10%") or be relative (ie: "s" or "s-10") to the specified screen side size (in which case the 'screenSide' argument is mandatory).
-- @param value (string or number) The value to convert.
-- @param screenSide (string) [optional] "x" (width) or "y" (height)
-- @param camera (Camera) [optional] The reference camera used to convert from pixels to units. Only needed when the value is in units.
-- @return (number) The converted value, expressed in pixels.
function GUI.ToPixel( value, screenSide, camera )
    if type( screenSide ) == "table" then
        camera = screenSide
        screenSide = nil
    end
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

        elseif value:find( "u" ) then
            if camera == nil then
                error( "GUI.ToPixel(value, camera) : Can't convert the value '"..value.."' from pixels to scene units because no camera component has been passed as argument.")
            end
            value = tonumber( value:sub( 0, #value-1) ) / camera:GetPixelsToUnits()

        else
            value = tonumber( value )
        end
    end
    return value
end

local function getCameraGO( params, gameObject, errorHead )
    if params.cameraGO == nil then
        params.cameraGO = gameObject:GetInAncestors( function( go ) if go.camera ~= nil then return true end end )
        if params.cameraGO == nil then
            error(errorHead..": The "..tostring(gameObject).." isn't a child of a game object with a camera component and no camera game object is passed via the 'params' argument.")
        end
    end
end

----------------------------------------------------------------------------------
-- Hud

GUI.Hud = {}
GUI.Hud.__index = GUI.Hud -- __index will be rewritted when Daneel loads (in Daneel.SetComponents()) and enable the dynamic accessors on the components
-- this is just meant to prevent some errors if Daneel is not loaded

--- Creates a "Hud Origin" child used for positioning hud components.
-- @param gameObject (GameObject) The game object with a camera component.
function GUI.Hud.RegisterCamera( gameObject )
    if gameObject.camera == nil then
        error( "GUI.Hud.RegisterCamera(): Provided game object "..tostring(gameObject).." has no camera component." )
    end
    local pixelsToUnits = gameObject.camera:GetPixelsToUnits()
    local screenSize = CS.Screen.GetSize()
    local originGO = CS.CreateGameObject( "Hud Origin for camera "..gameObject:GetName(), gameObject )
    originGO.transform:SetLocalPosition( Vector3:New(
        -screenSize.x * pixelsToUnits / 2,
        screenSize.y * pixelsToUnits / 2,
        0
    ) )
    -- the originGO is now at the top-left corner of the camera's frustum
    -- 06/06/2014: what happens with perspective cameras ?
    gameObject.hudOriginGO = originGO
end

-- Deprecated since v1.5.0.
-- Use Camera.WorldToScreenPoint() or Camera.Project() instead.
function GUI.Hud.ToHudPosition()
    error("GUI.Hud.ToHudPosition() is deprecated since v1.5.0. Use Camera.WorldToScreenPoint() or Camera.Project() instead.")
end

--- Make sure that the components of the provided Vector2 are numbers and in pixel,
-- instead of strings or in percentage or relative to the screensize.
-- @param vector (Vector2) The vector2.
-- @param camera (Camera) [optional] The reference camera used to convert from pixels to units. Only needed when the vector's components are in units.
-- @return (Vector2) The fixed position.
function Vector2.EnsureNumberPixel( vector, camera )
    vector.x = GUI.ToPixel( vector.x, "x", camera )
    vector.y = GUI.ToPixel( vector.y, "y", camera )
    return vector 
end

--- Creates a new Hud component instance.
-- @param gameObject (GameObject) The gameObject to add to the component to.
-- @param params (table) [optional] A table of parameters.
-- @return (Hud) The hud component.
function GUI.Hud.New( gameObject, params )
    params = params or {}
    getCameraGO( params, gameObject, "GUI.Hud.New()" )
    if params.cameraGO == nil then
        params.cameraGO = gameObject:GetInAncestors( function( go ) if go.camera ~= nil then return true end end )
        if params.cameraGO == nil then
            error("GUI.Hud.New(): The "..tostring(gameObject).." isn't a child of a game object with a camera component and no camera game object is passed via the 'params' argument.")
        end
    end
    local hud = setmetatable( {}, GUI.Hud )
    hud.gameObject = gameObject
    gameObject.hud = hud
    hud.id = Daneel.Utilities.GetId()
    if params.cameraGO.camera.hudOriginGO == nil then
        GUI.Hud.RegisterCamera( params.cameraGO )
    end
    hud:Set( table.merge( GUI.Config.hud, params ) )
    return hud
end

--- Sets the position of the gameObject on screen.
-- With the top-left corner of the screen as origin.
-- @param hud (Hud) The hud component.
-- @param position (Vector2) The position as a Vector2.
function GUI.Hud.SetPosition(hud, position)
    position:EnsureNumberPixel( hud.cameraGO.camera )
    local newPosition = hud.cameraGO.hudOriginGO.transform:GetPosition() +
    Vector3:New(
        position.x * hud.cameraGO.camera:GetPixelsToUnits(),
        -position.y * hud.cameraGO.camera:GetPixelsToUnits(),
        0
    )
    newPosition.z = hud.gameObject.transform:GetPosition().z
    hud.gameObject.transform:SetPosition( newPosition )
end

--- Get the position of the provided hud on the screen.
-- @param hud (Hud) The hud component.
-- @return (Vector2) The position.
function GUI.Hud.GetPosition(hud)
    local position = hud.gameObject.transform:GetPosition() - hud.cameraGO.hudOriginGO.transform:GetPosition()
    position = position / hud.cameraGO.camera:GetPixelsToUnits()
    return Vector2.New(math.round(position.x), math.round(-position.y))
end

--- Sets the local position (relative to its parent) of the gameObject on screen .
-- @param hud (Hud) The hud component.
-- @param position (Vector2) The position as a Vector2.
function GUI.Hud.SetLocalPosition(hud, position)
    position:EnsureNumberPixel( hud.cameraGO.camera )
    local parent = hud.gameObject.parent or hud.cameraGO.hudOriginGO
    local newPosition = parent.transform:GetPosition() +
    Vector3:New(
        position.x * hud.cameraGO.camera:GetPixelsToUnits(),
        -position.y * hud.cameraGO.camera:GetPixelsToUnits(),
        0
    )
    newPosition.z = hud.gameObject.transform:GetPosition().z
    hud.gameObject.transform:SetPosition( newPosition )
end

--- Get the local position (relative to its parent) of the gameObject on screen.
-- @param hud (Hud) The hud component.
-- @return (Vector2) The position.
function GUI.Hud.GetLocalPosition(hud)
    local parent = hud.gameObject.parent or hud.cameraGO.hudOriginGO
    local position = hud.gameObject.transform:GetPosition() - parent.transform:GetPosition()
    position = position / hud.cameraGO.camera:GetPixelsToUnits()
    return Vector2.New(math.round(position.x), math.round(-position.y))
end

--- Set the gameObject's layer.
-- @param hud (Hud) The hud component.
-- @param layer (number) The layer (a postive number).
function GUI.Hud.SetLayer(hud, layer)
    local originLayer = hud.cameraGO.hudOriginGO.transform:GetPosition().z
    local currentPosition = hud.gameObject.transform:GetPosition()
    hud.gameObject.transform:SetPosition( Vector3:New(currentPosition.x, currentPosition.y, originLayer-layer) )
end

--- Get the gameObject's layer.
-- @param hud (Hud) The hud component.
-- @return (number) The layer (with one decimal).
function GUI.Hud.GetLayer(hud)
    local originLayer = hud.cameraGO.hudOriginGO.transform:GetPosition().z
    return math.round( originLayer - hud.gameObject.transform:GetPosition().z, 1 )
end

--- Set the huds's local layer.
-- @param hud (Hud) The hud component.
-- @param layer (number) The layer (a postiv number).
function GUI.Hud.SetLocalLayer(hud, layer)
    local parent = hud.gameObject.parent or hud.cameraGO.hudOriginGO
    local originLayer = parent.transform:GetPosition().z
    local currentPosition = hud.gameObject.transform:GetPosition()
    hud.gameObject.transform:SetPosition( Vector3:New(currentPosition.x, currentPosition.y, originLayer-layer) )
end

--- Get the gameObject's local layer.
-- @param hud (Hud) The hud component.
-- @return (number) The layer (with one decimal).
function GUI.Hud.GetLocalLayer(hud)
    local parent = hud.gameObject.parent or hud.cameraGO.hudOriginGO
    local originLayer = parent.transform:GetPosition().z
    return math.round( originLayer - hud.gameObject.transform:GetPosition().z, 1 )
end

local _hud = { "hud", "Hud" }
table.mergein( Daneel.functionsDebugInfo, {
    ["GUI.Hud.RegisterCamera"] =    { _go },
    ["GUI.Hud.New"] =               { _go, _op },
    ["GUI.Hud.SetPosition"] =       { _hud, { "position", v2 } },
    ["GUI.Hud.GetPosition"] =       { _hud },
    ["GUI.Hud.SetLocalPosition"] =  { _hud, { "position", v2 } },
    ["GUI.Hud.GetLocalPosition"] =  { _hud },
    ["GUI.Hud.SetLayer"] =          { _hud, { "layer", n } },
    ["GUI.Hud.GetLayer"] =          { _hud },
    ["GUI.Hud.SetLocalLayer"] =     { _hud, { "layer", n } },
    ["GUI.Hud.GetLocalLayer"] =     { _hud },
} )


----------------------------------------------------------------------------------
-- Toggle

GUI.Toggle = {}
GUI.Toggle.__index = GUI.Toggle

--- Creates a new Toggle component.
-- @param gameObject (GameObject) The component gameObject.
-- @param params (table) [optional] A table of parameters.
-- @return (Toggle) The new component.
function GUI.Toggle.New( gameObject, params )
    if Daneel.modules.MouseInput == nil then
        error( "GUI.Toggle.New(): The 'Mouse Input' module is missing from your project. It is required for the player to interact with the GUI.Toggle, GUI.Input and GUI.Slider components." )
    end

    local toggle = table.copy( GUI.Config.toggle )
    toggle.defaultText = toggle.text
    toggle.text = nil
    toggle.gameObject = gameObject
    toggle.id = Daneel.Utilities.GetId()
    setmetatable( toggle, GUI.Toggle )
    if params ~= nil then
        toggle:Set( params )
    end

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
    return toggle
end

--- Set the provided toggle's text.
-- Actually set the text of the TextRenderer component on the same gameObject,
-- but add the correct check mark in front of the provided text.
-- @param toggle (Toggle) The toggle component.
-- @param text (string) The text to display.
function GUI.Toggle.SetText( toggle, text )
    if toggle.gameObject.textRenderer ~= nil then
        if toggle.isChecked == true then
            text = Daneel.Utilities.ReplaceInString( toggle.checkedMark, { text = text } )
        else
            text = Daneel.Utilities.ReplaceInString( toggle.uncheckedMark, { text = text } )
        end
        toggle.gameObject.textRenderer:SetText( text )
    else
        if Daneel.Config.debug.enableDebug then
            print( "WARNING: GUI.Toggle.SetText(toggle, text): Can't set the toggle's text because no TextRenderer component has been found on the gameObject '"..tostring( toggle.gameObject ).."'. Waiting for a TextRenderer to be added." )
        end
        toggle.defaultText = text
    end
end

--- Get the provided toggle's text.
-- Actually get the text of the TextRenderer component on the same gameObject but without the check mark.
-- @param toggle (Toggle) The toggle component.
-- @return (string) The text.
function GUI.Toggle.GetText( toggle )
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
        print("WARNING: GUI.Toggle.GetText(toggle): Can't get the toggle's text because no TextRenderer component has been found on the gameObject '"..tostring(toggle.gameObject).."'. Returning nil.")
    end
    return text
end

--- Check or uncheck the provided toggle and fire the OnUpdate event.
-- You can get the toggle's state via toggle.isChecked.
-- @param toggle (Toggle) The toggle component.
-- @param state (boolean) [default=true] The new state of the toggle.
-- @param forceUpdate (boolean) [default=false] Tell whether to force the updating of the state.
function GUI.Toggle.Check( toggle, state, forceUpdate )
    state = state or true
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
end

--- Set the toggle's group.
-- If the toggle was already in a group it will be removed from it.
-- @param toggle (Toggle) The toggle component.
-- @param group (string) [optional] The new group, or nil to remove the toggle from its group.
function GUI.Toggle.SetGroup( toggle, group )
    if group == nil and toggle.Group ~= nil then
        toggle.gameObject:RemoveTag( toggle.Group )
    else
        if toggle.Group ~= nil then
            toggle.gameObject:RemoveTag( toggle.Group )
        end
        toggle:Check( false )
        toggle.Group = group
        toggle.gameObject:AddTag( toggle.Group )
    end
end

--- Get the toggle's group.
-- @param toggle (Toggle) The toggle component.
-- @return (string) The group, or nil.
function GUI.Toggle.GetGroup( toggle )
    return toggle.Group
end

--- Apply the content of the params argument to the provided toggle.
-- Overwrite Component.Set() from Daneel's CraftStudio file.
-- @param toggle (Toggle) The toggle component.
-- @param params (table) A table of parameters to set the component with.
function GUI.Toggle.Set( toggle, params )
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
end

local _toggle = { "toggle", "Toggle" }
table.mergein( Daneel.functionsDebugInfo, {
    ["GUI.Toggle.New"] =        { _go, _op },
    ["GUI.Toggle.Set"] =        { _toggle, _p },
    ["GUI.Toggle.SetText"] =    { _toggle, { "text", s } },
    ["GUI.Toggle.GetText"] =    { _toggle },
    ["GUI.Toggle.Check"] =      { _toggle, { "state", defaultValue = true }, { "forceUpdate", defaultValue = false } },
    ["GUI.Toggle.SetGroup"] =   { _toggle, { "group", s, isOptional = true } },
    ["GUI.Toggle.GetGroup"] =   { _toggle },
} )


----------------------------------------------------------------------------------
-- ProgressBar

GUI.ProgressBar = {}
GUI.ProgressBar.__index = GUI.ProgressBar

--- Creates a new GUI.ProgressBar.
-- @param gameObject (GameObject) The component gameObject.
-- @param params (table) [optional] A table of parameters.
-- @return (ProgressBar) The new component.
function GUI.ProgressBar.New( gameObject, params )
    local progressBar = table.copy( GUI.Config.progressBar )
    progressBar.gameObject = gameObject
    progressBar.id = Daneel.Utilities.GetId()
    progressBar.value = nil -- remove the property to allow to use the dynamic getter/setter
    setmetatable( progressBar, GUI.ProgressBar )
    params = params or {}
    if params.value == nil then
        params.value = GUI.Config.progressBar.value
    end
    progressBar:Set( params )
    gameObject.progressBar = progressBar
    return progressBar
end

--- Set the value of the progress bar, adjusting its length.
-- Fires the 'OnUpdate' event.
-- @param progressBar (ProgressBar) The progressBar.
-- @param value (number or string) The value as a number (between minVal and maxVal) or as a string and a percentage (between "0%" and "100%").
function GUI.ProgressBar.SetValue(progressBar, value)
    local errorHead = "GUI.ProgressBar.SetValue(progressBar, value) : "
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
end
GUI.ProgressBar.SetProgress = GUI.ProgressBar.SetValue

--- Set the value of the progress bar, adjusting its length.
-- Does the same things as SetProgress() by does it faster.
-- Unlike SetProgress(), does not fire the 'OnUpdate' event by default.
-- Should be used when the value is updated regularly (ie : from a Behavior:Update() function).
-- @param progressBar (ProgressBar) The progressBar.
-- @param value (number or string) The value as a number (between minVal and maxVal) or as a string and a percentage (between "0%" and "100%").
-- @param fireEvent (boolean) [default=false] Tell whether to fire the 'OnUpdate' event (true) or not (false).
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
GUI.ProgressBar.UpdateProgress = GUI.ProgressBar.UpdateValue

--- Get the current value of the progress bar.
-- @param progressBar (ProgressBar) The progressBar.
-- @param getAsPercentage (boolean) [default=false] Get the value as a percentage (between 0 and 100) instead of an absolute value.
-- @return (number) The value.
function GUI.ProgressBar.GetValue(progressBar, getAsPercentage)
    local scale = math.round( progressBar.gameObject.transform:GetLocalScale().x, 2 )
    local value = (scale - progressBar.minLength) / (progressBar.maxLength - progressBar.minLength)
    if getAsPercentage == true then
        value = value * 100
    else
        value = (progressBar.maxValue - progressBar.minValue) * value + progressBar.minValue
    end
    return value
end
GUI.ProgressBar.GetProgress = GUI.ProgressBar.GetValue

--- Set the height of the progress bar.
-- @param progressBar (ProgressBar) The progressBar.
-- @param height (number or string) Get the height in pixel or scene unit.
function GUI.ProgressBar.SetHeight( progressBar, height )
    local currentScale = progressBar.gameObject.transform:GetLocalScale()
    progressBar.gameObject.transform:SetLocalScale( Vector3:New( currentScale.x, GUI.ToSceneUnit( height ), currentScale.z ) )
end

--- Get the height of the progress bar (the local scale's y component).
-- @param progressBar (ProgressBar) The progressBar.
-- @return (number) The height.
function GUI.ProgressBar.GetHeight( progressBar )
    return progressBar.gameObject.transform:GetLocalScale().y
end

--- Apply the content of the params argument to the provided progressBar.
-- Overwrite Component.Set() from CraftStudio module.
-- @param progressBar (ProgressBar) The progressBar.
-- @param params (table) A table of parameters to set the component with.
function GUI.ProgressBar.Set( progressBar, params )
    local value = params.value
    params.value = nil
    if value == nil then
        value = progressBar:GetValue()
    end
    for key, value in pairs(params) do
        progressBar[key] = value
    end
    progressBar:SetValue( value )
end

local _pb = { "progressBar", "ProgressBar" }
table.mergein( Daneel.functionsDebugInfo, {
    ["GUI.ProgressBar.New"] =       { _go, _op },
    ["GUI.ProgressBar.Set"] =       { _pb, _p },
    ["GUI.ProgressBar.SetValue"] =  { _pb, { "value", { s, n } } },
    ["GUI.ProgressBar.GetValue"] =  { _pb, { "getAsPercentage", defaultValue = false } },
    ["GUI.ProgressBar.SetHeight"] = { _pb, { "height", { s, n } } },
    ["GUI.ProgressBar.GetHeight"] = { _pb },
} )


----------------------------------------------------------------------------------
-- Slider

GUI.Slider = {}
GUI.Slider.__index = GUI.Slider

---- Creates a new GUI.Slider.
-- @param gameObject (GameObject) The component gameObject.
-- @param params (table) [optional] A table of parameters.
-- @return (Slider) The new component.
function GUI.Slider.New( gameObject, params )
    params = params or {}
    getCameraGO( params, gameObject, "GUI.Slider.New()" )
    if Daneel.modules.MouseInput == nil then
        error( "GUI.Slider.New(): The 'Mouse Input' module is missing from your project. It is required for the player to interact with the GUI.Toggle, GUI.Input and GUI.Slider components." )
    end

    local slider = table.copy( GUI.Config.slider )
    slider.gameObject = gameObject
    slider.id = Daneel.Utilities.GetId()
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

        gameObject.transform:Move( positionDelta * slider.cameraGO.camera:GetPixelsToUnits() )

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
    return slider
end

--- Set the value of the slider, adjusting its position.
-- @param slider (Slider) The slider.
-- @param value (number or string) The value as a number (between minVal and maxVal) or as a string and a percentage (between "0%" and "100%").
function GUI.Slider.SetValue( slider, value )
    local errorHead = "GUI.Slider.SetValue( slider, value ) : "
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

    slider.length = GUI.ToSceneUnit( slider.length, slider.cameraGO.camera )

    local direction = -Vector3:Left()
    if slider.axis == "y" then
        direction = Vector3:Up()
    end
    local orientation = Vector3.Rotate( direction, slider.gameObject.transform:GetOrientation() )
    local newPosition = slider.parent.transform:GetPosition() + orientation * slider.length * percentage
    slider.gameObject.transform:SetPosition( newPosition )

    Daneel.Event.Fire( slider, "OnUpdate", slider )
end

--- Get the current slider's value.
-- @param slider (Slider) The slider.
-- @param getAsPercentage (boolean) [default=false] Get the value as a percentage (between 0 and 100) instead of an absolute value.
-- @return (number) The value.
function GUI.Slider.GetValue( slider, getAsPercentage )
    local percentage = Vector3.Distance( slider.parent.transform:GetPosition(), slider.gameObject.transform:GetPosition() ) / slider.length
    local value = percentage * 100
    if getAsPercentage ~= true then
        value = (slider.maxValue - slider.minValue) * percentage + slider.minValue
    end
    return value
end

--- Apply the content of the params argument to the provided slider.
-- Overwrite Component.Set() from the core.
-- @param slider (Slider) The slider.
-- @param params (table) A table of parameters to set the component with.
function GUI.Slider.Set( slider, params )
    local value = params.value
    params.value = nil
    if value == nil then
        value = slider:GetValue()
    end
    for key, value in pairs(params) do
        slider[key] = value
    end
    slider:SetValue( value )
end


----------------------------------------------------------------------------------
-- Input

GUI.Input = {}
GUI.Input.__index = GUI.Input

--- Creates a new GUI.Input.
-- @param gameObject (GameObject) The component gameObject.
-- @param params (table) [optional] A table of parameters.
-- @return (Input) The new component.
function GUI.Input.New( gameObject, params )
    if Daneel.modules.MouseInput == nil then
        error( "GUI.Input.New(): The 'Mouse Input' module is missing from your project. It is required for the player to interact with the GUI.Toggle, GUI.Input and GUI.Slider components." )
    end

    params = params or {}
    local input = table.merge( GUI.Config.input, params )
    input.gameObject = gameObject
    input.id = Daneel.Utilities.GetId()
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
    return input
end

--- Set the focused state of the input.
-- @param input (Input) The input component.
-- @param focus (boolean) [default=true] The new focus.
function GUI.Input.Focus( input, focus )
    focus = focus or true
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
end

--- Update the cursor of the input.
-- @param input (Input) The input component.
function GUI.Input.UpdateCursor( input )
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
end

--- Update the text of the input.
-- @param input (Input) The input component.
-- @param text (string) The text (often just one character) to add to the current text.
-- @param replaceText (boolean) [default=false] Tell whether the provided text should be added (false) or replace (true) the current text.
function GUI.Input.Update( input, text, replaceText )
    --if not type( input ) == "table" or not input.isFocused then  -- 10/06/2014 : when would input not be a table ?
        --return
    --end
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
end

local _slider = { "slider", "Slider" }
local _input = { "input", "Input" }
table.mergein( Daneel.functionsDebugInfo, {
    ["GUI.Slider.New"] =       { _go, _op },
    ["GUI.Slider.Set"] =       { _slider, _p },
    ["GUI.Slider.SetValue"] =  { _slider, { "value", { s, n } } },
    ["GUI.Slider.GetValue"] =  { _slider, { "getAsPercentage", defaultValue = false } },
    ["GUI.Input.New"] =          { _go, _op },
    ["GUI.Input.Focus"] =        { _input, { "focus", defaultValue = true } },
    ["GUI.Input.UpdateCursor"] = { _input },
    ["GUI.Input.Update"] =   { _input, { "text", s }, { "replaceText", defaultValue = true } },
} )


----------------------------------------------------------------------------------
-- TextArea

GUI.TextArea = {}
GUI.TextArea.__index = GUI.TextArea

--- Creates a new TextArea component.
-- @param gameObject (GameObject) The game object.
-- @param params (table) A table of parameters.
-- @return (TextArea) The new component.
function GUI.TextArea.New( gameObject, params )
    local textArea = {}
    textArea.gameObject = gameObject
    gameObject.textArea = textArea
    textArea.id = Daneel.Utilities.GetId()
    textArea.lineGOs = {}
    setmetatable( textArea, GUI.TextArea )
    textArea.textRuler = gameObject.textRenderer -- used to store the TextRenderer properties and mesure the lines length in SetText()
    if textArea.textRuler == nil then
        textArea.textRuler = gameObject:CreateComponent( "TextRenderer" ) 
    end
    textArea.textRuler:SetText( "" )
    textArea:Set( table.merge( GUI.Config.textArea, params ) )
    return textArea
end

--- Apply the content of the params argument to the provided textArea.
-- Overwrite Component.Set() from the core.
-- @param textArea (TextArea) The textArea.
-- @param params (table) A table of parameters to set the component with.
function GUI.TextArea.Set( textArea, params )
    local lineGOs = textArea.lineGOs
    textArea.lineGOs = {} -- prevent the every setters to update the text when they are called
    -- this is done once at the end
    local text = params.text
    params.text = nil
    for key, value in pairs( params ) do
        textArea[ key ] = value
    end
    textArea.lineGOs = lineGOs
    if text == nil then
        text = textArea.Text
    end
    textArea:SetText( text )
end

--- Set the component's text.
-- @param textArea (TextArea) The textArea component.
-- @param text (string) The text to display.
function GUI.TextArea.SetText( textArea, text )
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

    if type( textArea.linesFilter ) == "function" then
        lines = textArea.linesFilter( textArea, lines ) or lines
    end
    
    local linesCount = #lines
    local lineGOs = textArea.lineGOs
    local oldLinesCount = #lineGOs
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

    for i=1, linesCount do
        local line = lines[i]    
        textRendererParams.text = line

        if lineGOs[i] ~= nil then
            lineGOs[i].transform:SetLocalPosition( Vector3:New( 0, offset, 0 ) )
            lineGOs[i].textRenderer:Set( textRendererParams )
        else
            local newLineGO = CS.CreateGameObject( "TextArea" .. textArea.id .. "-Line" .. i, gameObject )
            newLineGO.transform:SetLocalPosition( Vector3:New( 0, offset, 0 ) )
            newLineGO.transform:SetLocalScale( Vector3:New(1) )
            newLineGO:CreateComponent( "TextRenderer" )
            newLineGO.textRenderer:Set( textRendererParams )
            table.insert( lineGOs, newLineGO )
        end

        offset = offset - lineHeight 
    end

    -- this new text has less lines than the previous one
    if linesCount < oldLinesCount then
        for i = linesCount + 1, oldLinesCount do
            lineGOs[i].textRenderer:SetText( "" ) -- don't destroy the line game object, just remove any text
        end
    end

    Daneel.Event.Fire( textArea, "OnUpdate", textArea )
end

--- Get the component's text.
-- @param textArea (TextArea) The textArea component.
-- @return (string) The component's text.
function GUI.TextArea.GetText( textArea )
    return textArea.Text
end

--- Add a line to the text area's text.
-- @param textArea (TextArea) The textArea component.
-- @param line (string) The line to add.
-- @param prepend (boolean) [default=false] If true, prepend the line to the text. Otherwise, append the line to the text.
function GUI.TextArea.AddLine( textArea, line, prepend )
    local text = textArea.Text
    if prepend == true then
        text = line..textArea.NewLine..text
    else
        if text ~= "" and not string.endswith( text, textArea.NewLine ) then
            line = textArea.NewLine..line
        end
        text = text..line
    end
    textArea:SetText( text )
end

--- Set the component's area width (maximum line length).
-- Must be strictly positive to have an effect.
-- Set as a negative value, 0 or nil to remove the limitation.
-- @param textArea (TextArea) The textArea component.
-- @param areaWidth (number or string) [optional] The area width in scene units or in pixels as a string suffixed with "px".
function GUI.TextArea.SetAreaWidth( textArea, areaWidth )
    areaWidth = math.clamp( GUI.ToSceneUnit( areaWidth ), 0, 999 )   
    if textArea.AreaWidth ~= areaWidth then
        textArea.AreaWidth = areaWidth
        if #textArea.lineGOs > 0 then
            textArea:SetText( textArea.Text )
        end
    end
end

--- Get the component's area width.
-- @param textArea (TextArea) The textArea component.
-- @return (number) The area width in scene units.
function GUI.TextArea.GetAreaWidth( textArea )
    return textArea.AreaWidth
end

--- Set the component's wordWrap property.
-- Define what happens when the lines are longer then the area width.
-- @param textArea (TextArea) The textArea component.
-- @param wordWrap (boolean) [default=false] Cut the line when false, or creates new additional lines with the remaining text when true.
function GUI.TextArea.SetWordWrap( textArea, wordWrap )
    if textArea.WordWrap ~= wordWrap then
        textArea.WordWrap = wordWrap
        if #textArea.lineGOs > 0 then
            textArea:SetText( textArea.Text )
        end
    end
end

--- Get the component's wordWrap property.
-- @param textArea (TextArea) The textArea component.
-- @return (boolean) True or false.
function GUI.TextArea.GetWordWrap( textArea )
    return textArea.WordWrap
end

--- Set the component's newLine string used by SetText() to split the input text in several lines.
-- @param textArea (TextArea) The textArea component.
-- @param newLine (string) The newLine string (one or several character long). Set "\n" to split multiline strings.
function GUI.TextArea.SetNewLine( textArea, newLine )
    if textArea.NewLine ~= newLine then
        textArea.NewLine = newLine
        if #textArea.lineGOs > 0 then
            textArea:SetText( textArea.Text )
        end
    end
end

--- Get the component's newLine string.
-- @param textArea (TextArea) The textArea component.
-- @return (string) The newLine string.
function GUI.TextArea.GetNewLine( textArea )
    return textArea.NewLine
end

--- Set the component's line height.
-- @param textArea (TextArea) The textArea component.
-- @param lineHeight (number or string) The line height in scene units or in pixels as a string suffixed with "px".
function GUI.TextArea.SetLineHeight( textArea, lineHeight )
    local lineHeight = GUI.ToSceneUnit( lineHeight )
    if textArea.LineHeight ~= lineHeight then
        textArea.LineHeight = lineHeight
        if #textArea.lineGOs > 0 then
            textArea:SetText( textArea.Text )
        end
    end
end

--- Get the component's line height.
-- @param textArea (TextArea) The textArea component.
-- @return (number) The line height in scene units.
function GUI.TextArea.GetLineHeight( textArea )
    return textArea.LineHeight
end

--- Set the component's vertical alignment.
-- @param textArea (TextArea) The textArea component.
-- @param verticalAlignment (string) "top", "middle" or "bottom". Case-insensitive.
function GUI.TextArea.SetVerticalAlignment( textArea, verticalAlignment )
    local errorHead = "GUI.TextArea.SetVerticalAlignment( textArea, verticalAlignment ) : "
    verticalAlignment = Daneel.Debug.CheckArgValue( verticalAlignment, "verticalAlignment", {"top", "middle", "bottom"}, errorHead, GUI.Config.textArea.verticalAlignment )
    verticalAlignment = string.trim( verticalAlignment:lower() )
    if textArea.VerticalAlignment ~= verticalAlignment then 
        textArea.VerticalAlignment = verticalAlignment
        if #textArea.lineGOs > 0 then
            textArea:SetText( textArea.Text )
        end
    end
end

--- Get the component's vertical alignment property.
-- @param textArea (TextArea) The textArea component.
-- @return (string) The vertical alignment.
function GUI.TextArea.GetVerticalAlignment( textArea )
    return textArea.VerticalAlignment
end

--- Set the component's font used to renderer the text.
-- @param textArea (TextArea) The textArea component.
-- @param font (Font or string) The font asset or fully-qualified path.
function GUI.TextArea.SetFont( textArea, font )
    textArea.textRuler:SetFont( font )
    font = textArea.textRuler:GetFont()
    if textArea.Font ~= font then
        textArea.Font = font
        if #textArea.lineGOs > 0 then
            for i=1, #textArea.lineGOs do
                textArea.lineGOs[i].textRenderer:SetFont( textArea.Font )
            end
            textArea:SetText( textArea.Text ) -- reset the text because the size of the text may have changed
        end
    end
end

--- Get the component's font used to render the text.
-- @param textArea (TextArea) The textArea component.
-- @return (Font) The font.
function GUI.TextArea.GetFont( textArea )
    return textArea.Font
end

--- Set the component's alignment.
-- Works like a TextRenderer alignment.
-- @param textArea (TextArea) The textArea component.
-- @param alignment (TextRenderer.Alignment or string) One of the values in the 'TextRenderer.Alignment' enum (Left, Center or Right) or the same values as case-insensitive string ("left", "center" or "right").
function GUI.TextArea.SetAlignment( textArea, alignment )
    textArea.textRuler:SetAlignment( alignment )
    alignment = textArea.textRuler:GetAlignment()
    if textArea.Alignment ~= alignment then
        textArea.Alignment = alignment
        for i=1, #textArea.lineGOs do
            textArea.lineGOs[i].textRenderer:SetAlignment( textArea.Alignment )
        end
    end
end

--- Get the component's horizontal alignment.
-- @param textArea (TextArea) The textArea component.
-- @return (TextRenderer.Alignment or number) The alignment (of type number in the webplayer).
function GUI.TextArea.GetAlignment( textArea )
    return textArea.Alignment
end

--- Set the component's opacity.
-- @param textArea (TextArea) The textArea component.
-- @param opacity (number) The opacity between 0.0 and 1.0.
function GUI.TextArea.SetOpacity( textArea, opacity )
    if textArea.Opacity ~= opacity then
        textArea.Opacity = opacity
        for i=1, #textArea.lineGOs do
            textArea.lineGOs[i].textRenderer:SetOpacity( opacity )
        end
    end
end

--- Get the component's opacity.
-- @param textArea (TextArea) The textArea component.
-- @return (number) The opacity between 0.0 and 1.0.
function GUI.TextArea.GetOpacity( textArea )
    return textArea.Opacity
end

local _ta = { "textArea", "TextArea" }
table.mergein( Daneel.functionsDebugInfo, {
    ["GUI.TextArea.New"] =                  { { "gameObject", go }, { "params", t, isOptional = true } },
    ["GUI.TextArea.Set"] =                  { _ta, _p },
    ["GUI.TextArea.SetText"] =              { _ta, { "text", s } },
    ["GUI.TextArea.GetText"] =              { _ta },
    ["GUI.TextArea.AddLine"] =              { _ta, { "line", s }, { "prepend", defaultValue = false } },
    ["GUI.TextArea.SetAreaWidth"] =         { _ta, { "areaWidth", { s, n }, defaultValue = 0 } },
    ["GUI.TextArea.GetAreaWidth"] =         { _ta },
    ["GUI.TextArea.SetWordWrap"] =          { _ta, { "wordWrap", defaultValue = false } },
    ["GUI.TextArea.GetWordWrap"] =          { _ta },
    ["GUI.TextArea.SetNewLine"] =           { _ta, { "newLine", s } },
    ["GUI.TextArea.GetNewLine"] =           { _ta },
    ["GUI.TextArea.SetLineHeight"] =        { _ta, { "lineHeight", { s, n } } },
    ["GUI.TextArea.GetLineHeight"] =        { _ta },
    ["GUI.TextArea.SetVerticalAlignment"] = { _ta, { "verticalAlignment", s } },
    ["GUI.TextArea.GetVerticalAlignment"] = { _ta },
    ["GUI.TextArea.SetFont"] =              { _ta, { "font", { s, "Font" } } },
    ["GUI.TextArea.GetFont"] =              { _ta },
    ["GUI.TextArea.SetAlignment"] =         { _ta, { "alignment", { s, "unserdata", n } } },
    ["GUI.TextArea.GetAlignment"] =         { _ta },
    ["GUI.TextArea.SetOpacity"] =           { _ta, { "opacity", n } },
    ["GUI.TextArea.GetOpacity"] =           { _ta },
} )


----------------------------------------------------------------------------------
-- Config - loading

Daneel.modules.GUI = GUI

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

        -- for the GameObject.Animate() functions in the Tween module
        propertiesByComponentName = {
            hud = {"position", "localPosition", "layer", "localLayer"},
            progressBar = {"value", "height"},
            slider = {"value"},
            textArea = {"areaWidth", "lineHeight", "opacity"},
        }
    }

    return config
end
GUI.Config = GUI.DefaultConfig()

function GUI.Load()
    if Daneel.modules.Tween then
        table.mergein( Tween.Config.propertiesByComponentName, GUI.Config.propertiesByComponentName )
    end
end
