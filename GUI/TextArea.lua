-- TextArea.lua
-- Scripted behavior for GUI.TextArea component.
--
-- Last modified for v1.5.0
-- Copyright © 2013-2014 Florent POUJOL, published under the MIT license.

--[[PublicProperties
areaWidth string ""
wordWrap boolean false
newLine string ";"
lineHeight string "1"
verticalAlignment string "top"
cameraName string ""
/PublicProperties]]

function Behavior:Awake()
    if self.gameObject.textArea == nil then
        local params = {
            wordWrap = self.wordWrap,
            opacity = self.opacity
        }
        local props = {"areaWidth", "lineHeight", "verticalAlignment", "newLine"}
        for i, prop in pairs( props ) do
            if string.trim( self[ prop ] ) ~= "" then
                params[ prop ] = self[ prop ]
            end
        end
        
        if self.gameObject.textRenderer ~= nil then
            local props = {"font", "text", "alignment", "opacity"}
            for i, prop in pairs( props ) do
                local funcName = "Get"..string.ucfirst( prop )
                params[ prop ] = self.gameObject.textRenderer[ funcName ]( self.gameObject.textRenderer )
            end
        end

        self.cameraName = string.trim( self.cameraName )
        if self.cameraName ~= "" then
            params.cameraGO = GameObject.Get( self.cameraName )
        end
        
        GUI.TextArea.New( self.gameObject, params )
    end
end
