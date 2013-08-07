-- MouseInput.lua
-- Enable mouse interactions with game objects when added to a game object with a camera component.
--
-- Last modified for v1.2.0
-- Copyright © 2013 Florent POUJOL, published under the MIT licence.

MouseInput = {}

if CS.DaneelModules == nil then
    CS.DaneelModules = {}
end
CS.DaneelModules[ "MouseInput" ] = {}

MouseInput.Config = {
    doubleClickDelay = 20 -- Maximum number of frames between two clicks of the left mouse button to be considered as a double click
}


----------------------------------------------------------------------------------

--[[PublicProperties
tags string "guiComponent"
updateInterval number 10
/PublicProperties]]

function Behavior:Awake()
    Daneel.Debug.StackTrace.BeginFunction( "MouseInput:Awake" )

    Daneel.Event.Listen( "OnLeftMouseButtonJustPressed", self.gameObject )
    Daneel.Event.Listen( "OnLeftMouseButtonDown", self.gameObject )
    Daneel.Event.Listen( "OnRightMouseButtonJustPressed", self.gameObject )
    
    if self.tags:trim() == "" then
        self.tags = {}
    else
        self.tags = self.tags:split( ",", true )
    end

    if self.gameObject.camera == nil then
        CraftStudio.Destroy( self )
        error( "MouseInput:Awake() : GameObject with name '" .. self.gameObject:GetName() .. "' has no camera component attached." )
    end  

    self.frameCount = 0
    Daneel.Debug.StackTrace.EndFunction()
end


function Behavior:OnLeftMouseButtonJustPressed()
    for i, tag in ipairs( self.tags ) do
        local gameObjects = GameObject.Tags[ tag ]
        if gameObjects ~= nil then

            for i, gameObject in ipairs( gameObjects ) do
                if gameObject ~= nil and gameObject.isDestroyed ~= true and gameObject.isMouseOver == true then
                    Daneel.Event.Fire( gameObject, "OnClick", gameObject )
                    
                    if 
                        gameObject.lastLeftClickFrame ~= nil and 
                        Daneel.Time.frameCount <= gameObject.lastLeftClickFrame + MouseInput.Config.doubleClickDelay
                    then
                        Daneel.Event.Fire( gameObject, "OnDoubleClick", gameObject )
                    end
                    
                    gameObject.lastLeftClickFrame = Daneel.Time.frameCount
                end
            end

        end
    end
end


function Behavior:OnLeftMouseButtonDown()
    local vector = CraftStudio.Input.GetMouseDelta()
    if vector.x ~= 0 or vector.y ~= 0 then

        for i, tag in ipairs( self.tags ) do
            local gameObjects = GameObject.Tags[ tag ]
            if gameObjects ~= nil then

                for i, gameObject in ipairs( gameObjects ) do
                    if gameObject ~= nil and gameObject.isDestroyed ~= true and gameObject.isMouseOver == true then
                        Daneel.Event.Fire( gameObject, "OnDrag", gameObject )
                    end
                end

            end
        end

    end
end


function Behavior:OnRightMouseButtonJustPressed()
    for i, tag in ipairs( self.tags ) do
        local gameObjects = GameObject.Tags[ tag ]
        if gameObjects ~= nil then

            for i, gameObject in ipairs( gameObjects ) do
                if gameObject ~= nil and gameObject.isDestroyed ~= true and gameObject.isMouseOver == true then
                    Daneel.Event.Fire( gameObject, "OnRightClick", gameObject )
                end
            end

        end
    end
end


function Behavior:Update()
    self.frameCount = self.frameCount + 1
    
    if 
        self.tags == 0 or self.updateInterval < 1 or 
        ( self.updateInterval > 1 and self.frameCount % self.updateInterval ~= 0 )
    then
        return
    end

    local ray = self.gameObject.camera:CreateRay( CraftStudio.Input.GetMousePosition() )

    for i, tag in ipairs( self.tags ) do
        local gameObjects = GameObject.Tags[ tag ]
        if gameObjects ~= nil then

            for i = #gameObjects, 1, -1 do
                local gameObject = gameObjects[i]
                if gameObject ~= nil and gameObject.isDestroyed ~= true then
                    if ray:IntersectsGameObject( gameObject ) ~= nil then
                        -- the mouse pointer is over the gameObject
                        -- the action will depend on if this is the first time it hovers the gameObject
                        -- or if it was already over it the last frame
                        -- also on the user's input (clicks) while it hovers the gameObject
                        if gameObject.isMouseOver == true then
                            Daneel.Event.Fire( gameObject, "OnMouseOver", gameObject )
                        else
                            gameObject.isMouseOver = true
                            Daneel.Event.Fire( gameObject, "OnMouseEnter", gameObject )
                        end
                    else
                        -- was the gameObject still hovered the last frame ?
                        if gameObject.isMouseOver == true then
                            gameObject.isMouseOver = false
                            Daneel.Event.Fire( gameObject, "OnMouseExit", gameObject )
                        end
                    end
                else
                    table.remove( gameObjects )
                end
            end

        end
    end
end
