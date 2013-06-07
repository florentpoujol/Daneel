
-- Add this script as ScriptedBehavior on your camera to enable mouse interactions
-- If it is not already done, you also need to 
-- add "LeftMouse" and/or "RightMouse" in the 'config.input.buttons' table 
--  and create the corresponding buttons in your project administration.


local interactiveGameObjects = {}

function Behavior:Start()
    Daneel.Event.Listen("OnLeftMouseButtonJustPressed", self.gameObject)
    Daneel.Event.Listen("OnRightMouseButtonJustPressed", self.gameObject)
    interactiveGameObjects = config.mouseInteractiveGameObjects
end


function Behavior:OnLeftMouseButtonJustPressed()
    for i, gameObject in ipairs(interactiveGameObjects) do
        if gameObject ~= nil and gameObject.inner ~= nil then
            if gameObject.isHoveredByMouse == true then
                Daneel.Utilities.SendCallback(gameObject, "OnClick")
                
                if gameObject.lastLeftClickFrame ~= nil and 
                   Daneel.Time.frameCount <= gameObject.lastLeftClickFrame + config.input.doubleClickDelay then
                    Daneel.Utilities.SendCallback(gameObject, "OnDoubleClick")
                end
                
                gameObject.lastLeftClickFrame = Daneel.Time.frameCount
            end
        else
            table.remove(interactiveGameObjects, i)
        end
    end
end


function Behavior:OnRightMouseButtonJustPressed()
    for i, gameObject in ipairs(interactiveGameObjects) do
        if gameObject ~= nil and gameObject.iner ~= nil then 
            if gameObject.isHoveredByMouse == true then
                Daneel.Utilities.SendCallback(gameObject, "OnRightClick")
            else
        else
            table.remove(interactiveGameObjects, i)
        end
    end
end


function Behavior:Update()
    local ray = self.gameObject.camera:CreateRay(CraftStudio.Input.GetMousePosition())

    for i, gameObject in ipairs(interactiveGameObjects) do
        if gameObject ~= nil and gameObject.inner ~= nil then
            if local ray:IntersectsGameObject(gameObject) ~= nil then
                -- the mouse pointer is over the gameObject
                -- the action will depend on if this is the first time it hovers the gameObject
                -- or if it was already over it the last frame
                -- also on the user's input (clicks) while it hovers the gameObject
                if gameObject.isHoveredByMouse == true then
                    Daneel.Utilities.SendCallback(gameObject, "OnMouseOver")
                else
                    gameObject.isHoveredByMouse = true
                    Daneel.Utilities.SendCallback(gameObject, "OnMouseEnter")
                end
            else
                -- was the gameObject still hovered the last frame ?
                if gameObject.isHoveredByMouse == true then
                    gameObject.isHoveredByMouse = false
                    Daneel.Utilities.SendCallback(gameObject, "OnMouseExit")
                end
            end
        else
            table.remove(interactiveGameObjects, i)
        end
    end
end
