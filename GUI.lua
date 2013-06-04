
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
-- Vector 2

Vector2 = {}
Vector2.__index = Vector2

function Vector2.New(x, y)
    Daneel.Debug.StackTrace.BeginFunction("Vector2.new", x, y)
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

function Vector2.__tostring(vector2)
    return "Vector2: { x="..vector2.x..", y="..vector2.y.." }"
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
-- @param gameObject (GameObject) The gameObject to add to the compoenent to.
-- @return (Hud) The hud component.
function Daneel.GUI.Hud.New(gameObject)
    Daneel.Debug.StackTrace.BeginFunction("Daneel.GUI.Hud.New", gameObject)
    Daneel.Debug.CheckArgType(gameObject, "gameObject", "GameObject", "Daneel.GUI.Hud.New(gameObject) : ")
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
        component.text = component.text -- "reload" the check mark
        Callback(component, component.OnCheck)
    end
end

function Daneel.GUI.CheckBox.GetIsChecked(component)
    return component._isChecked
end


