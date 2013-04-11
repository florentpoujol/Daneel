
-- Behavior for Daneel.GUI.Checkbox

function Behavior:Start()
	Daneel.Events.Listen("OnLeftMouseButtonJustPressed", self.gameObject)

	for key, value in ipairs(Daneel.config.inputKeys) do
		-- the button name may be the key or the value
		if type(value) == "string" then
			Daneel.Events.Listen("On"..value:ucfirst().."ButtonJustPressed", self.gameObject)
		elseif type(key) == "string" then
			Daneel.Events.Listen("On"..key:ucfirst().."ButtonJustPressed", self.gameObject)
		end
	end
end

function Behavior:OnLeftMouseButtonJustPressed()
	-- onMouseOver comes from Daneel/Behavior/CameraMouseOver
	-- because Inputs are also mousehoverable gameObjects
	self.element.focus = self.gameObject.onMouseOver
end
 

for key, value in ipairs(Daneel.config.inputKeys) do
	-- the button name may be the key or the value
	local button = key
	local comb = {}

	if type(value) == "string" then
		button = value
	elseif type(key) == "string" then
		comb = value
	end

	local Button = button:ucfirst()

	Behavior["On"..Button.."ButtonJustPressed"] = function(self)
		if self.element.focused then
			-- upper case, lower case
			if CraftStudio.Input.IsButtonDown("LeftShift") or CraftStudio.Input.IsButtonDown("RightShift") then
				self.element.label = self.element.label..Button
			else
				self.element.label = self.element.label..button
			end

			-- comb
			for button, value in pairs(comb) do
				if CraftStudio.Input.IsButtonDown(button) then
					self.element.label = self.element.label..value
				end
			end

			if type(self.element.onChange) == "function" then
	            self.element:onChange()
	        end 
		end
	end
end

-- what about escape, space


