
-- Behavior for Daneel.GUI.Input component.

-- Public properties :
-- isFocused (boolean) [default=false]
-- maxLength (number) [default=9999]

function Behavior:Start()
	if self.gameObject.input == nil then
		self.gameObject:AddComponent("Input", { 
			isFocused = self.isFocused,
			maxLength = self.maxLength
		})
	end
end

function Behavior:OnClick()
	self.gameObject.input:Focus( self.gameObject.onMouseOver )
end
