
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


local function Callback(component, callback, ...)
    if arg == nil then arg = {} end
    local callbackType = type(callback)
    
    if callbackType == "function" then
        callback(component, unpack(arg))
    
    elseif callbackType == "string" and component.gameObject ~= nil then
        --arg.component = component
        gameObject:SendMessage(callback, component)
    end
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
    if gameObject.parent == nil then
        gameObject.parent = config.gui.hudOriginGO
    end
    gameObject.transform.localPosition = Vector3:New(0,0,-5)
    hud._position = Vector2.New(0)
    Daneel.Debug.StackTrace.EndFunction()
    return hud
end


--- Sets the position of the gameObject on screen, relative to its parent.
-- If the gameObject has no parent, it is actually parented to the HUDOrigin gameObject.
-- Which is at the top-left corner of the screen.
-- @param hud (Daneel.GUI.Hud) The hud component.
-- @param position (Vector2) The position as a Vector2.
function Daneel.GUI.Hud.SetPosition(hud, position)
    Daneel.Debug.StackTrace.BeginFunction("Daneel.GUI.Hud.SetPosition", hud, position)
    local errorHead = "Daneel.GUI.Hud.SetPosition(hud, position) : "
    Daneel.Debug.CheckArgType(hud, "hud", "Hud", errorHead)
    Daneel.Debug.CheckArgType(position, "position", "Vector2", errorHead)
    
    if type(position.x) == "string" then

    end
    hud._position = position
    local position3D = Vector3:New(
        position.x * Daneel.GUI.pixelsToUnits,
        -position.y * Daneel.GUI.pixelsToUnits,
        hud.gameObject.transform.localPosition.z
    )
    hud.gameObject.transform.localPosition = position3D
    Daneel.Debug.StackTrace.EndFunction()
end

--- Get the position of the provided hud on the screen.
-- @param hud (Daneel.GUI.Hud) The hud component.
-- @return (Vector2) The position.
function Daneel.GUI.Hud.GetPosition(hud)
    Daneel.Debug.StackTrace.BeginFunction("Daneel.GUI.Hud.GetPosition", hud)
    local errorHead = "Daneel.GUI.Hud.GetPosition(hud) : "
    Daneel.Debug.CheckArgType(hud, "hud", "Hud", errorHead)
    Daneel.Debug.StackTrace.EndFunction()
    return hud._position
end


--- Set the huds's layer which is actually its local position's z hud.
-- @param hud (Daneel.GUI.Hud) The hud component.
-- @param layer (number) The layer (a postiv number).
function Daneel.GUI.Hud.SetLayer(hud, layer)
    Daneel.Debug.StackTrace.BeginFunction("Daneel.GUI.Hud.SetLayer", hud)
    local errorHead = "Daneel.GUI.Hud.SetLayer(hud, layer) : "
    Daneel.Debug.CheckArgType(hud, "hud", "Hud", errorHead)
    Daneel.Debug.CheckArgType(layer, "layer", "number", errorHead)
    local pos = hud.gameObject.transform.localPosition
    hud.gameObject.transform.localPosition = Vector3:New(pos.x, pos.y, -layer)
    Daneel.Debug.StackTrace.EndFunction()
end

--- Get the gameObject's layer which is actually the inverse of its local position's z component.
-- @param hud (Daneel.GUI.Hud) The hud component.
-- @return (number) The layer.
function Daneel.GUI.Hud.GetLayer(hud)
    Daneel.Debug.StackTrace.BeginFunction("Daneel.GUI.Hud.GetLayer", hud)
    local errorHead = "Daneel.GUI.Hud.GetLyer(hud) : "
    Daneel.Debug.CheckArgType(hud, "hud", "Hud", errorHead)
    return -hud.gameObject.transform.localPosition.z
end


----------------------------------------------------------------------------------
-- CheckBox

Daneel.GUI.CheckBox = {}
-- The CheckBox has TextRenderer and Component has ancestors


