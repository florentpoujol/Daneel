
-- Behavior for Daneel.GUI.CheckBox component.

-- Public properties :
-- isChecked (boolean) [default=false]
-- text (string) [default=""]

function Behavior:Start()
	if self.gameObject.checkBox == nil then
		local checkBox = self.gameObject:AddComponent("CheckBox", { 
			isChecked = self.isChecked,
		})
        if self.text:trim() ~= "" then
            checkBox.text = self.text
        end
	end
end

-- when the gameObject is clicked by the mouse
function Behavior:OnClick()
    local checkBox = self.gameObject.checkBox
    if not (checkBox.group ~= nil and checkBox.isChecked) then
        checkBox:Check(not checkBox.isChecked)
    end
end
