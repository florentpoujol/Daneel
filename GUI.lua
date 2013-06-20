
local daneel_exists = false
for key, value in pairs(_G) do
    if key == "Daneel" then
        daneel_exists = true
        break
    end
end
if daneel_exists == false then
    Daneel = {}
end


----------------------------------------------------------------------------------
-- GUI

Daneel.GUI = {}

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

Daneel.GUI.Hud = {}


-- Create a new Hud component instance.
-- @param gameObject (GameObject) The gameObject to add to the component to.
-- @return (Hud) The hud component.
function Daneel.GUI.Hud.New(gameObject)
    Daneel.Debug.StackTrace.BeginFunction("Daneel.GUI.Hud.New", gameObject)
    Daneel.Debug.CheckArgType(gameObject, "gameObject", "GameObject", "Hud.New(gameObject) : ")
    if config.gui.hudCameraGO == nil and DEBUG == true then
        error("GUI was not set up or the HUD Camera gameObject with name '"..config.gui.hudCameraName.."' was not found. Be sure that you call Daneel.Awake() early on from your scene and check your config.")
    end

    local hud = setmetatable({}, Daneel.GUI.Hud)
    gameObject.hud = hud
    hud.gameObject = gameObject
    hud.inner = " : "..math.round(math.randomrange(100000, 999999))
    hud.position = Vector2.New(0)
    hud.layer = 1
    Daneel.Debug.StackTrace.EndFunction()
    return hud
end

--- Sets the position of the gameObject on screen.
-- With the top-left corner of the screen as origin.
-- @param hud (Daneel.GUI.Hud) The hud component.
-- @param position (Vector2) The position as a Vector2.
function Daneel.GUI.Hud.SetPosition(hud, position)
    Daneel.Debug.StackTrace.BeginFunction("Daneel.GUI.Hud.SetPosition", hud, position)
    local errorHead = "Daneel.GUI.Hud.SetPosition(hud, position) : "
    Daneel.Debug.CheckArgType(hud, "hud", "Hud", errorHead)
    Daneel.Debug.CheckArgType(position, "position", "Vector2", errorHead)

    local newPosition = config.gui.hudOriginPosition + 
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
-- @param hud (Daneel.GUI.Hud) The hud component.
-- @return (Vector2) The position.
function Daneel.GUI.Hud.GetPosition(hud)
    Daneel.Debug.StackTrace.BeginFunction("Daneel.GUI.Hud.GetPosition", hud)
    local errorHead = "Daneel.GUI.Hud.GetPosition(hud) : "
    Daneel.Debug.CheckArgType(hud, "hud", "Hud", errorHead)
    
    local position = hud.gameObject.transform.position - config.gui.hudOriginPosition
    position = position * Daneel.GUI.pixelsToUnits
    position = Vector2.New(math.round(position.x), math.round(-position.y))
    Daneel.Debug.StackTrace.EndFunction()
    return position
end

--- Sets the local position (relative to its parent) of the gameObject on screen .
-- @param hud (Daneel.GUI.Hud) The hud component.
-- @param position (Vector2) The position as a Vector2.
function Daneel.GUI.Hud.SetLocalPosition(hud, position)
    Daneel.Debug.StackTrace.BeginFunction("Daneel.GUI.Hud.SetLocalPosition", hud, position)
    local errorHead = "Daneel.GUI.Hud.SetLocalPosition(hud, position) : "
    Daneel.Debug.CheckArgType(hud, "hud", "Hud", errorHead)
    Daneel.Debug.CheckArgType(position, "position", "Vector2", errorHead)

    local parent = hud.gameObject.parent
    if parent == nil then parent = config.gui.hudOriginGO end
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
-- @param hud (Daneel.GUI.Hud) The hud component.
-- @return (Vector2) The position.
function Daneel.GUI.Hud.GetLocalPosition(hud)
    Daneel.Debug.StackTrace.BeginFunction("Daneel.GUI.Hud.GetLocalPosition", hud)
    local errorHead = "Daneel.GUI.Hud.GetLocalPosition(hud) : "
    Daneel.Debug.CheckArgType(hud, "hud", "Hud", errorHead)
    
    local parent = hud.gameObject.parent
    if parent == nil then parent = config.gui.hudOriginGO end
    local position = hud.gameObject.transform.position - parent.transform.position
    position = position / Daneel.GUI.pixelsToUnits
    position = Vector2.New(math.round(position.x), math.round(-position.y))
    Daneel.Debug.StackTrace.EndFunction()
    return position
