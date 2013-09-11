-- MaskCulling.lua
-- Scripted behavior that enable the culling of game objects based on a mask in front of the game object.
-- Typically used to implements some frustrum culling.
--
-- Last modified for v1.3
-- Copyright © 2013 Florent POUJOL, published under the MIT licence.

--[[PublicProperties
mask string ""
tags string ""
updateInterval number 10
/PublicProperties]]

MaskCulling = {}

if CS.DaneelModules == nil then
    CS.DaneelModules = {}
end
CS.DaneelModules[ "MaskCulling" ] = {}

function MaskCulling.Config()
    local config = {
        maskName = "Culling Mask",
    }

    return config
end


----------------------------------------------------------------------------------

function Behavior:Awake()
    self.gameObject.maskCulling = self

    local mask = self.mask
    if self.mask:trim() == "" then
        mask = MaskCulling.Config.maskName
        self.mask = self.gameObject:GetChild( MaskCulling.Config.maskName, true )
    else
        self.mask = GameObject.Get( self.mask )
    end

    if self.mask == nil then
        error( "MaskCulling:Awake() : Can't find the culling mask with name '" .. mask .."' for game object with name '".. self.gameObject:GetName() .. "'." )
    end

    if self.tags:trim() == "" then
        self.tags = {}
    else
        self.tags = self.tags:split( ",", true )
    end

    self.frameCount = 0
end


function Behavior:Update()
    self.frameCount = self.frameCount + 1
    
    if self.frameCount % self.updateInterval == 0 then
        local cameraPosition = self.gameObject.transform:GetPosition()
        
        for i, tag in pairs( self.tags ) do
            local gameObjects = GameObject.Tags[ tag ]

            if gameObjects ~= nil then
                for i, gameObject in ipairs( gameObjects ) do
                    if gameObject ~= nil and gameObject.isDestroyed ~= true then
                        if gameObject.isVisibleFrom == nil then
                            gameObject.isVisibleFrom = {}
                        end

                        local ray = Ray:New( cameraPosition, gameObject.transform:GetPosition() - cameraPosition )
                        local distance = ray:IntersectsGameObject( self.mask )

                        if distance ~= nil then 
                            -- objet is visible from this camera
                            if gameObject.isVisibleFrom[ self.gameObject ] ~= true then
                                -- gameObject was not visible from this camera the last time
                                gameObject.isVisibleFrom[ self.gameObject ] = true
                                Daneel.Event.Fire( gameObject, "OnCameraEnter", self.gameObject, self.mask )
                            end
                        elseif gameObject.isVisibleFrom[ self.gameObject ] == true then
                            -- gameObject was visible from this camera the last time but is not anymore
                            gameObject.isVisibleFrom[ self.gameObject ] = false
                            Daneel.Event.Fire( gameObject, "OnCameraExit", self.gameObject, self.mask )
                        end

                    end
                end
            end

        end
    end
end -- end of Update() function


--- Return the list of the game objects that are visible through the mask from this game object.
-- @param mask (GameObject) [optional] The mask. If nil use, the component's mask.
-- @param tags (string or table) [optional] The tags(s) the gameObjects must have. If nil, it uses the trigger's tags(s).
function Behavior:GetVisibleGameObjects( mask, tags )
    local errorHead = "MaskCulling:GetVisibleGameObjects( [mask, tags] ) : "
    Daneel.Debug.CheckOptionalArgType( mask, "mask", "GameObject", errorHead )
    Daneel.Debug.CheckOptionalArgType( tags, "tags", {"string", "table"}, errorHead )

    if mask == nil then
        mask = self.mask
    end

    if tags == nil then
        tags = self.tags
    end
    if type( tags ) == "string" then
        tags = { tags }
    end

    local visibleGameObjects = {}
    local cameraPosition = self.gameObject.transform:GetPosition()
    
    for i, tag in pairs( tags ) do
        local gameObjects = GameObject.Tags[ tag ]
        if gameObjects ~= nil then

            for i, gameObject in ipairs( gameObjects ) do
                if gameObject ~= nil and gameObject.isDestroyed ~= true then

                    local ray = Ray:New( cameraPosition, gameObject.transform:GetPosition() - cameraPosition )
                    local distance = ray:IntersectsGameObject( mask )

                    if distance ~= nil then 
                        table.insert( visibleGameObjects, gameObject )
                    end
                end
            end
        end
    end

    return visibleGameObjects
end


--- Tell wether the provided game object is visible throught the provided mask and from the game object.
-- @param gameObject (GameObject) The game object.
-- @param mask (GameObject) [optional] The mask.
-- @return (boolean)
function Behavior:IsGameObjectVisible( gameObject, mask )
    if mask ~= nil and gameObject == nil then
        gameObject = mask
        mask = nil
    end

    if mask == nil then
        mask = self.mask
    end

    local isVisible = false
    local cameraPosition = self.gameObject.transform:GetPosition()
    local ray = Ray:New( cameraPosition, gameObject.transform:GetPosition() - cameraPosition )
    local distance = ray:IntersectsGameObject( mask )
    if distance ~= nil then 
        isVisible = true
    end

    return isVisible
end
