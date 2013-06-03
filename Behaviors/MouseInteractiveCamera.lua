
-- Add this script as ScriptedBehavior on your camera to enable mouse interactions
-- If it is not already done, you also need to 
-- add "LeftMouse" and/or "RightMouse" in the 'config.input.buttons' table 
-- create the corresponding buttons in your project administration


local interactiveGameObjects = {}

function Behavior:Start()
    Daneel.Event.Listen("OnLeftMouseButtonJustPressed", self.gameObject)
    Daneel.Event.Listen("OnRightMouseButtonJustPressed", self.gameObject)

    interactiveGameObjects = config.mouseInteractiveGameObjects
end


function Behavior:OnLeftMouseButtonJustPressed()
    local ray = self.gameObject.camera:CreateRay(CraftStudio.Input.GetMousePosition())
    for i, gameObject in ipairs(interactiveGameObjects) do
        if gameObject ~= nil and gameObject.onMouseOver == true and ray:IntersectsGameObject(gameObject) ~= nil then
            gameObject:SendMessage("OnClick")
            
            if gameObject.framesSinceLastLeftClick ~= nil and 
                gameObject.framesSinceLastLeftClick <= config.input.doubleClickDelay then
                gameObject:SendMessage("OnDoubleClick")
            else
                gameObject.framesSinceLastLeftClick = 0
            end
        end
    end
end


function Behavior:OnRightMouseButtonJustPressed()
    local ray = self.gameObject.camera:CreateRay(CraftStudio.Input.GetMousePosition())
    for i, gameObject in ipairs(interactiveGameObjects) do
        if gameObject ~= nil and gameObject.onMouseOver == true and ray:IntersectsGameObject(gameObject) ~= nil then
            gameObject:SendMessage("OnRightClick")
        end
    end
end


function Behavior:Update()
    local ray = self.gameObject.camera:CreateRay(CraftStudio.Input.GetMousePosition())

    for i, gameObject in ipairs(interactiveGameObjects) do
        if gameObject ~= nil then
            if gameObject.framesSinceLastLeftClick ~= nil then
                gameObject.framesSinceLastLeftClick = gameObject.framesSinceLastLeftClick + 1
            end

            if ray:IntersectsGameObject(gameObject) ~= nil then
                -- the mouse pointer is over the gameObject
                -- the action will depend on if this is the first time it hovers the gameObject
                -- or if it was already over it the last frame
                -- also on the user's input (clicks) while it hovers the gameObject
                if gameObject.onMouseOver == true then
                    gameObject:SendMessage("OnMouseOver")
                else
                    gameObject.onMouseOver = true
                    gameObject:SendMessage("OnMouseEnter")
                end
            else
                -- was the gameObject still hovered the last frame ?
                if gameObject.onMouseOver == true then
                    gameObject.onMouseOver = false
                    gameObject:SendMessage("OnMouseExit")
                end
            end
        else
            table.remove(config.mousehoverableGameObjects, i)
        end
    end
end
