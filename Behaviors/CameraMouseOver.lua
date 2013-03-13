
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