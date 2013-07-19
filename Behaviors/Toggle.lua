-- Last modified for :
-- version 1.2.0
-- released 29th July 2013

-- Behavior for Daneel.GUI.Toggle component.

-- Public properties :
-- isChecked (boolean) [default=false]
-- text (string) [default=""]
-- group (string) [default=""]
-- checkedMark (string) [default=""]
-- uncheckedMark (string) [default=""]
-- checkedModel (string) [default=""]
-- uncheckedModel (string) [default=""]

function Behavior:Awake()
	if self.gameObject.toggle == nil then
        local params = {
            isChecked = self.isChecked,
        }
		local props = {"text", "group", "checkedMark", "uncheckedMark", "checkedModel", "uncheckedModel"}
        for i, prop in ipairs( props ) do
            if self[ prop ]:trim() ~= "" then
                params[ prop ] = self[ prop ]
            end
        end
        
        self.gameObject:AddComponent( "Toggle", params )
	end
end

-- when the gameObject is clicked by the mouse
function Behavior:OnClick()
    local toggle = self.gameObject.toggle
    if not (toggle.group ~= nil and toggle.isChecked) then -- true when not in a group or when in group but not checked
        toggle:Check( not toggle.isChecked )
    end
end


-- "wait" for the TextRenderer or ModelRenderer to be added
function Behavior:OnNewComponent(data)
    --if data == nil then return end -- FIXME : happens when the component is a scriptedBehavior
    local component = data[1]
    if component == nil then return end
    local mt = getmetatable(component)

    if mt == TextRenderer then
        local text = component:GetText()
        if text == nil then
            text = self.gameObject.toggle.defaultText
        end
        self.gameObject.toggle:SetText( text )

    elseif mt == ModelRenderer and toggle.checkedModel ~= nil then
        if toggle.isChecked then
            toggle.gameObject.modelRenderer:SetModel( toggle.checkedModel )
        else
            toggle.gameObject.modelRenderer:SetModel( toggle.uncheckedModel )
        end
    end
end
