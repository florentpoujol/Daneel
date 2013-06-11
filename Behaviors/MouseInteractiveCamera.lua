
-- Add this script as ScriptedBehavior on your camera to enable mouse interactions
-- If it is not already done, you also need to 
-- add "LeftMouse" and/or "RightMouse" in the 'config.input.buttons' table 
--  and create the corresponding buttons in your project administration.


local interactiveGameObjects = {}

function Behavior:Start()
    Daneel.Event.Listen({ "OnLeftMouseButtonJustPressed", "OnLeftMouseButtonDown", "OnRightMouseButtonJustPressed" }, self.gameObject)
    interactiveGameObjects = config.mouseInteractiveGameObjects
end


function Behavior:OnLeftMouseButtonJustPressed()
    for i, gameObject in ipairs(interactiveGameObjects) do
        if gameObject ~= nil and gameObject.inner ~= nil then
            if gameObject.isHoveredByMouse == true then
                Daneel.Event.Fire(gameObject, "OnClick")
                
                if gameObject.lastLeftClickFrame ~= nil and 
                   Daneel.Time.frameCount <= gameObject.lastLeftClickFrame + config.input.doubleClickDelay then
                    Daneel.Event.Fire(gameObject, "OnDoubleClick")
                end
                
                gameObject.lastLeftClickFrame = Daneel.Time.frameCount
            end
        else
            table.remove(interactiveGameObjects, i)
        end
    end
end


function Behavior:OnLeftMouseButtonDown()
    local vector = CraftStudio.Input.GetMouseDelta()
    if vector.x >= 1 or Vector.y >= 1 then
        for i, gameObject in ipairs(interactiveGameObjects) do
            if gameObject ~= nil and gameObject.inner ~= nil and gameObject.isHoveredByMouse == true then
                Daneel.Event.Fire(gameObject, "OnDrag")
            end
        end
    end
end


function Behavior:OnRightMouseButtonJustPressed()
    for i, gameObject in ipairs(interactiveGameObjects) do
        if gameObject ~= nil and gameObject.iner ~= nil then 
            if gameObject.isHoveredByMouse == true then
                Daneel.Event.Fire(gameObject, "OnRightClick")
            end
        else
            table.remove(interactiveGameObjects, i)
        end
    end
end


function Behavior:Update()
    local ray = self.gameObject.camera:CreateRay(CraftStudio.Input.GetMousePosition())

    for i, gameObject in ipairs(interactiveGameObjects) do
        if gameObject ~= nil and gameObject.inner ~= nil then
            if ray:IntersectsGameObject(gameObject) ~= nil then
                -- the mouse pointer is over the gameObject
                -- the action will depend on if this is the first time it hovers the gameObject
                -- or if it was already over it the last frame
                -- also on the user's input (clicks) while it hovers the gameObject
                if gameObject.isHoveredByMouse == true then
                    Daneel.Event.Fire(gameObject, "OnMouseOver")
                else
                    gameObject.isHoveredByMouse = true
                    Daneel.Event.Fire(gameObject, "OnMouseEnter")
                end
            else
                -- was the gameObject still hovered the last frame ?
                if gameObject.isHoveredByMouse == true then
                    gameObject.isHoveredByMouse = false
                    Daneel.Event.Fire(gameObject, "OnMouseExit")
                end
            end
        else
            table.remove(interactiveGameObjects, i)
        end
    end
end
