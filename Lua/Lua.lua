

if Daneel == nil then
    -- wait for daneel
end

----------------------------------------------------------------------------------
-- table

-- Built-in table have no metatable
-- The new() function add the 'table' object as the metatable

-- Allow to use .length as a shortcut for the length method
-- @param t (table) The Table
-- @param key (string) The key
function table.__index(t, key) 
    if key == "length" then
        return table.length(t)
    end

    return rawget(table, key)
end

-- Allow to do table1 + table2, shortcut for table.join()
-- @param t1 (table) The left table
-- @param t2 (table) The right table
-- @return t (table) The new table
function table.__add(t1, t2)
    Daneel.StackTrace.BeginFunction("table.__add", t1, t2)
    local t = table.join(t1, t2)
    Daneel.StackTrace.EndFunction("table.__add", t)
    return t
end



-- Constructor for tables that allows to use the functions in the table table on the table copies.
-- @param ... [optionnal] (mixed) A single table, or 0 or more values to fill the new table with.
-- @return (table) The new table.
function table.new(...)
    local t = arg
    
    if t == nil then
        Daneel.StackTrace.BeginFunction("table.new", nil)
        t = setmetatable({}, table)
        Daneel.StackTrace.EndFunction("table.new", t)
        return t
    end

    Daneel.StackTrace.BeginFunction("table.new", unpack(arg))

    t.n = nil
    
    if arg[2] == nil and type(arg[1]) == "table" then -- the only argument is the table
        t = {}
        for key,value in pairs(arg[1]) do
            t[key] = value
        end
    end

    t = setmetatable(t, table)
    Daneel.StackTrace.EndFunction("table.new", t)
    return t
end

-- Return a copy of the provided table.
-- Dependent of table.new().
-- @param t (table) The table to copy.
function table.copy(t)
    Daneel.StackTrace.BeginFunction("table.copy", t)

    local argType = type(t)
    if argType ~= "table" then
        error("table.copy(table) : Argument 'table' is of type '"..argType.."' with value '"..tostring(t).."' instead of 'table'.")
    end

    t = table.new(t)
    Daneel.StackTrace.EndFunction("table.copy", t)
    return t
end

-- Tells wether the provided key is found within the provided table.
-- @param t (table) The table to search in.
-- @param key (string) The key to search for.
-- @return (boolean) True if the key is found in the table, false otherwise.
function table.containskey(t, p_key)
    Daneel.StackTrace.BeginFunction("table.containskey", t, p_key)
    local errorHead = "table.containskey(table, key) : "

    local argType = type(t)
    if argType ~= "table" then
        error(errorHead.."Argument 'table' is of type '"..argType.."' with value '"..tostring(t).."' instead of 'table'.")
    end
    
    argType = type(p_key)
    if argType ~= "string" then
        error(errorHead.."Argument 'key' is of type '"..argType.."' with value '"..tostring(p_key).."' instead of 'string'.")
    end
    
    local containsKey = false

    for key, value in pairs(t) do
        if p_key == key then
            containsKey = true
            break
        end
    end
    
    Daneel.StackTrace.EndFunction("table.containskey", containsKey)
    return containsKey
end

-- Tells wether the provided value is found within the provided table.
-- @param t (table) The table to search in.
-- @param value (any) The value to search for.
-- @param ignoreCase [optionnal default=false] (boolean) Ignore the case of the value. If true, the value must be of type 'string'.
-- @return (boolean) True if the value is found in the table, false otherwise.
function table.containsvalue(t, p_value, ignoreCase)
    Daneel.StackTrace.BeginFunction("table.constainsvalue", t, p_value, ignoreCase)
    local errorHead = "table.containsvalue(table, value) : "

    local argType = type(t)
    if argType ~= "table" then
        error(errorHead.."Argument 'table' is of type '"..argType.."' with value '"..tostring(t).."' instead of 'table'.")
    end
    
    if p_value == nil then
        error(errorHead.."Argument 'value' is nil.")
    end

    argType = type(ignoreCase)
    if ignoreCase ~= nil and argType ~= 'boolean' then
        error(errorHead.."Argument 'ignoreCase' is of type '"..argType.."' with value '"..tostring(ignoreCase).."' instead of 'booelan'.")
    end

    argType = type(p_value)
    if ignoreCase == true and argType ~= 'string' then
        error(errorHead.."Argument 'ignoreCase' is true but argument 'value' is of type '"..argType.."' with value '"..tostring(p_value).."' instead of 'string'.")
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
        end
    end
    
    Daneel.StackTrace.EndFunction("table.containsvalue", containsValue)
    return containsValue
