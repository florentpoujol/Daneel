-- Lua.lua
-- Extends Lua's standard librairies.
--
-- Last modified for v1.2.0
-- Copyright © 2013 Florent POUJOL, published under the MIT licence.

Lua = {}

if CS.DaneelModules == nil then
    CS.DaneelModules = {}
end
CS.DaneelModules[ "Lua" ] = {}

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
    if Daneel.Cache.totable[s] ~= nil then
        return table.copy( Daneel.Cache.totable[s] )
        -- table.copy() is necessary to prevent string.ucfirst(), lcfirst() or any other function that uses the table returned by totable() to modify the table stored in the cache
    end
    Daneel.Debug.StackTrace.BeginFunction( "string.totable", s )
    Daneel.Debug.CheckArgType( s, "string", "string", "string.totable( string )" )

    local t = {}
    for i = 1, #s do
        table.insert( t, s:sub( i, i ) )
    end
    Daneel.Cache.totable[s] = table.copy( t )

    Daneel.Debug.StackTrace.EndFunction()
    return t
end

--- Tell whether the provided table contains the provided string. 
-- Alias of table.containsvalue().
-- @param s (string) The string.
-- @param t (table) The table containing the values to check against the string
-- @param ignoreCase [optional default=false] (boolean) Ignore the case.
-- @return (boolean) True if the string is found in the table, false otherwise.
function string.isoneof( s, t, ignoreCase )
    Daneel.Debug.StackTrace.BeginFunction("string.isoneof", s, t, ignoreCase )
    local errorHead = "string.isoneof( string, table[, ignoreCase] ) : "
    Daneel.Debug.CheckArgType( s, "string", "string", errorHead )
    Daneel.Debug.CheckArgType( t, "table", "table", errorHead )
    Daneel.Debug.CheckOptionalArgType( ignoreCase, "ignoreCase", "boolean", errorHead )

    local isOneOf = table.containsvalue( t, s, ignoreCase )
    Daneel.Debug.StackTrace.EndFunction()
    return isOneOf
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
-- If the string does not contain the delimiter, it returns a table containing only the whole string.
-- @param s (string) The string.
-- @param delimiter (string) The delimiter (may be several characters long).
-- @param trim [optional default=false] (boolean) Trim the chunks.
-- @return (table) The chunks.
function string.split( s, delimiter, trim )
    Daneel.Debug.StackTrace.BeginFunction( "string.split", s, delimiter, trim )
    local errorHead = "string.split( string, delimiter[, trim] ) : "
    Daneel.Debug.CheckArgType( s, "string", "string", errorHead )
    Daneel.Debug.CheckArgType( delimiter, "delimiter", "string", errorHead )
    Daneel.Debug.CheckOptionalArgType( trim, "trim", "boolean", errorHead )

    s = s .. delimier
    local fields = { s:match( 
        (s:gsub( "([^"..delimiter.."]*)"..delimiter, "(%1)"..delimiter ))
    ) }
    if trim then
        for i, s in pairs( fields ) do
            fields[ i ] = s:gsub( "^%s+", "" ):gsub( "%s+$", "" )
        end
    end
    Daneel.Debug.StackTrace.EndFunction()
    return chunks
end

--- Tell wether the provided string begins by the provided chunk or not.
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

--- Tell wether the provided string ends by the provided chunk or not.
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

--- Tell wether the provided string contains the provided chunk or not.
-- @param s (string) The string.
-- @param chunk (string) The searched chunk.
-- @return (boolean) True or false.
function string.contains( s, chunk )
    return ( s:find( chunk, 1, true ) ~= nil )
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
-- @param doNotCopyMetatable [optional default=false] (boolean) Tell wether to copy the provided table's metatable or not.
-- @return (table) The copied table.
function table.copy( t, doNotCopyMetatable )
    Daneel.Debug.StackTrace.BeginFunction( "table.copy", t, doNotCopyMetatable )
    local errorHead = "table.copy( table[, doNotCopyMetatable] ) :"
    Daneel.Debug.CheckArgType(t, "table", "table", errorHead )
    doNotCopyMetatable = Daneel.Debug.CheckOptionalArgType( doNotCopyMetatable, "doNotCopyMetatable", "boolean", errorHead, false )
    
    local newTable = {}
    for key, value in pairs( t ) do
        newTable[ key ] = value
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
-- @param p_value (any) The value to search for.
-- @param ignoreCase [optionnal default=false] (boolean) Ignore the case of the value. If true, the value must be of type 'string'.
-- @return (boolean) True if the value is found in the table, false otherwise.
function table.containsvalue(t, p_value, ignoreCase)
    Daneel.Debug.StackTrace.BeginFunction("table.constainsvalue", t, p_value, ignoreCase)
    local errorHead = "table.containsvalue(table, value) : "
    Daneel.Debug.CheckArgType(t, "table", "table", errorHead)
    
    if p_value == nil then
        error(errorHead.."Argument 'value' is nil.")
    end

    Daneel.Debug.CheckOptionalArgType(ignoreCase, "ignoreCase", "boolean", errorHead)
    
    if ignoreCase == true and type(p_value) ~= 'string' then
        Daneel.Debug.CheckArgType(p_value, "p_value", "string", errorHead)
    end
    
    local containsValue = false

    if ignoreCase then
        p_value = p_value:lower()
    end

    for key, value in pairs(t) do
        if ignoreCase then
            value = value:lower()
        end

        if p_value == value then
            containsValue = true
            break
        end
    end
    
    Daneel.Debug.StackTrace.EndFunction("table.containsvalue", containsValue)
    return containsValue
end

