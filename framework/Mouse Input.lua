-- Mouse Input.lua
-- Enable mouse interactions with game objects when added to a game object with a camera component.
--
-- Last modified for v1.5
-- Copyright © 2013-2014 Florent POUJOL, published under the MIT license.

MouseInput = { 
    buttonExists = { LeftMouse = false, RightMouse = false, WheelUp = false, WheelDown = false },
    
    frameCount = 0,
    lastLeftClickFrame = 0,

    components = {}, -- array of mouse input components
}
Daneel.modules.MouseInput = MouseInput

MouseInput.DefaultConfig = {
    doubleClickDelay = 20, -- Maximum number of frames between two clicks of the left mouse button to be considered as a double click

    mouseInput = {
        tags = {}
    },

    componentObjects = {
        MouseInput = MouseInput,
    },
}
MouseInput.Config = MouseInput.DefaultConfig

function MouseInput.Load()
    for buttonName, _ in pairs( MouseInput.buttonExists ) do
        MouseInput.buttonExists[ buttonName ] = Daneel.Utilities.ButtonExists( buttonName )
    end

    MouseInput.lastLeftClickFrame = -MouseInput.Config.doubleClickDelay
end

-- Loop on the MouseInput.components.
-- Works with the game objects that have at least one of the component's tag.
-- Check the position of the mouse against these game objects.
-- Fire events accordingly.
function MouseInput.Update()
    MouseInput.frameCount = MouseInput.frameCount + 1
    
    local mouseDelta = CS.Input.GetMouseDelta()
    local mouseIsMoving = false
    if mouseDelta.x ~= 0 or mouseDelta.y ~= 0 then
        mouseIsMoving = true
    end

    local leftMouseJustPressed = false
    local leftMouseDown = false
    local leftMouseJustReleased = false
    if MouseInput.buttonExists.LeftMouse then
        leftMouseJustPressed = CS.Input.WasButtonJustPressed( "LeftMouse" )
        leftMouseDown = CS.Input.IsButtonDown( "LeftMouse" )
        leftMouseJustReleased = CS.Input.WasButtonJustReleased( "LeftMouse" )
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
        mouseIsMoving == true or
        leftMouseJustPressed == true or 
        leftMouseDown == true or
        leftMouseJustReleased == true or 
        rightMouseJustPressed == true or
        wheelUpJustPressed == true or
        wheelDownJustPressed == true
    then
        local doubleClick = false
        if leftMouseJustPressed then
            doubleClick = ( MouseInput.frameCount <= MouseInput.lastLeftClickFrame + MouseInput.Config.doubleClickDelay )   
            MouseInput.lastLeftClickFrame = MouseInput.frameCount
        end

        local reindexComponents = false
        local reindexGameObjects = false

        for i=1, #MouseInput.components do
            local component = MouseInput.components[i]
            local mi_gameObject = component.gameObject -- mouse input game object

            if mi_gameObject.inner ~= nil and not mi_gameObject.isDestroyed and mi_gameObject.camera ~= nil then
                local ray = mi_gameObject.camera:CreateRay( CS.Input.GetMousePosition() )
                
                for j=1, #component.tags do
                    local tag = component.tags[j]
                    local gameObjects = GameObject.Tags[ tag ]
                    if gameObjects ~= nil then

                        for k=1, #gameObjects do
                            local gameObject = gameObjects[k]
                            -- gameObject is the game object whose position is checked against the raycasthit
                            if gameObject.inner ~= nil and not gameObject.isDestroyed then
                                
                                local raycastHit = ray:IntersectsGameObject( gameObject )
                                if raycastHit ~= nil then
                                    -- the mouse pointer is over the gameObject
                                    if not gameObject.isMouseOver then
                                        gameObject.isMouseOver = true
                                        Daneel.Event.Fire( gameObject, "OnMouseEnter", gameObject )
                                    end

                                elseif gameObject.isMouseOver == true then
                                    -- the gameObject was still hovered the last frame
                                    gameObject.isMouseOver = false
                                    Daneel.Event.Fire( gameObject, "OnMouseExit", gameObject )
                                end
                                
                                if gameObject.isMouseOver == true then
                                    Daneel.Event.Fire( gameObject, "OnMouseOver", gameObject, raycastHit )

                                    if leftMouseJustPressed == true then
                                        Daneel.Event.Fire( gameObject, "OnClick", gameObject )

                                        if doubleClick == true then
                                            Daneel.Event.Fire( gameObject, "OnDoubleClick", gameObject )
                                        end
                                    end

                                    if leftMouseDown == true and mouseIsMoving == true then
                                        Daneel.Event.Fire( gameObject, "OnDrag", gameObject )
                                    end

                                    if leftMouseJustReleased == true then
                                        Daneel.Event.Fire( gameObject, "OnLeftClickReleased", gameObject )
                                    end

                                    if rightMouseJustPressed == true then
                                        Daneel.Event.Fire( gameObject, "OnRightClick", gameObject )
                                    end

                                    if wheelUpJustPressed == true then
                                        Daneel.Event.Fire( gameObject, "OnWheelUp", gameObject )
                                    end
                                    if wheelDownJustPressed == true then
                                        Daneel.Event.Fire( gameObject, "OnWheelDown", gameObject )
                                    end
                                end
                            else 
                                -- gameObject is dead
                                gameObjects[ i ] = nil
                                reindexGameObjects = true
                            end
                        end -- for gameObjects with current tag

                        if reindexGameObjects == true then
                            GameObject.Tags[ tag ] = table.reindex( gameObjects )
                            reindexGameObjects = false
                        end
                    end -- if some game objects have this tag
                end -- for component.tags
            else
                -- this component's game object is dead or has no camera component
                MouseInput.components[i] = nil
                reindexComponents = true
            end -- gameObject is alive
        end -- for MouseInput.components

        if reindexComponents == true then
            table.reindex( MouseInput.components )
        end
    end -- if mouseIsMoving, ...
end -- MouseInput.Update() 

--- Create a new MouseInput component.
-- @param gameObject (GameObject) The game object.
-- @param params (table) A table of parameters.
-- @return (MouseInput) The new component.
function MouseInput.New( gameObject, params )
    if gameObject.camera == nil then
        error( "MouseInput.New(gameObject, params) : "..tostring(gameObject).." has no Camera component." )
        return
    end

    local component = table.copy( MouseInput.Config.mouseInput )
    component.gameObject = gameObject
    gameObject.mouseInput = component
    setmetatable( component, MouseInput )  
    component:Set(params or {})

    table.insert( MouseInput.components, component )
    return component
end
