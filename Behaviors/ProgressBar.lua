
-- Behavior for Daneel.GUI.ProgressBar component.

-- Public properties :
-- minValue (number) [default=0]
-- maxValue (number) [default=100]
-- minLength (string) [default="0"]
-- maxLength (string) [default="10"]
-- height (string) [default="1"]
-- progress (string) [default="100%"]

function Behavior:Awake()
	if self.gameObject.progressBar == nil then
		self.gameObject:AddComponent("ProgressBar", { 
			minValue = self.minValue,
			maxValue = self.maxValue,
			minLength = self.minLength,
			maxLength = self.maxLength,
			height = self.height,
			progress = self.progress,
		})
	end
end