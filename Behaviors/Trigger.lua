
-- public properties :
-- distance

function Behavior:Awake()
    -- the gameObject that touches this trigger
    self.gameObjects = table.new()
end


function Behavior:Update()
    local tObject = Daneel.Trigger.triggerableGameObjects

    for i, gameObject in ipairs(tObject) do
        if gameObject ~= nil then
            if Vector3.Distance(gameObject.transform.position, self.gameObject.transform.position) < self.radius then
                -- the gameObject is "inside" a trigger
                -- the action will depend on which trigger it is
                -- and if this is the first time it enters this trigger
                -- or if it was already inside it the last frame

                if self.gameObjects:containsvalue(gameObject) == false then
                    -- just entered the trigger
                    self.gameObjects:insert(gameObject)
                    gameObject:SendMessage("OnTriggerEnter", {gameObject = self.gameObject})
                else
                    -- already in this trigger
                    gameObject:SendMessage("OnTriggerStay", {gameObject = self.gameObject})
                end

            else
                -- was the gameObject still in this trigger the last frame ?
                if self.gameObjects:containsvalue(gameObject) == true then
                    self.gameObjects = self.gameObjects:removevalue(gameObject)
                    gameObject:SendMessage("OnTriggerExit", {gameObject = self.gameObject})
                end
            end
        else
            table.remove(Daneel.Trigger.triggerableGameObjects, i)
        end
    end
    
end