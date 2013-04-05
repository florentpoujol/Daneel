
----------------------------------------------------------------------------------
-- math

--- Tell whether the provided number is an integer.
-- @param number (number) The number to check.
-- @param errorIfValueIsNotNumber [optionnal default=false] (boolean) If true, the function returns an error when the 'number' argument is not a number.
function math.isinteger(number, errorIfValueIsNotNumber)
    Daneel.Debug.StackTrace.BeginFunction("math.isinteger", number, errorIfValueIsNotNumber)
    
    local argType = type(number)
    if argType ~= "number" then
        if errorIfValueIsNotNumber ~= nil and errorIfValueIsNotNumber == true then
            error("math.isinterger(number[, errorIfValueIsNotNumber]) : Argument 'number' is of type '"..argType.."' instead of 'number'.")
        else
            Daneel.Debug.StackTrace.EndFunction("math.isinteger", false)
            return false
        end
    end

    local isinteger = number == math.floor(number)
    Daneel.Debug.StackTrace.EndFunction("math.isinteger", isinteger)
    return isinteger
end


----------------------------------------------------------------------------------
-- string

--- Turn a string into a table, one character per index.
-- @param s (string) The string
-- @return (table) The table
function string.totable(s)
    Daneel.Debug.StackTrace.BeginFunction("string.totable", s)
    Daneel.Debug.CheckArgType(s, "string", "string", errorHead)
    local strLen = s:len()
    local t = table.new()
    for i = 1, strLen do
        table.insert(t, s:sub(i, i))
    end 
    Daneel.Debug.StackTrace.EndFunction("string.totable", t)
    return t
end

--- Tell whether the provided table contains the provided string. 
-- Alias of table.containsvalue().
-- @param s (string) The string.
-- @param t (table) The table containing the values to check against the string
-- @param ignoreCase [optional default=false] (boolean) Ignore the case.
-- @return (boolean) True if the string is found in the table, false otherwise.
function string.isoneof(s, t, ignoreCase)
    Daneel.Debug.StackTrace.BeginFunction("string.isoneof", s, t, ignoreCase)
    local errorHead = "string.isoneof(string, table[, ignoreCase]) : "
    Daneel.Debug.CheckArgType(s, "string", "string", errorHead)
    Daneel.Debug.CheckArgType(t, "table", "table", errorHead)
    Daneel.Debug.CheckOptionalArgType(ignoreCase, "ignoreCase", "boolean", errorHead)
    local isOneOf = table.containsvalue(t, s, ignoreCase)
    Daneel.Debug.StackTrace.EndFunction("string.isoneof", isOneOf)
    return isOneOf
end

--- Turn the first letter uppercase.
-- @param s (string) The string.
-- @return (string) The string.
function string.ucfirst(s)
    Daneel.Debug.StackTrace.BeginFunction("string.ucfirst", s)
    local errorHead = "string.ucfirst(string) : "
    Daneel.Debug.CheckArgType(s, "string", "string", errorHead)
    t = s:totable()
    t[1] = t[1]:upper()
    s = t:concat()
    Daneel.Debug.StackTrace.EndFunction("string.ucfirst", s)
    return s
end

--- Split the provided string in several chunks, using the provided delimiter.
-- If the string does not contain the delimiter, it returns a table containing only the whole string.
-- @param s (string) The string.
-- @param delimiter (string) The delimiter (must be a single character long).
-- @return (table) The chunks.
function string.split(s, delimiter)
    Daneel.Debug.StackTrace.BeginFunction("string.split", s, delimiter)
    local errorHead = "string.split(string, delimiter) : "
    Daneel.Debug.CheckArgType(s, "string", "string", errorHead)
    Daneel.Debug.CheckArgType(delimiter, "delimiter", "string", errorHead)
    local chunks = {}
    if s:find(delimiter) == nil then
        chunks = {s}
    else
        local chunk = ""
        s = s:totable()
        for i, char in ipairs(s) do
            if char == delimiter then
                table.insert(chunks, chunk)
                chunk = ""
            else
                chunk = chunk..char
            end
        end
        if #chunk > 0 then
            table.insert(chunks, chunk)
        end
    end
    Daneel.Debug.StackTrace.EndFunction()
    return chunks
end


----------------------------------------------------------------------------------
-- table

table.__index = table

--- Constructor for dynamic tables that allow to use the functions in the table library on the table copies (like what you can do with the strings).
-- @param t [optional] (table) A table.
-- @return (table) The new table.
function table.new(t)
    Daneel.Debug.StackTrace.BeginFunction("table.new", t)
    local newTable = t
    if newTable == nil then
        newTable = {}
    else
        Daneel.Debug.CheckArgType(t, "table", "table", "table.new([table]) : ")
    end

    newTable = setmetatable(newTable, table)
    Daneel.Debug.StackTrace.EndFunction("table.new", newTable)
    return newTable
