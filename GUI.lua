
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

    local hud = setmetatable({ gameObject = gameObject }, Daneel.GUI.Hud)
    gameObject.hud = hud
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
    Daneel.Debug.CheckArgType(gameObject, "gameObject", "string", errorHead)
    
    local checkBox = setmetatable({ gameObject = gameObject }, Daneel.GUI.CheckBox)
    gameObject.checkBox = checkBox

    gameObject:AddTags("mouseInteractive")

    if gameObject.textRenderer == nil then
        -- "wait" for the TextRenderer to be added
        checkBox.OnNewComponent = function(newComponent)
            if getmetatable(newComponent) == TextRenderer then
                checkBox.text = checkBox._text
            end
        end
        checkBox._text = "CheckBox"
    else
        checkBox.text = gameObject.textRenderer.text
    end
    
    checkBox:Check(config.gui.checkBoxDefaultState)
    Daneel.Debug.StackTrace.EndFunction()
    return checkBox
end

--- Set the provided checkBox's text.
-- Actually set the text of the TextRenderer component on the same gameObject,
-- but add the correct check mark in front of the provided text.
-- @param checkBox (CheckBox) The checkBox component.
function Daneel.GUI.CheckBox.SetText(checkBox, text)
    Daneel.Debug.StackTrace.BeginFunction("Daneel.GUI.CheckBox.SetText", checkBox, text)
    local errorHead = "Daneel.GUI.CheckBox.SetText(checkBox, text) : "
    Daneel.Debug.CheckArgType(checkBox, "checkBox", "CheckBox", errorHead)
    Daneel.Debug.CheckArgType(text, "text", "string", errorHead)

    if checkBox.isChecked == true then
        text = "√ "..text
    else
        text = "X "..text
    end
    if checkBox.gameObject.textRenderer ~= nil then
        checkBox.gameObject.textRenderer.text = text
    elseif DEBUG == true then
        print(errorHead.."Can't set the checkBox's text because no TextRenderer component has been found on the gameObject '"..tostring(checkBox.gameObject).."'.")
    end
    Daneel.Debug.StackTrace.EndFunction()
end

--- Get the provided checBox's text.
-- Actually get the text of the TextRenderer component on the same gameObject but without the check mark.
-- @param checkBox (CheckBox) The checkBox component.
-- @return (string) The text.
function Daneel.GUI.CheckBox.GetText(checkBox)
    Daneel.Debug.StackTrace.BeginFunction("Daneel.GUI.CheckBox.GetText", checkBox)
    local errorHead = "Daneel.GUI.CheckBox.GetText(checkBox, text) : "
    Daneel.Debug.CheckArgType(checkBox, "checkBox", "CheckBox", errorHead)

    local text = nil
    if checkBox.gameObject.textRenderer ~= nil then
        text = checkBox.gameObject.textRenderer.text:sub(3, 500)
    elseif DEBUG == true then
        print(errorHead.."Can't get the checkBox's text because no TextRenderer component has been found on the gameObject '"..tostring(checkBox.gameObject).."'.")
    end
    Daneel.Debug.StackTrace.EndFunction()
    return text
end 

--- Check or uncheck the provided checkBox.
-- You can get the checkbox's state via checkBox.isChecked.
-- @param checkBox (CheckBox) The checkBox component.
-- @param state [optional default=true] (boolean) The new state of the checkBox.
function Daneel.GUI.CheckBox.Check(checkBox, state)
    Daneel.Debug.StackTrace.BeginFunction("Daneel.GUI.CheckBox.Check", checkBox, state)
    local errorHead = "Daneel.GUI.CheckBox.Check(checkBox[, state]) : "
    Daneel.Debug.CheckArgType(checkBox, "checkBox", "CheckBox", errorHead)
    Daneel.Debug.CheckOptionalArgType(state, "state", "boolean", errorHead)

    if state == nil then state = true end
    if checkBox.isChecked ~= state then
        checkBox.isChecked = state
        checkBox.text = checkBox.text -- "reload" the check mark based on the new checked state
        Daneel.Event.Fire(checkBox, "OnUpdate")
    end
    Daneel.Debug.StackTrace.EndFunction()
end


----------------------------------------------------------------------------------
-- ProgressBar

Daneel.GUI.ProgressBar = {}

--- Create a new GUI.ProgressBar.
-- @param name (string) The component name.
-- @param params [optional] (table) A table with initialisation parameters.
-- @return (ProgressBar) The new component.
function Daneel.GUI.ProgressBar.New(gameObject)
    Daneel.Debug.StackTrace.BeginFunction("Daneel.GUI.ProgressBar.New", gameObject)
    local errorHead = "Daneel.GUI.ProgressBar.New(gameObject) : "
    Daneel.Debug.CheckArgType(gameObject, "gameObject", "GameObject", errorHead)

    local progressBar = setmetatable({ gameObject = gameObject }, Daneel.GUI.ProgressBar)
    gameObject.progressBar = progressBar
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
-- @param pogress (number or string) The progress as a number (between minVal and maxVal) or as a string and a percentage (between "0%" and "100%").
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

--- Create a new GUI.Slider.
-- @param name (string) The component name.
-- @param params [optional] (table) A table with initialisation parameters.
-- @return (Slider) The new component.
function Daneel.GUI.Slider.New(gameObject)
    Daneel.Debug.StackTrace.BeginFunction("Daneel.GUI.Slider.New", gameObject)
    local errorHead = "Daneel.GUI.Slider.New(gameObject) : "
    Daneel.Debug.CheckArgType(gameObject, "gameObject", "GameObject", errorHead)

    local slider = setmetatable({ gameObject = gameObject }, Daneel.GUI.Slider)
    gameObject.slider = slider

    gameObject:AddTags("mouseInteractive")

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
-- @param pogress (number or string) The value as a number (between minVal and maxVal) or as a string and a percentage (between "0%" and "100%").
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

function Daneel.GUI.Slider.GetValue(slider)
    Daneel.Debug.StackTrace.BeginFunction("Daneel.GUI.Slider.SetValue", slider)
    local errorHead = "Daneel.GUI.Slider.SetValue(slider, value) : "
    Daneel.Debug.CheckArgType(slider, "slider", "Slider", errorHead)
    Daneel.Debug.StackTrace.EndFunction()
    return slider._value
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

-- Return the length of the vector.
-- @param vector (Vector2) The vector.
function Vector2.GetLength(vector)
    return math.sqrt(vector.x^2 + vector.y^2)
end
