
--------------------------------------------------

--
-- Constructor for tables that allows to use the functions  in the table table on the table copies
--
function table.new (...)
    local table_mt = {}
    table_mt.__index = table

    if arg == nil then 
        return setmetatable ({}, table_mt)
    end

    arg.n = nil
    local newTable = arg
    
    if arg[2] == nil and type (arg[1]) == "table" then -- the only argument is the table
        for key,value in pairs(arg[1]) do
            newTable[key] = value
        end

        --newTable = table.copy (arg[1]) -- outch, great infinite loop with copy() that calls new()
    end

    return setmetatable (newTable, table_mt)
end


--------------------------------------------------

--
-- Return a copy of the provided table
--
function table.copy (t)
    if t == nil then
        error ("table.copy(table) : Arguent #1 is nil.")
    end
    
    local argType = type (t)
    if argType ~= "table" then
        error ("table.copy(table) : Argument #1 is of type "..argType.." instead of table.")
    end
    
    ----------

    return table.new (t)
end


--------------------------------------------------

--
-- Tells wether the provided key is found within the provided table
--
function table.containskey (t, p_key)
    if t == nil then
        error ("table.containskey(table, key) : Argument #1 is nil.")
    end
    
    local argType = type (t)
    if argType ~= "table" then
        error ("table.containskey(table, key) : Argument #1 is of type "..argType.." instead of table.")
    end
    
    if p_key == nil then
        error ("table.containskey(table, key) : Argument #2 is nil.")
    end
    
    ----------
    
    for key,value in pairs(t) do
        if p_key == key then return true end
    end
    
    return false
end


--------------------------------------------------

--
-- tells wether the provided value is found within the provided table
--
function table.containsvalue (t, p_value)
    if t == nil then
        error ("table.containsvalue(table, value) : Argument #1 is nil.")
    end
    
    local argType = type (t)
    if argType ~= "table" then
        error ("table.containsvalue(table, value) : Argument #1 is of type "..argType.." instead of table.")
    end
    
    if p_value == nil then
        error ("table.containsvalue(table, value) : Argument #2 is nil.")
    end
    
    ----------
    
    for key,value in pairs(t) do
        if p_value == value then return true end
    end
    
    return false
end


--------------------------------------------------

--
-- return the length of a table
-- keyType can be "number", "string", "both" or nil (defaulted to "both")
-- if "number", it count only numeric keys
-- if "string", it count only string key
-- if "both", it count both
--
function table.length (t, keyType)
    if t == nil then
        error ("table.length(table, keyType) : Argument #1 is empty.")
    end
    
    local argType = type (t)
    if argType ~= "table" then
        error ("table.length(table, keyType) : Argument #1 is of type "..argType.." instead of table.")
    end
    
    if keyType == nil then
        keyType = "both"
    elseif not table.containsvalue ({"number", "string", "both"}, keyType) then
        error ("table.length(table, keyType) : Argument #2 as an unautorized value ["..tostring(keyType).."]. Must be 'number', 'string', 'both' or nil.")
    end
    
    ----------  
    
    local length = 0
    
    for key,value in pairs(t) do
        if keyType == "both" then
            length = length +1
        elseif type (key) == keyType then
            length = length +1
        end
    end

    return length
end


--------------------------------------------------

--
-- Print all key/value pairs within the provided table
-- if verbose is true (a nil value is defaulted to false)
--
function table.print(t)
    if t == nil then
        print("table is nil")
        return
    end
    
    local argType = type (t)
    if argType ~= "table" then
        print ("table.print(table) : Argument #1 is of type "..argType.." instead of table.")
        return
    end
    
    if table.length (t) == 0 then
        print ("table.print(table) : Provided table is empty.")
        return
    end

    ----------
    
    for key,value in pairs(t) do
        print (key, value)
    end
end


--------------------------------------------------

--
-- Print all key/value pairs within the provided table
-- if verbose is true (a nil value is defaulted to false)
--
function table.printmetatable(t)
    if t == nil then
        print ("table.printmetatable(table) : Argument 'table' is nil.")
        return
    end
    
    local argType = type (t)
    if argType ~= "table" then
        print ("table.printmetatable(table) : Argument 'table' is of type "..argType.." instead of table.")
        return
    end
    
    local mt = getmetatable (table)
    if mt == nil then
        print ("table.printmetatable(table) : No metatable attached to the provided table.")
        return
    end

    ----------
    
    for key,value in pairs(mt) do
        print (key, value)
    end
end


--------------------------------------------------

--
-- Concatenate several table into one
--
function table.join(...)
    if arg == nil then 
        error ("table.join(...) : No argument provided. Need at least two.")
    end
    
    local fullTable = {}
    
    for i, t in ipairs(arg) do
        if type(t) == "table" then
            for key, value in pairs(t) do
                if type(tonumber(key)) == "number" then
                    table.insert(fullTable, value)
                else
                    fullTable[key] = value
                end
            end
        end
    end
    
    return fullTable
end


--------------------------------------------------

--
-- Compare t1 and t2
--
function table.compare (t1, t2)
    if table.length (t1) ~= table.length (t2) then
        return false
    end

    for key,value in ipairs (t1) do
        if t1[key] ~= t2[key] then
            return false
        end
    end
    
    return true
end
