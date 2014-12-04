# Color

The `Color` object allows to set thousands of color to model and text renderers with a preset of only up to 8 models or fonts.

- [Color instances](#color-instances)
- [Named colors](#named-colors)
- [Thousands of colors](#thousands-of-colors)
- [Usage](#usage)


<a name="color-instances"></a>
## Color instances

Instances of the `Color` object allow you to hold a color information as RGB keys or as hexadecimal string.

	local color1 = Color.New( 0, 255, 150 )
	-- color.hex (or color:GetHex()) == "00FF96"

	local color2 = Color( "FFAD52" )
	-- color.b == 82

	color1 + color2 == Color( 255, 255, 232 )

	-- you can also access color components as an array
	color[1] == color.r


<a name="named-colors"></a>
## Named colors

You can extends the `Color.colorsByName` dictionary to give name to predetermined colors. Keys are the color name, values are the color objects.  
Once a color is set in the table, you can access it via `Color[colorName]`.  
If a color instance is one of the colors set in the table, you can get its name via `color:GetName()` (or as always `color.name`).

	Color.colorsByName.beige = Color(255, 160, 95)

<a name="thousands-of-colors"></a>
## Thousands of colors

The system can only display the 7140 colors that follow one of these patterns :

- Some components are equal to 255, others are equal and have any value (between 0 and 255). Ie: (255, 89, 255) (120, 255, 120)
- Some components are equal to 0, others are equal and have any value. Ie: (100, 0, 100) (0, 150, 0)
- One component is equal to 0, one other is equal to 255 and the last one has any value. Ie: (0, 255, 56) (180, 0, 255)
- Two components are equal and the third one is apart and equidistant from 128 (their mean is equal to 128 ((max + min)/2 = 128)). Ie: (153, 102, 153) (51, 51, 204)
- One component is equal to 0 or 255 and the two others are apart and equidistant from 128. Ie : (255, 55, 200) (170, 85, 0)

<a name="usage"></a>
## Usage

To display these thousands of colors, you must create up to eight assets (models or fonts), each one having one of the primary or secondary colors: red, green, blue, magenta, yellow, cyan, black and white.  
Each asset must be named after its color (`"MyFolder/Green"` for the green asset).

But you don't need the eight assets for every colors.  
If you don't have an asset of a certain color and it is needed, you will get an error in the Runtime Report.  
Ie with a missing green model :

	Color._getAsset(): Could not find asset of type 'Model' at path 'Colors/Green' for ?Color: { r=0, g=255, b=0, hex="00FF00", name="green" }

If you have only one set of assets of each type, you can put them in a folder named after the value of the `Color.colorAssetsFolder` property (`"Colors/"` by default).  
Edit this property if you want to use another folder name.

If you have several sets of assets of the same type (several models or fonts) that must be colored, you have to set one of the asset on the renderer before actually setting the color (so that the asset's path can be inferred).

	self.gameObject.modelRenderer.model = "Character/Red"
	self.gameObject.modelRenderer:SetColor( "008CBE" ) -- some light blue


	self.gameObject.textRenderer.font = "Calibri/Red"
	self.gameObject.textRenderer.color = Color(255, 160, 95)
