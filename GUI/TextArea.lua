-- TextArea.lua
-- Scripted behavior for GUI.TextArea component.
--
-- Last modified for v1.5.0
-- Copyright © 2013-2014 Florent POUJOL, published under the MIT license.

--[[PublicProperties
areaWidth string ""
wordWrap boolean false
newLine string "<br>"
lineHeight string "1"
verticalAlignment string "top"
font string ""
text string ""
alignment string ""
opacity number 1.0
cameraName string ""
/PublicProperties]]

function Behavior:Awake()
    if self.gameObject.textArea == nil then
        local params = {
            wordWrap = self.wordWrap,
            newLine = self.newLine,
            text = self.text,
            opacity = self.opacity,
        }
        local props = {"areaWidth", "lineHeight", "verticalAlignment", "font", "alignment"}
        for i, prop in pairs( props ) do
            if string.trim( self[ prop ] ) ~= "" then
                params[ prop ] = self[ prop ]
            end
        end

        self.cameraName = string.trim( self.cameraName )
        if self.cameraName ~= "" then
            params.cameraGO = GameObject.Get( self.cameraName )
        end

        GUI.TextArea.New( self.gameObject, params )
    end
end
