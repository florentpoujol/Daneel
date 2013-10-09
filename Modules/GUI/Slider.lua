-- Slider.lua
-- Scripted behavior for GUI.Slider component.
--
-- Last modified for v1.2.0
-- Copyright © 2013 Florent POUJOL, published under the MIT license.

--[[PublicProperties
minValue number 0
maxValue number 100
length string "5"
axis string "x"
value string "0%"
/PublicProperties]]

function Behavior:Awake()
    if self.gameObject.slider == nil then
        if self.axis:trim() == "" then
            self.axis = "x"
        end
        if self.value:trim() == "" then
            self.value = "0%"
        end

        GUI.Slider.New( self.gameObject, { 
            minValue = self.minValue,
            maxValue = self.maxValue,
            length = self.length,
            axis = self.axis,
            value = self.value,
        } )
    end
end
