-- Last modified for :
-- version 1.2.0
-- released 29th July 2013

-- Behavior for Daneel.GUI.Input component.

-- Public properties :
-- isFocused (boolean) [default=false]
-- maxLength (number) [default=999999]
-- characterRange (string) [default=""]

function Behavior:Awake()
	if self.gameObject.input == nil then
		local params = { 
			isFocused = self.isFocused,
			maxLength = self.maxLength
		}
		if self.characterRange:Trim() ~= "" then
			params.characterRange = self.characterRange
		end

		self.gameObject:AddComponent( "Input", params )
	end
end
