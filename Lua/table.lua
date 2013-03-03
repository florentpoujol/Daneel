
-- Built-in table have no metatable
-- The table.new() function add the 'table' object as the metatable

-- Allow to use .length as a shortcut for the length method
-- @param t (table) The Table
-- @param key (string) The key
function table.__index(t, key) 
    if key == "length" then
        return table.length(t)
    end

    return rawget(table, key)
end

-- Allow to do table1 + table2, shortcut for table.merge()
-- @param t1 (table) The left table
-- @param t2 (table) The right table
-- @return t (table) The new table
function table.__add(t1, t2)
    Daneel.StackTrace.BeginFunction("table.__add", t1, t2)
    local t = table.merge(t1, t2)
    Daneel.StackTrace.EndFunction("table.__add", t)
    return t
end

-- Constructor for dynamic tables that allow to use the functions in the table library on the table copies.
-- @param ... [optional] (mixed) A single table, or 0 or more values to fill the new table with.
-- @return (table) The new table.
function table.new(...)
    local t = arg
    
    if t == nil then
        Daneel.StackTrace.BeginFunction("table.new")
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
    Daneel.Debug.CheckArgType(t, "t", "table", "table.copy(table) : ")

    t = table.new(t)
    Daneel.StackTrace.EndFunction("table.copy", t)
    return t
end

-- Tells wether the provided key is found within the provided table.
-- @param t (table) The table to search in.
-- @param key (mixed) The key to search for.
-- @return (boolean) True if the key is found in the table, false otherwise.
function table.containskey(t, p_key)
    Daneel.StackTrace.BeginFunction("table.containskey", t, p_key)
    local errorHead = "table.containskey(table, key) : "
    Daneel.Debug.CheckArgType(t, "t", "table", errorHead)
    
    if p_key == nil then
        daneelerror(errorHead.."Argument 'p_key' is 'nil'.")
    end
    
    local containsKey = false

    for key, value in pairs(t)
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
    Daneel.Debug.CheckArgType(t, "t", "table", errorHead)
    
    if p_value == nil then
        daneelerror(errorHead.."Argument 'value' is nil.")
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
    
    Daneel.StackTrace.EndFunction("table.containsvalue", containsValue)
    return containsValue
end

-- Returns the length of a table, which is the numbers of keys of the specified type (or of any type), for which the value is non-nil.
-- @param t (table) The table.
-- @param keyType [optional] (string) Any Lua or CraftStudio type.
-- @return (number) The table length.
function table.length(t, keyType)
    Daneel.StackTrace.BeginFunction("table.length", t, keyType)
    local errorHead = "table.length(table, keyType) : "
    Daneel.Debug.CheckArgType(t, "t", "table", errorHead)
    
    local length = 0
    
    for key, value in pairs(t) do
        if keyType == nil then
            length = length + 1
        elseif Daneel.Debug.GetType(key) == keyType then
            length = length + 1
        end
    end

    Daneel.StackTrace.EndFunction("table.length", length)
    return length
end

-- Print all key/value pairs within the provided table.
-- @param t (table) The table.
function table.print(t)
    Daneel.StackTrace.BeginFunction("table.print", t)
    local errorHead = "table.print(table) : "

    if t == nil then
        print(errorHead.."Provided table is nil.")
        Daneel.StackTrace.EndFunction("table.print")
        return
    end

    Daneel.Debug.CheckArgType(t, "t", "table", errorHead)
    
    print("~~~~~ table.print() ~~~~~ Start ~~~~~")
    print("Table : "..tostring(t))
    print("~~~~~")

    if table.length(t) == 0 then
        print("Provided table is empty.")
    else
        for key, value in pairs(t) do
            print(key, value)
        end
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
        print(errorHead.."Provided table is nil.")
        Daneel.StackTrace.EndFunction("table.printmetatable")
        return
    end

    Daneel.Debug.CheckArgType(t, "t", "table", errorHead)
    
    local mt = getmetatable(t)
    if mt == nil then
        print(errorHead.."Provided table '"..tostring(t).."' has no metatable attached.")
        Daneel.StackTrace.EndFunction("table.printmetatable")
        return
    end

    if table.length(mt) == 0 then
        print(errorHead.."The metatable of the provided table is empty.")
        Daneel.StackTrace.EndFunction("table.printmetatable")
        return
    end
   
    print("~~~~~ table.printmetatable() ~~~~~ Start ~~~~~")
    print("Metatable : "..tostring(mt))
    print("~~~~~")

    if table.length(t) == 0 then
        print("The metatable is empty.")
    else
        for key, value in pairs(mt) do
            print(key, value)
        end
    end

    print("~~~~~ table.printmetatable() ~~~~~ End ~~~~~")

    Daneel.StackTrace.EndFunction("table.printmetatable")
