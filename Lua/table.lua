
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


-- Remove the specified value from the provided table
-- @param t (table) The table
-- @param values (mixed) The value to remove
-- @param singleRemove [optional default=false] (boolean) Tell wether to remove all occurences of the value(s) or just the first one
-- @return (table) The table
function table.removevalue(t, value, singleRemove)
    Daneel.StackTrace.BeginFunction("table.removevalue", t, values, singleRemove)
    local errorHead = "table.removevalue(t, value) : "
    
    Daneel.Debug.CheckArgType(t, "table", "table", errorHead)
    Daneel.Debug.CheckOptionalArgType(singleRemove, "singleRemove", "boolean", errorHead)
    
    if value == nil then
        return false
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

    Daneel.StackTrace.EndFunction("table.removevalue", t)
    return t
end






