-- Lang.lua
-- Scripted behavior to enable the features of the Lang module while in the scene editor.
-- 
-- Last modified for v1.5.0
-- Copyright © 2013-2014 Florent POUJOL, published under the MIT license.

--[[PublicProperties
key string ""
registerForUpdate boolean false
/PublicProperties]]

function Behavior:Start()
    if string.trim( self.key ) ~= "" then
        if self.gameObject.textArea ~= nil then
            self.gameObject.textArea:SetText( Lang.Get( self.key ) )
        elseif self.gameObject.textRenderer ~= nil then
            self.gameObject.textRenderer:SetText( Lang.Get( self.key ) )
        end

        if self.registerForUpdate then
            Lang.RegisterForUpdate( self.gameObject, self.key )
        end
    end
end
