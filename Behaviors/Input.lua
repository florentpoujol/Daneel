
-- Behavior for Daneel.GUI.Input component.

-- Public properties :
-- isFocused (boolean) [default=false]
-- keyMap (string) [default=""]

local B = Behavior

function Behavior:Start()
	if self.gameObject.input == nil then
		self.gameObject:AddComponent("Input", { 
			isFocused = self.isFocused,
			keyMap = self.keyMap,
		})
	end

	Daneel.Events.Listen({
		"OnDeleteButtonJustPressed",
		"OnEnterButtonJustReleased",

		"OnLeftShiftButtonJustPressed",
		"OnLeftShiftButtonJustReleased",
		"OnRightShiftButtonJustPressed",
		"OnRightShiftButtonJustReleased",
		"OnCapsLockButtonJustPressed",
		"OnCapsLockButtonJustReleased",
	}, self.gameObject)
	self.gameObject.capsLockOn = false
	self.gameObject.uppercaseMode = false

	-- create functions to catch the event for each input keys
	for key, value in pairs(self.gameObject.input.keyMap) do
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

		Daneel.Events.Listen("On"..ButtonName.."ButtonJustPressed", self.gameObject)

		B["On"..ButtonName.."ButtonJustPressed"] = function(self)
			if self.gameObject.input.isFocused then
				if combinaisons ~= nil then 
					-- key=button name , value = combinaisons
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
					for button, value in pairs(combinaisons) do
						if type(button) ~= "number" and CraftStudio.Input.IsButtonDown(button) then
							self.gameObject.input:Update(value)
							return
						end
					end

					-- when pressed without combinaison
					if combinaisons[1] ~= nil then
						--if CraftStudio.Input.IsButtonDown(buttonName) then
							self.gameObject.input:Update(combinaisons[1])
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
		self.gameObject.input:Update("", true)
	end
end

function Behavior:OnEnterButtonJustReleased()
	Daneel.Fire.Event(self.gameObject.input, "OnValidate")
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

