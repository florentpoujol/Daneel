-- Toggle.lua
-- Scripted behavior for GUI.Toggle component.
--
-- Last modified for v1.3.0
-- Copyright © 2013-2014 Florent POUJOL, published under the MIT license.

--[[PublicProperties
isChecked boolean false
text string ""
group string ""
checkedMark string ""
uncheckedMark string ""
checkedModel string ""
uncheckedModel string ""
/PublicProperties]]

function Behavior:Awake()
    if self.gameObject.toggle == nil then
        local params = {
            isChecked = self.isChecked,
        }
        local props = {"text", "group", "checkedMark", "uncheckedMark", "checkedModel", "uncheckedModel"}
        for i, prop in ipairs( props ) do
            if string.trim( self[ prop ] ) ~= "" then
                params[ prop ] = self[ prop ]
            end
        end
        
        GUI.Toggle.New( self.gameObject, params )
    end
end
