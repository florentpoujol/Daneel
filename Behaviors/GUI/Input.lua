
-- Behavior for Daneel.GUI.Checkbox

local B = Behavior -- Behavior is not accessible from a function
local function CreateInputKeysEventFunctions()
	-- create function to catch the event for each inputKeys
	for key, value in pairs(Daneel.config.inputKeys) do
		-- the button name may be the key or the value
		local buttonName = value
		local combinaisons = nil
		local buttonValue = nil
		if type(key) == "string" then
			buttonName = key
			if type(value) == "table" then
				combinaisons = value
			else
				buttonValue = value
			end
		end
		local ButtonName = buttonName:ucfirst()

		B["On"..ButtonName.."ButtonJustPressed"] = function(self)
			if self.element.focused then
				if combinaisons ~= nil then -- key=button name , value = combinaisons

					for button, value in pairs(combinaisons) do
						if type(button) ~= "number" and CraftStudio.Input.IsButtonDown(button) then
							self.element:UpdateLabel(value)
							return
						end
					end

					if combinaisons[1] ~= nil then
						if CraftStudio.Input.IsButtonDown(buttonName) then
							self.element:UpdateLabel(combinaisons[1])
							return
						end
					end

				elseif buttonValue ~= nil then -- key=button name , value = replacement value
					self.element:UpdateLabel(buttonValue)
				else -- value = button Name
					if CraftStudio.Input.IsButtonDown("LeftShift") then
						self.element:UpdateLabel(ButtonName)
					else
						self.element:UpdateLabel(buttonName)
					end
				end
			end
		end
	end
end


function Behavior:Start()
	Daneel.Events.Listen("OnLeftArrowButtonJustPressed", self.gameObject)
	Daneel.Events.Listen("OnRightArrowButtonJustPressed", self.gameObject)
	Daneel.Events.Listen("OnDeleteButtonJustPressed", self.gameObject)

	for key, value in pairs(Daneel.config.inputKeys) do
		-- the button name may be the key or the value
        if type(key) == "string" then
            value = key
        end
        Daneel.Events.Listen("On"..value:ucfirst().."ButtonJustPressed", self.gameObject)
	end

	CreateInputKeysEventFunctions()
end


-- focus on the input and place the cursor to the letter
-- the gameObject has already registered to the "OnLeftMouseButtonJustReleased" event in GUI/Interactive
function Behavior:OnLeftMouseButtonJustReleased()
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
	end
end
