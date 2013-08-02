-- Lang.lua
-- Update the TextRenderer or TextArea component on the game object with the localized string whose key is provided.
-- Allow to register the game object for the localized text to be updated when the language changes.
--
-- Since v1.2.1
-- Last modified for v1.2.1
-- Copyright © 2013 Florent POUJOL, published under the MIT licence.

--[[PublicProperties
key string ""
registerForUpdate boolean false
/PublicProperties]]

function Behavior:Start()
    if self.key:trim() ~= "" then
        if self.gameObject.textArea ~= nil then
            self.gameObject.textArea:SetText( Daneel.Lang.Get( self.key ) )
        elseif self.gameObject.textRenderer ~= nil then
            self.gameObject.textRenderer:SetText( Daneel.Lang.Get( self.key ) )
        end

        if self.registerForUpdate then
            Daneel.Lang.RegisterForUpdate( self.gameObject, self.key )
        end
    end
end
