
-- Behavior for Daneel.GUI.CheckBox component.
-- Only use for this is to add a checkBox component while in the scene editor.

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
