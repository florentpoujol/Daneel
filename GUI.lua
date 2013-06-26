
function DaneelConfigModuleGUI()
    Daneel.GUI = DaneelGUI

    return {
        gui = {
            screenSize = CraftStudio.Screen.GetSize(),
            cameraName = "HUDCamera",
            cameraGO = nil, -- the corresponding GameObject, set at runtime
            originGO = nil, -- "parent" gameObject for global hud positioning, created at runtime in DaneelModuleGUIAwake
            originPosition = Vector3:New(0),

            hud = {
                localPosition = Vector2.New(0, 0),
                layer = 1,
            },

            checkBox = {
                isChecked = false, -- false = unchecked, true = checked
                text = "CheckBox",
                -- ':text' represents the checkBox's text
                defaultCheckedMark = "√ :text",
                defaultUncheckedMark = "X :text",
                defaultCheckedModel = nil,
                defaultUncheckedModel = nil,
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
            },

            input = {
                isFocused = false,
                maxLength = 99999,
                characterRange = nil,
            },
        },

        daneelComponentObjects = {
            Hud = Daneel.GUI.Hud,
            CheckBox = Daneel.GUI.CheckBox,
            ProgressBar = Daneel.GUI.ProgressBar,
            Slider = Daneel.GUI.Slider,
            Input = Daneel.GUI.Input,
        },

        daneelObjects = {
            Vector2 = Vector2,
        },
    }
end

function DaneelAwakeModuleGUI()
    -- setting pixelToUnits  

    -- get the smaller side of the screen (usually screenSize.y, the height)
    local smallSideSize = config.gui.screenSize.y
    if config.gui.screenSize.x < config.gui.screenSize.y then
        smallSideSize = config.gui.screenSize.x
    end

    config.gui.cameraGO = GameObject.Get(config.gui.cameraName)

    if config.gui.cameraGO ~= nil then
        -- The orthographic scale value (in units) is equivalent to the smallest side size of the screen (in pixel)
        -- pixelsToUnits (in units/pixels) is the correspondance between screen pixels and 3D world units
        Daneel.GUI.pixelsToUnits = config.gui.cameraGO.camera.orthographicScale / smallSideSize
        --Daneel.GUI.pixelsToUnits = config.gui.cameraGO.camera.orthographicScale / smallSideSize

        config.gui.originGO = GameObject.New("HUDOrigin", { parent = config.gui.cameraGO })
        config.gui.originGO.transform.localPosition = Vector3:New(
            -config.gui.screenSize.x * Daneel.GUI.pixelsToUnits / 2, 
            config.gui.screenSize.y * Daneel.GUI.pixelsToUnits / 2,
            0
        )
        -- the HUDOrigin is now at the top-left corner of the screen
        config.gui.originPosition = config.gui.originGO.transform.position
    end
end


----------------------------------------------------------------------------------
-- GUI

DaneelGUI = {}

-- used in ProgresBar.SetProgress()
local function tounit(value)
    if type(value) == "string" then
        local length = #value
        if value:endswith("px") then
            value = tonumber(value:sub(0, length-2)) * Daneel.GUI.pixelsToUnits
        elseif value:endswith("u") then
            value = tonumber(value:sub(0, length-1))
        else
            value = tonumber(value)
        end
    end
    return value
end


----------------------------------------------------------------------------------
-- Hud

DaneelGUI.Hud = {}

--- Transform the 3D position into a Hud position and a layer.
-- @param position (Vector3) The 3D position.
-- @return (Vector2) The hud position.
-- @return (numbe) The layer.
function DaneelGUI.Hud.ToHudPosition(position)
    Daneel.Debug.StackTrace.BeginFunction("Daneel.GUI.Hud.ToHudPosition", position)
    local errorHead = "Daneel.GUI.Hud.ToHudPosition(hud, position) : "
    Daneel.Debug.CheckArgType(position, "position", "Vector3", errorHead)

    local layer = config.gui.originPosition.z - position.z
    position = position - config.gui.originPosition
    position = Vector2(
        position.x / Daneel.GUI.pixelsToUnits,
        -position.y / Daneel.GUI.pixelsToUnits
    )
    Daneel.Debug.StackTrace.EndFunction()
    return position, layer
