-- Lua.lua
-- Contains extensions of Lua's libraries
--
-- Last modified for v1.4.0
-- Copyright © 2013-2014 Florent POUJOL, published under the MIT license.


----------------------------------------------------------------------------------
-- math

--- Tell whether the provided number is an integer.
-- That include numbers that have one or several zeros as decimals (1.0, 2.000, ...).
-- @param number (number) The number to check.
-- @return (boolean) True if the provided number is an integer, false otherwise.
function math.isinteger(number)
    Daneel.Debug.StackTrace.BeginFunction("math.isinteger", number)
    local isinteger = false
    if type(number) == "number" then
        isinteger = number == math.floor(number)
    end
    Daneel.Debug.StackTrace.EndFunction()
    return isinteger
end

--- Returns the value resulting of the linear interpolation between value a and b by the specified factor.
-- @param a (number)
-- @param b (number)
-- @param factor (number) Should be between 0.0 and 1.0.
-- @param easing (string) [optional] The easing of the factor, can be "smooth", "smooth in", "smooth out".
-- @return (number) The interpolated value.
function math.lerp( a, b, factor, easing )
    Daneel.Debug.StackTrace.BeginFunction( "math.lerp", a, b, factor, easing )
    local errorHead = "math.lerp( a, b, factor[, easing] ) : "
    Daneel.Debug.CheckArgType( a, "a", "number", errorHead )
    Daneel.Debug.CheckArgType( b, "b", "number", errorHead )
    Daneel.Debug.CheckArgType( factor, "factor", "number", errorHead )
    Daneel.Debug.CheckOptionalArgType( easing, "easing", "string", errorHead )

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

    Daneel.Debug.StackTrace.EndFunction()
    return a + (b - a) * factor
end

--- Wrap the provided angle between -180 and 180.
-- @param angle (number) The angle.
-- @return (number) The angle.
function math.warpangle( angle )
    Daneel.Debug.StackTrace.BeginFunction( "math.wrapangle", angle )
    local errorHead = "math.wrapangle( angle ) : "
    Daneel.Debug.CheckArgType( angle, "angle", "number", errorHead )
    
    if angle > 180 then
        angle = angle - 360
    elseif angle < -180 then
        angle = angle + 360
    end
    Daneel.Debug.StackTrace.EndFunction()
    return angle
end

--- Return the value rounded to the closest integer or decimal.
-- @param value (number) The value.
-- @param decimal (number) [optional default=0] The decimal at which to round the value.
-- @return (number) The new value.
function math.round( value, decimal )
    Daneel.Debug.StackTrace.BeginFunction( "math.round", value, decimal )
    local errorHead = "math.round( value[, decimal] ) : "
    Daneel.Debug.CheckArgType( value, "value", "number", errorHead )
    Daneel.Debug.CheckOptionalArgType( decimal, "decimal", "number", errorHead )

    if decimal ~= nil then
        value = math.floor( (value * 10^decimal) + 0.5) / (10^decimal)
    else
        value = math.floor( value + 0.5 )
    end
    Daneel.Debug.StackTrace.EndFunction()
    return value
end


----------------------------------------------------------------------------------
-- string

--- Turn a string into a table, one character per index.
-- @param s (string) The string.
-- @return (table) The table.
function string.totable( s )
    Daneel.Debug.StackTrace.BeginFunction( "string.totable", s )
    Daneel.Debug.CheckArgType( s, "string", "string", "string.totable( string )" )

    local t = {}
    for i = 1, #s do
        table.insert( t, s:sub( i, i ) )
    end

    Daneel.Debug.StackTrace.EndFunction()
    return t
end

--- Turn the first letter of the string uppercase.
-- @param s (string) The string.
-- @return (string) The string.
function string.ucfirst( s )
    if Daneel.Cache.ucfirst[s] ~= nil then
        return Daneel.Cache.ucfirst[s]
    end

    Daneel.Debug.StackTrace.BeginFunction( "string.ucfirst", s )
    local errorHead = "string.ucfirst( string ) : "
    Daneel.Debug.CheckArgType( s, "string", "string", errorHead )

    local ns = ( s:gsub( "^%l", string.upper ) )
    Daneel.Cache.ucfirst[s] = ns

    Daneel.Debug.StackTrace.EndFunction()
    return ns
