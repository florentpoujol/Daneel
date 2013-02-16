
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

