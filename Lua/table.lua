

-- Dynamic properties

-- Built-in table have no metatable
-- The new() function add 'table' as the metatable

function table.__index(t, key) 
    if key == "length" then
        return table.length(t)
    end

    return rawget(table, key)
end

-- Allow tbale1 + table2
function table.__add(t1, t2)
    return table.join(t1, t2)
end



-- Constructor for tables that allows to use the functions in the table table on the table copies.
-- @param ... [optionnal] (mixed) A single table, or 2 or more values to fill the new table with.
-- @return (table) The new table.
function table.new(...)
    if arg == nil then 
        return setmetatable({}, table)
    end

    arg.n = nil
    local newTable = arg
    
    if arg[2] == nil and type(arg[1]) == "table" then -- the only argument is the table
        for key,value in pairs(arg[1]) do
            newTable[key] = value
        end
    end

    return setmetatable(newTable, table)
end

-- Return a copy of the provided table.
-- Dependent of table.new().
-- @param t (table) The table to copy.
function table.copy(t)    
    local argType = type(t)
    if argType ~= "table" then
        error("table.copy(table) : Argument 'table' is of type '"..argType.."' with value '"..tostring(t).."' instead of 'table'.")
    end

    return table.new(t)
end

-- Tells wether the provided key is found within the provided table.
-- @param t (table) The table to search in.
-- @param key (string) The key to search for.
-- @return (boolean) True if the key is found in the table, false otherwise.
function table.containskey(t, p_key)
    local errorHead = "table.containskey(table, key) : "

    local argType = type(t)
    if argType ~= "table" then
        error(errorHead.."Argument 'table' is of type '"..argType.."' with value '"..tostring(t).."' instead of 'table'.")
    end
    
    argType = type(p_key)
    if argType ~= "string" then
        error(errorHead.."Argument 'key' is of type '"..argType.."' with value '"..tostring(p_key).."' instead of 'string'.")
    end
    
    for key, value in pairs(t) do
        if p_key == key then return true end
    end
    
    return false
end

-- Tells wether the provided value is found within the provided table.
-- @param t (table) The table to search in.
-- @param value (any) The value to search for.
-- @param ignoreCase [optionnal] (boolean=false) Ignore the case of the value. If true, the value must be of type 'string'.
-- @return (boolean) True if the value is found in the table, false otherwise.
function table.containsvalue(t, p_value, ignoreCase)
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
    
    for key, value in pairs(t) do
        if ignoreCase then
            p_value = p_value:lower()
            value = value:lower()
        end

        if p_value == value then return true end
    end
    
    return false
end

-- Returns the length of a table, which is the numbers of keys for which the value is non-nil.
-- The keyType argument can be "all" (default to "all"), nil (same effect as "all") or any Lua type (as a string).
-- The function returns only count the number of keys of values for which the key has the specified.
-- Dependent of table.constainsvalue().
-- @param t (table) The table.
-- @param keyType [optionnal] (string="all") See function description.
-- @return (number) The table length.
function table.length(t, keyType)
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

    return length
end

-- Print all key/value pairs within the provided table.
-- Dependent of table.length().
-- @param t (table) The table.
function table.print(t)
    errorHead = "table.print(table) : "

    if t == nil then
        print(errorHead.."Provided table is nil")
        return
    end

    local argType = type(t)
    if argType ~= 'table' then
        error(errorHead.."Argument 'table' is of type '"..argType.."' with value '"..tostring(t).."' instead of 'table'.")
    end
    
    if table.length(t) == 0 then
        print(errorHead.."Provided table is empty.")
        return
    end

    print("===== "..errorHead.."Start =====")
    print(t)

    for key, value in pairs(t) do
        print(key, value)
    end

    print("===== "..errorHead.."End =====")
end

-- Print the metatable of the provided table.
-- Dependent of table.length().
-- @param t (table) The table.
function table.printmetatable(t)
    errorHead = "table.printmetatable(table) : "

    if t == nil then
        print(errorHead.."Provided table is nil")
        return
    end

    local argType = type(t)
    if argType ~= 'table' then
        error(errorHead.."Argument 'table' is of type '"..argType.."' with value '"..tostring(t).."' instead of 'table'.")
    end
    
    local mt = getmetatable(table)
    if mt == nil then
        print(errorHead.."Provided table has no metatable attached.")
        return
    end

    if table.length(mt) == 0 then
        print(errorHead.."The metatable of the provided table is empty.")
        return
    end
   
    for key, value in pairs(mt) do
        print(key, value)
    end
end

-- Join two or more tables into one.
-- Integer keys are not overrided.
-- Dependent of math.isinterger().
-- @param ... (table) At least two tables to join together. Non-table arguments are ignored.
-- @return (table) The new table.
function table.join(...)
    if arg == nil then 
        error("table.join(...) : No argument provided. Need at least two.")
    end
    
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
    
    return fullTable
end

-- Compare table1 and table2. Returns true if they have the exact same keys which have the exact same values.
-- Dependant of table.length().
-- @param table1 (table) The first table to compare.
-- @param table2 (table) The second table to compare to the first table.
-- @return (boolean) True if the two table have the same content.
function table.compare(table1, table2)
    local errorHead = "table.compare(table1, table2) : "
    
    local argType = type(table1)
    if argType ~= "table" then
        error(errorHead.."Argument 'table1' is of type '"..argType.."' with value '"..tostring(table1).."' instead of 'table'.")
    end

    argType = type(table2)
    if argType ~= "table" then
        error(errorHead.."Argument 'table2' is of type '"..argType.."' with value '"..tostring(table2).."' instead of 'table'.")
    end

    if table.length(table1) ~= table.length(table2) then
        return false
    end

    for key, value in pairs(table1) do
        if table1[key] ~= table2[key] then
            return false
        end
    end
    
    return true
end

-- Create an associative table for the provided keys and values table
-- @param keys (table) The keys of the future table
-- @param values (table) The values of the future table
-- @param strict [optional] (boolean=false) If true, the function returns false if the keys and values table have different length
-- @return (table or boolean) The combined table or false if the table have different length
function table.combine(keys, values, strict)
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

        if strict == true then return false end
    end

    local newTable = table.new()

    for i, key in ipairs(keys) do
        newTable[key] = values[i]
    end

    return newTable
end