end

--- Turn the first letter of the string lowercase.
-- @param s (string) The string.
-- @return (string) The string.
function string.lcfirst( s )
    if Daneel.Cache.lcfirst[s] ~= nil then
        return Daneel.Cache.lcfirst[s]
    end

    Daneel.Debug.StackTrace.BeginFunction( "string.lcfirst", s )
    local errorHead = "string.lcfirst( string ) : "
    Daneel.Debug.CheckArgType( s, "string", "string", errorHead )

    local ns = ( s:gsub( "^%u", string.lower ) )
    Daneel.Cache.lcfirst[s] = ns

    Daneel.Debug.StackTrace.EndFunction()
    return ns
end

--- Split the provided string in several chunks, using the provided delimiter.
-- The delimiter can be a pattern and can be several characters long.
-- If the string does not contain the delimiter, a table containing only the whole string is returned.
-- @param s (string) The string.
-- @param delimiter (string) The delimiter.
-- @param delimiterIsPattern (boolean) [optional default=false] Interpret the delimiter as pattern instead of as plain text. The function's behavior is not garanteed if true and in the webplayer.
-- @return (table) The chunks.
function string.split( s, delimiter, delimiterIsPattern )
    Daneel.Debug.StackTrace.BeginFunction( "string.split", s, delimiter, delimiterIsPattern )
    local errorHead = "string.split( string, delimiter[, plainText] ) : "
    Daneel.Debug.CheckArgType( s, "string", "string", errorHead )
    Daneel.Debug.CheckArgType( delimiter, "delimiter", "string", errorHead )
    Daneel.Debug.CheckOptionalArgType( delimiterIsPattern, "delimiterIsPattern", "boolean", errorHead )

    local chunks = {}
    if delimiterIsPattern == nil and #delimiter == 1 then
        delimiterIsPattern = false
    end
    
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

    Daneel.Debug.StackTrace.EndFunction()
    return chunks
end

