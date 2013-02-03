
function string.totable(s, g)
    if s == string then
        s = g
    end

    local argType = type(s)
    if argType ~= "string" then
        error("string.totable(string) : Argument 'string' is of type '"..argType.."' instead of 'table'.")
    end

    local strLen = s:len()
    local t = {}

    for i = 1, strLen do
        table.insert(t, s:sub(i, i))
    end 

    return t
end
