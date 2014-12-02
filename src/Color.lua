-- Color.lua
-- Contains the Color object and the color solver.
--
-- Last modified for v1.5.0
-- Copyright © 2013-2014 Florent POUJOL, published under the MIT license.

Color = {}

ColorMT = {
    __call = function(Object, ...) return Object.New(...) end, -- Allow to call Color.New() by writing Color()

    __index = function( object, key )
        -- allow to get new Color instance from colors in the Color.colorsByname table by writing "Color.blue", "Color.red", ...
        local colorArray = Color.colorsByName[ key:lower() ]
        if colorArray ~= nil then
            return Color.New( colorArray )
        end
    end
}

setmetatable(Color, ColorMT)

function Color.__index( color, key )
    local comps = {"r", "g", "b"}
    key = comps[key] or key -- if key was == 1, 2 or 3; key is now r, g or b
    return Color[ key ] or color[ "_"..key ] or rawget( color, key )
end

function Color.__newindex( color, key, value )
    local comps = {"r", "g", "b"}
    key = comps[key] or key 

    if key == "r" or key == "g" or key == "b" then
        color["_"..key] = math.round( math.clamp( tonumber( value ), 0, 255 ), 0 )
    else
        rawset( color, key, value )
    end
end

function Color.__tostring(color)
    local s = "Color: { r="..color._r..", g="..color._g..", b="..color._b..", hex="..color:GetHex()
    local name = color:GetName()
    if name ~= nil then
        s = s..", name='"..name.."'"
    end
    return s.." }"
end

--- Create a new color object.
-- @param r (number, Color, table, Vector3 or string) The color's red component or a table with r,g,b / x,y,z / 1,2,3 components, or a color name or an hexadecimal color.
-- @param g (number) [optional] The color's green component.
-- @param b (number) [optional] The color's blue component.
-- @return (Color) The color object.
function Color.New(r, g, b)
    local color = setmetatable({}, Color)
    if type( r ) == "string" and g == nil then
        local colorFromName = Color[r] -- r is a color name
        if colorFromName ~= nil then
            return colorFromName
        else -- r is a hexadecimal color
            color:SetHex( r )
        end
    else
        if type( r ) == "table" then
            -- I don't check for the metatable in order to allow to pass table without them, no necessarily strict Color or Vector3 object
            if r.r ~= nil then -- Color style
                g = r.g
                b = r.b
                r = r.r
            elseif r.x ~= nil then -- Vector3 style
                g = r.y
                b = r.z
                r = r.x
            elseif #r == 3 then -- array style
                g = r[2]
                b = r[3]
                r = r[1]
            end
        end
        color.r = r or 0
        color.g = g or color._r
        color.b = b or color._g
    end
    return color
end

Color.colorsByName = {
    -- values can be array, Color or hex color
    red = {255,0,0},
    green = {0,255,0},
    blue = {0,0,255},
    yellow = {255,255,0},
    cyan = {0,255,255},
    magenta = {255,0,255},
    white = {255,255,255},
    black = {0,0,0},
}
-- More color/names : https://github.com/franks42/colors-rgb.lua/blob/master/colors-rgb.lua
-- Note that some of these colors can't be displayed by the current algorithm.

for name, colorArray in pairs( Color.colorsByName ) do
    Color.colorsByName[name] = Color.New(colorArray)
end

--- Return the name of the color, provided it can be found in the `Color.colorsByName` object.
-- @param color (Color) The color object.
-- @return (string) The color's name or nil.
function Color.GetName( color )
    for name, colorArray in pairs( Color.colorsByName ) do
        if type( colorArray ) == "string" then
            colorArray = { Color.HexToRGB( colorArray ) }
        end

        if color._r == colorArray[1] and color._g == colorArray[2] and color._b == colorArray[3] then
            return name
        end
    end
end

--------------------------------------------------------------------------------
-- Object format conversion

--- Convert the provided color object to an array.
-- Allow to loop on the color's components in order.
-- @param color (Color) The color object.
-- @return (table) The color as array.
function Color.ToArray( color )
    return { color._r, color._g, color._b }
end

