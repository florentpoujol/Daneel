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
        for name, colorArray in pairs( Color.colorsByName ) do
            if key == name then
                return Color.New( colorArray )
            end
        end
    end
}

setmetatable(Color, ColorMT)

function Color.__index( color, key )
    if Color[ key ] ~= nil then
        return Color[ key ]
    end

    if key == 1 or key == 2 or key == 3 then
        local comps = {"r", "g", "b"}
        key = comps[key]
    end

    if key == "r" or key == "g" or key == "b" then
        return color[ "_"..key ]
    end

    return rawget( color, key )
end

function Color.__newindex( color, key, value )
    if key == 1 or key == 2 or key == 3 then
        local comps = {"r", "g", "b"}
        key = comps[key]
    end

    if key == "r" or key == "g" or key == "b" then
        color["_"..key] = math.round( math.clamp( tonumber( value ), 0, 255 ) )
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

--------------------

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
    gray = {50,50,50},
    grey = {50,50,50}, -- English spelling
}
-- More color/names : https://github.com/franks42/colors-rgb.lua/blob/master/colors-rgb.lua
-- Note that some of these colors can't be displayed by the current algorithm.

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

--------------------

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
-- @param color (Color) The color obejct.
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

--------------------

--- Return the hexadecimal representation of the provided color or r, g, b components.
-- Only return the 6 characters of the component's values, so you may want to prefix it with "#" or "0x" yourself.
-- @param r (number, Color, table, Vector3 or string) The color's red component or a table with r,g,b / x,y,z / 1,2,3 components, or a color name or an hexadecimal color.
-- @param g (number) [optional] The color's green component.
-- @param b (number) [optional] The color's blue component.
function Color.RGBToHex( r, g, b )
    -- From : https://gist.github.com/marceloCodget/3862929    
    local colorArray = Color.New( r, g, b ):ToArray()
    local hexadecimal = ""
     
    for key, value in ipairs(colorArray) do
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
    local comps = { "r", "g", "b" }
    for i=1, 3 do
        color[ comps[i] ] = rgb[i]
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

--------------------

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

--- Allow to substract two Color objects by using the - operator.
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

-- Bc : Back color
-- Fc : Front color
-- Fo : Front opacity (back opacity is always 1)
-- Tc : Target color, the one we see

-- Relations :
-- Bc = ( Fc * Fo - Tc ) / ( Fo - 1 )
-- Fc = ( Tc - Bc ) / Fo + Bc
-- Fo = ( Tc - Bc ) / ( Fc - Bc )
-- Tc = ( Fc - Bc ) * Fo + Bc

-- if Bc = 0 then Tc = 255 * Fo
-- if Bc = 255 then Tc = Fc

-- With a set of 6 predetermined colors Red, Green, Blue, Magenta, Cyan, Yellow
-- We can create 2295 (255*2*3+255*3) colors

-- The generator can create colors where :
-- One of the component is equal to 0 or 255 and the mean of the other components is 128 (they are apart and equidistant from 128)
-- ie : (255, 50, 200) (128, 0, 128) (170, 85, 0)
-- or
-- Two components are equal and the third one is apart and equidistant from 128 ((max + min)/2 = 128)
-- ie : (153, 102, 153) (51, 51, 204)
-- or
-- one comp = 0, other comp = 255, on
-- or
-- a plain color (R, g, b, c, m, y, black, w) with saturation or value diminished


-- circle : one comp = 0, other are equidistant
-- hexagon : cyan-magenta-yellow = one comp = 255, others are equidistant
-- calque 3 :    two color equal, other equidistant
-- star : one or two at 255, othe is moving    only saturation is moving


-- white model change the saturation    opa = 0.5 > sat =      opa = 0.3  sat = 70
-- black model change   opa = 0.3 sat = 

-- sat = 0   > rgb coords goes toward the highmost coords
-- sat correspond to the smallest component value
-- sat = 100 - lowest comp / highest comp * 100
-- or (max - min ) / max  if min and max are on 0-1 range

-- value = 0   > rgb coords goes toward the smallest coords
-- value correspond to the smallest component value

