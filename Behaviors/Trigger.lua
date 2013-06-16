
-- public properties :
-- range (default = 0)
-- layers (default = "")
-- isStatic (default = false)


function Behavior:Start()
    self.gameObjectsInRange = table.new() -- the gameObjects that touches this trigger
    if self.layers == "" then
        self.layers = {}
    else
        self.layers = self.layers:split(",")
    end
end


function Behavior:Update()
    if self.range == 0 or self.isStatic == true or #self.layers == 0 then
        return
    end
    local triggerPosition = self.gameObject.transform.position
    for i, layer in ipairs(self.layers) do
        local gameObjects = GameObject.tags[layer]
        if gameObjects ~= nil then
            for i, gameObject in ipairs(gameObjects) do
                if gameObject ~= nil and gameObject.inner ~= nil then
                    if 
                        gameObject ~= self.gameObject and 
                        Vector3.Distance(gameObject.transform.position, triggerPosition) < self.range 
                    then
                        if self.gameObjectsInRange:containsvalue(gameObject) == false then
                            -- just entered the trigger
                            self.gameObjectsInRange:insert(gameObject)
                            Daneel.Event.Fire(gameObject, "OnTriggerEnter", self.gameObject)
                            Daneel.Event.Fire(self.gameObject, "OnTriggerEnter", gameObject)
                        else
                            -- already in this trigger
                            Daneel.Event.Fire(gameObject, "OnTriggerStay", self.gameObject)
                            Daneel.Event.Fire(self.gameObject, "OnTriggerStay", gameObject)
                        end
                    else
                        -- was the gameObject still in this trigger the last frame ?
                        if self.gameObjectsInRange:containsvalue(gameObject) == true then
                            self.gameObjectsInRange:removevalue(gameObject)
                            Daneel.Event.Fire(gameObject, "OnTriggerExit", self.gameObject)
                            Daneel.Event.Fire(self.gameObject, "OnTriggerExit", gameObject)
                        end
                    end
                else
                    table.remove(gameObjects, i)
                end
            end
        end
    end
end

--- Get the gameObjets that are closer than the trigger's range.
-- @param layers (string or table) [optional] The layer(s) in which to pick the triggerable gameObjects. If nil, it uses the trigger's layer(s).
-- @return (table) The list of the gameObjects in range.
function Behavior:GetGameObjectsInRange(layers)
    local gameObjectsInRange = table.new()
    if layers == nil then
        if self.isStatic == false then
            return self.gameObjectsInRange
        end
        layers = self.layers
    end
    if type(layers) == "string" then
        layers = layers:split(",")
    end
    local triggerPosition = self.gameObject.transform.position
    for i, layer in ipairs(layers) do
        local gameObjects = GameObject.tags[layer]
        if gameObjects ~= nil then
            for i, gameObject in ipairs(gameObjects) do
                if gameObject ~= nil and gameObject.inner ~= nil then
                    if 
                        gameObject ~= self.gameObject and 
                        Vector3.Distance(gameObject.transform.position, triggerPosition) <= self.range
                    then
                        table.insert(gameObjectsInRange, gameObject)
                    end
                else
                    table.remove(gameObjects, i)
                end
            end
        end
    end
    return gameObjectsInRange
end