end

--- Set the gameObject's layer.
-- @param hud (Daneel.GUI.Hud) The hud component.
-- @param layer (number) The layer (a postive number).
function Daneel.GUI.Hud.SetLayer(hud, layer)
    Daneel.Debug.StackTrace.BeginFunction("Daneel.GUI.Hud.SetLayer", hud)
    local errorHead = "Daneel.GUI.Hud.SetLayer(hud, layer) : "
    Daneel.Debug.CheckArgType(hud, "hud", "Hud", errorHead)
    Daneel.Debug.CheckArgType(layer, "layer", "number", errorHead)

    local originLayer = config.gui.hudOriginPosition.z
    local currentPosition = hud.gameObject.transform.position
    hud.gameObject.transform.position = Vector3:New(currentPosition.x, currentPosition.y, originLayer-layer)
    Daneel.Debug.StackTrace.EndFunction()
end

--- Get the gameObject's layer.
-- @param hud (Daneel.GUI.Hud) The hud component.
-- @return (number) The layer.
function Daneel.GUI.Hud.GetLayer(hud)
    Daneel.Debug.StackTrace.BeginFunction("Daneel.GUI.Hud.GetLayer", hud)
    local errorHead = "Daneel.GUI.Hud.GetLyer(hud) : "
    Daneel.Debug.CheckArgType(hud, "hud", "Hud", errorHead)

    local originLayer = config.gui.hudOriginPosition.z
    local layer = originLayer - hud.gameObject.transform.position.z 
    Daneel.Debug.StackTrace.EndFunction()
    return layer
end

--- Set the huds's local layer.
-- @param hud (Daneel.GUI.Hud) The hud component.
-- @param layer (number) The layer (a postiv number).
function Daneel.GUI.Hud.SetLocalLayer(hud, layer)
    Daneel.Debug.StackTrace.BeginFunction("Daneel.GUI.Hud.SetLayer", hud)
    local errorHead = "Daneel.GUI.Hud.SetLayer(hud, layer) : "
    Daneel.Debug.CheckArgType(hud, "hud", "Hud", errorHead)
    Daneel.Debug.CheckArgType(layer, "layer", "number", errorHead)

    local parent = hud.gameObject.parent
    if parent == nil then parent = config.gui.hudOriginGO end
    local originLayer = parent.transform.position.z
    local currentPosition = hud.gameObject.transform.position
    hud.gameObject.transform.position = Vector3:New(currentPosition.x, currentPosition.y, originLayer-layer)
    Daneel.Debug.StackTrace.EndFunction()
end

--- Get the gameObject's layer which is actually the inverse of its local position's z component.
-- @param hud (Daneel.GUI.Hud) The hud component.
-- @return (number) The layer.
function Daneel.GUI.Hud.GetLocalLayer(hud)
    Daneel.Debug.StackTrace.BeginFunction("Daneel.GUI.Hud.GetLayer", hud)
    local errorHead = "Daneel.GUI.Hud.GetLyer(hud) : "
    Daneel.Debug.CheckArgType(hud, "hud", "Hud", errorHead)

    local parent = hud.gameObject.parent
    if parent == nil then parent = config.gui.hudOriginGO end
    local originLayer = parent.transform.position.z
    local layer = originLayer - hud.gameObject.transform.position.z 
    Daneel.Debug.StackTrace.EndFunction()
    return layer
end


----------------------------------------------------------------------------------
-- CheckBox

Daneel.GUI.CheckBox = {}

