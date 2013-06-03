
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


----------------------------------------------------------------------------------
-- GUI

Daneel.GUI = {}


----------------------------------------------------------------------------------
-- Hud

Daneel.GUI.Hud = {}


function Daneel.GUI.Hud.New(gameObject)
    local hud = setmetatable({ gameObject = gameObject }, Daneel.GUI.Hud)
    gameObject.hud = hud
    gameObject.parent = config.gui.hudOriginGO
    gameObject.transform.localPosition = Vector3:New(0,0,-5)
    hud._position = Vector2.New(0)
    return hud
end

--- Sets the relative position of the hud's gameObject on the screen.
-- The postion is relative to the hud's parent which is the HUDOrigin gameObject, 
-- at the top-left corner fo the screen, or a GUI.Group.
-- @param hud (Daneel.GUI.Hud) The hud component.
-- @param position (Vector2) The position as a Vector2.
function Daneel.GUI.Hud.SetPosition(hud, position)
    Daneel.Debug.StackTrace.BeginFunction("Daneel.GUI.Hud.SetPosition", hud, position)
    local errorHead = "Daneel.GUI.Hud.SetPosition(hud, position) : "
    Daneel.Debug.CheckArgType(hud, "hud", "Hud", errorHead)
    Daneel.Debug.CheckArgType(position, "position", "Vector2", errorHead)
    
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
    
    component.text = "CheckBox"
    component.isChecked = config.gui.checkBoxDefaultState

    Daneel.Debug.StackTrace.EndFunction()
    return component
end


function Daneel.GUI.CheckBox.SetText(component, text)
    component._text = text
    if component.isChecked == true then
        text = "√ "..text
    else
        text = "X "..text
    end
    component.gameObject.textRenderer.text = text
end

function Daneel.GUI.CheckBox.GetText(component, text)
    return component._text
end 

-- Set the checked state of the checkbox.
-- Update the _isChecked variable and the textRenderer
-- @param component (Daneel.GUI.CheckBox) The component.
-- @param state (boolean) The state.
function Daneel.GUI.CheckBox.SetIsChecked(component, state)
    Daneel.Debug.StackTrace.BeginFunction("Daneel.GUI.CheckBox.SetChecked", component, state)
    local errorHead = "Daneel.GUI.CheckBox.SetChecked(component, state) : "
    Daneel.Debug.CheckArgType(component, "component", "Daneel.GUI.CheckBox", errorHead)
    Daneel.Debug.CheckArgType(state, "state", "boolean", errorHead)
    if component._isChecked ~= state then
        local text = component._text
        if state == true then
            text = "√ "..text
        else
            text = "X "..text
        end
        component.gameObject.textRenderer.text = text
        component._isChecked = state
        -- callback OnUpdate(state)
    end
    Daneel.Debug.StackTrace.EndFunction()
end

-- Get the checked state of the checkbox.
-- @param component (Daneel.GUI.CheckBox) The component.
-- @return (boolean) The state.
function Daneel.GUI.CheckBox.GetIsChecked(component)
    Daneel.Debug.StackTrace.BeginFunction("Daneel.GUI.CheckBox.GetChecked", component)
    local errorHead = "Daneel.GUI.CheckBox.GetChecked(component) : "
    Daneel.Debug.CheckArgType(component, "component", "Daneel.GUI.CheckBox", errorHead)
    Daneel.Debug.StackTrace.EndFunction()
    return component._isChecked    
end

-- Switch the checked state of the checkbox.
-- @param component (Daneel.GUI.CheckBox) The component.
function Daneel.GUI.CheckBox.SwitchState(component)
    Daneel.Debug.StackTrace.BeginFunction("Daneel.GUI.CheckBox.SwitchState", component)
    local errorHead = "Daneel.GUI.CheckBox.SwitchState(component) : "
    Daneel.Debug.CheckArgType(component, "component", "Daneel.GUI.CheckBox", errorHead)
    component.isChecked = not component._isChecked
    Daneel.Debug.StackTrace.EndFunction()
end