end

-- Returns the length of a table, which is the numbers of keys for which the value is non-nil.
-- The keyType argument can be "all" (default to "all"), nil (same effect as "all") or any Lua type (as a string).
-- The function returns only count the number of keys of values for which the key has the specified.
-- Dependent of table.constainsvalue().
-- @param t (table) The table.
-- @param keyType [optionnal default="all"] (string) See function description.
-- @return (number) The table length.
function table.length(t, keyType)
    Daneel.StackTrace.BeginFunction("table.length", t, keyType)
    local errorHead = "table.length(table, keyType) : "

    local argType = type(t)
    if argType ~= 'table' then
        error(errorHead.."Argument 'table' is of type '"..argType.."' with value '"..tostring(t).."' instead of 'table'.")
    end
        
    if keyType == nil then
        keyType = "all"
    elseif not table.containsvalue({"number", "string", "boolean", "table", "function", "userdata", "thread"}, keyType) then
        error(errorHead.."Argument 'keyType' as an unautorized value '"..tostring(keyType).."'. Must be one of the seven Lua data types, 'all', or nil.")
    end
    
    local length = 0
    
    for key, value in pairs(t) do
        if keyType == "all" then
            length = length + 1
        elseif type(key) == keyType then
            length = length + 1
        end
    end

    Daneel.StackTrace.EndFunction("table.length", length)
    return length
end

-- Print all key/value pairs within the provided table.
-- Dependent of table.length().
-- @param t (table) The table.
function table.print(t)
    Daneel.StackTrace.BeginFunction("table.print", t)
    local errorHead = "table.print(table) : "

    if t == nil then
        print(errorHead.."Provided table is nil")
        Daneel.StackTrace.EndFunction("table.print")
        return
    end

    local argType = type(t)
    if argType ~= 'table' then
        error(errorHead.."Argument 'table' is of type '"..argType.."' with value '"..tostring(t).."' instead of 'table'.")
    end
    
    if table.length(t) == 0 then
        print(errorHead.."Provided table is empty.")
        Daneel.StackTrace.EndFunction("table.print")
        return
    end

    print("~~~~~ table.print() ~~~~~ Start ~~~~~")
    print("Table : "..tostring(t))
    print("Metatable : "..tostring(getmetatable(t)))
    print("~~~~~")

    for key, value in pairs(t) do
        print(key, value)
    end

    print("~~~~~ table.print() ~~~~~ End ~~~~~")

    Daneel.StackTrace.EndFunction("table.print")
end

-- Print the metatable of the provided table.
-- Dependent of table.length().
-- @param t (table) The table.
function table.printmetatable(t)
    Daneel.StackTrace.BeginFunction("table.printmetatable", t)
    errorHead = "table.printmetatable(table) : "

    if t == nil then
        print(errorHead.."Provided table is nil")
        Daneel.StackTrace.EndFunction("table.printmetatable")
        return
    end

    local argType = type(t)
    if argType ~= 'table' then
        error(errorHead.."Argument 'table' is of type '"..argType.."' with value '"..tostring(t).."' instead of 'table'.")
    end
    
    local mt = getmetatable(t)
    if mt == nil then
        print(errorHead.."Provided table has no metatable attached.")
        Daneel.StackTrace.EndFunction("table.printmetatable")
        return
    end

    if table.length(mt) == 0 then
        print(errorHead.."The metatable of the provided table is empty.")
        Daneel.StackTrace.EndFunction("table.printmetatable")
        return
    end
   
    print("~~~~~ table.printmetatable() ~~~~~ Start ~~~~~")
    print("Table : "..tostring(t))
    print("Metatable : "..tostring(mt))
    print("Metatable of Metatable : "..tostring(getmetatable(mt)))
    print("~~~~~")

    for key, value in pairs(mt) do
        print(key, value)
    end

    print("~~~~~ table.printmetatable() ~~~~~ End ~~~~~")

    Daneel.StackTrace.EndFunction("table.printmetatable")