--- Tell whether the provided string begins by the provided chunk or not.
-- @param s (string) The string.
-- @param chunk (string) The searched chunk.
-- @return (boolean) True or false.
function string.startswith( s, chunk )
    Daneel.Debug.StackTrace.BeginFunction( "string.startswith", s, chunk )
    local errorHead = "string.startswith( string, chunk ) : "
    Daneel.Debug.CheckArgType( s, "string", "string", errorHead )
    Daneel.Debug.CheckArgType( chunk, "chunk", "string", errorHead )

    local startsWith = ( s:sub( 1, #chunk ) == chunk )
    Daneel.Debug.StackTrace.EndFunction()
    return startsWith
end

--- Tell whether the provided string ends by the provided chunk or not.
-- @param s (string) The string.
-- @param chunk (string) The searched chunk.
-- @return (boolean) True or false.
function string.endswith( s, chunk )
    Daneel.Debug.StackTrace.BeginFunction( "string.endswith", s, chunk )
    local errorHead = "string.endswith( string, chunk ) : "
    Daneel.Debug.CheckArgType( s, "string", "string", errorHead )
    Daneel.Debug.CheckArgType( chunk, "chunk", "string", errorHead )

    local endsWith = ( s:sub( #s - #chunk + 1, #s ) == chunk )
    Daneel.Debug.StackTrace.EndFunction()
    return endsWith
end

--- Removes the white spaces at the beginning of the provided string.
-- @param s (string) The string.
-- @return (string) The trimmed string.
function string.trimstart( s )
    Daneel.Debug.StackTrace.BeginFunction( "string.trimstart", s )
    local errorHead = "string.trimstart( string ) : "
    Daneel.Debug.CheckArgType( s, "string", "string", errorHead )
 
    local ns = ( s:gsub( "^%s+", "" ) )
    Daneel.Debug.StackTrace.EndFunction()
    return ns
end

--- Removes the white spaces at the end of the provided string.
-- @param s (string) The string.
-- @return (string) The trimmed string.
function string.trimend( s )
    Daneel.Debug.StackTrace.BeginFunction( "string.trimend", s )
    local errorHead = "string.trimend( string ) : "
    Daneel.Debug.CheckArgType( s, "string", "string", errorHead )

    local ns = ( s:gsub( "%s+$", "" ) )
    Daneel.Debug.StackTrace.EndFunction()
    return ns
end

--- Removes the white spaces at the beginning and the end of the provided string.
-- @param s (string) The string.
-- @return (string) The trimmed string.
function string.trim(s)
    Daneel.Debug.StackTrace.BeginFunction("string.trim", s)
    local errorHead = "string.trim(string) : "
    Daneel.Debug.CheckArgType(s, "string", "string", errorHead)

    local ns = ( s:gsub( "^%s+", "" ):gsub( "%s+$", "" ) )
    Daneel.Debug.StackTrace.EndFunction()
    return ns
end


----------------------------------------------------------------------------------
-- table

--- Return a copy of the provided table.
-- @param t (table) The table to copy.
-- @param recursive (boolean) [optional default=false] Tell whether to also copy the tables found as value (true), or just leave the same table as value (false).
-- @return (table) The copied table.
function table.copy( t, recursive )
    Daneel.Debug.StackTrace.BeginFunction( "table.copy", t, recursive )
    local errorHead = "table.copy( table[, recursive] ) :"
    Daneel.Debug.CheckArgType(t, "table", "table", errorHead )
    recursive = Daneel.Debug.CheckOptionalArgType( recursive, "recursive", "boolean", errorHead, false )
    
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
    
    Daneel.Debug.StackTrace.EndFunction()
    return newTable
end

--- Tell whether the provided value is found within the provided table.
-- @param t (table) The table to search in.
-- @param _value (mixed) The value to search for.
-- @param ignoreCase (boolean) [optional default=false] Ignore the case of the value. If true, the value must be of type 'string'.
-- @return (boolean) True if the value is found in the table, false otherwise.
function table.containsvalue(t, _value, ignoreCase)
    Daneel.Debug.StackTrace.BeginFunction("table.constainsvalue", t, _value, ignoreCase)
    local errorHead = "table.containsvalue(table, value) : "
    Daneel.Debug.CheckArgType(t, "table", "table", errorHead)
    
    if _value == nil then
        error(errorHead.."Argument 'value' is nil.")
    end

    Daneel.Debug.CheckOptionalArgType(ignoreCase, "ignoreCase", "boolean", errorHead)
    if ignoreCase and type( _value ) == 'string' then
        _value = _value:lower()
    else
        ignoreCase = false
    end
    
    local containsValue = false

    for key, value in pairs(t) do
        if ignoreCase and type( value ) == "string" then
            value = value:lower()
        end

        if _value == value then
            containsValue = true
            break
        end
    end
    
    Daneel.Debug.StackTrace.EndFunction()
    return containsValue
end

--- Returns the length of a table, which is the numbers of keys of the provided type (or of any type), for which the value is not nil.
-- @param t (table) The table.
-- @param keyType (string) [optional] Any Lua or CraftStudio type ('string', 'GameObject', ...), case insensitive.
-- @return (number) The table length.
function table.getlength( t, keyType )
    Daneel.Debug.StackTrace.BeginFunction( "table.getlength", t, keyType )
    local errorHead = "table.getlength( table[, keyType] ) : "
    Daneel.Debug.CheckArgType( t, "table", "table", errorHead )
    
    local length = 0
    if keyType ~= nil then
        keyType = keyType:lower()
    end
    for key, value in pairs( t ) do
        if 
            keyType == nil or
            type( key ) == keyType or
            tostring( Daneel.Debug.GetType( key ) ):lower() == keyType -- tostring() is to transform 'nil' as a string
        then
            length = length + 1
        end
    end

    Daneel.Debug.StackTrace.EndFunction()
    return length
end

--- Print all key/value pairs within the provided table.
-- @param t (table) The table to print.
function table.print(t)
    Daneel.Debug.StackTrace.BeginFunction("table.print", t)
    local errorHead = "table.print(table) : "

    if t == nil then
        print(errorHead.."Provided table is nil.")
        Daneel.Debug.StackTrace.EndFunction()
        return
    end

    Daneel.Debug.CheckArgType(t, "table", "table", errorHead)
    
    local tableString = tostring(t)
    local rawTableString = Daneel.Debug.ToRawString(t)
    if tableString ~= rawTableString then
        tableString = tableString.." / "..rawTableString
    end
    print("~~~~~ table.print("..tableString..") ~~~~~ Start ~~~~~")

    local func = pairs
    if table.getlength(t) == 0 then
        print("Provided table is empty.")
    elseif table.isarray( t ) then
        func = ipairs -- just to be sure that the entries are printed in order
    end
    
    for key, value in func(t) do
        print(key, value)
    end

    print("~~~~~ table.print("..tableString..") ~~~~~ End ~~~~~")

    Daneel.Debug.StackTrace.EndFunction()
end

--- Merge two or more tables into one.
-- Table as values with a metatable are considered as instances and are not recursively merged.
-- When the tables are arrays, the integer keys are not overridden.
-- @param ... (table) Two or more tables
-- @param recursive (boolean) [default=false] Tell whether tables as values must be merged recursively. Has no effect when the tables are arrays.
-- @return (table) The new table.
function table.merge( ... )
    local arg = {...}
    local recursive = table.remove( arg )
    local argType = type( recursive )
    if argType ~= "boolean" then
        if argType == "table" then
            table.insert( arg, recursive )
        end
        recursive = false
    end

    Daneel.Debug.StackTrace.BeginFunction( "table.merge", ..., recursive )
    
    local fullTable = {}
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
            
        elseif Daneel.Config.debug.enableDebug then
            print( "WARNING : table.merge( ..., recursive ) : Argument n°"..i.." is of type '"..argType.."' with value '"..tostring(t).."' instead of 'table'. The argument as been ignored." )
        end
    end
    Daneel.Debug.StackTrace.EndFunction()
    return fullTable
end

--- Deprecated since v1.3.1. Alias of table.merge( ..., true ).
-- @param ... (table) At least two tables to recursively merge together.
-- @return (table) The new table.
function table.deepmerge( ... )    
    return table.merge( unpack( table.insert( {...}, true ) ) )
end

--- Compare table1 and table2. Returns true if they have the exact same keys which have the exact same values.
-- @param table1 (table) The first table to compare.
-- @param table2 (table) The second table to compare to the first table.
-- @return (boolean) True if the two tables have the exact same content.
function table.havesamecontent( table1, table2 )
    Daneel.Debug.StackTrace.BeginFunction( "table.havesamecontent", table1, table2 )
    local errorHead = "table.havesamecontent( table1, table2 ) : "
    Daneel.Debug.CheckArgType( table1, "table1", "table", errorHead )
    Daneel.Debug.CheckArgType( table2, "table2", "table", errorHead )

    if table.getlength(table1) ~= table.getlength(table2) then
        Daneel.Debug.StackTrace.EndFunction()
        return false
    end

    local areEqual = true
    for key, value in pairs( table1 ) do
        if table1[ key ] ~= table2[ key ] then
            areEqual = false
            break
        end
    end
    
    Daneel.Debug.StackTrace.EndFunction()
    return areEqual
end

--- Create an associative table with the provided keys and values tables.
-- @param keys (table) The keys of the future table.
-- @param values (table) The values of the future table.
-- @param returnFalseIfNotSameLength (boolean) [optional default=false] If true, the function returns false if the keys and values tables have different length.
-- @return (table or boolean) The combined table or false if the tables have different length.
function table.combine( keys, values, returnFalseIfNotSameLength )
    Daneel.Debug.StackTrace.BeginFunction( "table.combine", keys, values, returnFalseIfNotSameLength )
    local errorHead = "table.combine( keys, values[, returnFalseIfNotSameLength] ) : "
    Daneel.Debug.CheckArgType( keys, "keys", "table", errorHead )
    Daneel.Debug.CheckArgType( values, "values", "table", errorHead )
    Daneel.Debug.CheckOptionalArgType( returnFalseIfNotSameLength, "returnFalseIfNotSameLength", "boolean", errorHead )
    
    if table.getlength( keys ) ~= table.getlength( values ) then
        if Daneel.Config.debug.enableDebug then
            print( errorHead.."WARNING : Arguments 'keys' and 'values' have different length." )
        end
        if returnFalseIfNotSameLength then
            Daneel.Debug.StackTrace.EndFunction()
            return false
        end
    end
    local newTable = {}
    for i, key in ipairs( keys ) do
        newTable[ key ] = values[ i ]
    end
    Daneel.Debug.StackTrace.EndFunction()
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
    Daneel.Debug.StackTrace.BeginFunction( "table.removevalue", t, value, maxRemoveCount )
    local errorHead = "table.removevalue( table, value[, maxRemoveCount] ) : "
    Daneel.Debug.CheckArgType( t, "table", "table", errorHead)
    Daneel.Debug.CheckOptionalArgType( maxRemoveCount, "maxRemoveCount", "number", errorHead )

    if value == nil and Daneel.Config.debug.enableDebug then
        print("WARNING : "..errorHead.."Argument 2 'value' is nil. Provided table is '"..tostring(t).."'")
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
    Daneel.Debug.StackTrace.EndFunction()
    return removeCount
end

--- Return all the keys of the provided table.
-- @param t (table) The table.
-- @return (table) The keys.
function table.getkeys( t )
    Daneel.Debug.StackTrace.BeginFunction( "table.getkeys", t )
    local errorHead = "table.getkeys( table ) : "
    Daneel.Debug.CheckArgType( t, "table", "table", errorHead )

    local keys = {}
    for key, value in pairs( t ) do
        table.insert( keys, key )
    end
    Daneel.Debug.StackTrace.EndFunction()
    return keys
end

--- Return all the values of the provided table.
-- @param t (table) The table.
-- @return (table) The values.
function table.getvalues( t )
    Daneel.Debug.StackTrace.BeginFunction( "table.getvalues", t )
    local errorHead = "table.getvalues( t ) : "
    Daneel.Debug.CheckArgType( t, "table", "table", errorHead )
    
    local values = {}
    for key, value in pairs( t ) do
        table.insert( values, value )
    end
    Daneel.Debug.StackTrace.EndFunction()
    return values
end

--- Get the key associated with the first occurrence of the provided value.
-- @param t (table) The table.
-- @param value (mixed) The value.
-- @return (mixed) The value's key or nil if the value is not found.
function table.getkey( t, value )
    Daneel.Debug.StackTrace.BeginFunction( "table.getkey", t, value )
    local errorHead = "table.getkey( table, value ) : "
    Daneel.Debug.CheckArgType( t, "table", "table", errorHead )
    if value == nil then
        error( errorHead.."Argument 'value' is nil." )
    end
    local key = nil
    for k, v in pairs( t ) do
        if value == v then
            key = k
        end
    end
    Daneel.Debug.StackTrace.EndFunction()
    return key
end

--- Sort a list of table using one of the tables property as criteria.
-- @param t (table) The table.
-- @param property (string) The property used as criteria to sort the table.
-- @param orderBy (string) [optional default="asc"] How the sort should be made. Can be "asc" or "desc". Asc means small values first.
-- @return (table) The ordered table.
function table.sortby( t, property, orderBy )
    Daneel.Debug.StackTrace.BeginFunction( "table.sortby", t, property, orderBy )
    local errorHead = "table.sortby( table, property[, orderBy] ) : "
    Daneel.Debug.CheckArgType( t, "table", "table", errorHead )
    Daneel.Debug.CheckArgType( property, "property", "string", errorHead )
    Daneel.Debug.CheckOptionalArgType( orderBy, "orderBy", "string", errorHead )
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
    
    Daneel.Debug.StackTrace.EndFunction()
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
    Daneel.Debug.StackTrace.BeginFunction( "table.getvalue", t, keys )
    local errorHead = "table.getvalue( table, keys ) : "
    Daneel.Debug.CheckArgType( t, "table", "table", errorHead )
    Daneel.Debug.CheckArgType( keys, "keys", "string", errorHead )

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
            Daneel.Debug.StackTrace.EndFunction()
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
    
    Daneel.Debug.StackTrace.EndFunction()
    return value
end

functionsDebugData[ "table.setvalue" ] = { { name = "t", type = "table" }, { name = "keys", type = "string" }, }
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
    Daneel.Debug.StackTrace.BeginFunction( "table.isarray", t )
    local errorHead = "table.isarray( table ) : "
    Daneel.Debug.CheckArgType( t, "table", "table", errorHead )
    strict = Daneel.Debug.CheckOptionalArgType( strict, "strict", "boolean", errorHead, true )

    local isArray = true
    local entriesCount = 0

    for k, v in pairs( t ) do
        entriesCount = entriesCount + 1
        if isArray and ( type( k ) ~= "number" or not math.isinteger( k ) ) then
            isArray = false
        end
    end

    if isArray and strict then
        isArray = (entriesCount == #t)
    end
    
    Daneel.Debug.StackTrace.EndFunction()
    return isArray
end

--- Reverse the order of the provided table's values.
-- @param t (table) The table.
-- @return (table) The new table.
function table.reverse( t )
    Daneel.Debug.StackTrace.BeginFunction( "table.reverse", t )
    local errorHead = "table.reverse( table ) : "
    Daneel.Debug.CheckArgType( t, "table", "table", errorHead )
    
    local length = #t
    local newTable = {}
    for i, v in ipairs( t ) do
        table.insert( newTable, 1, v )
    end
    
    Daneel.Debug.StackTrace.EndFunction()
    return newTable
end

--- Remove and returns the first value found in the table.
-- Works for arrays as well as associative tables.
-- @param t (table) The table.
-- @param returnKey (boolean) [default=false] If true, return the key and the value instead of just the value.
-- @return (mixed) The value, or the key and the value (if the returnKey argument is true), or nil.
function table.shift( t, returnKey )
    Daneel.Debug.StackTrace.BeginFunction( "table.shift", t, returnKey )
    local errorHead = "table.shift( table[, returnKey] ) : "
    Daneel.Debug.CheckArgType( t, "table", "table", errorHead )
    returnKey = Daneel.Debug.CheckOptionalArgType( returnKey, "returnKey", "boolean", errorHead, false )

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
    
    Daneel.Debug.StackTrace.EndFunction()
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
    Daneel.Debug.StackTrace.BeginFunction( "table.reindex", t )
    local errorHead = "table.reindex( table ) : "
    Daneel.Debug.CheckArgType( t, "table", "table", errorHead )

    local newTable = {}
    if not table.isarray( t, false ) then
        if Daneel.Config.debug.enableDebug then
            print( errorHead.."Provided table '"..tostring( t ).."' is not an array." )
        end
    else
        local maxi = 1
        for i, v in pairs( t ) do
            if i > maxi then
                maxi = i
            end
        end
        
        for i=1, maxi do
            if t[i] ~= nil then
                table.insert( newTable, t[i] )
            end
        end
    end

    Daneel.Debug.StackTrace.EndFunction()  
    return newTable
end


----------------------------------------------------------------------------------

-- DaneelModules is inside CS because you can do 'if CS.DaneelModules == nil' but you can't do 'if DaneelModules == nil'
-- and you can't be sure to be able to access table.getvalue( _G, "" )
-- (actually you can since v1.4)
CS.DaneelModules = {
    Lua = {
        DefaultConfig = function()
            return {
                functionsDebugData = {

                }
            }
        end
    }
}
    