--- Convert the provided color object to a table with "r", "g", "b" keys.
-- Allow to loop on the color's components.
-- @param color (Color) The color object.
-- @return (table) The color as table with "r", "g", "b" keys.
function Color.ToRGB( color )
    return { r = color._r, g = color._g, b = color._b }
end

--- Convert the provided color object to a Vector3.
-- This can be needed because the component's values of a Vector3 are not clamped between 0 and 255.
-- @param color (Color) The color object.
-- @return (Vector3) The color as a Vector3 with "x", "y", "z" keys.
function Color.ToVector3( color )
    return Vector3:New( color._r, color._g, color._b )
end

--- Returns a string representation of the color's components, each component being separated y a space.
-- ie: For a color { 10, 250, 128 }, the returned string would be "10 250 128".
-- Such string can be converted back to a color object with string.tocolor()
-- @param color (Color) The color object.
-- @return (string) The string.
function Color.ToString( color )
    return color._r.." "..color._g.." "..color._b
end

--- Convert a string representation of a color component's values to a Color object.
-- ie: For a string "10 250 128", the returned color would be { 10, 250, 128 }.
-- Such string can be created from a Color with with Color.ToString()
-- @param sColor (string) The color as a string, each component's value being separated by a space.
-- @return (Color) The color.
function string.tocolor( sColor )
    local color = Color.New(0)
    local comps = { "b", "g", "r" }
    for match in string.gmatch( sColor, "[0-9]+" ) do
        color[ table.remove( comps ) ] = tonumber(match)
    end
    return color
end

--------------------------------------------------------------------------------
-- Hex / HSV / RGB conversion

--- Return the hexadecimal representation of the provided color or r, g, b components.
-- Only return the 6 characters of the component's values, so you may want to prefix it with "#" or "0x" yourself.
-- @param r (number, Color, table, Vector3 or string) The color's red component or a table with r,g,b / x,y,z / 1,2,3 components, or a color name or an hexadecimal color.
-- @param g (number) [optional] The color's green component.
-- @param b (number) [optional] The color's blue component.
function Color.RGBToHex( r, g, b )
    -- From : https://gist.github.com/marceloCodget/3862929
    local colorArray = Color.New( r, g, b ):ToArray()
    local hexadecimal = ""

    for key=1, 3 do
        local value = colorArray[key]
        local hex = ''

        while value > 0 do
            local index = math.fmod(value, 16) + 1
            value = math.floor(value / 16)
            hex = string.sub('0123456789ABCDEF', index, index) .. hex
        end

        if string.len(hex) == 0 then
            hex = '00'
        elseif string.len(hex) == 1 then
            hex = '0' .. hex
        end

        hexadecimal = hexadecimal .. hex
    end

    return hexadecimal
end

--- Return the color's hexadecimal representation.
-- Only return the 6 characters of the component's values, so you may want to prefix it with "#" or "0x" yourself.
-- @param color (Color) The color object.
-- @return (string) The color's hexadecimal representation.
function Color.GetHex( color )
    return Color.RGBToHex( color )
end

--- Convert an hexadecimal color into its RGB components.
-- @param hex (string) The hexadecimal color. May be prefixed by "#", "0x", "0X" or nothing.
-- @return (number) The color's red component.
-- @return (number) The color's green component.
-- @return (number) The color's blue component.
function Color.HexToRGB( hex )
    -- From : https://gist.github.com/jasonbradley/4357406
    hex = hex:gsub("#",""):gsub("0x",""):gsub("0X","")
    return tonumber("0x"..hex:sub(1,2)), tonumber("0x"..hex:sub(3,4)), tonumber("0x"..hex:sub(5,6))
end

--- Set the color from an hexadecimal representation.
-- @param color (Color) The color object.
-- @param hex (string) The color's hexadecimal representation.
function Color.SetHex( color, hex )
    local rgb = { Color.HexToRGB( hex ) }
    for i=1, 3 do
        color[i] = rgb[i]
    end
end

