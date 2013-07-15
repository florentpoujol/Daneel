
-- Behavior for Daneel.GUI.Toggle component.

-- Public properties :
-- isChecked (boolean) [default=false]
-- text (string) [default=""]
-- group (string) [default=""]

function Behavior:Awake()
	if self.gameObject.toggle == nil then
		local toggle = self.gameObject:AddComponent("Toggle", { 
			isChecked = self.isChecked,
		})
        if self.text:trim() ~= "" then
            toggle.text = self.text
        end
        if self.group:trim() ~= "" then
            toggle.group = self.group
        end
	end
end

-- when the gameObject is clicked by the mouse
function Behavior:OnClick()
    local toggle = self.gameObject.toggle
    if not (toggle.group ~= nil and toggle.isChecked) then
        toggle:Check(not toggle.isChecked)
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
            text = self.gameObject.toggle.defaultText
        end
        self.gameObject.toggle.text = text

    elseif mt == ModelRenderer and toggle.checkedModel ~= nil then
        if toggle.isChecked then
            toggle.gameObject.modelRenderer.model = toggle.checkedModel
        else
            toggle.gameObject.modelRenderer.model = toggle.uncheckedModel
        end
    end
end