-- Create a new CheckBox component.
-- @param gameObject (GameObject) The component gameObject.
-- @return (CheckBox) The new component.
function Daneel.GUI.CheckBox.New(gameObject)
    Daneel.Debug.StackTrace.BeginFunction("Daneel.GUI.CheckBox.New", gameObject)
    local errorHead = "Daneel.GUI.CheckBox.New(gameObject) : "
    Daneel.Debug.CheckArgType(gameObject, "gameObject", "GameObject", errorHead)
    
    local checkBox = setmetatable({}, Daneel.GUI.CheckBox)
    gameObject.checkBox = checkBox
    checkBox.gameObject = gameObject
    checkBox.inner = " : "..math.round(math.randomrange(100000, 999999))

    checkBox.checkedMark = config.gui.checkBox.defaultCheckedMark
    checkBox.uncheckedMark = config.gui.checkBox.defaultUncheckedMark
    checkBox.checkedModel = config.gui.checkBox.defaultCheckedModel
    checkBox.uncheckedModel = config.gui.checkBox.defaultUncheckedModel

    if gameObject.textRenderer == nil or gameObject.modelRenderer == nil then
        -- "wait" for the TextRenderer or ModelRenderer to be added
        checkBox.OnNewComponent = function(newComponent)
            --if getmetatable(newComponent) == TextRenderer then
                --checkBox.text = checkBox._text
            --elseif getmetatable(newComponent) == ModelRenderer and checkBox.checkedModel ~= nil then
            if getmetatable(newComponent) == ModelRenderer and checkBox.checkedModel ~= nil then
                if checkbox.isChecked then
                    checkBox.gameObject.modelRenderer.model = checkBox.checkedModel
                else
                    checkBox.gameObject.modelRenderer.model = checkBox.uncheckedModel
                end
            end
        end
        checkBox._text = "CheckBox"
    end

    if gameObject.textRenderer ~= nil then
        checkBox.text = gameObject.textRenderer.text
    end

    if gameObject.modelRenderer ~= nil then
        if checkbox.isChecked then
            checkBox.gameObject.modelRenderer.model = checkBox.checkedModel
        else
            checkBox.gameObject.modelRenderer.model = checkBox.uncheckedModel
        end
    end

    checkBox:Check(config.gui.checkBox.defaultState)
    
    gameObject:AddScriptedBehavior("Daneel/Behaviors/CheckBox")
    gameObject:AddTag("mouseInteractive")
    
    Daneel.Debug.StackTrace.EndFunction()
    return checkBox
end

--- Set the provided checkBox's text.
-- Actually set the text of the TextRenderer component on the same gameObject,
-- but add the correct check mark in front of the provided text.
-- @param checkBox (CheckBox) The checkBox component.
-- @param text (string) The text to display.
function Daneel.GUI.CheckBox.SetText(checkBox, text)
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
        error(errorHead.."Can't set the checkBox's text because no TextRenderer component has been found on the gameObject '"..tostring(checkBox.gameObject).."'.")
    end
    Daneel.Debug.StackTrace.EndFunction()
end

--- Get the provided checkBox's text.
-- Actually get the text of the TextRenderer component on the same gameObject but without the check mark.
-- @param checkBox (CheckBox) The checkBox component.
-- @return (string) The text.
function Daneel.GUI.CheckBox.GetText(checkBox)
    Daneel.Debug.StackTrace.BeginFunction("Daneel.GUI.CheckBox.GetText", checkBox)
    local errorHead = "Daneel.GUI.CheckBox.GetText(checkBox, text) : "
    Daneel.Debug.CheckArgType(checkBox, "checkBox", "CheckBox", errorHead)

    local text = nil
    if checkBox.gameObject.textRenderer ~= nil then
        local textMark = checkBox.checkedMark
        if checkBox.isChecked == false then
            textMark = checkBox.checkedMark
        end
        local start, _end = textMark:find(":text")
        local prefix = textMark:sub(1, start-1)
        local suffix = textMark:sub(_end+1)
        local text = checkBox.gameObject.textRenderer.text
        text = text:gsub(prefix, ""):gsub(suffix, "")

    else
        error(errorHead.."Can't get the checkBox's text because no TextRenderer component has been found on the gameObject '"..tostring(checkBox.gameObject).."'.")
    end
    Daneel.Debug.StackTrace.EndFunction()
    return text
