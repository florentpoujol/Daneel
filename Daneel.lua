-- Daneel.lua
-- Contains Daneel's core functionalities.
--
-- Last modified for v1.3
-- Copyright © 2013 Florent POUJOL, published under the MIT license.

-- keep that up there
if CS.DaneelModules == nil then
    CS.DaneelModules = {}
    -- DaneelModules is inside CS because you can do 'if CS.DaneelModules == nil' but you can't do 'if DaneelModules == nil'
    -- and you can't be sure to be able to access table.getvalue( _G, "" )
end

----------------------------------------------------------------------------------
-- LUA (put here at the top because pretty much all functions depends on them)
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
-- @param doNotCopyMetatable (boolean) [optional default=false] Tell whether to copy the provided table's metatable or not.
-- @return (table) The copied table.
function table.copy( t, recursive, doNotCopyMetatable )
    Daneel.Debug.StackTrace.BeginFunction( "table.copy", t, recursive, doNotCopyMetatable )
    local errorHead = "table.copy( table[, recursive, doNotCopyMetatable] ) :"
    Daneel.Debug.CheckArgType(t, "table", "table", errorHead )
    recursive = Daneel.Debug.CheckOptionalArgType( recursive, "recursive", "boolean", errorHead, false )
    doNotCopyMetatable = Daneel.Debug.CheckOptionalArgType( doNotCopyMetatable, "doNotCopyMetatable", "boolean", errorHead, false )
    
    local newTable = {}
    if table.isarray( t ) then
        -- not sure if it's really necessary to use ipairs() instead of pairs() for arrays
        -- but better be safe than sorry
        for key, value in ipairs( t ) do
            if type( value ) == "table" and recursive then
                value = table.copy( value )
            end
            table.insert( newTable, value )
        end
    else
        for key, value in pairs( t ) do
            if type( value ) == "table" and recursive then
                value = table.copy( value )
            end
            newTable[ key ] = value
        end
    end
    
    if doNotCopyMetatable ~= true then
        local mt = getmetatable( t )
        if mt ~= nil then
            setmetatable( newTable, mt )
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

--- Merge two or more tables into one. Integer keys are not overridden.
-- When several tables have the same value (with an integer key), the value is only added once in the returned table.
-- @param ... (table) At least two tables to merge together.
-- @return (table) The new table.
function table.merge( ... )
    local arg = {...}
    if arg == nil or #arg == 0 then
        Daneel.Debug.StackTrace.BeginFunction( "table.merge" )
        error( "table.merge(...) : No argument provided. Need at least two." )
    end
    Daneel.Debug.StackTrace.BeginFunction( "table.merge", ... )
    
    local fullTable = {}
    for i, t in ipairs( arg ) do
        local argType = type( t )
        if argType == "table" then
            if table.isarray( t ) then
                for key, value in ipairs( t ) do
                    if not table.containsvalue( fullTable, value ) then
                        table.insert( fullTable, value )
                    end
                end
            else
                for key, value in pairs( t ) do
                    if math.isinteger( key ) then
                        if not table.containsvalue( fullTable, value ) then
                            table.insert( fullTable, value )
                        end
                    else
                        fullTable[ key ] = value
                    end
                end
            end
        elseif Daneel.Config.debug.enableDebug then
            print( "WARNING : table.merge(...) : Argument n°"..i.." is of type '"..argType.."' with value '"..tostring(t).."' instead of 'table'. The argument as been ignored." )
        end
    end
    Daneel.Debug.StackTrace.EndFunction()
    return fullTable
end

--- Deeply merge two or more tables into one. Integer keys are not overridden.
-- A deep merge means that the table values are also deeply merged.
-- When several tables have the same value (with an integer key), the value is only added once in the returned table.
-- @param ... (table) At least two tables to merge together.
-- @return (table) The new table.
function table.deepmerge( ... )
    local arg = {...}
    if arg == nil or #arg == 0 then
        Daneel.Debug.StackTrace.BeginFunction("table.deepmerge")
        error( "table.deepmerge(...) : No argument provided. Need at least two." )
    end
    Daneel.Debug.StackTrace.BeginFunction( "table.deepmerge", ... )
    
    local fullTable = {}
    for i, t in ipairs( arg ) do
        local argType = type( t )
        if argType == "table" then
            for key, value in pairs(t) do
                if math.isinteger( key ) then
                    if table.containsvalue( fullTable, value ) then
                        table.insert( fullTable, value )
                    end
                else
                    if fullTable[ key ] ~= nil and type( value ) == "table" then
                        local mt = getmetatable( fullTable[ key ] )
                        if mt ~= nil then -- consider the value an intance of an object, just replace the instance
                            fullTable[ key ] = value
                        else
                            fullTable[ key ] = table.deepmerge( fullTable[ key ], value )
                        end
                    else
                        fullTable[ key ] = value
                    end
                end
            end
        elseif Daneel.Config.debug.enableDebug then
            print( "WARNING : table.deepmerge(...) : Argument n°"..i.." is of type '"..argType.."' with value '"..tostring(t).."' instead of 'table'. The argument as been ignored." )
        end
    end
    Daneel.Debug.StackTrace.EndFunction()
    return fullTable
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

--- Tell wether he provided table is an array (has only integer keys).
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
-- Daneel
----------------------------------------------------------------------------------

Daneel = {}

-- Config, loading and Runtime at the end

----------------------------------------------------------------------------------
-- Utilities

Daneel.Utilities = {}

--- Make sure that the case of the provided name is correct by checking it against the values in the provided set.
-- @param name (string) The name to check the case of.
-- @param set (string or table) A single value or a table of values to check the name against.
function Daneel.Utilities.CaseProof( name, set )
    Daneel.Debug.StackTrace.BeginFunction( "Daneel.Utilities.CaseProof", name, set )
    local errorHead = "Daneel.Utilities.CaseProof( name, set ) : " 
    Daneel.Debug.CheckArgType( name, "name", "string", errorHead )
    Daneel.Debug.CheckArgType( set, "set", {"string", "table"}, errorHead )

    if type( set ) == "string" then
        set = { set }
    end
    local lname = name:lower()
    for i, item in pairs( set ) do
        if lname == item:lower() then
            name = item
            break
        end
    end
    Daneel.Debug.StackTrace.EndFunction()
    return name
end

--- Replace placeholders in the provided string with their corresponding provided replacements.
-- The placeholders are any pice of string prefixed by a semicolon.
-- @param string (string) The string.
-- @param replacements (table) The placeholders and their replacements ( { placeholder = "replacement", ... } ).
-- @return (string) The string.
function Daneel.Utilities.ReplaceInString( string, replacements )
    Daneel.Debug.StackTrace.BeginFunction( "Daneel.Utilities.ReplaceInString", string, replacements )
    local errorHead = "Daneel.Utilities.ReplaceInString( string, replacements ) : "
    Daneel.Debug.CheckArgType( string, "string", "string", errorHead )
    Daneel.Debug.CheckArgType( replacements, "replacements", "table", errorHead )
    
    for placeholder, replacement in pairs( replacements ) do
        string = string:gsub( ":"..placeholder, replacement )
    end
    Daneel.Debug.StackTrace.EndFunction()
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

--- A more flexible version of Lua's built-in tonumber() function.
-- Returns the first continuous series of numbers found in the text version of the provided data even if it is prefixed or suffied by other characters.
-- @param data (mixed) Usually string or userdata.
-- @return (number) The number, or nil.
function Daneel.Utilities.ToNumber( data )
    Daneel.Debug.StackTrace.BeginFunction( "Daneel.Utilities.ToNumber", data )
    local errorHead = "Daneel.Utilities.ToNumber( data ) : "
    if data == nil then
        error( errorHead .. "Argument 1 'data' is nil." )
    end

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
    Daneel.Debug.StackTrace.EndFunction()
    return number
end

--- Tell whether the provided button name exists amongst the Game Controls, or not.
-- If the button name does not exists, it will print an error in the Runtime Report but it won't kill the script that called the function.
-- CS.Input.ButtonExists is an alias of Daneel.Utilities.ButtonExists.
-- @param buttonName (string) The button name.
-- @return (boolean) True if the button name exists, false otherwise.
function Daneel.Utilities.ButtonExists( buttonName )
    Daneel.Debug.StackTrace.BeginFunction( "Daneel.Utilities.ButtonExists", buttonName )
    local errorHead = "Daneel.Utilities.ButtonExists( buttonName ) : "
    Daneel.Debug.CheckArgType( buttonName, "buttonName", "string", errorHead )

    local buttonExists =  Daneel.Debug.Try( function()
        CS.Input.WasButtonJustPressed( buttonName )
    end )

    Daneel.Debug.StackTrace.EndFunction()
    return buttonExists
end


----------------------------------------------------------------------------------
-- Debug

Daneel.Debug = {}

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

            if Daneel.Config.objects ~= nil then
                for type, object in pairs( Daneel.Config.objects ) do
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

local OriginalError = error

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
        OriginalError(message)
    end
end

--- Disable the debug from this point onward.
-- @param info [optional] (string) Some info about why or where you disabled the debug. Will be printed in the Runtime Report.
function Daneel.Debug.Disable(info)
    if info ~= nil then
        info = " : "..tostring(info)
    end
    print("Daneel.Debug.Disable()"..info)
    error = OriginalError
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
    local result = table.getkey(Daneel.Config.objects, value)
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
    events = {}, -- emptied when a new scene is loaded in CraftStudio.LoadScene()
}

