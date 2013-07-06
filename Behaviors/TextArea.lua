
-- Public properties :
-- areaWidth (string) [default=""]
-- wordWrap (boolean) [default=false]
-- EOL (string) [default="<br>"]
-- lineHeight (string) [default="0.5"]
-- font (string) [default=""]
-- text (string) [default="TextArea"]
-- alignment (string) [default="left"]
-- opacity (number) [default=1.0]


function Behavior:Awake()
	if self.gameObject.textArea == nil then
		self.gameObject:AddComponent( "TextArea", self )
	end
end

