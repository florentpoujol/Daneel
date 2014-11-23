-- ProgressBar.lua
-- Scripted behavior for GUI.PogressBar component.
--
-- Last modified for v1.5.0
-- Copyright © 2013-2014 Florent POUJOL, published under the MIT license.

--[[PublicProperties
minValue number 0
maxValue number 100
minLength string "0"
maxLength string "5"
height string "1"
value string "100%"
cameraName string ""
/PublicProperties]]

function Behavior:Awake()
    if self.gameObject.progressBar == nil then
        local cameraGO = nil
        self.cameraName = string.trim( self.cameraName )
        if self.cameraName ~= "" then
            cameraGO = GameObject.Get( self.cameraName )
        end

        GUI.ProgressBar.New( self.gameObject, { 
            minValue = self.minValue,
            maxValue = self.maxValue,
            minLength = self.minLength,
            maxLength = self.maxLength,
            height = self.height,
            value = self.value,
            cameraGO = cameraGO
        })
    end
end