--- Make the provided function or object listen to the provided event(s).
-- The function will be called whenever the provided event will be fired.
-- @param eventName (string or table) The event name (or names in a table).
-- @param functionOrObject (function or table) The function (not the function name) or the object.
function Daneel.Event.Listen( eventName, functionOrObject )
    Daneel.Debug.StackTrace.BeginFunction( "Daneel.Event.Listen", eventName, functionOrObject )
    local errorHead = "Daneel.Event.Listen( eventName, functionOrObject ) : "
    Daneel.Debug.CheckArgType( eventName, "eventName", {"string", "table"}, errorHead )
    Daneel.Debug.CheckArgType( functionOrObject, "functionOrObject", {"table", "function", "userdata"}, errorHead )
    
    local eventNames = eventName
    if type( eventName ) == "string" then
        eventNames = { eventName }
    end
    for i, eventName in pairs( eventNames ) do
        
        -- check for hotkeys
        local a,a, buttonName = eventName:find( "^On(.+)ButtonJustPressed$" )
        if buttonName == nil then
            a,a, buttonName = eventName:find( "^On(.+)ButtonJustReleased$" )
        end
        if buttonName == nil then
            a,a, buttonName = eventName:find( "^On(.+)ButtonDown$" )
        end

        if buttonName ~= nil and not table.containsvalue( Daneel.Config.hotKeys, buttonName ) then
            if not Daneel.isLoaded then
                Daneel.LateLoad( "Daneel.Event.Listen" )
            end

            if Daneel.Utilities.ButtonExists( buttonName ) then
                table.insert( Daneel.Config.hotKeys, buttonName )
            else
                if Daneel.Config.debug.enableDebug then
                    print( errorHead .. "You tried to listen to the '" .. eventName .. "' event but the '" .. buttonName .. "' button does not exists in the Game Controls." )
                end
                return
            end
        end

        --
        if Daneel.Event.events[ eventName ] == nil then
            Daneel.Event.events[ eventName ] = {}
        end

        if not table.containsvalue( Daneel.Event.events[ eventName ], functionOrObject ) then
            table.insert( Daneel.Event.events[ eventName ], functionOrObject )
        end
    end
    Daneel.Debug.StackTrace.EndFunction()
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
        eventNames = table.getkeys( Daneel.Event.events )
    end

    for i, eventName in pairs( eventNames ) do
        local listeners = Daneel.Event.events[ eventName ]
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
    if argType == "string" or argType == "nil" then -- 17/09/13 why checking for nil ?
        -- no object provided, fire on the listeners
        if eventName ~= nil then
            table.insert( arg, 1, eventName )
        end
        eventName = object
        object = nil

    else
        Daneel.Debug.CheckArgType( object, "object", "table", errorHead )
        Daneel.Debug.CheckArgType( eventName, "eventName", "string", errorHead )
    end

    
    local listeners = { object }
    if object == nil and Daneel.Event.events[ eventName ] ~= nil then
        listeners = Daneel.Event.events[ eventName ]
    end

    for i, listener in ipairs( listeners ) do
        
        local listenerType = type( listener )
        if listenerType == "function" or listenerType == "userdata" then
            listener( unpack( arg ) )

        else -- an object
            local mt = getmetatable( listener )
            if listener.isDestroyed ~= true or (mt == GameObject and listener.inner ~= nil)  then -- ensure that the event is not fired on a dead game object or component
                local message = eventName

                -- look for the value of the EventName property on the object
                local funcOrMessage = rawget( listener, eventName )
                -- Using rawget() prevent a 'Behavior function' to be called as a regular function when the listener is a ScriptedBehavior
                -- because the function exists on the Script object and not on the ScriptedBehavior (the listener),
                -- in which case rawget() returns nil

                local _type = type( funcOrMessage )
                if _type == "function" or _type == "userdata" then
                    funcOrMessage( unpack( arg ) )

                elseif _type == "string" then
                    message = funcOrMessage
                end

                -- always try to send the message, even when funcOrMessage was a function
                if mt == GameObject then
                    listener:SendMessage( message, arg )
                end
            end
        end

    end -- end for listeners
    Daneel.Debug.StackTrace.EndFunction()
end


----------------------------------------------------------------------------------
-- Time

Daneel.Time = {}
CS.DaneelModules['Time'] = Daneel.Time

function Daneel.Time.Load()
    setmetatable( Daneel.Time, nil )
    Daneel.Time = {
        realTime = 0.0,
        realDeltaTime = 0.0,

        time = 0.0,
        deltaTime = 0.0,
        timeScale = 1.0,

        frameCount = 0,
    }
    -- see below in Daneel.Update()
end

local mt = {
    __index = function( instance, key )
        setmetatable( Daneel.Time, nil ) -- best prevent C Stack Overflow
        if not Daneel.isLoaded then
            Daneel.LateLoad( "Daneel.Time __index" )
        end
        return Daneel.Time[ key ]
    end,

    __newindex = function( instance, key, value )
        setmetatable( Daneel.Time, nil ) 
        if not Daneel.isLoaded then
            Daneel.LateLoad( "Daneel.Time __newindex" )
        end
        Daneel.Time[ key ] = value
    end
}
setmetatable( Daneel.Time, mt )
-- Using the metatable allows to detect if the Time object is used when Daneel is not loaded yet.


----------------------------------------------------------------------------------
-- Cache

Daneel.Cache = {
    ucfirst = {},
    lcfirst = {},
    id = 0,
}

--- Returns an interger greater than 0 and incremented by 1 from the last time the funciton was called.
-- If an object is provided, returns the object's id (if no id is found, it is set).
-- @param object (table) [optional] An object. 
-- @return (number) The id.
function Daneel.Cache.GetId( object )
    if object ~= nil and type( object ) == "table" then
        local id = rawget( object, "id" )
        if id ~= nil then
            return id
        end
        id = Daneel.Cache.GetId()
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
        Daneel.Cache.id = Daneel.Cache.id + 1
        return Daneel.Cache.id
    end
end


----------------------------------------------------------------------------------
-- Storage

Daneel.Storage = {}

-- Store locally on the computer the provided data under the provided name.
-- @param name (string) The name of the data.
-- @param data (mixed) The data to store. May be nil.
-- @param callback (function) [optional] The function called when the save has completed. The potential error (as a string) is passed the callback first and only argument.
function Daneel.Storage.Save( name, data, callback )
    Daneel.Debug.StackTrace.BeginFunction( "Daneel.Storage.Save", name, data )
    local errorHead = "Daneel.Storage.Save( name, data ) : "
    Daneel.Debug.CheckArgType( name, "name", "string", errorHead )
    Daneel.Debug.CheckOptionalArgType( callback, "callback", "function", errorHead )

    if data ~= nil and type( data ) ~= "table" then
        data = { 
            value = data,
            isSavedByDaneel = true
        }
    end

    CS.Storage.Save( name, data, function( error )
        if error ~= nil then
            if Daneel.Config.debug.enableDebug then
                print( errorHead .. "Error saving with name, data and error : ", name, data, error.message )
            end
        end

        if callback ~= nil then
            if error == nil then
                error = {}
            end
            callback( error.message )
        end
    end )

    Daneel.Debug.StackTrace.EndFunction()
end

-- Load data stored locally on the computer under the provided name. The load operation may not be instantaneous.
-- The function will return the queried value (or defaultValue) if it completes right away, otherwise it returns nil.
-- @param name (string) The name of the data.
-- @param defaultValue (mixed) The value that is returned if no data is found.
-- @param callback (function) [optional] The function called when the data is loaded. The value and the potential error (as a string) are passed as first and second argument, respectivily.
-- @return (mixed) The data.
function Daneel.Storage.Load( name, defaultValue, callback )
    Daneel.Debug.StackTrace.BeginFunction( "Daneel.Storage.Load", name, defaultValue )
    local errorHead = "Daneel.Storage.Load( name, defaultValue ) : "
    Daneel.Debug.CheckArgType( name, "name", "string", errorHead )
    if callback == nil and type( defaultValue ) == "function" then
        callback = defaultValue
        defaultValue = nil
    end
    Daneel.Debug.CheckOptionalArgType( callback, "callback", "function", errorHead )

    local value = nil

    CS.Storage.Load( name, function( error, data )
        if error ~= nil then
            if Daneel.Config.debug.enableDebug then
                print( errorHead .. "Error loading with name, default value and error", name, defaultValue, error.message )
            end
            data = nil
        end
        
        value = defaultValue

        if data ~= nil then
            if data.value ~= nil and data.isSavedByDaneel then
                value = data.value
            else
                value = data
            end
        end

        if callback ~= nil then
            if error == nil then
                error = {}
            end
            callback( value, error.message )
        end
    end )
    
    Daneel.Debug.StackTrace.EndFunction()
    return value
end


----------------------------------------------------------------------------------
-- CRAFTSTUDIO
----------------------------------------------------------------------------------

setmetatable( Vector3, { __call = function(Object, ...) return Object:New(...) end } )
setmetatable( Quaternion, { __call = function(Object, ...) return Object:New(...) end } )
setmetatable( Plane, { __call = function(Object, ...) return Object:New(...) end } )


----------------------------------------------------------------------------------
-- Assets

Asset = {}
Asset.__index = Asset
setmetatable( Asset, { __call = function(Object, ...) return Object.Get(...) end } )

local assetGetTypes = { "string" }
--- Alias of CraftStudio.FindAsset( assetPath[, assetType] ).
-- Get the asset of the specified name and type.
-- The first argument may be an asset object, so that you can check if a variable was an asset object or name (and get the corresponding object).
-- @param assetPath (string or one of the asset type) The fully-qualified asset name or asset object.
-- @param assetType [optional] (string) The asset type as a case-insensitive string.
-- @param errorIfAssetNotFound [optional default=false] Throw an error if the asset was not found (instead of returning nil).
-- @return (One of the asset type) The asset, or nil if none is found.
function Asset.Get( assetPath, assetType, errorIfAssetNotFound )
    Daneel.Debug.StackTrace.BeginFunction( "Asset.Get", assetPath, assetType, errorIfAssetNotFound )
    local errorHead = "Asset.Get( assetPath[, assetType, errorIfAssetNotFound] ) : "
    if #assetGetTypes == 1 and Daneel.Config.assetTypes ~= nil then
        assetGetTypes = table.merge( assetGetTypes, Daneel.Config.assetTypes )
        -- 23 nov 2013 : why do I do that ?
        -- because Asset.Get() may be called when Daneel.Config.assetTypes is still nil ?
    end
    local argType = Daneel.Debug.CheckArgType( assetPath, "assetPath", assetGetTypes, errorHead )
    
    if assetType ~= nil then
        Daneel.Debug.CheckArgType( assetType, "assetType", "string", errorHead )
        assetType = Daneel.Debug.CheckArgValue( assetType, "assetType", Daneel.Config.assetTypes, errorHead )
    end

    -- just return the asset if assetPath is already an object
    if table.containsvalue( Daneel.Config.assetTypes, argType ) then
        if assetType ~= nil and argType ~= assetType then 
            error( errorHead.."Provided asset '"..assetPath.."' has a different type '"..argType.."' than the provided 'assetType' argument '"..assetType.."'." )
        end
        Daneel.Debug.StackTrace.EndFunction()
        return assetPath
    end
    -- else assetPath is always an actual asset path as a string
    
    Daneel.Debug.CheckOptionalArgType( errorIfAssetNotFound, "errorIfAssetNotFound", "boolean", errorHead )

    -- check if assetPath is a script alias
    local scriptAlias = assetPath
    if Daneel.Config.scriptPaths[ scriptAlias ] ~= nil then 
        assetPath = Daneel.Config.scriptPaths[ scriptAlias ]
        assetType = "Script"
    end

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

    Daneel.Debug.StackTrace.EndFunction()
    return asset
end

--- Returns the path of the provided asset.
-- @param asset (One of the asset types) The asset instance.
-- @return (string) The fully-qualified asset path.
function Asset.GetPath( asset )
    Daneel.Debug.StackTrace.BeginFunction( "Asset.GetPath", asset )
    local errorHead = "Asset.GetPath( asset ) : "
    Daneel.Debug.CheckArgType( asset, "asset", Daneel.Config.assetTypes, errorHead )
    local path = Map.GetPathInPackage( asset )
    Daneel.Debug.StackTrace.EndFunction()
    return path
end

--- Returns the name of the provided asset.
-- @param asset (One of the asset types) The asset instance.
-- @return (string) The name (the last segment of the fully-qualified path).
function Asset.GetName( asset )
    Daneel.Debug.StackTrace.BeginFunction( "Asset.GetName", asset )
    local errorHead = "Asset.GetName( asset ) : "
    Daneel.Debug.CheckArgType( asset, "asset", Daneel.Config.assetTypes, errorHead )
    local name = Asset.GetPath( asset ):gsub( "^(.*/)", "" ) 
    rawset( asset, "name", name )
    Daneel.Debug.StackTrace.EndFunction()
    return name
end

--- Returns the asset's internal unique identifier.
-- @param asset (any asset type) The asset.
-- @return (number) The id.
function Asset.GetId( asset )
    return Daneel.Cache.GetId( asset )