end

-- Create a new Hud component instance.
-- @param gameObject (GameObject) The gameObject to add to the component to.
-- @return (Hud) The hud component.
function DaneelGUI.Hud.New(gameObject)
    Daneel.Debug.StackTrace.BeginFunction("Daneel.GUI.Hud.New", gameObject)
    Daneel.Debug.CheckArgType(gameObject, "gameObject", "GameObject", "Hud.New(gameObject) : ")
    if config.gui.cameraGO == nil then
        error("GUI was not set up or the HUD Camera gameObject with name '"..config.gui.cameraName.."' (value of config.gui.cameraName) was not found. Be sure that you call Daneel.Awake() early on from your scene and check your config.")
    end

    local hud = setmetatable({}, Daneel.GUI.Hud)
    hud.gameObject = gameObject
    hud.inner = " : "..math.round(math.randomrange(100000, 999999))
    hud.localPosition = config.gui.hud.localPosition
    hud.layer = config.gui.hud.layer
    gameObject.hud = hud
    Daneel.Debug.StackTrace.EndFunction()
    return hud
end

--- Sets the position of the gameObject on screen.
-- With the top-left corner of the screen as origin.
-- @param hud (Hud) The hud component.
-- @param position (Vector2) The position as a Vector2.
function DaneelGUI.Hud.SetPosition(hud, position)
    Daneel.Debug.StackTrace.BeginFunction("Daneel.GUI.Hud.SetPosition", hud, position)
    local errorHead = "Daneel.GUI.Hud.SetPosition(hud, position) : "
    Daneel.Debug.CheckArgType(hud, "hud", "Hud", errorHead)
    Daneel.Debug.CheckArgType(position, "position", "Vector2", errorHead)

    local newPosition = config.gui.originPosition + 
    Vector3:New(
        position.x * Daneel.GUI.pixelsToUnits,
        -position.y * Daneel.GUI.pixelsToUnits,
        0
    )
    newPosition.z = hud.gameObject.transform.position.z
    hud.gameObject.transform.position = newPosition
    Daneel.Debug.StackTrace.EndFunction()
end

--- Get the position of the provided hud on the screen.
-- @param hud (Hud) The hud component.
-- @return (Vector2) The position.
function DaneelGUI.Hud.GetPosition(hud)
    Daneel.Debug.StackTrace.BeginFunction("Daneel.GUI.Hud.GetPosition", hud)
    local errorHead = "Daneel.GUI.Hud.GetPosition(hud) : "
    Daneel.Debug.CheckArgType(hud, "hud", "Hud", errorHead)
    
    local position = hud.gameObject.transform.position - config.gui.originPosition
    position = position / Daneel.GUI.pixelsToUnits
    position = Vector2.New(math.round(position.x), math.round(-position.y))
    Daneel.Debug.StackTrace.EndFunction()
    return position
end

--- Sets the local position (relative to its parent) of the gameObject on screen .
-- @param hud (Hud) The hud component.
-- @param position (Vector2) The position as a Vector2.
function DaneelGUI.Hud.SetLocalPosition(hud, position)
    Daneel.Debug.StackTrace.BeginFunction("Daneel.GUI.Hud.SetLocalPosition", hud, position)
    local errorHead = "Daneel.GUI.Hud.SetLocalPosition(hud, position) : "
    Daneel.Debug.CheckArgType(hud, "hud", "Hud", errorHead)
    Daneel.Debug.CheckArgType(position, "position", "Vector2", errorHead)

    local parent = hud.gameObject.parent
    if parent == nil then parent = config.gui.originGO end
    local newPosition = parent.transform.position + 
    Vector3:New(
        position.x * Daneel.GUI.pixelsToUnits,
        -position.y * Daneel.GUI.pixelsToUnits,
        0
    )
    newPosition.z = hud.gameObject.transform.position.z
    hud.gameObject.transform.position = newPosition
    Daneel.Debug.StackTrace.EndFunction()
