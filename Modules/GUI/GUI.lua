-- GUI.lua
-- Module adding the GUI components and Vector2 object
--
-- Last modified for v1.2.0
-- Copyright © 2013 Florent POUJOL, published under the MIT licence.

GUI = { pixelsToUnits = 0 }

-- convert a string value (maybe in pixels)
-- into a number of units
local function tounit(value)
    if type(value) == "string" then
        local length = #value
        if value:endswith("px") then
            value = tonumber(value:sub(0, length-2)) * GUI.pixelsToUnits
        elseif value:endswith("u") then
            value = tonumber(value:sub(0, length-1))
        else
            value = tonumber(value)
        end
    end
    return value
end


----------------------------------------------------------------------------------
-- Init module

if CS.DaneelModules == nil then
    CS.DaneelModules = {}
end
CS.DaneelModules[ "GUI" ] = {}

function GUI.Config()
    local config = {
        screenSize = CraftStudio.Screen.GetSize(),
        cameraName = "HUDCamera",  -- Name of the gameObject who has the orthographic camera used to render the HUD
        cameraGO = nil, -- the corresponding GameObject, set at runtime
        originGO = nil, -- "parent" gameObject for global hud positioning, created at runtime in DaneelModuleGUIAwake
        originPosition = Vector3:New(0),

        -- Default GUI components settings
        hud = {
            localPosition = Vector2.New(0, 0),
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

            behaviorPath = "Daneel/Modules/GUI/Toggle",
        },

        progressBar = {
            height = 1,
            minValue = 0,
            maxValue = 100,
            minLength = 0,
            maxLength = 5, -- in units
            progress = "100%",
        },

        slider = {
            minValue = 0,
            maxValue = 100,
            length = 5, -- 5 units
            axis = "x",
            value = "0%",
            behaviorPath = "Daneel/Modules/GUI/Slider",
        },

        input = {
            isFocused = false,
            maxLength = 99999,
            characterRange = nil,
        },

        textArea = {
            areaWidth = 0, -- max line length, in units or pixel as a string (0 = no max length)
            wordWrap = false, -- when a ligne is longer than the area width: cut the ligne when false, put the rest of the ligne in one or several lignes when true
            newLine = "\n", -- end of ligne delimiter
            lineHeight = 1, -- in units or pixels as a string
            verticalAlignment = "top",

            font = nil,
            text = "Text\nArea",
            alignment = nil,
            opacity = nil,
        },
   
        componentObjects = {
            ["GUI.Hud"] = GUI.Hud,
            ["GUI.Toggle"] = GUI.Toggle,
            ["GUI.ProgressBar"] = GUI.ProgressBar,
            ["GUI.Slider"] = GUI.Slider,
            ["GUI.Input"] = GUI.Input,
            ["GUI.TextArea"] = GUI.TextArea,
        },

        objects = {
            Vector2 = Vector2,
        },
    }

    config.componentTypes = table.getkeys( config.componentObjects )

    Daneel.Config.allComponentObjects   = table.merge( Daneel.Config.allComponentObjects, config.componentObjects )
    Daneel.Config.allComponentTypes     = table.merge( Daneel.Config.allComponentTypes, config.componentTypes )
    Daneel.Config.allObjects            = table.merge( Daneel.Config.allObjects, config.componentObjects, config.objects )

    return config
end


function GUI.Load()

    --- Update the gameObject's scale to make the text appear the provided width.
    -- @param textRenderer (TextRenderer) The textRenderer.
    -- @param width (number or string) The text's width in units or pixels.
    function TextRenderer.SetTextWidth( textRenderer, width )
        Daneel.Debug.StackTrace.BeginFunction("TextRenderer.SetTextWidth", textRenderer, width)
        local errorHead = "TextRenderer.SetTextWidth(textRenderer, width) : "
        Daneel.Debug.CheckArgType(textRenderer, "textRenderer", "TextRenderer", errorHead)
        local argType = Daneel.Debug.CheckArgType(width, "width", {"number", "string"}, errorHead)

        if argType == "string" then
            width = tounit( width )
        end
        
        local widthScaleRatio = textRenderer:GetTextWidth() / textRenderer.gameObject.transform:GetScale()
        textRenderer.gameObject.transform:SetScale( width / widthScaleRatio )
        Daneel.Debug.StackTrace.EndFunction()
    end

end


function GUI.Awake()
    -- setting pixelToUnits  

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

        GUI.Config.originGO = GameObject.New( "HUDOrigin", { parent = GUI.Config.cameraGO } )
        GUI.Config.originGO.transform:SetLocalPosition( Vector3:New(
            -screenSize.x * GUI.pixelsToUnits / 2, 
            screenSize.y * GUI.pixelsToUnits / 2,
            0
        ) )
        -- the HUDOrigin is now at the top-left corner of the screen
        GUI.Config.originPosition = GUI.Config.originGO.transform:GetPosition()
    end
end


----------------------------------------------------------------------------------
-- Hud

GUI.Hud = {}

--- Transform the 3D position into a Hud position and a layer.
-- @param position (Vector3) The 3D position.
-- @return (Vector2) The hud position.
-- @return (numbe) The layer.
function GUI.Hud.ToHudPosition(position)
    Daneel.Debug.StackTrace.BeginFunction("GUI.Hud.ToHudPosition", position)
    local errorHead = "GUI.Hud.ToHudPosition(hud, position) : "
    Daneel.Debug.CheckArgType(position, "position", "Vector3", errorHead)

    local layer = GUI.Config.originPosition.z - position.z
    position = position - GUI.Config.originPosition
    position = Vector2(
        position.x / GUI.pixelsToUnits,
        -position.y / GUI.pixelsToUnits
    )
    Daneel.Debug.StackTrace.EndFunction()
    return position, layer
end

-- Create a new Hud component instance.
-- @param gameObject (GameObject) The gameObject to add to the component to.
-- @param params (table) [optional] A table of parameters.
-- @return (GUI.Hud) The hud component.
function GUI.Hud.New( gameObject, params )
    Daneel.Debug.StackTrace.BeginFunction("GUI.Hud.New", gameObject, params )
    if GUI.Config.cameraGO == nil then
        error("GUI was not set up or the HUD Camera gameObject with name '"..GUI.Config.cameraName.."' (value of 'cameraName' in the config) was not found.")
    end
    local errorHead = "GUI.Hud.New( gameObject, params ) : "
    Daneel.Debug.CheckArgType(gameObject, "gameObject", "GameObject", errorHead )
    params = Daneel.Debug.CheckOptionalArgType( params, "params", "table", errorHead, {} )

    local hud = setmetatable( {}, GUI.Hud )
    hud.gameObject = gameObject
    hud.Id = Daneel.Cache.GetId()
    gameObject.hud = hud

    hud:Set( table.merge( GUI.Config.hud, params ) )
    Daneel.Debug.StackTrace.EndFunction()
    return hud
