-- Color.lua
-- Contains the Color object.
--
-- Last modified for v1.5.0
-- Copyright © 2013-2014 Florent POUJOL, published under the MIT license.


Color = {}

ColorMT = {
    __call = function(Object, ...) return Object.New(...) end,

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
    return "Color: { r="..color._r..", g="..color._g..", b="..color._b..", hex="..color:GetHex().." }"
end

--- Create a new color.

-- @return (Color) The color object.
function Color.New(r, g, b)
    local color = setmetatable({}, Color)

    if type( r ) == "string" and g == nil then
        color:SetHex( r )
    else
        if type( r ) == "table" then
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
        else

        color.r = r or 0
        color.g = g or color.r
        color.b = b or color.g
    end

    return color
end

--------------------

Color.colorsByName = {
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

--- Return the name of the color, provided it can be found in the `Color.colorsByName` object.
-- @param color (Color) The color object.
-- @return (string) The color's name or nil.
function Color.GetName( color )
    for name, colorArray in pairs( Color.colorsByName ) do
        if color._r == colorArray[1] and color._g == colorArray[2] and color._b == colorArray[3] then
            return name
        end
    end
end

--------------------

--- Convert the provided color object to an array.
-- Allow loop on a color's components in order.
-- @param color (Color) The color object.
-- @return (table) The color as array.
function Color.ToArray( color )
    return { color.r, color.g, color.b }
end

--- Convert the provided color object to a table with "r", "g", "b" keys.
-- Allow to loop on a color's components.
-- @param color (Color) The color object.
-- @return (table) The color as table with "r", "g", "b" keys.
function Color.ToRGB( color )
    return { r = color.r, g = color.g, b = color.b }
end

--- Returns a string representation of the color's components.
-- ie: For a color { 10, 250, 128 }, the returned string would be "10 250 128".
-- Such string can be converted back to a color object with string.tocolor()
-- @param color (Color) The color obejct.
-- @return (string) The string.
function Color.ToString( color )
    return color.r.." "..color.g.." "..color.b
end

--- Convert a string representation of a color component's values to a Color object.
-- ie: For a string "10 250 128", the returned color would be { 10, 250, 128 }.
-- Such string can be created from a Color with with Color.ToString()
-- @param sColor (string) The color as a string, each component's value being separated by a space.
-- @return (Color) The color.
function string.tocolor( sColor )
    local color = Color.New(0)
    local comps = { "b", "g", "r" }
    for match in string.gmatch( sColor, "[0-9.-]+" ) do
        color[ table.remove( comps ) ] = tonumber(match)
    end
    return color
end

--------------------

--- Return the hexadecimal representation of the provided color or r, g, b components.
-- Only return the 6 characters of the color's components, so you may want to add "#" or "0x" yourself.
-- @param r (number, Color, table or Vector3) The Red component of the color or a table with r,g,b / x,y,z / 1,2,3 components.
-- @param g (number) [optional] The green component of the color.
-- @param b (number) [optional] The blue component of the color.
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
-- Only return the 6 characters of the color's components, so you may want to add "#" or "0x" yourself.
-- @param color (Color) The color object.
-- @return (string) The color's hexadecimal representation.
function Color.GetHex( color )
    return Color.RGBToHex( color._r, color._g, color._b )
end

--- Convert an hexadecimal color into its RGB components.
-- @param hex (string) The hexadecimal color. May be prefixed by "#", "0x", "0X" or nothing
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
    for i, value in ipairs( rgb ) do
        color[ comps[i] ] = value
    end
end

--- Return the Hue, Saturation and Value of the provided color.
-- @param color (Color) The color object.
-- @return (number) The hue of the color (between 0 and 1).
-- @return (number) The saturation of the color (between 0 and 1).
-- @return (number) The value of the color (between 0 and 1).
function Color.GetHSV( color )
    -- Code adapted from rgbToHsv() : https://github.com/EmmanuelOga/columns/blob/master/utils/color.lua
    local r, g, b = color.r / 255, color.g / 255, color.b /255
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
    return (a.r == b.r and a.g == b.g and a.b == b.b)
end

--- Allow to add two Color objects by using the + operator.
-- Ie : color1 + color2
-- @param a (Color) The left member.
-- @param b (Color) The right member.
-- @return (Color) The new color object.
function Color.__add( a, b )
    return Color.New( a.r + b.r, a.g + b.g, a.b + b.b )
end  

--- Allow to substract two Color objects by using the - operator.
-- Ie : color1 - color2
-- @param a (Color) The left member.
-- @param b (Color) The right member.
-- @return (Color) The new color object.
function Color.__sub( a, b )
    return Color.New( a.r - b.r, a.g - b.g, a.b - b.b )
end

--- Allow to multiply two Color object or a Color object and a number by using the * operator.
-- @param a (Color or number) The left member.
-- @param b (Color or number) The right member.
-- @return (Color) The new color object.
function Color.__mul( a, b )
    local new = Color.New(0)
    if type(a) == "table" and type(b) == "number" then
        new.r = a.r * b
        new.g = a.g * b
        new.b = a.b * b
    elseif type(a) == "number" and type(b) == "table" then
        new.r = a * b.r
        new.g = a * b.g
        new.b = a * b.b
    elseif type(a) == "table" and type(b) == "table" then
        new.r = a.r * b.r
        new.g = a.g * b.g
        new.b = a.b * b.b
    end
    return new
end

--- Allow to divide two Color objects or a Color object and a number by using the / operator.
-- @param a (Color or number) The numerator.
-- @param b (Color or number) The denominator. Can't be equal to 0.
-- @return (Color) The new color object.
function Color.__div( a, b )
    local new = Color.New(0)
    if type(a) == "table" and type(b) == "number" then
        new.r = a.r / b
        new.g = a.g / b
        new.b = a.b / b
    elseif type(a) == "number" and type(b) == "table" then
        new.r = a / b.r
        new.g = a / b.g
        new.b = a / b.b
    elseif type(a) == "table" and type(b) == "table" then
        new.r = a.r / b.r
        new.g = a.g / b.g
        new.b = a.b / b.b
    end
    return new
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
-- One of the component is equal to 0 or 255 and the other components are apart and equidistant from 128
-- ie : (255, 50, 200) (128, 0, 128) (170, 85, 0)
-- or
-- Two components are equal and the third one is apart and equidistant from 128
-- ie : (153, 102, 153) (51, 51, 204)


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


Coler.modelsFolder = "Colors/" -- to be edited by the user if he wants another folder
Color.modelsByColorName = {}

function Color.GetModel( color )
    local name = color:GetName()
    local model = Color.modelsByColorName[ name ]

    if model == nil then
        if not string.endswith( Color.modelsFolder, "/" ) then -- let's be fool-proof
            Color.modelsFolder = Color.modelsFolder.."/"
        end

        local path = Color.modelsFolder..name
        model = CS.FindAsset( path, "Model" )
        
        path = Color.modelsFolder..string.ucfirst(name) -- let's be a little more fool-proof
        model = CS.FindAsset( path, "Model" )

        if model == nil then
            print("Color.GetModel(): Could not find model at path '"..path.."' for ", color)
            return
        end

        Color.modelsByColorName[ name ] = model
    end

    return model
end

-- Calculate the opacity of the front model.
-- @param Bc (color) The back color.
-- @param Fc (color) The front color.
-- @param Tc (color) The target color.
-- @return (number) The front opacity (Fo).
local function getFrontOpacity( Bc, Fc, Tc )
    local Fo = nil

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

-- main algorithm
function Color.Resolve( Tc )
    local Bc = Color.New(0)
    local Fc = Color.New(0)
    local Fo = 0
    local Ic, Mc, Mo -- Intermediate color, modifier color, modifier opacity

    for comp, value in pairs( color:ToRGB() ) do
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

        Ic = Color.New( ( Fc:ToVector3() - Bc:ToVector3() ) * Fo + Bc:ToVector3() )
        
        if Ic ~= Tc then
            -- the Tc color can't be achieved with only two levels of color
            -- a thrid one is needed

        end
    end
    print("get colors", Bc, Fc, Fo)
    
    ----------

    print("Tc = ", Tc )
    return Bc, Fc, Fo, Mo, Fo
end

--- Set the color of the provided model renderer.
-- @param modelRenderer (ModelRenderer) The model renderer.
-- @param r (number, Color or string) The color's red component, a color object or a color as hexadecimal string.
-- @param g (number) [optional] The color's green component.
-- @param b (number) [optional] The color's blue component.
function ModelRenderer.SetColor( modelRenderer, r, g, b )
    local color = Color.New( r, g, b )
    local Bc, Fc, Fo, Mc, Mo = color:Resolve()
    
    local gameObject = modelRenderer.gameObject
    if gameObject.modelRenderers == nil then
        gameObject.modelRenderers = { modelRenderer }
    end 

    --
    local backRndr = modelRenderer
    backRndr:SetModel( Bc:GetModel() )

    --
    local frontRndr = gameObject.modelRenderers[2]
    if frontRndr == nil then
        frontRndr = modelRenderer.gameObject:CreateComponent("ModelRenderer")
        gameObject.modelRenderer = backRndr
        table.insert( gameObject.modelRenderers, frontRndr )
    end

    frontRndr:SetModel( ColorGenerator.Config.modelsByColor[ Fc ] )
    frontRndr:SetOpacity( Fo )

    --
    local modRndr = gameObject.modelRenderers[3] -- modifier (saturation/value) (white/black)
    if Mc ~= nil then
        if modRndr == nil then
            modRndr = modelRenderer.gameObject:CreateComponent("ModelRenderer")
            gameObject.modelRenderer = backRndr
            table.insert( gameObject.modelRenderers, frontRndr )
        end

        modRndr:SetModel( ColorGenerator.Config.modelsByColor[ Mc ] )
        modRndr:SetOpacity( Mo )
    elseif modRndr ~= nil then
        modRndr:SetOpacity(0)
    end
end


--[[
function Color.Resolve( color )
    local Bc = Color.New(0)
    local Fc = Color.New(0)
    local Fo = 1.0

    local Ic = Color.New( color ) -- intermediate color (result of the front and back colors)
        
    local Mc = Color.New(0) -- modifier color
    local Mo = 0 --  modifier opacity

    local Rc = Color.New( color ) -- Result color
    
    local RComp = nil -- remarquable component ("r", "g", or "b", not a game object's component)
    

    local function getOpacity(Bc, Fc, Rc) -- args are of type numbers
        return math.round( (Rc - Bc) / (Fc - Bc), 3 )
    end


    local function GetModifierInfo( Rc, RComp, Ic, Mc, Mo)
    
        local mean = ((Rc.r + Rc.g + Rc.b - Rc[RComp]) / 2)
        if Rc[RComp] == 255 then
            Mc = Color.white
        else
            Mc = Color.black
        end
            
        if 
            (Rc[RComp] == 255 and mean > 127.5)
            or
            (Rc[RComp] == 0 and mean < 127.5)            
        then
            
            
            -- calculate Ic
                -- calculate color that must be generated by the back and front models
                local lowestCompValue = 256
                for comp, value in pairs( Rc:ToRGB() ) do
                    if comp ~= RComp and lowestCompValue > value then
                        lowestCompValue = value
                    end
                end 
                -- can't use math.min( Rc.r, Rc.g, Rc.b ) because don't work when Rc[RComp] == 0
    
                -- calculate offset of the component's values from the mean
                local offsetFromMean = mean - lowestCompValue
    
                -- calculate offset of the component's values from the mean
                -- by unit of mean from 255 or 0
                local unitOffset = offsetFromMean / math.abs( Rc[RComp] - mean )
                -- denominator is 
                -- (255 - mean) when Rc[RComp] == 255
                -- (mean)       when Rc[RComp] == 0               
    
                -- calculate new offset at mean = 128
                local newOffset = unitOffset * 128
    
                -- calculate new component values at mean = 128
                local newHighestCompValue = 128 + newOffset
                local newLowestCompValue = 128 - newOffset
                
                -- adjust Ic with these new values
                for comp, value in pairs( Ic:ToRGB() ) do
                    if comp ~= RComp then
                        if value > mean then
                            Ic[comp] = newHighestCompValue
                        else
                            Ic[comp] = newLowestCompValue
                        end
                    end
                end
                  
            -- calculate the color saturation
            if Rc[RComp] == 255 then
                local RcSat = Rc:GetSaturation()
                local IcSat = Ic:GetSaturation()
                if RcSat > IcSat then
                    print("error, color system can't display this color", RcSat, IcSat)
                end
            else
                local RcValue = Rc:GetValue()
                local IcValue = Ic:GetValue()
                if RcValue > IcValue then
                    print("error, color system can't display this color", RcSat, IcSat)
                end
            end

            local _Bc = Ic.r
            local _Fc = Mc.r
            local _Rc = Rc.r
            if RComp == "r" then
                _Bc = Ic.g
                _Fc = Mc.g
                _Rc = Rc.g
            end
            print( "Mo", _Bc, _Fc, _Rc )
            Mo = getOpacity( _Bc, _Fc, _Rc )
        else
            print("error 2, color system can't display this color", mean, Rc)
        end
        
        print("modifier info:", Ic, Mc, Mo)
        return Ic, Mc, Mo
    end


    --
    if Ic:AreTwoComponentsEqual() then
        
        RComp = Rc:GetLoneComponent()
        Bc[RComp] = 255
        Fc[RComp] = 0

        -- need the modifier
        --Ic, Mc, Mo = GetModifierInfo( Rc, RComp, Ic, Mc, Mo )

        if RComp == "r" then
            Bc.g = 0
            Bc.b = 0
            -- Red

            Fc.g = 255
            Fc.b = 255
            -- Cyan

            Fo = getOpacity(0, 255, Ic.g)
        elseif RComp == "g" then
            Bc.r = 0
            Bc.b = 0
            -- Green

            Fc.r = 255
            Fc.b = 255
            -- Magenta

            Fo = getOpacity(0, 255, Ic.r)
        elseif RComp == "b" then
            Bc.r = 0
            Bc.g = 0
            -- Blue

            Fc.r = 255
            Fc.g = 255
            -- Yellow

            Fo = getOpacity(0, 255, Ic.r)
        end

    else

        RComp = Rc:GetFirstComponentEqualTo(0)
        if RComp ~= nil then
            Bc[RComp] = 0
            Fc[RComp] = 0
        else
            RComp = Rc:GetFirstComponentEqualTo(255)
            Bc[RComp] = 255
            Fc[RComp] = 255
        end


        -- need the modifier
        Ic, Mc, Mo = GetModifierInfo( Rc, RComp, Ic, Mc, Mo )
        
        if RComp == "r" then
            Bc.g = 255
            Bc.b = 0
            -- Yellow (255) or Green (0)

            Fc.g = 0
            Fc.b = 255
            -- Magenta or Blue

            Fo = getOpacity(255, 0, Ic.g)

        elseif RComp == "g" then
            Bc.r = 255
            Bc.b = 0
            -- Yellow or Red

            Fc.r = 0
            Fc.b = 255
            -- Cyan or Blue

            Fo = getOpacity(255, 0, Ic.r)

        elseif RComp == "b" then
            Bc.r = 255
            Bc.g = 0
            -- Magenta or Red

            Fc.r = 0
            Fc.g = 255
            -- Cyan or Green

            Fo = getOpacity(255, 0, Ic.r)
        end
    
    end 
    
    Bc = Bc:GetName()
    Fc = Fc:GetName()
    Mc = Mc:GetName()


    print(Bc, Fc, Fo, Mc, Mo)

    -- returns the names of the models to use, and the front opacity
    return Bc, Fc, Fo, Mc, Mo
end]]


----------------------------------------------------------------------------------
-- Extension of the Color object for the color solver

--- Return the name of first component (in the r,g,b order) that has the provided value.
-- @param color (Color) The color.
-- @param value (number) The value to search in the color's components.
-- @return (string) The component name or nil.
function Color.GetFirstComponentEqualTo(color, value) -- IsOneComponentEqualTo
    for i, component in ipairs({"r", "g", "b"}) do
        if value == color[ component ] then
            return component
        end
    end
    return nil
end

--- Tell whether at least two components have the same value.
-- @param color (Color) The color.
-- @return (boolean) True if at least two components have the same value, or false.
function Color.AreTwoComponentsEqual(color)
    if color.r == color.g or color.r == color.b or color.g == color.b then
        return true
    end
    return false
end

--- Return the name of the component that has not the same value as the two others (which are equal).
-- @param color (Color) The color.
-- @return (string) The component's name.
function Color.GetLoneComponent(color)
    if color.r == color.g then
        if color.r == color.b then
            return nil
        end
        return "b"
    elseif color.r == color.b then
        return "g"
    elseif color.g == color.b then
        return "r"
    end
    return nil
end

function Color.GetOtherComp( comp )
    if comp == "r" then
        return "g"
    end
    return "r"
end

function Color.GetLowestComponent(color)
    local value = 256
    local name = nil
    local comps = {"r", "g", "b"}
    local array = color:ToArray()
    for i=1, 3 do 
        local val = array[i]
        if val < value then
            name = comps[i]
            value = val
        end
    end
    return value, name
end

function Color.GetHighestComponent(color)
    local value = -1
    local name = nil
    local comps = {"r", "g", "b"}
    local array = color:ToArray()
    for i=1, 3 do 
        local val = array[i]
        if val > value then
            name = comps[i]
            value = val
        end
    end
    return value, name
end

function Color.ToVector3( color )
    return Vector3:New( color.r, color.g, color.b )
end
