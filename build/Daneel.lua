-- Generated on Tue Dec 02 2014 21:48:42 GMT+0100 (Paris, Madrid)
-- Lua.lua
-- Contains extensions of Lua's libraries.
-- All functions in this file are totally independant from Daneel or CraftStudio, they can be reused in any Lua application.
--
-- Last modified for v1.5.0
-- Copyright © 2013-2014 Florent POUJOL, published under the MIT license.


----------------------------------------------------------------------------------
-- math

--- Tell whether the provided number is an integer.
-- That include numbers that have one or several zeros as decimals (1.0, 2.000, ...).
-- @param number (number) The number to check.
-- @return (boolean) True if the provided number is an integer, false otherwise.
function math.isinteger(number)
    local isinteger = false
    if type(number) == "number" then
        isinteger = number == math.floor(number)
    end
    return isinteger
end

--- Returns the value resulting of the linear interpolation between value a and b by the specified factor.
-- @param a (number)
-- @param b (number)
-- @param factor (number) Should be between 0.0 and 1.0.
-- @param easing (string) [optional] The easing of the factor, can be "smooth", "smooth in", "smooth out".
-- @return (number) The interpolated value.
function math.lerp( a, b, factor, easing )
    if easing == "smooth" then
        factor = factor * 2
        if factor < 1 then
            factor = 0.5 * factor * factor * factor
        else
            factor = factor - 2
            factor = 0.5 * ( factor * factor * factor + 2 )
        end
    elseif easing == "smooth in" then
        factor = factor * factor * factor
    elseif easing == "smooth out" then
        factor = factor - 1
        factor = factor * factor * factor + 1
    end
    return a + (b - a) * factor
end

--- Wrap the provided angle between -180 and 180.
-- @param angle (number) The angle.
-- @return (number) The angle.
function math.warpangle( angle )   
    if angle > 180 then
        angle = angle - 360
    elseif angle < -180 then
        angle = angle + 360
    end
    return angle
end

--- Round the value to the closest integer or decimal.
-- @param value (number) The value to round.
-- @param decimal (number) [default=0] The decimal at which to round the value.
-- @return (number) The rounded value.
function math.round( value, decimal )
    if decimal ~= nil then
        value = math.floor( (value * 10^decimal) + 0.5) / (10^decimal)
    else
        value = math.floor( value + 0.5 )
    end
    return value
end

--- Trucate the value to the provided decimal.
-- @param value (number) The value to truncate.
-- @param decimal (number) [default=0] The decimal at which to truncate the value.
-- @return (number) The truncated value.
function math.truncate( value, decimal )
    if decimal ~= nil then
        value = math.floor( (value * 10^decimal) ) / (10^decimal)
    else
        value = math.floor( value )
    end
    return value
end

--- A more flexible version of tonumber().
-- Returns the first continuous series of numbers found in the text version of the provided data even if it is prefixed or suffied by other characters.
-- @param data (mixed) The data to be converted to number. Usually of type number, string or userdata.
-- @return (number) The number, or nil.
function tonumber2( data )
    local number = tonumber( data )
    if number == nil then
        data = tostring( data )
        local pattern = "(%d+)"
        if data:find( ".", 1, true ) then
            pattern = "(%d+%.%d+)"
        end
        number = data:match( (data:gsub( pattern, "(%1)" )) )
        number = tonumber( number )
    end
    return number
end

--- Return the value clamped between min and max.
-- @param value (number) The value.
-- @param min (number) The minimal value.
-- @param max (number) The maximal value.
-- @return (number) The new value.
function math.clamp( value, min, max )
    value = math.max( value, min )
    value = math.min( value, max )
    return value
end

----------------------------------------------------------------------------------
-- string

--- Turn a string into a table, one character per index.
-- @param s (string) The string.
-- @return (table) The table.
function string.totable( s )
    local t = {}
    for i = 1, #s do
        table.insert( t, s:sub( i, i ) )
    end
    return t
end

--- Turn the first letter of the string uppercase.
-- @param s (string) The string.
-- @return (string) The string.
function string.ucfirst( s )
    local r = s:gsub( "^%l", string.upper ) 
    return r
    -- Original code was : return ( s:gsub( "^%u", string.lower ) )
    -- It has been changed because Luamin removes the parenthesis which makes the function return all the values
    -- returned by gsub() instead of just the one the function must return
end

--- Turn the first letter of the string lowercase.
-- @param s (string) The string.
-- @return (string) The string.
function string.lcfirst( s )
    local r = s:gsub( "^%u", string.lower )
    return r
end

