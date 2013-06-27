
-- Behavior for Daneel.GUI.CheckBox component.

-- Public properties :
-- isChecked (boolean) [default=false]
-- text (string) [default=""]
-- group (string) [default=""]

function Behavior:Awake()
	if self.gameObject.checkBox == nil then
		local checkBox = self.gameObject:AddComponent("CheckBox", { 
			isChecked = self.isChecked,
		})
        if self.text:trim() ~= "" then
            checkBox.text = self.text
        end
        if self.group:trim() ~= "" then
            checkBox.group = self.group
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


-- "wait" for the TextRenderer or ModelRenderer to be added
function Behavior:OnNewComponent(data)
    if data == nil then return end -- FIXME : happens when the component is a scriptedBehavior
    local component = data[1]
    if component == nil then return end
    local mt = getmetatable(component)

    if mt == TextRenderer then
        local text = component.text
        if text == nil then
            text = self.gameObject.checkBox.defaultText
        end
        self.gameObject.checkBox.text = text

    elseif mt == ModelRenderer and checkBox.checkedModel ~= nil then
        if checkBox.isChecked then
            checkBox.gameObject.modelRenderer.model = checkBox.checkedModel
        else
            checkBox.gameObject.modelRenderer.model = checkBox.uncheckedModel
        end
    end
end