-- Create a new GUI.CheckBox component.
-- @param gameObject (GameObject) The component gameObject.
-- @return (Daneel.GUI.CheckBox) The new component.
function Daneel.GUI.CheckBox.New(gameObject)
    Daneel.Debug.StackTrace.BeginFunction("Daneel.GUI.CheckBox.New", gameObject)
    local errorHead = "Daneel.GUI.CheckBox.New(gameObject) : "
    Daneel.Debug.CheckArgType(gameObject, "gameObject", "string", errorHead)

    local component = setmetatable({ gameObject = gameObject }, Daneel.GUI.CheckBox)
    gameObject.checkBox = component

    gameObject:AddComponent("TextRenderer", { font = { config.gui.textDefaultFontName } })
    gameObject:AddScriptedBehavior("Daneel/Behaviors/MouseInteractiveGameObject", { component = component })
    
    component.isChecked = config.gui.checkBoxDefaultState
    component.text = "CheckBox"
    -- component may be updated with params in gameObject:AddComponent()
    Daneel.Debug.StackTrace.EndFunction()
    return component
end


function Daneel.GUI.CheckBox.SetText(component, text)
    if component.isChecked == true then
        text = "√ "..text
    else
        text = "X "..text
    end
    component.gameObject.textRenderer.text = text
end

function Daneel.GUI.CheckBox.GetText(component, text)
    return component.gameObject.textRenderer.text:sub(3, 100)
end 


function Daneel.GUI.CheckBox.SetIsChecked(component, state)
    if state == nil then state = true end
    if component._isChecked ~= state then
        component._isChecked = state
        component.text = component.text -- "reload" the check mark based on the new checked state
        Callback(component, component.OnUpdate)
    end
end

function Daneel.GUI.CheckBox.GetIsChecked(component)
    return component._isChecked
end


----------------------------------------------------------------------------------
-- ProgressBar

Daneel.GUI.ProgressBar = {}