end

-- Join two or more tables into one.
-- Integer keys are not overrided.
-- Dependent of math.isinterger().
-- @param ... (table) At least two tables to join together. Non-table arguments are ignored.
-- @return (table) The new table.
function table.join(...)
    if arg == nil then
        Daneel.StackTrace.BeginFunction("table.join", nil)
        error("table.join(...) : No argument provided. Need at least two.")
    end

    Daneel.StackTrace.BeginFunction("table.join", unpack(arg))
    
    local fullTable = table.new()
    
    for i, t in ipairs(arg) do
        if type(t) == "table" then
            for key, value in pairs(t) do
                if math.isinteger(key) then
                    table.insert(fullTable, value)
                else
                    fullTable[key] = value
                end
            end
        end
    end
    
    Daneel.StackTrace.EndFunction("table.join", fullTable)
    return fullTable
end

-- Compare table1 and table2. Returns true if they have the exact same keys which have the exact same values.
-- Dependant of table.length().
-- @param table1 (table) The first table to compare.
-- @param table2 (table) The second table to compare to the first table.
-- @return (boolean) True if the two table have the same content.
function table.compare(table1, table2)
    Daneel.StackTrace.BeginFunction("table.compare", table1, table2)
    local errorHead = "table.compare(table1, table2) : "
    
    local argType = type(table1)
    if argType ~= "table" then
        error(errorHead.."Argument 'table1' is of type '"..argType.."' with value '"..tostring(table1).."' instead of 'table'.")
    end

    argType = type(table2)
    if argType ~= "table" then
        error(errorHead.."Argument 'table2' is of type '"..argType.."' with value '"..tostring(table2).."' instead of 'table'.")
    end

    local areEqual = true

    if table.length(table1) ~= table.length(table2) then
        Daneel.StackTrace.EndFunction("table.compare", false)
        return false
    end

    for key, value in pairs(table1) do
        if table1[key] ~= table2[key] then
            areEqual = false
            break
        end
    end
    
    Daneel.StackTrace.EndFunction("table.compare", areEqual)
    return areEqual
end

-- Create an associative table for the provided keys and values table
-- @param keys (table) The keys of the future table
-- @param values (table) The values of the future table
-- @param strict [optional default=false] (boolean) If true, the function returns false if the keys and values table have different length
-- @return (table or boolean) The combined table or false if the table have different length
function table.combine(keys, values, strict)
    Daneel.StackTrace.BeginFunction("table.combine", keys, values, strict)
    local errorHead = "table.combine(keys, values[, strict]) : "
    
    local argType = type(keys)
    if argType ~= "table" then
        error(errorHead.."Argument 'keys' is of type '"..argType.."' with value '"..tostring(keys).."' instead of 'table'.")
    end

    argType = type(values)
    if argType ~= "table" then
        error(errorHead.."Argument 'values' is of type '"..argType.."' with value '"..tostring(values).."' instead of 'table'.")
    end

    if table.length(keys) ~= table.length(values) then
        print(errorHead.."Arguments 'keys' and 'values' have different length.")

        if strict == true then
            Daneel.StackTrace.EndFunction("table.combine", false)
            return false
        end
    end

    local newTable = table.new()

    for i, key in ipairs(keys) do
        newTable[key] = values[i]
    end

    Daneel.StackTrace.EndFunction("table.compare", newTable)
    return newTable
end



----------------------------------------------------------------------------------
-- string


local stringMetatable = getmetatable("") -- the 'string' class is origininally stringMetatable.__index

