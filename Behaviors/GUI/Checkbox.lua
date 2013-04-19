
-- Behavior for Daneel.GUI.Checkbox

-- the gameObject has already registered to the "OnLeftMouseButtonJustReleased" event in GUI/Interactive
function Behavior:OnLeftMouseButtonJustReleased()
	-- onMouseOver comes from Daneel/Behavior/CameraMouseOver
	-- because Checkboxes are also mousehoverable gameObjects
	if self.gameObject.onMouseOver == true then
		-- checkbox is overed by the mouse
		-- and the left mouse button has been pressed
		-- > change the state of the element
		self.element:SwitchState()
	end
end
