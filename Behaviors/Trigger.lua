
-- public properties :
-- radius
-- layers (default value = "default")

-- triggerableGameObjects
local tgos = nil

function Behavior:Start()
    -- the gameObject that touches this trigger
    self.gameObjectsInRange = table.new()
    self.layers = self.layers:split(",")
    if table.containsvalue(self.layers, "all") then
        self.layers = {"all"}
    end
    tgos = Daneel.Config.Get("triggerableGameObjects")
end


function Behavior:Update()
    for i, layer in ipairs(self.layers) do
        if tgos[layer] ~= nil then
            for i, gameObject in ipairs(tgos[layer]) do
                if gameObject.inner ~= nil then
                    if Vector3.Distance(gameObject.transform.position, self.gameObject.transform.position) < self.radius then
                        -- the gameObject is "inside" a trigger
                        -- the action will depend on which trigger it is
                        -- and if this is the first time it enters this trigger
                        -- or if it was already inside it the last frame

                        if self.gameObjectsInRange:containsvalue(gameObject) == false then
                            -- just entered the trigger
                            self.gameObjectsInRange:insert(gameObject)
                            gameObject:SendMessage("OnTriggerEnter", self.gameObject)
                            self.gameObject:SendMessage("OnTriggerEnter", gameObject)
                        else
                            -- already in this trigger
                            gameObject:SendMessage("OnTriggerStay", self.gameObject)
                            self.gameObject:SendMessage("OnTriggerStay", gameObject)
                        end

                    else
                        -- was the gameObject still in this trigger the last frame ?
                        if self.gameObjectsInRange:containsvalue(gameObject) == true then
                            self.gameObjectsInRange = self.gameObjectsInRange:removevalue(gameObject)
                            gameObject:SendMessage("OnTriggerExit", self.gameObject)
                            self.gameObject:SendMessage("OnTriggerExit", gameObject)
                        end
                    end
                else
                    table.remove(tgos[layer], i)
                end
            end
        end 
    end
end

