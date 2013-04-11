
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

	Daneel.Events.Listen("OnLeftArrowButtonJustPressed", self.gameObject)
	Daneel.Events.Listen("OnRightArrowButtonJustPressed", self.gameObject)
end


-- focus on the input and place the cursor to the letter
function Behavior:OnLeftMouseButtonJustPressed()
	-- onMouseOver comes from Daneel/Behavior/CameraMouseOver
	-- because Inputs are also mousehoverable gameObjects
	self.element.focused = self.gameObject.onMouseOver
end

-- mouse the cursor left or right when focused and the user clicks on th left or right arrow
function Behavior:OnLeftArrowButtonJustPressed()
	if self.element.focused then
		self.element:SetCursorPosition(-1, true)
	end
end

function Behavior:OnRightArrowButtonJustPressed()
	if self.element.focused then
		self.element:SetCursorPosition(1, true)
	end
end

function Behavior:OnDeleteButtonJustPressed()
	if self.element.focused then
		self.element:UpdateLabel("Delete")
		self.element:SetCursorPosition(-1, true)
	end
end


-- create function to catch the event for each inputKeys
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
			
			for button, value in pairs(comb) do
				if CraftStudio.Input.IsButtonDown(button) then
					self.element:UpdateLabel(value)
					return
				end
			end

			-- upper case, lower case
			if CraftStudio.Input.IsButtonDown("LeftShift") then
				self.element:UpdateLabel(Button)
			else
				self.element:UpdateLabel(button)
			end
		end
	end
end


