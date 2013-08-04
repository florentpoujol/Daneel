-- Trigger.lua
-- Scripted behavior for triggers.
--
-- Last modified for v1.2.1
-- Copyright © 2013 Florent POUJOL, published under the MIT licence.

--[[PublicProperties
range number 0
tags string ""
updateInterval number 10
/PublicProperties]]

function Behavior:Awake()
    self.GameObjectsInRange = {} -- the gameObjects that touches this trigger

    if self.tags:trim() == "" then
        self.tags = {}
    else
        self.tags = self.tags:split( ",", true )
    end

    self.frameCount = 0

    if self.gameObject.modelRenderer ~= nil then
        self.gameObject.modelRenderer:SetOpacity( 0 )
    end
    if self.gameObject.mapRenderer ~= nil then
        self.gameObject.mapRenderer:SetOpacity( 0 )
    end
end


function Behavior:Update()
    self.frameCount = self.frameCount + 1

    if 
        self.updateInterval < 1 or #self.tags == 0 or
        ( self.updateInterval > 1 and self.frameCount % self.updateInterval ~= 0 )
    then
        return
    end

    local triggerPosition = self.gameObject.transform:GetPosition()
    
    for i, layer in ipairs( self.tags ) do
        local gameObjects = GameObject.Tags[ layer ]
        if gameObjects ~= nil then
            
            for i = #gameObjects, i, -1 do
                local gameObject = gameObjects[ i ]
                if gameObject ~= nil and gameObject.isDestroyed ~= true and gameObject ~= self.gameObject then

                    local gameObjectIsInTrigger = false
                    local gameObjectPosition = gameObject.transform:GetPosition()
                    local directionToTrigger = triggerPosition - gameObjectPosition
                    local distanceToTriggerSquared = directionToTrigger:SqrLength()

                    if self.range > 0 and distanceToTriggerSquared < self.range^2 then
                        gameObjectIsInTrigger = true

                    elseif self.range <= 0 then
                        local ray = Ray:New( gameObjectPosition, directionToTrigger ) -- ray from the gameObject to the trigger
                        local distance = nil

                        if gameObject.modelRenderer ~= nil then
                            distance = ray:IntersectsModelRenderer( gameObject.modelRenderer )
                        elseif gameObject.mapRenderer ~= nil then
                            distance = ray:IntersectsMapRenderer( gameObject.mapRenderer )
                        end

                        if distance ~= nil and distance^2 > distanceToTriggerSquared then
                            -- distance from the GO to the model or map is superior to the distance to the trigger
                            -- that means the GO is inside of the mode/map
                            -- the ray goes throught the GO origin before intersecting the map 
                            gameObjectIsInTrigger = true
                        end
                    end


                    if gameObjectIsInTrigger then
                        if not table.containsvalue( self.GameObjectsInRange, gameObject ) then
                            -- just entered the trigger
                            table.insert( self.GameObjectsInRange, gameObject )
                            Daneel.Event.Fire( gameObject, "OnTriggerEnter", self.gameObject )
                            Daneel.Event.Fire( self.gameObject, "OnTriggerEnter", gameObject )
                        else
                            -- already in this trigger
                            Daneel.Event.Fire( gameObject, "OnTriggerStay", self.gameObject )
                            Daneel.Event.Fire( self.gameObject, "OnTriggerStay", gameObject )
                        end
                    else
                        -- was the gameObject still in this trigger the last frame ?
                        if table.containsvalue( self.GameObjectsInRange, gameObject ) then
                            table.removevalue( self.GameObjectsInRange, gameObject )
                            Daneel.Event.Fire( gameObject, "OnTriggerExit", self.gameObject )
                            Daneel.Event.Fire( self.gameObject, "OnTriggerExit", gameObject )
                        end
                    end

                else
                    table.remove( gameObjects )
                end
            end

        end
    end
end

--- Get the gameObjets that are closer than the trigger's range.
-- @param tags [optional] (string or table) The tags(s) the gameObjects must have. If nil, it uses the trigger's tags(s).
-- @param range [optional] (number) The range within which to pick the gameObjects. If nil, it uses the trigger's range.
-- @return (table) The list of the gameObjects in range (empty if none in range).
function Behavior:GetGameObjectsInRange( tags, range )
    if type( tags ) == "number" then
        range = tags
        tags = nil
    end

    local errorHead = "Trigger:GetGameObjectsInRange( [tags, range] ) : "
    Daneel.Debug.CheckOptionalArgType( tags, "tags", {"string", "table"}, errorHead )

    if tags == nil then
        tags = self.tags
    end
    if type( tags ) == "string" then
        tags = { tags }
    end

    range = Daneel.Debug.CheckOptionalArgType( range, "range", "number", errorHead, self.range )
    
    local gameObjectsInRange = {}
    local triggerPosition = self.gameObject.transform:GetPosition()
    
    for i, layer in ipairs( tags ) do
        local gameObjects = GameObject.Tags[ layer ]
        if gameObjects ~= nil then

            for i, gameObject in ipairs( gameObjects ) do
                if gameObject ~= nil and gameObject.isDestroyed ~= true and gameObject ~= self.gameObject then 
                    
                    local gameObjectIsInTrigger = false
                    local gameObjectPosition = gameObject.transform:GetPosition()
                    local directionToTrigger = triggerPosition - gameObjectPosition
                    local distanceToTriggerSquared = directionToTrigger:SqrLength()

                    if self.range > 0 and distanceToTriggerSquared < self.range^2 then
                        gameObjectIsInTrigger = true

                    elseif self.range <= 0 then
                        local ray = Ray:New( gameObjectPosition, directionToTrigger ) -- ray from the gameObject to the trigger
                        local distance = nil

                        if gameObject.modelRenderer ~= nil then
                            distance = ray:IntersectsModelRenderer( gameObject.modelRenderer )
                        elseif gameObject.mapRenderer ~= nil then
                            distance = ray:IntersectsMapRenderer( gameObject.mapRenderer )
                        end

                        if distance ~= nil and distance^2 > distanceToTriggerSquared then
                            -- distance from the GO to the model or map is superior to the distance to the trigger
                            -- that means the GO is inside of the mode/map
                            -- the ray goes throught the GO origin before intersecting the map 
                            gameObjectIsInTrigger = true
                        end
                    end

                    if gameObjectIsInTrigger then
                        table.insert( gameObjectsInRange, gameObject )
                    end

                end
            end

        end
    end

    return gameObjectsInRange
end
