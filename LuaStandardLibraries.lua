
----------------------------------------------------------------------------------
-- math


--- Tell wether the provided number is an integer.
-- @param number The number to check.
-- @param strict [optionnal default=false] (boolean) If true, the function returns an error when the 'number' argument is not a number.
function math.isinteger(number, strict)
    local argType = type(number)
    if argType ~= "number" then
        if strict ~= nil and strict == true then
            error("math.isinterger(number[, strict]) : Argument 'number' is of type '"..argType.."' instead of 'number'.")
        else
            return false
        end
    end
    local isinteger = number == math.floor(number)
    return isinteger
end


----------------------------------------------------------------------------------
-- string


local stringMetatable = getmetatable("") -- the 'string' class is origininally stringMetatable.__index

--- Allow to build a string by repeating several times a strring segment
-- @param s (string) The string
-- @param num (number) The multiplier
-- @return (string) The new string
function stringMetatable.__mul(s, multiplier)
    local fullString = ""
    for i=1, multiplier do
        fullString = fullString .. s
    end
    return fullString
end

--- Turn a string into a table, one character per index
-- @param s (string) The string
-- @return (table) The table
function string.totable(s)
    local strLen = s:len()
    local t = table.new()
    for i = 1, strLen do
        table.insert(t, s:sub(i, i))
    end 
    return t
end

--- Alias of table.containsvalue().
-- Tell wether the specified table contains the specified string. 
-- @param s (string) The string
-- @param t (table) The table conataining the values to check against argument 'string'.
-- @param ignoreCase [optional default=false] (boolean) Ignore the case
-- @return (boolean) True if 's' is found in 't', false otherwise
function string.isoneof(s, t, ignoreCase)
    return table.containsvalue(t, s, ignoreCase)
end

--- Make the first letter uppercase
-- @param s (string) The string
-- @return (string) The string
function string.ucfirst(s)
    t = s:totable()
    t[1] = t[1]:upper()
    s = t:concat()
    return s
end



----------------------------------------------------------------------------------
-- table



-- Built-in table have no metatable
-- The table.new() function add the 'table' object as the metatable

table.__index = table

--- Constructor for dynamic tables that allow to use the functions in the table library on the table copies.
-- @param ... [optional] (mixed) A single table, or 0 or more values to fill the new table with.
-- @return (table) The new table.
function table.new(...)
    local t = {}
    if arg[2] ~= nil then -- at least two arguments
        t = arg
    elseif arg[1] ~= nil then -- only one argument, must be a table
        t = arg[1]
    end
    t = setmetatable(t, table)
    return t
end

--- Return a copy of the provided table.
-- Dependent of table.new().
-- @param t (table) The table to copy.
function table.copy(t)
    local t2 = table.new()
    for key, value in pairs(t) do
        t2[key] = value
    end  
    return t2
end

--- Tells wether the provided key is found within the provided table.
-- @param t (table) The table to search in.
-- @param key (mixed) The key to search for.
-- @return (boolean) True if the key is found in the table, false otherwise.
function table.containskey(t, p_key)
    if p_key == nil then
        Daneel.Debug.PrintError(errorHead.."Argument 'p_key' is 'nil'.")
    end
    local containsKey = false
    for key, value in pairs(t) do
        if p_key == key then
            containsKey = true
            break
        end
    end
    return containsKey
end

--- Tells wether the provided value is found within the provided table.
-- @param t (table) The table to search in.
-- @param value (any) The value to search for.
-- @param ignoreCase [optionnal default=false] (boolean) Ignore the case of the value. If true, the value must be of type 'string'.
-- @return (boolean) True if the value is found in the table, false otherwise.
function table.containsvalue(t, p_value, ignoreCase)
    if p_value == nil then
        Daneel.Debug.PrintError(errorHead.."Argument 'value' is nil.")
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
    return containsValue
end