--- Split the provided string in several chunks, using the provided delimiter.
-- The delimiter can be a pattern and can be several characters long.
-- If the string does not contain the delimiter, a table containing only the whole string is returned.
-- @param s (string) The string.
-- @param delimiter (string) The delimiter.
-- @param delimiterIsPattern (boolean) [default=false] Interpret the delimiter as pattern instead of as plain text. The function's behavior is not garanteed if true and in the webplayer.
-- @return (table) The chunks.
function string.split( s, delimiter, delimiterIsPattern )
    local chunks = {}
    
    if delimiterIsPattern then
        local delimiterStartIndex, delimiterEndIndex = s:find( delimiter )

        if delimiterStartIndex ~= nil then
            local pattern = delimiter
            delimiter = s:sub( delimiterStartIndex, delimiterEndIndex )
            if string.startswith( s, delimiter ) then
                s = s:sub( #delimiter+1, #s )
            end
            if not s:endswith( delimiter ) then
                s = s .. delimiter
            end
            
            for match in s:gmatch( "(.-)"..pattern ) do 
                table.insert( chunks, match )
            end
        end
    
    else -- plain text delimiter
        if s:find( delimiter, 1, true ) ~= nil then
            if string.startswith( s, delimiter ) then
                s = s:sub( #delimiter+1, #s )
            end
            if not s:endswith( delimiter ) then
                s = s .. delimiter
            end

            local chunk = ""
            local ts = string.totable( s )
            local i = 1

            while i <= #ts do
                local char = ts[i]
                if char == delimiter or s:sub( i, i-1 + #delimiter ) == delimiter then
                    table.insert( chunks, chunk )
                    chunk = ""
                    i = i + #delimiter
                else
                    chunk = chunk..char
                    i = i + 1
                end
            end

            if #chunk > 0 then
                table.insert( chunks, chunk )
            end
        end
    end

    if #chunks == 0 then
        chunks = { s }
    end

    return chunks
end

--- Tell whether the provided string begins by the provided chunk or not.
-- @param s (string) The string.
-- @param chunk (string) The searched chunk.
-- @return (boolean) True or false.
function string.startswith( s, chunk )
    local r = s:sub( 1, #chunk ) == chunk
    return r
end

--- Tell whether the provided string ends by the provided chunk or not.
-- @param s (string) The string.
-- @param chunk (string) The searched chunk.
-- @return (boolean) True or false.
function string.endswith( s, chunk )
    local r = s:sub( #s - #chunk + 1, #s ) == chunk
    return r
end

--- Removes the white spaces at the beginning of the provided string.
-- @param s (string) The string.
-- @return (string) The trimmed string.
function string.trimstart( s )
    local r = s:gsub( "^%s+", "" )
    return r
end

--- Removes the white spaces at the end of the provided string.
-- @param s (string) The string.
-- @return (string) The trimmed string.
function string.trimend( s )
    local r = s:gsub( "%s+$", "" )
    return r
end

--- Removes the white spaces at the beginning and the end of the provided string.
-- @param s (string) The string.
-- @return (string) The trimmed string.
function string.trim(s)
    local r = s:gsub( "^%s+", "" ):gsub( "%s+$", "" )
    return r
end

--- Reverse the order of the characters in a string ("abcd" becomes "dcba").
-- @param s (string) The string.
-- @return (string) The reversed string.
function string.reverse( s )
    local ns = ""
    for i=#s, 1, -1 do
        ns = ns..s:sub(i,i)
    end
    return ns
end

--- Make sure that the case of the provided string is correct by checking it against the values in the provided set.
-- @param s (string) The string to check the case of.
-- @param set (string or table) A single value or a table of values to check the string against.
-- @return (string) The string with the corrected case.
function string.fixcase( s, set )
    if type( set ) == "string" then
        set = { set }
    end
    local ls = s:lower()
    for i=1, #set do
        local item = set[i]
        if ls == item:lower() then
            return item
        end
    end
    return s -- in case no match is found the set
end

----------------------------------------------------------------------------------
-- table

--- Return a copy of the provided table.
-- @param t (table) The table to copy.
-- @param recursive (boolean) [default=false] Tell whether to also copy the tables found as value (true), or just leave the same table as value (false).
-- @return (table) The copied table.
function table.copy( t, recursive )
    local newTable = {}
    if table.isarray( t ) then
        -- not sure if it's really necessary to use ipairs() instead of pairs() for arrays
        -- but better be safe than sorry
        for key, value in ipairs( t ) do
            if type( value ) == "table" and recursive then
                value = table.copy( value, recursive )
            end
            table.insert( newTable, value )
        end
    else
        for key, value in pairs( t ) do
            if type( value ) == "table" and recursive then
                value = table.copy( value, recursive )
            end
            newTable[ key ] = value
        end
    end
    return newTable
end

--- Tell whether the provided value is found within the provided table.
-- @param t (table) The table to search in.
-- @param value (mixed) The value to search for.
-- @param ignoreCase (boolean) [default=false] Ignore the case of the value. If true, the value must be of type 'string'.
-- @return (boolean) True if the value is found in the table, false otherwise.
function table.containsvalue( t, value, ignoreCase )
    if value == nil then
        return false
    end
    if ignoreCase and type( value ) == 'string' then
        value = value:lower()
    end
    for key, _value in pairs(t) do
        if ignoreCase and type( _value ) == "string" then
            _value = _value:lower()
        end
        if value == _value then
            return true
        end
    end
    return false
end

--- Returns the length of a table, which is the numbers of keys of the provided type (or of any type), for which the value is not nil.
-- @param t (table) The table.
-- @param keyType (string) [optional] Any Lua or CraftStudio type ('string', 'GameObject', ...), case insensitive.
-- @return (number) The table length.
function table.getlength( t, keyType )   
    local length = 0
    if keyType ~= nil then
        keyType = keyType:lower()
    end
    for key, value in pairs( t ) do
        if 
            keyType == nil or
            type( key ) == keyType
        then
            length = length + 1
        end
    end
    return length
end

--- Print all key/value pairs within the provided table.
-- @param t (table) The table to print.
function table.print(t)
    if t == nil then
        print("table.print( t ) : Provided table is nil.")
        return
    end

    print("~~~~~ table.print("..tostring(t)..") ~~~~~ Start ~~~~~")

    local func = pairs
    if table.getlength(t) == 0 then
        print("Table is empty.")
    elseif table.isarray(t) then
        func = ipairs -- just to be sure that the entries are printed in order
    end
    
    for key, value in func(t) do
        if type(key) == "string" then
            key = '"'..key..'"'
        end
        if type(value) == "string" then
            value = '"'..value..'"'
        end
        print(key, value)
    end

    print("~~~~~ table.print("..tostring(t)..") ~~~~~ End ~~~~~")
end

local knownKeysByPrintedTable = {} -- [ table ] = key
local currentlyPrintedTable = nil

--- Recursively print all key/value pairs within the provided table.
-- Fully prints the tables that have no metatable found as values.
-- @param t (table) The table to print.
-- @param level (string) [default=""] The string to prepend to the printed lines. Should be empty or nil unless called from table.printr().
function table.printr( t, level )
    level = level or ""

    if t == nil then
        print(level.."table.printr( t ) : Provided table is nil.")
        return
    end

    if level == "" then
        print("~~~~~ table.printr("..tostring(t)..") ~~~~~ Start ~~~~~")       
        if currentlyPrintedTable == nil then
          currentlyPrintedTable = t
        end
    end   

    local func = pairs
    if table.getlength(t) == 0 then
        print(level, "Table is empty.")
    elseif table.isarray(t) then
        func = ipairs -- just to be sure that the entries are printed in order
    end
    
    for key, value in func(t) do
        if type(key) == "string" then
            key = '"'..key..'"'
        end
        if type(value) == "string" then
            value = '"'..value..'"'
        end

        if type( value ) == "table" and getmetatable( value ) == nil then
            local knownKey = knownKeysByPrintedTable[ value ]
            if value == currentlyPrintedTable then
                print(level..tostring(key), "Table currently being printed: "..tostring(value) )
            elseif knownKey ~= nil then
                print(level..tostring(key), "Already printed table with key "..knownKey..": "..tostring(value) )
            else
                knownKeysByPrintedTable[ value ] = key
                print(level..tostring(key), value)
                table.printr( value, level.."| - - - ")
            end
        else
            print(level..tostring(key), value)
        end
    end

    if level == "" then
        print("~~~~~ table.printr("..tostring(t)..") ~~~~~ End ~~~~~")
        knownKeysByPrintedTable = {}
        currentlyPrintedTable = nil
    end
end

--- Merge two or more tables into one new table.
-- Table as values with a metatable are considered as instances and are not recursively merged.
-- When the tables are arrays, the integer keys are not overridden.
-- @param ... (table) Two or more tables
-- @param recursive (boolean) [default=false] Tell whether tables as values must be merged recursively. Has no effect when the tables are arrays.
-- @return (table) The new table.
function table.merge( ... )
    return table.mergein( {}, ... )
end

--- Merge two or more tables in place, into the first provided table.
-- Table as values with a metatable are considered as instances and are not recursively merged.
-- When the tables are arrays, the integer keys are not overridden.
-- @param ... (table) Two or more tables
-- @param recursive (boolean) [default=false] Tell whether tables as values must be merged recursively. Has no effect when the tables are arrays.
-- @return (table) The first provided table.
function table.mergein( ... )
    local arg = {...}
    local recursive = false
    if #arg > 0 and type( arg[ #arg ] ) ~= "table" then
        recursive = table.remove( arg )
    end
    
    local fullTable = table.remove( arg, 1 )
    if fullTable == nil then
        local msg = "table.mergein(): No table where passed as argument."
        if #arg > 0 then
            table.print( arg )
            msg = "table.mergein(): First argument is nil. Other arguments are shown above."
        end
        error( msg )
    end
    for i, t in ipairs( arg ) do
        local argType = type( t )
        if argType == "table" then
            
            if table.isarray( t ) then
                for key, value in ipairs( t ) do
                    table.insert( fullTable, value )
                end

            else
                for key, value in pairs( t ) do
                    if fullTable[ key ] ~= nil and recursive and type( value ) == "table" and getmetatable( value ) == nil then
                        value = table.merge( fullTable[ key ], value, true )
                    end
                    fullTable[ key ] = value
                end
            end
        end
    end
    return fullTable
end

--- Compare table1 and table2. Returns true if they have the exact same keys which have the exact same values.
-- @param table1 (table) The first table to compare.
-- @param table2 (table) The second table to compare to the first table.
-- @return (boolean) True if the two tables have the exact same content.
function table.havesamecontent( table1, table2 )
    if table.getlength(table1) ~= table.getlength(table2) then
        return false
    end
    for key, value in pairs( table1 ) do
        if table1[ key ] ~= table2[ key ] then
            return false
        end
    end
    return true
end

--- Create an associative table with the provided keys and values tables.
-- @param keys (table) The keys of the future table.
-- @param values (table) The values of the future table.
-- @return (table or boolean) The combined table or false if the tables have different length.
function table.combine( keys, values )
    if #keys ~= #values then
        print( "table.combine( keys, values ) : WARNING : Arguments 'keys' and 'values' have different length :", #keys, #values )
    end
    local newTable = {}
    for i, key in pairs( keys ) do
        newTable[ key ] = values[ i ]
    end
    return newTable
end

--- Remove the provided value from the provided table.
-- If the index of the value is an integer, the value is nicely removed with table.remove().
-- /!\ Do not use this function on tables which have integer keys but that are not arrays (whose keys are not contiguous). /!\
-- @param t (table) The table.
-- @param value (mixed) The value to remove.
-- @param maxRemoveCount (number) [optional] Maximum number of occurrences of the value to be removed. If nil : remove all occurrences.
-- @return (number) The number of occurrence removed.
function table.removevalue( t, value, maxRemoveCount )
    if value == nil then
        return 0
    end
    local removeCount = 0
    for key, _value in pairs( t ) do
        if _value == value then
            if math.isinteger( key ) then
                table.remove( t, key )
            else
                t[ key ] = nil
            end
            removeCount = removeCount + 1
            if maxRemoveCount ~= nil and removeCount == maxRemoveCount then
                break
            end
        end
    end
    return removeCount
end

--- Return all the keys of the provided table.
-- @param t (table) The table.
-- @return (table) The keys.
function table.getkeys( t )
    local keys = {}
    for key, value in pairs( t ) do
        table.insert( keys, key )
    end
    return keys
end

--- Return all the values of the provided table.
-- @param t (table) The table.
-- @return (table) The values.
function table.getvalues( t )
    local values = {}
    for key, value in pairs( t ) do
        table.insert( values, value )
    end
    return values
end

--- Get the key associated with the first occurrence of the provided value.
-- @param t (table) The table.
-- @param value (mixed) The value.
-- @return (mixed) The value's key or nil if the value is not found.
function table.getkey( t, value )
    local key = nil
    for k, v in pairs( t ) do
        if value == v then
            key = k
        end
    end
    return key
end

--- Sort a list of table using one of the tables property as criteria.
-- @param t (table) The table.
-- @param property (string) The property used as criteria to sort the table.
-- @param orderBy (string) [default="asc"] How the sort should be made. Can be "asc" or "desc". Asc means small values first.
-- @return (table) The ordered table.
function table.sortby( t, property, orderBy )
    if orderBy == nil or not (orderBy == "asc" or orderBy == "desc") then
        orderBy = "asc"
    end
    
    local propertyValues = {}
    local itemsByPropertyValue = {}
    for i=1, #t do
        local propertyValue = t[i][property]
        if itemsByPropertyValue[propertyValue] == nil then
            table.insert(propertyValues, propertyValue)    
            itemsByPropertyValue[propertyValue] = {}
        end
        table.insert(itemsByPropertyValue[propertyValue], t[i])
    end
    
    if orderBy == "desc" then
        table.sort(propertyValues, function(a,b) return a>b end)
    else
        table.sort(propertyValues)
    end
    
    t = {}
    for i=1, #propertyValues do
        for j, _table in pairs(itemsByPropertyValue[propertyValues[i]]) do
            table.insert(t, _table)
        end
    end
    return t
end

--- Safely search several levels down inside nested tables. Just returns nil if the series of keys does not leads to a value. <br>
-- Can also be used to check if a global variable exists if the table is _G. <br>
-- Ie for this series of nested table : table1.table2.table3.fooBar <br>
-- table.getvalue( table1, "table2.table3.fooBar" ) would return the value of the 'fooBar' key in the 'table3' table <br>
-- table.getvalue( table1, "table2.table3" ) would return the value of 'table3' <br>
-- table.getvalue( table1, "table2.table3.Foo" ) would return nil because the 'table3' has no 'Foo' key <br>
-- table.getvalue( table1, "table2.Foo.Bar.Lorem.Ipsum" ) idem <br>
-- @param t (table) The table.
-- @param keys (string) The chain of keys to looks for as a string, each keys separated by a dot.
-- @return (mixed) The value, or nil.
function table.getvalue( t, keys )
    keys = string.split( keys, "." )
    local value = t
    
    if value == _G then
        -- prevent a "variable x was not declared" error
        local exists = false
        for key, value in pairs( _G ) do
            if key == keys[1] then
                exists = true
                break
            end
        end
        
        if not exists then
            return nil
        end
    end

    for i, key in ipairs( keys ) do
        if value[ key ] == nil then
            value = nil 
            break
        else
            value = value[ key ]
        end
    end
    return value
end

--- Safely set a value several levels down inside nested tables. Creates the missing levels if the series of keys is incomplete. <br>
-- Ie for this series of nested table : table1.table2.fooBar <br>
-- table.setvalue( table1, "table2.fooBar", true ) would set true as the value of the 'fooBar' key in the 'table1.table2' table. if table2 does not exists, it is created <br>
-- @param t (table) The table.
-- @param keys (string) The chain of keys to looks for as a string, each keys separated by a dot.
-- @param value (mixed) The value (nil is ok).
function table.setvalue( t, keys, value )
    if keys:find( ".", 1, true ) == nil then
        t[ keys ] = value
    
    else
        keys = string.split( keys, "." )
        
        for i, key in ipairs( keys ) do
            if i == #keys then
                t[ key ] = value
            else
                local temp = t[ key ]
                if temp == nil then
                    temp = {}
                    t[ key ] = temp
                end
                t = temp
            end
        end
    end
end

--- Tell whether he provided table is an array (has only integer keys).
-- Decimal numbers with only zeros after the coma are considered as integers.
-- @param t (table) The table.
-- @param strict (boolean) [default=true] When false, the function returns true when the table only has integer keys. When true, the function returns true when the table only has integer keys in a single and continuous set.
-- @return (boolean) True or false.
function table.isarray( t, strict )
    local entriesCount = 0
    for k, v in pairs( t ) do
        entriesCount = entriesCount + 1
        if type( k ) ~= "number" or not math.isinteger( k ) then
            return false
        end
    end
    if strict == nil or strict then
        return (entriesCount == #t)
    end  
    return true
end

--- Reverse the order of the provided table's values.
-- @param t (table) The table.
-- @return (table) The new table.
function table.reverse( t )
    local newTable = {}
    for i=1, #t do
        table.insert( newTable, 1, t[i] )
    end
    return newTable
end

--- Remove and returns the first value found in the table.
-- Works for arrays as well as associative tables.
-- @param t (table) The table.
-- @param returnKey (boolean) [default=false] If true, return the key and the value instead of just the value.
-- @return (mixed) The value, or the key and the value (if the returnKey argument is true), or nil.
function table.shift( t, returnKey )
    local key = nil
    local value = nil
    if table.isarray( t ) then
        if #t > 0 then
            key = 1
            value = table.remove( t, 1 )
        end
    else
        for k,v in pairs( t ) do
            key = k
            value = v
            break
        end
        if key ~= nil then
            t[ key ] = nil  
        end
    end
    if returnKey == true then
        return key, value
    else
        return value
    end
end

--- Turn the provided table (with only integer keys) in a proper sequence (with consecutive integer key beginning at 1).
-- @param t (table) The table.
-- @return (table) The sequence.
function table.reindex( t )
    if not table.isarray( t, false ) then
        print( "table.reindex( table ) : Provided table '"..tostring( t ).."' is not an array." )
    end
    local maxi = 1
    for i, v in pairs( t ) do
        if type( i ) == "number" and i > maxi then
            maxi = i
        end
    end
    local newTable = {}
    for i=1, maxi do
        if t[i] ~= nil then
            table.insert( newTable, t[i] )
        end
    end
    return newTable
end

--- Insert the provided value at the end of the provided table (or at the provided index) but only if the value is not already found in the table.
-- @param t (table) The table.
-- @param index (number) [optional] The index at which to insert the value.
-- @param value (mixed) The value to insert.
-- @return (boolean) Whether the value has been inserted (true) or not (false).
function table.insertonce( t, index, value )
    if value == nil then
        value = index
        index = nil
    end
    for key, _value in pairs(t) do
        if value == _value then
            return false
        end
    end
    if index == nil then
        table.insert( t, value )
    else
        table.insert( t, index, value )
    end
    return true
end

-- Daneel.lua
-- Contains Daneel's core functionalities.
--
-- Last modified for v1.5.0
-- Copyright © 2013-2014 Florent POUJOL, published under the MIT license.

Daneel = {}

Daneel.modules = { moduleNames = {} }
setmetatable( Daneel.modules, {
    __newindex = function( _, moduleName, moduleObject ) -- "_" argument is Daneel.modules object
        table.insert( Daneel.modules.moduleNames, moduleName )
        rawset( Daneel.modules, moduleName, moduleObject )
    end
} )


----------------------------------------------------------------------------------
-- Some Lua functions are overridden here with some Daneel-specific stuffs

function string.split( s, delimiter, delimiterIsPattern )
    local chunks = {}

    if delimiterIsPattern then
        local delimiterStartIndex, delimiterEndIndex = s:find( delimiter )

        if delimiterStartIndex ~= nil then
            local pattern = delimiter
            delimiter = s:sub( delimiterStartIndex, delimiterEndIndex )
            if string.startswith( s, delimiter ) then
                s = s:sub( #delimiter+1, #s )
            end
            if not s:endswith( delimiter ) then
                s = s .. delimiter
            end

            if CS.IsWebPlayer then
                -- CS Webplayer specific part :
                -- in the webplayer,  "(.-)"..delimiter  is translated into  "(.*)"..delimiter  which seems to create an infinite loop
                -- "(.+)"..delimiter   does not work either in the webplayer
                for match in s:gmatch( "([^"..pattern.."]+)"..pattern ) do
                    table.insert( chunks, match )
                end
            else
                for match in s:gmatch( "(.-)"..pattern ) do
                    table.insert( chunks, match )
                end
            end
        end

    else -- plain text delimiter
        if s:find( delimiter, 1, true ) ~= nil then
            if string.startswith( s, delimiter ) then
                s = s:sub( #delimiter+1, #s )
            end
            if not s:endswith( delimiter ) then
                s = s .. delimiter
            end

            local chunk = ""
            local ts = string.totable( s )
            local i = 1

            while i <= #ts do
                local char = ts[i]
                if char == delimiter or s:sub( i, i-1 + #delimiter ) == delimiter then
                    table.insert( chunks, chunk )
                    chunk = ""
                    i = i + #delimiter
                else
                    chunk = chunk..char
                    i = i + 1
                end
            end

            if #chunk > 0 then
                table.insert( chunks, chunk )
            end
        end
    end

    if #chunks == 0 then
        chunks = { s }
    end

    return chunks
end

function table.print(t)
    if t == nil then
        print("table.print( t ) : Provided table is nil.")
        return
    end

    local tableString = tostring(t)
    local rawTableString = Daneel.Debug.ToRawString(t)
    if tableString ~= rawTableString then
        tableString = tableString.." / "..rawTableString
    end
    print("~~~~~ table.print("..tableString..") ~~~~~ Start ~~~~~")

    local func = pairs
    if table.getlength(t) == 0 then
        print("Table is empty.")
    elseif table.isarray( t ) then
        func = ipairs -- just to be sure that the entries are printed in order
    end

    for key, value in func(t) do
        print(key, value)
    end

    print("~~~~~ table.print("..tableString..") ~~~~~ End ~~~~~")
end

function table.getlength( t, keyType )
    local length = 0
    if keyType ~= nil then
        keyType = keyType:lower()
    end
    for key, value in pairs( t ) do
        if
            keyType == nil or
            type( key ) == keyType or
            Daneel.Debug.GetType( key ):lower() == keyType
        then
            length = length + 1
        end
    end
    return length
end

----------------------------------------------------------------------------------
-- Utilities

Daneel.Utilities = {}

-- Deprecated since v1.5.0
Daneel.Utilities.CaseProof = string.fixcase

--- Replace placeholders in the provided string with their corresponding provided replacements.
-- The placeholders are any piece of string prefixed by a semicolon.
-- @param string (string) The string.
-- @param replacements (table) The placeholders and their replacements ( { placeholder = "replacement", ... } ).
-- @return (string) The string.
function Daneel.Utilities.ReplaceInString( string, replacements )
    for placeholder, replacement in pairs( replacements ) do
        string = string:gsub( ":"..placeholder, replacement )
    end
    return string
end

--- Allow to call getters and setters as if they were variable on the instance of the provided object.
-- The instances are tables that have the provided object as metatable.
-- Optionally allow to search in a ancestry of objects.
-- @param Object (mixed) The object.
-- @param ancestors (table) [optional] A table with one or several objects the Object "inherits" from.
function Daneel.Utilities.AllowDynamicGettersAndSetters( Object, ancestors )
    function Object.__index( instance, key )
        local ucKey = key
        if type( key ) == "string" then
            ucKey = string.ucfirst( key )
        end

        if key == ucKey then
            -- first letter was already uppercase or key is not if type string
            if Object[ key ] ~= nil then
                return Object[ key ]
            end

            if ancestors ~= nil then
                for i, Ancestor in ipairs( ancestors ) do
                    if Ancestor[ key ] ~= nil then
                        return Ancestor[ key ]
                    end
                end
            end

        else
            -- first letter lowercase, search for the corresponding getter
            local funcName = "Get"..ucKey

            if Object[ funcName ] ~= nil then
                return Object[ funcName ]( instance )
            elseif Object[ key ] ~= nil then
                return Object[ key ]
            end

            if ancestors ~= nil then
                for i, Ancestor in ipairs( ancestors ) do
                    if Ancestor[ funcName ] ~= nil then
                        return Ancestor[ funcName ]( instance )
                    elseif Ancestor[ key ] ~= nil then
                        return Ancestor[ key ]
                    end
                end
            end
        end

        return nil
    end

    function Object.__newindex( instance, key, value )
        local ucKey = key
        if type( key ) == "string" then
            ucKey = string.ucfirst( key )
        end

        if key ~= ucKey then -- first letter lowercase
            local funcName = "Set"..ucKey
            if Object[ funcName ] ~= nil then
                return Object[ funcName ]( instance, value )
            end
        end
        -- first letter was already uppercase or key not of type string
        return rawset( instance, key, value )
    end
end

-- Deprecated since v1.5.0
Daneel.Utilities.ToNumber = tonumber2

local buttonExists = {} -- Button names are keys, existence (false or true) is value

--- Tell whether the provided button name exists amongst the Game Controls, or not.
-- If the button name does not exists, it will print an error in the Runtime Report but it won't kill the script that called the function.
-- CS.Input.ButtonExists is an alias of Daneel.Utilities.ButtonExists.
-- @param buttonName (string) The button name.
-- @return (boolean) True if the button name exists, false otherwise.
function Daneel.Utilities.ButtonExists( buttonName )
    if buttonExists[ buttonName ] == nil then
        buttonExists[ buttonName ] = Daneel.Debug.Try( function()
            CS.Input.WasButtonJustPressed( buttonName )
        end )
    end
    return buttonExists[ buttonName ]
end

Daneel.Utilities.id = 0

--- Returns an integer greater than 0 and incremented by 1 from the last time the function was called.
-- If an object is provided, returns the object's id (if no id is found, it is set).
-- @param object (table) [optional] An object.
-- @return (number) The id.
function Daneel.Utilities.GetId( object )
    if object ~= nil and type( object ) == "table" then
        local id = rawget( object, "id" )
        if id ~= nil then
            return id
        end
        id = Daneel.Utilities.GetId()
        if object.inner ~= nil and not CS.IsWebPlayer then -- in the webplayer, tostring(object.inner) will just be table, so id will be nil
            -- object.inner :
            -- "CraftStudioRuntime.InGame.GameObject: 4620049" (of type userdata)
            -- "CraftStudioCommon.ProjectData.[AssetType]: [some ID]"
            id = tonumber( tostring( object.inner ):match( "%d+" ) )
        end
        if id == nil then
            id = "[no id]"
        end
        rawset( object, "id", id )
        return id
    else
        Daneel.Utilities.id = Daneel.Utilities.id + 1
        return Daneel.Utilities.id
    end
end

-- for backward compatibility, Cache object is deprecated since v1.5.0
Daneel.Cache = {
    GetId = Daneel.Utilities.GetId
}

----------------------------------------------------------------------------------
-- Debug

Daneel.Debug = {}

-- error reporting info
local s = "string"
local b = "boolean"
local n = "number"
local t = "table"
local f = "function"
local u = "userdata"
local _s = { "s", s }
local _t = { "t", t }

Daneel.Debug.functionArgumentsInfo = {
    ["math.isinteger"] = { { "number" } },
    ["math.lerp"] = {
        { "a", n },
        { "b", n },
        { "factor", n },
        { "easing", s, isOptional = true }
    },
    ["math.warpangle"] = { { "angle", n } },
    ["math.round"] = { { "value", n }, { "decimal", n, isOptional = true } },
    ["math.truncate"] = { { "value", n }, { "decimal", n, isOptional = true } },
    ["tonumber2"] = { { "data" } },
    ["math.clamp"] = { { "value", n }, { "min", n }, { "max", n } },

    ["string.totable"] = { _s },
    ["string.ucfirst"] = { _s },
    ["string.lcfirst"] = { _s },
    ["string.trimstart"] = { _s },
    ["string.trimend"] = { _s },
    ["string.trim"] = { _s },
    ["string.endswith"] = { _s, { "chunk", s } },
    ["string.startswith"] = { _s, { "chunk", s } },
    ["string.split"] = { _s,
        { "delimiter", s },
        { "delimiterIsPattern", b, defaultValue = false },
    },
    ["string.reverse"] = { _s },
    ["string.fixcase"] = { _s, { "set", { s, t } } },

    ["table.print"] = {}, -- just for the stacktrace
    ["table.merge"] = {},
    ["table.mergein"] = {},
    ["table.getkeys"] = { _t },
    ["table.getvalues"] = { _t },
    ["table.reverse"] = { _t },
    ["table.reindex"] = { _t },
    ["table.getvalue"] = { _t, { "keys", s } },
    ["table.setvalue"] = { _t, { "keys", s } },
    ["table.getkey"] = { _t, { "value" } },
    ["table.copy"] = { _t, { "recursive", b, defaultValue = false } },
    ["table.containsvalue"] = { _t, { "value" }, { "ignoreCase", b, defaultValue = false } },
    ["table.isarray"] = { _t, { "strict", b, defaultValue = true } },
    ["table.shift"] = { _t, { "returnKey", b, defaultValue = false } },
    ["table.getlength"] = { _t, { "keyType", s, isOptional = true } },
    ["table.havesamecontent"] = { { "table1", t }, { "table2", t } },
    ["table.combine"] = { _t,
        { "values", "table" },
        { "returnFalseIfNotSameLength", b, isOptional = true }
    },
    ["table.removevalue"] = { _t,
        { "value" },
        { "maxRemoveCount", n, isOptional = true }
    },
    ["table.sortby"] = { _t,
        { "property", s },
        { "orderBy", s, isOptional = true },
    },

    ["Daneel.Utilities.ReplaceInString"] = { { "string", s }, { "replacements", t } },
    ["Daneel.Utilities.ButtonExists"] = { { "buttonName", s } }
}

--- Check the provided argument's type against the provided type(s) and display error if they don't match.
-- @param argument (mixed) The argument to check.
-- @param argumentName (string) The argument name.
-- @param expectedArgumentTypes (string or table) The expected argument type(s).
-- @param p_errorHead [optional] (string) The beginning of the error message.
-- @return (mixed) The argument's type.
function Daneel.Debug.CheckArgType( argument, argumentName, expectedArgumentTypes, p_errorHead )
    if type( argument ) == "table" and getmetatable( argument ) == GameObject and argument.inner == nil then
        error( p_errorHead .. "Provided argument '" .. argumentName .. "' is a destroyed game object '" .. tostring(argument) )
        -- should do that for destroyed components too
    end

    if not Daneel.Config.debug.enableDebug then
        return Daneel.Debug.GetType( argument )
    end
    local errorHead = "Daneel.Debug.CheckArgType(argument, argumentName, expectedArgumentTypes[, p_errorHead]) : "

    local argType = type(argumentName)
    if argType ~= "string" then
        error(errorHead.."Argument 'argumentName' is of type '"..argType.."' with value '"..tostring(argumentName).."' instead of 'string'.")
    end

    argType = type(expectedArgumentTypes)
    if argType ~= "string" and argType ~= "table" then
        error(errorHead.."Argument 'expectedArgumentTypes' is of type '"..argType.."' with value '"..tostring(expectedArgumentTypes).."' instead of 'string' or 'table'.")
    end
    if argType == "string" then
        expectedArgumentTypes = {expectedArgumentTypes}
    elseif #expectedArgumentTypes <= 0 then
        error(errorHead.."Argument 'expectedArgumentTypes' is an empty table.")
    end

    argType = type(p_errorHead)
    if argType ~= "nil" and argType ~= "string" then
        error(errorHead.."Argument 'p_errorHead' is of type '"..argType.."' with value '"..tostring(p_errorHead).."' instead of 'string'.")
    end
    if p_errorHead == nil then p_errorHead = "" end

    argType = Daneel.Debug.GetType(argument)
    local luaArgType = type(argument) -- any object (that are tables) will now pass the test even when Daneel.Debug.GetType(argument) does not return "table"
    for i, expectedType in ipairs(expectedArgumentTypes) do
        if argType == expectedType or luaArgType == expectedType then
            return expectedType
        end
    end
    error(p_errorHead.."Argument '"..argumentName.."' is of type '"..argType.."' with value '"..tostring(argument).."' instead of '"..table.concat(expectedArgumentTypes, "', '").."'.")
end

--- If the provided argument is not nil, check the provided argument's type against the provided type(s) and display error if they don't match.
-- @param argument (mixed) The argument to check.
-- @param argumentName (string) The argument name.
-- @param expectedArgumentTypes (string or table) The expected argument type(s).
-- @param p_errorHead [optional] (string) The beginning of the error message.
-- @param defaultValue [optional] (mixed) The default value to return if 'argument' is nil.
-- @return (mixed) The value of 'argument' if it's non-nil, or the value of 'defaultValue'.
function Daneel.Debug.CheckOptionalArgType(argument, argumentName, expectedArgumentTypes, p_errorHead, defaultValue)
    if argument == nil then return defaultValue end
    if not Daneel.Config.debug.enableDebug then return argument end
    local errorHead = "Daneel.Debug.CheckOptionalArgType(argument, argumentName, expectedArgumentTypes[, p_errorHead, defaultValue]) : "

    local argType = type(argumentName)
    if argType ~= "string" then
        error(errorHead.."Argument 'argumentName' is of type '"..argType.."' with value '"..tostring(argumentName).."' instead of 'string'.")
    end

    argType = type(expectedArgumentTypes)
    if argType ~= "string" and argType ~= "table" then
        error(errorHead.."Argument 'expectedArgumentTypes' is of type '"..argType.."' with value '"..tostring(expectedArgumentTypes).."' instead of 'string' or 'table'.")
    end
    if argType == "string" then
        expectedArgumentTypes = {expectedArgumentTypes}
    elseif #expectedArgumentTypes <= 0 then
        error(errorHead.."Argument 'expectedArgumentTypes' is an empty table.")
    end

    argType = type(p_errorHead)
    if argType ~= "nil" and argType ~= "string" then
        error(errorHead.."Argument 'p_errorHead' is of type '"..argType.."' with value '"..tostring(p_errorHead).."' instead of 'string'.")
    end
    if p_errorHead == nil then errorHead = "" end

    argType = Daneel.Debug.GetType(argument)
    local luaArgType = type(argument)
    for i, expectedType in ipairs(expectedArgumentTypes) do
        if argType == expectedType or luaArgType == expectedType then
            return argument
        end
    end
    error(p_errorHead.."Optional argument '"..argumentName.."' is of type '"..argType.."' with value '"..tostring(argument).."' instead of '"..table.concat(expectedArgumentTypes, "', '").."'.")
end

-- For instances of objects, the type is the name of the metatable of the provided object, if the metatable is a first-level global variable.
-- Will return "ScriptedBehavior" when the provided object is a scripted behavior instance (yet ScriptedBehavior is not its metatable).
-- @param object (mixed) The argument to get the type of.
-- @param luaTypeOnly (boolean) [optional default=false] Tell whether to return only Lua's built-in types (string, number, boolean, table, function, userdata or thread).
-- @return (string) The type.
function Daneel.Debug.GetType( object, luaTypeOnly )
    local errorHead = "Daneel.Debug.GetType( object[, luaTypeOnly] ) : "
    -- DO NOT use CheckArgType here since it uses itself GetType() => overflow
    local argType = type( luaTypeOnly )
    if argType ~= "nil" and argType ~= "boolean" then
        error(errorHead.."Argument 'luaTypeOnly' is of type '"..argType.."' with value '"..tostring(luaTypeOnly).."' instead of 'boolean'.")
    end
    if luaTypeOnly == nil then luaTypeOnly = false end

    argType = type( object )
    if not luaTypeOnly and argType == "table" then
        -- the type is defined by the object's metatable
        local mt = getmetatable( object )
        if mt ~= nil then
            -- the metatable of the scripted behaviors is the corresponding script asset ('Behavior' in the script)
            -- the metatable of all script assets is the Script object
            if getmetatable( mt ) == Script then
                return "ScriptedBehavior"
            end

            if Daneel.Config.objectsByType ~= nil then
                for type, object in pairs( Daneel.Config.objectsByType ) do
                    if mt == object then
                        return type
                    end
                end
            end

            for type, object in pairs( _G ) do
                if mt == object then
                    return type
                end
            end
        end
    end
    return argType
end

oerror = error

-- prevent to set the new version of error() when DEBUG is false or before the StackTrace is enabled when DEBUG is true.
function Daneel.Debug.SetNewError()
    --- Print the stackTrace unless told otherwise then the provided error in the console.
    -- Only exists when debug is enabled. When debug in disabled the built-in 'error(message)'' function exists instead.
    -- @param message (string) The error message.
    -- @param doNotPrintStacktrace [optional default=false] (boolean) Set to true to prevent the stacktrace to be printed before the error message.
    function error(message, doNotPrintStacktrace)
        if Daneel.Config.debug.enableDebug and doNotPrintStacktrace ~= true then
            Daneel.Debug.StackTrace.Print()
        end
        oerror(message)
    end
end

--- Disable the debug from this point onward.
-- @param info [optional] (string) Some info about why or where you disabled the debug. Will be printed in the Runtime Report.
function Daneel.Debug.Disable(info)
    if info ~= nil then
        info = " : "..tostring(info)
    end
    print("Daneel.Debug.Disable()"..info)
    error = oerror
    Daneel.Config.debug.enableDebug = false
end

--- Bypass the __tostring() function that may exists on the data's metatable.
-- @param data (mixed) The data to be converted to string.
-- @return (string) The string.
function Daneel.Debug.ToRawString( data )
    -- 18/10/2013 removed the stacktrace as it caused a stack overflow when printing out destroyed game objects
    if data == nil and Daneel.Config.debug.enableDebug then
        print( "WARNING : Daneel.Debug.ToRawString( data ) : Argument 'data' is nil.")
        return nil
    end

    local text = nil
    local mt = getmetatable( data )
    if mt ~= nil then
        if mt.__tostring ~= nil then
            local mttostring = mt.__tostring
            mt.__tostring = nil
            text = tostring( data )
            mt.__tostring = mttostring
        end
    end
    if text == nil then
        text = tostring( data )
    end
    return text
end

--- Returns the name as a string of the global variable (including nested tables) whose value is provided.
-- This only works if the value of the variable is a table or a function.
-- When the variable is nested in one or several tables (like GUI.Hud), it must have been set in the 'objects' table in the config.
-- @param value (table or function) Any global variable, any object from CraftStudio or Daneel or objects whose name is set in 'userObjects' in the Daneel.Config.
-- @return (string) The name, or nil.
function Daneel.Debug.GetNameFromValue(value)
    Daneel.Debug.StackTrace.BeginFunction("Daneel.Debug.GetNameFromValue", value)
    local errorHead = "Daneel.Debug.GetNameFromValue(value) : "
    if value == nil then
        error(errorHead.." Argument 'value' is nil.")
    end
    local result = table.getkey(Daneel.Config.objectsByType, value)
    if result == nil then
        result = table.getkey(_G, value)
    end
    Daneel.Debug.StackTrace.EndFunction()
    return result
end

--- Check if the provided argument's value is in the provided expected value(s).
-- When that's not the case, return the value of the 'defaultValue' argument, or throws an error when it is nil.
-- Arguments of type string are considered case-insensitive. The case will be corrected but no error will be thrown.
-- When 'expectedArgumentValues' is of type table, it is always considered as a table of several expected values.
-- @param argument (mixed) The argument to check.
-- @param argumentName (string) The argument name.
-- @param expectedArgumentValues (mixed) The expected argument values(s).
-- @param p_errorHead [optional] (string) The beginning of the error message.
-- @param defaultValue [optional] (mixed) The optional default value.
-- @return (mixed) The argument's value (one of the expected argument values or default value)
function Daneel.Debug.CheckArgValue(argument, argumentName, expectedArgumentValues, p_errorHead, defaultValue)
    Daneel.Debug.StackTrace.BeginFunction("Daneel.Debug.CheckArgValue", argument, argumentName, expectedArgumentValues, p_errorHead)
    local errorHead = "Daneel.Debug.CheckArgValue(argument, argumentName, expectedArgumentValues[, p_errorHead, defaultValue]) : "
    Daneel.Debug.CheckArgType(argumentName, "argumentName", "string", errorHead)
    if expectedArgumentValues == nil then
        error(errorHead.."Argument 'expectedArgumentValues' is nil.")
    end
    Daneel.Debug.CheckOptionalArgType(p_errorHead, "p_errorHead", "string", errorHead)

    if type(expectedArgumentValues) ~= "table" then
        expectedArgumentValues = { expectedArgumentValues }
    elseif #expectedArgumentValues == 0 then
        error(errorHead.."Argument 'expectedArgumentValues' is an empty table.")
    end

    local correctValue = false
    if type(argument) == "string" then
        for i, expectedValue in ipairs(expectedArgumentValues) do
            if argument:lower() == expectedValue:lower() then
                argument = expectedValue
                correctValue = true
                break
            end
        end
    else
        for i, expectedValue in ipairs(expectedArgumentValues) do
            if argument == expectedValue then
                correctValue = true
                break
            end
        end
    end

    if not correctValue then
        if defaultValue ~= nil then
            argument = defaultValue
        else
            for i, value in ipairs(expectedArgumentValues) do
                expectedArgumentValues[i] = tostring(value)
            end
            error(p_errorHead.."The value '"..tostring(argument).."' of argument '"..argumentName.."' is not one of '"..table.concat(expectedArgumentValues, "', '").."'.")
        end
    end
    Daneel.Debug.StackTrace.EndFunction()
    return argument
end

local DaneelScriptAsset = Behavior
Daneel.Debug.tryGameObject = nil -- The game object Daneel.Debug.Try() works with

--- Allow to test out a piece of code without killing the script if the code throws an error.
-- If the code throw an error, it will be printed in the Runtime Report but it won't kill the script that calls Daneel.Debug.Try().
-- Does not protect against exceptions thrown by CraftStudio.
-- @param _function (function or userdata) The function containing the code to try out.
-- @return (boolean) True if the code runs without errors, false otherwise.
function Daneel.Debug.Try( _function )
    Daneel.Debug.StackTrace.BeginFunction( "Daneel.Debug.Try", _function )
    local errorHead = "Daneel.Debug.Try( _function ) : "
    Daneel.Debug.CheckArgType( _function, "_function", {"function", "userdata"}, errorHead )

    local gameObject = Daneel.Debug.tryGameObject
    if gameObject == nil or gameObject.inner == nil then
        gameObject = CraftStudio.CreateGameObject( "Daneel_Debug_Try" )
        Daneel.Debug.tryGameObject = gameObject
    end

    local success = false
    gameObject:CreateScriptedBehavior( DaneelScriptAsset, {
        debugTry = true,
        testFunction = _function,
        successCallback = function() success = true end
    } )

    Daneel.Debug.StackTrace.EndFunction()
    return success
end

--- Overload a function to call debug functions before and after it is itself called.
-- Called from Daneel.Load()
-- @param name (string) The function name
-- @param argsData (table) Mostly the list of arguments. may contains the 'includeInStackTrace' key.
function Daneel.Debug.RegisterFunction( name, argsData )
    if not Daneel.Config.debug.enableDebug then return end

    local includeInStackTrace = true
    if not Daneel.Config.debug.enableStackTrace then
        includeInStackTrace = false
    elseif argsData.includeInStackTrace ~= nil then
        includeInStackTrace = argsData.includeInStackTrace
    end

    local errorHead = name.."( "
    for i, arg in ipairs( argsData ) do
        if arg.name == nil then arg.name = arg[1] end
        errorHead = errorHead..arg.name..", "
    end

    errorHead = errorHead:sub( 1, #errorHead-2 ) -- removes the last coma+space
    errorHead = errorHead.." ) : "

    --
    local originalFunction = table.getvalue( _G, name )

    if originalFunction ~= nil then
        local newFunction = function( ... )
            local funcArgs = { ... }

            if includeInStackTrace then
                Daneel.Debug.StackTrace.BeginFunction( name, ... )
            end

            for i, arg in ipairs( argsData ) do
                if arg.type == nil then
                    arg.type = arg[2]
                    if arg.type == nil and arg.defaultValue ~= nil then
                        arg.type = type( arg.defaultValue )
                    end
                end

                if arg.type ~= nil then
                    if arg.defaultValue ~= nil or arg.isOptional == true then
                        funcArgs[ i ] = Daneel.Debug.CheckOptionalArgType( funcArgs[ i ], arg.name, arg.type, errorHead, arg.defaultValue )
                    else
                        Daneel.Debug.CheckArgType( funcArgs[ i ], arg.name, arg.type, errorHead )
                    end

                elseif funcArgs[ i ] == nil and not arg.isOptional then
                    error( errorHead.."Argument '"..arg.name.."' is nil." )
                end

                if arg.value ~= nil then
                    funcArgs[ i ] = Daneel.Debug.CheckArgValue( funcArgs[ i ], arg.name, arg.value, errorHead, arg.defaultValue )
                end
            end

            local returnValues = { originalFunction( unpack( funcArgs ) ) } -- use unpack here to take into account the values that may have been modified by CheckOptionalArgType()

            if includeInStackTrace then
                Daneel.Debug.StackTrace.EndFunction()
            end

            return unpack( returnValues )
        end

        table.setvalue( _G, name, newFunction )
    else
        print( "Daneel.Debug.RegisterFunction() : Function with name '"..name.."' was not found in the global table _G." )
    end
end

----------------------------------------------------------------------------------
-- StackTrace

Daneel.Debug.StackTrace = { messages = {} }

--- Register a function call in the stack trace.
-- @param functionName (string) The function name.
-- @param ... [optional] (mixed) Arguments received by the function.
function Daneel.Debug.StackTrace.BeginFunction( functionName, ... )
    if
        not Daneel.Config.debug.enableDebug or
        not Daneel.Config.debug.enableStackTrace
    then
        return
    end

    if #Daneel.Debug.StackTrace.messages > 200 then
        print( "WARNING : your StackTrace is more than 200 items long ! Emptying the StackTrace now. Did you forget to write a 'EndFunction()' somewhere ?" )
        Daneel.Debug.StackTrace.messages = {}
    end

    local errorHead = "Daneel.Debug.StackTrace.BeginFunction( functionName[, ...] ) : "
    Daneel.Debug.CheckArgType( functionName, "functionName", "string", errorHead )

    local msg = functionName .. "( "
    local arg = {...}

    if #arg > 0 then
        for i, argument in ipairs( arg ) do
            if type( argument) == "string" then
                msg = msg .. '"' .. tostring( argument ) .. '", '
            else
                msg = msg .. tostring( argument ) .. ", "
            end
        end

        msg = msg:sub( 1, #msg-2 ) -- removes the last coma+space
    end

    msg = msg .. " )"

    table.insert( Daneel.Debug.StackTrace.messages, msg )
end

--- Closes a successful function call, removing it from the stacktrace.
function Daneel.Debug.StackTrace.EndFunction()
    if
        not Daneel.Config.debug.enableDebug or
        not Daneel.Config.debug.enableStackTrace
    then
        return
    end
    -- since 16/05/2013 no arguments is needed anymore, since the StackTrace only keeps open functions calls and never keep returned values
    -- I didn't rewrote all the calls to EndFunction()
    table.remove( Daneel.Debug.StackTrace.messages )
end

--- Prints the StackTrace.
function Daneel.Debug.StackTrace.Print()
    if
        not Daneel.Config.debug.enableDebug or
        not Daneel.Config.debug.enableStackTrace
    then
        return
    end

    local messages = Daneel.Debug.StackTrace.messages
    Daneel.Debug.StackTrace.messages = {}

    print( "~~~~~ Daneel.Debug.StackTrace ~~~~~" )

    if #messages <= 0 then
        print( "No message in the StackTrace." )
    else
        for i, msg in ipairs( messages ) do
            if i < 10 then
                i = "0"..i
            end
            print( "#" .. i .. " " .. msg )
        end
    end
end

----------------------------------------------------------------------------------
-- Event

Daneel.Event = {
    events = {}, -- listeners by events - emptied when a new scene is loaded in CraftStudio.LoadScene()
    persistentEvents = {}, -- not emptied
}

--- Make the provided function or object listen to the provided event(s).
-- The function will be called whenever the provided event will be fired.
-- @param eventName (string or table) The event name (or names in a table).
-- @param functionOrObject (function or table) The function (not the function name) or the object.
-- @param isPersistent (boolean) [default=false] Tell whether the listener automatically stops to listen to any event when a new scene is loaded. Always false when the listener is a game object or a component.
function Daneel.Event.Listen( eventName, functionOrObject, isPersistent )
    local errorHead = "Daneel.Event.Listen( eventName, functionOrObject[, isPersistent] ) : "
    local listenerType = type( functionOrObject )
    local eventNames = eventName
    if type( eventName ) == "string" then
        eventNames = { eventName }
    end
    for i, eventName in pairs( eventNames ) do
        if Daneel.Event.events[ eventName ] == nil then
            Daneel.Event.events[ eventName ] = {}
        end
        if Daneel.Event.persistentEvents[ eventName ] == nil then
            Daneel.Event.persistentEvents[ eventName ] = {}
        end

        if
            not table.containsvalue( Daneel.Event.events[ eventName ], functionOrObject ) and
            not table.containsvalue( Daneel.Event.persistentEvents[ eventName ], functionOrObject )
        then
            -- check that the persistent listener is not a game object or a component (that are always destroyed when the scene loads)
            if isPersistent and listenerType == "table" then
                local mt = getmetatable( functionOrObject )
                if mt ~= nil and mt == GameObject or table.containsvalue( Daneel.Config.componentObjectsByType, mt ) then
                    if Daneel.Config.debug.enableDebug then
                        print( errorHead.."Game objects and components can't be persistent listeners", functionOrObject )
                    end
                    isPersistent = false
                end
            end

            local eventList = Daneel.Event.events
            if isPersistent then
                eventList = Daneel.Event.persistentEvents
            end

            table.insert( eventList[ eventName ], functionOrObject )
        end
    end
end

--- Make the provided function or object to stop listen to the provided event(s).
-- @param eventName (string or table) [optional] The event name or names in a table or nil to stop listen to every events.
-- @param functionOrObject (function, string or GameObject) The function, or the game object name or instance.
function Daneel.Event.StopListen( eventName, functionOrObject )
    if type( eventName ) ~= "string" then
        functionOrObject = eventName
        eventName = nil
    end

    Daneel.Debug.StackTrace.BeginFunction( "Daneel.Event.StopListen", eventName, functionOrObject )
    local errorHead = "Daneel.Event.StopListen( eventName, functionOrObject ) : "
    Daneel.Debug.CheckOptionalArgType( eventName, "eventName", "string", errorHead )
    Daneel.Debug.CheckArgType( functionOrObject, "functionOrObject", {"table", "function"}, errorHead )

    local eventNames = eventName
    if type( eventName ) == "string" then
        eventNames = { eventName }
    end
    if eventNames == nil then
        eventNames = table.merge( table.getkeys( Daneel.Event.events ), table.getkeys( Daneel.Event.persistentEvents ) )
    end

    for i, eventName in pairs( eventNames ) do
        local listeners = Daneel.Event.events[ eventName ]
        if listeners ~= nil then
            table.removevalue( listeners, functionOrObject )
        end
        listeners = Daneel.Event.persistentEvents[ eventName ]
        if listeners ~= nil then
            table.removevalue( listeners, functionOrObject )
        end
    end
    Daneel.Debug.StackTrace.EndFunction()
end

--- Fire the provided event at the provided object or the one that listen to it,
-- transmitting along all subsequent arguments if some exists. <br>
-- Allowed set of arguments are : <br>
-- (eventName[, ...]) <br>
-- (object, eventName[, ...]) <br>
-- @param object [optional] (table) The object to which fire the event at. If nil or abscent, will send the event to its listeners.
-- @param eventName (string) The event name.
-- @param ... [optional] Some arguments to pass along.
function Daneel.Event.Fire( object, eventName, ... )
    local arg = {...}
    Daneel.Debug.StackTrace.BeginFunction( "Daneel.Event.Fire", object, eventName, ... )
    local errorHead = "Daneel.Event.Fire( [object, ]eventName[, ...] ) : "

    local argType = type( object )
    if argType == "string" then
        -- no object provided, fire on the listeners
        if eventName ~= nil then
            table.insert( arg, 1, eventName )
        end
        eventName = object
        object = nil
    
    elseif argType ~= "nil" then
        Daneel.Debug.CheckArgType( object, "object", "table", errorHead )
        Daneel.Debug.CheckArgType( eventName, "eventName", "string", errorHead )
    end


    local listeners = { object }
    if object == nil then
        if Daneel.Event.events[ eventName ] ~= nil then
            listeners = Daneel.Event.events[ eventName ]
        end
        if Daneel.Event.persistentEvents[ eventName ] ~= nil then
            listeners = table.merge( listeners, Daneel.Event.persistentEvents[ eventName ] )
        end
    end

    local listenersToBeRemoved = {}
    for i=1, #listeners do
        local listener = listeners[i]

        local listenerType = type( listener )
        if listenerType == "function" or listenerType == "userdata" then
            if listener( unpack( arg ) ) == false then
                table.insert( listenersToBeRemoved, listener )
            end

        else -- an object
            local mt = getmetatable( listener )
            local listenerIsAlive = not listener.isDestroyed
            if mt == GameObject and listener.inner == nil then
                listenerIsAlive = false
            end
            if listenerIsAlive then -- ensure that the event is not fired on a dead game object or component
                local functions = {} -- list of listener functions attached to this object
                if listener.listenersByEvent ~= nil and listener.listenersByEvent[ eventName ] ~= nil then
                    functions = listener.listenersByEvent[ eventName ]
                end

                -- Look for the value of the EventName property on the object
                local func = rawget( listener, eventName )
                -- Using rawget() prevent a 'Behavior function' to be called as a regular function when the listener is a ScriptedBehavior
                -- because the function exists on the Script object and not on the ScriptedBehavior (the listener),
                -- in which case rawget() returns nil
                if func ~= nil then
                    table.insert( functions, func )
                end

                -- call all listener functions
                for j=1, #functions do
                    functions[j]( ... )
                end

                -- always try to send the message if the object is a game object
                if mt == GameObject then
                    local go = arg[1]
                    if go == listener then
                        -- don't send the first argument when it is the listener game
                        table.remove( arg, 1 )
                    end
                    if #arg == 1 and type( arg[1] ) == "table" then
                        -- directly send the table if there is no other argument
                        arg = arg[1]
                    end
                    listener:SendMessage( eventName, arg )
                end
            end
        end

    end -- end for listeners

    
    for i=1, #listenersToBeRemoved do
        Daneel.Event.StopListen( eventName, listenersToBeRemoved[i] )
    end
    Daneel.Debug.StackTrace.EndFunction()
end

--- Fire an event at the provided game object.
-- @param gameObject (GameObject) The game object.
-- @param eventName (string) The event name.
-- @param ... [optional] Some arguments to pass along.
function GameObject.FireEvent( gameObject, eventName, ... )
    Daneel.Event.Fire( gameObject, eventName, ... )
end

--- Add a listener function for the specified local event on this object.
-- @param object (table) The object.
-- @param eventName (string) The name of the event to listen to.
-- @param listener (function or userdata) The listener function.
function Daneel.Event.AddEventListener( object, eventName, listener )
    if object.listenersByEvent == nil then
        object.listenersByEvent = {}
    end
    if object.listenersByEvent[ eventName ] == nil then
        object.listenersByEvent[ eventName ] = {}
    end
    if not table.containsvalue( object.listenersByEvent[ eventName ], listener ) then
        table.insert( object.listenersByEvent[ eventName ], listener )
    elseif Daneel.Debug.enableDebug == true then
        print("Daneel.Event.AddEventListener(): "..tostring(listener).." already listen for event '"..eventName.."' on object: ", object)
    end
end

--- Add a listener function for the specified local event on this game object.
-- Alias of Daneel.Event.AddEventListener().
-- @param gameObject (GameObject) The game object.
-- @param eventName (string) The name of the event to listen to.
-- @param listener (function or userdata) The listener function.
function GameObject.AddEventListener( gameObject, eventName, listener )
    Daneel.Event.AddEventListener( gameObject, eventName, listener )
end

--- Remove the specified listener for the specified local event on this object
-- @param object (table) The object.
-- @param eventName (string) The name of the event.
-- @param listener (function or userdata) [optional] The listener function to remove. If nil, all listeners will be removed for the specified event.
function Daneel.Event.RemoveEventListener( object, eventName, listener )
    if object.listenersByEvent ~= nil and object.listenersByEvent[ eventName ] ~= nil then
        if listener ~= nil then
            table.removevalue( object.listenersByEvent[ eventName ], listener )
        else
            object.listenersByEvent[ eventName ] = nil
        end
    end
end

--- Remove the specified listener for the specified local event on this game object
-- @param gameObject (table) The game object.
-- @param eventName (string) The name of the event.
-- @param listener (function or userdata) [optional] The listener function to remove. If nil, all listeners will be removed for the specified event.
function GameObject.RemoveEventListener( gameObject, eventName, listener )
    Daneel.Event.RemoveEventListener( gameObject, eventName, listener )
end

local _go = { "gameObject", "GameObject" }
table.mergein( Daneel.Debug.functionArgumentsInfo, {
    ["Daneel.Event.Listen"] = { { "eventName", { s, t } }, { "functionOrObject", {t, f, u} }, { "isPersistent", defaultValue = false } },
    ["GameObject.FireEvent"] = { _go, { "eventName", s } },
    ["Daneel.Event.AddEventListener"] = { { "object", "table" }, { "eventName", s }, { "listener", { f, u } } },
    ["GameObject.AddEventListener"] =   { _go, { "eventName", s }, { "listener", { f, u } } },
    ["Daneel.Event.RemoveEventListener"] = { { "object", "table" }, { "eventName", s }, { "listener", { f, u }, isOptional = true } },
    ["GameObject.RemoveEventListener"] = { _go, { "eventName", s }, { "listener", { f, u }, isOptional = true } },
} )

----------------------------------------------------------------------------------
-- Time

Daneel.Time = {
    realTime = 0.0,
    realDeltaTime = 0.0,

    time = 0.0,
    deltaTime = 0.0,
    timeScale = 1.0,

    frameCount = 0,
}

----------------------------------------------------------------------------------
-- Config, loading

function Daneel.DefaultConfig()
    local config = {
        debug = {
            enableDebug = false, -- Enable/disable Daneel's global debugging features (error reporting + stacktrace).
            enableStackTrace = false, -- Enable/disable the Stack Trace.
        },

        -- this table define the object's type names, returned by Daneel.Debug.GetType()
        objectsByType = {
            GameObject = GameObject,
            Vector3 = Vector3,
            Quaternion = Quaternion,
            Plane = Plane,
            Ray = Ray,
        },

        componentObjectsByType = {
            ScriptedBehavior = ScriptedBehavior,
            ModelRenderer = ModelRenderer,
            MapRenderer = MapRenderer,
            Camera = Camera,
            Transform = Transform,
            Physics = Physics,
            TextRenderer = TextRenderer,
            NetworkSync = NetworkSync,
        },
        componentTypes = {},

        assetObjectsByType = {
            Script = Script,
            Model = Model,
            ModelAnimation = ModelAnimation,
            Map = Map,
            TileSet = TileSet,
            Sound = Sound,
            Scene = Scene,
            --Document = Document,
            Font = Font,
        },
        assetTypes = {},
    }

    return config
end
Daneel.Config = Daneel.DefaultConfig()
Daneel.Config.assetTypes = table.getkeys( Daneel.Config.assetObjectsByType ) -- needed in the CraftStudio script before Daneel is loaded

-- load Daneel at the start of the game
function Daneel.Load()
    if Daneel.isLoaded then return end
    Daneel.isLoading = true

    -- load Daneel config
    local userConfig = nil
    if Daneel.UserConfig ~= nil then
        table.mergein( Daneel.Config, Daneel.UserConfig(), true )
    end

    -- load modules config
    for i, name in ipairs( Daneel.modules.moduleNames ) do
        local module = Daneel.modules[ name ]

        if module.isConfigLoaded ~= true then
            module.isConfigLoaded = true

            if module.Config == nil then
                if module.DefaultConfig ~= nil then
                    module.Config = module.DefaultConfig()
                else
                    module.Config = {}
                end
            end

            if module.UserConfig ~= nil then
                table.mergein( module.Config, module.UserConfig(), true )
            end

            if module.Config.objectsByType ~= nil then
                table.mergein( Daneel.Config.objectsByType, module.Config.objectsByType )
            end

            if module.Config.componentObjectsByType ~= nil then
                table.mergein( Daneel.Config.componentObjectsByType, module.Config.componentObjectsByType )
                table.mergein( Daneel.Config.objectsByType, module.Config.componentObjectsByType )
            end
        end
    end

    table.mergein( Daneel.Config.objectsByType, Daneel.Config.componentObjectsByType, Daneel.Config.assetObjectsByType )

    -- Enable nice printing + dynamic access of getters/setters on components
    for componentType, componentObject in pairs( Daneel.Config.componentObjectsByType ) do
        Daneel.Utilities.AllowDynamicGettersAndSetters( componentObject, { Component } )

        if componentType ~= "ScriptedBehavior" then
            componentObject["__tostring"] = function( component )
                return componentType .. ": " .. component:GetId()
            end
        end
    end

    table.mergein( Daneel.Config.componentTypes, table.getkeys( Daneel.Config.componentObjectsByType ) )

    if Daneel.Config.debug.enableDebug then
        if Daneel.Config.debug.enableStackTrace then
            Daneel.Debug.SetNewError()
        end

        -- overload functions with debug (error reporting + stacktrace)
        for funcName, data in pairs( Daneel.Debug.functionArgumentsInfo ) do
            Daneel.Debug.RegisterFunction( funcName, data )
        end
    end

    -- Enable nice printing + dynamic access of getters/setters on assets
    for assetType, assetObject in pairs( Daneel.Config.assetObjectsByType ) do
        Daneel.Utilities.AllowDynamicGettersAndSetters( assetObject, { Asset } )

        assetObject["__tostring"] = function( asset )
            return  assetType .. ": " .. Daneel.Utilities.GetId( asset ) .. ": '" .. Map.GetPathInPackage( asset ) .. "'"
        end
    end

    CS.IsWebPlayer = type( Camera.ProjectionMode.Orthographic ) == "number" -- "userdata" in native runtimes

    Daneel.Debug.StackTrace.BeginFunction( "Daneel.Load" )

    -- Load modules
    for i, name in ipairs( Daneel.modules.moduleNames ) do
        local module = Daneel.modules[ name ]
        if module.isLoaded ~= true then
            module.isLoaded = true
            if type( module.Load ) == "function" then
                module.Load()
            end
        end
    end

    Daneel.isLoaded = true
    Daneel.isLoading = false
    if Daneel.Config.debug.enableDebug then
        print( "~~~~~ Daneel loaded ~~~~~" )
    end

    -- check for module update functions
    Daneel.moduleUpdateFunctions = {}
    for i, name in ipairs( Daneel.modules.moduleNames ) do
        local module = Daneel.modules[ name ]
        if module.doNotCallUpdate ~= true then
            if type( module.Update ) == "function" and not table.containsvalue( Daneel.moduleUpdateFunctions, module.Update ) then
                table.insert( Daneel.moduleUpdateFunctions, module.Update )
            end
        end
    end

    Daneel.Debug.StackTrace.EndFunction()
end -- end Daneel.Load()

----------------------------------------------------------------------------------
-- Runtime

-- luadoc stop
function Behavior.Awake( self )
    if self.debugTry == true then
        CraftStudio.Destroy( self )
        self.testFunction()
        -- testFunction() may throw an error, kill the scripted behavior and not call the success callback
        -- but it won't kill the script that created the scripted behavior (the one that called Daneel.Debug.Try())
        self.successCallback()
        return
    end

    if table.getvalue( _G, "LOAD_DANEEL" ) ~= nil and LOAD_DANEEL == false then -- just for tests purposes
        return
    end

    if Daneel.isAwake then
        if Daneel.Config.debug.enableDebug then
            print( "Daneel:Awake() : You tried to load Daneel twice ! The 'Daneel' scripted behavior is on two game objects inside the same scene. This time, it was on " .. tostring( self.gameObject ) )
        end
        CS.Destroy( self )
        return
    end
    Daneel.isAwake = true
    Daneel.Event.Listen( "OnNewSceneWillLoad", function() Daneel.isAwake = false end )

    Daneel.Load()
    Daneel.Debug.StackTrace.messages = {}
    Daneel.Debug.StackTrace.BeginFunction( "Daneel.Awake" )


    -- Awake modules
    for i, name in ipairs( Daneel.modules.moduleNames ) do
        local module = Daneel.modules[ name ]
        if type( module.Awake ) == "function" then
            module.Awake()
        end
    end

    if Daneel.Config.debug.enableDebug then
        print("~~~~~ Daneel awake ~~~~~")
    end

    Daneel.Event.Fire( "OnAwake" )

    Daneel.Debug.StackTrace.EndFunction()
end

function Behavior.Start( self )
    if self.debugTry then
        return
    end

    Daneel.Debug.StackTrace.BeginFunction( "Daneel.Start" )

    -- Start modules
    for i, name in ipairs( Daneel.modules.moduleNames ) do
        local module = Daneel.modules[ name ]
        if type( module.Start ) == "function" then
            module.Start()
        end
    end

    if Daneel.Config.debug.enableDebug then
        print("~~~~~ Daneel started ~~~~~")
    end

    Daneel.Event.Fire( "OnStart" )
    Daneel.Debug.StackTrace.EndFunction()
end

function Behavior.Update( self )
    if self.debugTry then
        return
    end

    -- Time
    local currentTime = os.clock()
    Daneel.Time.realDeltaTime = currentTime - Daneel.Time.realTime
    Daneel.Time.realTime = currentTime

    Daneel.Time.deltaTime = Daneel.Time.realDeltaTime * Daneel.Time.timeScale
    Daneel.Time.time = Daneel.Time.time + Daneel.Time.deltaTime

    Daneel.Time.frameCount = Daneel.Time.frameCount + 1

    -- Update modules
    for i=1, #Daneel.moduleUpdateFunctions do
        Daneel.moduleUpdateFunctions[i]()
    end
end

--------------------------------------------------------------------------------
-- Mouse Input component
-- Enable mouse interactions with game objects when added to a game object with a camera component.

MouseInput = { 
    buttonExists = { LeftMouse = false, RightMouse = false, WheelUp = false, WheelDown = false },
    
    frameCount = 0,
    lastLeftClickFrame = 0,

    components = {}, -- array of mouse input components
}
Daneel.modules.MouseInput = MouseInput

function MouseInput.DefaultConfig()
    return {
        doubleClickDelay = 20, -- Maximum number of frames between two clicks of the left mouse button to be considered as a double click

        componentObjectsByType = {
            MouseInput = MouseInput,
        },
    }
end
MouseInput.Config = MouseInput.DefaultConfig()

function MouseInput.Load()
    for buttonName, _ in pairs( MouseInput.buttonExists ) do
        MouseInput.buttonExists[ buttonName ] = Daneel.Utilities.ButtonExists( buttonName )
    end

    MouseInput.lastLeftClickFrame = -MouseInput.Config.doubleClickDelay
end

function MouseInput.Awake()
    MouseInput.components = {}
end

-- Loop on the MouseInput.components.
-- Works with the game objects that have at least one of the component's tag.
-- Check the position of the mouse against these game objects.
-- Fire events accordingly.
function MouseInput.Update()
    MouseInput.frameCount = MouseInput.frameCount + 1
    
    local mouseDelta = CS.Input.GetMouseDelta()
    local mouseIsMoving = false
    if mouseDelta.x ~= 0 or mouseDelta.y ~= 0 then
        mouseIsMoving = true
    end

    local leftMouseJustPressed = false
    local leftMouseDown = false
    local leftMouseJustReleased = false
    if MouseInput.buttonExists.LeftMouse then
        leftMouseJustPressed = CS.Input.WasButtonJustPressed( "LeftMouse" )
        leftMouseDown = CS.Input.IsButtonDown( "LeftMouse" )
        leftMouseJustReleased = CS.Input.WasButtonJustReleased( "LeftMouse" )
    end

    local rightMouseJustPressed = false
    if MouseInput.buttonExists.RightMouse then
        rightMouseJustPressed = CS.Input.WasButtonJustPressed( "RightMouse" )
    end

    local wheelUpJustPressed = false
    if MouseInput.buttonExists.WheelUp then
        wheelUpJustPressed = CS.Input.WasButtonJustPressed( "WheelUp" )
    end

    local wheelDownJustPressed = false
    if MouseInput.buttonExists.WheelDown then
        wheelDownJustPressed = CS.Input.WasButtonJustPressed( "WheelDown" )
    end
    
    if 
        mouseIsMoving == true or
        leftMouseJustPressed == true or 
        leftMouseDown == true or
        leftMouseJustReleased == true or 
        rightMouseJustPressed == true or
        wheelUpJustPressed == true or
        wheelDownJustPressed == true
    then
        local doubleClick = false
        if leftMouseJustPressed then
            doubleClick = ( MouseInput.frameCount <= MouseInput.lastLeftClickFrame + MouseInput.Config.doubleClickDelay )   
            MouseInput.lastLeftClickFrame = MouseInput.frameCount
        end

        local reindexComponents = false
        local reindexGameObjects = false

        for i=1, #MouseInput.components do
            local component = MouseInput.components[i]
            local mi_gameObject = component.gameObject -- mouse input game object

            if mi_gameObject.inner ~= nil and not mi_gameObject.isDestroyed and mi_gameObject.camera ~= nil then
                local ray = mi_gameObject.camera:CreateRay( CS.Input.GetMousePosition() )
                
                for j=1, #component._tags do
                    local tag = component._tags[j]
                    local gameObjects = GameObject.GetWithTag( tag )

                    for k=1, #gameObjects do
                        local gameObject = gameObjects[k]
                        -- gameObject is the game object whose position is checked against the raycasthit
                            
                        local raycastHit = ray:IntersectsGameObject( gameObject )
                        if raycastHit ~= nil then
                            -- the mouse pointer is over the gameObject
                            if not gameObject.isMouseOver then
                                gameObject.isMouseOver = true
                                Daneel.Event.Fire( gameObject, "OnMouseEnter", gameObject )
                            end

                        elseif gameObject.isMouseOver == true then
                            -- the gameObject was still hovered the last frame
                            gameObject.isMouseOver = false
                            Daneel.Event.Fire( gameObject, "OnMouseExit", gameObject )
                        end
                        
                        if gameObject.isMouseOver == true then
                            Daneel.Event.Fire( gameObject, "OnMouseOver", gameObject, raycastHit )

                            if leftMouseJustPressed == true then
                                Daneel.Event.Fire( gameObject, "OnClick", gameObject )

                                if doubleClick == true then
                                    Daneel.Event.Fire( gameObject, "OnDoubleClick", gameObject )
                                end
                            end

                            if leftMouseDown == true and mouseIsMoving == true then
                                Daneel.Event.Fire( gameObject, "OnDrag", gameObject )
                            end

                            if leftMouseJustReleased == true then
                                Daneel.Event.Fire( gameObject, "OnLeftClickReleased", gameObject )
                            end

                            if rightMouseJustPressed == true then
                                Daneel.Event.Fire( gameObject, "OnRightClick", gameObject )
                            end

                            if wheelUpJustPressed == true then
                                Daneel.Event.Fire( gameObject, "OnWheelUp", gameObject )
                            end
                            if wheelDownJustPressed == true then
                                Daneel.Event.Fire( gameObject, "OnWheelDown", gameObject )
                            end
                        end
                    end -- for gameObjects with current tag
                end -- for component._tags
            else
                -- this component's game object is dead or has no camera component
                MouseInput.components[i] = nil
                reindexComponents = true
            end -- gameObject is alive
        end -- for MouseInput.components

        if reindexComponents == true then
            MouseInput.components = table.reindex( MouseInput.components )
        end
    end -- if mouseIsMoving, ...
end -- end MouseInput.Update() 

--- Create a new MouseInput component.
-- @param gameObject (GameObject) The game object.
-- @param params (table) [optional] A table of parameters.
-- @return (MouseInput) The new component.
function MouseInput.New( gameObject, params )
    if gameObject.camera == nil then
        error( "MouseInput.New(gameObject, params) : "..tostring(gameObject).." has no Camera component." )
        return
    end

    local component = { _tags = {} }
    component.gameObject = gameObject
    gameObject.mouseInput = component
    setmetatable( component, MouseInput )  
    if params ~= nil then
        component:Set( params )
    end

    table.insert( MouseInput.components, component )
    return component
end

--- Set tag(s) of the game objects the component works with.
-- @param mouseInput (MouseInput) The mouse input component.
-- @param tags (string or table) The tag(s) of the game objects the component works with.
function MouseInput.SetTags( mouseInput, tags )
    if type( tags ) == "string" then
        tags = {tags}
    end
    mouseInput._tags = tags
end

--- Return the tag(s) of the game objects the component works with.
-- @param mouseInput (MouseInput) The mouse input component.
-- @return (table) The tag(s) of the game objects the component works with.
function MouseInput.GetTags( mouseInput )
    return mouseInput._tags
end

local _mo = { "mouseInput", "MouseInput" }
table.mergein( Daneel.Debug.functionArgumentsInfo, {
    ["MouseInput.New"] = { _go, { "params", "table", isOptional = true } },
    ["MouseInput.SetTags"] = { _mo, { "tags", { s, t } } },
    ["MouseInput.GetTags"] = { _mo },
} )

--------------------------------------------------------------------------------
-- Trigger component

Trigger = {
    frameCount = 0,
    triggerComponents = {},
}
Daneel.modules.Trigger = Trigger

function Trigger.DefaultConfig()
    return {
        componentObjectsByType = {
            Trigger = Trigger,
        },
    }
end
Trigger.Config = Trigger.DefaultConfig()

function Trigger.Awake()
    Trigger.triggerComponents = {}
end

function Trigger.Update()
    Trigger.frameCount = Trigger.frameCount + 1
    local reindexComponents = false

    for i=1, #Trigger.triggerComponents do
        local trigger = Trigger.triggerComponents[i]
        local triggerGameObject = trigger.gameObject

        if triggerGameObject.inner ~= nil and not triggerGameObject.isDestroyed then
            if trigger._updateInterval > 1 and Trigger.frameCount % trigger._updateInterval == 0 then
                local triggerPosition = triggerGameObject.transform:GetPosition()
                
                for j=1, #trigger._tags do
                    local tag = trigger._tags[j]
                    local gameObjects = GameObject.Tags[ tag ]
                    if gameObjects ~= nil then

                        for k=1, #gameObjects do
                            local gameObject = gameObjects[k]
                            -- gameObject is the game object whose position is checked against the trigger's
                            if gameObject.inner ~= nil and not gameObject.isDestroyed and gameObject ~= triggerGameObject then    

                                local gameObjectIsInRange = trigger:IsGameObjectInRange( gameObject, triggerPosition )
                                local gameObjectWasInRange = table.containsvalue( trigger.gameObjectsInRangeLastUpdate, gameObject )

                                if gameObjectIsInRange then
                                    if gameObjectWasInRange then
                                        -- already in this trigger
                                        Daneel.Event.Fire( gameObject, "OnTriggerStay", gameObject, triggerGameObject )
                                        Daneel.Event.Fire( triggerGameObject, "OnTriggerStay", triggerGameObject, gameObject )
                                    else
                                        -- just entered the trigger
                                        table.insert( trigger.gameObjectsInRangeLastUpdate, gameObject )
                                        Daneel.Event.Fire( gameObject, "OnTriggerEnter", gameObject, triggerGameObject )
                                        Daneel.Event.Fire( triggerGameObject, "OnTriggerEnter", triggerGameObject, gameObject )
                                    end
                                elseif gameObjectWasInRange then
                                    -- was in the trigger, but not anymore
                                    table.removevalue( trigger.gameObjectsInRangeLastUpdate, gameObject )
                                    Daneel.Event.Fire( gameObject, "OnTriggerExit", gameObject, triggerGameObject )
                                    Daneel.Event.Fire( triggerGameObject, "OnTriggerExit", triggerGameObject, gameObject )
                                end
                            else 
                                -- gameObject is dead
                                gameObjects[ i ] = nil
                                reindexGameObjects = true
                            end
                        end -- for gameObjects with current tag

                        if reindexGameObjects == true then
                            GameObject.Tags[ tag ] = table.reindex( gameObjects )
                            reindexGameObjects = false
                        end
                    end -- if some game objects have this tag
                end -- for component._tags
            end -- it's time to update this trigger
        else
            -- this component's game object is dead
            Trigger.triggerComponents[i] = nil
            reindexComponents = true
        end -- game object is alive
    end -- for Trigger.triggerComponents

    if reindexComponents == true then
        Trigger.triggerComponents = table.reindex( Trigger.triggerComponents )
    end
end

--- Create a new Trigger component.
-- @param gameObject (GameObject) The game object.
-- @param params (table) [optional] A table of parameters.
-- @return (Trigger) The new component.
function Trigger.New( gameObject, params )
    local trigger = {
        _range = 1,
        _updateInterval = 5,
        _tags = {},
        gameObjectsInRangeLastUpdate = {},
    }
    trigger.gameObject = gameObject
    gameObject.trigger = trigger
    setmetatable( trigger, Trigger )
    if params ~= nil then
        trigger:Set( params )
    end
    return trigger
end

--- Set tag(s) of the game objects the component works with.
-- @param trigger (Trigger) The trigger component.
-- @param tags (string or table) The tag(s) of the game objects the component works with.
function Trigger.SetTags( trigger, tags )
    if type( tags ) == "string" then
        tags = {tags}
    end
    trigger._tags = tags
end

--- Return the tag(s) of the game objects the component works with.
-- @param trigger (Trigger) The trigger component.
-- @return (table) The tag(s) of the game objects the component works with.
function Trigger.GetTags( trigger )
    return trigger._tags
end

--- Set the range of the trigger.
-- @param trigger (Trigger) The trigger component.
-- @param range (number) The range of the trigger. Must be >= 0. Set to 0 to use the trigger's map or model as area.
function Trigger.SetRange( trigger, range )
    trigger._range = math.clamp( range, 0, 9999 )
end

--- Get the range of the trigger.
-- @param trigger (Trigger) The trigger component.
-- @return (number) The range of the trigger.
function Trigger.GetRange( trigger )
    return trigger._range
end

--- Set the interval (in frames) at which the trigger is automatically updated.
-- A value < 1 will prevent the trigger to be automatically updated.
-- @param trigger (Trigger) The trigger component.
-- @param updateInterval (number) The update interval in frames. Must be >= 0
function Trigger.SetUpdateInterval( trigger, updateInterval )
    trigger._updateInterval = math.clamp( updateInterval, 0, 9999 )
end

--- Get the interval (in frames) at which the trigger is automatically updated.
-- @param trigger (Trigger) The trigger component.
-- @return (number) The update interval (in frames) of the trigger.
function Trigger.GetUpdateInterval( trigger )
    return trigger._updateInterval
end

--- Get the gameObjets that are within range of that trigger.
-- @param trigger (Trigger) The trigger component.
-- @return (table) The list of the gameObjects in range (empty if none in range).
function Trigger.GetGameObjectsInRange( trigger )
    local triggerPosition = self.gameObject.transform:GetPosition() 
    local gameObjectsInRange = {}
    for i=1, #trigger._tags do
        local gameObjects = GameObject.GetWithTag( trigger._tags[i] )
        for j=1, #gameObjects do
            local gameObject = gameObjets[j]
            if 
                gameObject ~= trigger.gameObject and
                trigger:IsGameObjectInRange( gameObject, triggerPosition )
            then
                table.insertonce( gameObjectsInRange, gameObject )
            end
        end
    end
    return gameObjectsInRange
end

--- Tell whether the provided game object is in range of the trigger.
-- @param trigger (Trigger) The trigger component.
-- @param gameObject (GameObject) The gameObject.
-- @param triggerPosition (Vector3) [optional] The trigger's current position.
-- @return (boolean) True or false.
function Trigger.IsGameObjectInRange( trigger, gameObject, triggerPosition )
    local errorHead = "Behavior:IsGameObjectInRange( gameObject[, triggerPosition] )"
    local triggerGameObject = trigger.gameObject
    if triggerPosition == nil then
        triggerPosition = triggerGameObject.transform:GetPosition()
    end 

    local gameObjectIsInTrigger = false
    local directionToGameObject = gameObject.transform:GetPosition() - triggerPosition
    local sqrDistanceToGameObject = directionToGameObject:SqrLength()

    if trigger._range > 0 and sqrDistanceToGameObject <= trigger._range ^ 2 then
        gameObjectIsInTrigger = true

    elseif trigger._range <= 0 then
        if trigger.ray == nil then
            trigger.ray = Ray.New( Vector3.New(0), Vector3.New(0) )
        end
        local ray = trigger.ray
        ray.position = triggerPosition
        ray.direction = directionToGameObject -- ray from the trigger to the game object
        
        local distanceToTriggerAsset = nil -- distance to trigger model or map
        if triggerGameObject.modelRenderer ~= nil then
            distanceToTriggerAsset = ray:IntersectsModelRenderer( triggerGameObject.modelRenderer )
        elseif triggerGameObject.mapRenderer ~= nil then
            distanceToTriggerAsset = ray:IntersectsMapRenderer( triggerGameObject.mapRenderer )
        end

        -- if the gameObject has a model or map, replace the distance to the game object with the distance to the asset
        if gameObject.modelRenderer ~= nil then
            sqrDistanceToGameObject = ray:IntersectsModelRenderer( gameObject.modelRenderer ) ^ 2
        elseif gameObject.mapRenderer ~= nil then
            sqrDistanceToGameObject = ray:IntersectsMapRenderer( gameObject.mapRenderer ) ^ 2
        end

        if distanceToTriggerAsset ~= nil and sqrDistanceToGameObject <= distanceToTriggerAsset ^ 2 then
            -- distance from the trigger to the game object is inferior to the distance from the trigger to the trigger's model or map
            -- that means the GO is inside of the model/map
            -- the ray goes through the GO origin before intersecting the asset 
            gameObjectIsInTrigger = true
        end
    end

    return gameObjectIsInTrigger
end

local _trigger = { "trigger", "Trigger" }
table.mergein( Daneel.Debug.functionArgumentsInfo, {
    ["Trigger.New"] = { _go, { "params", "table", isOptional = true } },
    ["Trigger.SetTags"] = { _trigger, { "tags", { s, t } } },
    ["Trigger.GetTags"] = { _trigger },
    ["Trigger.SetRange"] = { _trigger, { "range", n } },
    ["Trigger.GetRange"] = { _trigger },
    ["Trigger.SetUpdateInterval"] = { _trigger, { "updateInterval", n } },
    ["Trigger.GetUpdateInterval"] = { _trigger },
    ["Trigger.GetGameObjectsInRange"] = { _trigger },
    ["Trigger.IsGameObjectInRange"] = { _trigger, _go, { "triggerPosition", "Vector3", isOptional = true } },
} )

--------------------------------------------------------------------------------
-- Language - Localization

Lang = {
    dictionariesByLanguage = { english = {} },
    cache = {},
    gameObjectsToUpdate = {},
    doNotCallUpdate = true, -- let that here ! It's read in Daneel.Load() to not include Lang.Update() to the list of functions to be called every frames.
}

Daneel.modules.Lang = Lang

function Lang.DefaultConfig()
    return {
        default = nil, -- Default language
        current = nil, -- Current language
        searchInDefault = true, -- Tell whether Lang.Get() search a line key in the default language 
        -- when it is not found in the current language before returning the value of keyNotFound
        keyNotFound = "langkeynotfound", -- Value returned when a language key is not found
    }
end
Lang.Config = Lang.DefaultConfig()

function Lang.Load()
    local defaultLanguage = nil

    for lang, dico in pairs( Lang.dictionariesByLanguage ) do
        local llang = lang:lower()
        if llang ~= lang then
            Lang.dictionariesByLanguage[ llang ] = dico
            Lang.dictionariesByLanguage[ lang ] = nil
        end

        if defaultLanguage == nil then
            defaultLanguage = llang
        end
    end

    if defaultLanguage == nil then -- no dictionary found
        if Daneel.Config.debug.enableDebug == true then
            error("Lang.Load(): No dictionary found in Lang.dictionariesByLanguage !")
        end
        return
    end
    
    if Lang.Config.default == nil then
        Lang.Config.default = defaultLanguage
    end
    Lang.Config.default = Lang.Config.default:lower()

    if Lang.Config.current == nil then
        Lang.Config.current = Lang.Config.default
    end
    Lang.Config.current = Lang.Config.current:lower()
end

function Lang.Start() 
    if Lang.Config.current ~= nil then
        Lang.Update( Lang.Config.current )
    end
end

--- Get the localized line identified by the provided key.
-- @param key (string) The language key.
-- @param replacements (table) [optional] The placeholders and their replacements.
-- @return (string) The line.
function Lang.Get( key, replacements )
    if replacements == nil and Lang.cache[ key ] ~= nil then
        return Lang.cache[ key ]
    end

    local currentLanguage = Lang.Config.current
    local defaultLanguage = Lang.Config.default
    local searchInDefault = Lang.Config.searchInDefault
    local cache = true

    local keys = string.split( key, "." )
    local language = currentLanguage
    if Lang.dictionariesByLanguage[ keys[1] ] ~= nil then
        language = table.remove( keys, 1 )
    end
    
    local noLangKey = table.concat( keys, "." ) -- rebuilt the key, but without the language
    local fullKey = language .. "." .. noLangKey 
    if replacements == nil and Lang.cache[ fullKey ] ~= nil then
        return Lang.cache[ fullKey ]
    end

    local dico = Lang.dictionariesByLanguage[ language ]
    local errorHead = "Lang.Get(key[, replacements]): "
    if dico == nil then
        error( errorHead.."Language '"..language.."' does not exists", key, fullKey )
    end

    for i=1, #keys do
        local _key = keys[i]
        if dico[_key] == nil then
            -- key was not found in this language
            -- search for it in the default language
            if searchInDefault == true and language ~= defaultLanguage then
                cache = false
                dico = Lang.Get( defaultLanguage.."."..noLangKey, replacements )
            else -- already default language or don't want to search in
                dico = Lang.Config.keyNotFound or "keynotfound"
            end

            break
        end
        dico = dico[ _key ]
        -- dico is now a nested table in the dictionary, or a searched string (or the keynotfound string)
    end

    -- dico should be the searched (or keynotfound) string by now
    local line = dico
    if type( line ) ~= "string" then
        error( errorHead.."Localization key '"..key.."' does not lead to a string but to : '"..tostring(line).."'.", key, fullKey )
    end

    -- process replacements
    if replacements ~= nil then
        line = Daneel.Utilities.ReplaceInString( line, replacements )
    elseif cache == true and line ~= Lang.Config.keyNotFound then
        Lang.cache[ key ] = line -- ie: "greetings.welcome"
        Lang.cache[ fullKey ] = line -- ie: "english.greetings.welcome"
    end

    return line
end

--- Register a game object to update its text renderer whenever the language will be updated by Lang.Update().
-- @param gameObject (GameObject) The gameObject.
-- @param key (string) The language key.
-- @param replacements (table) [optional] The placeholders and their replacements.
function Lang.RegisterForUpdate( gameObject, key, replacements )
    Lang.gameObjectsToUpdate[gameObject] = {
        key = key,
        replacements = replacements,
    }
end

--- Update the current language and the text of all game objects that have registered via Lang.RegisterForUpdate(). <br>
-- Fire the OnLangUpdate event.
-- @param language (string) The new current language.
function Lang.Update( language )
    language = Daneel.Debug.CheckArgValue( language, "language", table.getkeys( Lang.dictionariesByLanguage ), "Lang.Update(language): " )
    
    Lang.cache = {} -- ideally only the items that do not begins by a language name should be deleted
    Lang.Config.current = language
    for gameObject, data in pairs( Lang.gameObjectsToUpdate ) do
        if gameObject.inner == nil or gameObject.isDestroyed == true then
            Lang.gameObjectsToUpdate[ gameObject ] = nil
        else
            local text = Lang.Get( data.key, data.replacements )
            
            if gameObject.textArea ~= nil then
                gameObject.textArea:SetText( text )
            elseif gameObject.textRenderer ~= nil then
                gameObject.textRenderer:SetText( text )
            
            elseif Daneel.Config.debug.enableDebug then
                print( "Lang.Update(language): WARNING : "..tostring( gameObject ).." has no TextRenderer or GUI.TextArea component." )
            end
        end
    end

    Daneel.Event.Fire( "OnLangUpdate" )
end

table.mergein( Daneel.Debug.functionArgumentsInfo, {
    ["Lang.Get"] = { { "key", "string" }, { "replacements", "table", isOptional = true } },
    ["Lang.RegisterForUpdate"] = { _go, { "key", "string" }, { "replacements", "table", isOptional = true } },
    ["Lang.Update"] = { { "language", "string" } },
} )

-- CraftStudio.lua
-- Contains extensions of CraftStudio's API.
--
-- Last modified for v1.5.0
-- Copyright © 2013-2014 Florent POUJOL, published under the MIT license.

-- debug info
local s = "string"
local b = "boolean"
local n = "number"
local t = "table"
local go = "GameObject"
local v2 = "Vector2"
local v3 = "Vector3"
local _p = { "params", t }

setmetatable( Vector3, { __call = function(Object, ...) return Object:New(...) end } )
setmetatable( Quaternion, { __call = function(Object, ...) return Object:New(...) end } )
setmetatable( Plane, { __call = function(Object, ...) return Object:New(...) end } )

-- fix
Plane.__tostring = function( p )
    return "Plane: { normal="..tostring(p.normal)..", distance="..tostring(p.distance).." }"
    -- tostring() to prevent a "p.normal is not defined" error
end

--------------------------------------------------------------------------------
-- Assets

Asset = {}
Asset.__index = Asset
setmetatable( Asset, { __call = function(Object, ...) return Object.Get(...) end } )

local assetPathTypes = table.merge( { "string" }, Daneel.Config.assetTypes ) -- Allow the assetPath argument to be an asset or the asset path (string)
--- Alias of CraftStudio.FindAsset( assetPath[, assetType] ).
-- Get the asset of the specified name and type.
-- The first argument may be an asset object, so that you can check if a variable was an asset object or name (and get the corresponding object).
-- @param assetPath (string or any asset type) The fully-qualified asset name or asset object.
-- @param assetType [optional] (string) The asset type as a case-insensitive string.
-- @param errorIfAssetNotFound [default=false] Throw an error if the asset was not found (instead of returning nil).
-- @return (One of the asset type) The asset, or nil if none is found.
function Asset.Get( assetPath, assetType, errorIfAssetNotFound )
    local errorHead = "Asset.Get( assetPath[, assetType, errorIfAssetNotFound] ) : "

    if assetPath == nil then
        if Daneel.Config.debug.enableDebug then
            error( errorHead.."Argument 'assetPath' is nil." )
        end
        return nil
    end

    local argType = Daneel.Debug.CheckArgType( assetPath, "assetPath", assetPathTypes, errorHead )
    
    if assetType ~= nil then
        Daneel.Debug.CheckArgType( assetType, "assetType", "string", errorHead )
        assetType = Daneel.Debug.CheckArgValue( assetType, "assetType", Daneel.Config.assetTypes, errorHead )
    end

    -- just return the asset if assetPath is already an object
    if argType ~= "string" then
        if assetType ~= nil and argType ~= assetType then
            error( errorHead.."Provided asset '"..assetPath.."' has a different type '"..argType.."' than the provided 'assetType' argument '"..assetType.."'." )
        end
        return assetPath
    end
    -- else assetPath is always an actual asset path as a string

    Daneel.Debug.CheckOptionalArgType( errorIfAssetNotFound, "errorIfAssetNotFound", "boolean", errorHead )

    -- get asset
    local asset = nil
    if assetType == nil then
        asset = CraftStudio.FindAsset( assetPath )
    else
        asset = CraftStudio.FindAsset( assetPath, assetType )
    end

    if asset == nil and errorIfAssetNotFound then
        if assetType == nil then
            assetType = "asset"
        end
        error( errorHead .. "Argument 'assetPath' : " .. assetType .. " with name '" .. assetPath .. "' was not found." )
    end

    return asset
end

--- Returns the path of the provided asset.
-- Alias of Map.GetPathInPackage().
-- @param asset (any asset type) The asset instance.
-- @return (string) The fully-qualified asset path.
function Asset.GetPath( asset )
    return Map.GetPathInPackage( asset )
end

--- Returns the name of the provided asset.
-- @param asset (any asset type) The asset instance.
-- @return (string) The name (the last segment of the fully-qualified path).
function Asset.GetName( asset )
    local name = rawget( asset, "name" )
    if name == nil then
        name = Asset.GetPath( asset ):gsub( "^(.*/)", "" )
        rawset( asset, "name", name )
    end
    return name
end

--- Returns the asset's internal unique identifier.
-- @param asset (any asset type) The asset.
-- @return (number) The id.
function Asset.GetId( asset )
    return Daneel.Utilities.GetId( asset )
end

--------------------------------------------------------------------------------
-- Component ("mother" object of components)

Component = {}
Component.__index = Component

--- Apply the content of the params argument to the provided component.
-- @param component (any component type) The component.
-- @param params (table) A table of parameters to set the component with.
function Component.Set( component, params )
    for key, value in pairs( params ) do
        component[key] = value
    end
end

--- Destroy the provided component, removing it from the game object.
-- Note that the component is removed only at the end of the current frame.
-- @param component (any component type) The component.
function Component.Destroy( component )
    table.removevalue( component.gameObject, component )
    CraftStudio.Destroy( component )
end

--- Returns the component's internal unique identifier.
-- @param component (any component type) The component.
-- @return (number) The id.
function Component.GetId( component )
    -- no Debug because is used in __tostring
    return Daneel.Utilities.GetId( component )
end

table.mergein( Daneel.Debug.functionArgumentsInfo, {
    ["Asset.Get"] = { { "assetPath" }, { "assetType", isOptional = true }, { "errorIfAssetNotFound", defaultValue = false } },
    ["Asset.GetPath"] = { { "asset", Daneel.Config.assetTypes } },
    ["Asset.GetName"] = { { "asset", Daneel.Config.assetTypes } },

    ["Component.Set"] = { { "component", Daneel.Config.componentTypes }, { "params", defaultValue = {} } },
    ["Component.Destroy"] = { { "component", Daneel.Config.componentTypes } },
} )


--------------------------------------------------------------------------------
-- Map

Map.oGetPathInPackage = Map.GetPathInPackage
function Map.GetPathInPackage( asset )
    local path = rawget( asset, "path" )
    if path == nil then
        path = Map.oGetPathInPackage( asset )
    end
    return path
end

Map.oLoadFromPackage = Map.LoadFromPackage
function Map.LoadFromPackage( path, callback )
    Map.oLoadFromPackage( path, function( map )
        if map ~= nil then
            --fix for Map.GetPathInPackage() that returns an error when the asset was dynamically loaded
            rawset( map, "path", path )
        end
        callback( map )
    end )
end

Map.oGetBlockIDAt = Map.GetBlockIDAt
--- Returns A block ID between 0-254 if a block exists at the given location (all valid block IDs are in the range 0-254),
-- otherwise f there is no block at the given location then it will return Map.EmptyBlockID (which has a value of 255).
-- @param map (Map) The map.
-- @param x (number or Vector3) The location's x component, or the location as a Vector3.
-- @param y (number) [optional] The location's y component. Should be nil if the "x" argument is a Vector3.
-- @param z (number) [optional] The location's z component. Should be nil if the "x" argument is a Vector3.
-- @return (number) The block ID.
function Map.GetBlockIDAt( map, x, y, z )
    if type( x ) == "table" then
        z = x.z
        y = x.y
        x = x.x
    end
    return Map.oGetBlockIDAt( map, x, y, z )
end

Map.oGetBlockOrientationAt = Map.GetBlockOrientationAt
--- Returns The block orientation of the block at the specified location, 
-- otherwise if there is no block at the given location it will return Map.BlockOrientation.North.
-- @param map (Map) The map.
-- @param x (number or Vector3) The location's x component, or the location as a Vector3.
-- @param y (number) [optional] The location's y component. Should be nil if the "x" argument is a Vector3.
-- @param z (number) [optional] The location's z component. Should be nil if the "x" argument is a Vector3.
-- @return (Map.BlockOrientation) The block orientation.
function Map.GetBlockOrientationAt( map, x, y, z )
    if type( x ) == "table" then
        z = x.z
        y = x.y
        x = x.x
    end
    return Map.GetBlockOrientationAt( map, x, y, z )
end

Map.oSetBlockAt = Map.SetBlockAt
--- Sets a block's ID and block orientation at the given location on the map.
-- @param map (Map) The map.
-- @param x (number or Vector3) The location's x component, or the location as a Vector3.
-- @param y (number) [optional] The location's y component. Must have the value of the "id" argument if the "x" argument is a Vector3.
-- @param z (number) [optional] The location's z component. Must have the value of the optional "orientation" argument  if the "x" argument is a Vector3.
-- @param id (number) The block ID.
-- @param orientation (Map.BlockOrientation) [optional] The block orientation.
function Map.SetBlockAt( map, x, y, z, id, orientation )
    if type( x ) == "table" then
        id = y
        orientation = z
        z = x.z
        y = x.y
        x = x.x
    end
    if orientation == nil then
        Map.oSetBlockAt( map, x, y, z, id )
    else
        Map.oSetBlockAt( map, x, y, z, id, orientation )
    end
end

--------------------------------------------------------------------------------
-- Transform

Transform.oSetLocalScale = Transform.SetLocalScale
--- Set the transform's local scale.
-- @param transform (Transform) The transform component.
-- @param scale (number or Vector3) The global scale.
function Transform.SetLocalScale(transform, scale)
    if type( scale ) == "number" then
        scale = Vector3:New(scale)
    end
    Transform.oSetLocalScale(transform, scale)
end

--- Set the transform's global scale.
-- @param transform (Transform) The transform component.
-- @param scale (number or Vector3) The global scale.
function Transform.SetScale(transform, scale)
    if type( scale ) == "number" then
        scale = Vector3:New(scale)
    end
    local parent = transform.gameObject:GetParent()
    if parent ~= nil then
        scale = scale / parent.transform:GetScale()
    end
    transform:SetLocalScale( scale )
end

--- Get the transform's global scale.
-- @param transform (Transform) The transform component.
-- @return (Vector3) The global scale.
function Transform.GetScale(transform)
    local scale = transform:GetLocalScale()
    local parent = transform.gameObject:GetParent()
    if parent ~= nil then
        scale = scale * parent.transform:GetScale()
    end
    return scale
end

--- Transform a global position to a position local to this transform.
-- @param transform (Transform) The transform component.
-- @param position (Vector3) The global position.
-- @return (Vector3) The local position corresponding to the provided global position.
function Transform.WorldToLocal( transform, position )
    local go = transform.worldToLocalGO
    if go == nil then
        go = CS.CreateGameObject( "WorldToLocal", transform.gameObject )
        transform.worldToLocalGO = go
    else
        go:SetParent( transform.gameObject )
    end
    go.transform:SetPosition( position )
    return go.transform:GetLocalPosition()
end

--- Transform a position local to this transform to a global position.
-- @param transform (Transform) The transform component.
-- @param position (Vector3) The local position.
-- @return (Vector3) The global position corresponding to the provided local position.
function Transform.LocalToWorld( transform, position )
    local go = transform.worldToLocalGO
    if go == nil then
        go = CS.CreateGameObject( "WorldToLocal", transform.gameObject )
        transform.worldToLocalGO = go
    else
        go:SetParent( transform.gameObject )
    end
    go.transform:SetLocalPosition( position )
    return go.transform:GetPosition()
end

--------------------------------------------------------------------------------
-- ModelRenderer

ModelRenderer.oSetModel = ModelRenderer.SetModel
--- Attach the provided model to the provided modelRenderer.
-- @param modelRenderer (ModelRenderer) The modelRenderer.
-- @param modelNameOrAsset (string or Model) [optional] The model name or asset, or nil.
function ModelRenderer.SetModel( modelRenderer, modelNameOrAsset )
    local model = nil
    if modelNameOrAsset ~= nil then
        model = Asset.Get( modelNameOrAsset, "Model", true )
    end
    ModelRenderer.oSetModel( modelRenderer, model )
end

ModelRenderer.oSetAnimation = ModelRenderer.SetAnimation
--- Set the specified animation for the modelRenderer's current model.
-- @param modelRenderer (ModelRenderer) The modelRenderer.
-- @param animationNameOrAsset (string or ModelAnimation) [optional] The animation name or asset, or nil.
function ModelRenderer.SetAnimation( modelRenderer, animationNameOrAsset )
    local animation = nil
    if animationNameOrAsset ~= nil then
        animation = Asset.Get( animationNameOrAsset, "ModelAnimation", true )
    end
    ModelRenderer.oSetAnimation( modelRenderer, animation )
end

--- Apply the content of the params argument to the provided model renderer.
-- @param modelRenderer (ModelRenderer) The model renderer.
-- @param params (table) A table of parameters to set the component with.
function ModelRenderer.Set( modelRenderer, params )
    if params.model ~= nil then
        modelRenderer:SetModel( params.model )
        params.model = nil
    end
    if params.animationTime ~= nil and params.animation ~= nil then
        modelRenderer:SetAnimation( params.animation )
        params.animation = nil
    end
    Component.Set( modelRenderer, params )
end

--------------------------------------------------------------------------------
-- MapRenderer

MapRenderer.oSetMap = MapRenderer.SetMap
--- Attach the provided map to the provided map renderer.
-- @param mapRenderer (MapRenderer) The map renderer.
-- @param mapNameOrAsset (string or Map) [optional] The map name or asset, or nil.
-- @param replaceTileSet (boolean) [default=true] Replace the current TileSet by the one set for the provided map in the map editor.
function MapRenderer.SetMap( mapRenderer, mapNameOrAsset, replaceTileSet )
    local map = nil
    if mapNameOrAsset ~= nil then
        map = Asset.Get( mapNameOrAsset, "Map", true )
    end
    if replaceTileSet ~= nil then
        MapRenderer.oSetMap(mapRenderer, map, replaceTileSet)
    else
        MapRenderer.oSetMap(mapRenderer, map)
    end
end

MapRenderer.oSetTileSet = MapRenderer.SetTileSet
--- Set the specified tileSet for the mapRenderer's map.
-- @param mapRenderer (MapRenderer) The mapRenderer.
-- @param tileSetNameOrAsset (string or TileSet) [optional] The tileSet name or asset, or nil.
function MapRenderer.SetTileSet( mapRenderer, tileSetNameOrAsset )
    local tileSet = nil
    if tileSetNameOrAsset ~= nil then
        tileSet = Asset.Get( tileSetNameOrAsset, "TileSet", true )
    end
    MapRenderer.oSetTileSet( mapRenderer, tileSet )
end

--- Apply the content of the params argument to the provided map renderer.
-- @param mapRenderer (MapRenderer) The map renderer.
-- @param params (table) A table of parameters to set the component with.
function MapRenderer.Set( mapRenderer, params )
    if params.map ~= nil then
        mapRenderer:SetMap( params.map )
        -- set the map here in case of the tileSet property is set too
        params.map = nil
    end
    Component.Set( mapRenderer, params )
end

--- Dynamically loads a new version of the provided map renderer's map and sets it as the map renderer new map.
-- @param mapRenderer (MapRenderer) The map renderer.
-- @param callback (function) [optional] The callback function to be called when the new map has been loaded. The new map is pased as first and only argument.
function MapRenderer.LoadNewMap( mapRenderer, callback )
    local map = mapRenderer:GetMap()
    if map ~= nil then
        Map.LoadFromPackage( Map.GetPathInPackage( map ), function( map )
            mapRenderer:SetMap( map )
            if callback ~= nil then
                callback( map )
            end
        end )
    elseif Daneel.Config.debug.enableDebug == true then
        error("MapRenderer.LoadNewMap(): No map is set on the provided map renderer. Can't load new map.")
    end
end

--------------------------------------------------------------------------------
-- TextRenderer

TextRenderer.oSetFont = TextRenderer.SetFont
--- Set the provided font to the provided text renderer.
-- @param textRenderer (TextRenderer) The text renderer.
-- @param fontNameOrAsset (string or Font) [optional] The font name or asset, or nil.
function TextRenderer.SetFont( textRenderer, fontNameOrAsset )
    local font = nil
    if fontNameOrAsset ~= nil then
        font = Asset.Get( fontNameOrAsset, "Font", true )
    end
    TextRenderer.oSetFont( textRenderer, font )
end

TextRenderer.oSetAlignment = TextRenderer.SetAlignment
--- Set the text's alignment.
-- @param textRenderer (TextRenderer) The textRenderer.
-- @param alignment (string or TextRenderer.Alignment) The alignment. Values (case-insensitive when of type string) may be "left", "center", "right", TextRenderer.Alignment.Left, TextRenderer.Alignment.Center or TextRenderer.Alignment.Right.
function TextRenderer.SetAlignment(textRenderer, alignment)
    if type( alignment ) == "string" then
        local default = "Center"
        if Daneel.Config.textRenderer ~= nil and Daneel.Config.textRenderer.alignment ~= nil then
            default = Daneel.Config.textRenderer.alignment
        end
        local errorHead = "TextRenderer.SetAlignment( textRenderer, alignment ) : "
        alignment = Daneel.Debug.CheckArgValue( alignment, "alignment", {"Left", "Center", "Right"}, errorHead, default )
        alignment = TextRenderer.Alignment[ alignment ]
    end
    TextRenderer.oSetAlignment( textRenderer, alignment )
end

--- Update the game object's scale to make the text appear the provided width.
-- @param textRenderer (TextRenderer) The textRenderer.
-- @param width (number) The text's width in scene units.
function TextRenderer.SetTextWidth( textRenderer, width )
    local widthScaleRatio = textRenderer:GetTextWidth() / textRenderer.gameObject.transform:GetScale()
    textRenderer.gameObject.transform:SetScale( width / widthScaleRatio )
end

--------------------------------------------------------------------------------
-- Camera

Camera.oSetProjectionMode = Camera.SetProjectionMode
--- Sets the camera projection mode.
-- @param camera (Camera) The camera.
-- @param projectionMode (string or Camera.ProjectionMode) The projection mode. Possible values are "perspective", "orthographic" (as a case-insensitive string), Camera.ProjectionMode.Perspective or Camera.ProjectionMode.Orthographic.
function Camera.SetProjectionMode( camera, projectionMode )
    if type( projectionMode ) == "string" then
        local default = "Perspective"
        if Daneel.Config.camera ~= nil and Daneel.Config.camera.projectionMode ~= nil then
            default = Daneel.Config.camera.projectionMode
        end
        projectionMode = Daneel.Debug.CheckArgValue( projectionMode, "projectionMode", {"Perspective", "Orthographic"}, "Camera.SetProjectionMode( camera[, projectionMode] ) : ", default )
        projectionMode = Camera.ProjectionMode[ projectionMode ]
    end
    Camera.oSetProjectionMode( camera, projectionMode )
end

--- Apply the content of the params argument to the provided camera.
-- @param camera (Camera) The camera.
-- @param params (table) A table of parameters to set the component with.
function Camera.Set( camera, params )
    if params.projectionMode ~= nil then
        camera:SetProjectionMode( params.projectionMode )
        params.projectionMode = nil
    end
    Component.Set( camera, params )
end

--- Returns the pixels to scene units factor.
-- @return (number) The camera's PixelsToUnits ratio.
function Camera.GetPixelsToUnits( camera )
    local screenSize = CS.Screen.GetSize()
    local smallestSideSize = screenSize.y
    if screenSize.x < screenSize.y then
        smallestSideSize = screenSize.x
    end
    if camera:GetProjectionMode() == Camera.ProjectionMode.Orthographic then
        return camera:GetOrthographicScale() / smallestSideSize
    else -- perspective
        -- UnitsToPixels (px) = BaseDist * SSS (px) = 0.5 * SSS / tan( FOV / 2 )
        return math.tan( math.rad( camera:GetFOV() / 2 ) ) / smallestSideSize * 2
        -- Original expression was as below. Has been changed to remove the parenthesis so that luamin 
        -- doesn't mess with the calculation by removing the parenthesis itself without changing the values.
        -- return math.tan( math.rad( camera:GetFOV() / 2 ) ) / ( 0.5 * smallestSideSize )
    end
end

--- Returns the scene units to pixels factor.
-- @return (number) The camera's UnitsToPixels ratio.
function Camera.GetUnitsToPixels( camera )
    local pixelsToUnits = camera:GetPixelsToUnits()
    if pixelsToUnits ~= nil and pixelsToUnits ~= 0 then
        return 1 / pixelsToUnits
    end
end

--- Returns the perspective camera's base distance.
-- The base distance is the distance from the camera at which 1 scene unit has the size of the smallest side of the screen.
-- Only works for perspective cameras. Returns nil for orthographic cameras.
-- @param camera (Camera) The camera component.
-- @return (number) The camera's base distance.
function Camera.GetBaseDistance( camera )
    if camera:GetProjectionMode() == Camera.ProjectionMode.Perspective then
        return 0.5 / math.tan( math.rad( camera:GetFOV() / 2 ) )
    end
end

--- Tell whether the provided position is inside the camera's frustum.
-- @param camera (Camera) The camera component.
-- @param position (Vector3) The position.
-- @return (boolean) True if the position is inside the camera's frustum.
function Camera.IsPositionInFrustum( camera, position )
    local localPosition = camera.gameObject.transform:WorldToLocal( position )
    if localPosition.z < 0 then
        local screenSize = CS.Screen.GetSize()
        local range = Vector2.New(0)

        if camera:GetProjectionMode() == Camera.ProjectionMode.Orthographic then
            range = screenSize * camera:GetPixelsToUnits() / 2
        else -- perspective
            local smallestSideSize = screenSize.y
            if screenSize.x < screenSize.y then
                smallestSideSize = screenSize.x
            end
            range = -localPosition.z / camera:GetBaseDistance() * screenSize / smallestSideSize -- frustrum size
            range = range / 2
        end

        if
            localPosition.x >= -range.x and localPosition.x <= range.x and
            localPosition.y >= - range.y and localPosition.y <= range.y
        then
            return true
        end
    end
    return false
end

--- Translate a position in the scene to an on-screen position.
-- The Z component of the returned Vector3 represent the distance from the camera to the position's plane.
-- It's inferior to zero when the position is in front of the camera.
-- Note that when the object is behind the camera, the returned screen coordinates are not the same as the ones given by Camera.Project().
-- @param camera (Camera) The camera component.
-- @param position (Vector3) The position.
-- @return (Vector3) A Vector3 where X and Y are the screen position and Z the distance to the position's plane.
function Camera.WorldToScreenPoint( camera, position )
    local localPosition = camera.gameObject.transform:WorldToLocal( position )
    local unitsToPixels = camera:GetUnitsToPixels()
    local screenSize = CS.Screen.GetSize()
    if camera:GetProjectionMode() == Camera.ProjectionMode.Orthographic then
        localPosition.x =  localPosition.x * unitsToPixels + screenSize.x / 2
        localPosition.y = -localPosition.y * unitsToPixels + screenSize.y / 2
    else -- perspective
        local distance = math.abs( localPosition.z )
        localPosition.x =  localPosition.x / distance * unitsToPixels + screenSize.x / 2
        localPosition.y = -localPosition.y / distance * unitsToPixels + screenSize.y / 2
    end
    return localPosition
end

Camera.oGetFOV = Camera.GetFOV
--- Returns the FOV of the provided perspective camera (rounded to the second digit after the coma).
-- @param camera (Camera) The Camera component.
-- @return (number) The FOV
function Camera.GetFOV( camera )
    return math.round( Camera.oGetFOV( camera ), 2 )
end

-- Just to be able to dynamically call Get/SetFOV() with "camera.fov" instead of "camera.fOV"
Camera.GetFov = Camera.GetFOV
Camera.SetFov = Camera.SetFOV

Camera.oProject = Camera.Project
--- Projects a 3D space position to a 2D screen position.
-- @param camera (Camera) The camera component.
-- @param position (Vector3) The position.
-- @return (Vector2) The projected screen coordinates.
function Camera.Project( camera, position )
    return setmetatable( Camera.oProject( camera, position ), Vector2 )
end

table.mergein( Daneel.Debug.functionArgumentsInfo, {
    ["Transform.SetLocalScale"] = { { "transform", "Transform" }, { "number", { n, v3 } } },
    ["Transform.SetScale"] =      { { "transform", "Transform" }, { "number", { n, v3 } } },
    ["Transform.GetScale"] =      { { "transform", "Transform" } },
    ["Transform.WorldToLocal"] =  { { "transform", "Transform" }, { "position", v3 } },
    ["Transform.LocalToWorld"] =  { { "transform", "Transform" }, { "position", v3 } },

    ["ModelRenderer.SetModel"] =     { { "modelRenderer", "ModelRenderer" }, { "modelNameOrAsset", { s, "Model" }, isOptional = true } },
    ["ModelRenderer.SetAnimation"] = { { "modelRenderer", "ModelRenderer" }, { "animationNameOrAsset", { s, "ModelAnimation" }, isOptional = true } },
    ["ModelRenderer.Set"] =          { { "modelRenderer", "ModelRenderer" }, _p },

    ["MapRenderer.SetMap"] = {
        { "mapRenderer", "MapRenderer" },
        { "mapNameOrAsset", { s, "Map" }, isOptional = true },
        { "replaceTileSet", defaultValue = true },
    },
    ["MapRenderer.SetTileSet"] = { { "mapRenderer", "MapRenderer" }, { "tileSetNameOrAsset", { s, "TileSet" }, isOptional = true } },
    ["MapRenderer.Set"] =        { { "mapRenderer", "MapRenderer" }, _p },
    ["MapRenderer.LoadNewMap"] = { { "mapRenderer", "MapRenderer" }, { "callback", "function", isOptional = true } },

    ["TextRenderer.SetFont"] =      { { "textRenderer", "TextRenderer" }, { "fontNameOrAsset", { s, "Font" }, isOptional = true } },
    ["TextRenderer.SetAlignment"] = { { "textRenderer", "TextRenderer" }, { "alignment", {s, "userdata", n} } }, -- number because enum returns a number in the webplayer
    ["TextRenderer.SetTextWidth"] = { { "textRenderer", "TextRenderer" }, { "width", n } },

    ["Camera.SetProjectionMode"] =   { { "camera", "Camera" }, { "projectionMode", {s, "userdata", n} } },
    ["Camera.Set"] =                 { { "camera", "Camera" }, _p },
    ["Camera.GetPixelsToUnits"] =    { { "camera", "Camera" } },
    ["Camera.GetUnitsToPixels"] =    { { "camera", "Camera" } },
    ["Camera.GetBaseDistance"] =     { { "camera", "Camera" } },
    ["Camera.IsPositionInFrustum"] = { { "camera", "Camera" }, { "position", v3 } },
    ["Camera.WorldToScreenPoint"] =  { { "camera", "Camera" }, { "position", v3 } },
    ["Camera.GetFOV"] =  { { "camera", "Camera" } },
} )

--------------------------------------------------------------------------------
-- Vector2

Vector2 = {}
Vector2.__index = Vector2
setmetatable( Vector2, { __call = function(Object, ...) return Object.New(...) end } )
Daneel.Config.objectsByType.Vector2 = Vector2

function Vector2.__tostring(vector2)
    return "Vector2: { x="..vector2.x..", y="..vector2.y.." }"
end

--- Creates a new Vector2 intance.
-- @param x (number, table or Vector2) The vector's x component, or a table that contains "x" and "y" components.
-- @param y (number) [optional] The vector's y component. If nil, will be equal to x.
-- @return (Vector2) The new instance.
function Vector2.New(x, y)
    local vector = setmetatable( { x = x, y = y }, Vector2 )
    if type( x ) == "table" then
        vector.x = x.x
        vector.y = x.y
    elseif y == nil then
        vector.y = x
    end
    return vector
end

--- Return the length of the vector.
-- @param vector (Vector2) The vector.
-- @return (number) The length.
function Vector2.GetLength( vector )
    return math.sqrt( vector.x^2 + vector.y^2 )
end

--- Return the squared length of the vector.
-- @param vector (Vector2) The vector.
-- @return (number) The squared length.
function Vector2.GetSqrLength( vector )
    return vector.x^2 + vector.y^2
end

--- Return a copy of the provided vector, normalized.
-- @param vector (Vector2) The vector to normalize.
-- @return (Vector2) A copy of the vector, normalized.
function Vector2.Normalized( vector )
    return Vector2.New( vector.x, vector.y ):Normalize()
end

--- Normalize the provided vector in place (makes its length equal to 1).
-- @param vector (Vector2) The vector to normalize.
function Vector2.Normalize( vector )
    local length = vector:GetLength()
    if length ~= 0 then
        vector = vector / length
    end
end

--- Allow to add two Vector2 by using the + operator.
-- Ie : vector1 + vector2
-- @param a (Vector2) The left member.
-- @param b (Vector2) The right member.
-- @return (Vector2) The new vector.
function Vector2.__add(a, b)
    return Vector2.New(a.x + b.x, a.y + b.y)
end

--- Allow to substract two Vector2 by using the - operator.
-- Ie : vector1 - vector2
-- @param a (Vector2) The left member.
-- @param b (Vector2) The right member.
-- @return (Vector2) The new vector.
function Vector2.__sub(a, b)
    return Vector2.New(a.x - b.x, a.y - b.y)
end

--- Allow to multiply two Vector2 or a Vector2 and a number by using the * operator.
-- @param a (Vector2 or number) The left member.
-- @param b (Vector2 or number) The right member.
-- @return (Vector2) The new vector.
function Vector2.__mul(a, b)
    local newVector = nil
    if type(a) == "number" then
        newVector = Vector2.New(a * b.x, a * b.y)
    elseif type(b) == "number" then
        newVector = Vector2.New(a.x * b, a.y * b)
    else
        newVector = Vector2.New(a.x * b.x, a.y * b.y)
    end
    return newVector
end

--- Allow to divide two Vector2 or a Vector2 and a number by using the / operator.
-- @param a (Vector2 or number) The numerator.
-- @param b (Vector2 or number) The denominator. Can't be equal to 0.
-- @return (Vector2) The new vector.
function Vector2.__div(a, b)
    local errorHead = "Vector2.__div(a, b) : "
    local newVector = nil
    if type(a) == "number" then
        if b.x == 0 or b.y == 0 then
            error(errorHead.."One of the components of the denominator is equal to 0. Can't divide by 0 !", a, b)
        end
        newVector = Vector2.New(a / b.x, a / b.y)
    elseif type(b) == "number" then
        if b == 0 then
            error(errorHead.."The denominator is equal to 0 ! Can't divide by 0 !", a, b)
        end
        newVector = Vector2.New(a.x / b, a.y / b)
    else
        if b.x == 0 or b.y == 0 then
            error(errorHead.."One of the components of the denominator is equal to 0. Can't divide by 0 !", a, b)
        end
        newVector = Vector2.New(a.x / b.x, a.y / b.y)
    end
    return newVector
end

--- Allow to inverse a vector2 using the - operator.
-- @param vector (Vector2) The vector.
-- @return (Vector2) The new vector.
function Vector2.__unm(vector)
    return Vector2.New(-vector.x, -vector.y)
end

--- Allow to raise a Vector2 to a power using the ^ operator.
-- @param vector (Vector2) The vector.
-- @param exp (number) The power to raise the vector to.
-- @return (Vector2) The new vector.
function Vector2.__pow(vector, exp)
    return Vector2.New(vector.x ^ exp, vector.y ^ exp)
end

--- Allow to check for the equality between two Vector2 using the == comparison operator.
-- @param a (Vector2) The left member.
-- @param b (Vector2) The right member.
-- @return (boolean) True if the same components of the two vectors are equal (a.x=b.x and a.y=b.y)
function Vector2.__eq(a, b)
    return ((a.x == b.x) and (a.y == b.y))
end

--- Returns a string representation of the vector's component's values.
-- ie: For a vector {-6.5,10}, the returned string would be "-6.5 10".
-- Such string can be converted back to a vector with string.tovector()
-- @param vector (Vector2) The vector.
-- @return (string) The string.
function Vector2.ToString( vector )
    for i, comp in pairs({"x", "y"}) do
        if tostring(vector[comp]) == "-0" then
            vector[comp] = 0
        end
    end
    return vector.x.." "..vector.y
end

--------------------------------------------------------------------------------
-- Vector3

Vector3.tostringRoundValue = 3
Vector3.__tostring = function( vector )
    local roundValue = Vector3.tostringRoundValue
    if roundValue ~= nil and roundValue >= 0 then
        return "Vector3: { x="..math.round( vector.x, roundValue )..", y="..math.round( vector.y, roundValue )..", z="..math.round( vector.z, roundValue ).." }"
    else
        return "Vector3: { x="..vector.x..", y="..vector.y..", z="..vector.z.." }"
    end
end

--- Returns a new Vector3.
-- @param x (number, Vector3 or Vector2) [optional] The vector's x component.
-- @param y (number or Vector2) [optional] The vector's y component.
-- @param z (number) [optional] The vector's z component.
function Vector3.New( x, y, z, z2 )
    if x == Vector3 then -- when called like Vector3:New( x, y, z )
        x = y
        y = z
        z = z2
    end
    if type(x) == "table" then -- x is vector2 or vector3
        if x.z == nil then -- vector2
            y = x.y
            x = x.x
        else -- vector3
            y = x.y
            z = x.z
            x = x.x
        end
    elseif type(y) == "table" then -- x is a number, y is a vector2
        z = y.y
        y = y.x
    end
    x = x or 0
    y = y or x
    z = z or y
    return setmetatable( { x=x, y=y, z=z }, Vector3 )
end

--- Returns the length of the provided vector
-- @param vector (Vector3) The vector.
-- @return (number) The length.
function Vector3.GetLength( vector )
  return math.sqrt( vector.x ^ 2 + vector.y ^ 2 + vector.z ^ 2 )
end

--- Return the squared length of the vector.
-- @param vector (Vector3) The vector.
-- @return (number) The squared length.
function Vector3.GetSqrLength( vector )
  return vector.x ^ 2 + vector.y ^ 2 + vector.z ^ 2
end

--- Returns a string representation of the vector's component's values.
-- ie: For a vector {-6.5,10,2.1}, the returned string would be "-6.5 10 2.1".
-- Such string can be converted back to a vector with string.tovector()
-- @param vector (Vector3) The vector.
-- @return (string) The string.
function Vector3.ToString( vector )
    for i, comp in pairs({"x", "y", "z"}) do
        if tostring(vector[comp]) == "-0" then
            vector[comp] = 0
        end
    end
    return vector.x.." "..vector.y.." "..vector.z
end

--- Convert a string representation of a vector component's values to a Vector3 or a Vector2.
-- ie: For a string "-6.5 10 2.1", the returned vector would be {-6.5, 10, 2.1}.
-- Such string can be created from a vector2 or Vector3 with Vector2.ToString() or Vector3.ToString().
-- @param sVector (string) The vector as a string, each component's value being separated by a space.
-- @return (Vector3 or vector2) The vector.
function string.tovector( sVector )
    local vector = Vector3:New(0)
    local keys = { "z", "y", "x" }
    for match in string.gmatch( sVector, "[0-9.-]+" ) do
        local comp = table.remove( keys )
        if comp ~= nil then
            vector[ comp ] = tonumber(match)
        else
            break
        end
    end
    if table.remove( keys ) == "z" then
        setmetatable( vector, Vector2 )
        vector.z = nil
    end
    return vector
end

table.mergein( Daneel.Debug.functionArgumentsInfo, {
    ["Vector2.New"] = { { "x", { s, n, t, v2, v3 } }, { "y", { s, n }, isOptional = true } },
    ["Vector2.GetLength"] = { { "vector", v2 } },
    ["Vector2.GetSqrLength"] = { { "vector", v2 } },
    ["Vector2.Normalized"] = { { "vector", v2 } },
    ["Vector2.Normalize"] = { { "vector", v2 } },
    ["Vector2.__add"] = { { "a", v2 }, { "b", v2 } },
    ["Vector2.__sub"] = { { "a", v2 }, { "b", v2 } },
    ["Vector2.__mul"] = { { "a", { n, v2 } }, { "b", { n, v2 } } },
    ["Vector2.__div"] = { { "a", { n, v2 } }, { "b", { n, v2 } } },
    ["Vector2.__unm"] = { { "vector", v2 } },
    ["Vector2.__pow"] = { { "vector", v2 }, { "exp", "number" } },
    ["Vector2.__add"] = { { "a", v2 }, { "b", v2 } },

    ["Vector3.GetLength"] = { { "vector", v3 } },
    ["Vector3.GetSqrLength"] = { { "vector", v3 } },
    ["Vector3.ToString"] = { { "vector", v3 } },
    ["string.tovector"] = { { "sVector", s } },
} )

--------------------------------------------------------------------------------

CraftStudio.Input.oGetMousePosition = CraftStudio.Input.GetMousePosition
--- Return the mouse position on screen coordinates {x, y}
-- @return (Vector2) The on-screen mouse position.
function CraftStudio.Input.GetMousePosition()
    return setmetatable( CraftStudio.Input.oGetMousePosition(), Vector2 )
end

CraftStudio.Input.oGetMouseDelta = CraftStudio.Input.GetMouseDelta
--- Return the mouse delta (the variation of position) since the last frame.
-- Positive x is right, positive y is bottom.
-- @return (Vector2) The position's delta.
function CraftStudio.Input.GetMouseDelta()
    return setmetatable( CraftStudio.Input.oGetMouseDelta(), Vector2 )
end

CraftStudio.Input.isMouseLocked = false

CraftStudio.Input.oLockMouse = CraftStudio.Input.LockMouse
function CraftStudio.Input.LockMouse()
    CraftStudio.Input.isMouseLocked = true
    CraftStudio.Input.oLockMouse()
end

CraftStudio.Input.oUnlockMouse = CraftStudio.Input.UnlockMouse
function CraftStudio.Input.UnlockMouse()
    CraftStudio.Input.isMouseLocked = false
    CraftStudio.Input.oUnlockMouse()
end

--- Toggle the locked state of the mouse, which can be accessed via the CraftStudio.Input.isMouseLocked property.
function CraftStudio.Input.ToggleMouseLock()
    if CraftStudio.Input.isMouseLocked == true then
        CraftStudio.Input.UnlockMouse()
    else
        CraftStudio.Input.LockMouse()
    end
end

--------------------------------------------------------------------------------

CraftStudio.Screen.oSetSize = CraftStudio.Screen.SetSize
--- Sets the size of the screen, in pixels.
-- @param x (number or table) The width of the screen or a table containing the width and height as x and and y components.
-- @param y (number) [optional] The height of the screen (has no effect when the "x" argument is a table).
function CraftStudio.Screen.SetSize( x, y )
    if type( x ) == "table" then
        y = x.y
        x = x.x
    end
    CraftStudio.Screen.oSetSize( x, y )
    CraftStudio.Screen.GetSize() -- reset aspect ratio. Done after SetSize() so that the aspecty ratio doesn't change if the window is not rezisable
end

CraftStudio.Screen.oGetSize = CraftStudio.Screen.GetSize
--- Return the size of the screen, in pixels.
-- @return (Vector2) The screen's size.
function CraftStudio.Screen.GetSize()
    local screenSize = CraftStudio.Screen.oGetSize()
    CraftStudio.Screen.aspectRatio = screenSize.x / screenSize.y
    return setmetatable( screenSize, Vector2 )
end
CraftStudio.Screen.GetSize() -- set aspect ratio

--------------------------------------------------------------------------------
-- RaycastHit

RaycastHit = {}
RaycastHit.__index = RaycastHit
setmetatable( RaycastHit, { __call = function(Object, ...) return Object.New(...) end } )
Daneel.Config.objectsByType.RaycastHit = RaycastHit

-- Allow to access the "hitLocation" property on raycastHits for backward compatibility.
-- The property has been renamed "hitPosition" since v1.5.0.
RaycastHit.__index = function( raycastHit, key )
    if key == "hitLocation" then
        return raycastHit.hitPosition
    end
end

function RaycastHit.__tostring( instance )
    local msg = "RaycastHit: { "
    local first = true
    for key, value in pairs( instance ) do
        if first then
            msg = msg..key.."="..tostring( value )
            first = false
        else
            msg = msg..", "..key.."="..tostring( value )
        end
    end
    return msg.." }"
end

Daneel.Debug.functionArgumentsInfo["RaycastHit.New"] = { { "params", defaultValue = {} } }
--- Create a new RaycastHit
-- @return (RaycastHit) The raycastHit.
function RaycastHit.New( params )
    if params == nil then params = {} end
    return setmetatable( params, RaycastHit )
end

--------------------------------------------------------------------------------
-- Ray

setmetatable( Ray, { __call = function(Object, ...) return Object:New(...) end } )

--- Check the collision of the ray against the provided set of game objects.
-- @param ray (Ray) The ray.
-- @param gameObjects (table) The set of game objects to cast the ray against.
-- @param sortByDistance (boolean) [default=false] Sort the raycastHit by increasing distance in the returned table.
-- @return (table) A table of RaycastHits (will be empty if the ray didn't intersects anything).
function Ray.Cast( ray, gameObjects, sortByDistance )
    local hits = {}
    for i, gameObject in pairs( gameObjects ) do
        if gameObject.inner ~= nil then
            local raycastHit = ray:IntersectsGameObject( gameObject )
            if raycastHit ~= nil then
                table.insert( hits, raycastHit )
            end
        end
    end
    if sortByDistance == true then
        hits = table.sortby( hits, "distance" )
    end
    return hits
end

--- Check if the ray intersects the specified game object.
-- @param ray (Ray) The ray.
-- @param gameObjectNameOrInstance (string or GameObject) The game object instance or name.
-- @return (RaycastHit) A raycastHit if there was a collision, or nil.
function Ray.IntersectsGameObject( ray, gameObjectNameOrInstance )
    local gameObject = GameObject.Get( gameObjectNameOrInstance, true )
    local raycastHit = nil
    if gameObject.inner == nil then
        -- should not happend since CheckArgType() returns an error when the game object is dead
        return nil
    end
    local component = gameObject.modelRenderer
    if component ~= nil then
        raycastHit = ray:IntersectsModelRenderer( component, true )
    end
    if raycastHit == nil then
        component = gameObject.mapRenderer
        if component ~= nil then
            raycastHit = ray:IntersectsMapRenderer( component, true )
        end
    end
    if raycastHit == nil then
        component = gameObject.textRenderer
        if component ~= nil then
            raycastHit = ray:IntersectsTextRenderer( component, true )
        end
    end
    if raycastHit ~= nil then
        raycastHit.gameObject = gameObject
    end
    return raycastHit
end

Ray.oIntersectsPlane = Ray.IntersectsPlane
-- Check if the ray intersects the provided plane and returns the distance of intersection or a raycastHit.
-- @param ray (Ray) The ray.
-- @param plane (Plane) The plane.
-- @param returnRaycastHit (boolean) [default=false] Tell if the hit infos must be returned as a raycastHit.
-- @return (number or RaycastHit) The distance of intersection (if any) or a raycastHit with the 'distance' and 'hitPosition' properties (if any).
function Ray.IntersectsPlane( ray, plane, returnRaycastHit )
    local distance = Ray.oIntersectsPlane( ray, plane )
    if returnRaycastHit and distance ~= nil then
        return RaycastHit.New({
            distance = distance,
            hitPosition = ray.position + ray.direction * distance,
            hitObject = plane,
        })
    end
    return distance
end

Ray.oIntersectsModelRenderer = Ray.IntersectsModelRenderer
-- Check if the ray intersects the provided modelRenderer.
-- @param ray (Ray) The ray.
-- @param modelRenderer (ModelRenderer) The modelRenderer.
-- @param returnRaycastHit (boolean) [default=false] Tell if the hit infos must be returned as a raycastHit.
-- @return (number or RaycastHit) The distance of intersection (if any) or a raycastHit with the 'distance', 'normal' and 'hitPosition' properties (if any).
-- @return (Vector3) If 'returnRaycastHit' argument is false : the normal of the hit face, or nil
function Ray.IntersectsModelRenderer( ray, modelRenderer, returnRaycastHit )
    local distance, normal = Ray.oIntersectsModelRenderer( ray, modelRenderer )
    if returnRaycastHit and distance ~= nil then
        return RaycastHit.New({
            distance = distance,
            normal = normal,
            hitPosition = ray.position + ray.direction * distance,
            hitObject = modelRenderer,
            gameObject = modelRenderer.gameObject,
        })
    end
    return distance, normal
end

Ray.oIntersectsMapRenderer = Ray.IntersectsMapRenderer
-- Check if the ray intersects the provided mapRenderer.
-- @param ray (Ray) The ray.
-- @param mapRenderer (MapRenderer) The map renderer.
-- @param returnRaycastHit (boolean) [default=false] Tell if the hit infos must be returned as a raycastHit.
-- @return (number or RaycastHit) The distance of intersection (if any) or a raycastHit with the 'distance', 'normal', 'hitBlockLocation', 'adjacentBlockLocation' and 'hitPosition' properties (if any).
-- @return (Vector3) If 'returnRaycastHit' argument is false : the normal of the hit face, or nil
-- @return (Vector3) If 'returnRaycastHit' argument is false : the location of the block hit, or nil
-- @return (Vector3) If 'returnRaycastHit' argument is false : the location of the adjacent block, or nil
function Ray.IntersectsMapRenderer( ray, mapRenderer, returnRaycastHit )
    local distance, normal, hitBlockLocation, adjacentBlockLocation = Ray.oIntersectsMapRenderer( ray, mapRenderer )
    if hitBlockLocation ~= nil then
        setmetatable( hitBlockLocation, Vector3 )
    end
    if adjacentBlockLocation ~= nil then
        setmetatable( adjacentBlockLocation, Vector3 )
    end
    if returnRaycastHit and distance ~= nil then
        return RaycastHit.New({
            distance = distance,
            normal = normal,
            hitBlockLocation = hitBlockLocation,
            adjacentBlockLocation = adjacentBlockLocation,
            hitPosition = ray.position + ray.direction * distance,
            hitObject = mapRenderer,
            gameObject = mapRenderer.gameObject,
        })
    end
    return distance, normal, hitBlockLocation, adjacentBlockLocation
end

Ray.oIntersectsTextRenderer = Ray.IntersectsTextRenderer
-- Check if the ray intersects the provided textRenderer.
-- @param ray (Ray) The ray.
-- @param textRenderer (TextRenderer) The textRenderer.
-- @param returnRaycastHit (boolean) [default=false] Tell if the hit infos must be returned as a raycastHit.
-- @return (number or RaycastHit) The distance of intersection (if any) or a raycastHit with the 'distance', 'normal' and 'hitPosition' properties (if any).
-- @return (Vector3) If 'returnRaycastHit' argument is false : the normal of the hit face, or nil
function Ray.IntersectsTextRenderer( ray, textRenderer, returnRaycastHit )
    local distance, normal = Ray.oIntersectsTextRenderer( ray, textRenderer )
    if returnRaycastHit and distance ~= nil then
        return RaycastHit.New({
            distance = distance,
            normal = normal,
            hitPosition = ray.position + ray.direction * distance,
            hitObject = textRenderer,
            gameObject = textRenderer.gameObject,
        })
    end
    return distance, normal
end

--------------------------------------------------------------------------------
-- Scene

--- Alias of CraftStudio.LoadScene().
-- Schedules loading the specified scene after the current tick (frame) (1/60th of a second) has completed.
-- When the new scene is loaded, all of the current scene's game objects will be removed.
-- Calling this function doesn't immediately stops the calling function. As such, you might want to add a return statement afterwards.
-- @param sceneNameOrAsset (string or Scene) The scene name or asset.
function Scene.Load( sceneNameOrAsset )
    CraftStudio.LoadScene( sceneNameOrAsset )
end

CraftStudio.oLoadScene = CraftStudio.LoadScene
--- Schedules loading the specified scene after the current tick (1/60th of a second) has completed.
-- When the new scene is loaded, all of the current scene's game objects will be removed.
-- Calling this function doesn't immediately stops the calling function. As such, you might want to add a return statement afterwards.
-- @param sceneNameOrAsset (string or Scene) The scene name or asset.
function CraftStudio.LoadScene( sceneNameOrAsset )
    local scene = Asset.Get( sceneNameOrAsset, "Scene", true )
    Daneel.Event.Fire( "OnNewSceneWillLoad", scene )
    Daneel.Event.events = {} -- do this here to make sure that any events that might be fired from OnSceneLoad-catching function are indeed fired
    Scene.current = scene
    CraftStudio.oLoadScene( scene )
end

--- Alias of CraftStudio.AppendScene().
-- Appends the specified scene to the game by instantiating all of its game objects. Contrary to CraftStudio.LoadScene, this doesn't unload the current scene nor waits for the next tick: it happens right away.
-- You can optionally specify a parent game object which will be used as a root for adding all game objects.
-- Returns the game object appended if there was only one root game object in the provided scene.
-- @param sceneNameOrAsset (string or Scene) The scene name or asset.
-- @param parentNameOrInstance (string or GameObject) [optional] The parent game object name or instance.
-- @return (GameObject) The appended game object, or nil.
function Scene.Append( sceneNameOrAsset, parentNameOrInstance )
    local scene = Asset.Get( sceneNameOrAsset, "Scene", true )
    local parent = nil
    if parentNameOrInstance ~= nil then
        parent = GameObject.Get( parentNameOrInstance, true )
    end
    return CraftStudio.AppendScene( scene, parent )
end

--------------------------------------------------------------------------------

CraftStudio.oDestroy = CraftStudio.Destroy
--- Removes the specified game object (and all of its descendants) or the specified component from its game object.
-- You can also optionally specify a dynamically loaded asset for unloading (See Map.LoadFromPackage ).
-- Sets the 'isDestroyed' property to 'true' and fires the 'OnDestroy' event on the object.
-- @param object (GameObject, a component or a dynamically loaded asset) The game object, component or a dynamically loaded asset (like a map loaded with Map.LoadFromPackage).
function CraftStudio.Destroy( object )
    if type( object ) == "table" then
        Daneel.Event.Fire( object, "OnDestroy", object )
        Daneel.Event.StopListen( object ) -- remove from listener list
        object.isDestroyed = true
    end
    CraftStudio.oDestroy( object )
end

local _ray = { "ray", "Ray" }
local _returnraycasthit = { "returnRaycastHit", defaultValue = false }

table.mergein( Daneel.Debug.functionArgumentsInfo, {
    ["Ray.Cast"] =                    { _ray, { "gameObjects", t }, { "sortByDistance", defaultValue = false } },
    ["Ray.IntersectsGameObject"] =    { _ray, { "gameObjectNameOrInstance", { s, go } }, _returnraycasthit },
    ["Ray.IntersectsPlane"] =         { _ray, { "plane", "Plane" }, _returnraycasthit },
    ["Ray.IntersectsModelRenderer"] = { _ray, { "modelRenderer", "ModelRenderer" }, _returnraycasthit },
    ["Ray.IntersectsMapRenderer"] =   { _ray, { "mapRenderer", "MapRenderer" }, _returnraycasthit },
    ["Ray.IntersectsTextRenderer"] =  { _ray, { "textRenderer", "TextRenderer" }, _returnraycasthit },

    ["Scene.Load"] =            { { "sceneNameOrAsset", { s, "Scene" } } },
    ["CraftStudio.LoadScene"] = { { "sceneNameOrAsset", { s, "Scene" } } },
    ["Scene.Append"] =          { { "sceneNameOrAsset", { s, "Scene" } }, { "parentNameOrInstance", { s, go }, isOptional = true } },

    ["CraftStudio.Destroy"] = { { "object" } },
} )

--------------------------------------------------------------------------------
-- Storage

CraftStudio.Storage.oSave = CraftStudio.Storage.Save
--- Store locally on the computer the provided data under the provided identifier.
-- @param identifier (string) The identifier of the data.
-- @param data (mixed) The data to store. May be nil.
-- @param callback (function) [optional] The function called when the save has completed. The potential error (as a string) is passed to the callback first and only argument (nil if no error).
function CraftStudio.Storage.Save( identifier, data, callback )
    if data ~= nil and type( data ) ~= "table" then
        data = {
            value = data,
            isSavedByDaneel = true
        }
    end
    CraftStudio.Storage.oSave( identifier, data, function( _error )
        if _error ~= nil and Daneel.Config.debug.enableDebug == true then
            table.print( data )
            print( "CS.Storage.Save( identifier, data[, callback] ) : Error saving with identifier, data (printed above) and error : ", identifier, _error.message )
        end
        if callback ~= nil then
            callback( _error )
        end
    end )
end

CraftStudio.Storage.oLoad = CraftStudio.Storage.Load
--- Load data stored locally on the computer under the provided identifier. The load operation may not be instantaneous.
-- @param identifier (string) The identifier of the data.
-- @param defaultValue (mixed) [optional] The value that is returned if no data (and no error) is found.
-- @param callback (function) The function called when the data is loaded. The the potential error (nil if no error) and data (of mixed type) are passed as first and second argument, respectively.
function CraftStudio.Storage.Load( identifier, defaultValue, callback )
    if callback == nil and type( defaultValue ) == "function" then
        callback = defaultValue
        defaultValue = nil
    end
    CraftStudio.Storage.oLoad( identifier, function( _error, data )
        if _error ~= nil and Daneel.Config.debug.enableDebug == true then
            print( "CS.Storage.Load( identifier[, defaultValue], callback ) : Error loading with identifier, default value and error", identifier, defaultValue, _error.message )
        end
        if data ~= nil and data.value ~= nil and data.isSavedByDaneel == true then
            data = data.value
        end
        if _error == nil and data == nil then
            data = defaultValue
        end
        callback( _error, data )
    end )
end

table.mergein( Daneel.Debug.functionArgumentsInfo, {
    ["CraftStudio.Storage.Save"] = { { "identifier", s }, { "data", isOptional = true }, { "callback", "function", isOptional = true } },
    ["CraftStudio.Storage.Load"] = { { "identifier", s }, { "defaultValue", isOptional = true }, { "callback", "function", isOptional = true } }
} )

--------------------------------------------------------------------------------
-- GAMEOBJECT

setmetatable( GameObject, { __call = function(Object, ...) return Object.New(...) end } )

-- returns something like "GameObject: 123456789: 'MyName'"
function GameObject.__tostring( gameObject )
    if rawget( gameObject, "inner" ) == nil then
        return "Destroyed GameObject: "..tostring(gameObject:GetId())..": '"..tostring(gameObject._name).."': "..Daneel.Debug.ToRawString( gameObject )
        -- _name is set when the object is destroyed in GameObject.Destroy()
    end
    return "GameObject: "..gameObject:GetId()..": '"..gameObject:GetName().."'"
end

-- Dynamic getters
function GameObject.__index( gameObject, key )
    if GameObject[ key ] ~= nil then
        return GameObject[ key ]
    end
    if type( key ) == "string" then
        -- or the name of a getter
        local ucKey = string.ucfirst( key )
        if key ~= ucKey then
            local funcName = "Get" .. ucKey
            if GameObject[ funcName ] ~= nil then
                return GameObject[ funcName ]( gameObject )
            end
        end
    end
    return nil
end

-- Dynamic setters
function GameObject.__newindex( gameObject, key, value )
    local ucKey = key
    if type( key ) == "string" then
        ucKey = string.ucfirst( key )
    end
    if key ~= ucKey and key ~= "transform" then -- first letter lowercase
        -- check about Transform is needed because CraftStudio.CreateGameObject() set the transfom variable on new game objects
        -- 26/09/2013 And so what ? If SetTransform() doesn't exist, it's not an issue
        local funcName = "Set" .. ucKey
        -- ie: variable "name" call "SetName"
        if GameObject[ funcName ] ~= nil then
            return GameObject[ funcName ]( gameObject, value )
        end
    end
    rawset( gameObject, key, value )
end

--------------------------------------------------------------------------------

--- Create a new game object and optionally initialize it.
-- @param name (string) The game object name.
-- @param params (table or GameObject) [optional] A table with parameters to initialize the new game object with, or the parent gameO object to attach to.
-- @return (GameObject) The new game object.
function GameObject.New( name, params )
    local gameObject = nil
    if params ~= nil and getmetatable( params ) == GameObject then
        gameObject = CraftStudio.CreateGameObject( name, params )
    else
        gameObject = CraftStudio.CreateGameObject( name )
    end
    if params ~= nil then
        gameObject:Set(params)
    end
    return gameObject
end

--- Create a new game object with the content of the provided scene and optionally initialize it.
-- @param name (string) The game object name.
-- @param sceneNameOrAsset (string or Scene) The scene name or scene asset.
-- @param params (table or GameObject) [optional] A table with parameters to initialize the new game object with, or the parent gameO object to attach to..
-- @return (GameObject) The new game object.
function GameObject.Instantiate(name, sceneNameOrAsset, params)
    local scene = Asset.Get(sceneNameOrAsset, "Scene", true)
    local gameObject = nil
    if params ~= nil and getmetatable( params ) == GameObject then
        gameObject = CraftStudio.Instantiate( name, scene, params )
    else
        gameObject = CraftStudio.Instantiate( name, scene )
    end
    if params ~= nil then
        gameObject:Set( params )
    end
    return gameObject
end

--- Apply the content of the params argument to the provided game object.
-- @param gameObject (GameObject) The game object.
-- @param params (table) A table of parameters to set the game object with.
function GameObject.Set( gameObject, params )
    local errorHead = "GameObject.Set( gameObject[, params] ) :"
    if params.parent ~= nil then
        -- do that first so that setting a local position works
        gameObject:SetParent( params.parent )
        params.parent = nil
    end

    if params.transform ~= nil then
        gameObject.transform:Set( params.transform )
        params.transform = nil
    end

    -- components
    for i, componentType in pairs( Daneel.Config.componentTypes ) do
        if componentType ~= "ScriptedBehavior" and componentType ~= "Transform" then
            local lcComponentType = string.lcfirst( componentType )
            local componentParams = params[ lcComponentType ]

            if componentParams ~= nil then
                params[ lcComponentType ] = nil
                Daneel.Debug.CheckArgType( componentParams, "params."..lcComponentType, "table", errorHead )

                local component = gameObject[ lcComponentType ]
                if component == nil then -- can work for built-in components when their property on the game object has been unset for some reason
                    component = gameObject:GetComponent( componentType )
                end
                if component == nil then
                    component = gameObject:AddComponent( componentType, componentParams )
                else
                    component:Set( componentParams )
                end
            end
        end
    end

    -- all other keys/values
    for key, value in pairs( params ) do
        if key == "tags"  then
            gameObject:RemoveTag()
            gameObject:AddTag( value )
        else
            gameObject[key] = value
        end
    end
end

--------------------------------------------------------------------------------
-- Miscellaneous

--- Alias of CraftStudio.FindGameObject(name).
-- Get the first game object with the provided name.
-- @param name (string) The game object name.
-- @param errorIfGameObjectNotFound (boolean) [default=false] Throw an error if the game object was not found (instead of returning nil).
-- @return (GameObject) The game object or nil if none is found.
function GameObject.Get( name, errorIfGameObjectNotFound )
    if getmetatable(name) == GameObject then
        return name
    end

    local errorHead = "GameObject.Get( name[, errorIfGameObjectNotFound] ) : "
    local names = string.split( name, "." )
    local gameObject = CraftStudio.FindGameObject( names[1] )
    if gameObject == nil and errorIfGameObjectNotFound == true then
        error( errorHead.."GameObject with name '" .. names[1] .. "' (from '" .. name .. "') was not found." )
    end

    if gameObject ~= nil then
        local originalName = name
        local fullName = table.remove( names, 1 )

        for i, name in ipairs( names ) do
            gameObject = gameObject:GetChild( name )
            fullName = fullName .. "." .. name

            if gameObject == nil then
                if errorIfGameObjectNotFound == true then
                    error( errorHead.."GameObject with name '" .. fullName .. "' (from '" .. originalName .. "') was not found." )
                end
                break
            end
        end
    end
    return gameObject
end

--- Returns the game object's internal unique identifier.
-- @param gameObject (GameObject) The game object.
-- @return (number) The id.
function GameObject.GetId( gameObject )
    return Daneel.Utilities.GetId( gameObject )
end

GameObject.oSetParent = GameObject.SetParent
--- Set the game object's parent.
-- Optionaly carry over the game object's local transform instead of the global one.
-- @param gameObject (GameObject) The game object.
-- @param parentNameOrInstance (string or GameObject) [optional] The parent name or game object (or nil to remove the parent).
-- @param keepLocalTransform (boolean) [default=false] Carry over the game object's local transform instead of the global one.
function GameObject.SetParent( gameObject, parentNameOrInstance, keepLocalTransform )
    local parent = nil
    if parentNameOrInstance ~= nil then
        parent = GameObject.Get(parentNameOrInstance, true)
    end
    if keepLocalTransform == nil then
        keepLocalTransform = false
    end
    GameObject.oSetParent(gameObject, parent, keepLocalTransform)
end

--- Alias of GameObject.FindChild().
-- Find the first game object's child with the provided name.
-- If the name is not provided, it returns the first child.
-- @param gameObject (GameObject) The game object.
-- @param name (string) [optional] The child name (may be hyerarchy of names separated by dots).
-- @param recursive (boolean) [default=false] Search for the child in all descendants instead of just the first generation.
-- @return (GameObject) The child or nil if none is found.
function GameObject.GetChild( gameObject, name, recursive )
    if recursive == nil then
        recursive = false
    end
    local child = nil
    if name == nil then
        local children = gameObject:GetChildren()
        child = children[1]
    else
        local names = string.split( name, "." )
        for i, name in ipairs( names ) do
            gameObject = gameObject:FindChild( name, recursive )
            if gameObject == nil then
                break
            end
        end
        child = gameObject
    end
    return child
end

GameObject.oGetChildren = GameObject.GetChildren
--- Get all descendants of the game object.
-- @param gameObject (GameObject) The game object.
-- @param recursive (boolean) [default=false] Look for all descendants instead of just the first generation.
-- @param includeSelf (boolean) [default=false] Include the game object in the children.
-- @return (table) The children.
function GameObject.GetChildren( gameObject, recursive, includeSelf )
    local allChildren = GameObject.oGetChildren( gameObject )
    if recursive then
        for i, child in ipairs( table.copy( allChildren ) ) do
            allChildren = table.merge( allChildren, child:GetChildren( true ) )
        end
    end
    if includeSelf then
        table.insert( allChildren, 1, gameObject )
    end
    return allChildren
end

--- Search the ancestors of the provided game object. It returns the game object that match the condition in the search function.
-- The search function receive a game object as the only argument.
-- The search function must return true in order for GetInAncestors() to return the searched game object.
-- @param gameObject (GameObject) The game object.
-- @param searchFunction (function) The search function.
-- @return (GameObject) The searched game object, or nil.
function GameObject.GetInAncestors( gameObject, searchFunction )
    local parent = gameObject:GetParent()
    if parent == nil then
        return
    end
    if searchFunction( parent ) == true then
        return parent
    end
    return parent:GetInAncestors( searchFunction )
end

GameObject.oSendMessage = GameObject.SendMessage
--- Tries to call a method with the provided name on all the scriptedBehaviors attached to the game object.
-- The data argument can be nil or a table you want the method to receive as its first (and only) argument.
-- If none of the scripteBehaviors attached to the game object or its children have a method matching the provided name, nothing happens.
-- @param gameObject (GameObject) The game object.
-- @param functionName (string) The method name.
-- @param data (table) [optional] The data to pass along the method call.
function GameObject.SendMessage(gameObject, functionName, data)
    if Daneel.Config.debug.enableDebug then
        -- prevent an error of type "La référence d'objet n'est pas définie à une instance d'un objet." to stops the script that sends the message
        local success = Daneel.Debug.Try( function()
            GameObject.oSendMessage( gameObject, functionName, data )
        end )

        if not success then
            local dataText = "No data"
            local length = 0
            if data ~= nil then
                length = table.getlength( data )
                dataText = "Data with "..length.." entries"
            end
            print( "GameObject.SendMessage( gameObject, functionName[, data] ) : Error sending message with parameters : ", gameObject, functionName, dataText )
            if length > 0 then
                table.print( data )
            end
        end
    else
        GameObject.oSendMessage( gameObject, functionName, data )
    end
end

--- Display or hide the game object. Act on the renderer's opacity or the transform's local position.
-- Sets the "isDisplayed" property to true or false and fire the "OnDisplay" event on the game object.
-- @param gameObject (GameObject) The game object.
-- @param value (boolean, number or Vector3) [default=true] Tell whether to display or hide the game object (as a boolean), or the opacity (as a number) or the local position (as a Vector3).
-- @param forceUseLocalPosition (boolean) [default=false] Tell whether to force to axt on the game object's local position even when it possess a renderer.
function GameObject.Display( gameObject, value, forceUseLocalPosition )
    local display = false
    if value ~= false and value ~= 0 then -- nil, true or non 0 value
        display = true
    end

    local valueType = type(value)
    if valueType == "boolean" then
        value = nil
    elseif valueType == "number" and forceUseLocalPosition == true then
        value = Vector3:New(value)
        valueType = "table"
    end  

    --
    local renderer = gameObject.textRenderer or gameObject.modelRenderer or gameObject.mapRenderer
    
    if renderer ~= nil and forceUseLocalPosition ~= true and valueType == "number" then
        if not display and gameObject.displayOpacity == nil then
            gameObject.displayOpacity = renderer:GetOpacity()
        end
        if display then
            value = value or gameObject.displayOpacity or 1
        else
            value = value or 0
        end
        renderer:SetOpacity( value )
    else
        if not display and gameObject.displayLocalPosition == nil then
            gameObject.displayLocalPosition = gameObject.transform:GetLocalPosition()
        end
        if display then
            value = value or gameObject.displayLocalPosition or Vector3:New(1)
        else
            value = value or Vector3:New(0,0,999)
        end
        gameObject.transform:SetLocalPosition( value )
    end

    gameObject.isDisplayed = display 
    Daneel.Event.Fire( gameObject, "OnDisplay", gameObject )
end

--- Destroy the game object at the end of this frame.
-- @param gameObject (GameObject) The game object.
function GameObject.Destroy( gameObject )
    for i, go in pairs( gameObject:GetChildren( true, true ) ) do -- recursive, include self
        go:RemoveTag()
    end
    for key, value in pairs( gameObject ) do
        if key ~= "inner" and type( value ) == "table" then -- in the Webplayer inner is a regular object, considered of type table and not userdata
            Daneel.Event.Fire( value, "OnDestroy", value )
        end
    end
    gameObject._name = gameObject:GetName() -- used by GameObject.__tostring()
    CraftStudio.Destroy( gameObject )
end

--------------------------------------------------------------------------------
-- Components

--- Add a component to the game object and optionally initialize it.
-- @param gameObject (GameObject) The game object.
-- @param componentType (string or Script) The component type, or script asset or path (can't be Transform or ScriptedBehavior).
-- @param params (string, Script or table) [optional] A table of parameters to initialize the new component with or, if componentType is 'ScriptedBehavior', the mandatory script name or asset.
-- @return (mixed) The component.
function GameObject.AddComponent( gameObject, componentType, params )
    local errorHead = "GameObject.AddComponent( gameObject, componentType[, params] ) : "
    componentType = Daneel.Debug.CheckArgValue( componentType, "componentType", Daneel.Config.componentTypes, errorHead, componentType )
    local component = nil

    if Daneel.Config.componentObjectsByType[ componentType ] == nil then
        -- componentType is not one of the component types
        -- it may be a script path, asset
        local script = Asset.Get( componentType, "Script" )
        if script == nil then
            error( errorHead.."Provided component type '"..tostring(componentType).."' is not one of the component types, nor a script asset or path." )
        end
        component = gameObject:CreateScriptedBehavior( script, params or {} )

    elseif Daneel.DefaultConfig().componentObjectsByType[ componentType ] ~= nil then
        -- built-in component type
        if componentType == "Transform" then
            error( errorHead.."Can't add a transform component because game objects may only have one transform." )
        elseif componentType == "ScriptedBehavior" then
            error( errorHead.."To add a scripted behavior, pass the script asset or path instead of 'ScriptedBehavior' as the 'componentType' argument." )
        end

        component = gameObject:CreateComponent( componentType )
        if params ~= nil then
            component:Set(params)
        end

    else -- custom component type
        local componentObject = Daneel.Config.componentObjectsByType[ componentType ]
        -- component object is never nil since componentType's value is checked at the beginning
        if type( componentObject.New ) == "function" then
            component = componentObject.New( gameObject, params )
        else
            error( errorHead.."Can't create custom component of type '"..componentType.."' because the component object does not provide a New() function." )
        end
    end

    Daneel.Event.Fire( gameObject, "OnNewComponent", component )
    return component
end

GameObject.oGetComponent = GameObject.GetComponent
--- Get the first component of the provided type attached to the game object.
-- @param gameObject (GameObject) The game object.
-- @param componentType (string or Script) The component type, or script asset or path.
-- @return (One of the component types) The component instance, or nil if none is found.
function GameObject.GetComponent( gameObject, componentType )
    local errorHead = "GameObject.GetComponent( gameObject, componentType ) : "
    componentType = Daneel.Debug.CheckArgValue( componentType, "componentType", Daneel.Config.componentTypes, errorHead, componentType )
    
    local lcComponentType = componentType
    if type( componentType ) == "string" then
        lcComponentType = string.lcfirst( componentType )
    end
    
    local component = nil
    if lcComponentType ~= "scriptedBehavior" then
        component = gameObject[ lcComponentType ]
    end
    if component == nil then
        if Daneel.DefaultConfig().componentObjectsByType[ componentType ] ~= nil then
            component = GameObject.oGetComponent( gameObject, componentType )
        elseif Daneel.Config.componentObjectsByType[ componentType ] == nil then -- not a custom component either
            local script = Asset.Get( componentType, "Script", true ) -- componentType is the script path or asset
            component = GameObject.oGetScriptedBehavior( gameObject, script )
        end
    end
    return component
end

GameObject.oGetScriptedBehavior = GameObject.GetScriptedBehavior
--- Get the provided scripted behavior instance attached to the game object.
-- @param gameObject (GameObject) The game object.
-- @param scriptNameOrAsset (string or Script) The script name or asset.
-- @return (ScriptedBehavior) The ScriptedBehavior instance.
function GameObject.GetScriptedBehavior( gameObject, scriptNameOrAsset )
    local script = Asset.Get( scriptNameOrAsset, "Script", true )
    return GameObject.oGetScriptedBehavior( gameObject, script )
end

--------------------------------------------------------------------------------
-- Tags

GameObject.Tags = {}

Daneel.modules.Tags = {
    Awake = function()
        GameObject.Tags = {}
    end
}

--- Returns the game object(s) that have all the provided tag(s).
-- @param tag (string or table) One or several tag(s) (as a string or table of strings).
-- @return (table) The game object(s) (empty if none is found).
function GameObject.GetWithTag( tag )
    local tags = tag
    if type( tags ) == "string" then
        tags = { tags }
    end

    local gameObjectsWithTag = {}
    local reindex = false

    for i, tag in pairs( tags ) do
        local gameObjects = GameObject.Tags[ tag ]
        if gameObjects ~= nil then
            for j, gameObject in pairs( gameObjects ) do
                if gameObject.inner ~= nil then
                    if gameObject:HasTag( tags ) and not table.containsvalue( gameObjectsWithTag, gameObject ) then
                        table.insert( gameObjectsWithTag, gameObject )
                    end
                else
                    gameObjects[ j ] = nil
                    reindex = true
                end
            end
            if reindex then
                GameObject.Tags[ tag ] = table.reindex( gameObjects )
                reindex = false
            end
        end
    end

    return gameObjectsWithTag
end

--- Returns the tag(s) of the provided game object.
-- @param gameObject (GameObject) The game object.
-- @return (table) The tag(s) (empty if the game object has no tag).
function GameObject.GetTags( gameObject )
    local tags = {}
    for tag, gameObjects in pairs( GameObject.Tags ) do
        if table.containsvalue( gameObjects, gameObject ) then
            table.insert( tags, tag )
        end
    end
    return tags
end

--- Add the provided tag(s) to the provided game object.
-- @param gameObject (GameObject) The game object.
-- @param tag (string or table) One or several tag(s) (as a string or table of strings).
function GameObject.AddTag( gameObject, tag )
    local tags = tag
    if type( tags ) == "string" then
        tags = { tags }
    end

    for i, tag in pairs( tags ) do
        if GameObject.Tags[ tag ] == nil then
            GameObject.Tags[ tag ] = { gameObject }
        elseif not table.containsvalue( GameObject.Tags[ tag ], gameObject ) then
            table.insert( GameObject.Tags[ tag ], gameObject )
        end
    end
end

--- Remove the provided tag(s) from the provided game object.
-- If the 'tag' argument is not provided, all tag of the game object will be removed.
-- @param gameObject (GameObject) The game object.
-- @param tag (string or table) [optional] One or several tag(s) (as a string or table of strings).
function GameObject.RemoveTag( gameObject, tag )
    local tags = tag
    if type( tags ) == "string" then
        tags = { tags }
    end

    for tag, gameObjects in pairs( GameObject.Tags ) do
        if tags == nil or table.containsvalue( tags, tag ) then
            table.removevalue( GameObject.Tags[ tag ], gameObject )
        end
    end
end

--- Tell whether the provided game object has all (or at least one of) the provided tag(s).
-- @param gameObject (GameObject) The game object.
-- @param tag (string or table) One or several tag (as a string or table of strings).
-- @param atLeastOneTag (boolean) [default=false] If true, returns true if the game object has AT LEAST one of the tag (instead of ALL the tag).
-- @return (boolean) True
function GameObject.HasTag( gameObject, tag, atLeastOneTag )
    local tags = tag
    if type(tags) == "string" then
        tags = { tags }
    end
    local hasTags = false
    if atLeastOneTag == true then
        for i, tag in pairs( tags ) do
            if GameObject.Tags[ tag ] ~= nil and table.containsvalue( GameObject.Tags[ tag ], gameObject ) then
                hasTags = true
                break
            end
        end
    else
        hasTags = true
        for i, tag in pairs( tags ) do
            if GameObject.Tags[ tag ] == nil or not table.containsvalue( GameObject.Tags[ tag ], gameObject ) then
                hasTags = false
                break
            end
        end
    end
    return hasTags
end

local _t = { "tag", {"string", "table"} }
local _go = { "gameObject", "GameObject" }

table.mergein( Daneel.Debug.functionArgumentsInfo, {
    ["GameObject.New"] =         { { "name", s }, { "params", { t, "GameObject" }, isOptional = true } },
    ["GameObject.Instantiate"] = { { "name", s }, { "sceneNameOrAsset", { s, "Scene" } }, { "params", { t, "GameObject" }, isOptional = true } },
    ["GameObject.Set"] =         { _go, _p },
    ["GameObject.Get"] =         { { "name", { s, "GameObject" } }, { "errorIfGameObjectNotFound", defaultValue = false } },
    ["GameObject.Destroy"] =     { _go },

    ["GameObject.SetParent"] =          { _go, { "parentNameOrInstance", { s, "GameObject" }, isOptional = true }, { "keepLocalTransform", defaultValue = false } },
    ["GameObject.GetChild"] =           { _go, { "name", s, isOptional = true }, { "recursive", defaultValue = false } },
    ["GameObject.GetChildren"] =        { _go, { "recursive", defaultValue = false }, { "includeSelf", defaultValue = false } },
    ["GameObject.GetInAncestors"] =     { _go, { "searchFunction", "function" } },

    ["GameObject.SendMessage"] =      { _go, { "functionName", s }, { "data", t, isOptional = true } },

    ["GameObject.AddComponent"] =        { _go, { "componentType", { s, "Script" } }, { "params", t, isOptional = true } },
    ["GameObject.GetComponent"] =        { _go, { "componentType", { s, "Script" } } },
    ["GameObject.GetScriptedBehavior"] = { _go, { "scriptNameOrAsset", { s, "Script" } } },

    ["GameObject.GetWithTag"] = { _t },
    ["GameObject.GetTags"] =    { _go },
    ["GameObject.AddTag"] =     { _go, _t },
    ["GameObject.RemoveTag"] =  { _go, { "tag", {"string", "table"}, isOptional = true } },
    ["GameObject.HasTag"] =     { _go, _t, { "atLeastOneTag", defaultValue = false } },
} )

-- GUI.lua
-- Module adding the GUI components
--
-- Last modified for v1.5.0
-- Copyright © 2013-2014 Florent POUJOL, published under the MIT license.

GUI = {}

-- debug info
local s = "string"
local b = "boolean"
local n = "number"
local t = "table"
local go = "GameObject"
local v2 = "Vector2"
local v3 = "Vector3"
local _go = { "gameObject", go }
local _op = { "params", t, defaultValue = {} }
local _p = { "params", t }

--- Convert the provided value (a length) in a number expressed in scene unit.
-- The provided value may be suffixed with "px" (pixels) or "u" (scene units).
-- @param value (string or number) The value to convert.
-- @param camera (Camera or GameObject) [optional] The reference camera used to convert from pixels to units. Only needed when the value is in pixels.
-- @return (number) The converted value, expressed in scene units.
function GUI.ToSceneUnit( value, camera )
    if type( value ) == "string" then
        value = value:trim()
        if value:find( "px" ) then
            if camera ~= nil and getmetatable( camera ) == GameObject then
                camera = camera.camera      
            end
            if camera == nil then
                error( "GUI.ToSceneUnit(value, camera) : Can't convert the value '"..value.."' from pixels to scene units because no camera component has been passed as argument.")
            end
            value = tonumber( value:sub( 0, #value-2) ) * camera:GetPixelsToUnits()
        elseif value:find( "u" ) then
            value = tonumber( value:sub( 0, #value-1) )
        else
            value = tonumber( value )
        end
    end
    return value
end

--- Convert the provided value (a length) in a number expressed in screen pixel.
-- The provided value may be suffixed with "px" or be expressed in percentage (ie: "10%") or be relative (ie: "s" or "s-10") to the specified screen side size (in which case the 'screenSide' argument is mandatory).
-- @param value (string or number) The value to convert.
-- @param screenSide (string) [optional] "x" (width) or "y" (height)
-- @param camera (Camera) [optional] The reference camera used to convert from pixels to units. Only needed when the value is in units.
-- @return (number) The converted value, expressed in pixels.
function GUI.ToPixel( value, screenSide, camera )
    if type( value ) == "string" then
        if type( screenSide ) == "table" then
            camera = screenSide
            screenSide = nil
        end

        value = value:trim()
        local screenSize = CS.Screen.GetSize()

        if value:find( "px" ) then
            value = tonumber( value:sub( 0, #value-2) )

        elseif value:find( "%", 1, true ) and screenSide ~= nil then
            value = screenSize[ screenSide ] * tonumber( value:sub( 0, #value-1) ) / 100

        elseif value:find( "s" ) and screenSide ~= nil then  -- ie: "s-50"  =  "screenSize.x - 50px"
            value = value:sub( 2 ) -- removes the "s" at the beginning
            if value == "" then -- value was just "s"
                value = 0
            end
            value = screenSize[ screenSide ] + tonumber( value )
        elseif value:find( "u" ) then
            if camera == nil then
                error( "GUI.ToPixel(value, camera) : Can't convert the value '"..value.."' from pixels to scene units because no camera component has been passed as argument.")
            end
            value = tonumber( value:sub( 0, #value-1) ) / camera:GetPixelsToUnits()

        else
            value = tonumber( value )
        end
    end
    return value
end

-- Find the first parent with a camera component.
-- @param gameObject (GameObject) The child game object.
-- @param errorHead (string) [optional] The name of the function that call getCameraGO(). If set, will return an error when the parent isn't found.
-- @return (GameObject) The camera game object, or nil.
local function getCameraGO( gameObject, errorHead )
    local cameraGO = gameObject:GetInAncestors( function( go ) if go.camera ~= nil then return true end end )
    if cameraGO == nil and errorHead ~= nil then
        error(errorHead..": The "..tostring(gameObject).." isn't a child of a game object with a camera component and no camera game object is passed via the 'params' argument.")
    end
    return cameraGO
end


----------------------------------------------------------------------------------
-- Hud

GUI.Hud = {}
GUI.Hud.__index = GUI.Hud -- __index will be rewritted when Daneel loads (in Daneel.SetComponents()) and enable the dynamic accessors on the components
-- this is just meant to prevent some errors if Daneel is not loaded

--- Creates a "Hud Origin" child used for positioning hud components.
-- @param gameObject (GameObject) The game object with a camera component.
function GUI.Hud.CreateOriginGO( gameObject )
    if gameObject.camera == nil then
        error( "GUI.Hud.CreateOriginGO(): Provided game object "..tostring(gameObject).." has no camera component." )
    end
    local pixelsToUnits = gameObject.camera:GetPixelsToUnits()
    local screenSize = CS.Screen.GetSize()
    local originGO = CS.CreateGameObject( "Hud Origin for camera "..gameObject:GetName(), gameObject )
    originGO.transform:SetLocalPosition( Vector3:New(
        -screenSize.x * pixelsToUnits / 2,
        screenSize.y * pixelsToUnits / 2,
        0
    ) )
    -- the originGO is now at the top-left corner of the camera's frustum
    -- 06/06/2014: what happens with perspective cameras ?
    gameObject.hudOriginGO = originGO
end

-- Deprecated since v1.5.0.
-- Use Camera.WorldToScreenPoint() or Camera.Project() instead.
function GUI.Hud.ToHudPosition()
    error("GUI.Hud.ToHudPosition() is deprecated since v1.5.0. Use Camera.WorldToScreenPoint() or Camera.Project() instead.")
end

--- Make sure that the components of the provided Vector2 are numbers and in pixel,
-- instead of strings or in percentage or relative to the screensize.
-- @param vector (Vector2) The vector2.
-- @param camera (Camera) [optional] The reference camera used to convert from pixels to units. Only needed when the vector's components are in units.
-- @return (Vector2) The fixed position.
function Vector2.ToPixel( vector, camera )
    return Vector2.New(
        GUI.ToPixel( vector.x, "x", camera ),
        GUI.ToPixel( vector.y, "y", camera )
    )
end

--- Creates a new Hud component instance.
-- @param gameObject (GameObject) The gameObject to add to the component to.
-- @param params (table) [optional] A table of parameters.
-- @return (Hud) The hud component.
function GUI.Hud.New( gameObject, params )
    local hud = setmetatable( {}, GUI.Hud )
    hud.gameObject = gameObject
    gameObject.hud = hud
    hud.id = Daneel.Utilities.GetId()
    params = params or {}
    hud.cameraGO = params.cameraGO or getCameraGO( gameObject, "GUI.Hud.New()" )
    if hud.cameraGO.hudOriginGO == nil then
        GUI.Hud.CreateOriginGO( hud.cameraGO )
    end
    hud:Set( table.merge( GUI.Config.hud, params ) )
    return hud
end

--- Sets the position of the gameObject on screen.
-- With the top-left corner of the screen as origin.
-- @param hud (Hud) The hud component.
-- @param position (Vector2) The position as a Vector2.
function GUI.Hud.SetPosition(hud, position)
    position = position:ToPixel( hud.cameraGO.camera )
    local newPosition = hud.cameraGO.hudOriginGO.transform:GetPosition() +
    Vector3:New(
        position.x * hud.cameraGO.camera:GetPixelsToUnits(),
        -position.y * hud.cameraGO.camera:GetPixelsToUnits(),
        0
    )
    newPosition.z = hud.gameObject.transform:GetPosition().z
    hud.gameObject.transform:SetPosition( newPosition )
end

--- Get the position of the provided hud on the screen.
-- @param hud (Hud) The hud component.
-- @return (Vector2) The position.
function GUI.Hud.GetPosition(hud)
    local position = hud.gameObject.transform:GetPosition() - hud.cameraGO.hudOriginGO.transform:GetPosition()
    position = position / hud.cameraGO.camera:GetPixelsToUnits()
    return Vector2.New(math.round(position.x), math.round(-position.y))
end

--- Sets the local position (relative to its parent) of the gameObject on screen .
-- @param hud (Hud) The hud component.
-- @param position (Vector2) The position as a Vector2.
function GUI.Hud.SetLocalPosition(hud, position)
    position = position:ToPixel( hud.cameraGO.camera )
    local parent = hud.gameObject.parent or hud.cameraGO.hudOriginGO
    local newPosition = parent.transform:GetPosition() +
    Vector3:New(
        position.x * hud.cameraGO.camera:GetPixelsToUnits(),
        -position.y * hud.cameraGO.camera:GetPixelsToUnits(),
        0
    )
    newPosition.z = hud.gameObject.transform:GetPosition().z
    hud.gameObject.transform:SetPosition( newPosition )
end

--- Get the local position (relative to its parent) of the gameObject on screen.
-- @param hud (Hud) The hud component.
-- @return (Vector2) The position.
function GUI.Hud.GetLocalPosition(hud)
    local parent = hud.gameObject.parent or hud.cameraGO.hudOriginGO
    local position = hud.gameObject.transform:GetPosition() - parent.transform:GetPosition()
    position = position / hud.cameraGO.camera:GetPixelsToUnits()
    return Vector2.New(math.round(position.x), math.round(-position.y))
end

--- Set the gameObject's layer.
-- @param hud (Hud) The hud component.
-- @param layer (number) The layer (a postive number).
function GUI.Hud.SetLayer(hud, layer)
    local originLayer = hud.cameraGO.hudOriginGO.transform:GetPosition().z
    local currentPosition = hud.gameObject.transform:GetPosition()
    hud.gameObject.transform:SetPosition( Vector3:New(currentPosition.x, currentPosition.y, originLayer-layer) )
end

--- Get the gameObject's layer.
-- @param hud (Hud) The hud component.
-- @return (number) The layer (with one decimal).
function GUI.Hud.GetLayer(hud)
    local originLayer = hud.cameraGO.hudOriginGO.transform:GetPosition().z
    return math.round( originLayer - hud.gameObject.transform:GetPosition().z, 1 )
end

--- Set the huds's local layer.
-- @param hud (Hud) The hud component.
-- @param layer (number) The layer (a postiv number).
function GUI.Hud.SetLocalLayer(hud, layer)
    local parent = hud.gameObject.parent or hud.cameraGO.hudOriginGO
    local originLayer = parent.transform:GetPosition().z
    local currentPosition = hud.gameObject.transform:GetPosition()
    hud.gameObject.transform:SetPosition( Vector3:New(currentPosition.x, currentPosition.y, originLayer-layer) )
end

--- Get the gameObject's local layer.
-- @param hud (Hud) The hud component.
-- @return (number) The layer (with one decimal).
function GUI.Hud.GetLocalLayer(hud)
    local parent = hud.gameObject.parent or hud.cameraGO.hudOriginGO
    local originLayer = parent.transform:GetPosition().z
    return math.round( originLayer - hud.gameObject.transform:GetPosition().z, 1 )
end

local _hud = { "hud", "Hud" }
table.mergein( Daneel.Debug.functionArgumentsInfo, {
    ["GUI.Hud.CreateOriginGO"] =    { _go },
    ["GUI.Hud.New"] =               { _go, _op },
    ["GUI.Hud.SetPosition"] =       { _hud, { "position", v2 } },
    ["GUI.Hud.GetPosition"] =       { _hud },
    ["GUI.Hud.SetLocalPosition"] =  { _hud, { "position", v2 } },
    ["GUI.Hud.GetLocalPosition"] =  { _hud },
    ["GUI.Hud.SetLayer"] =          { _hud, { "layer", n } },
    ["GUI.Hud.GetLayer"] =          { _hud },
    ["GUI.Hud.SetLocalLayer"] =     { _hud, { "layer", n } },
    ["GUI.Hud.GetLocalLayer"] =     { _hud },
} )


----------------------------------------------------------------------------------
-- Toggle

GUI.Toggle = {}
GUI.Toggle.__index = GUI.Toggle

--- Creates a new Toggle component.
-- @param gameObject (GameObject) The component gameObject.
-- @param params (table) [optional] A table of parameters.
-- @return (Toggle) The new component.
function GUI.Toggle.New( gameObject, params )
    if Daneel.modules.MouseInput == nil then
        error( "GUI.Toggle.New(): The 'Mouse Input' module is missing from your project. It is required for the player to interact with the GUI.Toggle, GUI.Input and GUI.Slider components." )
    end

    local toggle = table.copy( GUI.Config.toggle )
    toggle.defaultText = toggle.text
    toggle.text = nil
    toggle.gameObject = gameObject
    toggle.id = Daneel.Utilities.GetId()
    setmetatable( toggle, GUI.Toggle )
    if params ~= nil then
        toggle:Set( params )
    end

    gameObject.toggle = toggle
    gameObject:AddTag( "guiComponent" )

    gameObject.OnNewComponent = function( component )
        if component == nil then return end
        local mt = getmetatable( component )

        if mt == TextRenderer then
            local text = component:GetText()
            if text == nil then
                text = toggle.defaultText
            end
            toggle:SetText( text )

        elseif mt == ModelRenderer and toggle.checkedModel ~= nil then
            if toggle.isChecked and toggle.checkedModel ~= nil then
                component:SetModel( toggle.checkedModel )
            elseif not toggle.isChecked and toggle.uncheckedModel ~= nil then
                component:SetModel( toggle.uncheckedModel )
            end
        end
    end

    gameObject.OnClick = function()
        if not (toggle.group ~= nil and toggle.isChecked) then -- true when not in a group or when in group but not checked
            toggle:Check( not toggle.isChecked )
        end
    end

    if gameObject.textRenderer ~= nil and gameObject.textRenderer:GetText() ~= nil then
        toggle:SetText( gameObject.textRenderer:GetText() )
    end

    if gameObject.modelRenderer ~= nil then
        if toggle.isChecked and toggle.checkedModel ~= nil then
            toggle.gameObject.modelRenderer:SetModel( toggle.checkedModel )
        elseif not toggle.isChecked and toggle.uncheckedModel ~= nil then
            toggle.gameObject.modelRenderer:SetModel( toggle.uncheckedModel )
        end
    end

    toggle:Check( toggle.isChecked, true )
    return toggle
end

--- Set the provided toggle's text.
-- Actually set the text of the TextRenderer component on the same gameObject,
-- but add the correct check mark in front of the provided text.
-- @param toggle (Toggle) The toggle component.
-- @param text (string) The text to display.
function GUI.Toggle.SetText( toggle, text )
    if toggle.gameObject.textRenderer ~= nil then
        if toggle.isChecked == true then
            text = Daneel.Utilities.ReplaceInString( toggle.checkedMark, { text = text } )
        else
            text = Daneel.Utilities.ReplaceInString( toggle.uncheckedMark, { text = text } )
        end
        toggle.gameObject.textRenderer:SetText( text )
    else
        if Daneel.Config.debug.enableDebug then
            print( "WARNING: GUI.Toggle.SetText(toggle, text): Can't set the toggle's text because no TextRenderer component has been found on the gameObject '"..tostring( toggle.gameObject ).."'. Waiting for a TextRenderer to be added." )
        end
        toggle.defaultText = text
    end
end

--- Get the provided toggle's text.
-- Actually get the text of the TextRenderer component on the same gameObject but without the check mark.
-- @param toggle (Toggle) The toggle component.
-- @return (string) The text.
function GUI.Toggle.GetText( toggle )
    local text = nil
    if toggle.gameObject.textRenderer ~= nil then
        text = toggle.gameObject.textRenderer:GetText()
        if text == nil then
            text = toggle.defaultText
        end
        local textMark = toggle.checkedMark
        if not toggle.isChecked then
            textMark = toggle.uncheckedMark
        end
        local start, _end = textMark:find( ":text" )
        if start ~= nil and _end ~= nil then
            local prefix = textMark:sub( 1, start - 1 )
            local suffix = textMark:sub( _end + 1 )
            text = text:gsub(prefix, ""):gsub(suffix, "")
        end
    elseif Daneel.Config.debug.enableDebug then
        print("WARNING: GUI.Toggle.GetText(toggle): Can't get the toggle's text because no TextRenderer component has been found on the gameObject '"..tostring(toggle.gameObject).."'. Returning nil.")
    end
    return text
end

--- Check or uncheck the provided toggle and fire the OnUpdate event.
-- You can get the toggle's state via toggle.isChecked.
-- @param toggle (Toggle) The toggle component.
-- @param state (boolean) [default=true] The new state of the toggle.
-- @param forceUpdate (boolean) [default=false] Tell whether to force the updating of the state.
function GUI.Toggle.Check( toggle, state, forceUpdate )
    if state == nil then
        state = true
    end
    if forceUpdate == true or toggle.isChecked ~= state then
        local text = nil
        if toggle.gameObject.textRenderer ~= nil then
            text = toggle:GetText()
        end
        toggle.isChecked = state
        if toggle.gameObject.textRenderer ~= nil then
            toggle:SetText( text ) -- "reload" the check mark based on the new checked state
        end
        if toggle.gameObject.modelRenderer ~= nil then
            if state == true and toggle.checkedModel ~= nil then
                toggle.gameObject.modelRenderer:SetModel( toggle.checkedModel )
            elseif state == false and toggle.uncheckedModel ~= nil then
                toggle.gameObject.modelRenderer:SetModel( toggle.uncheckedModel )
            end
        end
        Daneel.Event.Fire( toggle, "OnUpdate", toggle )
        if toggle.Group ~= nil and state == true then
            local gameObjects = GameObject.GetWithTag( toggle.Group )
            for i, gameObject in ipairs( gameObjects ) do
                if gameObject ~= toggle.gameObject then
                    gameObject.toggle:Check( false, true )
                end
            end
        end
    end
end

--- Set the toggle's group.
-- If the toggle was already in a group it will be removed from it.
-- @param toggle (Toggle) The toggle component.
-- @param group (string) [optional] The new group, or nil to remove the toggle from its group.
function GUI.Toggle.SetGroup( toggle, group )
    if group == nil and toggle.Group ~= nil then
        toggle.gameObject:RemoveTag( toggle.Group )
    else
        if toggle.Group ~= nil then
            toggle.gameObject:RemoveTag( toggle.Group )
        end
        toggle:Check( false )
        toggle.Group = group
        toggle.gameObject:AddTag( toggle.Group )
    end
end

--- Get the toggle's group.
-- @param toggle (Toggle) The toggle component.
-- @return (string) The group, or nil.
function GUI.Toggle.GetGroup( toggle )
    return toggle.Group
end

--- Apply the content of the params argument to the provided toggle.
-- Overwrite Component.Set() from Daneel's CraftStudio file.
-- @param toggle (Toggle) The toggle component.
-- @param params (table) A table of parameters to set the component with.
function GUI.Toggle.Set( toggle, params )
    local group = params.group
    params.group = nil
    local isChecked = params.isChecked
    params.isChecked = nil
    for key, value in pairs( params ) do
        toggle[key] = value
    end
    if group ~= nil then
        toggle:SetGroup( group )
    end
    if isChecked ~= nil then
        toggle:Check( isChecked )
    end
end

local _toggle = { "toggle", "Toggle" }
table.mergein( Daneel.Debug.functionArgumentsInfo, {
    ["GUI.Toggle.New"] =        { _go, _op },
    ["GUI.Toggle.Set"] =        { _toggle, _p },
    ["GUI.Toggle.SetText"] =    { _toggle, { "text", s } },
    ["GUI.Toggle.GetText"] =    { _toggle },
    ["GUI.Toggle.Check"] =      { _toggle, { "state", defaultValue = true }, { "forceUpdate", defaultValue = false } },
    ["GUI.Toggle.SetGroup"] =   { _toggle, { "group", s, isOptional = true } },
    ["GUI.Toggle.GetGroup"] =   { _toggle },
} )


----------------------------------------------------------------------------------
-- ProgressBar

GUI.ProgressBar = {}
GUI.ProgressBar.__index = GUI.ProgressBar

--- Creates a new GUI.ProgressBar.
-- @param gameObject (GameObject) The component gameObject.
-- @param params (table) [optional] A table of parameters.
-- @return (ProgressBar) The new component.
function GUI.ProgressBar.New( gameObject, params )
    local progressBar = table.copy( GUI.Config.progressBar )
    progressBar.gameObject = gameObject
    progressBar.id = Daneel.Utilities.GetId()
    progressBar.value = nil -- remove the property to allow to use the dynamic getter/setter
    setmetatable( progressBar, GUI.ProgressBar )
    params = params or {}
    if params.value == nil then
        params.value = GUI.Config.progressBar.value
    end
    progressBar.cameraGO = params.cameraGO or getCameraGO( gameObject )
    progressBar:Set( params )
    gameObject.progressBar = progressBar
    return progressBar
end

--- Set the value of the progress bar, adjusting its length.
-- Fires the 'OnUpdate' event.
-- @param progressBar (ProgressBar) The progressBar.
-- @param value (number or string) The value as a number (between minVal and maxVal) or as a string and a percentage (between "0%" and "100%").
function GUI.ProgressBar.SetValue(progressBar, value)
    local errorHead = "GUI.ProgressBar.SetValue(progressBar, value) : "
    local minVal = progressBar.minValue
    local maxVal = progressBar.maxValue
    local percentageOfProgress = nil

    if type(value) == "string" then
        if value:endswith("%") then
            percentageOfProgress = tonumber(value:sub(1, #value-1)) / 100

            local oldPercentage = percentageOfProgress
            percentageOfProgress = math.clamp(percentageOfProgress, 0.0, 1.0)
            if percentageOfProgress ~= oldPercentage and Daneel.Config.debug.enableDebug then
                print(errorHead.."WARNING : value in percentage with value '"..value.."' is below 0% or above 100%.")
            end

            value = (maxVal - minVal) * percentageOfProgress + minVal
        else
            value = tonumber(value)
        end
    end

    -- now value is a number and should be a value between minVal and maxVal
    local oldValue = value
    value = math.clamp(value, minVal, maxVal)

    progressBar.minLength = GUI.ToSceneUnit( progressBar.minLength, progressBar.cameraGO )
    progressBar.maxLength = GUI.ToSceneUnit( progressBar.maxLength, progressBar.cameraGO )
    local currentValue = progressBar:GetValue()

    if value ~= currentValue then
        if value ~= oldValue and Daneel.Config.debug.enableDebug then
            print(errorHead.." WARNING : value with value '"..oldValue.."' is out of its boundaries : min='"..minVal.."', max='"..maxVal.."'")
        end
        local diff = maxVal - minVal -- Luamin removes parenthesis at the end of expression. 
        -- Calculation of percentageOfProgress would fail if it was done like this: (value - minVal) / (maxVal - minVal)
        -- because it would hev been shortened to (v-min)/max-min instead of (v-min)/(max-min)
        percentageOfProgress = (value - minVal) / diff

        progressBar.height = GUI.ToSceneUnit( progressBar.height, progressBar.cameraGO )

        local newLength = (progressBar.maxLength - progressBar.minLength) * percentageOfProgress + progressBar.minLength
        local currentScale = progressBar.gameObject.transform:GetLocalScale()
        progressBar.gameObject.transform:SetLocalScale( Vector3:New(newLength, progressBar.height, currentScale.z) )
        -- newLength = scale only because the base size of the model is of one unit at a scale of one

        Daneel.Event.Fire(progressBar, "OnUpdate", progressBar)
    end
end
GUI.ProgressBar.SetProgress = GUI.ProgressBar.SetValue

--- Set the value of the progress bar, adjusting its length.
-- Does the same things as SetProgress() by does it faster.
-- Unlike SetProgress(), does not fire the 'OnUpdate' event by default.
-- Should be used when the value is updated regularly (ie : from a Behavior:Update() function).
-- @param progressBar (ProgressBar) The progressBar.
-- @param value (number or string) The value as a number (between minVal and maxVal) or as a string and a percentage (between "0%" and "100%").
-- @param fireEvent (boolean) [default=false] Tell whether to fire the 'OnUpdate' event (true) or not (false).
function GUI.ProgressBar.UpdateValue( progressBar, value, fireEvent )
    if value == progressBar._value then return end
    progressBar._value = value

    local minVal = progressBar.minValue
    local maxVal = progressBar.maxValue
    local minLength = progressBar.minLength
    local percentageOfProgress = nil

    if type(value) == "string" then
        local _value = value
        value = tonumber(value)
        if value == nil then -- value in percentage. ie "50%"
            percentageOfProgress = tonumber( _value:sub( 1, #_value-1 ) ) / 100
        end
    end

    if percentageOfProgress == nil then
        local diff = maxVal - minVal
        percentageOfProgress = (value - minVal) / diff
    end
    percentageOfProgress = math.clamp( percentageOfProgress, 0.0, 1.0 )

    local newLength = (progressBar.maxLength - minLength) * percentageOfProgress + minLength
    local currentScale = progressBar.gameObject.transform:GetLocalScale()
    progressBar.gameObject.transform:SetLocalScale( Vector3:New( newLength, progressBar.height, currentScale.z ) )

    if fireEvent == true then
        Daneel.Event.Fire( progressBar, "OnUpdate", progressBar )
    end
end
GUI.ProgressBar.UpdateProgress = GUI.ProgressBar.UpdateValue

--- Get the current value of the progress bar.
-- @param progressBar (ProgressBar) The progressBar.
-- @param getAsPercentage (boolean) [default=false] Get the value as a percentage (between 0 and 100) instead of an absolute value.
-- @return (number) The value.
function GUI.ProgressBar.GetValue(progressBar, getAsPercentage)
    local scale = math.round( progressBar.gameObject.transform:GetLocalScale().x, 2 )
    local diff = progressBar.maxLength - progressBar.minLength
    local value = (scale - progressBar.minLength) / diff
    if getAsPercentage == true then
        value = value * 100
    else
        value = (progressBar.maxValue - progressBar.minValue) * value + progressBar.minValue
    end
    return value
end
GUI.ProgressBar.GetProgress = GUI.ProgressBar.GetValue

--- Set the height of the progress bar.
-- @param progressBar (ProgressBar) The progressBar.
-- @param height (number or string) Get the height in pixel or scene unit.
function GUI.ProgressBar.SetHeight( progressBar, height )
    local currentScale = progressBar.gameObject.transform:GetLocalScale()
    local height = GUI.ToSceneUnit( height, progressBar.cameraGO )
    progressBar.gameObject.transform:SetLocalScale( Vector3:New( currentScale.x, height, currentScale.z ) )
end

--- Get the height of the progress bar (the local scale's y component).
-- @param progressBar (ProgressBar) The progressBar.
-- @return (number) The height.
function GUI.ProgressBar.GetHeight( progressBar )
    return progressBar.gameObject.transform:GetLocalScale().y
end

--- Apply the content of the params argument to the provided progressBar.
-- Overwrite Component.Set() from CraftStudio module.
-- @param progressBar (ProgressBar) The progressBar.
-- @param params (table) A table of parameters to set the component with.
function GUI.ProgressBar.Set( progressBar, params )
    local value = params.value
    params.value = nil
    if value == nil then
        value = progressBar:GetValue()
    end
    for key, value in pairs(params) do
        progressBar[key] = value
    end
    progressBar:SetValue( value )
end

local _pb = { "progressBar", "ProgressBar" }
table.mergein( Daneel.Debug.functionArgumentsInfo, {
    ["GUI.ProgressBar.New"] =       { _go, _op },
    ["GUI.ProgressBar.Set"] =       { _pb, _p },
    ["GUI.ProgressBar.SetValue"] =  { _pb, { "value", { s, n } } },
    ["GUI.ProgressBar.GetValue"] =  { _pb, { "getAsPercentage", defaultValue = false } },
    ["GUI.ProgressBar.SetHeight"] = { _pb, { "height", { s, n } } },
    ["GUI.ProgressBar.GetHeight"] = { _pb },
} )


----------------------------------------------------------------------------------
-- Slider

GUI.Slider = {}
GUI.Slider.__index = GUI.Slider

---- Creates a new GUI.Slider.
-- @param gameObject (GameObject) The component gameObject.
-- @param params (table) [optional] A table of parameters.
-- @return (Slider) The new component.
function GUI.Slider.New( gameObject, params )
    
    if Daneel.modules.MouseInput == nil then
        error( "GUI.Slider.New(): The 'Mouse Input' module is missing from your project. It is required for the player to interact with the GUI.Toggle, GUI.Input and GUI.Slider components." )
    end

    local slider = table.copy( GUI.Config.slider )
    slider.gameObject = gameObject
    slider.id = Daneel.Utilities.GetId()
    slider.value = nil
    slider.parent = slider.gameObject:GetParent()
    if slider.parent == nil then
        local go = CS.CreateGameObject( "SliderParent" )
        go.transform:SetPosition( slider.gameObject.transform:GetPosition() )
        slider.gameObject:SetParent( go )
    end
    setmetatable( slider, GUI.Slider )

    gameObject.slider = slider
    gameObject:AddTag( "guiComponent" )

    gameObject.OnDrag = function()
        local mouseDelta = CraftStudio.Input.GetMouseDelta()
        local positionDelta = Vector3:New( mouseDelta.x, 0, 0 )
        if slider.axis == "y" then
            positionDelta = Vector3:New( 0, -mouseDelta.y, 0, 0 )
        end

        gameObject.transform:Move( positionDelta * slider.cameraGO.camera:GetPixelsToUnits() )

        local goPosition = gameObject.transform:GetPosition()
        local parentPosition = slider.parent.transform:GetPosition()
        if slider.axis == "x" and goPosition.x < parentPosition.x then
            slider:SetValue( slider.minValue )
        elseif slider.axis == "y" and goPosition.y < parentPosition.y then -- Conditions done like this because of Luamin
            slider:SetValue( slider.minValue )
        elseif slider:GetValue() > slider.maxValue then
            slider:SetValue( slider.maxValue )
        else
            Daneel.Event.Fire( slider, "OnUpdate", slider )
        end
    end
    
    params = params or {}
    slider.cameraGO = params.cameraGO or getCameraGO( gameObject, "GUI.Slider.New()" )
    if params.value == nil then
        params.value = GUI.Config.slider.value
    end
    slider:Set( params )
    return slider
end

--- Set the value of the slider, adjusting its position.
-- @param slider (Slider) The slider.
-- @param value (number or string) The value as a number (between minVal and maxVal) or as a string and a percentage (between "0%" and "100%").
function GUI.Slider.SetValue( slider, value )
    local errorHead = "GUI.Slider.SetValue( slider, value ) : "
    local maxVal = slider.maxValue
    local minVal = slider.minValue
    local percentage = nil

    if type( value ) == "string" then
        if value:endswith( "%" ) then
            percentage = tonumber( value:sub( 1, #value-1 ) ) / 100
            value = (maxVal - minVal) * percentage + minVal
        else
            value = tonumber( value )
        end
    end

    -- now value is a number and should be a value between minVal and maxVal
    local oldValue = value
    value = math.clamp( value, minVal, maxVal )
    if value ~= oldValue and Daneel.Config.debug.enableDebug then
        print( errorHead .. "WARNING : Argument 'value' with value '" .. oldValue .. "' is out of its boundaries : min='" .. minVal .. "', max='" .. maxVal .. "'" )
    end
    local diff = maxVal - minVal
    percentage = (value - minVal) / diff

    slider.length = GUI.ToSceneUnit( slider.length, slider.cameraGO )

    local direction = -Vector3:Left()
    if slider.axis == "y" then
        direction = Vector3:Up()
    end
    local orientation = Vector3.Rotate( direction, slider.gameObject.transform:GetOrientation() )
    local newPosition = slider.parent.transform:GetPosition() + orientation * slider.length * percentage
    slider.gameObject.transform:SetPosition( newPosition )

    Daneel.Event.Fire( slider, "OnUpdate", slider )
end

--- Get the current slider's value.
-- @param slider (Slider) The slider.
-- @param getAsPercentage (boolean) [default=false] Get the value as a percentage (between 0 and 100) instead of an absolute value.
-- @return (number) The value.
function GUI.Slider.GetValue( slider, getAsPercentage )
    local percentage = Vector3.Distance( slider.parent.transform:GetPosition(), slider.gameObject.transform:GetPosition() ) / slider.length
    local value = percentage * 100
    if getAsPercentage ~= true then
        value = (slider.maxValue - slider.minValue) * percentage + slider.minValue
    end
    return value
end

--- Apply the content of the params argument to the provided slider.
-- Overwrite Component.Set() from the core.
-- @param slider (Slider) The slider.
-- @param params (table) A table of parameters to set the component with.
function GUI.Slider.Set( slider, params )
    local value = params.value
    params.value = nil
    if value == nil then
        value = slider:GetValue()
    end
    for key, value in pairs(params) do
        slider[key] = value
    end
    slider:SetValue( value )
end


----------------------------------------------------------------------------------
-- Input

GUI.Input = {}
GUI.Input.__index = GUI.Input

--- Creates a new GUI.Input.
-- @param gameObject (GameObject) The component gameObject.
-- @param params (table) [optional] A table of parameters.
-- @return (Input) The new component.
function GUI.Input.New( gameObject, params )
    if Daneel.modules.MouseInput == nil then
        error( "GUI.Input.New(): The 'Mouse Input' module is missing from your project. It is required for the player to interact with the GUI.Toggle, GUI.Input and GUI.Slider components." )
    end

    params = params or {}
    local input = table.merge( GUI.Config.input, params )
    input.gameObject = gameObject
    input.id = Daneel.Utilities.GetId()
    setmetatable( input, GUI.Input )
    
    -- adapted from Blast Turtles
    if input.OnTextEntered == nil then
        input.OnTextEntered = function( char )
            if input.isFocused then
                local charNumber = string.byte( char )

                if charNumber == 8 then -- Backspace
                    local text = gameObject.textRenderer:GetText()
                    input:Update( text:sub( 1, #text - 1 ), true )

                --elseif charNumber == 13 then -- Enter
                    --Daneel.Event.Fire( input, "OnValidate", input )

                -- Any character between 32 and 127 is regular printable ASCII
                elseif charNumber >= 32 and charNumber <= 127 then
                    if input.characterRange ~= nil and input.characterRange:find( char, 1, true ) == nil then
                        return
                    end
                    input:Update( char )
                end
            end
        end
    end

    local cursorGO = gameObject:GetChild( "Cursor" )
    if cursorGO ~= nil then
        input.cursorGO = cursorGO
        -- make the cursor blink
        cursorGO.tweener = Tween.Timer( 
            input.cursorBlinkInterval,
            function( tweener )
                if tweener.gameObject == nil or tweener.gameObject.inner == nil then
                    tweener:Destroy()
                    return
                end
                local opacity = 1
                if tweener.gameObject.modelRenderer:GetOpacity() == 1 then
                    opacity = 0
                end
                tweener.gameObject.modelRenderer:SetOpacity( opacity )
            end,
            true -- loop
        )
        cursorGO.tweener.isPaused = true
        cursorGO.tweener.gameObject = cursorGO
    end

    local isFocused = input.isFocused
    input.isFocused = nil -- force the state
    input:Focus( isFocused )

    gameObject.input = input
    gameObject:AddTag( "guiComponent" )
    gameObject:AddTag( "gui_input" )

    local backgroundGO = gameObject:GetChild( "Background" )
    if backgroundGO ~= nil then
        input.backgroundGO = backgroundGO
        if input.focusOnBackgroundClick then
            backgroundGO:AddTag( "guiComponent" )
        end
    end

    return input
end

GUI.Input.Module = {}
Daneel.modules.GUIInput = GUI.Input.Module
-- the module object can't be GUI.Input because it already has an Update() function

-- Called from [Daneel/Update] every frames
function GUI.Input.Module.Update() 
    if CS.Input.WasButtonJustReleased( "LeftMouse" ) then
        local inputGOs = GameObject.GetWithTag( "gui_input" )
        local inputToFocus = nil

        for i, inputGO in pairs( inputGOs ) do
            local input = inputGO.input

            local isMouseOver = inputGO.isMouseOver -- click on the text
            if isMouseOver ~= true and input.focusOnBackgroundClick and input.backgroundGO ~= nil then
                isMouseOver = input.backgroundGO.isMouseOver -- click on the background
            end
            if isMouseOver == true then
                inputToFocus = input
            else
                input:Focus(false)
            end
        end

        if inputToFocus ~= nil then
            inputToFocus:Focus(true)
        end
    end

    if CS.Input.WasButtonJustReleased( "ValidateInput" ) then
        local inputGOs = GameObject.GetWithTag( "gui_input" )
        for i, inputGO in pairs( inputGOs ) do
            local input = inputGO.input
            if input.isFocused then
                Daneel.Event.Fire( input, "OnValidate", input )
                break
            end
        end
    end
end

--- Set the focused state of the input.
-- @param input (Input) The input component.
-- @param focus (boolean) [default=true] The new focus.
function GUI.Input.Focus( input, focus )
    if focus == nil then
        focus = true
    end
    if input.isFocused ~= focus then
        input.isFocused = focus
        local text = string.trim( input.gameObject.textRenderer:GetText() )
        if focus == true then
            CS.Input.OnTextEntered( input.OnTextEntered )
            if text == input.defaultValue then
                input.gameObject.textRenderer:SetText( "" )
            end
        else
            CS.Input.OnTextEntered( nil )
            if input.defaultValue ~= nil and input.defaultValue ~= "" and text == "" then
                input.gameObject.textRenderer:SetText( input.defaultValue )
            end
        end
        Daneel.Event.Fire( input, "OnFocus", input )
        input:UpdateCursor()
    end
end

--- Update the position and opacity of the input's cursor.
-- @param input (Input) The input component.
function GUI.Input.UpdateCursor( input )
    if input.cursorGO ~= nil then
        local alignment = input.gameObject.textRenderer:GetAlignment()
        if alignment ~= TextRenderer.Alignment.Right then
            local length = input.gameObject.textRenderer:GetTextWidth() -- Left
            if alignment == TextRenderer.Alignment.Center then
                length = length / 2
            end
            input.cursorGO.transform:SetLocalPosition( Vector3:New( length, 0, 0 ) )
        end
        local opacity = 0
        if input.isFocused then
            opacity = 1
        end
        input.cursorGO.modelRenderer:SetOpacity( opacity )
        input.cursorGO.tweener.isPaused = not input.isFocused
        Daneel.Event.Fire( input.cursorGO, "OnUpdate", input )
    end
end

--- Update the text of the input.
-- @param input (Input) The input component.
-- @param text (string) The text (often just one character) to add to the current text.
-- @param replaceText (boolean) [default=false] Tell whether the provided text should be added (false) or replace (true) the current text.
function GUI.Input.Update( input, text, replaceText )
    local oldText = input.gameObject.textRenderer:GetText()
    if not replaceText then -- nil or false
        text = oldText .. text
    end
    if #text > input.maxLength then
        text = text:sub( 1, input.maxLength )
    end
    if oldText ~= text then
        input.gameObject.textRenderer:SetText( text )
        Daneel.Event.Fire( input, "OnUpdate", input )
        input:UpdateCursor()
    end
end

local _slider = { "slider", "Slider" }
local _input = { "input", "Input" }
table.mergein( Daneel.Debug.functionArgumentsInfo, {
    ["GUI.Slider.New"] =       { _go, _op },
    ["GUI.Slider.Set"] =       { _slider, _p },
    ["GUI.Slider.SetValue"] =  { _slider, { "value", { s, n } } },
    ["GUI.Slider.GetValue"] =  { _slider, { "getAsPercentage", defaultValue = false } },
    ["GUI.Input.New"] =          { _go, _op },
    ["GUI.Input.Focus"] =        { _input, { "focus", defaultValue = true } },
    ["GUI.Input.UpdateCursor"] = { _input },
    ["GUI.Input.Update"] =       { _input, { "text", s }, { "replaceText", defaultValue = false } },
} )


----------------------------------------------------------------------------------
-- TextArea

GUI.TextArea = {}
GUI.TextArea.__index = GUI.TextArea

--- Creates a new TextArea component.
-- @param gameObject (GameObject) The game object.
-- @param params (table) A table of parameters.
-- @return (TextArea) The new component.
function GUI.TextArea.New( gameObject, params )
    local textArea = {}
    textArea.gameObject = gameObject
    gameObject.textArea = textArea
    textArea.id = Daneel.Utilities.GetId()
    textArea.lineGOs = {}
    setmetatable( textArea, GUI.TextArea )
    textArea.textRuler = gameObject.textRenderer -- used to store the TextRenderer properties and mesure the lines length in SetText()
    if textArea.textRuler == nil then
        textArea.textRuler = gameObject:CreateComponent( "TextRenderer" ) 
    end
    textArea.textRuler:SetText( "" )
    params = params or {}
    textArea.cameraGO = params.cameraGO or getCameraGO( gameObject )
    textArea:Set( table.merge( GUI.Config.textArea, params ) )
    return textArea
end

--- Apply the content of the params argument to the provided textArea.
-- Overwrite Component.Set() from the core.
-- @param textArea (TextArea) The textArea.
-- @param params (table) A table of parameters to set the component with.
function GUI.TextArea.Set( textArea, params )
    local lineGOs = textArea.lineGOs
    textArea.lineGOs = {} -- prevent the every setters to update the text when they are called
    -- this is done once at the end
    local text = params.text
    params.text = nil
    for key, value in pairs( params ) do
        textArea[ key ] = value
    end
    textArea.lineGOs = lineGOs
    if text == nil then
        text = textArea.Text
    end
    textArea:SetText( text )
end

--- Set the component's text.
-- @param textArea (TextArea) The textArea component.
-- @param text (string) The text to display.
function GUI.TextArea.SetText( textArea, text )
    textArea.Text = text

    local lines = { text }
    if textArea.newLine ~= "" then
        lines = string.split( text, textArea.NewLine )
    end

    local textAreaScale = textArea.gameObject.transform:GetLocalScale()

    -- areaWidth is the max length in units of each line
    local areaWidth = textArea.AreaWidth
    if areaWidth ~= nil and areaWidth > 0 then
        -- cut the lines based on their length
        local tempLines = table.copy( lines )
        lines = {}

        for i = 1, #tempLines do
            local line = tempLines[i]

            if textArea.textRuler:GetTextWidth( line ) * textAreaScale.x > areaWidth then
                local newLine = ""

                for j = 1, #line do
                    local char = line:sub(j,j)
                    newLine = newLine..char

                    if textArea.textRuler:GetTextWidth( newLine ) * textAreaScale.x > areaWidth then
                        if char == " " then
                            table.insert( lines, newLine:sub( 1, #newLine-1 ) )
                            newLine = "" 
                            -- Having `""` instead of `char` will delete all spaces at the beginning of a line
                            -- this not necessarily something that is wanted...
                        else
                            -- the end of the line is inside a word
                            -- go backward to find the first space char and cut the line there
                            local word = ""
                            for k = #newLine, 1, -1 do
                                local wordLetter = newLine:sub(k,k)
                                if wordLetter == " " then
                                    break
                                else
                                    word = wordLetter..word
                                end
                            end
                            
                            table.insert( lines, newLine:sub( 1, #newLine-#word ) )
                            newLine = word
                        end

                        if not textArea.WordWrap then
                            newLine = nil
                            break
                        end
                    end
                end

                if newLine ~= nil then
                    table.insert( lines, newLine )
                end
            else
                table.insert( lines, line )
            end
        end -- end loop on lines
    end

    if type( textArea.linesFilter ) == "function" then
        lines = textArea.linesFilter( textArea, lines ) or lines
    end
    
    local linesCount = #lines
    local lineGOs = textArea.lineGOs
    local oldLinesCount = #lineGOs
    local lineHeight = textArea.LineHeight / textAreaScale.y
    local gameObject = textArea.gameObject
    local textRendererParams = {
        font = textArea.Font,
        alignment = textArea.Alignment,
        opacity = textArea.Opacity,
    }

    -- calculate position offset of the first line based on vertical alignment and number of lines
    -- the offset is decremented by lineHeight after every lines
    local offset = -lineHeight / 2 -- verticalAlignment = "top"
    if textArea.VerticalAlignment == "middle" then
        offset = lineHeight * linesCount / 2 - lineHeight / 2
    elseif textArea.VerticalAlignment == "bottom" then
        offset = lineHeight * linesCount - lineHeight / 2
    end

    for i=1, linesCount do
        local line = lines[i]    
        textRendererParams.text = line

        if lineGOs[i] ~= nil then
            lineGOs[i].transform:SetLocalPosition( Vector3:New( 0, offset, 0 ) )
            lineGOs[i].textRenderer:Set( textRendererParams )
        else
            local newLineGO = CS.CreateGameObject( "TextArea" .. textArea.id .. "-Line" .. i, gameObject )
            newLineGO.transform:SetLocalPosition( Vector3:New( 0, offset, 0 ) )
            newLineGO.transform:SetLocalScale( Vector3:New(1) )
            newLineGO:CreateComponent( "TextRenderer" )
            newLineGO.textRenderer:Set( textRendererParams )
            table.insert( lineGOs, newLineGO )
        end

        offset = offset - lineHeight 
    end

    -- this new text has less lines than the previous one
    if linesCount < oldLinesCount then
        for i = linesCount + 1, oldLinesCount do
            lineGOs[i].textRenderer:SetText( "" ) -- don't destroy the line game object, just remove any text
        end
    end

    Daneel.Event.Fire( textArea, "OnUpdate", textArea )
end

--- Get the component's text.
-- @param textArea (TextArea) The textArea component.
-- @return (string) The component's text.
function GUI.TextArea.GetText( textArea )
    return textArea.Text
end

--- Add a line to the text area's text.
-- @param textArea (TextArea) The textArea component.
-- @param line (string) The line to add.
-- @param prepend (boolean) [default=false] If true, prepend the line to the text. Otherwise, append the line to the text.
function GUI.TextArea.AddLine( textArea, line, prepend )
    local text = textArea.Text
    if prepend == true then
        text = line..textArea.NewLine..text
    else
        if text ~= "" and not string.endswith( text, textArea.NewLine ) then
            line = textArea.NewLine..line
        end
        text = text..line
    end
    textArea:SetText( text )
end

--- Set the component's area width (maximum line length).
-- Must be strictly positive to have an effect.
-- Set as a negative value, 0 or nil to remove the limitation.
-- @param textArea (TextArea) The textArea component.
-- @param areaWidth (number or string) [optional] The area width in scene units or in pixels as a string suffixed with "px".
function GUI.TextArea.SetAreaWidth( textArea, areaWidth )
    areaWidth = math.clamp( GUI.ToSceneUnit( areaWidth, textArea.cameraGO ), 0, 999 )   
    if textArea.AreaWidth ~= areaWidth then
        textArea.AreaWidth = areaWidth
        if #textArea.lineGOs > 0 then
            textArea:SetText( textArea.Text )
        end
    end
end

--- Get the component's area width.
-- @param textArea (TextArea) The textArea component.
-- @return (number) The area width in scene units.
function GUI.TextArea.GetAreaWidth( textArea )
    return textArea.AreaWidth
end

--- Set the component's wordWrap property.
-- Define what happens when the lines are longer then the area width.
-- @param textArea (TextArea) The textArea component.
-- @param wordWrap (boolean) [default=false] Cut the line when false, or creates new additional lines with the remaining text when true.
function GUI.TextArea.SetWordWrap( textArea, wordWrap )
    if textArea.WordWrap ~= wordWrap then
        textArea.WordWrap = wordWrap
        if #textArea.lineGOs > 0 then
            textArea:SetText( textArea.Text )
        end
    end
end

--- Get the component's wordWrap property.
-- @param textArea (TextArea) The textArea component.
-- @return (boolean) True or false.
function GUI.TextArea.GetWordWrap( textArea )
    return textArea.WordWrap
end

--- Set the component's newLine string used by SetText() to split the input text in several lines.
-- @param textArea (TextArea) The textArea component.
-- @param newLine (string) The newLine string (one or several character long). Set "\n" to split multiline strings.
function GUI.TextArea.SetNewLine( textArea, newLine )
    if textArea.NewLine ~= newLine then
        textArea.NewLine = newLine
        if #textArea.lineGOs > 0 then
            textArea:SetText( textArea.Text )
        end
    end
end

--- Get the component's newLine string.
-- @param textArea (TextArea) The textArea component.
-- @return (string) The newLine string.
function GUI.TextArea.GetNewLine( textArea )
    return textArea.NewLine
end

--- Set the component's line height.
-- @param textArea (TextArea) The textArea component.
-- @param lineHeight (number or string) The line height in scene units or in pixels as a string suffixed with "px".
function GUI.TextArea.SetLineHeight( textArea, lineHeight )
    local lineHeight = GUI.ToSceneUnit( lineHeight, textArea.cameraGO )
    if textArea.LineHeight ~= lineHeight then
        textArea.LineHeight = lineHeight
        if #textArea.lineGOs > 0 then
            textArea:SetText( textArea.Text )
        end
    end
end

--- Get the component's line height.
-- @param textArea (TextArea) The textArea component.
-- @return (number) The line height in scene units.
function GUI.TextArea.GetLineHeight( textArea )
    return textArea.LineHeight
end

--- Set the component's vertical alignment.
-- @param textArea (TextArea) The textArea component.
-- @param verticalAlignment (string) "top", "middle" or "bottom". Case-insensitive.
function GUI.TextArea.SetVerticalAlignment( textArea, verticalAlignment )
    local errorHead = "GUI.TextArea.SetVerticalAlignment( textArea, verticalAlignment ) : "
    verticalAlignment = Daneel.Debug.CheckArgValue( verticalAlignment, "verticalAlignment", {"top", "middle", "bottom"}, errorHead, GUI.Config.textArea.verticalAlignment )
    verticalAlignment = string.trim( verticalAlignment:lower() )
    if textArea.VerticalAlignment ~= verticalAlignment then 
        textArea.VerticalAlignment = verticalAlignment
        if #textArea.lineGOs > 0 then
            textArea:SetText( textArea.Text )
        end
    end
end

--- Get the component's vertical alignment property.
-- @param textArea (TextArea) The textArea component.
-- @return (string) The vertical alignment.
function GUI.TextArea.GetVerticalAlignment( textArea )
    return textArea.VerticalAlignment
end

--- Set the component's font used to renderer the text.
-- @param textArea (TextArea) The textArea component.
-- @param font (Font or string) The font asset or fully-qualified path.
function GUI.TextArea.SetFont( textArea, font )
    textArea.textRuler:SetFont( font )
    font = textArea.textRuler:GetFont()
    if textArea.Font ~= font then
        textArea.Font = font
        if #textArea.lineGOs > 0 then
            for i=1, #textArea.lineGOs do
                textArea.lineGOs[i].textRenderer:SetFont( textArea.Font )
            end
            textArea:SetText( textArea.Text ) -- reset the text because the size of the text may have changed
        end
    end
end

--- Get the component's font used to render the text.
-- @param textArea (TextArea) The textArea component.
-- @return (Font) The font.
function GUI.TextArea.GetFont( textArea )
    return textArea.Font
end

--- Set the component's alignment.
-- Works like a TextRenderer alignment.
-- @param textArea (TextArea) The textArea component.
-- @param alignment (TextRenderer.Alignment or string) One of the values in the 'TextRenderer.Alignment' enum (Left, Center or Right) or the same values as case-insensitive string ("left", "center" or "right").
function GUI.TextArea.SetAlignment( textArea, alignment )
    textArea.textRuler:SetAlignment( alignment )
    alignment = textArea.textRuler:GetAlignment()
    if textArea.Alignment ~= alignment then
        textArea.Alignment = alignment
        for i=1, #textArea.lineGOs do
            textArea.lineGOs[i].textRenderer:SetAlignment( textArea.Alignment )
        end
    end
end

--- Get the component's horizontal alignment.
-- @param textArea (TextArea) The textArea component.
-- @return (TextRenderer.Alignment or number) The alignment (of type number in the webplayer).
function GUI.TextArea.GetAlignment( textArea )
    return textArea.Alignment
end

--- Set the component's opacity.
-- @param textArea (TextArea) The textArea component.
-- @param opacity (number) The opacity between 0.0 and 1.0.
function GUI.TextArea.SetOpacity( textArea, opacity )
    if textArea.Opacity ~= opacity then
        textArea.Opacity = opacity
        for i=1, #textArea.lineGOs do
            textArea.lineGOs[i].textRenderer:SetOpacity( opacity )
        end
    end
end

--- Get the component's opacity.
-- @param textArea (TextArea) The textArea component.
-- @return (number) The opacity between 0.0 and 1.0.
function GUI.TextArea.GetOpacity( textArea )
    return textArea.Opacity
end

local _ta = { "textArea", "TextArea" }
table.mergein( Daneel.Debug.functionArgumentsInfo, {
    ["GUI.TextArea.New"] =                  { { "gameObject", go }, { "params", t, isOptional = true } },
    ["GUI.TextArea.Set"] =                  { _ta, _p },
    ["GUI.TextArea.SetText"] =              { _ta, { "text", s } },
    ["GUI.TextArea.GetText"] =              { _ta },
    ["GUI.TextArea.AddLine"] =              { _ta, { "line", s }, { "prepend", defaultValue = false } },
    ["GUI.TextArea.SetAreaWidth"] =         { _ta, { "areaWidth", { s, n }, defaultValue = 0 } },
    ["GUI.TextArea.GetAreaWidth"] =         { _ta },
    ["GUI.TextArea.SetWordWrap"] =          { _ta, { "wordWrap", defaultValue = false } },
    ["GUI.TextArea.GetWordWrap"] =          { _ta },
    ["GUI.TextArea.SetNewLine"] =           { _ta, { "newLine", s } },
    ["GUI.TextArea.GetNewLine"] =           { _ta },
    ["GUI.TextArea.SetLineHeight"] =        { _ta, { "lineHeight", { s, n } } },
    ["GUI.TextArea.GetLineHeight"] =        { _ta },
    ["GUI.TextArea.SetVerticalAlignment"] = { _ta, { "verticalAlignment", s } },
    ["GUI.TextArea.GetVerticalAlignment"] = { _ta },
    ["GUI.TextArea.SetFont"] =              { _ta, { "font", { s, "Font" } } },
    ["GUI.TextArea.GetFont"] =              { _ta },
    ["GUI.TextArea.SetAlignment"] =         { _ta, { "alignment", { s, "userdata", n } } },
    ["GUI.TextArea.GetAlignment"] =         { _ta },
    ["GUI.TextArea.SetOpacity"] =           { _ta, { "opacity", n } },
    ["GUI.TextArea.GetOpacity"] =           { _ta },
} )


----------------------------------------------------------------------------------
-- Config - loading

Daneel.modules.GUI = GUI

function GUI.DefaultConfig()
    local config = {
        cameraName = "HUD Camera",  -- Name of the gameObject who has the orthographic camera used to render the HUD
        cameraGO = nil, -- the corresponding GameObject, set at runtime
        originGO = nil, -- "parent" gameObject for global hud positioning, created at runtime in DaneelModuleGUIAwake

        -- Default GUI components settings
        hud = {},

        toggle = {
            isChecked = false, -- false = unchecked, true = checked
            text = "Toggle",
            -- ':text' represents the toggle's text
            checkedMark = ":text",
            uncheckedMark = ":text",
            checkedModel = nil,
            uncheckedModel = nil,
        },

        progressBar = {
            height = 1,
            minValue = 0,
            maxValue = 100,
            minLength = 0,
            maxLength = 5, -- in units
            value = "100%",
        },

        slider = {
            minValue = 0,
            maxValue = 100,
            length = 5, -- 5 units
            axis = "x",
            value = "0%",
            OnTextEntered = nil
        },

        input = {
            isFocused = false,
            maxLength = 9999,
            defaultValue = nil,
            characterRange = nil,
            focusOnBackgroundClick = true,
            cursorBlinkInterval = 0.5, -- second
        },

        textArea = {
            areaWidth = 0, -- max line length, in units or pixel as a string (0 = no max length)
            wordWrap = false, -- when a line is longer than the area width: cut the ligne when false, put the rest of the ligne in one or several lines when true
            newLine = "<br>", -- end of line delimiter
            lineHeight = 1, -- in units or pixels
            verticalAlignment = "top",

            font = nil,
            text = "",
            alignment = nil,
            opacity = nil,
        },

        componentObjectsByType = {
            Hud = GUI.Hud,
            Toggle = GUI.Toggle,
            ProgressBar = GUI.ProgressBar,
            Slider = GUI.Slider,
            Input = GUI.Input,
            TextArea = GUI.TextArea,
        },
        componentTypes = {},

        -- for the GameObject.Animate() functions in the Tween module
        propertiesByComponentName = {
            hud = {"position", "localPosition", "layer", "localLayer"},
            progressBar = {"value", "height"},
            slider = {"value"},
            textArea = {"text", "areaWidth", "lineHeight", "opacity"},
        }
    }

    return config
end
GUI.Config = GUI.DefaultConfig()

function GUI.Load()
    if Daneel.modules.Tween then
        table.mergein( Tween.Config.propertiesByComponentName, GUI.Config.propertiesByComponentName )
    end
end

-- Draw.lua
-- Module adding the Draw components.
--
-- Last modified for v1.4.0
-- Copyright © 2013-2014 Florent POUJOL, published under the MIT license.

Draw = {}
Daneel.modules.Draw = Draw

local functionsDebugInfo = {}
local s = "string"
local b = "boolean"
local n = "number"
local t = "table"
local v = "Vector3"
local _go = { "gameObject", "GameObject" }
local _p = { "params", t, defaultValue = {} }
local _l = { "line", "LineRenderer"}
local _c = { "circle", "CircleRenderer"}
local _d = { "draw", b, defaultValue = true }


----------------------------------------------------------------------------------
-- LineRenderer

Draw.LineRenderer = {}

functionsDebugInfo[ "Draw.LineRenderer.New" ] = { _go, _p }
--- Creates a new LineRenderer component.
-- @param gameObject (GameObject) The game object.
-- @param params (table) A table of parameters.
-- @return (LineRenderer) The new component.
function Draw.LineRenderer.New( gameObject, params )
    local line = {
        origin = gameObject.transform:GetPosition(),
        _direction = Vector3:Left(),
        _length = 1,
        _width = 1,
        gameObject = gameObject
    }
    line._endPosition = line.origin
    gameObject.lineRenderer = line

    setmetatable( line, Draw.LineRenderer )
    
    params = table.merge( Draw.Config.lineRenderer, params )
    if params.endPosition ~= nil then
        params.length = nil
        params.direction = nil
    end
    line:Set( params )

    return line
end

functionsDebugInfo[ "Draw.LineRenderer.Set" ] = { _l, _p }
--- Apply the content of the params argument to the provided line renderer.
-- Overwrite Component.Set().
-- @param line (LineRenderer) The line renderer.
-- @param params (table) A table of parameters.
function Draw.LineRenderer.Set( line, params )
    if params.endPosition then
        if params.length or params.direction then
            if Daneel.Config.debug.enableDebug then
                local text = "Draw.LineRenderer.Set( line, params ) : The 'endPosition' property is set with value "..tostring(params.endPosition)
                if params.length then
                    text = text.." The 'length' property with value '"..tostring( params.length ).."' has been ignored."
                end
                if params.direction then
                    text = text.." The 'direction' property with value '"..tostring( params.direction ).."' has been ignored."
                end
                print( text )
            end
            params.length = nil
            params.direction = nil
        end
    end

    local draw = false
    for key, value in pairs( params ) do
        local funcName = "Set"..string.ucfirst( key )
        if Draw.LineRenderer[ funcName ] ~= nil then
            draw = true
            if funcName == "SetDirection" then
                Draw.LineRenderer[ funcName ]( line, value, nil, false )
            else
                Draw.LineRenderer[ funcName ]( line, value, false )
            end
        else
            line[ key ] = value
        end
    end
    if draw then
        line:Draw()
    end
end

functionsDebugInfo[ "Draw.LineRenderer.Draw" ] = { _l }
--- Draw the line renderer. Updates the game object based on the line renderer's properties.
-- Fires the OnDraw event on the line renderer.
-- @param line (LineRenderer) The line renderer.
function Draw.LineRenderer.Draw( line )
    line.gameObject.transform:LookAt( line._endPosition )
    line.gameObject.transform:SetLocalScale( Vector3:New( line._width, line._width, line._length ) )
    Daneel.Event.Fire( line, "OnDraw", line )
end

functionsDebugInfo[ "Draw.LineRenderer.SetEndPosition" ] = { _l, { "endPosition", v }, _d }
--- Set the line renderer's end position.
-- It also updates the line renderer's direction and length.
-- @param line (LineRenderer) The line renderer.
-- @param endPosition (Vector3) The end position.
-- @param draw (boolean) [default=true] Tell whether to re-draw immediately the line renderer.
function Draw.LineRenderer.SetEndPosition( line, endPosition, draw )
    line._endPosition = endPosition
    line._direction = (line._endPosition - line.origin)
    line._length = line._direction:Length()
    if draw == nil or draw then
        line:Draw()
    end
end

functionsDebugInfo[ "Draw.LineRenderer.GetEndPosition" ] = { _l }
--- Returns the line renderer's end position.
-- @param line (LineRenderer) The line renderer.
-- @return (Vector3) The end position.
function Draw.LineRenderer.GetEndPosition( line )
    return line._endPosition
end

functionsDebugInfo[ "Draw.LineRenderer.SetLength" ] = { _l, { "length", n }, _d }
--- Set the line renderer's length.
-- It also updates line renderer's end position.
-- @param line (LineRenderer) The line renderer.
-- @param length (number) The length (in scene units).
-- @param draw (boolean) [default=true] Tell whether to re-draw immediately the line renderer.
function Draw.LineRenderer.SetLength( line, length, draw )
    line._length = length
    line._endPosition = line.origin + line._direction * length
    if draw == nil or draw then
        line:Draw()
    end
end

functionsDebugInfo[ "Draw.LineRenderer.GetLength" ] = { _l }
--- Returns the line renderer's length.
-- @param line (LineRenderer) The line renderer.
-- @return (number) The length (in scene units).
function Draw.LineRenderer.GetLength( line )
    return line._length
end

functionsDebugInfo[ "Draw.LineRenderer.SetWidth" ] = { _l, { "direction", v },
    { "useDirectionAsLength", b, defaultValue = false }, _d
}
--- Set the line renderer's direction.
-- It also updates line renderer's end position.
-- @param line (LineRenderer) The line renderer.
-- @param direction (Vector3) The direction.
-- @param useDirectionAsLength (boolean) [default=false] Tell whether to update the line renderer's length based on the provided direction's vector length.
-- @param draw (boolean) [default=true] Tell whether to re-draw immediately the line renderer.
function Draw.LineRenderer.SetDirection( line, direction, useDirectionAsLength, draw )
    line._direction = direction:Normalized()
    if useDirectionAsLength then
        line._length = direction:Length()
    end
    line._endPosition = line.origin + line._direction * line._length
    if draw == nil or draw then
        line:Draw()
    end
end

functionsDebugInfo[ "Draw.LineRenderer.GetDirection" ] = { _l }
--- Returns the line renderer's direction.
-- @param line (LineRenderer) The line renderer.
-- @return (Vector3) The direction.
function Draw.LineRenderer.GetDirection( line )
    return line._direction
end

functionsDebugInfo[ "Draw.LineRenderer.SetWidth" ] = { _l, { "width", n }, _d }
--- Set the line renderer's width (and height).
-- @param line (LineRenderer) The line renderer.
-- @param width (number) The width (in scene units).
-- @param draw (boolean) [default=true] Tell whether to re-draw immediately the line renderer.
function Draw.LineRenderer.SetWidth( line, width, draw )
    line._width = width
    if draw == nil or draw then
        line:Draw()
    end
end

functionsDebugInfo[ "Draw.LineRenderer.GetWidth" ] = { _l }
--- Returns the line renderer's width.
-- @param line (LineRenderer) The line renderer.
-- @return (number) The width.
function Draw.LineRenderer.GetWidth( line )
    return line._width
end

----------------------------------------------------------------------------------
-- CircleRenderer

Draw.CircleRenderer = {}

functionsDebugInfo[ "Draw.CircleRenderer.New" ] = { _go, _p }
--- Creates a new circle renderer component.
-- @param gameObject (GameObject) The game object.
-- @param params (table) A table of parameters.
-- @return (CircleRenderer) The new component.
function Draw.CircleRenderer.New( gameObject, params )   
    local circle = {
        gameObject = gameObject,
        origin = gameObject.transform:GetPosition(),
        segments = {}, -- game objects
        _segmentCount = 6,
        _radius = 1,
        _width = 1,
        _model = nil, -- model asset
    }
    circle._endPosition = circle.origin
    gameObject.circleRenderer = circle

    -- allow to set the circle renderer's model via a model renderer 
    if params.model == nil and gameObject.modelRenderer ~= nil then
        params.model = gameObject.modelRenderer:GetModel()
        gameObject.modelRenderer:SetModel( nil )
    end

    setmetatable( circle, Draw.CircleRenderer )
    circle:Set( table.merge( Draw.Config.circleRenderer, params ) )

    return circle
end

functionsDebugInfo[ "Draw.CircleRenderer.Set" ] = { _c, _p }
--- Apply the content of the params argument to the provided circle renderer.
-- Overwrite Component.Set().
-- @param circle (CircleRenderer) The circle renderer.
-- @param params (table) A table of parameters.
function Draw.CircleRenderer.Set( circle, params )
    local draw = false
    for key, value in pairs( params ) do
        local funcName = "Set"..string.ucfirst( key )
        if Draw.CircleRenderer[ funcName ] ~= nil then
            draw = true
            Draw.CircleRenderer[ funcName ]( circle, value, false )
        else
            circle[ key ] = value
        end
    end
    if draw then
        circle:Draw()
    end
end

functionsDebugInfo[ "Draw.CircleRenderer.Draw" ] = { _c }
--- Draw the circle renderer. Updates the game object based on the circle renderer's properties.
-- Fires the OnDraw event at the circle renderer.
-- @param circle (CircleRenderer) The circle renderer.
function Draw.CircleRenderer.Draw( circle )
    -- coordinate of a point on a circle
    -- x = center.x + radius * cos( angleInRadian )
    -- y = center.y + radius * sin( angleInRadian )

    local offset = (2*math.pi) / circle._segmentCount
    local angle = -offset
    local circleId = circle:GetId()

    -- create and position the segments
    for i=1, circle._segmentCount do
        angle = angle + offset
        local lineStartLocalPosition = Vector3:New(
            circle._radius * math.cos( angle ),
            circle._radius * math.sin( angle ),
            0
        )

        if circle.segments[ i ] == nil then
            local newSegment = CS.CreateGameObject( "Circle "..circleId.." Segment "..i, circle.gameObject )
            newSegment:CreateComponent( "ModelRenderer" )
            if circle._model ~= nil then
                newSegment.modelRenderer:SetModel( circle._model )
            end
            table.insert( circle.segments, i, newSegment )
        end

        circle.segments[ i ].transform:SetLocalPosition( lineStartLocalPosition )
    end

    -- destroy unused gameObjects
    while #circle.segments > circle._segmentCount do
        table.remove( circle.segments ):Destroy()
    end
    
    local firstSegmentPosition = circle.segments[1].transform:GetPosition()
    local segmentLength = Vector3.Distance( firstSegmentPosition, circle.segments[2].transform:GetPosition() )
    
    -- scale the segments, setting their width and length
    for i, segment in ipairs( circle.segments ) do
        if circle.segments[ i+1 ] ~= nil then
            segment.transform:LookAt( circle.segments[ i+1 ].transform:GetPosition() )
        else
            segment.transform:LookAt( firstSegmentPosition )
        end
        segment.transform:SetLocalScale( Vector3:New( circle._width, circle._width, segmentLength ) )
    end
    
    Daneel.Event.Fire( circle, "OnDraw", circle )
end

functionsDebugInfo[ "Draw.CircleRenderer.SetRadius" ] = { _c, { "radius", n }, _d }
--- Sets the circle renderer's radius.
-- @param circle (CircleRenderer) The circle renderer.
-- @param radius (number) The radius (in scene units).
-- @param draw (boolean) [default=true] Tell whether to re-draw immediately the circle renderer.
function Draw.CircleRenderer.SetRadius( circle, radius, draw )
    circle._radius = radius
    if draw == nil or draw then
        circle:Draw()
    end
end

functionsDebugInfo[ "Draw.CircleRenderer.GetRadius" ] = { _c }
--- Returns the circle renderer's radius.
-- @param circle (CircleRenderer) The circle renderer.
-- @return (number) The radius (in scene units).
function Draw.CircleRenderer.GetRadius( circle )
    return circle._radius
end

functionsDebugInfo[ "Draw.CircleRenderer.SetSegmentCount" ] = { _c, { "count", n }, _d }
--- Sets the circle renderer's segment count.
-- @param circle (CircleRenderer) The circle renderer.
-- @param count (number) The segment count (can't be lower than 3).
-- @param draw (boolean) [default=true] Tell whether to re-draw immediately the circle renderer.
function Draw.CircleRenderer.SetSegmentCount( circle, count, draw )
    if count < 3 then count = 3 end
    if circle._segmentCount ~= count then
        circle._segmentCount = count
        if draw == nil or draw then
            circle:Draw()
        end
    end
end

functionsDebugInfo[ "Draw.CircleRenderer.GetSegmentCount" ] = { _c }
--- Returns the circle renderer's number of segments.
-- @param circle (CircleRenderer) The circle renderer.
-- @return (number) The segment count.
function Draw.CircleRenderer.GetSegmentCount( circle )
    return circle._segmentCount
end

functionsDebugInfo[ "Draw.CircleRenderer.SetWidth" ] = { _c, { "width", n } }
--- Sets the circle renderer segment's width.
-- @param circle (CircleRenderer) The circle renderer.
-- @param width (number) The segment's width (and height).
function Draw.CircleRenderer.SetWidth( circle, width )
    if circle._width ~= width then
        circle._width = width
        if #circle.segments > 0 and draw then
            local newScale = Vector3:New( circle._width, circle._width, circle.segments[1].transform:GetLocalScale().z )
            for i, line in pairs( circle.segments ) do
                line.transform:SetLocalScale( newScale )
            end
        end
    end
end

functionsDebugInfo[ "Draw.CircleRenderer.GetWidth" ] = { _c }
--- Returns the circle renderer's segment's width (and height).
-- @param circle (CircleRenderer) The circle renderer.
-- @return (number) The width (in scene units).
function Draw.CircleRenderer.GetWidth( circle )
    return circle._width
end

functionsDebugInfo[ "Draw.CircleRenderer.SetModel" ] = { _c, { "model", {"string", "Model"}, isOptional = true } }
--- Sets the circle renderer segment's model.
-- @param circle (CircleRenderer) The circle renderer.
-- @param model (string or Model) [optional] The segment's model name or asset, or nil.
function Draw.CircleRenderer.SetModel( circle, model )
    if 
        circle._model ~= model -- always true when model is of type string
    then
        if type( model ) == "sting" and circle._model ~= nil and circle._model:GetPath() == model then
            -- prevent setting the model if it is already set to this model's path
            return
        end
        if model ~= nil then
            circle._model = Asset.Get( model, "Model", true )
        else
            circle._model = nil
        end
        for i, line in pairs( circle.segments ) do
            line.modelRenderer:SetModel( circle._model )
        end
    end
end

functionsDebugInfo[ "Draw.CircleRenderer.GetModel" ] = { _c }
--- Returns the circle renderer's segment's model.
-- @param circle (CircleRenderer) The circle renderer.
-- @return (Model) The model asset.
function Draw.CircleRenderer.GetModel( circle )
    return circle._model
end

functionsDebugInfo[ "Draw.CircleRenderer.SetOpacity" ] = { _c, { "opacity", "number" } }
--- Sets the circle renderer segments' opacity.
-- @param circle (CircleRenderer) The circle renderer.
-- @param opacity (number) The opacity.
function Draw.CircleRenderer.SetOpacity( circle, opacity )  
    for i=1, #cicle.segments do
        circle.segments[i].modelRenderer:SetOpacity( opacity )
    end
end

functionsDebugInfo[ "Draw.CircleRenderer.GetOpacity" ] = { _c }
--- Returns the circle renderer's segments' opacity.
-- @param circle (CircleRenderer) The circle renderer.
-- @return (number) The opacity (nil if the circle renderer has no segment).
function Draw.CircleRenderer.GetOpacity( circle )
    if circle.segments[1] ~= nil then
        return circle.segments[1].modelRenderer:GetOpacity()
    end
    return nil
end


----------------------------------------------------------------------------------

table.mergein( Daneel.Debug.functionArgumentsInfo, functionsDebugInfo )

function Draw.DefaultConfig()
    local config = {
        lineRenderer = {
            direction = Vector3:Left(),
            length = 2,
            width = 0.1,
            --endPosition = nil -- Vector3
        },

        circleRenderer = {
            segmentCount = 6,
            radius = 1,
            width = 1,
            model = nil, -- model name or asset
        },
        
        componentObjectsByType = {
            LineRenderer = Draw.LineRenderer,
            CircleRenderer = Draw.CircleRenderer,
        },

        -- for the GameObject.Animate() functions in the Tween module
        propertiesByComponentName = {
            lineRenderer = { "length", "endPosition", "direction", "width" },
            circleRenderer = { "radius", "segmentCount", "direction", "width", "opacity" },
        }
    }

    return config
end
Draw.Config = Draw.DefaultConfig()

function Draw.Load()
    if Daneel.modules.Tween then
        table.mergein( Tween.Config.propertiesByComponentName, Draw.Config.propertiesByComponentName )
    end
end

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

-- Tween.lua
-- Module adding the Tweener and Timer objects, and the easing equations.
--
-- Last modified for v1.5.0
-- Copyright © 2013-2014 Florent POUJOL, published under the MIT license.

Tween = {}

-- Allow to get the target's "property" even if it's virtual and normally handled via getter/setter.
local function GetTweenerProperty(tweener)
    if tweener.target ~= nil then
        Daneel.Debug.StackTrace.BeginFunction("GetTweenerProperty", tweener)
        local value = nil
        value = tweener.target[tweener.property]
        if value == nil then
            -- 04/06/2014 : this piece of code allows tweeners to work even on objects that do not have Daneel's dynamic getters and setters.
            local functionName = "Get"..string.ucfirst( tweener.property )
            if tweener.target[functionName] ~= nil then
                value = tweener.target[functionName](tweener.target)
            end
        end
        Daneel.Debug.StackTrace.EndFunction()
        return value
    end
end

-- Allow to set the target's "property" even if it's virtual and normally handled via getter/setter.
local function SetTweenerProperty(tweener, value)
    if tweener.target ~= nil then
        Daneel.Debug.StackTrace.BeginFunction("SetTweenerProperty", tweener, value)
        if tweener.valueType == "string" then
            -- don't update the property unless the text has actually changed
            if type(value) == "number" and value >= #tweener.stringValue + 1 then               
                local newValue = tweener.startStringValue..tweener.endStringValue:sub( 1, value )
                if newValue ~= tweener.stringValue then
                    tweener.stringValue = newValue
                    value = newValue
                else 
                    return
                end
            else
                return
            end
        end
        if tweener.target[tweener.property] == nil then
            local functionName = "Set"..string.ucfirst( tweener.property )
            if tweener.target[functionName] ~= nil then
                tweener.target[functionName](tweener.target, tweener.property)
            end
        else
            tweener.target[tweener.property] = value
        end
        Daneel.Debug.StackTrace.EndFunction()
    end
end

----------------------------------------------------------------------------------
-- Tweener

Tween.Tweener = { tweeners = {} }
Tween.Tweener.__index = Tween.Tweener
setmetatable(Tween.Tweener, { __call = function(Object, ...) return Object.New(...) end })

function Tween.Tweener.__tostring(tweener)
    return "Tweener: " .. tweener.id
end

--- Creates a new tweener via one of the three allowed constructors : <br>
-- Tweener.New(target, property, endValue, duration[, params]) <br>
-- Tweener.New(startValue, endValue, duration[, params]) <br>
-- Tweener.New(params)
-- @param target (table) An object.
-- @param property (string) The name of the propertty to animate.
-- @param endValue (number) The value the property should have at the end of the duration.
-- @param duration (number) The time or frame it should take for the property to reach endValue.
-- @param onCompleteCallback (function) [optional] The function to execute when the tweener has completed.
-- @param params (table) [optional] A table of parameters.
-- @return (Tweener) The Tweener.
function Tween.Tweener.New(target, property, endValue, duration, onCompleteCallback, params)
    Daneel.Debug.StackTrace.BeginFunction("Tween.Tweener.New", target, property, endValue, duration, params)
    local errorHead = "Tween.Tweener.New(target, property, endValue, duration[, params]) : "
    
    local tweener = table.copy(Tween.Config.tweener)
    setmetatable(tweener, Tween.Tweener)
    tweener.id = Daneel.Utilities.GetId()

    -- three constructors :
    -- target, property, endValue, duration, [onCompleteCallback, params]
    -- startValue, endValue, duration, [onCompleteCallback, params]
    -- params
    local targetType = type( target )
    local mt = nil
    if targetType == "table" then 
        mt = getmetatable( target )
    end

    if 
        targetType == "number" or targetType == "string" or 
        mt == Vector2 or mt == Vector3
    then
        -- constructor n°2
        params = onCompleteCallback
        onCompleteCallback = duration
        duration = endValue
        endValue = property
        local startValue = target
        
        errorHead = "Tween.Tweener.New(startValue, endValue, duration[, onCompleteCallback, params]) : "

        Daneel.Debug.CheckArgType(duration, "duration", "number", errorHead)
        if type( onCompleteCallback ) == "table" then
            params = onCompleteCallback
            onCompleteCallback = nil
        end
        Daneel.Debug.CheckOptionalArgType(onCompleteCallback, "onCompleteCallback", "function", errorHead)
        Daneel.Debug.CheckOptionalArgType(params, "params", "table", errorHead)

        tweener.startValue = startValue
        tweener.endValue = endValue
        tweener.duration = duration
        if onCompleteCallback ~= nil then
            tweener.OnComplete = onCompleteCallback
        end
        if params ~= nil then
            tweener:Set(params)
        end
    elseif property == nil then
        -- constructor n°3
        Daneel.Debug.CheckArgType(target, "params", "table", errorHead)
        errorHead = "Tween.Tweener.New(params) : "
        tweener:Set(target)
    else
        -- constructor n°1
        Daneel.Debug.CheckArgType(target, "target", "table", errorHead)
        Daneel.Debug.CheckArgType(property, "property", "string", errorHead)
        Daneel.Debug.CheckArgType(duration, "duration", "number", errorHead)
        if type( onCompleteCallback ) == "table" then
            params = onCompleteCallback
            onCompleteCallback = nil
        end
        Daneel.Debug.CheckOptionalArgType(onCompleteCallback, "onCompleteCallback", "function", errorHead)
        Daneel.Debug.CheckOptionalArgType(params, "params", "table", errorHead)

        tweener.target = target
        tweener.property = property
        tweener.endValue = endValue
        tweener.duration = duration
        if onCompleteCallback ~= nil then
            tweener.OnComplete = onCompleteCallback
        end
        if params ~= nil then
            tweener:Set(params)
        end
    end

    if tweener.endValue == nil then
        error("Tween.Tweener.New(): 'endValue' property is nil for tweener: "..tostring(tweener))
    end
    
    if tweener.startValue == nil then
        tweener.startValue = GetTweenerProperty( tweener )
    end

    if tweener.target ~= nil then
        tweener.gameObject = tweener.target.gameObject
    end

    tweener.valueType = Daneel.Debug.GetType( tweener.startValue )

    if tweener.valueType == "string" then
        tweener.startStringValue = tweener.startValue
        tweener.stringValue = tweener.startStringValue
        tweener.endStringValue = tweener.endValue
        tweener.startValue = 1
        tweener.endValue = #tweener.endStringValue
    end
    
    Tween.Tweener.tweeners[tweener.id] = tweener
    Daneel.Debug.StackTrace.EndFunction()
    return tweener
end

-- Sets parameters in mass.
-- Should not be used after the tweener has been created.
-- That's why it is not in the function reference.
function Tween.Tweener.Set(tweener, params)
    Daneel.Debug.StackTrace.BeginFunction("Tween.Tweener.Set", tweener, params)
    local errorHead = "Tween.Tweener.Set(tweener, params) : "
    Daneel.Debug.CheckArgType(tweener, "tweener", "Tween.Tweener", errorHead)

    for key, value in pairs(params) do
        tweener[key] = value
    end
    Daneel.Debug.StackTrace.EndFunction()
    return tweener
end

--- Unpause the tweener and fire the OnPlay event.
-- @param tweener (Tween.Tweener) The tweener.
function Tween.Tweener.Play(tweener)
    if tweener.isEnabled == false then return end
    Daneel.Debug.StackTrace.BeginFunction("Tween.Tweener.Play", tweener)
    local errorHead = "Tween.Tweener.Play(tweener) : "
    Daneel.Debug.CheckArgType(tweener, "tweener", "Tween.Tweener", errorHead)

    tweener.isPaused = false
    Daneel.Event.Fire(tweener, "OnPlay", tweener)
    Daneel.Debug.StackTrace.EndFunction()
end

--- Pause the tweener and fire the OnPause event.
-- @param tweener (Tween.Tweener) The tweener.
function Tween.Tweener.Pause(tweener)
    if tweener.isEnabled == false then return end
    Daneel.Debug.StackTrace.BeginFunction("Tween.Tweener.Pause", tweener)
    local errorHead = "Tween.Tweener.Pause(tweener) : "
    Daneel.Debug.CheckArgType(tweener, "tweener", "Tween.Tweener", errorHead)

    tweener.isPaused = true
    Daneel.Event.Fire(tweener, "OnPause", tweener)
    Daneel.Debug.StackTrace.EndFunction()
end

--- Completely restart the tweener.
-- @param tweener (Tween.Tweener) The tweener.
function Tween.Tweener.Restart(tweener)
    if tweener.isEnabled == false then return end
    Daneel.Debug.StackTrace.BeginFunction("Tween.Tweener.Restart", tweener)
    local errorHead = "Tween.Tweener.Restart(tweener) : "
    Daneel.Debug.CheckArgType(tweener, "tweener", "Tween.Tweener", errorHead)

    tweener.elapsed = 0
    tweener.fullElapsed = 0
    tweener.elapsedDelay = 0
    tweener.completedLoops = 0
    tweener.isCompleted = false
    tweener.hasStarted = false
    local startValue = tweener.startValue
    if tweener.loopType == "yoyo" and tweener.completedLoops % 2 ~= 0 then -- the current loop is Y to X, so endValue and startValue are inversed
        startValue = tweener.endValue
    end
    if tweener.target ~= nil then
        SetTweenerProperty(tweener, startValue)
    end
    tweener.value = startValue
    Daneel.Debug.StackTrace.EndFunction()
end

--- Complete the tweener fire the OnComple event.
-- @param tweener (Tween.Tweener) The tweener.
function Tween.Tweener.Complete( tweener )
    if tweener.isEnabled == false or tweener.loops == -1 then return end
    Daneel.Debug.StackTrace.BeginFunction( "Tween.Tweener.Complete", tweener )
    local errorHead = "Tween.Tweener.Complete( tweener ) : "
    Daneel.Debug.CheckArgType( tweener, "tweener", "Tween.Tweener", errorHead )

    tweener.isCompleted = true
    local endValue = tweener.endValue
    if tweener.loopType == "yoyo" then
        if tweener.loops % 2 == 0 and tweener.completedLoops % 2 == 0 then -- endValue must be original startValue (because of even number of loops) | current X to Y loop, 
            endValue = tweener.startValue
        elseif tweener.loops % 2 ~= 0 and tweener.completedLoops % 2 ~= 0 then -- endValue must be the original endValue but the current loop is Y to X, so endValue and startValue are inversed
            endValue = tweener.startValue
        end
        -- Condition done this way so Luamin does mess it.
        -- Original condition was :
        -- if (tweener.loops % 2 == 0 and tweener.completedLoops % 2 == 0) or
        --    (tweener.loops % 2 ~= 0 and tweener.completedLoops % 2 ~= 0) then
    end
    if tweener.target ~= nil then
        SetTweenerProperty( tweener, endValue )
    end
    tweener.value = endValue
    
    Daneel.Event.Fire( tweener, "OnComplete", tweener )
    if tweener.destroyOnComplete then
        tweener:Destroy()
    end

    Daneel.Debug.StackTrace.EndFunction()
end

-- Tell whether the provided game object has been destroyed.
-- @param gameObject (GameObject) The game object.
-- @return (boolean)
local function isGameObjectDestroyed( gameObject )
    return gameObject.isDestroyed == true or gameObject.inner == nil
end

-- Tell whether the tweener's target has been destroyed.
-- @param tweener (Tween.Tweener) The tweener.
-- @return (boolean)
function Tween.Tweener.IsTargetDestroyed( tweener )
    if tweener.target ~= nil then
        if tweener.target.isDestroyed then
            return true
        end
        if tweener.target.gameObject ~= nil and isGameObjectDestroyed( tweener.target.gameObject ) then 
            -- isGameObjectDestroyed() is used here so that Luamin doesn't mess up the condition.
            return true
        end
    end
    if tweener.gameObject ~= nil and isGameObjectDestroyed( tweener.gameObject ) then
        return true
    end
    return false
end

--- Destroy the tweener.
-- @param tweener (Tween.Tweener) The tweener.
function Tween.Tweener.Destroy( tweener )
    Daneel.Debug.StackTrace.BeginFunction( "Tween.Tweener.Destroy", tweener )
    local errorHead = "Tween.Tweener.Destroy( tweener ) : "
    Daneel.Debug.CheckArgType( tweener, "tweener", "Tween.Tweener", errorHead )

    tweener.isEnabled = false
    tweener.isPaused = true
    tweener.target = nil
    tweener.duration = 0

    Tween.Tweener.tweeners[ tweener.id ] = nil
    CraftStudio.Destroy( tweener )
    Daneel.Debug.StackTrace.EndFunction()
end

--- Update the tweener's value based on the tweener's elapsed property.
-- Fire the OnUpdate event.
-- This allows the tweener to fast-forward to a certain time.
-- @param tweener (Tween.Tweener) The tweener.
-- @param deltaDuration [optional] (number) <strong>Only used internaly.</strong> If nil, the tweener's value will be updated based on the current value of tweener.elapsed.
function Tween.Tweener.Update(tweener, deltaDuration) -- the deltaDuration argument is only used from the Tween.Update() function
    if tweener.isEnabled == false then return end
    Daneel.Debug.StackTrace.BeginFunction("Tween.Tweener.Update", tweener, deltaDuration)
    local errorHead = "Tween.Tweener.Update(tweener[, deltaDuration]) : "
    Daneel.Debug.CheckArgType(tweener, "tweener", "Tween.Tweener", errorHead)
    Daneel.Debug.CheckArgType(deltaDuration, "deltaDuration", "number", errorHead)

    if Tween.Ease[tweener.easeType] == nil then
        if Daneel.Config.debug.enableDebug then
            print("Tween.Tweener.Update() : Easing '"..tostring(tweener.easeType).."' for tweener ID '"..tween.id.."' does not exists. Setting it back for the default easing '"..Tween.Config.tweener.easeType.."'.")
        end
        tweener.easeType = Tween.Config.tweener.easeType
    end

    if deltaDuration ~= nil then
        tweener.elapsed = tweener.elapsed + deltaDuration
        tweener.fullElapsed = tweener.fullElapsed + deltaDuration
    end
    local value = nil

    if tweener.elapsed > tweener.duration then
        tweener.isCompleted = true
        tweener.elapsed = tweener.duration
        if tweener.isRelative == true then
            value = tweener.startValue + tweener.endValue
        else
            value = tweener.endValue
        end
    else
        if tweener.valueType == "Vector3" then
            value = Vector3:New(
                Tween.Ease[tweener.easeType](tweener.elapsed, tweener.startValue.x, tweener.diffValue.x, tweener.duration),
                Tween.Ease[tweener.easeType](tweener.elapsed, tweener.startValue.y, tweener.diffValue.y, tweener.duration),
                Tween.Ease[tweener.easeType](tweener.elapsed, tweener.startValue.z, tweener.diffValue.z, tweener.duration)
            )
        elseif tweener.valueType == "Vector2" then
            value = Vector2.New(
                Tween.Ease[tweener.easeType](tweener.elapsed, tweener.startValue.x, tweener.diffValue.x, tweener.duration),
                Tween.Ease[tweener.easeType](tweener.elapsed, tweener.startValue.y, tweener.diffValue.y, tweener.duration)
            )
        else -- tweener.valueType == number or string
            -- when valueType == string, value represent the number of chars that must be displayed
            value = Tween.Ease[tweener.easeType](tweener.elapsed, tweener.startValue, tweener.diffValue, tweener.duration)
        end
    end

    if tweener.target ~= nil then
        SetTweenerProperty(tweener, value)
        -- when valueType == string, SetTweenerProperty() sets tweener.stringValue
    end
    tweener.value = value

    Daneel.Event.Fire(tweener, "OnUpdate", tweener)
    Daneel.Debug.StackTrace.EndFunction()
end

----------------------------------------------------------------------------------
-- Timer

Tween.Timer = {}
Tween.Timer.__index = Tween.Tweener
setmetatable( Tween.Timer, { __call = function(Object, ...) return Object.New(...) end } )


--- Creates a new tweener via one of the two allowed constructors : <br>
-- Timer.New(duration, OnCompleteCallback[, params]) <br>
-- Timer.New(duration, OnLoopCompleteCallback, true[, params]) <br>
-- @param duration (number) The time or frame it should take for the timer or one loop to complete.
-- @param callback (function or userdata) The function that gets called when the OnComplete or OnLoopComplete event are fired.
-- @param isInfiniteLoop [optional default=false] (boolean) Tell wether the timer loops indefinitely.
-- @param params [optional] (table) A table of parameters.
-- @return (Tweener) The tweener.
function Tween.Timer.New( duration, callback, isInfiniteLoop, params )  
    Daneel.Debug.StackTrace.BeginFunction( "Tween.Timer.New", duration, callback, isInfiniteLoop, params )
    local errorHead = "Tween.Timer.New( duration, callback[, isInfiniteLoop, params] ) : "
    if type( isInfiniteLoop ) == "table" then
        params = isInfiniteLoop
        errorHead = "Tween.Timer.New( duration, callback[, params] ) : "
    end
    Daneel.Debug.CheckArgType( duration, "duration", "number", errorHead )
    Daneel.Debug.CheckArgType( callback, "callback", {"function", "userdata"}, errorHead )
    Daneel.Debug.CheckOptionalArgType( params, "params", "table", errorHead )

    local tweener = table.copy( Tween.Config.tweener )
    setmetatable( tweener, Tween.Tweener )
    tweener.id = Daneel.Utilities.GetId()
    tweener.startValue = duration
    tweener.endValue = 0
    tweener.duration = duration

    if isInfiniteLoop == true then
        tweener.loops = -1
        tweener.OnLoopComplete = callback
    else
        tweener.OnComplete = callback
    end
    if params ~= nil then
        tweener:Set( params )
    end

    Tween.Tweener.tweeners[ tweener.id ] = tweener
    Daneel.Debug.StackTrace.EndFunction()
    return tweener
end

----------------------------------------------------------------------------------
-- Config - Loading

Daneel.modules.Tween = Tween

function Tween.DefaultConfig()
    local config = {
        tweener = {
            isEnabled = true, -- a disabled tweener won't update but the function like Play(), Pause(), Complete(), Destroy() will have no effect
            isPaused = false,

            delay = 0.0, -- delay before the tweener starts (in the same time unit as the duration (durationType))
            duration = 0.0, -- time or frames the tween (or one loop) should take (in durationType unit)
            durationType = "time", -- the unit of time for delay, duration, elapsed and fullElapsed. Can be "time", "realTime" or "frame"

            startValue = nil, -- it will be the current value of the target's property
            endValue = 0.0,

            loops = 0, -- number of loops to perform (-1 = infinite)
            loopType = "simple", -- type of loop. Can be "simple" (X to Y, repeat), "yoyo" (X to Y, Y to X, repeat)
            
            easeType = "linear", -- type of easing, check the doc or the end of the "Daneel/Lib/Easing" script for all possible values
            
            isRelative = false, -- If false, tween the value TO endValue. If true, tween the value BY endValue.

            destroyOnComplete = true, -- tell wether to destroy the tweener (true) when it completes
            destroyOnSceneLoad = true, -- tell wether to destroy the tweener (true) or keep it 'alive' (false) when the scene is changing

            updateInterval = 1, 

            ------------
            -- "read-only" properties or properties the user has no interest to change the value of

            Id = -1, -- can be anything, not restricted to numbers
            hasStarted = false,
            isCompleted = false,
            elapsed = 0, -- elapsed time or frame (in durationType unit), delay excluded
            fullElapsed = 0, -- elapsed time, including loops, excluding delay
            elapsedDelay = 0,
            completedLoops = 0,
            diffValue = 0.0, -- endValue - startValue
            value = 0.0, -- current value (between startValue and endValue)
            frameCount = 0,
        },
    
        objectsByType = {
            ["Tween.Tweener"] = Tween.Tweener,
        },

        propertiesByComponentName = {
            transform = {
                "scale", "localScale",
                "position", "localPosition",
                "eulerAngles", "localEulerAngles",
            },
            modelRenderer = { "opacity" },
            mapRenderer = { "opacity" },
            textRenderer = { "text", "opacity" },
            camera = { "fov" },
        }
    }

    return config
end
Tween.Config = Tween.DefaultConfig()

function Tween.Awake()
    -- In Awake() to let other modules update Tween.Config.propertiesByComponentName from their Load() function
    -- Actually this should be done automatically (without things to set up in the config) by looking up the functions on the components' objects
    local t = {}
    for compName, properties in pairs( Tween.Config.propertiesByComponentName ) do
        for i=1, #properties do
            local property = properties[i]
            t[ property ] = t[ property ] or {}
            table.insert( t[ property ], compName )
        end
    end
    Tween.Config.componentNamesByProperty = t

    -- destroy and sanitize the tweeners when the scene loads
    for id, tweener in pairs( Tween.Tweener.tweeners ) do
        if tweener.destroyOnSceneLoad then
            tweener:Destroy()
        end
    end
end

function Tween.Update()
    for id, tweener in pairs( Tween.Tweener.tweeners ) do
        if tweener:IsTargetDestroyed() then
            tweener:Destroy()
        end

        if tweener.isEnabled == true and tweener.isPaused == false and tweener.isCompleted == false and tweener.duration > 0 then
            tweener.frameCount = tweener.frameCount + 1

            if tweener.frameCount % tweener.updateInterval == 0 then

                local deltaDuration = Daneel.Time.deltaTime * tweener.updateInterval               
                if tweener.durationType == "realTime" then
                    deltaDuration = Daneel.Time.realDeltaTime * tweener.updateInterval
                elseif tweener.durationType == "frame" then
                    deltaDuration = tweener.updateInterval
                end

                if deltaDuration > 0 then
                    if tweener.elapsedDelay >= tweener.delay then
                        -- no more delay before starting the tweener, update the tweener
                        if tweener.hasStarted == false then
                            -- firt loop for this tweener
                            tweener.hasStarted = true
                            
                            if tweener.startValue == nil then
                                if tweener.target ~= nil then
                                    tweener.startValue = GetTweenerProperty( tweener )
                                else
                                    error( "Tween.Update() : startValue is nil but no target is set for tweener: "..tostring(tweener) )
                                end
                            elseif tweener.target ~= nil then
                                -- when start value and a target are set move the target to startValue before updating the tweener
                                SetTweenerProperty( tweener, tweener.startValue )
                            end
                            tweener.value = tweener.startValue

                            if tweener.isRelative == true then
                                tweener.diffValue = tweener.endValue
                            else
                                tweener.diffValue = tweener.endValue - tweener.startValue
                            end

                            Daneel.Event.Fire( tweener, "OnStart", tweener )
                        end
                        
                        -- update the tweener
                        tweener:Update( deltaDuration )
                    else
                        tweener.elapsedDelay = tweener.elapsedDelay + deltaDuration
                    end -- end if tweener.delay <= 0


                    if tweener.isCompleted == true then
                        tweener.completedLoops = tweener.completedLoops + 1
                        if tweener.loops == -1 or tweener.completedLoops < tweener.loops then
                            tweener.isCompleted = false
                            tweener.elapsed = 0

                            if tweener.loopType:lower() == "yoyo" then
                                local startValue = tweener.startValue
                                
                                if tweener.isRelative then
                                    tweener.startValue = tweener.value
                                    tweener.endValue = -tweener.endValue
                                    tweener.diffValue = tweener.endValue
                                else
                                    tweener.startValue = tweener.endValue
                                    tweener.endValue = startValue
                                    tweener.diffValue = -tweener.diffValue
                                end

                            elseif tweener.target ~= nil then
                                SetTweenerProperty( tweener, tweener.startValue )
                            end

                            tweener.value = tweener.startValue
                            Daneel.Event.Fire( tweener, "OnLoopComplete", tweener )

                        else
                            Daneel.Event.Fire( tweener, "OnComplete", tweener )
                            if tweener.destroyOnComplete and tweener.Destroy ~= nil then
                                -- tweener.Destroy may be nil if a new scene is loaded from the OnComplete callback
                                -- the tweener will have been destroyed already an its metatable stripped
                                tweener:Destroy()
                            end
                        end
                    end
                end -- end if deltaDuration > 0
            end -- end if tweener.frameCount % tweener.updateInterval == 0
        end -- end if tweener.isEnabled == true
    end -- end for tweeners
end -- end Tween.Update

----------------------------------------------------------------------------------
-- GameObject

-- Find the component that has the provided property on the provided game object.
-- @param gameObject (GameObject) The game object.
-- @param property (string) The property.
-- @return (a component) The component.
local function resolveTarget( gameObject, property )
    local component = nil
    if 
        (property == "position" or property == "localPosition") and -- let the parenthesis at the beginning of the condition, or they will be removed by Luamin !
        GUI ~= nil and GUI.Hud ~= nil and gameObject.hud ~= nil
        -- 02/06/2014 - This is bad, this code should be handled by the GUI module itself
        -- but I have no idea how to properly set that up easily
        -- Plus I really should test the type of the endValue instead (in case it's a Vector3 for instance beacuse the user whants to work on the transform and not the hud)
    then
        component = gameObject.hud
    elseif property == "text" and GUI ~= nil and GUI.TextArea ~= nil and gameObject.textArea ~= nil then
        component = gameObject.textArea
    else
        local compNames = Tween.Config.componentNamesByProperty[ property ]
        if compNames ~= nil then
            for i=1, #compNames do
                component = gameObject[ compNames[i] ]
                if component ~= nil then
                    break
                end
            end
        end
    end
    if component == nil then
        error("Tween: resolveTarget(): Couldn't resolve the target for property '"..property.."' and gameObject: "..tostring(gameObject))
    end
    return component
end

--- Creates an animation (a tweener) with the provided parameters.
-- @param property (string) The name of the property to animate.
-- @param endValue (number, Vector2, Vector3 or string) The value the property should have at the end of the duration.
-- @param duration (number) The time (in seconds) or frame it should take for the property to reach endValue.
-- @param onCompleteCallback (function) [optional] The function to execute when the tweener has completed.
-- @param params (table) [optional] A table of parameters.
-- @return (Tweener) The tweener.
function GameObject.Animate( gameObject, property, endValue, duration, onCompleteCallback, params )
    local component = nil
    if type( onCompleteCallback ) == "table" and params == nil then
        params = onCompleteCallback
        onCompleteCallback = nil
    end
    if params ~= nil and params.target ~= nil then
        component = params.target
    else
        component = resolveTarget( gameObject, property )
    end
    return Tween.Tweener.New( component, property, endValue, duration, onCompleteCallback, params )   
end

----------------------------------------------------------------------------------
-- Easing equations
-- From Emmanuel Oga's easing equations : https://github.com/EmmanuelOga/easing

--
-- Adapted from
-- Tweener's easing functions (Penner's Easing Equations)
-- and http://code.google.com/p/tweener/ (jstweener javascript version)
--

--[[
Disclaimer for Robert Penner's Easing Equations license:

TERMS OF USE - EASING EQUATIONS

Open source under the BSD License.

Copyright © 2001 Robert Penner
All rights reserved.

Redistribution and use in source and binary forms, with or without modification, are permitted provided that the following conditions are met:

* Redistributions of source code must retain the above copyright notice, this list of conditions and the following disclaimer.
* Redistributions in binary form must reproduce the above copyright notice, this list of conditions and the following disclaimer in the documentation and/or other materials provided with the distribution.
* Neither the name of the author nor the names of contributors may be used to endorse or promote products derived from this software without specific prior written permission.

THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
]]

-- For all easing functions:
-- t = elapsed time
-- b = begin
-- c = change == ending - beginning
-- d = duration (total time)

local pow = math.pow
local sin = math.sin
local cos = math.cos
local pi = math.pi
local sqrt = math.sqrt
local abs = math.abs
local asin = math.asin

local function linear(t, b, c, d)
  return c * t / d + b
end

local function inQuad(t, b, c, d)
  t = t / d
  return c * pow(t, 2) + b
end

local function outQuad(t, b, c, d)
  t = t / d
  return -c * t * (t - 2) + b
end

local function inOutQuad(t, b, c, d)
  t = t / d * 2
  if t < 1 then
    return c / 2 * pow(t, 2) + b
  else
    return -c / 2 * ((t - 1) * (t - 3) - 1) + b
  end
end

local function outInQuad(t, b, c, d)
  if t < d / 2 then
    return outQuad (t * 2, b, c / 2, d)
  else
    return inQuad((t * 2) - d, b + c / 2, c / 2, d)
  end
end

local function inCubic (t, b, c, d)
  t = t / d
  return c * pow(t, 3) + b
end

local function outCubic(t, b, c, d)
  t = t / d - 1
  return c * (pow(t, 3) + 1) + b
end

local function inOutCubic(t, b, c, d)
  t = t / d * 2
  if t < 1 then
    return c / 2 * t * t * t + b
  else
    t = t - 2
    return c / 2 * (t * t * t + 2) + b
  end
end

local function outInCubic(t, b, c, d)
  if t < d / 2 then
    return outCubic(t * 2, b, c / 2, d)
  else
    return inCubic((t * 2) - d, b + c / 2, c / 2, d)
  end
end

local function inQuart(t, b, c, d)
  t = t / d
  return c * pow(t, 4) + b
end

local function outQuart(t, b, c, d)
  t = t / d - 1
  return -c * (pow(t, 4) - 1) + b
end

local function inOutQuart(t, b, c, d)
  t = t / d * 2
  if t < 1 then
    return c / 2 * pow(t, 4) + b
  else
    t = t - 2
    return -c / 2 * (pow(t, 4) - 2) + b
  end
end

local function outInQuart(t, b, c, d)
  if t < d / 2 then
    return outQuart(t * 2, b, c / 2, d)
  else
    return inQuart((t * 2) - d, b + c / 2, c / 2, d)
  end
end

local function inQuint(t, b, c, d)
  t = t / d
  return c * pow(t, 5) + b
end

local function outQuint(t, b, c, d)
  t = t / d - 1
  return c * (pow(t, 5) + 1) + b
end

local function inOutQuint(t, b, c, d)
  t = t / d * 2
  if t < 1 then
    return c / 2 * pow(t, 5) + b
  else
    t = t - 2
    return c / 2 * (pow(t, 5) + 2) + b
  end
end

local function outInQuint(t, b, c, d)
  if t < d / 2 then
    return outQuint(t * 2, b, c / 2, d)
  else
    return inQuint((t * 2) - d, b + c / 2, c / 2, d)
  end
end

local function inSine(t, b, c, d)
  return -c * cos(t / d * (pi / 2)) + c + b
end

local function outSine(t, b, c, d)
  return c * sin(t / d * (pi / 2)) + b
end

local function inOutSine(t, b, c, d)
  return -c / 2 * (cos(pi * t / d) - 1) + b
end

local function outInSine(t, b, c, d)
  if t < d / 2 then
    return outSine(t * 2, b, c / 2, d)
  else
    return inSine((t * 2) -d, b + c / 2, c / 2, d)
  end
end

local function inExpo(t, b, c, d)
  if t == 0 then
    return b
  else
    return c * pow(2, 10 * (t / d - 1)) + b - c * 0.001
  end
end

local function outExpo(t, b, c, d)
  if t == d then
    return b + c
  else
    return c * 1.001 * (-pow(2, -10 * t / d) + 1) + b
  end
end

local function inOutExpo(t, b, c, d)
  if t == 0 then return b end
  if t == d then return b + c end
  t = t / d * 2
  if t < 1 then
    return c / 2 * pow(2, 10 * (t - 1)) + b - c * 0.0005
  else
    t = t - 1
    return c / 2 * 1.0005 * (-pow(2, -10 * t) + 2) + b
  end
end

local function outInExpo(t, b, c, d)
  if t < d / 2 then
    return outExpo(t * 2, b, c / 2, d)
  else
    return inExpo((t * 2) - d, b + c / 2, c / 2, d)
  end
end

local function inCirc(t, b, c, d)
  t = t / d
  return(-c * (sqrt(1 - pow(t, 2)) - 1) + b)
end

local function outCirc(t, b, c, d)
  t = t / d - 1
  return(c * sqrt(1 - pow(t, 2)) + b)
end

local function inOutCirc(t, b, c, d)
  t = t / d * 2
  if t < 1 then
    return -c / 2 * (sqrt(1 - t * t) - 1) + b
  else
    t = t - 2
    return c / 2 * (sqrt(1 - t * t) + 1) + b
  end
end

local function outInCirc(t, b, c, d)
  if t < d / 2 then
    return outCirc(t * 2, b, c / 2, d)
  else
    return inCirc((t * 2) - d, b + c / 2, c / 2, d)
  end
end

local function inElastic(t, b, c, d, a, p)
  if t == 0 then return b end

  t = t / d

  if t == 1 then return b + c end

  if not p then p = d * 0.3 end

  local s

  if not a or a < abs(c) then
    a = c
    s = p / 4
  else
    s = p / (2 * pi) * asin(c/a)
  end

  t = t - 1

  return -(a * pow(2, 10 * t) * sin((t * d - s) * (2 * pi) / p)) + b
end

-- a: amplitud
-- p: period
local function outElastic(t, b, c, d, a, p)
  if t == 0 then return b end

  t = t / d

  if t == 1 then return b + c end

  if not p then p = d * 0.3 end

  local s

  if not a or a < abs(c) then
    a = c
    s = p / 4
  else
    s = p / (2 * pi) * asin(c/a)
  end

  return a * pow(2, -10 * t) * sin((t * d - s) * (2 * pi) / p) + c + b
end

-- p = period
-- a = amplitud
local function inOutElastic(t, b, c, d, a, p)
  if t == 0 then return b end

  t = t / d * 2

  if t == 2 then return b + c end

  if not p then p = d * (0.3 * 1.5) end
  if not a then a = 0 end

  if not a or a < abs(c) then
    a = c
    s = p / 4
  else
    s = p / (2 * pi) * asin(c / a)
  end

  if t < 1 then
    t = t - 1
    return -0.5 * (a * pow(2, 10 * t) * sin((t * d - s) * (2 * pi) / p)) + b
  else
    t = t - 1
    return a * pow(2, -10 * t) * sin((t * d - s) * (2 * pi) / p ) * 0.5 + c + b
  end
end

-- a: amplitud
-- p: period
local function outInElastic(t, b, c, d, a, p)
  if t < d / 2 then
    return outElastic(t * 2, b, c / 2, d, a, p)
  else
    return inElastic((t * 2) - d, b + c / 2, c / 2, d, a, p)
  end
end

local function inBack(t, b, c, d, s)
  if not s then s = 1.70158 end
  t = t / d
  return c * t * t * ((s + 1) * t - s) + b
end

local function outBack(t, b, c, d, s)
  if not s then s = 1.70158 end
  t = t / d - 1
  return c * (t * t * ((s + 1) * t + s) + 1) + b
end

local function inOutBack(t, b, c, d, s)
  if not s then s = 1.70158 end
  s = s * 1.525
  t = t / d * 2
  if t < 1 then
    return c / 2 * (t * t * ((s + 1) * t - s)) + b
  else
    t = t - 2
    return c / 2 * (t * t * ((s + 1) * t + s) + 2) + b
  end
end

local function outInBack(t, b, c, d, s)
  if t < d / 2 then
    return outBack(t * 2, b, c / 2, d, s)
  else
    return inBack((t * 2) - d, b + c / 2, c / 2, d, s)
  end
end

local function outBounce(t, b, c, d)
  t = t / d
  if t < 1 / 2.75 then
    return c * (7.5625 * t * t) + b
  elseif t < 2 / 2.75 then
    t = t - (1.5 / 2.75)
    return c * (7.5625 * t * t + 0.75) + b
  elseif t < 2.5 / 2.75 then
    t = t - (2.25 / 2.75)
    return c * (7.5625 * t * t + 0.9375) + b
  else
    t = t - (2.625 / 2.75)
    return c * (7.5625 * t * t + 0.984375) + b
  end
end

local function inBounce(t, b, c, d)
  return c - outBounce(d - t, 0, c, d) + b
end

local function inOutBounce(t, b, c, d)
  if t < d / 2 then
    return inBounce(t * 2, 0, c, d) * 0.5 + b
  else
    return outBounce(t * 2 - d, 0, c, d) * 0.5 + c * .5 + b
  end
end

local function outInBounce(t, b, c, d)
  if t < d / 2 then
    return outBounce(t * 2, b, c / 2, d)
  else
    return inBounce((t * 2) - d, b + c / 2, c / 2, d)
  end
end

-- Modifications for Daneel : replaced 'return {' by 'Tween.Ease = {'
Tween.Ease = {
  linear = linear,
  inQuad = inQuad,
  outQuad = outQuad,
  inOutQuad = inOutQuad,
  outInQuad = outInQuad,
  inCubic = inCubic ,
  outCubic = outCubic,
  inOutCubic = inOutCubic,
  outInCubic = outInCubic,
  inQuart = inQuart,
  outQuart = outQuart,
  inOutQuart = inOutQuart,
  outInQuart = outInQuart,
  inQuint = inQuint,
  outQuint = outQuint,
  inOutQuint = inOutQuint,
  outInQuint = outInQuint,
  inSine = inSine,
  outSine = outSine,
  inOutSine = inOutSine,
  outInSine = outInSine,
  inExpo = inExpo,
  outExpo = outExpo,
  inOutExpo = inOutExpo,
  outInExpo = outInExpo,
  inCirc = inCirc,
  outCirc = outCirc,
  inOutCirc = inOutCirc,
  outInCirc = outInCirc,
  inElastic = inElastic,
  outElastic = outElastic,
  inOutElastic = inOutElastic,
  outInElastic = outInElastic,
  inBack = inBack,
  outBack = outBack,
  inOutBack = inOutBack,
  outInBack = outInBack,
  inBounce = inBounce,
  outBounce = outBounce,
  inOutBounce = inOutBounce,
  outInBounce = outInBounce,
}

