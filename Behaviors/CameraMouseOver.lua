
function Behavior:Update()
    local ray = self.gameObject.camera:Ray()

    for i, gameObject in ipairs(Daneel.config.mousehoverableGameObjects) do
        if ray:IntersectsGameObject(gameObject) then
            -- the mouse pointer is over the gameObject
            -- the action will depend on if this is the first time it hovers the gameObject
            -- or if it was already over it the last frame
            -- also on the user's input (clicks) while it hovers the gameObject
            if gameObject.onMouseOver == true then
                gameObject:SendMessage("OnMouseOver")

                -- check inputs while hovering
                for i, buttonName in ipairs(Daneel.config.input.buttons) do
                    if CraftStudio.Input.IsButtonDown(buttonName) then
                        gameObject:SendMessage("OnMouseOverAnd"..buttonName:ucfirst().."ButtonDown")
                    end

                    if CraftStudio.Input.WasButtonJustPressed(buttonName) then
                        gameObject:SendMessage("OnMouseOverAnd"..buttonName:ucfirst().."ButtonJustPressed")
                    end

                    if CraftStudio.Input.WasButtonJustReleased(buttonName) then
                        gameObject:SendMessage("OnMouseOverAnd"..buttonName:ucfirst().."ButtonJustReleased")
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
    end -- end for
end