--- Return the Hue, Saturation and Value of the provided color.
-- @param color (Color) The color object.
-- @return (number) The hue of the color (between 0 and 1).
-- @return (number) The saturation of the color (between 0 and 1).
-- @return (number) The value of the color (between 0 and 1).
function Color.GetHSV( color )
    -- Code adapted from rgbToHsv() : https://github.com/EmmanuelOga/columns/blob/master/utils/color.lua
    local r, g, b = color._r / 255, color._g / 255, color._b /255
    local max, min = math.max(r, g, b), math.min(r, g, b)
    local h, s, v
    v = max
    local d = max - min

    if max == 0 then
        s = 0
    else
        s = d / max
    end

    if max == min then
        h = 0 -- achromatic
    else
        if max == r then
            h = (g - b) / d
            if g < b then
                h = h + 6
            end
        elseif max == g then
            h = (b - r) / d + 2
        elseif max == b then
            h = (r - g) / d + 4
        end
        h = h / 6
    end
    return h, s, v
end

--------------------------------------------------------------------------------
-- Operator functions

--- Allow to check for the equality between two Color objects using the == comparison operator.
-- @param a (Color) The left member.
-- @param b (Color) The right member.
-- @return (boolean) True if the same components of the two colors are equal (a.r=b.r, a.g=b.g and a.b=b.b)
function Color.__eq(a, b)
    return (a._r == b._r and a._g == b._g and a._b == b._b)
end

--- Allow to add two Color objects by using the + operator.
-- Ie : color1 + color2
-- @param a (Color) The left member.
-- @param b (Color) The right member.
-- @return (Color) The new color object.
function Color.__add( a, b )
    return Color.New( a._r + b._r, a._g + b._g, a._b + b._b )
end

--- Allow to subtract two Color objects by using the - operator.
-- Ie : color1 - color2
-- @param a (Color) The left member.
-- @param b (Color) The right member.
-- @return (Color) The new color object.
function Color.__sub( a, b )
    return Color.New( a._r - b._r, a._g - b._g, a._b - b._b )
end

--- Allow to multiply two Color object or a Color object and a number by using the * operator.
-- @param a (Color or number) The left member.
-- @param b (Color or number) The right member.
-- @return (Color) The new color object.
function Color.__mul( a, b )
    local color = Color.New(0)
    if type(a) == "table" and type(b) == "number" then
        color.r = a._r * b
        color.g = a._g * b
        color.b = a._b * b
    elseif type(a) == "number" and type(b) == "table" then
        color.r = a * b._r
        color.g = a * b._g
        color.b = a * b._b
    elseif type(a) == "table" and type(b) == "table" then
        color.r = a._r * b._r
        color.g = a._g * b._g
        color.b = a._b * b._b
    end
    return color
end

--- Allow to divide two Color objects or a Color object and a number by using the / operator.
-- @param a (Color or number) The numerator.
-- @param b (Color or number) The denominator. Can't be equal to 0.
-- @return (Color) The new color object.
function Color.__div( a, b )
    local color = Color.New(0)
    if type(a) == "table" and type(b) == "number" then
        color.r = a._r / b
        color.g = a._g / b
        color.b = a._b / b
    elseif type(a) == "number" and type(b) == "table" then
        color.r = a / b._r
        color.g = a / b._g
        color.b = a / b._b
    elseif type(a) == "table" and type(b) == "table" then
        color.r = a._r / b._r
        color.g = a._g / b._g
        color.b = a._b / b._b
    end
    return color
end

----------------------------------------------------------------------------------
-- Solver

-- Find the Back and Front color and the Front opacity needed to render the provided Target color.
-- @param Tc (color) The target color.
-- @return (Color) The back color.
-- @return (Color) The front color, or nil.
-- @return (number) The front opacity.
-- @return (Color) The result color. Will be different from Tc when the system can't render Tc.
function Color._resolve( Tc )
    -- Back color       
    -- Bc = ( Fc * Fo - Tc ) / ( Fo - 1 )
    -- Front color
    -- Fc = ( Tc - Bc ) / Fo + Bc
    -- Front Opacity
    -- Fo = ( Tc - Bc ) / ( Fc - Bc ) 
    -- Target color
    -- Tc = ( Fc - Bc ) * Fo + Bc

    local Bc = Color.New(0)
    local Fc = Color.New(0)
    for comp, value in pairs( Tc:ToRGB() ) do
        if value ~= 255 and value >= 127.5 then
            Bc[comp] = 255
            Fc[comp] = 0
        elseif value ~= 0 and value < 127.5 then
            Bc[comp] = 0
            Fc[comp] = 255
        else -- value = 255 or 0
            Bc[comp] = value
            Fc[comp] = value
        end
    end
    if Fc == Bc then
        Fc = nil
    end

    local Rc = Bc -- result/rendered color
    local Fo = 0
    if Fc ~= nil then
        Fo = Color._getFrontOpacity( Bc, Fc, Tc )
        Rc = Color.New( ( Fc:ToVector3() - Bc:ToVector3() ) * Fo + Bc:ToVector3() )

        if Rc ~= Tc then
            -- the Tc color can't be achieved with only two levels of color, a thrid one is needed
            print("Color._resolve(): Sorry, can't resolve target color [1], getting [2] instead", Tc, Rc )
        end
    end

    return Bc, Fc, Fo, Rc
