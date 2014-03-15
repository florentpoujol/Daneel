-- LineRenderer.lua
-- Scripted behavior for Draw.LineRenderer component.
--
-- Last modified for v1.4.0
-- Copyright © 2013-2014 Florent POUJOL, published under the MIT license.

--[[PublicProperties
length number 2
width number 1
direction string "-1, 0, 0"
endPosition string ""
/PublicProperties]]

function Behavior:Awake()
    if self.gameObject.lineRenderer == nil then
        local direction = nil
        self.direction = string.trim( self.direction )
        if self.direction ~= "" then
            local vector = string.split( self.direction, "," )
            vector.x = tonumber( vector[1] )
            vector.y = tonumber( vector[2] )
            vector.z = tonumber( vector[3] )
            direction = Vector3:New( vector )
        end

        local endPosition = nil
        self.endPosition = string.trim( self.endPosition )
        if self.endPosition ~= "" then
            local vector = string.split( self.endPosition, "," )
            vector.x = tonumber( vector[1] )
            vector.y = tonumber( vector[2] )
            vector.z = tonumber( vector[3] )
            endPosition = Vector3:New( vector )

            direction = nil
            self.length = nil
        end

        Draw.LineRenderer.New( self.gameObject, {
            length = self.length,
            width = self.width,
            direction = direction,
            endPosition = endPosition,           
        } )
    end
end