end

--- Get the local position (relative to its parent) of the gameObject on screen.
-- @param hud (Hud) The hud component.
-- @return (Vector2) The position.
function DaneelGUI.Hud.GetLocalPosition(hud)
    Daneel.Debug.StackTrace.BeginFunction("Daneel.GUI.Hud.GetLocalPosition", hud)
    local errorHead = "Daneel.GUI.Hud.GetLocalPosition(hud) : "
    Daneel.Debug.CheckArgType(hud, "hud", "Hud", errorHead)
    
    local parent = hud.gameObject.parent
    if parent == nil then parent = config.gui.originGO end
    local position = hud.gameObject.transform.position - parent.transform.position
    position = position / Daneel.GUI.pixelsToUnits
    position = Vector2.New(math.round(position.x), math.round(-position.y))
    Daneel.Debug.StackTrace.EndFunction()
    return position
end

--- Set the gameObject's layer.
-- @param hud (Hud) The hud component.
-- @param layer (number) The layer (a postive number).
function DaneelGUI.Hud.SetLayer(hud, layer)
    Daneel.Debug.StackTrace.BeginFunction("Daneel.GUI.Hud.SetLayer", hud)
    local errorHead = "Daneel.GUI.Hud.SetLayer(hud, layer) : "
    Daneel.Debug.CheckArgType(hud, "hud", "Hud", errorHead)
    Daneel.Debug.CheckArgType(layer, "layer", "number", errorHead)

    local originLayer = config.gui.originPosition.z
    local currentPosition = hud.gameObject.transform.position
    hud.gameObject.transform.position = Vector3:New(currentPosition.x, currentPosition.y, originLayer-layer)
    Daneel.Debug.StackTrace.EndFunction()
end

--- Get the gameObject's layer.
-- @param hud (Hud) The hud component.
-- @return (number) The layer.
function DaneelGUI.Hud.GetLayer(hud)
    Daneel.Debug.StackTrace.BeginFunction("Daneel.GUI.Hud.GetLayer", hud)
    local errorHead = "Daneel.GUI.Hud.GetLyer(hud) : "
    Daneel.Debug.CheckArgType(hud, "hud", "Hud", errorHead)

    local originLayer = config.gui.originPosition.z
    local layer = originLayer - hud.gameObject.transform.position.z 
    Daneel.Debug.StackTrace.EndFunction()
    return layer
end

--- Set the huds's local layer.
-- @param hud (Hud) The hud component.
-- @param layer (number) The layer (a postiv number).
function DaneelGUI.Hud.SetLocalLayer(hud, layer)
    Daneel.Debug.StackTrace.BeginFunction("Daneel.GUI.Hud.SetLayer", hud)
    local errorHead = "Daneel.GUI.Hud.SetLayer(hud, layer) : "
    Daneel.Debug.CheckArgType(hud, "hud", "Hud", errorHead)
    Daneel.Debug.CheckArgType(layer, "layer", "number", errorHead)

    local parent = hud.gameObject.parent
    if parent == nil then parent = config.gui.originGO end
    local originLayer = parent.transform.position.z
    local currentPosition = hud.gameObject.transform.position
    hud.gameObject.transform.position = Vector3:New(currentPosition.x, currentPosition.y, originLayer-layer)
    Daneel.Debug.StackTrace.EndFunction()
end

--- Get the gameObject's layer which is actually the inverse of its local position's z component.
-- @param hud (Hud) The hud component.
-- @return (number) The layer.
function DaneelGUI.Hud.GetLocalLayer(hud)
    Daneel.Debug.StackTrace.BeginFunction("Daneel.GUI.Hud.GetLayer", hud)
    local errorHead = "Daneel.GUI.Hud.GetLyer(hud) : "
    Daneel.Debug.CheckArgType(hud, "hud", "Hud", errorHead)

    local parent = hud.gameObject.parent
    if parent == nil then parent = config.gui.originGO end
    local originLayer = parent.transform.position.z
    local layer = originLayer - hud.gameObject.transform.position.z 
    Daneel.Debug.StackTrace.EndFunction()
    return layer
