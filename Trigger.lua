-- Trigger.lua
-- Scripted behavior for triggers.
--
-- Last modified for v1.3.1
-- Copyright © 2013 Florent POUJOL, published under the MIT license.


Daneel.modules.Trigger = {
    Load = function()
        if Daneel.modules.Tags == nil then
            print( "ERROR : Trigger.Load() : the 'Tags' module is missing." )
            GameObject.Tags = {} -- prevent the script to throw bazillion errors in Update
        end
    end
}


--[[PublicProperties
tags string ""
range number 0
updateInterval number 5
/PublicProperties]]

function Behavior:Awake()
    self.gameObject.trigger = self
    self.GameObjectsInRange = {} -- the gameObjects that touches this trigger
    self.tags = string.split( self.tags, "," )
    for k, v in pairs( self.tags ) do
        self.tags[ k ] = string.trim( v )
    end
    self.frameCount = 0
    self.ray = Ray:New()
end

function Behavior:Update()
    self.frameCount = self.frameCount + 1
    if self.updateInterval > 1 and #self.tags > 0 and self.frameCount % self.updateInterval == 0 then
        local triggerPosition = self.gameObject.transform:GetPosition()
        
        if type( self.tags ) == "string" then
            self.tags = string.split( self.tags, "," )
            for k, v in pairs( self.tags ) do
                self.tags[ k ] = string.trim( v )
            end
        end
        
        local reindex = false
        
        for i, tag in pairs( self.tags ) do
            local gameObjects = GameObject.Tags[ tag ]
            if gameObjects ~= nil then
                
                for i, gameObject in pairs( gameObjects ) do
                    local gameObject = gameObjects[ i ]
                    if gameObject.inner == nil then
                        gameObjects[ i ] = nil
                        reindex = true
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

                if reindex then
                    GameObject.Tags[ tag ] = table.reindex( gameObjects )
                    reindex = false
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
        self.tags = string.split( self.tags, "," )
        for k, v in pairs( self.tags ) do
            self.tags[ k ] = string.trim( v )
        end
    end
    
    for i, tag in pairs( self.tags ) do
        local gameObjects = GameObject.Tags[ tag ]
        if gameObjects ~= nil then

            for i, gameObject in pairs( gameObjects ) do
                if 
                    gameObject.inner ~= nil and gameObject ~= self.gameObject and
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
    local directionToGameObject = gameObjectPosition - triggerPosition
    local sqrDistanceToGameObject = directionToGameObject:SqrLength()

    if self.range > 0 and distanceToTriggerSquared < self.range^2 then
        gameObjectIsInTrigger = true

    elseif self.range <= 0 then
        self.ray.position = triggerPosition
        self.ray.direction = directionToGameObject -- ray from the trigger to the game object
        
        local distanceToTriggerAsset = nil -- distance to trigger model or map
        if self.gameObject.modelRenderer ~= nil then
            distanceToTriggerAsset = self.ray:IntersectsModelRenderer( self.gameObject.modelRenderer )
        elseif self.gameObject.mapRenderer ~= nil then
            distanceToTriggerAsset = self.ray:IntersectsMapRenderer( self.gameObject.mapRenderer )
        end

        local distanceToGameObjectAsset = nil
        if gameObject.modelRenderer ~= nil then
            distanceToGameObjectAsset = self.ray:IntersectsModelRenderer( gameObject.modelRenderer )
        elseif gameObject.mapRenderer ~= nil then
            distanceToGameObjectAsset = self.ray:IntersectsMapRenderer( gameObject.mapRenderer )
        end
        -- if the gameObject has a model or map, replace the distance to the game object with the distance to the asset
        if distanceToGameObjectAsset ~= nil then
            sqrDistanceToGameObject = distanceToGameObjectAsset^2
        end

        if distanceToTriggerAsset ~= nil and distanceToTriggerAsset^2 > sqrDistanceToGameObject then
            -- distance from the trigger to the game object is inferior to the distance from the trigger to the trigger's model or map
            -- that means the GO is inside of the model/map
            -- the ray goes through the GO origin before intersecting the map 
            gameObjectIsInTrigger = true
        end
    end

    Daneel.Debug.StackTrace.EndFunction()
    return gameObjectIsInTrigger
end
