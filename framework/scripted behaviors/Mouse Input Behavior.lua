-- Mouse Input Behavior.lua
-- Enable mouse interactions with game objects when added to a game object with a camera component.
--
-- Last modified for v1.5.0
-- Copyright © 2013-2014 Florent POUJOL, published under the MIT license.

--[[PublicProperties
tags string ""
/PublicProperties]]

function Behavior:Awake()
    if self.gameObject.mouseInput == nil then
        self.tags = string.split( self.tags, "," )
        for i=1, #self.tags do
            self.tags[i] = string.trim( self.tags[i] )
        end

        MouseInput.New( self.gameObject, { tags = self.tags } )
    end
end