end


----------------------------------------------------------------------------------
-- CheckBox

DaneelGUI.CheckBox = {}

-- Create a new CheckBox component.
-- @param gameObject (GameObject) The component gameObject.
-- @return (CheckBox) The new component.
function DaneelGUI.CheckBox.New(gameObject)
    Daneel.Debug.StackTrace.BeginFunction("Daneel.GUI.CheckBox.New", gameObject)
    local errorHead = "Daneel.GUI.CheckBox.New(gameObject) : "
    Daneel.Debug.CheckArgType(gameObject, "gameObject", "GameObject", errorHead)
    
    local checkBox = table.copy(config.gui.checkBox)
    checkBox.defaultText = checkBox.text
    checkBox.text = nil
    checkBox.gameObject = gameObject
    checkBox.inner = " : "..math.round(math.randomrange(100000, 999999))
    setmetatable(checkBox, Daneel.GUI.CheckBox)
    
    gameObject.checkBox = checkBox
    gameObject:AddTag("mouseInteractive")
    gameObject:AddScriptedBehavior("Daneel/Behaviors/CheckBox")

    if gameObject.textRenderer ~= nil and gameObject.textRenderer.text ~= nil then
        checkBox.text = gameObject.textRenderer.text
    end

    if gameObject.modelRenderer ~= nil then
        if checkBox.isChecked then
            checkBox.gameObject.modelRenderer.model = checkBox.checkedModel
        else
            checkBox.gameObject.modelRenderer.model = checkBox.uncheckedModel
        end
    end

    checkBox:Check(checkBox.isChecked)

    Daneel.Debug.StackTrace.EndFunction()
    return checkBox
end

--- Set the provided checkBox's text.
-- Actually set the text of the TextRenderer component on the same gameObject,
-- but add the correct check mark in front of the provided text.
-- @param checkBox (CheckBox) The checkBox component.
-- @param text (string) The text to display.
function DaneelGUI.CheckBox.SetText(checkBox, text)
    Daneel.Debug.StackTrace.BeginFunction("Daneel.GUI.CheckBox.SetText", checkBox, text)
    local errorHead = "Daneel.GUI.CheckBox.SetText(checkBox, text) : "
    Daneel.Debug.CheckArgType(checkBox, "checkBox", "CheckBox", errorHead)
    Daneel.Debug.CheckArgType(text, "text", "string", errorHead)

    if checkBox.gameObject.textRenderer ~= nil then
        if checkBox.isChecked == true then
            text = Daneel.Utilities.ReplaceInString(checkBox.checkedMark, { text = text })
        else
            text = Daneel.Utilities.ReplaceInString(checkBox.uncheckedMark, { text = text })
        end
        checkBox.gameObject.textRenderer.text = text

    else
        if DEBUG then
            print("WARNING : "..errorHead.."Can't set the checkBox's text because no TextRenderer component has been found on the gameObject '"..tostring(checkBox.gameObject).."'. Waiting for a TextRenderer to be added.")
        end
        checkBox.defaultText = text
    end
    Daneel.Debug.StackTrace.EndFunction()
end

