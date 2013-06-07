
-- Behavior for Daneel.GUI.CheckBox component.
-- Only add to a gameObject while in the scene editor.

-- Public properties :
-- isChecked (boolean) [default=false]
-- text (string) [default="CheckBox"]

function Behavior:Start()
	if self.gameObject.checkBox == nil then
		self.gameObject:AddComponent("CheckBox", { 
			isChecked = self.isChecked,
			text = self.text
		})
	end
end
