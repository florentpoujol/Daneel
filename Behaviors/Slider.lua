
-- Behavior for Daneel.GUI.Slider component.

-- Public properties :
-- minValue (number) [default=0]
-- maxValue (number) [default=100]
-- length (string) [default="5"]
-- value (string) [default="0%"]
-- axis (string) [default="x"]

function Behavior:Start()
	if self.gameObject.slider == nil then
		self.gameObject:AddComponent("Slider", { 
			minValue = self.minValue,
			maxValue = self.maxValue,
			length = self.length,
			axis = self.axis,
			value = self.value,
		})
	end
end

-- when the handle is dragged
function Behavior:OnDrag()
	local slider = self.gameObject.slider
	local mousePosition = CraftStudio.Input.GetMousePosition()
	local newPosition = Vector2(mousePosition.x, self.gameObject.hud.position.y) 
	if slider.axis == "y" then
		newPosition = Vector2(self.gameObject.hud.position.x, mousePosition.y)
	end
    self.gameObject.hud.position = newPosition
    slider.value = math.clamp(slider.value, slider.minValue, slider.maxValue)
end


function Behavior:OnNewComponent(data)
    if data == nil then return end -- FIXME : happens when the component is a scriptedBehavior
    local component = data[1]
    if component == nil then return end
    local mt = getmetatable(component)

    if mt == Daneel.GUI.Hud then
        self.gameObject.slider.startPosition = self.gameObject.transform.position
    end
end