--- Get the provided checkBox's text.
-- Actually get the text of the TextRenderer component on the same gameObject but without the check mark.
-- @param checkBox (CheckBox) The checkBox component.
-- @return (string) The text.
function DaneelGUI.CheckBox.GetText(checkBox)
    Daneel.Debug.StackTrace.BeginFunction("Daneel.GUI.CheckBox.GetText", checkBox)
    local errorHead = "Daneel.GUI.CheckBox.GetText(checkBox, text) : "
    Daneel.Debug.CheckArgType(checkBox, "checkBox", "CheckBox", errorHead)

    local text = nil
    if checkBox.gameObject.textRenderer ~= nil then
        local textMark = checkBox.checkedMark
        if not checkBox.isChecked then
            textMark = checkBox.uncheckedMark
        end
        local start, _end = textMark:find(":text")
        local prefix = textMark:sub(1, start-1)
        local suffix = textMark:sub(_end+1)

        text = checkBox.gameObject.textRenderer.text
        if text == nil then
            text = checkBox.defaultText
        end
        text = text:gsub(prefix, ""):gsub(suffix, "")
    
    elseif DEBUG then
        print("WARNING : "..errorHead.."Can't get the checkBox's text because no TextRenderer component has been found on the gameObject '"..tostring(checkBox.gameObject).."'. Returning nil.")
    end
    Daneel.Debug.StackTrace.EndFunction()
    return text
end 

--- Check or uncheck the provided checkBox and fire the OnUpdate event.
-- You can get the checkBox's state via checkBox.isChecked.
-- @param checkBox (CheckBox) The checkBox component.
-- @param state [optional default=true] (boolean) The new state of the checkBox.
function DaneelGUI.CheckBox.Check(checkBox, state)
    Daneel.Debug.StackTrace.BeginFunction("Daneel.GUI.CheckBox.Check", checkBox, state)
    local errorHead = "Daneel.GUI.CheckBox.Check(checkBox[, state]) : "
    Daneel.Debug.CheckArgType(checkBox, "checkBox", "CheckBox", errorHead)
    state = Daneel.Debug.CheckOptionalArgType(state, "state", "boolean", errorHead, true)

    if checkBox.isChecked ~= state then
        local text = nil
        if checkBox.gameObject.textRenderer ~= nil then
            text = checkBox.text
        end
        
        checkBox.isChecked = state
        
        if checkBox.gameObject.textRenderer ~= nil then
            checkBox.text = text -- "reload" the check mark based on the new checked state
        elseif checkBox.gameObject.modelRenderer ~= nil then
            if state == true then
                checkBox.gameObject.modelRenderer.model = checkBox.checkedModel
            else
                checkBox.gameObject.modelRenderer.model = checkBox.uncheckedModel
            end
        end

        Daneel.Event.Fire(checkBox, "OnUpdate")

        if checkBox._group ~= nil and state == true then
            local gameObjects = GameObject.tags[checkBox._group]
            for i, gameObject in ipairs(gameObjects) do
                if gameObject ~= checkBox.gameObject then
                    gameObject.checkBox:Check(false)
                end
            end
        end
    end
    Daneel.Debug.StackTrace.EndFunction()
end

--- Set the checkBox's group.
-- If the checkBox was already in a group it will be removed from it.
-- @param checkBox (CheckBox) The checkBox component.
-- @param group [optional] (string) The new group, or nil to remove from its group.
function DaneelGUI.CheckBox.SetGroup(checkBox, group)
    Daneel.Debug.StackTrace.BeginFunction("Daneel.GUI.CheckBox.SetGroup", checkBox, group)
    local errorHead = "Daneel.GUI.CheckBox.SetGroup(checkBox[, group]) : "
    Daneel.Debug.CheckArgType(checkBox, "checkBox", "CheckBox", errorHead)
    Daneel.Debug.CheckOptionalArgType(group, "group", "string", errorHead)

    if group == nil and checkBox._group ~= nil then
        checkBox.gameObject:RemoveTag(checkBox._group)
    else
        if checkBox._group ~= nil then
            checkBox.gameObject:RemoveTag(checkBox._group)
        end
        checkBox:Check(false)
        checkBox._group = group
        checkBox.gameObject:AddTag(checkBox._group)
    end
    Daneel.Debug.StackTrace.EndFunction()
end

-- Get the checkBox's group.
-- @param checkBox (CheckBox) The checkBox component.
-- @return (string) The group, or nil.
function DaneelGUI.CheckBox.GetGroup(checkBox)
    Daneel.Debug.StackTrace.BeginFunction("Daneel.GUI.CheckBox.GetGroup", checkBox)
    local errorHead = "Daneel.GUI.CheckBox.GetGroup(checkBox) : "
    Daneel.Debug.CheckArgType(checkBox, "checkBox", "CheckBox", errorHead)
    Daneel.Debug.StackTrace.EndFunction()
    return checkBox._group
