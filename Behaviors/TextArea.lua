
-- Behavior for Daneel.GUI.TextArea component.

-- Public properties :
-- areaWidth (string) [default=""]
-- wordWrap (boolean) [default=false]
-- newLine (string) [default="\n"]
-- lineHeight (string) [default="1"]
-- verticalAlignment (string) [default="top"]
-- font (string) [default=""]
-- text (string) [default="Text\nArea"]
-- alignment (string) [default=""]
-- opacity (number) [default=1.0]

-- creating a TextArea from Awake cause an exception (collecion being modified while looping on it)
function Behavior:Start()
	if self.gameObject.textArea == nil then
		local params = {
			wordWrap = self.wordWrap,
			opacity = self.opacity
		}
		local props = {"areaWidth", "newLine", "lineHeight", "verticalAlignment", "font", "text", "alignment"}
        for i, prop in ipairs( props ) do
            if self[ prop ]:trim() ~= "" then
                params[ prop ] = self[ prop ]
            end
        end

		self.gameObject:AddComponent( "TextArea", params )
	end
end
