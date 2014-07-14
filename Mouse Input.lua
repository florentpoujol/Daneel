-- Mouse Input.lua
-- Enable mouse interactions with game objects when added to a game object with a camera component.
--
-- Last modified for v1.3.1
-- Copyright © 2013-2014 Florent POUJOL, published under the MIT license.

MouseInput = { 
    buttonExists = { LeftMouse = false, RightMouse = false, WheelUp = false, WheelDown = false }
}
Daneel.modules.MouseInput = MouseInput

MouseInput.DefaultConfig = {
    doubleClickDelay = 20, -- Maximum number of frames between two clicks of the left mouse button to be considered as a double click
}
MouseInput.Config = MouseInput.DefaultConfig

function MouseInput.Load()
    if Daneel.modules.Tags == nil then
        print( "ERROR : MouseInput.Load() : the 'Tags' module is missing." )
        GameObject.Tags = {} -- prevent the script to throw bazillion errors in Update
    end
    for buttonName, _ in pairs( MouseInput.buttonExists ) do
        MouseInput.buttonExists[ buttonName ] = Daneel.Utilities.ButtonExists( buttonName )
    end
end

local MouseInputScriptAsset = Behavior
Daneel.Event.Listen( "GameObject.On", function( gameObject, eventName, _function )
    -- find game object with camera in ancestry
    local cameraGO = gameObject:GetInAncestors( function( parent ) if parent.camera ~= nil then return true end end )
    if cameraGO ~= nil then
        local miScript = cameraGO:GetScriptedBehavior( MouseInputScriptAsset )
        if miScript == nil then
            cameraGO:CreateScriptedBehavior( MouseInputScriptAsset )
        end
        table.insertonce( miScript.tags, "mouseinput" )
        gameObject:AddTag( "mouseinput" )
    else
        error("MouseInput: 'GameObject.On' event: You tried to use mouse input event '"..eventName.."' on the "..tostring(gameObject)..", which is not a child of a game object with a camera component.")
    end
end )


----------------------------------------------------------------------------------

--[[PublicProperties
tags string ""
OnMouseOverInterval number 0
/PublicProperties]]

function Behavior:Awake()
    if not MouseInput.isLoaded then
        if table.getvalue( _G, "MouseInputUserConfig" ) ~= nil and type( MouseInputUserConfig ) == "function" then
            MouseInput.Config = MouseInputUserConfig()
        end
        MouseInput.Load()
        MouseInput.isLoaded = true
    end

    Daneel.Debug.StackTrace.BeginFunction( "MouseInput:Awake" )

    if self.gameObject.camera == nil then
        CS.Destroy( self )
        error( "MouseInput:Awake() : GameObject with name '" .. self.gameObject:GetName() .. "' has no Camera component attached." )
    end  

    self.tags = string.split( self.tags, "," )
    for k, v in pairs( self.tags ) do
        self.tags[ k ] = string.trim( v )
    end
    self.gameObject.mouseInput = self
    self.frameCount = 0
    self.lastLeftClickFrame = -MouseInput.Config.doubleClickDelay

    Daneel.Debug.StackTrace.EndFunction()
end

function Behavior:Update()
    self.frameCount = self.frameCount + 1
    
    local mouseDelta = CS.Input.GetMouseDelta()
    local mouseIsMoving = false
    if mouseDelta.x ~= 0 or mouseDelta.y ~= 0 then
        mouseIsMoving = true
    end

    local leftMouseJustPressed = false
    local leftMouseDown = false
    if MouseInput.buttonExists.LeftMouse then
        leftMouseJustPressed = CS.Input.WasButtonJustPressed( "LeftMouse" )
        leftMouseDown = CS.Input.IsButtonDown( "LeftMouse" )
    end

    local rightMouseJustPressed = false
    if MouseInput.buttonExists.RightMouse then
        rightMouseJustPressed = CS.Input.WasButtonJustPressed( "RightMouse" )
    end

    local wheelUpJustPressed = false
    if MouseInput.buttonExists.WheelUp then
        wheelUpJustPressed = CS.Input.WasButtonJustPressed( "WheelUp" )
    end

    local wheelDownJustPressed = false
    if MouseInput.buttonExists.WheelDown then
        wheelDownJustPressed = CS.Input.WasButtonJustPressed( "WheelDown" )
    end
    
    if 
        mouseIsMoving or
        leftMouseJustPressed or 
        leftMouseDown or
        rightMouseJustPressed or
        wheelUpJustPressed or
        wheelDownJustPressed or
        (self.OnMouseOverInterval > 0 and self.frameCount % self.OnMouseOverInterval == 0 )
    then
        local doubleClick = false
        if leftMouseJustPressed then
            doubleClick = ( self.frameCount <= self.lastLeftClickFrame + MouseInput.Config.doubleClickDelay )   
            self.lastLeftClickFrame = self.frameCount
        end

        local ray = self.gameObject.camera:CreateRay( CS.Input.GetMousePosition() )
        local reindex = true
        
        for i, tag in pairs( self.tags ) do
            local gameObjects = GameObject.Tags[ tag ]
            if gameObjects ~= nil then

                for i, gameObject in pairs( gameObjects ) do
                    if gameObject.inner ~= nil then
                        
                        local raycastHit = ray:IntersectsGameObject( gameObject )
                        if raycastHit ~= nil then
                            -- the mouse pointer is over the gameObject
                            if not gameObject.isMouseOver then
                                gameObject.isMouseOver = true
                                Daneel.Event.Fire( gameObject, "OnMouseEnter", gameObject )
                            end

                        elseif gameObject.isMouseOver then
                            -- the gameObject was still hovered the last frame
                            gameObject.isMouseOver = false
                            Daneel.Event.Fire( gameObject, "OnMouseExit", gameObject )
                        end
                        
                        if gameObject.isMouseOver then
                            Daneel.Event.Fire( gameObject, "OnMouseOver", gameObject, raycastHit )

                            if leftMouseJustPressed then
                                Daneel.Event.Fire( gameObject, "OnClick", gameObject )

                                if doubleClick then
                                    Daneel.Event.Fire( gameObject, "OnDoubleClick", gameObject )
                                end
                            end

                            if leftMouseDown and mouseIsMoving then
                                Daneel.Event.Fire( gameObject, "OnDrag", gameObject )
                            end

                            if rightMouseJustPressed then
                                Daneel.Event.Fire( gameObject, "OnRightClick", gameObject )
                            end

                            if wheelUpJustPressed then
                                Daneel.Event.Fire( gameObject, "OnWheelUp", gameObject )
                            end
                            if wheelDownJustPressed then
                                Daneel.Event.Fire( gameObject, "OnWheelDown", gameObject )
                            end
                        end
                    else -- else if gameObject is destroyed
                        gameObjects[ i ] = nil
                        reindex = true
                    end
                end -- end looping on gameObjects with current tag

                if reindex then
                    GameObject.Tags[ tag ] = table.reindex( gameObjects )
                    reindex = false
                end
            end
        end -- end looping on tags
    end
end -- end of Behavior:Update() function