--- Returns the length of a table, which is the numbers of keys of the provided type (or of any type), for which the value is not nil.
-- @param t (table) The table.
-- @param keyType [optional] (string) Any Lua or CraftStudio type ('string', 'GameObject', ...).
-- @return (number) The table length.
function table.getlength( t, keyType )
    Daneel.Debug.StackTrace.BeginFunction( "table.getlength", t, keyType )
    local errorHead = "table.length( table[, keyType] ) : "
    Daneel.Debug.CheckArgType( t, "table", "table", errorHead )
    
    local length = 0
    if keyType ~= nil then
        keyType:lower()
    end
    for key, value in pairs( t ) do
        if keyType == nil then
            length = length + 1
        elseif Daneel.Debug.GetType( key ) == keyType then
            length = length + 1
        end
    end

    Daneel.Debug.StackTrace.EndFunction()
    return length
end
function table.length( t, keyType )
    return table.getlength( t, keyType )
end

--- Print all key/value pairs within the provided table.
-- @param t (table) The table to print.
function table.print(t)
    Daneel.Debug.StackTrace.BeginFunction("table.print", t)
    local errorHead = "table.print(table) : "

    if t == nil then
        print(errorHead.."Provided table is nil.")
        Daneel.Debug.StackTrace.EndFunction("table.print")
        return
    end

    Daneel.Debug.CheckArgType(t, "table", "table", errorHead)
    
    local tableString = tostring(t)
    local rawTableString = Daneel.Debug.ToRawString(t)
    if tableString ~= rawTableString then
        tableString = tableString.." / "..rawTableString
    end
    print("~~~~~ table.print("..tableString..") ~~~~~ Start ~~~~~")

    if table.length(t) == 0 then
        print("Provided table is empty.")
    else
        for key, value in pairs(t) do
            print(key, value)
        end
    end

    print("~~~~~ table.print("..tableString..") ~~~~~ End ~~~~~")

    Daneel.Debug.StackTrace.EndFunction("table.print")
end

--- Merge two or more tables into one. Integer keys are not overrided.
-- When several tables have the same value (with an integer key), the value is only added once in the returned table.
-- @param ... (table) At least two tables to merge together.
-- @return (table) The new table.
function table.merge(...)
    if arg == nil or #arg == 0 then
        Daneel.Debug.StackTrace.BeginFunction("table.merge")
        error("table.merge(...) : No argument provided. Need at least two.")
    end
    Daneel.Debug.StackTrace.BeginFunction("table.merge", unpack(arg))
    
    local fullTable = {}
    for i, t in ipairs(arg) do
        local argType = type(t)
        if argType == "table" then
            for key, value in pairs(t) do
                if math.isinteger(key) and not table.containsvalue(fullTable, value) then
                    table.insert(fullTable, value)
                else
                    fullTable[key] = value
                end
            end
        elseif Daneel.Config.debug.enableDebug then
            print("WARNING : table.merge(...) : Argument n°"..i.." is of type '"..argType.."' with value '"..tostring(t).."' instead of 'table'. The argument as been ignored.")
        end
    end
    Daneel.Debug.StackTrace.EndFunction("table.merge", fullTable)
    return fullTable
end

--- Deeply merge two or more tables into one. Integer keys are not overrided.
-- A deep merge means that the table values are also deeply merged.
-- When several tables have the same value (with an integer key), the value is only added once in the returned table.
-- @param ... (table) At least two tables to merge together.
-- @return (table) The new table.
function table.deepmerge(...)
    if arg == nil or #arg == 0 then
        Daneel.Debug.StackTrace.BeginFunction("table.deepmerge")
        error("table.deepmerge(...) : No argument provided. Need at least two.")
    end
    Daneel.Debug.StackTrace.BeginFunction("table.deepmerge", unpack(arg))
    
    local fullTable = {}
    for i, t in ipairs(arg) do
        local argType = type(t)
        if argType == "table" then
            
            for key, value in pairs(t) do
                if math.isinteger(key) and not table.containsvalue(fullTable, value) then
                    table.insert(fullTable, value)
                else
                    if fullTable[key] ~= nil and type(value) == "table" then
                        local mt = getmetatable(fullTable[key])
                        if mt ~= nil then -- consider the value an intance of an object, just replace the instance
                            fullTable[key] = value
                        else
                            fullTable[key] = table.deepmerge(fullTable[key], value)
                        end
                    else
                        fullTable[key] = value
                    end
                end
            end

        elseif Daneel.Config.debug.enableDebug then
            print("WARNING : table.deepmerge(...) : Argument n°"..i.." is of type '"..argType.."' with value '"..tostring(t).."' instead of 'table'. The argument as been ignored.")
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
-- @param returnFalseIfNotSameLength [optional default=false] (boolean) If true, the function returns false if the keys and values tables have different length.
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
-- Do not use this function on tables which have integer keys but that are not arrays (whose keys are not contiguous).
-- @param t (table) The table.
-- @param value (mixed) The value to remove.
-- @param maxRemoveCount (number) [optional] Maximum number of occurences of the value to be removed. If nil : remove all occurences.
-- @return (boolean) True if a value has been removed.
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

--- Get the key associated with the first occurence of the provided value.
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
-- @param orderBy [optional default="asc"] (string) How the sort should be made. Can be "asc" or "desc". Asc means small values first.
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
    
    t = table.new()
    for i, propertyValue in ipairs(propertyValues) do
        for j, _table in pairs(itemsByPropertyValue[propertyValue]) do
            table.insert(t, _table)
        end
    end
    
    Daneel.Debug.StackTrace.EndFunction()
    return t
end