-- Calculate the opacity of the front model.
-- @param Bc (color) The back color.
-- @param Fc (color) The front color.
-- @param Tc (color) The target color.
-- @return (number) The front opacity.
local function getFrontOpacity( Bc, Fc, Tc )
    local Fo = 0

    -- Find the component for which the back and front color haven't the same value
    -- because it would cause a division by zero in the opacity's calculation
    local comp = nil
    local comps = { "r", "g", "b" }
    for i, _comp in ipairs( comps ) do
        if Fc[_comp] ~= Bc[_comp] then
            comp = _comp
            break
        end
    end
    
    if comp ~= nil then
        Fo = math.round( (Tc[comp] - Bc[comp]) / (Fc[comp] - Bc[comp]), 3 )
    else
        print("getFrontOpacity(): can't calculate opacity because no suitable component was found", Bc, Fc, Tc)
    end
    
    return Fo
end

--- Find the Back and Front color and the Front opacity needed to render the provided Target color.
-- @param Tc (color) The target color.
-- @return (Color) The back color.
-- @return (Color) The front color, or nil.
-- @return (number) The front opacity.
function Color.Resolve( Tc )
    local Bc = Color.New(0)
    local Fc = Color.New(0)
    local Fo = 0

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

    if Fc ~= nil then
        Fo = getFrontOpacity( Bc, Fc, Tc )
        -- actual color
        local Ac = Color.New( ( Fc:ToVector3() - Bc:ToVector3() ) * Fo + Bc:ToVector3() )
        
        if Ac ~= Tc then
            -- the Tc color can't be achieved with only two levels of color
            -- a thrid one is needed
            print("Color.Resolve(): Sorry, can't resolve ", Tc )
            print("Color.Resolve(): Getting instead ", Ac )
        end
    end

    return Bc, Fc, Fo
end

--------------------

-- Set the color of the provided model or text renderer.
-- @param renderer (ModelRenderer or TextRenderer) The renderer.
-- @param r (number, Color or string) The color's red component, a color object, a color as hexadecimal string or a color name that can be found in the Color.colorsByName table.
-- @param g (number) [optional] The color's green component.
-- @param b (number) [optional] The color's blue component.
local function setColor( renderer, r, g, b )
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

    local color = Color.New( r, g, b )
    local Bc, Fc, Fo = color:Resolve()
    
    -- back
    local newAsset = Bc:GetAsset( assetType )
    local oldAsset = assetGetterFunction( renderer )
    if oldAsset ~= newAsset then
        assetSetterFunction( renderer, newAsset )
    end
    
    -- front
    local gameObject = renderer.gameObject
    local frontRndr = gameObject[ "front"..rendererType ]
    if frontRndr == nil and Fc ~= nil then
        frontRndr = gameObject:CreateComponent( rendererType )
        gameObject[ string.lcfirst( rendererType ) ] = renderer
        gameObject[ "front"..rendererType ] = frontRndr

        if rendererType == "TextRenderer" then
            frontRndr:SetAlignment( renderer:GetAlignment() )
        end
    end

    if frontRndr ~= nil then
        if Fc ~= nil then
            local newAsset = Fc:GetAsset( assetType )
            local oldAsset = assetGetterFunction( frontRndr )
            if oldAsset ~= newAsset then 
                -- setting a new Font asset everytime the function was called make the test project actually lag
                -- setting big Font asset seems very slow
                assetSetterFunction( frontRndr, newAsset )
            end
        end
        
        if Fo ~= frontRndr:GetOpacity() then
            frontRndr:SetOpacity( Fo )
        end
    end
end

--- Set the color of the provided model renderer.
-- @param modelRenderer (ModelRenderer) The model renderer.
-- @param r (number, Color or string) The color's red component, a color object, a color as hexadecimal string or a color name that can be found in the Color.colorsByName table.
-- @param g (number) [optional] The color's green component.
-- @param b (number) [optional] The color's blue component.
function ModelRenderer.SetColor( modelRenderer, r, g, b )
    setColor( modelRenderer, r, g, b )
end

--- Set the color of the provided text renderer.
-- @param textRenderer (textRenderer) The text renderer.
-- @param r (number, Color or string) The color's red component, a color object, a color as hexadecimal string or a color name that can be found in the Color.colorsByName table.
-- @param g (number) [optional] The color's green component.
-- @param b (number) [optional] The color's blue component.
function TextRenderer.SetColor( textRenderer, r, g, b )
    setColor( textRenderer, r, g, b )
