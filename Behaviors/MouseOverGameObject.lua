
function Behavior:Awake()
    self.camera =  Daneel.config.HUDCamera
    self.leftMouseButtonName = Daneel.config.input.leftMouseButtonName
end

function Behavior:Update()
    -- get the camera,
    -- lauch a ray,
    -- check if it intersects with a mouse overable gameObject

    -- events
    -- on mouse enter
    -- on mouse over
    -- on mouse leave
    -- on click
    -- on left click
    -- on right click

    local ray = self.camera:Ray()
    local mouseGOs = Daneel.config.mouseHoverableGameObjects

    for i, gameObject in ipairs(mouseGOs) do
        if gameObject ~= nil then
            if ray:IntersectsGameObject(gameObject) then

                -- the mouse pointer is over the gameObject
                -- the action will depend on if this is the first time it enters this trigger
                -- or if it was already inside it the last frame
                -- also on the user's input (clicks) while it hovers the gameObject
                if gameObject.onMouseOver == true then
                    gameObject:SendMessage("OnMouseOver")

                    -- check inputs while hovering
                    for buttonKey, buttonName in pairs(Daneel.config.input) do
                        if CraftStudio.Input.WasButtonJustPressed(buttonName) then
                            gameObject:SendMessage("OnMouseOverAnd"..buttonName.."Pressed")
                        end
                    end
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
            table.remove(Daneel.config.mouseHoverableGameObjects, i)
        end
    end
    
end