end

--- Sets the position of the gameObject on screen.
-- With the top-left corner of the screen as origin.
-- @param hud (GUI.Hud) The hud component.
-- @param position (Vector2) The position as a Vector2.
function GUI.Hud.SetPosition(hud, position)
    Daneel.Debug.StackTrace.BeginFunction("GUI.Hud.SetPosition", hud, position)
    local errorHead = "GUI.Hud.SetPosition(hud, position) : "
    Daneel.Debug.CheckArgType(hud, "hud", "GUI.Hud", errorHead)
    Daneel.Debug.CheckArgType(position, "position", "Vector2", errorHead)

    local newPosition = GUI.Config.originPosition + 
    Vector3:New(
        position.x * GUI.pixelsToUnits,
        -position.y * GUI.pixelsToUnits,
        0
    )
    newPosition.z = hud.gameObject.transform.position.z
    hud.gameObject.transform.position = newPosition
    Daneel.Debug.StackTrace.EndFunction()
end

--- Get the position of the provided hud on the screen.
-- @param hud (GUI.Hud) The hud component.
-- @return (Vector2) The position.
function GUI.Hud.GetPosition(hud)
    Daneel.Debug.StackTrace.BeginFunction("GUI.Hud.GetPosition", hud)
    local errorHead = "GUI.Hud.GetPosition(hud) : "
    Daneel.Debug.CheckArgType(hud, "hud", "GUI.Hud", errorHead)
    
    local position = hud.gameObject.transform.position - GUI.Config.originPosition
    position = position / GUI.pixelsToUnits
    position = Vector2.New(math.round(position.x), math.round(-position.y))
    Daneel.Debug.StackTrace.EndFunction()
    return position
end

--- Sets the local position (relative to its parent) of the gameObject on screen .
-- @param hud (GUI.Hud) The hud component.
-- @param position (Vector2) The position as a Vector2.
function GUI.Hud.SetLocalPosition(hud, position)
    Daneel.Debug.StackTrace.BeginFunction("GUI.Hud.SetLocalPosition", hud, position)
    local errorHead = "GUI.Hud.SetLocalPosition(hud, position) : "
    Daneel.Debug.CheckArgType(hud, "hud", "GUI.Hud", errorHead)
    Daneel.Debug.CheckArgType(position, "position", "Vector2", errorHead)

    local parent = hud.gameObject.parent
    if parent == nil then parent = GUI.Config.originGO end
    local newPosition = parent.transform.position + 
    Vector3:New(
        position.x * GUI.pixelsToUnits,
        -position.y * GUI.pixelsToUnits,
        0
    )
    newPosition.z = hud.gameObject.transform.position.z
    hud.gameObject.transform.position = newPosition
    Daneel.Debug.StackTrace.EndFunction()
end

--- Get the local position (relative to its parent) of the gameObject on screen.
-- @param hud (GUI.Hud) The hud component.
-- @return (Vector2) The position.
function GUI.Hud.GetLocalPosition(hud)
    Daneel.Debug.StackTrace.BeginFunction("GUI.Hud.GetLocalPosition", hud)
    local errorHead = "GUI.Hud.GetLocalPosition(hud) : "
    Daneel.Debug.CheckArgType(hud, "hud", "GUI.Hud", errorHead)
    
    local parent = hud.gameObject.parent
    if parent == nil then parent = GUI.Config.originGO end
    local position = hud.gameObject.transform.position - parent.transform.position
    position = position / GUI.pixelsToUnits
    position = Vector2.New(math.round(position.x), math.round(-position.y))
    Daneel.Debug.StackTrace.EndFunction()
    return position
end

--- Set the gameObject's layer.
-- @param hud (GUI.Hud) The hud component.
-- @param layer (number) The layer (a postive number).
function GUI.Hud.SetLayer(hud, layer)
    Daneel.Debug.StackTrace.BeginFunction("GUI.Hud.SetLayer", hud)
    local errorHead = "GUI.Hud.SetLayer(hud, layer) : "
    Daneel.Debug.CheckArgType(hud, "hud", "GUI.Hud", errorHead)
    Daneel.Debug.CheckArgType(layer, "layer", "number", errorHead)

    local originLayer = GUI.Config.originPosition.z
    local currentPosition = hud.gameObject.transform.position
    hud.gameObject.transform.position = Vector3:New(currentPosition.x, currentPosition.y, originLayer-layer)
    Daneel.Debug.StackTrace.EndFunction()
end

--- Get the gameObject's layer.
-- @param hud (GUI.Hud) The hud component.
-- @return (number) The layer.
function GUI.Hud.GetLayer(hud)
    Daneel.Debug.StackTrace.BeginFunction("GUI.Hud.GetLayer", hud)
    local errorHead = "GUI.Hud.GetLyer(hud) : "
    Daneel.Debug.CheckArgType(hud, "hud", "GUI.Hud", errorHead)

    local originLayer = GUI.Config.originPosition.z
    local layer = originLayer - hud.gameObject.transform.position.z 
    Daneel.Debug.StackTrace.EndFunction()
    return layer
end

--- Set the huds's local layer.
-- @param hud (GUI.Hud) The hud component.
-- @param layer (number) The layer (a postiv number).
function GUI.Hud.SetLocalLayer(hud, layer)
    Daneel.Debug.StackTrace.BeginFunction("GUI.Hud.SetLayer", hud)
    local errorHead = "GUI.Hud.SetLayer(hud, layer) : "
    Daneel.Debug.CheckArgType(hud, "hud", "GUI.Hud", errorHead)
    Daneel.Debug.CheckArgType(layer, "layer", "number", errorHead)

    local parent = hud.gameObject.parent
    if parent == nil then parent = GUI.Config.originGO end
    local originLayer = parent.transform.position.z
    local currentPosition = hud.gameObject.transform.position
    hud.gameObject.transform.position = Vector3:New(currentPosition.x, currentPosition.y, originLayer-layer)
    Daneel.Debug.StackTrace.EndFunction()
end

