-- Toggle.lua
-- Scripted behavior for GUI.Toggle component.
--
-- Last modified for v1.2.0
-- Copyright © 2013 Florent POUJOL, published under the MIT licence.

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
    Daneel.Debug.AlertLoad()

    if self.gameObject.toggle == nil then
        local params = {
            isChecked = self.isChecked,
        }
        local props = {"text", "group", "checkedMark", "uncheckedMark", "checkedModel", "uncheckedModel"}
        for i, prop in ipairs( props ) do
            if self[ prop ]:trim() ~= "" then
                params[ prop ] = self[ prop ]
            end
        end
        
        GUI.Toggle.New( self.gameObject, params )
    end
end
