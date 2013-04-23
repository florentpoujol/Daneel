
-- public properties :
-- radius

function Behavior:Awake()
    -- the gameObject that touches this trigger
    self.gameObjectsInRange = table.new()
end


function Behavior:Update()
    local tObject = config.default.triggerableGameObjects

    for i, gameObject in ipairs(tObject) do
        if gameObject ~= nil then
            if Vector3.Distance(gameObject.transform.position, self.gameObject.transform.position) < self.radius then
                -- the gameObject is "inside" a trigger
                -- the action will depend on which trigger it is
                -- and if this is the first time it enters this trigger
                -- or if it was already inside it the last frame

                if self.gameObjectsInRange:containsvalue(gameObject) == false then
                    -- just entered the trigger
                    self.gameObjectsInRange:insert(gameObject)
                    gameObject:SendMessage("OnTriggerEnter", self.gameObject)
                else
                    -- already in this trigger
                    gameObject:SendMessage("OnTriggerStay", self.gameObject)
                end

            else
                -- was the gameObject still in this trigger the last frame ?
                if self.gameObjectsInRange:containsvalue(gameObject) == true then
                    self.gameObjectsInRange = self.gameObjectsInRange:removevalue(gameObject)
                    gameObject:SendMessage("OnTriggerExit", self.gameObject)
                end
            end
        else
            table.remove(config.default.triggerableGameObjects, i)
        end
    end
    
end