end

-- Calculate the opacity of the front renderer.
-- @param Bc (color) The back color.
-- @param Fc (color) The front color.
-- @param Tc (color) The target color.
-- @return (number) The front opacity.
function Color._getFrontOpacity( Bc, Fc, Tc )
    -- Find the component for which the back and front color haven't the same value
    -- because it would cause a division by zero in the opacity's calculation
    local comp = nil
    local comps = { "r", "g", "b" }
    for i=1, 3 do
        local _comp = comps[i]
        if Fc[_comp] ~= Bc[_comp] then
            comp = _comp
            break
        end
    end

    if comp ~= nil then
        -- Fo = ( Tc - Bc ) / ( Fc - Bc ) 
        return math.round( (Tc[comp] - Bc[comp]) / (Fc[comp] - Bc[comp]), 3 )
    else
        print("Color._getFrontOpacity(): can't calculate opacity because no suitable component was found", Bc, Fc, Tc) 
        return 1
    end
end

--------------------------------------------------------------------------------
-- Asset

Color.colorAssetsFolder = "Colors/" -- to be edited by the user if he wants another folder

-- Get the asset (Model or Font) corresponding to the provided color.
-- The color must have been set in the Color.colorsByName table.
-- @param color (Color) The color object.
-- @param assetType (string) The asset type ("Model" or "Font")
-- @param assetFolder (string) [optional] The asset folder to get the asset from.
-- @return (Model or Font) The asset, or nil.
function Color._getAsset( color, assetType, assetFolder )
    if not string.endswith( Color.colorAssetsFolder, "/" ) then -- let's be fool-proof
        Color.colorAssetsFolder = Color.colorAssetsFolder.."/"
    end
    assetFolder = assetFolder or Color.colorAssetsFolder

    local name = color:GetName() -- name may be nil !
    if name == nil then
        if Daneel.Config.debug.enableDebug == true then
            print("Color._getAsset(): Can't find the name of the provided color", color, "It must be set in the Color.colorsByName table.")
        end
        return nil
    end

    local path = assetFolder..name
    local asset = CS.FindAsset( path, assetType )
    if asset == nil then
        path = assetFolder..string.ucfirst(name) -- let's be a little more fool-proof
        asset = CS.FindAsset( path, assetType )
    end

    if asset == nil and Daneel.Config.debug.enableDebug == true then
        print("Color._getAsset(): Could not find asset of type '"..assetType.."' at path '"..path.."' for ", color)
    end
    return asset
end

--------------------------------------------------------------------------------
-- Set color