--- Returns the length of a table, which is the numbers of keys of the specified type (or of any type), for which the value is non-nil.
-- @param t (table) The table.
-- @param keyType [optional] (string) Any Lua or CraftStudio type.
-- @return (number) The table length.
function table.length(t, keyType)
    local length = 0
    for key, value in pairs(t) do
        if keyType == nil then
            length = length + 1
        elseif Daneel.Debug.GetType(key) == keyType then
            length = length + 1
        end
    end
    return length
end

--- Print all key/value pairs within the provided table.
-- @param t (table) The table.
function table.print(t)
    if t == nil then
        print("table.print(t) : Provided table is nil.")
        return
    end
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
end

--- Print the metatable of the provided table.
-- Dependent of table.length().
-- @param t (table) The table.
function table.printmetatable(t)
    local errorHead = "table.printmetatable(t) : "
    if t == nil then
        print(errorHead.."Provided table is nil.")   
        return
    end
    local mt = getmetatable(t)
    if mt == nil then
        print(errorHead.."Provided table '"..tostring(t).."' has no metatable attached.")
        return
    end
    if table.length(mt) == 0 then
        print(errorHead.."The metatable of the provided table is empty.")  
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
end

--- Merge two or more tables into one. Integer keys are not overrided.
-- @param ... (table) At least two tables to merge together. Non-table arguments are ignored.
-- @return (table) The new table.
function table.merge(...)
    if arg == nil then 
        Daneel.Debug.PrintError("table.merge(...) : No argument provided. Need at least two.")
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

--- Compare table1 and table2. Returns true if they have the exact same keys which have the exact same values.
-- @param table1 (table) The first table to compare.
-- @param table2 (table) The second table to compare to the first table.
-- @return (boolean) True if the two table have the same content.
function table.compare(table1, table2)
    local areEqual = true
    if table.length(table1) ~= table.length(table2) then 
        return false
    end
    for key, value in pairs(table1) do
        if table1[key] ~= table2[key] then
            areEqual = false
            break
        end
    end
    return areEqual
end

--- Create an associative table with the provided keys and values table
-- @param keys (table) The keys of the future table
-- @param values (table) The values of the future table
-- @param strict [optional default=false] (boolean) If true, the function returns false if the keys and values table have different length
-- @return (table or boolean) The combined table or false if the table have different length
function table.combine(keys, values, strict)
    if table.length(keys) ~= table.length(values) then
        print(errorHead.."Arguments 'keys' and 'values' have different length.")

        if strict == true then
            
            return false
        end
    end
    local newTable = table.new()
    for i, key in ipairs(keys) do
        newTable[key] = values[i]
    end
    return newTable
end

--- Remove the specified value from the provided table
-- @param t (table) The table
-- @param value (mixed) The value to remove
-- @param singleRemove [optional default=false] (boolean) Tell wether to remove all occurences of the value or just the first one
-- @return (table) The table
function table.removevalue(t, value, singleRemove)
    if value == nil then
        Daneel.Debug.PrintError(errorHead.."Argument 'value' is nil.")
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
    return t
end

--- Return all the keys of the provided table
-- @param t (table) The table
-- @return (table) The keys
function table.getkeys(t)
    local keys = table.new()
    for key, value in pairs(t) do
        keys:insert(key)
    end
    return keys
end

--- Return all the values of the provided table
-- @param t (table) The table
-- @return (table) The values
function table.getvalues(t)
    local values = table.new()
    for key, value in pairs(t) do
        values:insert(value)
    end
    return values
end

--- Get the key associated with the provided value
-- @param t (table) The table
-- @param value (mixed) The value
function table.getkey(t, value)
    local key = nil
    for k, v in pairs(t) do
        if value == v then
            key = k
        end
    end
    return key
end



function table.dump(t)
    
    print("~~~~~ table.print() ~~~~~ Start ~~~~~")
    if t == nil then
        print("Provided table is nil.")
        t = {}
    end

    for key, value in pairs(t) do
        print(key, value)
    end
    print("~~~~~ table.print() ~~~~~ End ~~~~~")
end