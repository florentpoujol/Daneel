-- Trigger.lua
-- Scripted behavior for triggers.
--
-- Last modified for v1.3
-- Copyright © 2013 Florent POUJOL, published under the MIT license.

--[[PublicProperties
tags string ""
range number 0
updateInterval number 5
/PublicProperties]]

function Behavior:Awake()
    self.gameObject.trigger = self
    self.GameObjectsInRange = {} -- the gameObjects that touches this trigger
    self.tags = self.tags:split( ",", true )
    self.frameCount = 0
    self.ray = Ray:New()
end

function Behavior:Update()
    self.frameCount = self.frameCount + 1
    if self.updateInterval > 1 and #self.tags > 0 and self.frameCount % self.updateInterval == 0 then
        local triggerPosition = self.gameObject.transform:GetPosition()
        
        if type( self.tags ) == "string" then
            self.tags = self.tags:split( ",", true )
        end
    
        for i, tag in pairs( self.tags ) do
            local gameObjects = GameObject.Tags[ tag ]
            if gameObjects ~= nil then
                
                for i, gameObject in pairs( gameObjects ) do
                    local gameObject = gameObjects[ i ]
                    if gameObject.transform == nil then
                        table.remove( gameObjects, i )
                    elseif gameObject ~= self.gameObject then

                        local gameObjectIsInRange = self:IsGameObjectInRange( gameObject, triggerPosition )
                        local gameObjectWasInRange = table.containsvalue( self.GameObjectsInRange, gameObject )

                        if gameObjectIsInRange then
                            if gameObjectWasInRange then
                                -- already in this trigger
                                Daneel.Event.Fire( gameObject, "OnTriggerStay", self.gameObject )
                                Daneel.Event.Fire( self.gameObject, "OnTriggerStay", gameObject )
                            else
                                -- just entered the trigger
                                table.insert( self.GameObjectsInRange, gameObject )
                                Daneel.Event.Fire( gameObject, "OnTriggerEnter", self.gameObject )
                                Daneel.Event.Fire( self.gameObject, "OnTriggerEnter", gameObject )
                            end
                        else
                            -- was the gameObject still in this trigger the last frame ?
                            if table.containsvalue( self.GameObjectsInRange, gameObject ) then
                                table.removevalue( self.GameObjectsInRange, gameObject )
                                Daneel.Event.Fire( gameObject, "OnTriggerExit", self.gameObject )
                                Daneel.Event.Fire( self.gameObject, "OnTriggerExit", gameObject )
                            end
                        end

                    end
                end

            end
        end
    end
end

--- Get the gameObjets that are within range of that trigger.
-- @return (table) The list of the gameObjects in range (empty if none in range).
function Behavior:GetGameObjectsInRange()
    Daneel.Debug.StackTrace.BeginFunction( "Trigger:GetGameObjectsInRange" )
    local gameObjectsInRange = {}
    local triggerPosition = self.gameObject.transform:GetPosition()
    
    if type( self.tags ) == "string" then
        self.tags = self.tags:split( ",", true )
    end
    for i, tag in pairs( self.tags ) do
        local gameObjects = GameObject.Tags[ tag ]
        if gameObjects ~= nil then

            for i, gameObject in pairs( gameObjects ) do
                if 
                    gameObject.transform ~= nil and gameObject ~= self.gameObject and
                    self:IsGameObjectInRange( gameObject, triggerPosition ) and
                    not table.containsvalue( gameObjectsInRange, gameObject )
                then
                    table.insert( gameObjectsInRange, gameObject )
                end
            end
        end
    end

    Daneel.Debug.StackTrace.EndFunction()
    return gameObjectsInRange
end

--- Tell whether the provided game object is in range of the trigger.
-- @param gameObject (GameObject) The gameObject.
-- @param triggerPosition (Vector3) [optional] The trigger's current position.
-- @return (boolean) True or false.
function Behavior:IsGameObjectInRange( gameObject, triggerPosition )
    Daneel.Debug.StackTrace.BeginFunction( "Trigger:IsGameObjectInRange", gameObject, triggerPosition )
    local errorHead = "Behavior:IsGameObjectInRange( gameObject[, triggerPosition] )"
    Daneel.Debug.CheckArgType( gameObject, "gameObject", "GameObject", errorHead )
    Daneel.Debug.CheckOptionalArgType( triggerPosition, "triggerPosition", "Vector3", errorHead )
    if triggerPosition == nil then
        triggerPosition = self.gameObject.transform:GetPosition()
    end 

    local gameObjectIsInTrigger = false
    local gameObjectPosition = gameObject.transform:GetPosition()
    local directionToTrigger = triggerPosition - gameObjectPosition
    local distanceToTriggerSquared = directionToTrigger:SqrLength()

    if self.range > 0 and distanceToTriggerSquared < self.range^2 then
        gameObjectIsInTrigger = true

    elseif self.range <= 0 then
        self.ray.position = gameObjectPosition
        self.ray.direction = directionToTrigger -- ray from the gameObject to the trigger
        local distance = nil

        if gameObject.modelRenderer ~= nil then
            distance = self.ray:IntersectsModelRenderer( gameObject.modelRenderer )
        elseif gameObject.mapRenderer ~= nil then
            distance = self.ray:IntersectsMapRenderer( gameObject.mapRenderer )
        end

        if distance ~= nil and distance^2 > distanceToTriggerSquared then
            -- distance from the GO to the model or map is superior to the distance to the trigger
            -- that means the GO is inside of the model/map
            -- the ray goes through the GO origin before intersecting the map 
            gameObjectIsInTrigger = true
        end
    end

    Daneel.Debug.StackTrace.EndFunction()
    return gameObjectIsInTrigger
end
