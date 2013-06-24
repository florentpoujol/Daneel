
-- Behavior for Daneel.GUI.Input component.

-- Public properties :
-- isFocused (boolean) [default=false]
-- buttonMap (string) [default=""]
-- allowAutoCapitalisation (boolean) [default=true]
-- maxLength (number) [default=9999]

local B = Behavior

function Behavior:Start()
	if self.gameObject.input == nil then
		self.gameObject:AddComponent("Input", { 
			isFocused = self.isFocused,
			buttonMap = self.buttonMap,
			allowAutoCapitalisation = self.allowAutoCapitalisation,
			maxLength = self.maxLength
		})
	end

	Daneel.Events.Listen({
		"OnDeleteButtonJustPressed",
		"OnEnterButtonJustReleased",
	}, self.gameObject)

	if self.gameObject.input.allowAutoCapitalisation then
		Daneel.Event.Listen({
			"OnLeftShiftButtonJustPressed",
			"OnLeftShiftButtonJustReleased",
			"OnRightShiftButtonJustPressed",
			"OnRightShiftButtonJustReleased",
			"OnCapsLockButtonJustPressed",
			"OnCapsLockButtonJustReleased",
		}, self.gameObject)
	end
	self.gameObject.capsLockOn = false
	self.gameObject.uppercaseMode = false


	-- create functions to catch the event for each input keys
	for key, value in pairs(self.gameObject.input.buttonMap) do
		-- the button name may be the key or the value
		local buttonName = value
		local combinations = nil
		local buttonValue = nil
		if type(key) == "string" then
			buttonName = key
			if type(value) == "table" then
				combinations = value
			else
				buttonValue = value
			end
		end
		local ButtonName = buttonName:ucfirst()

		Daneel.Events.Listen("On"..ButtonName.."ButtonJustPressed", self.gameObject)

		B["On"..ButtonName.."ButtonJustPressed"] = function(self)
			if self.gameObject.input.isFocused then
				if combinations ~= nil then 
					-- key=button name , value = combinations
					--[[
					ie : 
					inputKeys = {
						D5 = {
							"(", 				-- when button is pressed without combinaison
							leftShift = "5", 	-- leftShift + ( (in this order) = "5"
							rightShift = "5",
							rightAlt = "["
						}
					}
					]]
					for button, value in pairs(combinations) do
						if type(button) ~= "number" and CraftStudio.Input.IsButtonDown(button) then
							self.gameObject.input:Update(value)
							return
						end
					end

					-- when pressed without combinaison
					if combinations[1] ~= nil then
						--if CraftStudio.Input.IsButtonDown(buttonName) then
							self.gameObject.input:Update(combinations[1])
							--return
						--end
					end

				elseif buttonValue ~= nil then 
					-- key=button name , value = replacement value
					self.gameObject.input:Update(buttonValue)
				
				else 
					-- value = buttonName  or, combined with LeftShift : ButtonName (uppercase)
					local value = buttonName
					if self.gameObject.uppercaseMode then
						value = ButtonName
					end
					self.gameObject.input:Update(value)
				end
			end
		end -- end function self.gameObject["On"..ButtonName.."ButtonJustPressed"]
	end -- enf for inputkeys
end


function Behavior:OnClick()
	self.gameObject.input:Focus(self.gameObject.onMouseOver)
end

function Behavior:OnDeleteButtonJustPressed()
	if self.gameObject.input.isFocused then
		local text = self.gameObject.textRenderer.text
		self.gameObject.input:Update(text:sub(1, #text-1), true)
	end
end

function Behavior:OnEnterButtonJustReleased()
	if self.gameObject.input.isFocused then
		Daneel.Fire.Event(self.gameObject.input, "OnValidate")
	end
end

-- handle uppercase mode
function Behavior:OnLeftShiftButtonJustPressed()
	self.gameObject.uppercaseMode = not self.gameObject.capsLockOn
end

function Behavior:OnLeftShiftButtonJustReleased()
	self.gameObject.uppercaseMode = not self.gameObject.capsLockOn
end

function Behavior:OnRightShiftButtonJustPressed()
	self.gameObject.uppercaseMode = not self.gameObject.capsLockOn
end

function Behavior:OnRightShiftButtonJustReleased()
	self.gameObject.uppercaseMode = not self.gameObject.capsLockOn
end

function Behavior:OnCapsLockButtonJustPressed()
	self.gameObject.capsLockOn = not self.gameObject.capsLockOn
end

function Behavior:OnCapsLockButtonJustReleased()
	self.gameObject.capsLockOn = not self.gameObject.capsLockOn
end

