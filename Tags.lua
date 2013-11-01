-- Tags.lua
-- Scripted behavior to add tags to game objects while in the scene editor.
--
-- Last modified for v1.2.0
-- Copyright © 2013 Florent POUJOL, published under the MIT license.

--[[PublicProperties
tags string ""
/PublicProperties]]

function Behavior:Awake()
    if self.tags ~= "" then
        local tags = string.split( self.tags, ",", true )
        self.gameObject:AddTag( tags )
    end
end