end

-- fix for Map.GetPathInPackage() that returns an error when the asset was dynamically loaded
local OriginalMapGetPathInPackage = Map.GetPathInPackage

function Map.GetPathInPackage( asset )
    local path = rawget( asset, "path" )
    if path == nil then
        path = OriginalMapGetPathInPackage( asset )
    end
    return path
end

local OriginalMapLoadFromPackage = Map.LoadFromPackage

function Map.LoadFromPackage( path )
    local asset = OriginalMapLoadFromPackage( path )
    if asset ~= nil then
        rawset( asset, "path", path )
    end
    return asset
end


----------------------------------------------------------------------------------
-- Components

Component = {}
Component.__index = Component

--- Apply the content of the params argument to the provided component.
-- @param component (any component's type) The component.
-- @param params (table) A table of parameters to set the component with.
function Component.Set(component, params)
    Daneel.Debug.StackTrace.BeginFunction("Component.Set", component, params)
    local errorHead = "Component.Set(component, params) : "
    Daneel.Debug.CheckArgType(component, "component", Daneel.Config.componentTypes, errorHead)
    Daneel.Debug.CheckArgType(params, "params", "table", errorHead)

    for key, value in pairs(params) do
        component[key] = value
    end
    Daneel.Debug.StackTrace.EndFunction()
end

--- Destroy the provided component, removing it from the game object.
-- Note that the component is removed only at the end of the current frame.
-- @param component (any component type) The component.
function Component.Destroy( component )
    Daneel.Debug.StackTrace.BeginFunction( "Component.Destroy", component )
    local errorHead = "Component.Destroy( component ) : "
    Daneel.Debug.CheckArgType( component, "component", Daneel.Config.componentTypes, errorHead )

    table.removevalue( component.gameObject, component )    
    CraftStudio.Destroy( component )
    Daneel.Debug.StackTrace.EndFunction()
end

--- Returns the component's internal unique identifier.
-- @param component (any component type) The component.
-- @return (number) The id.
function Component.GetId( component )
    -- no Debug because is used in __tostring
    return Daneel.Cache.GetId( component )
end


----------------------------------------------------------------------------------
-- Transform

local OriginalSetLocalScale = Transform.SetLocalScale

--- Set the transform's local scale.
-- @param transform (Transform) The transform component.
-- @param scale (number or Vector3) The global scale.
function Transform.SetLocalScale(transform, scale)
    Daneel.Debug.StackTrace.BeginFunction("Transform.SetLocalScale", transform, scale)
    local errorHead = "Transform.SetLocalScale(transform, scale) : "
    Daneel.Debug.CheckArgType(transform, "transform", "Transform", errorHead)
    local argType = Daneel.Debug.CheckArgType(scale, "scale", {"number", "Vector3"}, errorHead)

    if argType == "number" then
        scale = Vector3:New(scale)
    end
    OriginalSetLocalScale(transform, scale)
    Daneel.Debug.StackTrace.EndFunction()
end

--- Set the transform's global scale.
-- @param transform (Transform) The transform component.
-- @param scale (number or Vector3) The global scale.
function Transform.SetScale(transform, scale)
    Daneel.Debug.StackTrace.BeginFunction("Transform.SetScale", transform, scale)
    local errorHead = "Transform.SetScale(transform, scale) : "
    Daneel.Debug.CheckArgType(transform, "transform", "Transform", errorHead)
    local argType = Daneel.Debug.CheckArgType(scale, "scale", {"number", "Vector3"}, errorHead)

    if argType == "number" then
        scale = Vector3:New(scale)
    end

    local parent = transform.gameObject:GetParent()
    if parent ~= nil then
        scale = scale / parent.transform:GetScale()
    end
    transform:SetLocalScale( scale )
    Daneel.Debug.StackTrace.EndFunction()
end

--- Get the transform's global scale.
-- @param transform (Transform) The transform component.
-- @return (Vector3) The global scale.
function Transform.GetScale(transform)
    Daneel.Debug.StackTrace.BeginFunction("Transform.GetScale", transform)
    local errorHead = "Transform.GetScale(transform) : "
    Daneel.Debug.CheckArgType(transform, "transform", "Transform", errorHead)

    local scale = transform:GetLocalScale()
    local parent = transform.gameObject:GetParent()
    if parent ~= nil then
        scale = scale * parent.transform:GetScale()
    end
    Daneel.Debug.StackTrace.EndFunction()
    return scale
end


----------------------------------------------------------------------------------
-- ModelRenderer

local OriginalSetModel = ModelRenderer.SetModel

--- Attach the provided model to the provided modelRenderer.
-- @param modelRenderer (ModelRenderer) The modelRenderer.
-- @param modelNameOrAsset (string or Model) [optional] The model name or asset, or nil.
function ModelRenderer.SetModel( modelRenderer, modelNameOrAsset )
    Daneel.Debug.StackTrace.BeginFunction( "ModelRenderer.SetModel", modelRenderer, modelNameOrAsset )
    local errorHead = "ModelRenderer.SetModel( modelRenderer[, modelNameOrAsset] ) : "
    Daneel.Debug.CheckArgType( modelRenderer, "modelRenderer", "ModelRenderer", errorHead )
    Daneel.Debug.CheckOptionalArgType( modelNameOrAsset, "modelNameOrAsset", {"string", "Model"}, errorHead )

    local model = nil
    if modelNameOrAsset ~= nil then
        model = Asset.Get( modelNameOrAsset, "Model", true )
    end
    OriginalSetModel( modelRenderer, model )
    Daneel.Debug.StackTrace.EndFunction()
end

local OriginalSetAnimation = ModelRenderer.SetAnimation

--- Set the specified animation for the modelRenderer's current model.
-- @param modelRenderer (ModelRenderer) The modelRenderer.
-- @param animationNameOrAsset (string or ModelAnimation) [optional] The animation name or asset, or nil.
function ModelRenderer.SetAnimation( modelRenderer, animationNameOrAsset )
    Daneel.Debug.StackTrace.BeginFunction( "ModelRenderer.SetAnimation", modelRenderer, animationNameOrAsset )
    local errorHead = "ModelRenderer.SetAnimation( modelRenderer[, animationNameOrAsset] ) : "
    Daneel.Debug.CheckArgType( modelRenderer, "modelRenderer", "ModelRenderer", errorHead )
    Daneel.Debug.CheckOptionalArgType( animationNameOrAsset, "animationNameOrAsset", {"string", "ModelAnimation"}, errorHead )

    local animation = nil 
    if animationNameOrAsset ~= nil then
        animation = Asset.Get( animationNameOrAsset, "ModelAnimation", true )
    end
    OriginalSetAnimation( modelRenderer, animation )
    Daneel.Debug.StackTrace.EndFunction()
end

--- Apply the content of the params argument to the provided model renderer.
-- @param modelRenderer (ModelRenderer) The model renderer.
-- @param params (table) A table of parameters to set the component with.
function ModelRenderer.Set( modelRenderer, params )
    Daneel.Debug.StackTrace.BeginFunction( "ModelRenderer.Set", modelRenderer, params )
    local errorHead = "ModelRenderer.Set( modelRenderer, params ) : "
    Daneel.Debug.CheckArgType( modelRenderer, "modelRenderer", "ModelRenderer", errorHead )
    Daneel.Debug.CheckArgType( params, "params", "table", errorHead )

    if params.model ~= nil then
        modelRenderer:SetModel( params.model )
        params.model = nil
    end

    if params.animationTime ~= nil and params.animation ~= nil then
        modelRenderer:SetAnimation( params.animation )
        params.animation = nil
    end

    Component.Set( modelRenderer, params )
    Daneel.Debug.StackTrace.EndFunction()
end


----------------------------------------------------------------------------------
-- MapRenderer

local OriginalSetMap = MapRenderer.SetMap

--- Attach the provided map to the provided map renderer.
-- @param mapRenderer (MapRenderer) The map renderer.
-- @param mapNameOrAsset (string or Map) [optional] The map name or asset, or nil.
-- @param replaceTileSet (boolean) [optional default=true] Replace the current TileSet by the one set for the provided map in the map editor. 
function MapRenderer.SetMap( mapRenderer, mapNameOrAsset, replaceTileSet )
    Daneel.Debug.StackTrace.BeginFunction( "MapRenderer.SetMap", mapRenderer, mapNameOrAsset, replaceTileSet )
    local errorHead = "MapRenderer.SetMap( mapRenderer[, mapNameOrAsset, replaceTileSet] ) : "
    Daneel.Debug.CheckArgType( mapRenderer, "mapRenderer", "MapRenderer", errorHead )
    Daneel.Debug.CheckOptionalArgType( mapNameOrAsset, "mapNameOrAsset", {"string", "Map"}, errorHead )
    Daneel.Debug.CheckOptionalArgType( replaceTileSet, "replaceTileSet", "boolean", errorHead )

    local map = nil
    if mapNameOrAsset ~= nil then
        map = Asset.Get( mapNameOrAsset, "Map", true )
    end

    if replaceTileSet ~= nil then
        OriginalSetMap(mapRenderer, map, replaceTileSet)
    else
        OriginalSetMap(mapRenderer, map)
    end
    Daneel.Debug.StackTrace.EndFunction()
end

local OriginalSetTileSet = MapRenderer.SetTileSet

--- Set the specified tileSet for the mapRenderer's map.
-- @param mapRenderer (MapRenderer) The mapRenderer.
-- @param tileSetNameOrAsset (string or TileSet) [optional] The tileSet name or asset, or nil.
function MapRenderer.SetTileSet( mapRenderer, tileSetNameOrAsset )
    Daneel.Debug.StackTrace.BeginFunction("MapRenderer.SetTileSet", mapRenderer, tileSetNameOrAsset )
    local errorHead = "MapRenderer.SetTileSet( mapRenderer[, tileSetNameOrAsset] ) : "
    Daneel.Debug.CheckArgType( mapRenderer, "mapRenderer", "MapRenderer", errorHead )
    Daneel.Debug.CheckOptionalArgType( tileSetNameOrAsset, "tileSetNameOrAsset", {"string", "TileSet"}, errorHead )

    local tileSet = nil
    if tileSetNameOrAsset ~= nil then
        tileSet = Asset.Get( tileSetNameOrAsset, "TileSet", true )
    end
    OriginalSetTileSet( mapRenderer, tileSet )
    Daneel.Debug.StackTrace.EndFunction()
end

--- Apply the content of the params argument to the provided map renderer.
-- @param mapRenderer (MapRenderer) The map renderer.
-- @param params (table) A table of parameters to set the component with.
function MapRenderer.Set( mapRenderer, params )
    Daneel.Debug.StackTrace.BeginFunction( "MapRenderer.Set", mapRenderer, params )
    local errorHead = "MapRenderer.Set( mapRenderer, params ) : "
    Daneel.Debug.CheckArgType( mapRenderer, "mapRenderer", "MapRenderer", errorHead )
    Daneel.Debug.CheckArgType( params, "params", "table", errorHead )

    if params.map ~= nil then
        mapRenderer:SetMap( params.map )
        -- set the map here in case of the tileSet property is set too
        params.map = nil
    end

    Component.Set( mapRenderer, params )
    Daneel.Debug.StackTrace.EndFunction()
end


----------------------------------------------------------------------------------
-- TextRenderer

local OriginalSetFont = TextRenderer.SetFont

--- Set the provided font to the provided text renderer.
-- @param textRenderer (TextRenderer) The text renderer.
-- @param fontNameOrAsset (string or Font) [optional] The font name or asset, or nil.
function TextRenderer.SetFont( textRenderer, fontNameOrAsset )
    Daneel.Debug.StackTrace.BeginFunction( "TextRenderer.SetFont", textRenderer, fontNameOrAsset )
    local errorHead = "TextRenderer.SetFont( textRenderer[, fontNameOrAsset] ) : "
    Daneel.Debug.CheckArgType( textRenderer, "textRenderer", "TextRenderer", errorHead )
    Daneel.Debug.CheckOptionalArgType( fontNameOrAsset, "fontNameOrAsset", {"string", "Font"}, errorHead )

    local font = nil
    if fontNameOrAsset ~= nil then
        font = Asset.Get( fontNameOrAsset, "Font", true )
    end
    OriginalSetFont( textRenderer, font )
    Daneel.Debug.StackTrace.EndFunction()
end

local OriginalSetAlignment = TextRenderer.SetAlignment

--- Set the text's alignment.
-- @param textRenderer (TextRenderer) The textRenderer.
-- @param alignment (string or TextRenderer.Alignment) The alignment. Values (case-insensitive when of type string) may be "left", "center", "right", TextRenderer.Alignment.Left, TextRenderer.Alignment.Center or TextRenderer.Alignment.Right.
function TextRenderer.SetAlignment(textRenderer, alignment)
    Daneel.Debug.StackTrace.BeginFunction("TextRenderer.SetAlignment", textRenderer, alignment)
    local errorHead = "TextRenderer.SetAlignment(textRenderer, alignment) : "
    Daneel.Debug.CheckArgType(textRenderer, "textRenderer", "TextRenderer", errorHead)
    local argType = Daneel.Debug.CheckArgType(alignment, "alignment", {"string", "userdata", "number"}, errorHead) -- number because enum returns a number in the webplayer

    if argType == "string" then
        local default = "Center"
        if Daneel.Config.textRenderer ~= nil and Daneel.Config.textRenderer.alignment ~= nil then
            default = Daneel.Config.textRenderer.alignment
        end
        alignment = Daneel.Debug.CheckArgValue( alignment, "alignment", {"Left", "Center", "Right"}, errorHead, default )
        alignment = TextRenderer.Alignment[ alignment ]
    end
    OriginalSetAlignment( textRenderer, alignment )
    Daneel.Debug.StackTrace.EndFunction()
end

--- Update the game object's scale to make the text appear the provided width.
-- @param textRenderer (TextRenderer) The textRenderer.
-- @param width (number) The text's width in scene units.
function TextRenderer.SetTextWidth( textRenderer, width )
    Daneel.Debug.StackTrace.BeginFunction("TextRenderer.SetTextWidth", textRenderer, width)
    local errorHead = "TextRenderer.SetTextWidth(textRenderer, width) : "
    Daneel.Debug.CheckArgType(textRenderer, "textRenderer", "TextRenderer", errorHead)
    local argType = Daneel.Debug.CheckArgType(width, "width", "number", errorHead)

    local widthScaleRatio = textRenderer:GetTextWidth() / textRenderer.gameObject.transform:GetScale()
    textRenderer.gameObject.transform:SetScale( width / widthScaleRatio )
    Daneel.Debug.StackTrace.EndFunction()
end


----------------------------------------------------------------------------------
-- Camera

local OriginalSetProjectionMode = Camera.SetProjectionMode

--- Sets the camera projection mode.
-- @param camera (Camera) The camera.
-- @param projectionMode (string or Camera.ProjectionMode) The projection mode. Possible values are "perspective", "orthographic" (as a case-insensitive string), Camera.ProjectionMode.Perspective or Camera.ProjectionMode.Orthographic.
function Camera.SetProjectionMode( camera, projectionMode )
    Daneel.Debug.StackTrace.BeginFunction( "Camera.SetProjectionMode", camera, projectionMode )
    local errorHead = "Camera.SetProjectionMode( camera, projectionMode ) : "
    Daneel.Debug.CheckArgType( camera, "camera", "Camera", errorHead)
    local argType = Daneel.Debug.CheckArgType( projectionMode, "projectionMode", {"string", "userdata", "number"}, errorHead )

    if argType == "string" then
        local default = "Perspective"
        if Daneel.Config.camera ~= nil and Daneel.Config.camera.projectionMode ~= nil then
            default = Daneel.Config.camera.projectionMode
        end
        projectionMode = Daneel.Debug.CheckArgValue( projectionMode, "projectionMode", {"Perspective", "Orthographic"}, errorHead, default )
        projectionMode = Camera.ProjectionMode[ projectionMode ]
    end

    OriginalSetProjectionMode( camera, projectionMode )
    Daneel.Debug.StackTrace.EndFunction()
end

--- Apply the content of the params argument to the provided camera.
-- @param camera (Camera) The camera.
-- @param params (table) A table of parameters to set the component with.
function Camera.Set( camera, params )
    Daneel.Debug.StackTrace.BeginFunction( "Camera.Set", camera, params )
    local errorHead = "Camera.Set( camera, params ) : "
    Daneel.Debug.CheckArgType( camera, "camera", "Camera", errorHead )
    Daneel.Debug.CheckArgType( params, "params", "table", errorHead )

    if params.projectionMode ~= nil then
        camera:SetProjectionMode( params.projectionMode )
        params.projectionMode = nil
    end

    Component.Set( camera, params )
    Daneel.Debug.StackTrace.EndFunction()
end


----------------------------------------------------------------------------------
-- Ray

setmetatable( Ray, { __call = function(Object, ...) return Object:New(...) end } )

--- Check the collision of the ray against the provided set of game objects.
-- @param ray (Ray) The ray.
-- @param gameObjects (table) The set of game objects to cast the ray against.
-- @param sortByDistance [optional default=false] (boolean) Sort the raycastHit by increasing distance in the returned table.
-- @return (table) A table of RaycastHits (will be empty if the ray didn't intersects anything).
function Ray.Cast( ray, gameObjects, sortByDistance )
    Daneel.Debug.StackTrace.BeginFunction( "Ray.Cast", ray, gameObjects, sortByDistance )
    local errorHead = "Ray.Cast( ray, gameObjects[, sortByDistance] ) : "
    Daneel.Debug.CheckArgType( ray, "ray", "Ray", errorHead )
    Daneel.Debug.CheckArgType( gameObjects, "gameObjects", "table", errorHead )
    Daneel.Debug.CheckOptionalArgType( sortByDistance, "sortByDistance", "boolean", errorHead )
    
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

    Daneel.Debug.StackTrace.EndFunction()
    return hits
end

--- Check if the ray intersect the specified game object.
-- @param ray (Ray) The ray.
-- @param gameObjectNameOrInstance (string or GameObject) The game object instance or name.
-- @return (RaycastHit) A raycastHit with the if there was a collision, or nil.
function Ray.IntersectsGameObject( ray, gameObjectNameOrInstance )
    Daneel.Debug.StackTrace.BeginFunction( "Ray.IntersectsGameObject", ray, gameObjectNameOrInstance )
    local errorHead = "Ray.IntersectsGameObject( ray, gameObjectNameOrInstance ) : "
    Daneel.Debug.CheckArgType( ray, "ray", "Ray", errorHead )
    Daneel.Debug.CheckArgType( gameObjectNameOrInstance, "gameObjectNameOrInstance", {"string", "GameObject"}, errorHead )
    
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

    Daneel.Debug.StackTrace.EndFunction()
    return raycastHit
end

local OriginalIntersectsPlane = Ray.IntersectsPlane

-- Check if the ray intersects the provided plane and returns the distance of intersection or a raycastHit.
-- @param ray (Ray) The ray.
-- @param plane (Plane) The plane.
-- @param returnRaycastHit (boolean) [optional default=false] Tell if the hit infos must be returned as a raycastHit.
-- @return (number or RaycastHit) The distance of intersection (if any) or a raycastHit with the 'distance' and 'hitLocation' properties (if any).
function Ray.IntersectsPlane( ray, plane, returnRaycastHit )
    -- 08/08/13 removed reference to plane in BeginFunction and CheckArgType
    -- because Plane.__tostring is wrong, causes 'var self is not declared'
    Daneel.Debug.StackTrace.BeginFunction( "Ray.IntersectsPlane", ray, nil, returnRaycastHit )
    local errorHead = "Ray.IntersectsPlane( ray, plane[, returnRaycastHit] ) : "
    Daneel.Debug.CheckArgType( ray, "ray", "Ray", errorHead )
    --Daneel.Debug.CheckArgType( plane, "plane", "Plane", errorHead )
    returnRaycastHit = Daneel.Debug.CheckOptionalArgType( returnRaycastHit, "returnRaycastHit", "boolean", errorHead, false )

    local distance = OriginalIntersectsPlane( ray, plane )
    if returnRaycastHit and distance ~= nil then
        local raycastHit = RaycastHit.New({
            distance = distance,
            hitLocation = ray.position + ray.direction * distance,
            hitObject = plane,
        })

        distance = raycastHit
    end

    Daneel.Debug.StackTrace.EndFunction()
    return distance
end

local OriginalIntersectsModelRenderer = Ray.IntersectsModelRenderer

-- Check if the ray intersects the provided modelRenderer.
-- @param ray (Ray) The ray.
-- @param modelRenderer (ModelRenderer) The modelRenderer.
-- @param returnRaycastHit (boolean) [optional default=false] Tell if the hit infos must be returned as a raycastHit.
-- @return (number or RaycastHit) The distance of intersection (if any) or a raycastHit with the 'distance', 'normal' and 'hitLocation' properties (if any).
-- @return (Vector3) If 'returnRaycastHit' argument is false : the normal of the hit face, or nil
function Ray.IntersectsModelRenderer( ray, modelRenderer, returnRaycastHit )
    Daneel.Debug.StackTrace.BeginFunction( "Ray.IntersectsModelRenderer", ray, modelRenderer, returnRaycastHit )
    local errorHead = "Ray.IntersectsModelRenderer( ray, modelRenderer[, returnRaycastHit] ) : "
    Daneel.Debug.CheckArgType( ray, "ray", "Ray", errorHead )
    Daneel.Debug.CheckArgType( modelRenderer, "modelRenderer", "ModelRenderer", errorHead )
    returnRaycastHit = Daneel.Debug.CheckOptionalArgType( returnRaycastHit, "returnRaycastHit", "boolean", errorHead, false )

    local distance, normal = OriginalIntersectsModelRenderer( ray, modelRenderer )
    if returnRaycastHit and distance ~= nil then
        local raycastHit = RaycastHit.New({
            distance = distance,
            normal = normal,
            hitLocation = ray.position + ray.direction * distance,
            hitObject = modelRenderer,
            gameObject = modelRenderer.gameObject,
        })

        distance = raycastHit
        normal = nil
    end

    Daneel.Debug.StackTrace.EndFunction()
    return distance, normal
end

local OriginalIntersectsMapRenderer = Ray.IntersectsMapRenderer

-- Check if the ray intersects the provided mapRenderer.
-- @param ray (Ray) The ray.
-- @param mapRenderer (MapRenderer) The mapRenderer.
-- @param returnRaycastHit (boolean) [optional default=false] Tell if the hit infos must be returned as a raycastHit.
-- @return (number or RaycastHit) The distance of intersection (if any) or a raycastHit with the 'distance', 'normal', 'hitBlockLocation', 'adjacentBlockLocation' and 'hitLocation' properties (if any).
-- @return (Vector3) If 'returnRaycastHit' argument is false : the normal of the hit face, or nil
-- @return (Vector3) If 'returnRaycastHit' argument is false : the location of the block hit, or nil
-- @return (Vector3) If 'returnRaycastHit' argument is false : the location of the adjacent block, or nil
function Ray.IntersectsMapRenderer( ray, mapRenderer, returnRaycastHit )
    Daneel.Debug.StackTrace.BeginFunction( "Ray.IntersectsMapRenderer", ray, mapRenderer, returnRaycastHit )
    local errorHead = "Ray.IntersectsMapRenderer( ray, mapRenderer[, returnRaycastHit] ) : "
    Daneel.Debug.CheckArgType( ray, "ray", "Ray", errorHead )
    Daneel.Debug.CheckArgType( mapRenderer, "mapRenderer", "MapRenderer", errorHead )
    returnRaycastHit = Daneel.Debug.CheckOptionalArgType( returnRaycastHit, "returnRaycastHit", "boolean", errorHead, false )

    local distance, normal, hitBlockLocation, adjacentBlockLocation = OriginalIntersectsMapRenderer( ray, mapRenderer )
    if hitBlockLocation ~= nil then
        setmetatable( hitBlockLocation, Vector3 )
    end
    if adjacentBlockLocation ~= nil then
        setmetatable( adjacentBlockLocation, Vector3 )
    end

    if returnRaycastHit and distance ~= nil then
        local raycastHit = RaycastHit.New({
            distance = distance,
            normal = normal,
            hitBlockLocation = hitBlockLocation,
            adjacentBlockLocation = adjacentBlockLocation,
            hitLocation = ray.position + ray.direction * distance,
            hitObject = mapRenderer,
            gameObject = mapRenderer.gameObject,
        })

        distance = raycastHit
        normal = nil
        hitBlockLocation = nil
        adjacentBlockLocation = nil
    end

    Daneel.Debug.StackTrace.EndFunction()
    return distance, normal, hitBlockLocation, adjacentBlockLocation
end

local OriginalIntersectsTextRenderer = Ray.IntersectsTextRenderer

-- Check if the ray intersects the provided textRenderer.
-- @param ray (Ray) The ray.
-- @param textRenderer (TextRenderer) The textRenderer.
-- @param returnRaycastHit (boolean) [optional default=false] Tell if the hit infos must be returned as a raycastHit.
-- @return (number or RaycastHit) The distance of intersection (if any) or a raycastHit with the 'distance', 'normal' and 'hitLocation' properties (if any).
-- @return (Vector3) If 'returnRaycastHit' argument is false : the normal of the hit face, or nil
function Ray.IntersectsTextRenderer( ray, textRenderer, returnRaycastHit )
    Daneel.Debug.StackTrace.BeginFunction( "Ray.IntersectsTextRenderer", ray, textRenderer, returnRaycastHit )
    local errorHead = "Ray.IntersectsTextRenderer( ray, textRenderer[, returnRaycastHit] ) : "
    Daneel.Debug.CheckArgType( ray, "ray", "Ray", errorHead )
    Daneel.Debug.CheckArgType( textRenderer, "textRenderer", "TextRenderer", errorHead )
    returnRaycastHit = Daneel.Debug.CheckOptionalArgType( returnRaycastHit, "returnRaycastHit", "boolean", errorHead, false )

    local distance, normal = OriginalIntersectsTextRenderer( ray, textRenderer )
    if returnRaycastHit and distance ~= nil then
        local raycastHit = RaycastHit.New({
            distance = distance,
            normal = normal,
            hitLocation = ray.position + ray.direction * distance,
            hitObject = textRenderer,
            gameObject = textRenderer.gameObject,
        })

        Daneel.Debug.StackTrace.EndFunction()
        return raycastHit
    end

    Daneel.Debug.StackTrace.EndFunction()
    return distance, normal
end


----------------------------------------------------------------------------------
-- RaycastHit

RaycastHit = {}
RaycastHit.__index = RaycastHit
setmetatable( RaycastHit, { __call = function(Object, ...) return Object.New(...) end } )

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

--- Create a new RaycastHit
-- @return (RaycastHit) The raycastHit.
function RaycastHit.New( data )
    Daneel.Debug.StackTrace.BeginFunction( "RaycastHit.New", data )
    local errorHead = "RaycastHit.New( [data] ) : "
    data = Daneel.Debug.CheckOptionalArgType( data, "data", "table", errorHead, {} )

    local raycastHit = setmetatable( data, RaycastHit )
    Daneel.Debug.StackTrace.EndFunction()
    return raycastHit
end


----------------------------------------------------------------------------------
-- Scene

--- Alias of CraftStudio.LoadScene().
-- Schedules loading the specified scene after the current tick (frame) (1/60th of a second) has completed.
-- When the new scene is loaded, all of the current scene's game objects will be removed.
-- Calling this function doesn't immediately stops the calling function. As such, you might want to add a return statement afterwards. 
-- @param sceneNameOrAsset (string or Scene) The scene name or asset.
function Scene.Load( sceneNameOrAsset )
    Daneel.Debug.StackTrace.BeginFunction( "Scene.Load", sceneNameOrAsset )
    local errorHead = "Scene.Load( sceneNameOrAsset ) : "
    Daneel.Debug.CheckArgType( sceneNameOrAsset, "sceneNameOrAsset", {"string", "Scene"}, errorHead )

    CraftStudio.LoadScene( sceneNameOrAsset )
    Daneel.Debug.StackTrace.EndFunction()
end

local OriginalLoadScene = CraftStudio.LoadScene

--- Schedules loading the specified scene after the current tick (1/60th of a second) has completed.
-- When the new scene is loaded, all of the current scene's game objects will be removed.
-- Calling this function doesn't immediately stops the calling function. As such, you might want to add a return statement afterwards. 
-- @param sceneNameOrAsset (string or Scene) The scene name or asset.
function CraftStudio.LoadScene( sceneNameOrAsset )
    Daneel.Debug.StackTrace.BeginFunction( "CraftStudio.LoadScene", sceneNameOrAsset )
    local errorHead = "CraftStudio.LoadScene( sceneNameOrAsset ) : "
    Daneel.Debug.CheckArgType( sceneNameOrAsset, "sceneNameOrAsset", {"string", "Scene"}, errorHead )

    local scene = Asset.Get( sceneNameOrAsset, "Scene", true )
    
    Daneel.Event.Fire( "OnSceneLoad", scene )
    Daneel.Event.events = {} -- do this here to make sure that any events that might be fired from OnSceneLoad-catching function are indeed fired
    Scene.current = scene

    Daneel.Debug.StackTrace.EndFunction()
    OriginalLoadScene( scene )
end

--- Alias of CraftStudio.AppendScene().
-- Appends the specified scene to the game by instantiating all of its game objects. Contrary to CraftStudio.LoadScene, this doesn't unload the current scene nor waits for the next tick: it happens right away.
-- You can optionally specify a parent game object which will be used as a root for adding all game objects. 
-- Returns the game object appended if there was only one root game object in the provided scene.
-- @param sceneNameOrAsset (string or Scene) The scene name or asset.
-- @param parentNameOrInstance [optional] (string or GameObject) The parent game object name or instance.
-- @return (GameObject) The appended game object, or nil.
function Scene.Append( sceneNameOrAsset, parentNameOrInstance )
    Daneel.Debug.StackTrace.BeginFunction( "Scene.Append", sceneNameOrAsset, parentNameOrInstance )
    local errorHead = "Scene.Append( sceneNameOrAsset[, parentNameOrInstance] ) : "
    Daneel.Debug.CheckArgType( sceneNameOrAsset, "sceneNameOrAsset", {"string", "Scene"}, errorHead )
    Daneel.Debug.CheckOptionalArgType( parentNameOrInstance, "parentNameOrInstance", {"string", "GameObject"}, errorHead )

    local scene = Asset.Get( sceneNameOrAsset, "Scene", true )
    local parent = nil
    if parentNameOrInstance ~= nil then
        parent = GameObject.Get( parentNameOrInstance, true )
    end
    local gameObject = CraftStudio.AppendScene( scene, parent )

    Daneel.Debug.StackTrace.EndFunction()
    return gameObject
end


----------------------------------------------------------------------------------

local OriginalDestroy = CraftStudio.Destroy

--- Removes the specified game object (and all of its descendants) or the specified component from its game object.
-- You can also optionally specify a dynamically loaded asset for unloading (See Map.LoadFromPackage ).
-- Sets the 'isDestroyed' property to 'true' and fires the 'OnDestroy' event on the object.
-- @param object (GameObject, a component or a dynamically loaded asset) The game object, component or a dynamically loaded asset (like a map loaded with Map.LoadFromPackage).
function CraftStudio.Destroy( object )
    Daneel.Debug.StackTrace.BeginFunction( "CraftStudio.Destroy", object )
    if type( object ) == "table" then
        Daneel.Event.Fire( object, "OnDestroy", object )
        Daneel.Event.StopListen( object ) -- remove from listener list
        object.isDestroyed = true
    end
    OriginalDestroy( object )
    Daneel.Debug.StackTrace.EndFunction()
end


----------------------------------------------------------------------------------
-- GAMEOBJECT
----------------------------------------------------------------------------------


setmetatable( GameObject, { __call = function(Object, ...) return Object.New(...) end } )

-- returns something like "GameObject: 123456789: 'MyName'"
function GameObject.__tostring( gameObject )
    if rawget( gameObject, "transform" ) == nil then
        return "Destroyed gameObject: " .. Daneel.Debug.ToRawString( gameObject )
        -- the important here was to prevent throwing an error
    end

    return "GameObject: " .. gameObject:GetId() .. ": '" .. gameObject:GetName() .. "'"
end

-- Dynamic getters
function GameObject.__index( gameObject, key )
    if GameObject[ key ] ~= nil then
        return GameObject[ key ]
    end

    -- maybe the key is a script alias
    local path = Daneel.Config.scriptPaths[ key ]
    if path ~= nil then
        local behavior = gameObject:GetScriptedBehavior( path )
        if behavior ~= nil then
            rawset( gameObject, key, behavior )
            return behavior
        end
    end

    if type( key ) == "string" then
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


----------------------------------------------------------------------------------

--- Create a new game object and optionally initialize it.
-- When the first argument is a scene name or asset, the scene may contains only one top-level game object.
-- If it's not the case, the function won't return any game object yet some may have been created (depending on the behavior of CS.AppendScene()).
-- @param name (string or Scene) The game object name or scene name or scene asset.
-- @param params (table) [optional] A table with parameters to initialize the new game object with.
-- @return (GameObject) The new game object.
function GameObject.New( name, params )
    Daneel.Debug.StackTrace.BeginFunction( "GameObject.New", name, params )
    local errorHead = "GameObject.New( name[, params] ) : "
    local argType = Daneel.Debug.CheckArgType( name, "name", {"string", "Scene"}, errorHead )
    Daneel.Debug.CheckOptionalArgType( params, "params", "table", errorHead )
    
    local gameObject = nil
    local scene = Asset.Get( name, "Scene" ) -- scene will be nil if name is a sting ad not a scene path
    if scene ~= nil then
        gameObject = CraftStudio.AppendScene( scene )
    else
        gameObject = CraftStudio.CreateGameObject( name )
    end

    if params ~= nil and gameObject ~= nil then
        gameObject:Set(params)
    end
    Daneel.Debug.StackTrace.EndFunction()
    return gameObject
end

--- Create a new game object with the content of the provided scene and optionally initialize it.
-- @param gameObjectName (string) The game object name.
-- @param sceneNameOrAsset (string or Scene) The scene name or scene asset.
-- @param params [optional] (table) A table with parameters to initialize the new game object with.
-- @return (GameObject) The new game object.
function GameObject.Instantiate(gameObjectName, sceneNameOrAsset, params)
    Daneel.Debug.StackTrace.BeginFunction("GameObject.Instantiate", gameObjectName, sceneNameOrAsset, params)
    local errorHead = "GameObject.Instantiate( gameObjectName, sceneNameOrAsset[, params] ) : "
    Daneel.Debug.CheckArgType(gameObjectName, "gameObjectName", "string", errorHead)
    Daneel.Debug.CheckArgType(sceneNameOrAsset, "sceneNameOrAsset", {"string", "Scene"}, errorHead)
    Daneel.Debug.CheckOptionalArgType(params, "params", "table", errorHead)

    local scene = Asset.Get(sceneNameOrAsset, "Scene", true)
    local gameObject = CraftStudio.Instantiate(gameObjectName, scene)
    if params ~= nil then
        gameObject:Set( params )
    end
    Daneel.Debug.StackTrace.EndFunction()
    return gameObject
end

--- Apply the content of the params argument to the provided game object.
-- @param gameObject (GameObject) The game object.
-- @param params (table) A table of parameters to set the game object with.
function GameObject.Set( gameObject, params )
    Daneel.Debug.StackTrace.BeginFunction( "GameObject.Set", gameObject, params )
    local errorHead = "GameObject.Set( gameObject, params ) : "
    Daneel.Debug.CheckArgType( gameObject, "gameObject", "GameObject", errorHead )
    Daneel.Debug.CheckArgType( params, "params", "table", errorHead )
    local argType = nil
    
    if params.parent ~= nil then
        -- do that first so that setting a local position works
        gameObject:SetParent( params.parent )
        params.parent = nil
    end
    
    -- components
    for i, componentType in pairs( Daneel.Config.componentTypes ) do
        local component = nil

        if componentType ~= "ScriptedBehavior" then
            componentType = componentType:lower()

            -- check if params has a key for that component
            local componentParams = nil
            for key, value in pairs( params ) do
                if key:lower() == componentType then
                    componentParams = value
                    Daneel.Debug.CheckArgType( componentParams, "params."..key, "table", errorHead )
                    break
                end
            end

            if componentParams ~= nil then
                -- check if gameObject has a key for that component
                for key, value in pairs( gameObject ) do
                    if key:lower() == componentType then
                        component = value
                        break
                    end
                end
                
                if component == nil then -- can work for built-in components when their property on the game object has been unset for some reason
                    component = gameObject:GetComponent( componentType )
                end
                
                if component == nil then
                    component = gameObject:AddComponent( componentType )
                end

                component:Set( componentParams )
                table.removevalue( params, componentParams )
            end
        end
    end

    -- all other keys/values
    for key, value in pairs( params ) do

        -- if key is a script alias or a script path
        if Daneel.Config.scriptPaths[key] ~= nil or table.containsvalue( Daneel.Config.scriptPaths, key ) then
            local scriptPath = key
            if Daneel.Config.scriptPaths[key] ~= nil then
                scriptPath = Daneel.Config.scriptPaths[key]
            end

            local component = gameObject:GetScriptedBehavior( scriptPath )
            if component == nil then
                component = gameObject:AddComponent( scriptPath )
            end
            
            component:Set(value)

        elseif key == "tags"  then
            gameObject:RemoveTag()
            gameObject:AddTag( value )

        else
            gameObject[key] = value
        end
    end
    Daneel.Debug.StackTrace.EndFunction()
end


----------------------------------------------------------------------------------
-- Miscellaneous

--- Alias of CraftStudio.FindGameObject(name).
-- Get the first game object with the provided name.
-- @param name (string) The game object name.
-- @param errorIfGameObjectNotFound [optional default=false] (boolean) Throw an error if the game object was not found (instead of returning nil).
-- @return (GameObject) The game object or nil if none is found.
function GameObject.Get( name, errorIfGameObjectNotFound ) 
    if getmetatable(name) == GameObject then
        return name
    end

    Daneel.Debug.StackTrace.BeginFunction( "GameObject.Get", name, errorIfGameObjectNotFound )
    local errorHead = "GameObject.Get( name[, errorIfGameObjectNotFound] ) : "
    Daneel.Debug.CheckArgType( name, "name", "string", errorHead )
    Daneel.Debug.CheckOptionalArgType( errorIfGameObjectNotFound, "errorIfGameObjectNotFound", "boolean", errorHead )
    

    local gameObject = nil
    local names = string.split( name, "." )
    
    gameObject = CraftStudio.FindGameObject( names[1] )
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

    Daneel.Debug.StackTrace.EndFunction()
    return gameObject
end

--- Returns the game object's internal unique identifier.
-- @param gameObject (GameObject) The game object.
-- @return (number) The id.
function GameObject.GetId( gameObject )
    return Daneel.Cache.GetId( gameObject )
end

local OriginalSetParent = GameObject.SetParent

--- Set the game object's parent. 
-- Optionaly carry over the game object's local transform instead of the global one.
-- @param gameObject (GameObject) The game object.
-- @param parentNameOrInstance [optional] (string or GameObject) The parent name or game object (or nil to remove the parent).
-- @param keepLocalTransform [optional default=false] (boolean) Carry over the game object's local transform instead of the global one.
function GameObject.SetParent(gameObject, parentNameOrInstance, keepLocalTransform)
    Daneel.Debug.StackTrace.BeginFunction("GameObject.SetParent", gameObject, parentNameOrInstance, keepLocalTransform)
    local errorHead = "GameObject.SetParent(gameObject, [parentNameOrInstance, keepLocalTransform]) : "
    Daneel.Debug.CheckArgType(gameObject, "gameObject", "GameObject", errorHead)
    Daneel.Debug.CheckOptionalArgType(parentNameOrInstance, "parentNameOrInstance", {"string", "GameObject"}, errorHead)
    keepLocalTransform = Daneel.Debug.CheckOptionalArgType(keepLocalTransform, "keepLocalTransform", "boolean", errorHead, false)

    local parent = nil
    if parentNameOrInstance ~= nil then
        parent = GameObject.Get(parentNameOrInstance, true)
    end
    OriginalSetParent(gameObject, parent, keepLocalTransform)
    Daneel.Debug.StackTrace.EndFunction()
end

--- Alias of GameObject.FindChild().
-- Find the first game object's child with the provided name.
-- If the name is not provided, it returns the first child.
-- @param gameObject (GameObject) The game object.
-- @param name [optional] (string) The child name (may be hyerarchy of names separated by dots).
-- @param recursive [optional default=false] (boolean) Search for the child in all descendants instead of just the first generation.
-- @return (GameObject) The child or nil if none is found.
function GameObject.GetChild( gameObject, name, recursive )
    Daneel.Debug.StackTrace.BeginFunction( "GameObject.GetChild", gameObject, name, recursive )
    local errorHead = "GameObject.GetChild( gameObject, name[, recursive] ) : "
    Daneel.Debug.CheckArgType( gameObject, "gameObject", "GameObject", errorHead )
    Daneel.Debug.CheckOptionalArgType( name, "name", "string", errorHead )
    recursive = Daneel.Debug.CheckOptionalArgType( recursive, "recursive", "boolean", errorHead, false )
    
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
    Daneel.Debug.StackTrace.EndFunction()
    return child
end

local OriginalGetChildren = GameObject.GetChildren

--- Get all descendants of the game object.
-- @param gameObject (GameObject) The game object.
-- @param recursive [optional default=false] (boolean) Look for all descendants instead of just the first generation.
-- @param includeSelf [optional default=false] (boolean) Include the game object in the children.
-- @return (table) The children.
function GameObject.GetChildren( gameObject, recursive, includeSelf )
    Daneel.Debug.StackTrace.BeginFunction( "GameObject.GetChildren", gameObject, recursive, includeSelf )
    local errorHead = "GameObject.GetChildren( gameObject[, recursive, includeSelf] ) : "
    Daneel.Debug.CheckArgType( gameObject, "gameObject", "GameObject", errorHead )
    Daneel.Debug.CheckOptionalArgType( recursive, "recursive", "boolean", errorHead )
    Daneel.Debug.CheckOptionalArgType( includeSelf, "includeSelf", "boolean", errorHead )

    local allChildren = OriginalGetChildren( gameObject )

    if recursive then
        for i, child in ipairs( table.copy( allChildren ) ) do
            allChildren = table.merge( allChildren, child:GetChildren( true ) )
        end
    end

    if includeSelf then
        table.insert( allChildren, 1, gameObject )
    end
    Daneel.Debug.StackTrace.EndFunction()
    return allChildren
end

local OriginalSendMessage = GameObject.SendMessage

--- Tries to call a method with the provided name on all the scriptedBehaviors attached to the game object. 
-- The data argument can be nil or a table you want the method to receive as its first (and only) argument.
-- If none of the scripteBehaviors attached to the game object or its children have a method matching the provided name, nothing happens. 
-- @param gameObject (GameObject) The game object.
-- @param functionName (string) The method name.
-- @param data [optional] (table) The data to pass along the method call.
function GameObject.SendMessage(gameObject, functionName, data)
    Daneel.Debug.StackTrace.BeginFunction("GameObject.SendMessage", gameObject, functionName, data)
    local errorHead = "GameObject.SendMessage(gameObject, functionName[, data]) : "
    Daneel.Debug.CheckArgType(gameObject, "gameObject", "GameObject", errorHead)
    Daneel.Debug.CheckArgType(functionName, "functionName", "string", errorHead)
    Daneel.Debug.CheckOptionalArgType(data, "data", "table", errorHead)
    
    -- prevent an error of type "La référence d'objet n'est pas définie à une instance d'un objet." to stops the script that sends the message
    local success = Daneel.Debug.Try( function()
        OriginalSendMessage( gameObject, functionName, data )
    end )
    
    if not success then
        local dataText = "No data"
        local length = 0
        if data ~= nil then
            length = table.getlength( data )
            dataText = "Data with "..length.." entries"
        end
        print( errorHead.."Error sending message with parameters : ", gameObject, functionName, dataText )
        if length > 0 then
            table.print( data )
        end
    end

    Daneel.Debug.StackTrace.EndFunction()
end

--- Tries to call a method with the provided name on all the scriptedBehaviors attached to the game object or any of its descendants. 
-- The data argument can be nil or a table you want the method to receive as its first (and only) argument.
-- If none of the scripteBehaviors attached to the game object or its children have a method matching the provided name, nothing happens. 
-- @param gameObject (GameObject) The game object.
-- @param functionName (string) The method name.
-- @param data [optional] (table) The data to pass along the method call.
function GameObject.BroadcastMessage(gameObject, functionName, data)
    Daneel.Debug.StackTrace.BeginFunction("GameObject.BroadcastMessage", gameObject, functionName, data)
    local errorHead = "GameObject.BroadcastMessage(gameObject, functionName[, data]) : "
    Daneel.Debug.CheckArgType(gameObject, "gameObject", "GameObject", errorHead)
    Daneel.Debug.CheckArgType(functionName, "functionName", "string", errorHead)
    Daneel.Debug.CheckOptionalArgType(data, "data", "table", errorHead)
    
    local allGos = gameObject:GetChildren(true, true) -- the game object + all of its children
    for i, go in ipairs(allGos) do
        go:SendMessage(functionName, data)
    end
    Daneel.Debug.StackTrace.EndFunction()
end


----------------------------------------------------------------------------------
-- Add components

--- Add a component to the game object and optionally initialize it.
-- @param gameObject (GameObject) The game object.
-- @param componentType (string or Script) The component type, or script asset, path or alias (can't be Transform or ScriptedBehavior).
-- @param params [optional] (string, Script or table) A table of parameters to initialize the new component with or, if componentType is 'ScriptedBehavior', the mandatory script name or asset.
-- @return (mixed) The component.
function GameObject.AddComponent( gameObject, componentType, params )
    Daneel.Debug.StackTrace.BeginFunction( "GameObject.AddComponent", gameObject, componentType, params )
    local errorHead = "GameObject.AddComponent( gameObject, componentType[, params] ) : "
    Daneel.Debug.CheckArgType( gameObject, "gameObject", "GameObject", errorHead )
    Daneel.Debug.CheckArgType( componentType, "componentType", {"string", "Script"}, errorHead )
    componentType = Daneel.Debug.CheckArgValue( componentType, "componentType", Daneel.Config.componentTypes, errorHead, componentType )
    Daneel.Debug.CheckOptionalArgType( params, "params", "table", errorHead )    

    local component = nil
    
    if Daneel.Config.componentObjects[ componentType ] == nil then
        -- componentType is not one of the component types
        -- it may be a script path, alias or asset
        local script = Asset.Get( componentType, "Script" )
        if script == nil then
            if Daneel.Config.debug.enableDebug then
                error( errorHead.."Provided component type '"..tostring(componentType).."' in not one of the component types, nor a script asset, path or alias." )
            end
            Daneel.Debug.StackTrace.EndFunction()
            return
        end

        if params == nil then
            params = {}
        end
        component = gameObject:CreateScriptedBehavior( script, params )
        params = nil
    
    elseif Daneel.DefaultConfig().componentObjects[ componentType ] ~= nil then
        if componentType == "Transform" then
            if Daneel.Config.debug.enableDebug then
                print( errorHead.."Can't add a transform component because gameObjects may only have one transform." )
            end
            Daneel.Debug.StackTrace.EndFunction()
            return
        elseif componentType == "ScriptedBehavior" then
            if Daneel.Config.debug.enableDebug then
                print( errorHead.."To add a scripted behavior, pass the script asset, path or alias instead of 'ScriptedBehavior' as argument 'componentType'." )
            end
            Daneel.Debug.StackTrace.EndFunction()
            return
        end

        component = gameObject:CreateComponent( componentType )

        local defaultComponentParams = Daneel.Config[ string.lcfirst( componentType ) ]
        if defaultComponentParams ~= nil then
            params = table.merge( defaultComponentParams, params )
        end

    else
        local componentObject = table.getvalue( _G, componentType )

        if componentObject ~= nil and type( componentObject.New ) == "function" then
            component = componentObject.New( gameObject )
        else
            if Daneel.Config.debug.enableDebug then
                error( errorHead.."Custom component of type '"..componentType.."' does not provide a New() function; Can't create the component." )
            end
            Daneel.Debug.StackTrace.EndFunction()
            return
        end

        local object = table.getvalue( _G, string.split( componentType, "." )[1] ) -- leave the parenthesis
        if object ~= nil and object.Config ~= nil then
            local defaultComponentParams = object.Config[ string.lcfirst( componentType ) ]
            if defaultComponentParams ~= nil then
                params = table.merge( defaultComponentParams, params )
            end
        end
    end
    
    if params ~= nil and component ~= nil then
        component:Set( params )
    end

    Daneel.Event.Fire( gameObject, "OnNewComponent", component )
    Daneel.Debug.StackTrace.EndFunction()
    return component
end


----------------------------------------------------------------------------------
-- Get components

local OriginalGetComponent = GameObject.GetComponent
local OriginalGetScriptedBehavior = GameObject.GetScriptedBehavior

--- Get the first component of the provided type attached to the game object.
-- @param gameObject (GameObject) The game object.
-- @param componentType (string or Script) The component type, or script asset, path or alias.
-- @return (One of the component types) The component instance, or nil if none is found.
function GameObject.GetComponent( gameObject, componentType )
    Daneel.Debug.StackTrace.BeginFunction( "GameObject.GetComponent", gameObject, componentType )
    local errorHead = "GameObject.GetComponent( gameObject, componentType ) : "
    Daneel.Debug.CheckArgType( gameObject, "gameObject", "GameObject", errorHead )
    local argType = Daneel.Debug.CheckArgType( componentType, "componentType", {"string", "Script"}, errorHead )
    componentType = Daneel.Debug.CheckArgValue( componentType, "componentType", Daneel.Config.componentTypes, errorHead, componentType )
    
    local lcComponentType = componentType
    if argType == "string" then
        lcComponentType = string.lcfirst( componentType )
    end
    local component = gameObject[ lcComponentType ]
    
    if component == nil then
        if Daneel.DefaultConfig().componentObjects[ componentType ] ~= nil then
            component = OriginalGetComponent( gameObject, componentType )
        elseif Daneel.Config.componentObjects[ componentType ] == nil then -- not a custom component either
            local script = Asset.Get( componentType, "Script", true ) -- componentType is the script path or asset
            component = OriginalGetScriptedBehavior( gameObject, script )
        end
    end

    Daneel.Debug.StackTrace.EndFunction()
    return component
end

--- Get the provided scripted behavior instance attached to the game object.
-- @param gameObject (GameObject) The game object.
-- @param scriptNameOrAsset (string or Script) The script name or asset.
-- @return (ScriptedBehavior) The ScriptedBehavior instance.
function GameObject.GetScriptedBehavior( gameObject, scriptNameOrAsset )
    Daneel.Debug.StackTrace.BeginFunction( "GameObject.GetScriptedBehavior", gameObject, scriptNameOrAsset )
    local errorHead = "GameObject.GetScriptedBehavior( gameObject, scriptNameOrAsset ) : "
    Daneel.Debug.CheckArgType( gameObject, "gameObject", "GameObject", errorHead )
    Daneel.Debug.CheckArgType( scriptNameOrAsset, "scriptNameOrAsset", {"string", "Script"}, errorHead )

    local script = Asset.Get( scriptNameOrAsset, "Script", true )
    local component = OriginalGetScriptedBehavior( gameObject, script )
    Daneel.Debug.StackTrace.EndFunction()
    return component
end


----------------------------------------------------------------------------------
-- Destroy game object

--- Destroy the game object at the end of this frame.
-- @param gameObject (GameObject) The game object.
function GameObject.Destroy( gameObject )
    Daneel.Debug.StackTrace.BeginFunction( "GameObject.Destroy", gameObject )
    local errorHead = "GameObject.Destroy( gameObject ) : "
    Daneel.Debug.CheckArgType( gameObject, "gameObject", "GameObject", errorHead )

    for i, go in pairs( gameObject:GetChildren( true, true ) ) do -- recursive, include self
        go:RemoveTag()
    end

    for key, value in pairs( gameObject ) do
        if key ~= "inner" and type( value ) == "table" then -- in the Webplayer inner is a regular object, considered of type table and not userdata
            Daneel.Event.Fire( value, "OnDestroy", value )
        end
    end

    CraftStudio.Destroy( gameObject )
    Daneel.Debug.StackTrace.EndFunction()
end


----------------------------------------------------------------------------------
-- Tags

GameObject.Tags = {}
-- GameObject.Tags is emptied in Daneel:Awake()

--- Returns the game object(s) that have all the provided tag(s).
-- @param tag (string or table) One or several tag(s) (as a string or table of strings).
-- @return (table) The game object(s) (empty if none is found).
function GameObject.GetWithTag( tag )
    Daneel.Debug.StackTrace.BeginFunction( "GameObject.GetWithTag", tag )
    local errorHead = "GameObject.GetWithTag( tag ) : "
    local argType = Daneel.Debug.CheckArgType( tag, "tag", {"string", "table"}, errorHead )

    local tags = tag
    if argType == "string" then
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

    Daneel.Debug.StackTrace.EndFunction()
    return gameObjectsWithTag
end

--- Returns the tag(s) of the provided game object.
-- @param gameObject (GameObject) The game object.
-- @return (table) The tag(s) (empty if the game object has no tag).
function GameObject.GetTags( gameObject )
    Daneel.Debug.StackTrace.BeginFunction( "GameObject.GetTags", gameObject )
    local errorHead = "GameObject.GetTags( gameObject ) : "
    Daneel.Debug.CheckArgType( gameObject, "gameObject", "GameObject", errorHead )

    local tags = {}

    for tag, gameObjects in pairs( GameObject.Tags ) do
        if table.containsvalue( gameObjects, gameObject ) then
            table.insert( tags, tag )
        end
    end

    Daneel.Debug.StackTrace.EndFunction()
    return tags
end

--- Add the provided tag(s) to the provided game object.
-- @param gameObject (GameObject) The game object.
-- @param tag (string or table) One or several tag(s) (as a string or table of strings).
function GameObject.AddTag( gameObject, tag )
    Daneel.Debug.StackTrace.BeginFunction( "GameObject.AddTag", gameObject, tag )
    local errorHead = "GameObject.AddTag( gameObject, tag ) : "
    Daneel.Debug.CheckArgType( gameObject, "gameObject", "GameObject", errorHead )
    Daneel.Debug.CheckArgType( tag, "tag", {"string", "table"}, errorHead )
    
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

    Daneel.Debug.StackTrace.EndFunction()
end

--- Remove the provided tag(s) from the provided game object.
-- If the 'tag' argument is not provided, all tag of the game object will be removed.
-- @param gameObject (GameObject) The game object.
-- @param tag [optional] (string or table) One or several tag(s) (as a string or table of strings).
function GameObject.RemoveTag( gameObject, tag )
    Daneel.Debug.StackTrace.BeginFunction( "GameObject.RemoveTag", gameObject, tag )
    local errorHead = "GameObject.RemoveTag( gameObject[, tag] ) : "
    Daneel.Debug.CheckArgType( gameObject, "gameObject", "GameObject", errorHead )
    Daneel.Debug.CheckOptionalArgType( tag, "tag", {"string", "table"}, errorHead )
    
    local tags = tag
    if type( tags ) == "string" then
        tags = { tags }
    end

    for tag, gameObjects in pairs( GameObject.Tags ) do
        if tags == nil or table.containsvalue( tags, tag ) then
            table.removevalue( GameObject.Tags[ tag ], gameObject )
        end
    end
    Daneel.Debug.StackTrace.EndFunction()
end

--- Tell whether the provided game object has all (or at least one of) the provided tag(s).
-- @param gameObject (GameObject) The game object.
-- @param tag (string or table) One or several tag (as a string or table of strings).
-- @param atLeastOneTag [default=false] (boolean) If true, returns true if the game object has AT LEAST one of the tag (instead of ALL the tag).
-- @return (boolean) True
function GameObject.HasTag( gameObject, tag, atLeastOneTag )
    Daneel.Debug.StackTrace.BeginFunction( "GameObject.HasTag", gameObject, tag, atLeastOneTag )
    local errorHead = "GameObject.HasTag( gameObject, tag ) : "
    Daneel.Debug.CheckArgType( gameObject, "gameObject", "GameObject", errorHead )
    Daneel.Debug.CheckArgType( tag, "tag", {"string", "table"}, errorHead, {} )
    Daneel.Debug.CheckOptionalArgType( atLeastOneTag, "atLeastOneTag", "boolean", errorHead )

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

    Daneel.Debug.StackTrace.EndFunction()
    return hasTags
end


----------------------------------------------------------------------------------
-- Config, loading

-- Enables the dynamic accessors on the components
-- write the __tostring function
function Daneel.SetComponents( components )    
    for componentType, componentObject in pairs( components ) do
        Daneel.Utilities.AllowDynamicGettersAndSetters( componentObject, { Component } )

        if componentType ~= "ScriptedBehavior" then
            componentObject["__tostring"] = function( component )
                return componentType .. ": " .. component:GetId()
            end
        end
    end
end


-- Config - Loading
function Daneel.DefaultConfig()
    local config = {  
        debug = {
            enableDebug = false, -- Enable/disable Daneel's global debugging features (error reporting + stacktrace).
            enableStackTrace = false, -- Enable/disable the Stack Trace.
        },
       
        ----------------------------------------------------------------------------------
        
        -- List of the Scripts paths as values and optionally the script alias as the keys.
        -- Ie :
        -- "fully-qualified Script path"
        -- or
        -- alias = "fully-qualified Script path"
        --
        -- Setting a script path here allow you to  :
        -- * Use the dynamic getters and setters
        -- * Use component:Set() (for scripted behaviors)
        -- * Use component:GetId() (for scripted behaviors)
        -- * If you defined aliases, dynamically access the scripted behavior on the game object via its alias
        scriptPaths = {},

        -- Default CraftStudio's components settings (except Transform)
        -- textRenderer = { font = "MyFont" },

        hotKeys = {}, -- button names that throws events On[ButtonName]JustPressed... 
        -- filled in Daneel.Event.Listen

        objects = {
            GameObject = GameObject,
            Vector3 = Vector3,
            Quaternion = Quaternion,
            Plane = Plane,
            Ray = Ray,
            RaycastHit = RaycastHit,
        },

        componentObjects = {
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

        assetObjects = {
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
Daneel.SetComponents( Daneel.Config.componentObjects ) -- called here for the built-in components, is called another time after the modules and user config gets loaded

-- Assets
for assetType, assetObject in pairs( Daneel.Config.assetObjects ) do
    table.insert( Daneel.Config.assetTypes, assetType )
    Daneel.Utilities.AllowDynamicGettersAndSetters( assetObject, { Asset } )

    assetObject["__tostring"] = function( asset )
        return  assetType .. ": " .. Daneel.Cache.GetId( asset ) .. ": '" .. Map.GetPathInPackage( asset ) .. "'"
    end
end

Daneel.Config.componentTypes = table.getkeys( Daneel.Config.componentObjects ) -- put here so that table.getkeys() don't throw error because Daneel.Debug doesn't exists
Daneel.Config.assetTypes = table.getkeys( Daneel.Config.assetObjects )



-- load Daneel at the start of the game
function Daneel.Load()
    if Daneel.isLoaded then return end
    Daneel.isLoading = true

    -- load modules config
    for name, _module in pairs( CS.DaneelModules ) do
        if _module.isConfigLoaded ~= true then
            _module.isConfigLoaded = true

            if _module.Config == nil then
                _module.Config = {}
            end
            if type( _module.DefaultConfig ) == "function" then
                _module.Config = _module.DefaultConfig()
            end
            
            local userConfig = {}
            local functionName = name .. "UserConfig"
            if table.getvalue( _G, functionName ) ~= nil and type( _G[ functionName ] ) == "function" then
                _module.Config = table.deepmerge( _module.Config, _G[ functionName ]() )
            end

            if _module.Config.objects ~= nil then
                Daneel.Config.objects = table.merge( Daneel.Config.objects, _module.Config.objects )
            end

            if _module.Config.componentObjects ~= nil then
                Daneel.Config.componentObjects = table.merge( Daneel.Config.componentObjects, _module.Config.componentObjects )
                Daneel.Config.objects = table.merge( Daneel.Config.objects, _module.Config.componentObjects )
            end
        end
    end

    -- load Daneel config
    if table.getvalue( _G, "DaneelUserConfig" ) ~= nil and type( DaneelUserConfig ) == "function" then 
        Daneel.Config = table.deepmerge( Daneel.Config, DaneelUserConfig() ) -- use Daneel.Config here since some of its values may have been modified already by some momdules
    end
    
    Daneel.Config.objects = table.merge( Daneel.Config.objects, Daneel.Config.componentObjects, Daneel.Config.assetObjects )
    
    Daneel.SetComponents( Daneel.Config.componentObjects )
    Daneel.Config.componentTypes = table.getkeys( Daneel.Config.componentObjects )

    if Daneel.Config.debug.enableDebug and Daneel.Config.debug.enableStackTrace then
        Daneel.Debug.SetNewError()
    end

    -- ScriptAlias
    for alias, path in pairs( Daneel.Config.scriptPaths ) do
        local script = CraftStudio.FindAsset( path, "Script" )

        if script ~= nil then
            Daneel.Utilities.AllowDynamicGettersAndSetters( script, { Script, Component } )

            script["__tostring"] = function( scriptedBehavior )
                return "ScriptedBehavior: " .. Daneel.Cache.GetId( scriptedBehavior ) .. ": '" .. path .. "'"
            end
        else
            Daneel.Config.scriptPaths[ alias ] = nil
            if Daneel.Config.debug.enableDebug then
                print( "Daneel.Load() : item with key '" .. alias .. "' and value '" .. path .. "' in 'Daneel.Config.scriptPaths' ('DaneelUserConfig()'') is not a valid script path." )
            end
        end
    end

    Daneel.Debug.StackTrace.BeginFunction( "Daneel.Load" )

    -- Load modules 
    for i, _module in pairs( CS.DaneelModules ) do
        if _module.isLoaded ~= true then
            _module.isLoaded = true
            if type( _module.Load ) == "function" then
                _module.Load()
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
    for i, _module in pairs( CS.DaneelModules ) do
        if _module.doNotCallUpdate ~= true then
            if type( _module.Update ) == "function" and not table.containsvalue( Daneel.moduleUpdateFunctions, _module.Update ) then
                table.insert( Daneel.moduleUpdateFunctions, _module.Update )
            end
        end
    end

    Daneel.Debug.StackTrace.EndFunction()
end -- end Daneel.Load()

-- Called at runtime by code that needs Daneel to be loaded but it isn't yet.
function Daneel.LateLoad( source )
    if Daneel.isLateLoading or Daneel.isAwake then return end
    Daneel.isLateLoading = true
    
    print( "~~~~~~ Daneel Late Load ~~~~~~", source )
    local go = CS.CreateGameObject( "Daneel Late Load" )
    go:CreateScriptedBehavior( DaneelScriptAsset ) -- DaneelScriptAsset is set above, before Utilities.ButtonExists()
end


----------------------------------------------------------------------------------
-- Runtime
local luaDocStop = ""

function Behavior:Awake()
    if self.debugTry == true then
        CraftStudio.Destroy( self )
        self.testFunction()
        -- testFunction() may throw an error, kill the scripted behavior and not call the success callback
        -- but it won't kill the script that created the scripted behavior (the one that called Daneel.Debug.Try())
        self.successCallback()
        return
    end

    if tostring( self.gameObject.inner ) == "table" then
        CS.IsWebPlayer = true
    end

    if table.getvalue( _G, "LOAD_DANEEL" ) ~= nil and LOAD_DANEEL == false then
        return
    end
    
    if Daneel.isAwake then
        if Daneel.Config.debug.enableDebug then
            print( "Daneel:Awake() : You tried to load Daneel twice ! This time the 'Daneel' scripted behavior was on the " .. tostring( self.gameObject ) )
        end
        CS.Destroy( self )
        return
    end
    Daneel.isAwake = true
    Daneel.Event.Listen( "OnSceneLoad", function() Daneel.isAwake = false end )

    Daneel.Load()
    Daneel.Debug.StackTrace.messages = {}
    Daneel.Debug.StackTrace.BeginFunction( "Daneel.Awake" )
    

    -- remove all dead game objects from GameObject.Tags
    if Daneel.isLateLoading then
        -- can't do GameObject.Tags = {} because of Daneel late loading, it would discard alive game objects that are already added as tags
        for tag, gameObjects in pairs( GameObject.Tags ) do
            for i, gameObject in pairs( gameObjects ) do
                if gameObject.inner == nil then
                    gameObjects[i] = nil
                end
            end
            
            GameObject.Tags[ tag ] = table.reindex( gameObjects )
        end
    else
        GameObject.Tags = {}
    end


    -- Awake modules 
    for i, _module in pairs( CS.DaneelModules ) do
        if type( _module.Awake ) == "function" then
            _module.Awake()
        end
    end

    if Daneel.Config.debug.enableDebug then
        print("~~~~~ Daneel awake ~~~~~")
    end

    Daneel.Debug.StackTrace.EndFunction()
end 

function Behavior:Start()
    if self.debugTry then
        return
    end

    Daneel.Debug.StackTrace.BeginFunction( "Daneel.Start" )

    -- Start modules 
    for i, _module in pairs( CS.DaneelModules ) do
        if type( _module.Start ) == "function" then
            _module.Start()
        end
    end

    if Daneel.Config.debug.enableDebug then
        print("~~~~~ Daneel started ~~~~~")
    end

    Daneel.isLateLoading = nil
    Daneel.Debug.StackTrace.EndFunction()
end 

function Behavior:Update()
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

    -- HotKeys
    -- fire an event whenever a registered button is pressed
    for i, buttonName in pairs( Daneel.Config.hotKeys ) do
        if CraftStudio.Input.WasButtonJustPressed( buttonName ) then
            Daneel.Event.Fire( "On"..buttonName.."ButtonJustPressed" )
        end

        if CraftStudio.Input.IsButtonDown( buttonName ) then
            Daneel.Event.Fire( "On"..buttonName.."ButtonDown" )
        end

        if CraftStudio.Input.WasButtonJustReleased( buttonName ) then
            Daneel.Event.Fire( "On"..buttonName.."ButtonJustReleased" )
        end
    end

    -- Update modules 
    for i, func in pairs( Daneel.moduleUpdateFunctions ) do
        func()
    end
end
