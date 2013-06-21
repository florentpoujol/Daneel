
-- Behavior for Daneel.GUI.Input component.

-- Public properties :
-- isFocused (boolean) [default=false]
-- keySet (string) [default=""]

local B = Behavior

function Behavior:Start()
	if self.gameObject.input == nil then
		self.gameObject:AddComponent("Input", { 
			isFocused = self.isFocused,
			keySet = self.keySet,
		})
	end

	Daneel.Events.Listen("OnDeleteButtonJustPressed", self.gameObject)
	Daneel.Events.Listen("OnMajButtonJustPressed", self.gameObject)
	Daneel.Events.Listen("OnMajButtonJustReleased", self.gameObject)
	self.gameObject.majButtonDown = false

	-- create functions to catch the event for each input keys
	for key, value in pairs(self.gameObject.input.keySet) do
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
					inputkeys = {
						buttonName = {
							"value",
							otherButton = "other value",
						}
					}
					]]
					for button, value in pairs(combinaisons) do
						if type(button) ~= "number" and CraftStudio.Input.IsButtonDown(button) then
							self.gameObject.textRenderer.text = self.gameObject.textRenderer.text + value
							return
						end
					end

					-- pourquoi ?? quel intéret ??
					if combinaisons[1] ~= nil then
						if CraftStudio.Input.IsButtonDown(buttonName) then
							self.gameObject.textRenderer.text = self.gameObject.textRenderer.text + combinaisons[1]
							return
						end
					end

				elseif buttonValue ~= nil then 
					-- key=button name , value = replacement value
					self.gameObject.textRenderer.text = self.gameObject.textRenderer.text + buttonValue
				
				else 
					-- value = buttonName  or, combined with LeftShift : ButtonName (uppercase)
					local value = buttonName
					if self.gameObject.majButtonDown then
						value = ButtonName
					end
					self.gameObject.textRenderer.text = self.gameObject.textRenderer.text + value
				end
			end
		end -- end function self.gameObject["On"..ButtonName.."ButtonJustPressed"]
	end -- enf for inputkeys
end


-- focus on the input and place the cursor to the letter
-- the gameObject has already registered to the "OnLeftMouseButtonJustReleased" event in GUI/Interactive
function Behavior:OnClick()
	self.gameObject.input:Focus(self.gameObject.onMouseOver)
end

function Behavior:OnDeleteButtonJustPressed()
	if self.gameObject.input.isFocused then
		local text = self.gameObject.textRenderer.text:totable()
		table.remove(text)
		self.gameObject.textRenderer.text = table.concat(text)
	end
end

function Behavior:OnMajButtonJustPressed()
	self.gameObject.majButtonDown = true
end

function Behavior:OnMajButtonJustReleased()
	self.gameObject.majButtonDown = false
end
