-- Input.lua
-- Scripted behavior for GUI.Input component.
--
-- Last modified for v1.2.0
-- Copyright © 2013 Florent POUJOL, published under the MIT license.

--[[PublicProperties
isFocused boolean false
maxLength number 9999
characterRange string ""
defaultValue string ""
focusOnBackgroundClick boolean true
/PublicProperties]]

function Behavior:Awake()
    if self.gameObject.input == nil then
        local params = { 
            isFocused = self.isFocused,
            maxLength = self.maxLength,
            focusOnbackgroundClick = self.focusOnbackgroundClick,
            defaultValue = self.defaultValue,
        }
        
        if self.characterRange ~= "" then
            params.characterRange = self.characterRange
        end

        GUI.Input.New( self.gameObject, params )
    end
end
