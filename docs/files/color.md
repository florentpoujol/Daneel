# Color

The `Color` object allows to set thousands of color to model and text renderers with a preset of only up to 8 models or fonts.

Instances of the `Color` object allow you to hold a color information as RGB keys or as hexadecimal string.

	local color1 = Color.New( 0, 255, 150 )
	-- color.hex (or color:GetHex()) == 00FF96

	local color2 = Color( "FFAD52" )
	-- color.b == 82

	color1 + color2 == Color( 255, 255, 232 )

	-- you can also access color components as an array
	color[1] == color.r


Model and text renderers implement a `renderer:SetColor()` function




You can extends the `Color.colorsByName` dictionary to give name to predetermined colors. Keys are the color name, values are the color objects.

Once a color is set in the table, you can access it via `Color[colorName]`.  
If a color instance is one of the colors set in the table, you can get its name via `color:GetName()` (or as always `color.name`)