-- Set the color of the provided model or text renderer.
-- @param renderer (ModelRenderer or TextRenderer) The renderer.
-- @param color (Color) The color instance.
function Color._setColor( renderer, color )
    local rendererType, assetType, assetSetterFunction, assetGetterFunction
    local mt = getmetatable( renderer )
    if mt == ModelRenderer then
        rendererType = "ModelRenderer"
        assetType = "Model"
        assetSetterFunction = ModelRenderer.SetModel
        assetGetterFunction = ModelRenderer.GetModel
    elseif mt == TextRenderer then
        rendererType = "TextRenderer"
        assetType = "Font"
        assetSetterFunction = TextRenderer.SetFont
        assetGetterFunction = TextRenderer.GetFont
    end

    local Bc, Fc, Fo = color:_resolve()

    local gameObject = renderer.gameObject
    local frontRndr = gameObject.frontColorRenderer

    -- back
    local assetFolder = nil
    local oldAsset = assetGetterFunction( renderer )
    if oldAsset ~= nil then
        assetFolder = oldAsset:GetPath():gsub(oldAsset.name, "") -- with trailing slash
    end

    local newAsset = Bc:_getAsset( assetType, assetFolder )
    if oldAsset ~= newAsset then
        assetSetterFunction( renderer, newAsset )
    end

    -- front
    if frontRndr == nil and Fc ~= nil then
        frontRndr = gameObject:CreateComponent( rendererType )
        gameObject[ string.lcfirst( rendererType ) ] = renderer
        gameObject.frontColorRenderer = frontRndr

        if rendererType == "TextRenderer" then
            frontRndr:SetAlignment( renderer:GetAlignment() )
        end
    end

    if frontRndr ~= nil then
        if Fc ~= nil then
            local newAsset = Fc:_getAsset( assetType, assetFolder )
            local oldAsset = assetGetterFunction( frontRndr )
            if oldAsset ~= newAsset then
                -- setting a new Font asset every time the function was called make the test project actually lag
                -- setting big Font asset seems very slow
                assetSetterFunction( frontRndr, newAsset )
            end
        end

        frontRndr.Fo = Fo
        frontRndr:SetOpacity( Fo * renderer:GetOpacity() )
    end
end

--- Set the color of the provided model renderer.
-- @param modelRenderer (ModelRenderer) The model renderer.
-- @param color (Color) The color instance.
function ModelRenderer.SetColor( modelRenderer, color )
    Color._setColor( modelRenderer, color )
end

--- Set the color of the provided text renderer.
-- @param textRenderer (textRenderer) The text renderer.
-- @param color (Color) The color instance.
function TextRenderer.SetColor( textRenderer, color )
    Color._setColor( textRenderer, color )
end

local oSetText = TextRenderer.SetText
function TextRenderer.SetText( textRenderer, text )
    oSetText( textRenderer, text )

    local frontRndr = textRenderer.gameObject.frontColorRenderer
    if frontRndr ~= nil then
        oSetText( frontRndr, text )
    end
end

local oSetAlignment = TextRenderer.SetAlignment
function TextRenderer.SetAlignment( textRenderer, alignment )
    oSetAlignment( textRenderer, alignment )

    local frontRndr = textRenderer.gameObject.frontColorRenderer
    if frontRndr ~= nil then
        oSetAlignment( frontRndr, alignment )
    end
end

-- Set the opacity of the back and front model or text renderer.
-- @param renderer (ModelRenderer or TextRenderer) The (back) model or text renderer.
-- @param opacity (number) The opacity.
function Color._setOpacity( renderer, opacity )
    renderer:oSetOpacity( opacity )
    local frontRndr = renderer.gameObject.frontColorRenderer
    if frontRndr ~= nil and renderer ~= frontRndr then
        local Fo = frontRndr.Fo or 1
        frontRndr:oSetOpacity( Fo * opacity )
    end
end

ModelRenderer.oSetOpacity = ModelRenderer.SetOpacity
ModelRenderer.SetOpacity = Color._setOpacity

TextRenderer.oSetOpacity = TextRenderer.SetOpacity
TextRenderer.SetOpacity = Color._setOpacity

--------------------------------------------------------------------------------
-- Get color

-- Get the color of the provided model or text renderer.
-- @param renderer (ModelRenderer or TextRenderer) The model or text renderer.
-- @return Rc (Color) The result/rendered color (the one you see).
function Color._getColor( renderer )
    local rendererType, assetGetterFunction
    local mt = getmetatable( renderer )
    if mt == ModelRenderer then
        rendererType = "ModelRenderer"
        assetGetterFunction = ModelRenderer.GetModel
    elseif mt == TextRenderer then
        rendererType = "TextRenderer"
        assetGetterFunction = TextRenderer.GetFont
    end

    local Bc, Fc, Rc

    -- back
    local asset = assetGetterFunction( renderer )
    if asset ~= nil then
        Bc = Color[ asset:GetName() ]
    end

    -- front
    local frontRndr = renderer.gameObject.frontColorRenderer
    local Fo = 1
    if frontRndr ~= nil and Bc ~= nil then
        Fo = frontRndr.Fo or 1
        local asset = assetGetterFunction( frontRndr )
        if asset ~= nil then
            Fc = Color[ asset:GetName() ]
        end
    end

    if Bc ~= nil then
        if Fc ~= nil then
            Rc = Color.New( ( Fc:ToVector3() - Bc:ToVector3() ) * Fo + Bc:ToVector3() )
        else
            Rc = Bc
        end
    end
    return Rc
