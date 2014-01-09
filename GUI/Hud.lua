-- Hud.lua
-- Scripted behavior for GUI.Hud component.
--
-- Last modified for v1.3.0
-- Copyright © 2013-2014 Florent POUJOL, published under the MIT license.

--[[PublicProperties
position string ""
localPosition string ""
layer string ""
localLayer string ""
/PublicProperties]]

function Behavior:Awake()
    if self.gameObject.hud == nil then
        local params = {}
        if self.position ~= "" then
            local x, y = unpack( self.position:split( "," ) )
            params.position = Vector2.New( x, y )
        end
        if self.localPosition ~= "" then
            local x, y = unpack( self.localPosition:split( "," ) )
            params.localPosition = Vector2.New( x, y )
        end
        if self.layer ~= "" then
            params.layer = tonumber( self.layer )
        end
        if self.localLayer ~= "" then
            params.localLayer = tonumber( self.localLayer )
        end

        -- allow the gameObject to stay at the same position than defined in the scene
        local position, layer = GUI.Hud.ToHudPosition( self.gameObject.transform:GetPosition() )
        if params.position == nil and params.localPosition == nil then
            params.position = position
        end
        if params.layer == nil and params.localLayer == nil then
            params.layer = layer
        end

        GUI.Hud.New( self.gameObject, params )
    end
end
