
-- Behavior for Daneel.GUI.Input component.

-- Public properties :
-- isFocused (boolean) [default=false]
-- maxLength (number) [default=999999]

function Behavior:Start()
	if self.gameObject.input == nil then
		self.gameObject:AddComponent("Input", { 
			isFocused = self.isFocused,
			maxLength = self.maxLength
		})
	end
end