end

--- Return a copy of the provided table.
-- @param t (table) The table to copy.
function table.copy(t)
    Daneel.Debug.StackTrace.BeginFunction("table.copy", t)
    Daneel.Debug.CheckArgType(t, "table", "table", "table.copy(table) : ", nil, true)
    
    local newTable = table.new()
    for key, value in pairs(t) do
        newTable[key] = value
    end

    local mt = getmetatable(t)
    if mt ~= nil then
        setmetatable(newTable, mt)
    end

    new.Debug.StackTrace.EndFunction("table.copy", newTable)
    return newTable
end

--- Tell whether the provided key is found within the provided table.
-- @param t (table) The table to search in.
-- @param p_key (mixed) The key to search for.
-- @return (boolean) True if the key is found in the table, false otherwise.
function table.containskey(t, p_key)
    Daneel.Debug.StackTrace.BeginFunction("table.containskey", t, p_key)
    local errorHead = "table.containskey(table, key) : "
    Daneel.Debug.CheckArgType(t, "table", "table", errorHead)
    
    if p_key == nil then
        error(errorHead.."Argument 'p_key' is 'nil'.")
    end
    
    local containsKey = false

    for key, value in pairs(t) do
        if p_key == key then
            containsKey = true
            break
        end
    end
    Daneel.Debug.StackTrace.EndFunction("table.containskey", containsKey)
    return containsKey
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
function table.length(t, keyType)
    Daneel.Debug.StackTrace.BeginFunction("table.length", t, keyType)
    local errorHead = "table.length(table, keyType) : "
    Daneel.Debug.CheckArgType(t, "table", "table", errorHead)
    
    local length = 0
    
    for key, value in pairs(t) do
        if keyType == nil then
            length = length + 1
        elseif Daneel.Debug.GetType(key) == keyType then
            length = length + 1
        end
    end

    Daneel.Debug.StackTrace.EndFunction("table.length", length)
    return length
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

--- Print the metatable of the provided table.
-- @param t (table) The table who has a metatable to print.
function table.printmetatable(t)
    Daneel.Debug.StackTrace.BeginFunction("table.printmetatable", t)
    errorHead = "table.printmetatable(table) : "

    if t == nil then
        print(errorHead.."Provided table is nil.")
        Daneel.Debug.StackTrace.EndFunction("table.printmetatable")
        return
    end

    Daneel.Debug.CheckArgType(t, "table", "table", errorHead)
    
    local mt = getmetatable(t)
    if mt == nil then
        print(errorHead.."Provided table '"..tostring(t).."' has no metatable attached.")
        Daneel.Debug.StackTrace.EndFunction("table.printmetatable")
        return
    end
    
    local tableString = tostring(mt)
    local rawTableString = Daneel.Debug.ToRawString(mt)
    if tableString ~= rawTableString then
        tableString = tableString.." / "..rawTableString
    end
    print("~~~~~ table.printmetatable("..tableString..") ~~~~~ Start ~~~~~")

    if table.length(t) == 0 then
        print("The metatable is empty.")
    else
        for key, value in pairs(t) do
            print(key, value)
        end
    end

    print("~~~~~ table.printmetatable("..tableString..") ~~~~~ End ~~~~~")

    Daneel.Debug.StackTrace.EndFunction("table.printmetatable")
end

--- Merge two or more tables into one. Integer keys are not overrided.
-- @param ... (table) At least two tables to merge together. Arguments that are not of type 'table' are ignored.
-- @return (table) The new table.
function table.merge(...)
    if arg == nil then
        Daneel.Debug.StackTrace.BeginFunction("table.merge")
        error("table.merge(...) : No argument provided. Need at least two.")
    end

    Daneel.Debug.StackTrace.BeginFunction("table.merge", unpack(arg))
    
    local fullTable = table.new()
    
    for i, t in ipairs(arg) do
        local argType = type(t)
        if argType == "table" then
            for key, value in pairs(t) do
                if math.isinteger(key) then
                    table.insert(fullTable, value)
                else
                    fullTable[key] = value
                end
            end
        else
            print("table.merge(...) : WARNING : Argument n°"..i.." is of type '"..argType.."' with value '"..tostring(t).."' instead of 'table'. The argument as been ignored.")
        end
    end
    
    Daneel.Debug.StackTrace.EndFunction("table.merge", fullTable)
    return fullTable
end