end

local oSetText = TextRenderer.SetText
function TextRenderer.SetText( textRenderer, text )
    oSetText( textRenderer, text )
    
    local frontRndr = textRenderer.gameObject.frontTextRenderer
    if frontRndr ~= nil then
        oSetText( frontRndr, text )
    end
end

local oSetAlignment = TextRenderer.SetAlignment
function TextRenderer.SetAlignment( textRenderer, alignment )
    oSetAlignment( textRenderer, alignment )
    
    local frontRndr = textRenderer.gameObject.frontTextRenderer
    if frontRndr ~= nil then
        oSetAlignment( frontRndr, alignment )
    end
end

--------------------

-- Get the color of the provided model or text renderer.
-- @param renderer (ModelRenderer or TextRenderer) The model or text renderer.
-- @return Rc (Color) The result/rendered color (the one you see).
-- @return Bc (Color) The back color.
-- @return Fc (Color) The front color.
-- @return Fo (number) The front opacity.
local function getColor( renderer )
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
    local Fo = 0

    -- back
    local asset = assetGetterFunction( renderer )
    if asset ~= nil then
        Bc = Color[ asset:GetName() ]
    end
    
    -- front
    local gameObject = renderer.gameObject
    local frontRndr = gameObject[ "front"..rendererType ]
    if frontRndr ~= nil then
        local asset = assetGetterFunction( frontRndr ) 
        if asset ~= nil then
            Fc = Color[ asset:GetName() ]
        end
        Fo = frontRndr:GetOpacity()
    end

    if Bc ~= nil and Fc ~= nil then
        Rc = Color.New( ( Fc:ToVector3() - Bc:ToVector3() ) * Fo + Bc:ToVector3() )
    end

    return Rc, Bc, Fc, Fo
end

--- Get the color of the provided model renderer.
-- @param modelRenderer (ModelRenderer) The model renderer.
-- @return Rc (Color) The result/renderer color (the one you see).
-- @return Bc (Color) The back color.
-- @return Fc (Color) The front color.
-- @return Fo (number) The front opacity.
function ModelRenderer.GetColor( modelRenderer )
    return getColor( modelRenderer )
end

--- Get the color of the provided text renderer.
-- @param textRenderer (textRenderer) The text renderer.
-- @return Rc (Color) The result/renderer color (the one you see).
-- @return Bc (Color) The back color.
-- @return Fc (Color) The front color.
-- @return Fo (number) The front opacity.
function TextRenderer.GetColor( textRenderer )
    return getColor( textRenderer )
end

--------------------

Color.colorAssetsFolder = "Colors/" -- to be edited by the user if he wants another folder

Color.modelsByColorName = {}
Color.fontsByColorName = {}

--- Get the asset (Model or Font) corresponding to the provided color
-- Normally, the provided color can only be Red, Green, Blue, Magenta, Yellow, Cyan, Black or White.
-- @param color (Color) The color object.
-- @param assetType (string) The asset type ("Model" or "Font")
-- @return (Model or Font) The asset, or nil.
function Color.GetAsset( color, assetType )
    local name = color:GetName()
    local lcAssetType = string.lower( assetType )
    local assetsByColorName = Color[ lcAssetType.."sByColorName" ]
    local asset = assetsByColorName[ name ]

    if asset == nil then
        if not string.endswith( Color.colorAssetsFolder, "/" ) then -- let's be fool-proof
            Color.colorAssetsFolder = Color.colorAssetsFolder.."/"
        end

        local path = Color.colorAssetsFolder..name
        asset = CS.FindAsset( path, assetType )
        
        if asset == nil then
            path = Color.colorAssetsFolder..string.ucfirst(name) -- let's be a little more fool-proof
            asset = CS.FindAsset( path, assetType )
        end

        if asset == nil then
            print("Color.GetAsset(): Could not find asset of type '"..assetType.."' at path '"..path.."' for ", color)
            return
        end

        assetsByColorName[ name ] = asset
    end

    return asset
end
