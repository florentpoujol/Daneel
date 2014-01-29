-- Mouse Input.lua
-- Enable mouse interactions with game objects when added to a game object with a camera component.
--
-- Last modified for v1.3.1
-- Copyright © 2013-2014 Florent POUJOL, published under the MIT license.

MouseInput = {}

if CS.DaneelModules == nil then
    CS.DaneelModules = {}
end
CS.DaneelModules[ "MouseInput" ] = MouseInput

function MouseInput.DefaultConfig()
    return {
        doubleClickDelay = 20, -- Maximum number of frames between two clicks of the left mouse button to be considered as a double click
    }
end
MouseInput.Config = MouseInput.DefaultConfig()

function MouseInput.Load()
    MouseInput.buttonExists = { LeftMouse = false, RightMouse = false, WheelUp = false, WheelDown = false }
    local eventList = {}
    for buttonName, _ in pairs( MouseInput.buttonExists ) do
        local exists = Daneel.Utilities.ButtonExists( buttonName )
        MouseInput.buttonExists[ buttonName ] = exists
        
        if exists then
            table.insert( eventList, "On"..buttonName.."ButtonWasJustPressed" )
            if buttonName == "LeftMouse" then
                table.insert( eventList, "OnLeftMouseButtonDown" )
            end
        end
    end

    MouseInput.update = false -- prevent the system to miss a click if it happens when  self.frameCount % self.updateInterval ~= 0  by forcing the update
    
    if #eventList > 0 then
        Daneel.Event.Listen(
            eventList,
            function() MouseInput.update = true end,
            true -- persistent listener
        )
    end
end


----------------------------------------------------------------------------------

--[[PublicProperties
tags string ""
onMouseOverInterval number 0
updateWhenMouseMoves boolean true
/PublicProperties]]

function Behavior:Awake()
    if not Daneel.isLoaded then
        Daneel.LateLoad( "MouseInput.Awake" )
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

    if 
        MouseInput.update or
        (mouseIsMoving and self.updateWhenMouseMoves) or
        ( self.onMouseOverInterval > 0 and self.frameCount % self.onMouseOverInterval == 0 )
    then
        MouseInput.update = false

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
        
        --
        local doubleClick = false
        if leftMouseJustPressed then
            doubleClick = ( self.frameCount <= self.lastLeftClickFrame + MouseInput.Config.doubleClickDelay )   
            self.lastLeftClickFrame = self.frameCount
        end

        local mousePosition = CS.Input.GetMousePosition()
        local reindex = true
        
        for i, tag in pairs( self.tags ) do
            local gameObjects = GameObject.Tags[ tag ]
            if gameObjects ~= nil then

                for i, gameObject in pairs( gameObjects ) do
                    if gameObject.inner ~= nil then
                        -- OnMouseEnter, OnMouseOver, OnMouseExit, gameObject.isMouseOver
                        local ray = self.gameObject.camera:CreateRay( mousePosition )
                                                
                        if ray:IntersectsGameObject( gameObject ) then
                            -- the mouse pointer is over the gameObject
                            -- the action will depend on if this is the first time it hovers the gameObject
                            -- or if it was already over it the last frame
                            -- also on the user's input (clicks) while it hovers the gameObject
                            if gameObject.isMouseOver then
                                Daneel.Event.Fire( gameObject, "OnMouseOver", gameObject )
                            else
                                gameObject.isMouseOver = true
                                Daneel.Event.Fire( gameObject, "OnMouseEnter", gameObject )
                            end                           

                        elseif gameObject.isMouseOver then
                            -- the gameObject was still hovered the last frame
                            gameObject.isMouseOver = false
                            Daneel.Event.Fire( gameObject, "OnMouseExit", gameObject )
                        end
                        

                        if gameObject.isMouseOver then
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
