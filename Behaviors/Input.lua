
-- Behavior for Daneel.GUI.Input component.

-- Public properties :
-- minValue (number) [default=0]
-- maxValue (number) [default=100]
-- length (string) [default="0"]
-- value (string) [default="0%"]
-- axis (string) [default="x"]

function Behavior:Start()
	if self.gameObject.slider == nil then
		self.gameObject:AddComponent("Input", { 
			minValue = self.minValue,
			maxValue = self.maxValue,
			length = self.length,
			axis = self.axis,
			value = self.value,
		})
	end
end