end


----------------------------------------------------------------------------------
-- ProgressBar

DaneelGUI.ProgressBar = {}

-- Create a new GUI.ProgressBar.
-- @param gameObject (GameObject) The component gameObject.
-- @return (ProgressBar) The new component.
function DaneelGUI.ProgressBar.New(gameObject)
    Daneel.Debug.StackTrace.BeginFunction("Daneel.GUI.ProgressBar.New", gameObject)
    local errorHead = "Daneel.GUI.ProgressBar.New(gameObject) : "
    Daneel.Debug.CheckArgType(gameObject, "gameObject", "GameObject", errorHead)

    local progressBar = table.copy(config.gui.progressBar)
    progressBar.gameObject = gameObject
    progressBar.inner = " : "..math.round(math.randomrange(100000, 999999))
    progressBar.progress = nil -- remove the property to allow to use the dynamic getter/setter
    setmetatable(progressBar, Daneel.GUI.ProgressBar)
    progressBar.progress = config.gui.progressBar.progress
    
    gameObject.progressBar = progressBar

    Daneel.Debug.StackTrace.EndFunction()
    return progressBar
end

--- Set the progress of the progress bar, adjusting its length.
-- @param progressBar (ProgressBar) The progressBar.
-- @param progress (number or string) The progress as a number (between minVal and maxVal) or as a string and a percentage (between "0%" and "100%").
function DaneelGUI.ProgressBar.SetProgress(progressBar, progress)
    Daneel.Debug.StackTrace.BeginFunction("Daneel.GUI.ProgressBar.SetProgress", progressBar, progress)
    local errorHead = "Daneel.GUI.ProgressBar.SetProgress(progressBar, progress) : "
    Daneel.Debug.CheckArgType(progressBar, "progressBar", "ProgressBar", errorHead)
    Daneel.Debug.CheckArgType(progress, "progress", {"string", "number"}, errorHead)

    local minVal = progressBar.minValue
    local maxVal = progressBar.maxValue
    local percentageOfProgress = nil

    if type(progress) == "string" then
        if progress:endswith("%") then
            percentageOfProgress = tonumber(progress:sub(1, #progress-1)) / 100

            local oldPercentage = percentageOfProgress
            percentageOfProgress = math.clamp(percentageOfProgress, 0.0, 1.0)
            if percentageOfProgress ~= oldPercentage and DEBUG == true then
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
    if progress ~= oldProgress and DEBUG == true then
        print(errorHead.." WARNING : progress with value '"..oldProgress.."' is out of its boundaries : min='"..minVal.."', max='"..maxVal.."'")
    end
    percentageOfProgress = (progress - minVal) / (maxVal - minVal)
    
    --
    progressBar.minLength = tounit(progressBar.minLength)
    progressBar.maxLength = tounit(progressBar.maxLength)
    progressBar.height = tounit(progressBar.height)

    local newLength = (progressBar.maxLength - progressBar.minLength) * percentageOfProgress + progressBar.minLength 
    local currentScale = progressBar.gameObject.transform.localScale
    progressBar.gameObject.transform.localScale = Vector3:New(newLength, progressBar.height, currentScale.z)
    -- newLength = scale only because the base size of the model is of one unit at a scale of one

    Daneel.Event.Fire(progressBar, "OnUpdate")
    Daneel.Debug.StackTrace.EndFunction()
end

--- Get the current progress of the progress bar.
-- @param progressBar (ProgressBar) The progressBar.
-- @param getAsPercentage [optional default=false] (boolean) Get the progress as a percentage (between 0 and 100) instead of an absolute value.
-- @return (number) The progress.
function DaneelGUI.ProgressBar.GetProgress(progressBar, getAsPercentage)
    Daneel.Debug.StackTrace.BeginFunction("Daneel.GUI.ProgressBar.GetProgress", progressBar, getAsPercentage)
    local errorHead = "Daneel.GUI.ProgressBar.GetProgress(progressBar[, getAsPercentage]) : "
    Daneel.Debug.CheckArgType(progressBar, "progressBar", "ProgressBar", errorHead)
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

DaneelGUI.Slider = {}

-- Create a new GUI.Slider.
-- @param gameObject (GameObject) The component gameObject.
-- @return (Slider) The new component.
function DaneelGUI.Slider.New(gameObject)
    Daneel.Debug.StackTrace.BeginFunction("Daneel.GUI.Slider.New", gameObject)
    local errorHead = "Daneel.GUI.Slider.New(gameObject) : "
    Daneel.Debug.CheckArgType(gameObject, "gameObject", "GameObject", errorHead)

    local slider = table.copy(config.gui.slider)
    slider.gameObject = gameObject
    slider.inner = " : "..math.round(math.randomrange(100000, 999999))
    slider.startPosition = gameObject.transform.position
    slider.value = nil
    setmetatable(slider, Daneel.GUI.Slider)
    slider.value = config.gui.slider.value
    
    gameObject.slider = slider
    gameObject:AddTag("mouseInteractive")
    gameObject:AddScriptedBehavior("Daneel/Behaviors/Slider")

    Daneel.Debug.StackTrace.EndFunction()
    return slider
end

--- Set the value of the slider, adjusting its position.
-- @param slider (Slider) The slider.
-- @param value (number or string) The value as a number (between minVal and maxVal) or as a string and a percentage (between "0%" and "100%").
function DaneelGUI.Slider.SetValue(slider, value)
    Daneel.Debug.StackTrace.BeginFunction("Daneel.GUI.Slider.SetValue", slider, value)
    local errorHead = "Daneel.GUI.Slider.SetValue(slider, value) : "
    Daneel.Debug.CheckArgType(slider, "slider", "Slider", errorHead)
    Daneel.Debug.CheckArgType(value, "value", {"string", "number"}, errorHead)

    local maxVal = slider.maxValue
    local minVal = slider.minValue
    local percentage = nil

    if type(value) == "string" then
        if value:endswith("%") then
            percentage = tonumber(value:sub(1, #value-1)) / 100
            value = (maxVal - minVal) * percentage + minVal
        else
            value = tonumber(value)
        end
    end

    -- now value is a number and should be a value between minVal and maxVal
    local oldValue = value
    value = math.clamp(value, minVal, maxVal)
    if value ~= oldValue and DEBUG == true then
        print(errorHead.." WARNING : Argument 'value' with value '"..oldValue.."' is out of its boundaries : min='"..minVal.."', max='"..maxVal.."'")
    end
    percentage = (value - minVal) / (maxVal - minVal)

    slider.length = tounit(slider.length)

    local direction = -Vector3:Left()
    if slider.axis == "y" then
        direction = Vector3:Up()
    end
    local orientation = Vector3.Transform( direction, slider.gameObject.transform.orientation )
    local newPosition = slider.startPosition + orientation * slider.length * percentage
    slider.gameObject.transform.position = newPosition

    Daneel.Event.Fire(slider, "OnUpdate")
    Daneel.Debug.StackTrace.EndFunction()
end

--- Get the current slider's value.
-- @param slider (Slider) The slider.
-- @param getAsPercentage [optional default=false] (boolean) Get the value as a percentage (between 0 and 100) instead of an absolute value.
-- @return (number) The value.
function DaneelGUI.Slider.GetValue(slider, getAsPercentage)
    Daneel.Debug.StackTrace.BeginFunction("Daneel.GUI.Slider.GetValue", slider, getAsPercentage)
    local errorHead = "Daneel.GUI.Slider.GetValue(slider, value) : "
    Daneel.Debug.CheckArgType(slider, "slider", "Slider", errorHead)
    Daneel.Debug.CheckOptionalArgType(getAsPercentage, "getAsPercentage", "boolean", errorHead)
   
    local percentage = Vector3.Distance(slider.startPosition, slider.gameObject.transform.position) / slider.length
    local value = percentage * 100
    if getAsPercentage ~= true then
        value = (slider.maxValue - slider.minValue) * percentage + slider.minValue
    end
    value = math.round(value)
    Daneel.Debug.StackTrace.EndFunction()
    return value
end


----------------------------------------------------------------------------------
-- Input

DaneelGUI.Input = {}

-- Create a new GUI.Input.
-- @param gameObject (GameObject) The component gameObject.
-- @return (Input) The new component.
function DaneelGUI.Input.New( gameObject )
    Daneel.Debug.StackTrace.BeginFunction( "Daneel.GUI.Input.New", gameObject )
    local errorHead = "Daneel.GUI.Input.New(gameObject) : "
    Daneel.Debug.CheckArgType( gameObject, "gameObject", "GameObject", errorHead )

    local input = table.copy( config.gui.input )
    input.gameObject = gameObject
    input.inner = " : "..math.round( math.randomrange( 100000, 999999 ) )
    -- adapted from Blast Turtles
    input.OnTextEntered = function( char )
        if not input.isFocused then return end
        local charNumber = string.byte( char )
        
        if charNumber == 8 then -- Backspace
            local text = gameObject.textRenderer.text
            input:Update( text:sub( 1, #text - 1 ), true )
        
        elseif charNumber == 13 then -- Enter
            Daneel.Event.Fire( input, "OnValidate" )
        
        -- Any character between 32 and 127 is regular printable ASCII
        elseif charNumber >= 32 and charNumber <= 127 then
            if input.characterRange ~= nil and input.characterRange:find( char ) == nil then
                return
            end
            input:Update( char )
        end
    end
    setmetatable( input, Daneel.GUI.Input )

    gameObject.input = input
    gameObject:AddTag( "mouseInteractive" )
    
    Daneel.Event.Listen( "OnLeftMouseButtonJustPressed", 
        function()
            if input.gameObject.isMouseOver == nil then
                input.gameObject.isMouseOver = false
            end
            input.gameObject.input:Focus( input.gameObject.isMouseOver )
        end 
    )

    Daneel.Debug.StackTrace.EndFunction()
    return input
end

-- Set the focused state of the input.
-- @param input (Input) The input component.
-- @param state [optional default=true] (boolean) The new state.
function DaneelGUI.Input.Focus( input, state )
    Daneel.Debug.StackTrace.BeginFunction( "Daneel.GUI.Input.Focus", input, state )
    local errorHead = "Daneel.GUI.Input.Focus(input[, state]) : "
    Daneel.Debug.CheckArgType( input, "input", "Input", errorHead )
    state = Daneel.Debug.CheckOptionalArgType( state, "state", "boolean", errorHead, true )
    
    if input.isFocused ~= state then
        input.isFocused = state
        if state == true then
            CS.Input.OnTextEntered( input.OnTextEntered )
        else
            CS.Input.OnTextEntered( nil )
        end
        Daneel.Event.Fire( input, "OnFocus" )
    end
    Daneel.Debug.StackTrace.EndFunction()
end

-- Set the focused state of the input.
-- @param input (Input) The input component.
-- @param text (string) The text to add to the current text.
-- @param replaceText [optional default=false] (boolean) Tell wether the provided text should be added (false) or replace (true) the current text.
function DaneelGUI.Input.Update(input, text, replaceText)
    Daneel.Debug.StackTrace.BeginFunction("Daneel.GUI.Input.Update", input, text)
    local errorHead = "Daneel.GUI.Input.Update(input, text) : "
    Daneel.Debug.CheckArgType(input, "input", "Input", errorHead)
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
        text = text:sub(1, input.maxLength)
    end
    if oldText ~= text then
        input.gameObject.textRenderer.text = text
        Daneel.Event.Fire(input, "OnUpdate")
    end
    Daneel.Debug.StackTrace.EndFunction()
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
