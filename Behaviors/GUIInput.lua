
-- Behavior for Daneel.GUI.Checkbox

local B = Behavior
local function CreateFunctions()
	-- create function to catch the event for each inputKeys
	for key, value in pairs(Daneel.config.inputKeys) do
		-- the button name may be the key or the value
		local button = value
		local comb = {}

		if type(key) == "string" then
			button = key
			comb = value
		end

		local Button = button:ucfirst()

		B["On"..Button.."ButtonJustPressed"] = function(self)
			if self.element.focused then
				table.print(comb)
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
end


function Behavior:Start()
	Daneel.Events.Listen("OnLeftMouseButtonJustPressed", self.gameObject)
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

	CreateFunctions()
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
	end
end



