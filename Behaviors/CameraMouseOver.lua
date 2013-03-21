-- Add this script as ScriptedBehavior on your camera

function Behavior:Update()
    local ray = self.gameObject.camera:CreateRay(CraftStudio.Input.GetMousePosition())

    for i, gameObject in ipairs(Daneel.config.mousehoverableGameObjects) do
        if gameObject ~= nil then
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
            table.remove(Daneel.config.mousehoverableGameObjects, i)
        end
    end
end
