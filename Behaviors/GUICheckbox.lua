
-- Behavior for Daneel.GUI.Checkbox

function Behavior:Start()
	Daneel.Events.Listen("OnLeftMouseButtonJustReleased", self.gameObject)
end

function Behavior:OnLeftMouseButtonReleased()
	-- onMouseOver comes from Daneel/Behavior/CameraMouseOver
	-- because Checkboxes are also mousehoverable gameObjects
	if self.gameObject.onMouseOver == true then
		-- checkbox is overed by the mouse
		-- and the left mouse button has been pressed
		-- > change the state of the element
		self.element:SwitchState()

		if type(self.element.onClick) == "function" then
            self.element:onClick()
        end
	end
end
