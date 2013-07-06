
-- Public properties :
-- range (number) [default= 0]
-- layers (string) [default=""]
-- isStatic (boolean) [default=false]


function Behavior:Awake()
    self.gameObjectsInRange = table.new() -- the gameObjects that touches this trigger
    if self.layers == "" then
        self.layers = {}
    else
        self.layers = self.layers:split(",", true)
    end
end


function Behavior:Update()
    if self.range <= 0 or self.isStatic == true or #self.layers == 0 then
        return
    end
    local triggerPosition = self.gameObject.transform.position
    
    for i, layer in ipairs(self.layers) do
        local gameObjects = GameObject.tags[layer]
        if gameObjects ~= nil then
            
            for i = #gameObjects, i, -1 do
                local gameObject = gameObjects[i]
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
                    table.remove(gameObjects)
                end
            end

        end
    end
end

--- Get the gameObjets that are closer than the trigger's range.
-- @param tags [optional] (string or table) The tags(s) the gameObjects must have. If nil, it uses the trigger's layer(s).
-- @param range [optional] (number) The range within which to pick the gameObjects. If nil, it uses the trigger's range.
-- @return (table) The list of the gameObjects in range (empty if none in range).
function Behavior:GetGameObjectsInRange( tags, range )
    if type( tags ) == "number" then
        range = tags
        tags = nil
    end

    local errorHead = "Trigger:GetGameObjectsInRange( [tags, range] ) : "
    Daneel.Debug.CheckOptionalArgType( tags, "tags", {"string", "table"}, errorHead)

    if tags == nil then
        if self.isStatic == false then
            if self.gameObjectsInRange == nil then -- happens when called before Awake is called
                self.gameObjectsInRange = {}
            end
            return self.gameObjectsInRange
        end
        tags = self.layers
    end
    if type( tags ) == "string" then
        tags = tags:split( ",", true )
    end

    range = Daneel.Debug.CheckOptionalArgType( range, "range", "number", errorHead, self.range)
    
    local gameObjectsInRange = table.new()

    local triggerPosition = self.gameObject.transform.position
    for i, layer in ipairs( tags ) do
        local gameObjects = GameObject.tags[ layer ]
        if gameObjects ~= nil then
            for i, gameObject in ipairs( gameObjects ) do
                if 
                    gameObject ~= nil and gameObject.inner ~= nil and
                    gameObject ~= self.gameObject and 
                    Vector3.Distance( gameObject.transform.position, triggerPosition ) <= self.range
                then
                    table.insert( gameObjectsInRange, gameObject )
                end
            end
        end
    end
    return gameObjectsInRange
end
