
-- Behavior for Daneel.GUI.Checkbox

local B = Behavior -- Behavior is not accessible from a function
local function CreateButtonEventFunctions()
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
				if type(comb) == "table" then
					for button, value in pairs(comb) do
						if CraftStudio.Input.IsButtonDown(button) then
							self.element:UpdateLabel(value)
							return
						end
					end
				else
					-- comb is of type string
					self.element:UpdateLabel(comb)
					return
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

	CreateButtonEventFunctions()
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


-- call the mouse hoverable callbacks
function Behavior:OnMouseEnter()
	if type(self.element.onMouseEnter) == "function" then
		self.element:onMouseEnter()
	end
end

function Behavior:OnMouseOver()
	if type(self.element.onMouseOver) == "function" then
		self.element:onMouseOver()
	end
end

function Behavior:OnMouseExit()
	if type(self.element.onMouseExit) == "function" then
		self.element:onMouseExit()
	end
end