--- Create a new GUI.ProgressBar.
-- @param name (string) The component name.
-- @param params [optional] (table) A table with initialisation parameters.
-- @return (Daneel.GUI.ProgressBar) The new component.
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
-- @param progressBar (Daneel.GUI.ProgressBar) The progressBar.
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
    progressBar._progress = progress
    
    local minLength = progressBar.minLength
    if type(minLength) == "string" then
        local length = minLength:len()
        if minLength:endswith("px") then
            minLength = tonumber(minLength:sub(0, length-2)) * Daneel.GUI.pixelsToUnits
        elseif minLength:endswith("u") then
            minLength = tonumber(minLength:sub(0, length-1))
        else
            minLength = tonumber(minLength)
        end
        progressBar.minLength = minLength
    end

    local maxLength = progressBar.maxLength
    if type(maxLength) == "string" then
        local length = maxLength:len()
        if maxLength:endswith("px") then
            maxLength = tonumber(maxLength:sub(0, length-2)) * Daneel.GUI.pixelsToUnits
        elseif maxLength:endswith("u") then
            maxLength = tonumber(maxLength:sub(0, length-1))
        else
            maxLength = tonumber(maxLength)
        end
        progressBar.maxLength = maxLength
    end

    local height = progressBar.height
    if type(height) == "string" then
        if height:endswith("px") then
            height = tonumber(height:sub(0, #height-2)) * Daneel.GUI.pixelsToUnits
        elseif height:endswith("u") then
            height = tonumber(height:sub(0, #height-1))
        else
            height = tonumber(height)
        end
        progressBar.height = height
    end

    local newLength = (maxLength - minLength) * percentageOfProgress + minLength 
    local currentScale = progressBar.gameObject.transform.localScale
    progressBar.gameObject.transform.localScale = Vector3:New(newLength, height, currentScale.z)
    -- newLength = scale only because the base size of the model is of one unit at a scale of one

    Callback(progressBar, progressBar.OnUpdate)
end

--- Get the current progress of the progress bar.
-- @param progressBar (Daneel.GUI.ProgressBar) The progressBar.
-- @param getAsPercentage [optional default=false] (boolean) Get the progress as a percentage instead of an absolute value.
-- @return (number) The progress.
function Daneel.GUI.ProgressBar.GetProgress(progressBar, getAsPercentage)
    Daneel.Debug.StackTrace.BeginFunction("Daneel.GUI.ProgressBar.GetProgress", progressBar, getAsPercentage)
    local errorHead = "Daneel.GUI.ProgressBar.GetProgress(progressBar[, getAsPercentage]) : "
    Daneel.Debug.CheckArgType(progressBar, "progressBar", "ProgressBar", errorHead)
    Daneel.Debug.CheckOptionalArgType(getAsPercentage, "getAsPercentage", "boolean", errorHead)
    local progress = progressBar._progress
    if getAsPercentage == true then
        progress = progress / progressBar.maxValue * 100
    end
    Daneel.Debug.StackTrace.EndFunction()
    return progress
end



----------------------------------------------------------------------------------
-- Vector 2

Vector2 = {}
Vector2.__index = Vector2
setmetatable(Vector2, { __call = function(Object, ...) return Object.New(...) end })

function Vector2.__tostring(vector2)
    return "Vector2: { x="..vector2.x..", y="..vector2.y.." }"
end

function Vector2.New(x, y)
    Daneel.Debug.StackTrace.BeginFunction("Vector2.New", x, y)
    local errorHead = "Vector2.New(x, y) : "
    Daneel.Debug.CheckArgType(x, "x", {"string", "number"}, errorHead)
    Daneel.Debug.CheckOptionalArgType(y, "y", {"string", "number"}, errorHead)
    if y == nil then
        y = x
    end
    local vector = setmetatable({ x = x, y = y }, Vector2)
    Daneel.Debug.StackTrace.EndFunction()
    return vector
end

function Vector2.__add(a, b)
    Daneel.Debug.StackTrace.BeginFunction("Vector2.__add", a, b)
    local errorHead = "Vector2.__add(a, b) : "
    Daneel.Debug.CheckArgType(a, "a", "Vector2", errorHead)
    Daneel.Debug.CheckArgType(b, "b", "Vector2", errorHead)
    a = Vector2.New(a.x + b.x, a.y + b.y)
    Daneel.Debug.StackTrace.EndFunction()
    return a
end
  
function Vector2.__sub(a, b)
    Daneel.Debug.StackTrace.BeginFunction("Vector2.__sub", a, b)
    local errorHead = "Vector2.__sub(a, b) : "
    Daneel.Debug.CheckArgType(a, "a", "Vector2", errorHead)
    Daneel.Debug.CheckArgType(b, "b", "Vector2", errorHead)
    a = Vector2.New(a.x - b.x, a.y - b.y)
    Daneel.Debug.StackTrace.EndFunction()
    return a
end
  
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
  
function Vector2.__div(a, b)
    Daneel.Debug.StackTrace.BeginFunction("Vector2.__div", a, b)
    local errorHead = "Vector2.__div(a, b) : "
    Daneel.Debug.CheckArgType(a, "a", {"Vector2", "number"}, errorHead)
    Daneel.Debug.CheckArgType(b, "b", {"Vector2", "number"}, errorHead)
    local newVector = 0
    if type(a) == "number" then
        newVector = Vector2.New(a / b.x, a / b.y)
    elseif type(b) == "number" then
        newVector = Vector2.New(a.x / b, a.y / b)
    else
        newVector = Vector2.New(a.x / b.x, a.y / b.y)
    end
    Daneel.Debug.StackTrace.EndFunction()
    return newVector
  end
  
function Vector2.__unm(vector)
    Daneel.Debug.StackTrace.BeginFunction("Vector2.__unm", vector)
    local errorHead = "Vector2.__unm(vector) : "
    Daneel.Debug.CheckArgType(vector, "vector", "Vector2", errorHead)
    local vector = Vector2.New(-vector.x, -vector.y)
    Daneel.Debug.StackTrace.EndFunction()
    return vector
  end
  
function Vector2.__pow(vector, exp)
    Daneel.Debug.StackTrace.BeginFunction("Vector2.__pow", vector, exp)
    local errorHead = "Vector2.__pow(vector, exp) : "
    Daneel.Debug.CheckArgType(vector, "vector", "Vector2", errorHead)
    Daneel.Debug.CheckArgType(exp, "exp", "number", errorHead)
    vector = Vector2.New(vector.x ^ exp, vector.y ^ exp)
    Daneel.Debug.StackTrace.EndFunction()
    return vector
  end
  
function Vector2.__eq(a, b)
    Daneel.Debug.StackTrace.BeginFunction("Vector2.__eq", a, b)
    local errorHead = "Vector2.__eq(a, b) : "
    Daneel.Debug.CheckArgType(a, "a", "Vector2", errorHead)
    Daneel.Debug.CheckArgType(b, "b", "Vector2", errorHead)
    local eq = ((a.x == b.x) and (a.y == b.y))
    Daneel.Debug.StackTrace.EndFunction()
    return eq
end