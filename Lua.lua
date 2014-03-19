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

--- Return the value rounded to the closest integer or decimal.
-- @param value (number) The value.
-- @param decimal (number) [default=0] The decimal at which to round the value.
-- @return (number) The new value.
function math.round( value, decimal )
    if decimal ~= nil then
        value = math.floor( (value * 10^decimal) + 0.5) / (10^decimal)
    else
        value = math.floor( value + 0.5 )
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
    return ( s:gsub( "^%l", string.upper ) )
end

--- Turn the first letter of the string lowercase.
-- @param s (string) The string.
-- @return (string) The string.
function string.lcfirst( s )
    return ( s:gsub( "^%u", string.lower ) )
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
    return ( s:sub( 1, #chunk ) == chunk )
end

--- Tell whether the provided string ends by the provided chunk or not.
-- @param s (string) The string.
-- @param chunk (string) The searched chunk.
-- @return (boolean) True or false.
function string.endswith( s, chunk )
    return ( s:sub( #s - #chunk + 1, #s ) == chunk )
end

--- Removes the white spaces at the beginning of the provided string.
-- @param s (string) The string.
-- @return (string) The trimmed string.
function string.trimstart( s )
    return ( s:gsub( "^%s+", "" ) )
end

--- Removes the white spaces at the end of the provided string.
-- @param s (string) The string.
-- @return (string) The trimmed string.
function string.trimend( s )
    return ( s:gsub( "%s+$", "" ) )
end

--- Removes the white spaces at the beginning and the end of the provided string.
-- @param s (string) The string.
-- @return (string) The trimmed string.
function string.trim(s)
    return ( s:gsub( "^%s+", "" ):gsub( "%s+$", "" ) )
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
    local containsValue = false
    for key, _value in pairs(t) do
        if ignoreCase and type( _value ) == "string" then
            _value = _value:lower()
        end
        if value == _value then
            containsValue = true
            break
        end
    end
    return containsValue
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
        print(key, value)
    end

    print("~~~~~ table.print("..tostring(t)..") ~~~~~ End ~~~~~")
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
    if orderBy == nil or not (orderBy == "asc" or orderBy == "desc" ) then
        orderBy = "asc"
    end
    
    local propertyValues = {}
    local itemsByPropertyValue = {} -- propertyValue = _table (values in the t table)
    for i, _table in ipairs(t) do
        local propertyValue = _table[property]
        table.insert(propertyValues, propertyValue)
        if itemsByPropertyValue[propertyValue] == nil then
            itemsByPropertyValue[propertyValue] = {}
        end
        table.insert(itemsByPropertyValue[propertyValue], _table)
    end
    
    if orderBy == "desc" then
        table.sort(propertyValues, function(a,b) return a>b end)
    else
        table.sort(propertyValues)
    end
    
    t = {}
    for i, propertyValue in ipairs(propertyValues) do
        for j, _table in pairs(itemsByPropertyValue[propertyValue]) do
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
-- table.getvalue( table1, "table2.table3.Foo" ) would return nul because the 'table3' has no 'Foo' key <br>
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
    for i, v in ipairs( t ) do
        table.insert( newTable, 1, v )
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
            value = table.removevalue( t, 1 )
            if value ~= nil then -- should always be ~= nil if #t > 0
                key = 1
            end
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
    if returnKey then
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
