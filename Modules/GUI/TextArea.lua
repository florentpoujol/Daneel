-- TextArea.lua
-- Scripted behavior for GUI.TextArea component.
--
-- Last modified for v1.2.0
-- Copyright © 2013 Florent POUJOL, published under the MIT license.

--[[PublicProperties
areaWidth string ""
wordWrap boolean false
newLine string "\n"
lineHeight string "1"
verticalAlignment string "top"
font string ""
text string "Text\nArea"
alignment string ""
opacity number 1.0
/PublicProperties]]

function Behavior:Awake()
    if self.gameObject.textArea == nil then
        local params = {
            wordWrap = self.wordWrap,
            opacity = self.opacity
        }
        local props = {"areaWidth", "newLine", "lineHeight", "verticalAlignment", "font", "text", "alignment"}
        for i, prop in ipairs( props ) do
            if string.trim( self[ prop ] ) ~= "" then
                params[ prop ] = self[ prop ]
            end
        end

        GUI.TextArea.New( self.gameObject, params )
    end
end