end

--- Get the color of the provided model renderer.
-- @param modelRenderer (ModelRenderer) The model renderer.
-- @return Rc (Color) The result/renderer color (the one you see).
function ModelRenderer.GetColor( modelRenderer )
    return Color._getColor( modelRenderer )
end

--- Get the color of the provided text renderer.
-- @param textRenderer (textRenderer) The text renderer.
-- @return Rc (Color) The result/renderer color (the one you see).
function TextRenderer.GetColor( textRenderer )
    return Color._getColor( textRenderer )
end

--------------------------------------------------------------------------------
-- Random

Color.Pattern = {
    DesaturedPlainColor = 1,
    DeValuedPlainColor = 2,
    Any0255 = 3, -- one comp = 0, other comp = 255, other comp may have any value

    -- These names are dumb... (FIXME)
    ["21128"] = 4, -- Two components are equal and the third one is apart and equidistant from 128 (their mean is 128 ((max + min)/2 = 128)) : ie : (153, 102, 153) (51, 51, 204)
    ["0128"] = 5, -- One of the component is equal to 0 or 255 and the two others are apart and equidistant from 128 (their mean is 128 ((max + min)/2 = 128))   ie : (255, 50, 200) (128, 0, 128) (170, 85,
}

Color.PatternsById = {}
for name, id in pairs( Color.Pattern ) do
    Color.PatternsById[ id ] = name
end

--- Returns a random color, optional of the provided pattern.
-- @param pattern (number or Color.Patterns) [optional] The color pattern.
-- @return (Color) The color.
function Color.GetRandom( pattern )
    -- sekect pattern
    pattern = pattern or math.random( #Color.PatternsById )

    local plainColors = table.copy( Color.colorsByName )
    plainColors.black = nil
    plainColors = table.getvalues( plainColors )
    -- plainColors contains r, g, b, y, c, m, w

    local color = Color.New(0)
    if pattern == 1 then
        -- desat plain color
        local baseColor = Color.New( plainColors[ math.random( #plainColors ) ] )
        color = baseColor + Color.New( math.random( 0, 255 )  ) -- this move the components which where at 0 closer to 255

    elseif pattern == 2 then
        -- devalue plain color
        local baseColor = Color.New( plainColors[ math.random( #plainColors ) ] )
        color = baseColor - Color.New( math.random( 0, 255 ) ) -- this move the components which where at 0 closer to 255

    elseif pattern == 3 then
        -- 0, 255, any | 0, any, 255 | 255, 0, any | 255, any, 0 | any, 0, 255 | any, 255, 0
        local values = { 0, 255, math.random( 0, 255 ) }
        for i=1, 3 do
            color[i] = table.remove( values, math.random( #values ) )
        end

    elseif pattern == 4 then
        -- Two components are equal and the third one is apart and equidistant from 128 (their mean is 128 ((max + min)/2 = 128)) : ie : (153, 102, 153) (51, 51, 204)
        local min = math.random(0, 128)
        local max = 255 - min
        local other = min
        if math.random(2) == 1 then
            other = max
        end
        local values = { min, max, other }
        for i=1, 3 do
            color[i] = table.remove( values, math.random( #values ) )
        end

    elseif pattern == 5 then
        -- One of the component is equal to 0 or 255 and the two others are apart and equidistant from 128 (their mean is 128 ((max + min)/2 = 128))   ie : (255, 50, 200) (128, 0, 128) (170, 85,
        local min = math.random(0, 128)
        local max = 255 - min
        local other = 0
        if math.random(2) == 1 then
            other = 255
        end
        local values = { min, max, other }
        for i=1, 3 do
            color[i] = table.remove( values, math.random( #values ) )
        end
    end

    return color
end