-- Allow to build a string by repeating sevral times a strring segment
-- @param s (string) The string
-- @param num (number) The multiplier
-- @return (string) The new string
function stringMetatable.__mul(s, multiplier)
    local errorHead = "[metatable of strings].__mul(string, multiplier) : "

    local argType = type(s)
    if argType ~= "string" then
        error(errorHead.."Argument 'string' is of type '"..argType.."' with value '"..tostring(s).."' instead of 'string'.")
    end

    argType = type(multiplier)
    if argType ~= "number" then
        error(errorHead.."Argument 'multiplier' is of type '"..argType.."' with value '"..tostring(multiplier).."' instead of 'number'.")
    end

    local fullString = ""

    for i=1, multiplier do
        fullString = fullString .. s
    end

    return fullString
end

-- Turn a string into a table, one character per index
-- @param s (string) The string
-- @return (table) The table
function string.totable(s)
    Daneel.StackTrace.BeginFunction("string.totable", s)

    local argType = type(s)
    if argType ~= "string" then
        error("string.totable(string) : Argument 'string' is of type '"..argType.."' with value '"..tostring(s).."' instead of 'string'.")
    end

    local strLen = s:len()
    local t = table.new()

    for i = 1, strLen do
        table.insert(t, s:sub(i, i))
    end 

    Daneel.StackTrace.EndFunction("string.totable", t)
    return t
end

-- Alias of table.containsvalue().
-- Tell wether the specified table contains the specified string. 
-- @param s (string) The string
-- @param t (table) The table conataining the values to check against argument 'string'.
-- @param ignoreCase [optional=false] (boolean) Ignore the case
-- @return (boolean) True if 's' is found in 't', false otherwise
function string.isOneOf(s, t, ignoreCase)
    Daneel.StackTrace.BeginFunction("string.isOneOf", s, t, ignoreCase)
    local errorHead = "string.isOneOf(string, table[, ignoreCase]) : "

    local argType = type(s)
    if argType ~= "string" then
        error(errorHead.."Argument 'string' is of type '"..argType.."' with value '"..tostring(s).."' instead of 'string'.")
    end

    argType = type(t)
    if argType ~= "table" then
        error(errorHead.."Argument 'table' is of type '"..argType.."' with value '"..tostring(s).."' instead of 'table'.")
    end

    argType = type(ignoreCase)
    if argType ~= nil and argType ~= "boolean" then
        error(errorHead.."Argument 'string' is of type '"..argType.."' with value '"..tostring(s).."' instead of 'boolean'.")
    end

    local isOneOf = table.constainsvalue(t, s, ignoreCase)
    Daneel.StackTrace.EndFunction("string.isOneOf", isOneOf)
    return isOneOf
end

-- Make the first letter uppercase
-- @param s (string) The string
-- @return (string) The string
function string.ucfirst(s)
    Daneel.StackTrace.BeginFunction("string.ucfirst", s)
    local errorHead = "string.ucfirst(string) : "

    local argType = type(s)
    if argType ~= "string" then
        error(errorHead.."Argument 'string' is of type '"..argType.."' with value '"..tostring(s).."' instead of 'string'.")
    end

    t = s:totable()
    t[1] = t[1]:upper()
    s = t:concat()

    Daneel.StackTrace.EndFunction("string.ucfirst", s)
    return s
end




----------------------------------------------------------------------------------
-- math

-- Tell wether the provided number is an integer.
-- @param number The number to check.
-- @param strict [optionnal default=false] (boolean) If true, the function returns an error when the 'number' argument is not a number.
function math.isinteger(number, strict)
    Daneel.StackTrace.BeginFunction("math.isinteger", number, strict)
    
    local argType = type(number)
    if argType ~= "number" then
        if strict ~= nil and strict == true then
            error("math.isinterger(number[, strict]) : Argument 'number' is of type '"..argType.."' instead of 'number'.")
        else
            Daneel.StackTrace.EndFunction("math.isinteger", false)
            return false
        end
    end

    local isinteger = number == math.floor(number)
    Daneel.StackTrace.EndFunction("math.isinteger", isinteger)
    return isinteger
end
-- used in table.join()
