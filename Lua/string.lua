
-- Dynamic properties

local stringMetatable = getmetatable("") -- the 'string' class is origininally stringMetatable.__index

--
function stringMetatable.__index(s, key) 
    if key == "length" then
        return string.len(s)
    end

    return rawget(string, key)
end

   

-- Turn a string into a table, one character per index
-- @param s (string) The string
-- @return (table) The table
function string.totable(s, g)
    if s == string then
        s = g
    end

    local argType = type(s)
    if argType ~= "string" then
        error("string.totable(string) : Argument 'string' is of type '"..argType.."' with value '"..tostring(s).."' instead of 'string'.")
    end

    local strLen = s:len()
    local t = table.new()

    for i = 1, strLen do
        table.insert(t, s:sub(i, i))
    end 

    return t
end

-- Alias of table.containsvalue().
-- Tell wether the specified table contains the specified string. 
-- @param s (string) The string
-- @param t (table) The table conataining the values to check against argument 'string'.
-- @param ignoreCase [optional=false] (boolean) Ignore the case
-- @return (boolean) True if 's' is found in 't', false otherwise
function string.isOneOf(s, t, ignoreCase, g)
    if s == string then
        s = t
        t = ignoreCase
        ignoreCase = g
    end

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
        error(errorHead.."Argument 'string' is of type '"..argType.."' with value '"..tostring(s).."' instead of 'string'.")
    end

    return table.constainsvalue(t, s, ignoreCase)
end


-- Make the first letter uppercase
-- @param s (string) The string
-- @return (string) The string
function string.ucfirst(s, g)
    if s == string then
        s = g
    end

    local errorHead = "string.ucfirst(string) : "

    local argType = type(s)
    if argType ~= "string" then
        error(errorHead.."Argument 'string' is of type '"..argType.."' with value '"..tostring(s).."' instead of 'string'.")
    end

    t = s:totable()
    t[1] = t[1]:upper()
    return t:concat()
end

