
local stringMetatable = getmetatable("") -- the 'string' class is origininally stringMetatable.__index

-- Allow to build a string by repeating sevral times a strring segment
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

-- Turn a string into a table, one character per index
-- @param s (string) The string
-- @return (table) The table
function string.totable(s)
    Daneel.StackTrace.BeginFunction("string.totable", s)
    Daneel.Debug.CheckArgType(s, "string", "string", errorHead)
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
-- @param ignoreCase [optional default=false] (boolean) Ignore the case
-- @return (boolean) True if 's' is found in 't', false otherwise
function string.isoneof(s, t, ignoreCase)
    Daneel.StackTrace.BeginFunction("string.isoneof", s, t, ignoreCase)
    local errorHead = "string.isoneff(string, table[, ignoreCase]) : "
    Daneel.Debug.CheckArgType(s, "string", "string", errorHead)
    Daneel.Debug.CheckArgType(t, "t", "table", errorHead)
    Daneel.Debug.CheckOptionalArgType(ignoreCase, "ignoreCase", "boolean", errorHead)
    local isOneOf = table.constainsvalue(t, s, ignoreCase)
    Daneel.StackTrace.EndFunction("string.isoneof", isOneOf)
    return isOneOf
end

-- Make the first letter uppercase
-- @param s (string) The string
-- @return (string) The string
function string.ucfirst(s)
    Daneel.StackTrace.BeginFunction("string.ucfirst", s)
    local errorHead = "string.ucfirst(string) : "
    Daneel.Debug.CheckArgType(s, "string", "string", errorHead)
    t = s:totable()
    t[1] = t[1]:upper()
    s = t:concat()
    Daneel.StackTrace.EndFunction("string.ucfirst", s)
    return s
end

