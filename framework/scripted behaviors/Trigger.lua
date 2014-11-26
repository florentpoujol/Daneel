-- Trigger.lua
-- Scripted behavior to add a Trigger component while in the scene editor.
--
-- Last modified for v1.5.0
-- Copyright © 2013-2014 Florent POUJOL, published under the MIT license.

--[[PublicProperties
tags string ""
range number 0
updateInterval number 5
/PublicProperties]]

function Behavior:Awake()
    if self.gameObject.trigger == nil then
        local params = {
            tags = string.split( self.tags, "," ),
            range = self.range,
            updateInterval = self.updateInterval
        }
        
        for i=1, #params.tags do
            params.tags[i] = string.trim( params.tags[i] )
        end

        Trigger.New( self.gameObject, params )
    end
end