end

-- Merge two or more tables into one. Integer keys are not overrided.
-- @param ... (table) At least two tables to merge together. Non-table arguments are ignored.
-- @return (table) The new table.
function table.merge(...)
    if arg == nil then
        Daneel.StackTrace.BeginFunction("table.merge")
        daneelerror("table.merge(...) : No argument provided. Need at least two.")
    end

    Daneel.StackTrace.BeginFunction("table.merge", unpack(arg))
    
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
    
    Daneel.StackTrace.EndFunction("table.merge", fullTable)
    return fullTable
end

-- Compare table1 and table2. Returns true if they have the exact same keys which have the exact same values.
-- @param table1 (table) The first table to compare.
-- @param table2 (table) The second table to compare to the first table.
-- @return (boolean) True if the two table have the same content.
function table.compare(table1, table2)
    Daneel.StackTrace.BeginFunction("table.compare", table1, table2)
    local errorHead = "table.compare(table1, table2) : "
    Daneel.Debug.CheckArgType(table1, "table1", "table", errorHead)
    Daneel.Debug.CheckArgType(table2, "table2", "table", errorHead)

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

-- Create an associative table with the provided keys and values table
-- @param keys (table) The keys of the future table
-- @param values (table) The values of the future table
-- @param strict [optional default=false] (boolean) If true, the function returns false if the keys and values table have different length
-- @return (table or boolean) The combined table or false if the table have different length
function table.combine(keys, values, strict)
    Daneel.StackTrace.BeginFunction("table.combine", keys, values, strict)
    local errorHead = "table.combine(keys, values[, strict]) : "
    Daneel.Debug.CheckArgType(keys, "keys", "table", errorHead)
    Daneel.Debug.CheckArgType(values, "values", "table", errorHead)
    Daneel.Debug.CheckOptionalArgType(strict, "strict", "boolean", errorHead)

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
-- @param value (mixed) The value to remove
-- @param singleRemove [optional default=false] (boolean) Tell wether to remove all occurences of the value or just the first one
-- @return (table) The table
function table.removevalue(t, value, singleRemove)
    Daneel.StackTrace.BeginFunction("table.removevalue", t, values, singleRemove)
    local errorHead = "table.removevalue(t, value[, singleRemove]) : "
    Daneel.Debug.CheckArgType(t, "table", "table", errorHead)
    Daneel.Debug.CheckOptionalArgType(singleRemove, "singleRemove", "boolean", errorHead)
    
    if value == nil then
        daneelerror(errorHead.."Argument 'value' is nil.")
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

-- Return all the keys of the provided table
-- @param t (table) The table
-- @return (table) The keys
function table.getkeys(t)
    Daneel.StackTrace.BeginFunction("table.getkeys", t)
    local errorHead = "table.getkeys(t) : "
    Daneel.Debug.CheckArgType(t, "table", "table", errorHead)

    local keys = table.new()
    for key, value in pairs(t) do
        keys:insert(key)
    end

    Daneel.StackTrace.EndFunction("table.getkeys", keys)
    return keys
end

-- Return all the values of the provided table
-- @param t (table) The table
-- @return (table) The values
function table.getvalues(t)
    Daneel.StackTrace.BeginFunction("table.getvalues", t)
    local errorHead = "table.getvalues(t) : "
    Daneel.Debug.CheckArgType(t, "table", "table", errorHead)

    local values = table.new()
    for key, value in pairs(t) do
        values:insert(value)
    end

    Daneel.StackTrace.EndFunction("table.getvalues", values)
    return values
end