end 

--- Check or uncheck the provided checkBox and fire the OnUpdate event.
-- You can get the checkbox's state via checkBox.isChecked.
-- @param checkBox (CheckBox) The checkBox component.
-- @param state [optional default=true] (boolean) The new state of the checkBox.
function Daneel.GUI.CheckBox.Check(checkBox, state)
    Daneel.Debug.StackTrace.BeginFunction("Daneel.GUI.CheckBox.Check", checkBox, state)
    local errorHead = "Daneel.GUI.CheckBox.Check(checkBox[, state]) : "
    Daneel.Debug.CheckArgType(checkBox, "checkBox", "CheckBox", errorHead)
    state = Daneel.Debug.CheckOptionalArgType(state, "state", "boolean", errorHead, true)

    if checkBox.isChecked ~= state then
        checkBox.isChecked = state
        
        if checkBox.gameObject.textRenderer ~= nil then
            checkBox.text = checkBox.text -- "reload" the check mark based on the new checked state
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
function Daneel.GUI.CheckBox.SetGroup(checkBox, group)
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
function Daneel.GUI.CheckBox.GetGroup(checkBox)
    Daneel.Debug.StackTrace.BeginFunction("Daneel.GUI.CheckBox.GetGroup", checkBox)
    local errorHead = "Daneel.GUI.CheckBox.GetGroup(checkBox) : "
    Daneel.Debug.CheckArgType(checkBox, "checkBox", "CheckBox", errorHead)
    Daneel.Debug.StackTrace.EndFunction()
    return checkBox._group
end


----------------------------------------------------------------------------------
-- ProgressBar

Daneel.GUI.ProgressBar = {}

-- Create a new GUI.ProgressBar.
-- @param gameObject (GameObject) The component gameObject.
-- @return (ProgressBar) The new component.
function Daneel.GUI.ProgressBar.New(gameObject)
    Daneel.Debug.StackTrace.BeginFunction("Daneel.GUI.ProgressBar.New", gameObject)
    local errorHead = "Daneel.GUI.ProgressBar.New(gameObject) : "
    Daneel.Debug.CheckArgType(gameObject, "gameObject", "GameObject", errorHead)

    local progressBar = setmetatable({}, Daneel.GUI.ProgressBar)
    gameObject.progressBar = progressBar
    progressBar.gameObject = gameObject
    progressBar.inner = " : "..math.round(math.randomrange(100000, 999999))

    progressBar.height = 1
    progressBar.minValue = 0
    progressBar.maxValue = 100
    progressBar.minLength = 0
    progressBar.maxLength = 5
    progressBar.progress = "100%"

    Daneel.Debug.StackTrace.EndFunction()
    return progressBar
end

--- Set the progress of the progress bar, adjusting its length.
-- @param progressBar (ProgressBar) The progressBar.
-- @param progress (number or string) The progress as a number (between minVal and maxVal) or as a string and a percentage (between "0%" and "100%").
function Daneel.GUI.ProgressBar.SetProgress(progressBar, progress)
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
-- @param getAsPercentage [optional default=false] (boolean) Get the progress as a percentage instead of an absolute value.
-- @return (number) The progress.
function Daneel.GUI.ProgressBar.GetProgress(progressBar, getAsPercentage)
    Daneel.Debug.StackTrace.BeginFunction("Daneel.GUI.ProgressBar.GetProgress", progressBar, getAsPercentage)
    local errorHead = "Daneel.GUI.ProgressBar.GetProgress(progressBar[, getAsPercentage]) : "
    Daneel.Debug.CheckArgType(progressBar, "progressBar", "ProgressBar", errorHead)
    Daneel.Debug.CheckOptionalArgType(getAsPercentage, "getAsPercentage", "boolean", errorHead)

    local scale = progressBar.gameObject.transform.localScale.x
    local progress = (scale - progressBar.minLength) / (progressBar.maxLength - progressBar.minLength)
    if getAsPercentage == true then
        progress = progress * 100
    else
        progress = (progressBar.maxValue - progressBar.minValue) * progress
    end
    progress = math.round(progress)
    Daneel.Debug.StackTrace.EndFunction()
    return progress
