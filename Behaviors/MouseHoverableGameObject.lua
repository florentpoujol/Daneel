
function Behavior:Awake()
    self.camera = Daneel.config.HUDCamera
end

function Behavior:Update()
    local ray = self.camera:Ray()
    
    if ray:IntersectsGameObject(sef.gameObject) then
        -- the mouse pointer is over the gameObject
        -- the action will depend on if this is the first time it hovers the gameObject
        -- or if it was already over it the last frame
        -- also on the user's input (clicks) while it hovers the gameObject
        if self.gameObject.onMouseOver == true then
            self.gameObject:SendMessage("OnMouseOver")

            -- check inputs while hovering
            for i, buttonName in ipairs(Daneel.config.input.buttons) do
                if CraftStudio.Input.WasButtonJustPressed(buttonName) then
                    self.gameObject:SendMessage("OnMouseOverAnd"..buttonName.."Pressed")
                end
            end
        else
            self.gameObject.onMouseOver = true
            self.gameObject:SendMessage("OnMouseEnter")
        end
    else
        -- was the self.gameObject still hovered the last frame ?
        if self.gameObject.onMouseOver == true then
            self.gameObject.onMouseOver = false
            self.gameObject:SendMessage("OnMouseExit")
        end
    end
end