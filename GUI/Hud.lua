-- Hud.lua
-- Scripted behavior for GUI.Hud component.
--
-- Last modified for v1.5.0
-- Copyright © 2013-2014 Florent POUJOL, published under the MIT license.

--[[PublicProperties
position string ""
localPosition string ""
layer string ""
localLayer string ""
cameraName string ""
/PublicProperties]]

function Behavior:Awake()
    if self.gameObject.hud == nil then
        local params = {}

        if self.position ~= "" then
            local x, y = unpack( string.split( self.position, "," ) )
            params.position = Vector2.New( x, y )
        end
        if self.localPosition ~= "" then
            local x, y = unpack( string.split( self.localPosition, "," ) )
            params.localPosition = Vector2.New( x, y )
        end

        if self.layer ~= "" then
            params.layer = tonumber( self.layer )
        end
        if self.localLayer ~= "" then
            params.localLayer = tonumber( self.localLayer )
        end

        if string.trim( self.cameraName ) ~= "" then
            params.cameraGO = GameObject.Get( self.cameraName )
        end
        if params.cameraGO == nil then
            params.cameraGO = self.gameObject:GetInAncestors( function( go ) if go.camera ~= nil then return true end end )
        end

        -- allow the gameObject to stay at the position defined in the scene
        local currentPos =  self.gameObject.transform:GetPosition()
        if params.cameraGO ~= nil and params.position == nil and params.localPosition == nil then
            local position = params.cameraGO.camera:WorldToScreenPoint( currentPos ) -- vector3
            params.position = Vector2.New( position.x, position.y )
        end
        if params.layer == nil and params.localLayer == nil then
            params.layer = -currentPos.z
        end
        GUI.Hud.New( self.gameObject, params )
    end
end