end


----------------------------------------------------------------------------------
-- Slider

Daneel.GUI.Slider = {}

-- Create a new GUI.Slider.
-- @param gameObject (GameObject) The component gameObject.
-- @return (Slider) The new component.
function Daneel.GUI.Slider.New(gameObject)
    Daneel.Debug.StackTrace.BeginFunction("Daneel.GUI.Slider.New", gameObject)
    local errorHead = "Daneel.GUI.Slider.New(gameObject) : "
    Daneel.Debug.CheckArgType(gameObject, "gameObject", "GameObject", errorHead)

    local slider = setmetatable({}, Daneel.GUI.Slider)
    gameObject.slider = slider
    slider.gameObject = gameObject
    slider.inner = " : "..math.round(math.randomrange(100000, 999999))

    gameObject:AddTag("mouseInteractive")

    slider.minValue = 0
    slider.maxValue = 100
    slider.length = 5
    slider.startPosition = slider.gameObject.transform.position
    slider.value = "0%"

    Daneel.Debug.StackTrace.EndFunction()
    return slider
end


--- Set the value of the slider, adjusting its position.
-- @param slider (Slider) The slider.
-- @param value (number or string) The value as a number (between minVal and maxVal) or as a string and a percentage (between "0%" and "100%").
function Daneel.GUI.Slider.SetValue(slider, value)
    Daneel.Debug.StackTrace.BeginFunction("Daneel.GUI.Slider.SetValue", slider, value)
    local errorHead = "Daneel.GUI.Slider.SetValue(slider, value) : "
    Daneel.Debug.CheckArgType(slider, "slider", "Slider", errorHead)
    Daneel.Debug.CheckArgType(value, "value", {"string", "number"}, errorHead)

    local maxVal = slider.maxValue
    local minVal = slider.minValue
    local percentageOfProgress = nil

    if type(value) == "string" then
        if value:endswith("%") then
            percentageOfProgress = tonumber(value:sub(1, #value-1)) / 100
            local oldPercentage = percentageOfProgress
            percentageOfProgress = math.clamp(percentageOfProgress, 0.0, 1.0)
            if percentageOfProgress ~= oldPercentage and DEBUG == true then
                print(errorHead.."WARNING : value in percentageOfProgress '"..value.."' is below 0% or above 100%.")
            end
            value = (maxVal - minVal) * percentageOfProgress + minVal
        else
            value = tonumber(value)
        end
    end
    slider._value = value

    -- now value is a number and should be a value between minVal and maxVal
    local oldValue = value
    value = math.clamp(value, minVal, maxVal)
    if value ~= oldValue and DEBUG == true then
        print(errorHead.." WARNING : progress with value '"..oldValue.."' is out of its boundaries : min='"..minVal.."', max='"..maxVal.."'")
    end
    percentageOfProgress = (value - minVal) / (maxVal - minVal)

    -- update the actual position
    slider.length = tounit(slider.length)
    local length = Vector3:New(slider.length)
    if slider.gameObject.hud ~= nil then
        length.z = 0
    end

    local newPos = slider.startPosition + (length * percentageOfProgress)
    slider.gameObject.transform.position = newPos

    Daneel.Event.Fire(slider, "OnUpdate")
    Daneel.Debug.StackTrace.EndFunction()
end

-- @param slider (Slider) The slider.
function Daneel.GUI.Slider.GetValue(slider)
    Daneel.Debug.StackTrace.BeginFunction("Daneel.GUI.Slider.SetValue", slider)
    local errorHead = "Daneel.GUI.Slider.SetValue(slider, value) : "
    Daneel.Debug.CheckArgType(slider, "slider", "Slider", errorHead)
    Daneel.Debug.StackTrace.EndFunction()
    return slider._value
end
