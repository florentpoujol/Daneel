
-- Add this script as ScriptedBehavior on your camera to enable mouse interactions
-- If it is not already done, you also need to 
-- add "LeftMouse" and/or "RightMouse" in the 'config.input.buttons' table 
--  and create the corresponding buttons in your project administration.


local interactiveGameObjects = {}

function Behavior:Awake()
    Daneel.Debug.StackTrace.BeginFunction("MouseInputs:Awake")

    Daneel.Event.Listen("OnLeftMouseButtonJustPressed", self.gameObject)
    Daneel.Event.Listen("OnLeftMouseButtonDown", self.gameObject)
    Daneel.Event.Listen("OnRightMouseButtonJustPressed", self.gameObject)
    
    if GameObject.tags == nil then
        error("MouseInputs:Awake() : Variable 'GameObject.tags' does not exists because the GameObject file probably missing.")
    end
    interactiveGameObjects = GameObject.tags.mouseInteractive

    if self.gameObject.camera == nil then
        CS.Destroy(self)
        error("MouseInputs:Awake() : GameObject with name '"..self.gameObject:GetName().."' has no camera component attached.")
    end
    
    Daneel.Debug.StackTrace.EndFunction()
end


function Behavior:OnLeftMouseButtonJustPressed()
    for i, gameObject in ipairs(interactiveGameObjects) do
        if gameObject ~= nil and gameObject.inner ~= nil and gameObject.isHoveredByMouse == true then
            Daneel.Event.Fire(gameObject, "OnClick")
            
            if gameObject.lastLeftClickFrame ~= nil and 
               Daneel.Time.frameCount <= gameObject.lastLeftClickFrame + config.input.doubleClickDelay then
                Daneel.Event.Fire(gameObject, "OnDoubleClick")
            end
            
            gameObject.lastLeftClickFrame = Daneel.Time.frameCount
        end
    end
end


function Behavior:OnLeftMouseButtonDown()
    local vector = CraftStudio.Input.GetMouseDelta()
    if vector.x >= 1 or vector.y >= 1 then
        for i, gameObject in ipairs(interactiveGameObjects) do
            if gameObject ~= nil and gameObject.inner ~= nil and gameObject.isHoveredByMouse == true then
                Daneel.Event.Fire(gameObject, "OnDrag")
            end
        end
    end
end


function Behavior:OnRightMouseButtonJustPressed()
    for i, gameObject in ipairs(interactiveGameObjects) do
        if gameObject ~= nil and gameObject.iner ~= nil and gameObject.isHoveredByMouse == true then
            Daneel.Event.Fire(gameObject, "OnRightClick")
        end
    end
end


function Behavior:Update()
    local ray = self.gameObject.camera:CreateRay(CraftStudio.Input.GetMousePosition())
    local gameObjectsToRemove = {}
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
            table.insert(gameObjectsToRemove, gameObject)
        end
    end

    for i, gameObject in ipairs(gameObjectsToRemove) do
        table.removevalue(interactiveGameObjects, gameObject)
    end
end