--- Compare table1 and table2. Returns true if they have the exact same keys which have the exact same values.
-- @param table1 (table) The first table to compare.
-- @param table2 (table) The second table to compare to the first table.
-- @return (boolean) True if the two tables have the exact same content.
function table.compare(table1, table2)
    Daneel.Debug.StackTrace.BeginFunction("table.compare", table1, table2)
    local errorHead = "table.compare(table1, table2) : "
    Daneel.Debug.CheckArgType(table1, "table1", "table", errorHead)
    Daneel.Debug.CheckArgType(table2, "table2", "table", errorHead)

    local areEqual = true

    if table.length(table1) ~= table.length(table2) then
        Daneel.Debug.StackTrace.EndFunction("table.compare", false)
        return false
    end

    for key, value in pairs(table1) do
        if table1[key] ~= table2[key] then
            areEqual = false
            break
        end
    end
    
    Daneel.Debug.StackTrace.EndFunction("table.compare", areEqual)
    return areEqual
end

--- Create an associative table with the provided keys and values tables.
-- @param keys (table) The keys of the future table.
-- @param values (table) The values of the future table.
-- @param returnFalseIfNotSameLength [optional default=false] (boolean) If true, the function returns false if the keys and values tables have different length.
-- @return (table or boolean) The combined table or false if the tables have different length.
function table.combine(keys, values, returnFalseIfNotSameLength)
    Daneel.Debug.StackTrace.BeginFunction("table.combine", keys, values, returnFalseIfNotSameLength)
    local errorHead = "table.combine(keys, values[, returnFalseIfNotSameLength]) : "
    Daneel.Debug.CheckArgType(keys, "keys", "table", errorHead)
    Daneel.Debug.CheckArgType(values, "values", "table", errorHead)
    Daneel.Debug.CheckOptionalArgType(returnFalseIfNotSameLength, "returnFalseIfNotSameLength", "boolean", errorHead)

    if table.length(keys) ~= table.length(values) then
        print(errorHead.."WARNING : Arguments 'keys' and 'values' have different length.")

        if returnFalseIfNotSameLength == true then
            Daneel.Debug.StackTrace.EndFunction("table.combine", false)
            return false
        end
    end

    local newTable = table.new()

    for i, key in ipairs(keys) do
        newTable[key] = values[i]
    end

    Daneel.Debug.StackTrace.EndFunction("table.compare", newTable)
    return newTable
end

--- Remove the provided value from the provided table.
-- If the index of the value is an integer, the value is nicely removed with table.remove().
-- @param t (table) The table.
-- @param value (mixed) The value to remove.
-- @param singleRemove [optional default=false] (boolean) Tell whether to remove all occurences of the value or just the first one.
-- @return (table) The table.
function table.removevalue(t, value, singleRemove)
    Daneel.Debug.StackTrace.BeginFunction("table.removevalue", t, value, singleRemove)
    local errorHead = "table.removevalue(table, value[, singleRemove]) : "
    Daneel.Debug.CheckArgType(t, "table", "table", errorHead)
    Daneel.Debug.CheckOptionalArgType(singleRemove, "singleRemove", "boolean", errorHead)
    
    if value == nil then
        error(errorHead.."Argument 'value' is nil.")
    end

    for key, _value in pairs(t) do
        if _value == value then
            if math.isinteger(key) then
                table.remove(t, key)
            else
                t[key] = nil
            end

            if singleRemove == true then
                break
            end
        end
    end

    Daneel.Debug.StackTrace.EndFunction("table.removevalue", t)
    return t
end

--- Return all the keys of the provided table.
-- @param t (table) The table.
-- @return (table) The keys.
function table.getkeys(t)
    Daneel.Debug.StackTrace.BeginFunction("table.getkeys", t)
    local errorHead = "table.getkeys(table) : "
    Daneel.Debug.CheckArgType(t, "table", "table", errorHead)

    local keys = table.new()
    for key, value in pairs(t) do
        keys:insert(key)
    end

    Daneel.Debug.StackTrace.EndFunction("table.getkeys", keys)
    return keys
end

--- Return all the values of the provided table.
-- @param t (table) The table.
-- @return (table) The values.
function table.getvalues(t)
    Daneel.Debug.StackTrace.BeginFunction("table.getvalues", t)
    local errorHead = "table.getvalues(t) : "
    Daneel.Debug.CheckArgType(t, "table", "table", errorHead)

    local values = table.new()
    for key, value in pairs(t) do
        values:insert(value)
    end

    Daneel.Debug.StackTrace.EndFunction("table.getvalues", values)
    return values
end

--- Get the key associated with the first occurence of the provided value.
-- @param t (table) The table.
-- @param value (mixed) The value.
function table.getkey(t, value)
    Daneel.Debug.StackTrace.BeginFunction("table.getkey", t, value)
    local errorHead = "table.getkey(table, value) : "
    Daneel.Debug.CheckArgType(t, "table", "table", errorHead)

    if value == nil then
        error(errorHead.."Argument 'value' is nil.")
    end

    local key = nil
    for k, v in pairs(t) do
        if value == v then
            key = k
        end
    end

    Daneel.Debug.StackTrace.EndFunction("table.getkey", key)
    return key
end