--- Get the gameObject's layer which is actually the inverse of its local position's z component.
-- @param hud (GUI.Hud) The hud component.
-- @return (number) The layer.
function GUI.Hud.GetLocalLayer(hud)
    Daneel.Debug.StackTrace.BeginFunction("GUI.Hud.GetLayer", hud)
    local errorHead = "GUI.Hud.GetLyer(hud) : "
    Daneel.Debug.CheckArgType(hud, "hud", "GUI.Hud", errorHead)

    local parent = hud.gameObject.parent
    if parent == nil then parent = GUI.Config.originGO end
    local originLayer = parent.transform.position.z
    local layer = originLayer - hud.gameObject.transform.position.z 
    Daneel.Debug.StackTrace.EndFunction()
    return layer
end


----------------------------------------------------------------------------------
-- Toggle

GUI.Toggle = {}

-- Create a new Toggle component.
-- @param gameObject (GameObject) The component gameObject.
-- @param params (table) A table of parameters.
-- @return (GUI.Toggle) The new component.
function GUI.Toggle.New( gameObject, params )
    Daneel.Debug.StackTrace.BeginFunction( "GUI.Toggle.New", gameObject, params )
    local errorHead = "GUI.Toggle.New( gameObject, params ) : "
    Daneel.Debug.CheckArgType( gameObject, "gameObject", "GameObject", errorHead )
    params = Daneel.Debug.CheckOptionalArgType( params, "params", "table", errorHead, {} )
    
    local toggle = GUI.Config.toggle
    toggle.defaultText = toggle.text
    toggle.text = nil
    toggle.gameObject = gameObject
    toggle.Id = Daneel.Cache.GetId()
    setmetatable( toggle, GUI.Toggle )

    toggle:Set( params )    
    
    gameObject.toggle = toggle
    gameObject:AddTag( "guiComponent" )
    if gameObject:GetScriptedBehavior( GUI.Config.toggle.behaviorPath ) == nil then
        gameObject:AddScriptedBehavior( GUI.Config.toggle.behaviorPath )
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
-- @param toggle (GUI.Toggle) The toggle component.
-- @param text (string) The text to display.
function GUI.Toggle.SetText( toggle, text )
    Daneel.Debug.StackTrace.BeginFunction( "GUI.Toggle.SetText", toggle, text )
    local errorHead = "GUI.Toggle.SetText( toggle, text ) : "
    Daneel.Debug.CheckArgType( toggle, "toggle", "GUI.Toggle", errorHead )
    Daneel.Debug.CheckArgType( text, "text", "string", errorHead )

    if toggle.gameObject.textRenderer ~= nil then
        if toggle.isChecked == true then
            text = Daneel.Utilities.ReplaceInString( toggle.checkedMark, { text = text } )
        else
            text = Daneel.Utilities.ReplaceInString( toggle.uncheckedMark, { text = text } )
        end
        toggle.gameObject.textRenderer.text = text

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
-- @param toggle (GUI.Toggle) The toggle component.
-- @return (string) The text.
function GUI.Toggle.GetText(toggle)
    Daneel.Debug.StackTrace.BeginFunction("GUI.Toggle.GetText", toggle)
    local errorHead = "GUI.Toggle.GetText(toggle, text) : "
    Daneel.Debug.CheckArgType(toggle, "toggle", "GUI.Toggle", errorHead)

    local text = nil
    if toggle.gameObject.textRenderer ~= nil then
        local textMark = toggle.checkedMark
        if not toggle.isChecked then
            textMark = toggle.uncheckedMark
        end
        local start, _end = textMark:find(":text")
        local prefix = textMark:sub(1, start-1)
        local suffix = textMark:sub(_end+1)

        text = toggle.gameObject.textRenderer.text
        if text == nil then
            text = toggle.defaultText
        end
        text = text:gsub(prefix, ""):gsub(suffix, "")
    
    elseif Daneel.Config.debug.enableDebug then
        print("WARNING : "..errorHead.."Can't get the toggle's text because no TextRenderer component has been found on the gameObject '"..tostring(toggle.gameObject).."'. Returning nil.")
    end
    Daneel.Debug.StackTrace.EndFunction()
    return text
end 

--- Check or uncheck the provided toggle and fire the OnUpdate event.
-- You can get the toggle's state via toggle.isChecked.
-- @param toggle (GUI.Toggle) The toggle component.
-- @param state [optional default=true] (boolean) The new state of the toggle.
-- @param forceUpdate [optional default=false] (boolean) Tell wether to force the updating of the state.
function GUI.Toggle.Check( toggle, state, forceUpdate )
    Daneel.Debug.StackTrace.BeginFunction( "GUI.Toggle.Check", toggle, state, forceUpdate )
    local errorHead = "GUI.Toggle.Check( toggle[, state, forceUpdate] ) : "
    Daneel.Debug.CheckArgType( toggle, "toggle", "GUI.Toggle", errorHead )
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

        if toggle._group ~= nil and state == true then
            local gameObjects = GameObject.Tags[ toggle._group ]
            for i, gameObject in ipairs( gameObjects ) do
                if gameObject ~= toggle.gameObject then
                    gameObject.toggle:Check( false )
                end
            end
        end
    end
    
    Daneel.Debug.StackTrace.EndFunction()
end

--- Set the toggle's group.
-- If the toggle was already in a group it will be removed from it.
-- @param toggle (GUI.Toggle) The toggle component.
-- @param group [optional] (string) The new group, or nil to remove from its group.
function GUI.Toggle.SetGroup(toggle, group)
    Daneel.Debug.StackTrace.BeginFunction("GUI.Toggle.SetGroup", toggle, group)
    local errorHead = "GUI.Toggle.SetGroup(toggle[, group]) : "
    Daneel.Debug.CheckArgType(toggle, "toggle", "GUI.Toggle", errorHead)
    Daneel.Debug.CheckOptionalArgType(group, "group", "string", errorHead)

    if group == nil and toggle._group ~= nil then
        toggle.gameObject:RemoveTag(toggle._group)
    else
        if toggle._group ~= nil then
            toggle.gameObject:RemoveTag(toggle._group)
        end
        toggle:Check(false)
        toggle._group = group
        toggle.gameObject:AddTag(toggle._group)
    end
    Daneel.Debug.StackTrace.EndFunction()
end

-- Get the toggle's group.
-- @param toggle (GUI.Toggle) The toggle component.
-- @return (string) The group, or nil.
function GUI.Toggle.GetGroup(toggle)
    Daneel.Debug.StackTrace.BeginFunction("GUI.Toggle.GetGroup", toggle)
    local errorHead = "GUI.Toggle.GetGroup(toggle) : "
    Daneel.Debug.CheckArgType(toggle, "toggle", "GUI.Toggle", errorHead)
    Daneel.Debug.StackTrace.EndFunction()
    return toggle._group
