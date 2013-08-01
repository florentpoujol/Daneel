-- Slider.lua
-- Scripted behavior for Daneel.GUI.Slider component.
--
-- Last modified for v1.2.0
-- Copyright © 2013 Florent POUJOL, published under the MIT licence.

--[[PublicProperties
minValue number 0
maxValue number 100
length string "5"
axis string "x"
value string "0%"
/PublicProperties]]

function Behavior:Awake()
    if self.gameObject.slider == nil then
        self.gameObject:AddComponent( "Slider", { 
            minValue = self.minValue,
            maxValue = self.maxValue,
            length = self.length,
            axis = self.axis,
            value = self.value,
        } )
    end
end

-- when the handle is dragged
function Behavior:OnDrag()
    if self.gameObject.hud == nil then
        self.gameObject:AddComponent( "Hud" ) -- adding the hud component now cause the handle to be put at the end of the slider
    end

    local slider = self.gameObject.slider
    local mousePosition = CraftStudio.Input.GetMousePosition()
    local newPosition = Vector2( mousePosition.x, self.gameObject.hud.position.y ) 
    if slider.axis == "y" then
        newPosition = Vector2( self.gameObject.hud.position.x, mousePosition.y )
    end

    self.gameObject.hud.position = newPosition
    
    if 
        (slider.axis == "x" and self.gameObject.transform.position.x < slider.startPosition.x) or
        (slider.axis == "y" and self.gameObject.transform.position.y < slider.startPosition.y)
    then
        slider.value = slider.minValue
    else
        slider.value = math.clamp( slider.value, slider.minValue, slider.maxValue )
    end
end
