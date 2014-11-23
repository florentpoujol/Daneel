-- Lang Behavior.lua
-- Update the TextRenderer or GUI.TextArea component on the game object with the localized string whose key is provided.
-- Allow to register the game object for the localized text to be updated when the language changes.
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