end


----------------------------------------------------------------------------------
-- ProgressBar

GUI.ProgressBar = {}

-- Create a new GUI.ProgressBar.
-- @param gameObject (GameObject) The component gameObject.
-- @param params (table) A table of parameters.
-- @return (ProgressBar) The new component.
function GUI.ProgressBar.New( gameObject, params )
    Daneel.Debug.StackTrace.BeginFunction( "GUI.ProgressBar.New", gameObject, params )
    local errorHead = "GUI.ProgressBar.New( gameObject, params ) : "
    Daneel.Debug.CheckArgType( gameObject, "gameObject", "GameObject", errorHead )
    params = Daneel.Debug.CheckOptionalArgType( params, "params", "table", errorHead, {} )

    local progressBar = table.merge( GUI.Config.progressBar, params )
    progressBar.gameObject = gameObject
    progressBar.Id = Daneel.Cache.GetId()
    progressBar.progress = nil -- remove the property to allow to use the dynamic getter/setter
    setmetatable( progressBar, GUI.ProgressBar )
    progressBar.progress = GUI.Config.progressBar.progress
    
    gameObject.progressBar = progressBar

    Daneel.Debug.StackTrace.EndFunction()
    return progressBar
end

--- Set the progress of the progress bar, adjusting its length.
-- Fires the 'OnUpdate' event.
-- @param progressBar (ProgressBar) The progressBar.
-- @param progress (number or string) The progress as a number (between minVal and maxVal) or as a string and a percentage (between "0%" and "100%").
function GUI.ProgressBar.SetProgress(progressBar, progress)
    Daneel.Debug.StackTrace.BeginFunction("GUI.ProgressBar.SetProgress", progressBar, progress)
    local errorHead = "GUI.ProgressBar.SetProgress(progressBar, progress) : "
    Daneel.Debug.CheckArgType(progressBar, "progressBar", "GUI.ProgressBar", errorHead)
    Daneel.Debug.CheckArgType(progress, "progress", {"string", "number"}, errorHead)

    local minVal = progressBar.minValue
    local maxVal = progressBar.maxValue
    local percentageOfProgress = nil

    if type(progress) == "string" then
        if progress:endswith("%") then
            percentageOfProgress = tonumber(progress:sub(1, #progress-1)) / 100

            local oldPercentage = percentageOfProgress
            percentageOfProgress = math.clamp(percentageOfProgress, 0.0, 1.0)
            if percentageOfProgress ~= oldPercentage and Daneel.Config.debug.enableDebug then
                print(errorHead.."WARNING : progress in percentage with value '"..progress.."' is below 0% or above 100%.")
            end

            progress = (maxVal - minVal) * percentageOfProgress + minVal
        else
            progress = tonumber(progress)
        end
    end

    -- now progress is a number and should be a value between minVal and maxVal
    local oldProgress = progress
    progress = math.clamp(progress, minVal, maxVal)

    progressBar.minLength = tounit(progressBar.minLength)
    progressBar.maxLength = tounit(progressBar.maxLength)
    local currentProgress = progressBar.progress

    if progress ~= currentProgress then
        if progress ~= oldProgress and Daneel.Config.debug.enableDebug then
            print(errorHead.." WARNING : progress with value '"..oldProgress.."' is out of its boundaries : min='"..minVal.."', max='"..maxVal.."'")
        end
        percentageOfProgress = (progress - minVal) / (maxVal - minVal)
        
        progressBar.height = tounit(progressBar.height)

        local newLength = (progressBar.maxLength - progressBar.minLength) * percentageOfProgress + progressBar.minLength 
        local currentScale = progressBar.gameObject.transform.localScale
        progressBar.gameObject.transform.localScale = Vector3:New(newLength, progressBar.height, currentScale.z)
        -- newLength = scale only because the base size of the model is of one unit at a scale of one

        Daneel.Event.Fire(progressBar, "OnUpdate", progressBar)
    end
    Daneel.Debug.StackTrace.EndFunction()
end

--- Set the progress of the progress bar, adjusting its length.
-- Does the same things as SetProgress() by does it faster. 
-- Unlike SetProgress(), does not fire the 'OnUpdate' event by default.
-- Should be used when the progress is updated regularly (ie : from a Behavior:Update() function).
-- @param progressBar (ProgressBar) The progressBar.
-- @param progress (number or string) The progress as a number (between minVal and maxVal) or as a string and a percentage (between "0%" and "100%").
-- @param fireEvent [optional default=false] (boolean) Tell wether to fire the 'OnUpdate' event (true) or not (false).
function GUI.ProgressBar.UpdateProgress( progressBar, progress, fireEvent )
    if progress == progressBar._progress then return end
    progressBar._progress = progress

    local minVal = progressBar.minValue
    local maxVal = progressBar.maxValue
    local minLength = progressBar.minLength
    local percentageOfProgress = nil

    if type(progress) == "string" then
        local _progress = progress
        progress = tonumber(progress)
        if progress == nil then -- progress in percentage. ie "50%"
            percentageOfProgress = tonumber( _progress:sub( 1, #_progress-1 ) ) / 100
        end
    end

    if percentageOfProgress == nil then
        percentageOfProgress = (progress - minVal) / (maxVal - minVal)
    end
    percentageOfProgress = math.clamp( percentageOfProgress, 0.0, 1.0 )

    local newLength = (progressBar.maxLength - minLength) * percentageOfProgress + minLength 
    local currentScale = progressBar.gameObject.transform.localScale
    progressBar.gameObject.transform.localScale = Vector3:New( newLength, progressBar.height, currentScale.z )
    
    if fireEvent == true then
        Daneel.Event.Fire( progressBar, "OnUpdate", progressBar )
    end
end

--- Get the current progress of the progress bar.
-- @param progressBar (ProgressBar) The progressBar.
-- @param getAsPercentage [optional default=false] (boolean) Get the progress as a percentage (between 0 and 100) instead of an absolute value.
-- @return (number) The progress.
function GUI.ProgressBar.GetProgress(progressBar, getAsPercentage)
    Daneel.Debug.StackTrace.BeginFunction("GUI.ProgressBar.GetProgress", progressBar, getAsPercentage)
    local errorHead = "GUI.ProgressBar.GetProgress(progressBar[, getAsPercentage]) : "
    Daneel.Debug.CheckArgType(progressBar, "progressBar", "GUI.ProgressBar", errorHead)
    Daneel.Debug.CheckOptionalArgType(getAsPercentage, "getAsPercentage", "boolean", errorHead)

    local scale = progressBar.gameObject.transform.localScale.x
    local progress = (scale - progressBar.minLength) / (progressBar.maxLength - progressBar.minLength)
    if getAsPercentage == true then
        progress = progress * 100
    else
        progress = (progressBar.maxValue - progressBar.minValue) * progress + progressBar.minValue
    end
    progress = math.round(progress)
    Daneel.Debug.StackTrace.EndFunction()
    return progress
end


----------------------------------------------------------------------------------
-- Slider

GUI.Slider = {}

-- Create a new GUI.Slider.
-- @param gameObject (GameObject) The component gameObject.
-- @param params (table) A table of parameters.
-- @return (GUI.Slider) The new component.
function GUI.Slider.New( gameObject, params )
    Daneel.Debug.StackTrace.BeginFunction( "GUI.Slider.New", gameObject, params )
    local errorHead = "GUI.Slider.New( gameObject, params ) : "
    Daneel.Debug.CheckArgType( gameObject, "gameObject", "GameObject", errorHead )
    params = Daneel.Debug.CheckOptionalArgType( params, "params", "table", errorHead, {} )

    local slider = table.merge( GUI.Config.slider, params )
    slider.gameObject = gameObject
    slider.Id = Daneel.Cache.GetId()
    slider.startPosition = gameObject.transform.position
    slider.value = nil
    setmetatable( slider, GUI.Slider )
    slider.value = GUI.Config.slider.value
    
    gameObject.slider = slider
    gameObject:AddTag( "guiComponent" )
    if gameObject:GetScriptedBehavior( GUI.Config.slider.behaviorPath ) == nil then
        gameObject:AddScriptedBehavior( GUI.Config.slider.behaviorPath )
    end
    
    Daneel.Debug.StackTrace.EndFunction()
    return slider
end

--- Set the value of the slider, adjusting its position.
-- @param slider (GUI.Slider) The slider.
-- @param value (number or string) The value as a number (between minVal and maxVal) or as a string and a percentage (between "0%" and "100%").
function GUI.Slider.SetValue( slider, value )
    Daneel.Debug.StackTrace.BeginFunction( "GUI.Slider.SetValue", slider, value )
    local errorHead = "GUI.Slider.SetValue( slider, value ) : "
    Daneel.Debug.CheckArgType( slider, "slider", "GUI.Slider", errorHead )
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

    slider.length = tounit( slider.length )

    local direction = -Vector3:Left()
    if slider.axis == "y" then
        direction = Vector3:Up()
    end
    local orientation = Vector3.Transform( direction, slider.gameObject.transform.orientation )
    local newPosition = slider.startPosition + orientation * slider.length * percentage
    slider.gameObject.transform.position = newPosition

    Daneel.Event.Fire( slider, "OnUpdate", slider )
    Daneel.Debug.StackTrace.EndFunction()
end

--- Get the current slider's value.
-- @param slider (GUI.Slider) The slider.
-- @param getAsPercentage [optional default=false] (boolean) Get the value as a percentage (between 0 and 100) instead of an absolute value.
-- @return (number) The value.
function GUI.Slider.GetValue( slider, getAsPercentage )
    Daneel.Debug.StackTrace.BeginFunction( "GUI.Slider.GetValue", slider, getAsPercentage )
    local errorHead = "GUI.Slider.GetValue( slider, value ) : "
    Daneel.Debug.CheckArgType(slider, "slider", "GUI.Slider", errorHead)
    Daneel.Debug.CheckOptionalArgType( getAsPercentage, "getAsPercentage", "boolean", errorHead )
   
    local percentage = Vector3.Distance( slider.startPosition, slider.gameObject.transform.position ) / slider.length
    local value = percentage * 100
    if getAsPercentage ~= true then
        value = (slider.maxValue - slider.minValue) * percentage + slider.minValue
    end
    
    Daneel.Debug.StackTrace.EndFunction()
    return value
end


----------------------------------------------------------------------------------
-- Input

GUI.Input = {}

-- Create a new GUI.Input.
-- @param gameObject (GameObject) The component gameObject.
-- @param params (table) A table of parameters.
-- @return (GUI.Input) The new component.
function GUI.Input.New( gameObject, params )
    Daneel.Debug.StackTrace.BeginFunction( "GUI.Input.New", gameObject, params )
    local errorHead = "GUI.Input.New( gameObject, params ) : "
    Daneel.Debug.CheckArgType( gameObject, "gameObject", "GameObject", errorHead )
    params = Daneel.Debug.CheckOptionalArgType( params, "params", "table", errorHead, {} )

    local input = table.merge( GUI.Config.input, params )
    input.gameObject = gameObject
    input.Id = Daneel.Cache.GetId()
    -- adapted from Blast Turtles
    input.OnTextEntered = function( char )
        if not input.isFocused then return end
        local charNumber = string.byte( char )
        
        if charNumber == 8 then -- Backspace
            local text = gameObject.textRenderer.text
            input:Update( text:sub( 1, #text - 1 ), true )
        
        elseif charNumber == 13 then -- Enter
            Daneel.Event.Fire( input, "OnValidate", input )
        
        -- Any character between 32 and 127 is regular printable ASCII
        elseif charNumber >= 32 and charNumber <= 127 then
            if input.characterRange ~= nil and input.characterRange:find( char, 1, true ) == nil then
                return
            end
            input:Update( char )
        end
    end
    setmetatable( input, GUI.Input )

    gameObject.input = input
    gameObject:AddTag( "guiComponent" )
    
    Daneel.Event.Listen( "OnLeftMouseButtonJustPressed", 
        function()
            if gameObject.isMouseOver == nil then
                gameObject.isMouseOver = false
            end
            gameObject.input:Focus( gameObject.isMouseOver )
        end 
    )

    Daneel.Debug.StackTrace.EndFunction()
    return input
end

-- Set the focused state of the input.
-- @param input (GUI.Input) The input component.
-- @param state [optional default=true] (boolean) The new state.
function GUI.Input.Focus( input, state )
    Daneel.Debug.StackTrace.BeginFunction( "GUI.Input.Focus", input, state )
    local errorHead = "GUI.Input.Focus(input[, state]) : "
    Daneel.Debug.CheckArgType( input, "input", "GUI.Input", errorHead )
    state = Daneel.Debug.CheckOptionalArgType( state, "state", "boolean", errorHead, true )
    
    if input.isFocused ~= state then
        input.isFocused = state
        if state == true then
            CS.Input.OnTextEntered( input.OnTextEntered )
        else
            CS.Input.OnTextEntered( nil )
        end
        Daneel.Event.Fire( input, "OnFocus", input )
    end
    Daneel.Debug.StackTrace.EndFunction()
end

-- Set the focused state of the input.
-- @param input (GUI.Input) The input component.
-- @param text (string) The text to add to the current text.
-- @param replaceText [optional default=false] (boolean) Tell wether the provided text should be added (false) or replace (true) the current text.
function GUI.Input.Update( input, text, replaceText )
    Daneel.Debug.StackTrace.BeginFunction("GUI.Input.Update", input, text)
    local errorHead = "GUI.Input.Update(input, text) : "
    Daneel.Debug.CheckArgType(input, "input", "GUI.Input", errorHead)
    Daneel.Debug.CheckArgType(text, "text", "string", errorHead)
    replaceText = Daneel.Debug.CheckOptionalArgType(replaceText, "replaceText", "boolean", errorHead, false)

    if input.isFocused == false then 
        Daneel.Debug.StackTrace.EndFunction()
        return
    end
    
    local oldText = input.gameObject.textRenderer.text
    if replaceText == false then
        text = oldText .. text
    end
    if #text > input.maxLength then
        text = text:sub( 1, input.maxLength )
    end
    if oldText ~= text then
        input.gameObject.textRenderer.text = text
        Daneel.Event.Fire( input, "OnUpdate", input )
    end
    Daneel.Debug.StackTrace.EndFunction()
end


----------------------------------------------------------------------------------
-- TextArea

GUI.TextArea = {}

--- Creates a new TextArea component.
-- @param gameObject (GameObject) The game object.
-- @param params (table) A table of parameters.
-- @return (GUI.TextArea) The new component.
function GUI.TextArea.New( gameObject, params )
    Daneel.Debug.StackTrace.BeginFunction( "GUI.TextArea.New", gameObject, params )
    local errorHead = "GUI.TextArea.New( gameObject, params ) : "
    Daneel.Debug.CheckArgType( gameObject, "gameObject", "GameObject", errorHead )
    params = Daneel.Debug.CheckOptionalArgType( params, "params", "table", errorHead, {} )

    local textArea = {}
    textArea.gameObject = gameObject
    textArea.Id = Daneel.Cache.GetId()
    textArea.lineRenderers = {}
    setmetatable( textArea, GUI.TextArea )

    gameObject:AddComponent( "TextRenderer" ) -- used to store the TextRenderer properties and mesure the lines length in SetText()
    textArea:Set( table.merge( GUI.Config.textArea, params ) )

    gameObject.textArea = textArea
    Daneel.Debug.StackTrace.EndFunction()
    return textArea
end

--- Set the component's text.
-- @param textArea (GUI.TextArea) The textArea component.
-- @param text (string) The text to display.
function GUI.TextArea.SetText( textArea, text )
    Daneel.Debug.StackTrace.BeginFunction( "GUI.TextArea.SetText", textArea, text )
    local errorHead = "GUI.TextArea.SetText( textArea, text ) : "
    Daneel.Debug.CheckArgType( textArea, "textArea", "GUI.TextArea", errorHead )
    Daneel.Debug.CheckArgType( text, "text", "string", errorHead )

    textArea.Text = text

    local lines = { text }
    if textArea.newLine ~= "" then
        lines = text:split( textArea.NewLine )
    end

    -- areaWidth is the max length in units of each line
    local areaWidth = textArea.AreaWidth
    if areaWidth ~= nil and areaWidth > 0 then
        -- cut the lines based on their length
        local tempLines = table.copy( lines )
        lines = {}

        for i = 1, #tempLines do
            local line = tempLines[i]
            
            if textArea.gameObject.textRenderer:GetTextWidth( line ) > areaWidth then
                line = line:totable()
                local newLine = {}
                
                for j, char in ipairs( line ) do
                    table.insert( newLine, char )

                    if textArea.gameObject.textRenderer:GetTextWidth( table.concat( newLine ) ) > areaWidth then  
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
    local lineHeight = textArea.LineHeight
    local gameObject = textArea.gameObject
    local textRendererParams = {
        font = textArea.Font,
        alignment = textArea.Alignment,
        opacity = textArea.Opacity,
    }

    -- calculate position offset based on vertical alignment and number of lines
    local offset = -lineHeight / 2 -- verticalAlignment = "top"
    if textArea.VerticalAlignment == "middle" then
        offset = lineHeight * linesCount / 2 - lineHeight / 2
    elseif textArea.VerticalAlignment == "bottom" then
        offset = lineHeight * linesCount
    end

    for i, line in ipairs( lines ) do
        textRendererParams.text = line

        if lineRenderers[i] ~= nil then
            lineRenderers[i].gameObject.transform:SetLocalPosition( Vector3:New( 0, offset, 0 ) )
            lineRenderers[i]:SetText( line )
        else
            local newLineGO = GameObject.New( "TextAreaLine-" .. textArea.Id .. "-" .. i, {
                parent = gameObject,
                transform = {
                    localPosition = Vector3:New( 0, offset, 0 )
                },
                textRenderer = textRendererParams
            })

            table.insert( lineRenderers, newLineGO.textRenderer )
        end

        offset = offset - textArea.lineHeight
    end

    -- this new text as less lines than the previous one
    if lineRenderersCount > linesCount then
        for i = linesCount + 1, lineRenderersCount do
            lineRenderers[i]:SetText( "" )
        end
    end

    Daneel.Event.Fire( textArea, "OnUpdate", textArea)
    
    Daneel.Debug.StackTrace.EndFunction()
end

--- Get the component's text.
-- @param textArea (GUI.TextArea) The textArea component.
-- @return (string) The component's text.
function GUI.TextArea.GetText( textArea )
    local errorHead = "GUI.TextArea.GetText( textArea ) : "
    Daneel.Debug.CheckArgType( textArea, "textArea", "GUI.TextArea", errorHead )
    return textArea.Text
end

--- Set the component's area width (maximum line length).
-- Must be strictly positive to have an effect.
-- Set as a negative value, 0 or nil to remove the limitation.
-- @param textArea (GUI.TextArea) The textArea component.
-- @param areaWidth (number or string) The area width in scene units or in pixels as a string suffixed with "px".
function GUI.TextArea.SetAreaWidth( textArea, areaWidth )
    Daneel.Debug.StackTrace.BeginFunction( "GUI.TextArea.SetAreaWidth", textArea, areaWidth )
    local errorHead = "GUI.TextArea.SetAreaWidth( textArea, areaWidth ) : "
    Daneel.Debug.CheckArgType( textArea, "textArea", "GUI.TextArea", errorHead )
    Daneel.Debug.CheckOptionalArgType( areaWidth, "areaWidth", {"string", "number"}, errorHead )

    if areaWidth ~= nil then
        areaWidth = math.clamp( tounit( areaWidth ), 0, 999999 )
    end

    if textArea.AreaWidth ~= areaWidth then
        textArea.AreaWidth = areaWidth
        if #textArea.lineRenderers > 0 then
            textArea:SetText( textArea.Text )
        end
    end
    Daneel.Debug.StackTrace.EndFunction()
end

--- Get the component's area width.
-- @param textArea (GUI.TextArea) The textArea component.
-- @return (number) The area width in scene units.
function GUI.TextArea.GetAreaWidth( textArea )
    local errorHead = "GUI.TextArea.GetAreaWidth( textArea ) : "
    Daneel.Debug.CheckArgType( textArea, "textArea", "GUI.TextArea", errorHead )
    return textArea.AreaWidth
end

--- Set the component's wordWrap property.
-- Define what happens when the lines are longer then the area width.
-- @param textArea (GUI.TextArea) The textArea component.
-- @param wordWrap (boolean) Cut the line when false, or creates new additional lines with the remaining text when true.
function GUI.TextArea.SetWordWrap( textArea, wordWrap )
    Daneel.Debug.StackTrace.BeginFunction( "GUI.TextArea.SetWordWrap", textArea, wordWrap )
    local errorHead = "GUI.TextArea.SetWordWrap( textArea, wordWrap ) : "
    Daneel.Debug.CheckArgType( textArea, "textArea", "GUI.TextArea", errorHead )
    Daneel.Debug.CheckArgType( wordWrap, "wordWrap", "boolean", errorHead )

    textArea.WordWrap = wordWrap
    if #textArea.lineRenderers > 0 then
        textArea:SetText( textArea.Text )
    end
    Daneel.Debug.StackTrace.EndFunction()
end

--- Get the component's wordWrap property.
-- @param textArea (GUI.TextArea) The textArea component.
-- @return (boolean) True or false.
function GUI.TextArea.GetWordWrap( textArea )
    local errorHead = "GUI.TextArea.GetWordWrap( textArea ) : "
    Daneel.Debug.CheckArgType( textArea, "textArea", "GUI.TextArea", errorHead )
    return textArea.WordWrap
end

--- Set the component's newLine string used by SetText() to split the input text in several lines.
-- @param textArea (GUI.TextArea) The textArea component.
-- @param newLine (string) The newLine string (one or several character long). Set "\n" to split multiline strings.
function GUI.TextArea.SetNewLine( textArea, newLine )
    Daneel.Debug.StackTrace.BeginFunction( "GUI.TextArea.SetNewLine", textArea, newLine )
    local errorHead = "GUI.TextArea.SetNewLine( textArea, newLine ) : "
    Daneel.Debug.CheckArgType( textArea, "textArea", "GUI.TextArea", errorHead )
    Daneel.Debug.CheckArgType( newLine, "newLine", "string", errorHead )

    textArea.NewLine = newLine
    if #textArea.lineRenderers > 0 then
        textArea:SetText( textArea.Text )
    end
    Daneel.Debug.StackTrace.EndFunction()
end

--- Get the component's newLine string.
-- @param textArea (GUI.TextArea) The textArea component.
-- @return (string) The newLine string.
function GUI.TextArea.GetNewLine( textArea )
    local errorHead = "GUI.TextArea.GetNewLine( textArea ) : "
    Daneel.Debug.CheckArgType( textArea, "textArea", "GUI.TextArea", errorHead )
    return textArea.NewLine
end

--- Set the component's line height.
-- @param textArea (GUI.TextArea) The textArea component.
-- @param lineHeight (number or string) The line height in scene units or in pixels as a string suffixed with "px".
function GUI.TextArea.SetLineHeight( textArea, lineHeight )
    Daneel.Debug.StackTrace.BeginFunction( "GUI.TextArea.SetLineHeight", textArea, lineHeight )
    local errorHead = "GUI.TextArea.SetLineHeight( textArea, lineHeight ) : "
    Daneel.Debug.CheckArgType( textArea, "textArea", "GUI.TextArea", errorHead )
    Daneel.Debug.CheckArgType( lineHeight, "lineHeight", {"string", "number"}, errorHead )

    textArea.LineHeight = tounit( lineHeight )
    if #textArea.lineRenderers > 0 then
        textArea:SetText( textArea.Text )
    end
    Daneel.Debug.StackTrace.EndFunction()
end

--- Get the component's line height.
-- @param textArea (GUI.TextArea) The textArea component.
-- @return (number) The line height in scene units.
function GUI.TextArea.GetLineHeight( textArea )
    local errorHead = "GUI.TextArea.GetLineHeight( textArea ) : "
    Daneel.Debug.CheckArgType( textArea, "textArea", "GUI.TextArea", errorHead )
    return textArea.LineHeight
end

--- Set the component's vertical alignment.
-- @param textArea (GUI.TextArea) The textArea component.
-- @param verticalAlignment (string) "top", "middle" or "bottom". Case-insensitive.
function GUI.TextArea.SetVerticalAlignment( textArea, verticalAlignment )
    Daneel.Debug.StackTrace.BeginFunction( "GUI.TextArea.SetVerticalAlignment", textArea, verticalAlignment )
    local errorHead = "GUI.TextArea.SetVerticalAlignment( textArea, verticalAlignment ) : "
    Daneel.Debug.CheckArgType( textArea, "textArea", "GUI.TextArea", errorHead )
    Daneel.Debug.CheckArgType( verticalAlignment, "verticalAlignment", "string", errorHead )
    verticalAlignment = Daneel.Debug.CheckArgValue( verticalAlignment, "verticalAlignment", {"top", "middle", "bottom"}, errorHead, "top" )

    textArea.VerticalAlignment = verticalAlignment:lower():trim()
    if #textArea.lineRenderers > 0 then
        textArea:SetText( textArea.Text )
    end
    Daneel.Debug.StackTrace.EndFunction()
end

--- Get the component's vertical alignment property.
-- @param textArea (GUI.TextArea) The textArea component.
-- @return (string) The vertical alignment.
function GUI.TextArea.GetVerticalAlignment( textArea )
    local errorHead = "GUI.TextArea.GetVerticalAlignment( textArea ) : "
    Daneel.Debug.CheckArgType( textArea, "textArea", "GUI.TextArea", errorHead )
    return textArea.VerticalAlignment
end

--- Set the component's font used to renderer the text.
-- @param textArea (GUI.TextArea) The textArea component.
-- @param font (Font or string) The font asset or fully-qualified path.
function GUI.TextArea.SetFont( textArea, font )
    Daneel.Debug.StackTrace.BeginFunction( "GUI.TextArea.SetFont", textArea, font )
    local errorHead = "GUI.TextArea.SetFont( textArea, font ) : "
    Daneel.Debug.CheckArgType( textArea, "textArea", "GUI.TextArea", errorHead )
    Daneel.Debug.CheckArgType( font, "font", {"string", "Font"}, errorHead )

    textArea.gameObject.textRenderer:SetFont( font )
    textArea.Font = textArea.gameObject.textRenderer:GetFont()

    if #textArea.lineRenderers > 0 then
        for i, textRenderer in ipairs( textArea.lineRenderers ) do
            textRenderer:SetFont( textArea.Font )
        end
    end
    Daneel.Debug.StackTrace.EndFunction()
end

--- Get the component's font used to render the text.
-- @param textArea (GUI.TextArea) The textArea component.
-- @return (Font) The font.
function GUI.TextArea.GetFont( textArea )
    local errorHead = "GUI.TextArea.GetFont( textArea ) : "
    Daneel.Debug.CheckArgType( textArea, "textArea", "GUI.TextArea", errorHead )
    return textArea.Font
end

--- Set the component's alignment.
-- Works like a TextRenderer alignment.
-- @param textArea (GUI.TextArea) The textArea component.
-- @param alignment (TextRenderer.Alignment or string) One of the values in the 'TextRenderer.Alignment' enum (Left, Center or Right) or the same values as case-insensitive string ("left", "center" or "right").
function GUI.TextArea.SetAlignment( textArea, alignment )
    Daneel.Debug.StackTrace.BeginFunction( "GUI.TextArea.SetAlignment", textArea, alignment )
    local errorHead = "GUI.TextArea.SetAlignment( textArea, alignment ) : "
    Daneel.Debug.CheckArgType( textArea, "textArea", "GUI.TextArea", errorHead )
    Daneel.Debug.CheckArgType( alignment, "alignment", {"string", "userdata"}, errorHead )

    textArea.gameObject.textRenderer:SetAlignment( alignment )
    textArea.Alignment = textArea.gameObject.textRenderer:GetAlignment()

    if #textArea.lineRenderers > 0 then
        for i, textRenderer in ipairs( textArea.lineRenderers ) do
            textRenderer:SetAlignment( textArea.Alignment )
        end
    end
    Daneel.Debug.StackTrace.EndFunction()
end

--- Get the component's horizontal alignment.
-- @param textArea (GUI.TextArea) The textArea component.
-- @return (TextRenderer.Alignment) The alignment.
function GUI.TextArea.GetAlignment( textArea )
    local errorHead = "GUI.TextArea.GetAlignment( textArea ) : "
    Daneel.Debug.CheckArgType( textArea, "textArea", "GUI.TextArea", errorHead )
    return textArea.Alignment
end

--- Set the component's opacity.
-- @param textArea (GUI.TextArea) The textArea component.
-- @param opacity (number) The opacity between 0.0 and 1.0.
function GUI.TextArea.SetOpacity( textArea, opacity )
    Daneel.Debug.StackTrace.BeginFunction( "GUI.TextArea.SetOpacity", textArea, opacity )
    local errorHead = "GUI.TextArea.SetOpacity( textArea, opacity ) : "
    Daneel.Debug.CheckArgType( textArea, "textArea", "GUI.TextArea", errorHead )
    Daneel.Debug.CheckArgType( opacity, "opacity", "number", errorHead )

    textArea.Opacity = opacity
    if #textArea.lineRenderers > 0 then
        for i, textRenderer in ipairs( textArea.lineRenderers ) do
            textRenderer:SetOpacity( opacity )
        end
    end
    Daneel.Debug.StackTrace.EndFunction()
end

--- Get the component's opacity.
-- @param textArea (GUI.TextArea) The textArea component.
-- @return (number) The opacity between 0.0 and 1.0.
function GUI.TextArea.GetOpacity( textArea )
    local errorHead = "GUI.TextArea.GetOpacity( textArea ) : "
    Daneel.Debug.CheckArgType( textArea, "textArea", "GUI.TextArea", errorHead )
    return textArea.Opacity
end


----------------------------------------------------------------------------------
-- Vector 2

Vector2 = {}
Vector2.__index = Vector2
setmetatable(Vector2, { __call = function(Object, ...) return Object.New(...) end })

function Vector2.__tostring(vector2)
    return "Vector2: { x="..vector2.x..", y="..vector2.y.." }"
end

--- Creates a new Vector2 intance.
-- @param x (number or string) The vector's x component.
-- @param y [optional] (number or string) The vector's y component. If nil, will be equal to x. 
-- @return (Vector2) The new instance.
function Vector2.New(x, y)
    Daneel.Debug.StackTrace.BeginFunction("Vector2.New", x, y)
    local errorHead = "Vector2.New(x, y) : "
    Daneel.Debug.CheckArgType(x, "x", {"string", "number"}, errorHead)
    Daneel.Debug.CheckOptionalArgType(y, "y", {"string", "number"}, errorHead)
    
    if y == nil then y = x end
    local vector = setmetatable({ x = x, y = y }, Vector2)
    Daneel.Debug.StackTrace.EndFunction()
    return vector
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
    local newVector = 0
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
    local newVector = 0
    if type(a) == "number" then
        if b.x == 0 or b.y == 0 then
            error(errorHead.."One of the components of the denominator is equal to 0. Can't divide by 0 ! b.x="..b.x.." b.y="..b.y)
        end
        newVector = Vector2.New(a / b.x, a / b.y)
    elseif type(b) == "number" then
        if b == 0 then
            error(errorHead.."The denominator is equal to 0 ! Can't divide by 0 !")
        end
        newVector = Vector2.New(a.x / b, a.y / b)
    else
        if b.x == 0 or b.y == 0 then
            error(errorHead.."One of the components of the denominator is equal to 0. Can't divide by 0 ! b.x="..b.x.." b.y="..b.y)
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

--- Return the length of the vector.
-- @param vector (Vector2) The vector.
function Vector2.GetLength(vector)
    return math.sqrt(vector.x^2 + vector.y^2)
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
