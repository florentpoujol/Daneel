
-- Tell wether the provided number is an integer.
-- @param number The number to check.
-- @param strict [optionnal default=false] (boolean) If true, the function returns an error when the 'number' argument is not a number.
function math.isinteger(number, strict)
    Daneel.Debug.StackTrace.BeginFunction("math.isinteger", number, strict)
    
    local argType = type(number)
    if argType ~= "number" then
        if strict ~= nil and strict == true then
            error("math.isinterger(number[, strict]) : Argument 'number' is of type '"..argType.."' instead of 'number'.")
        else
            Daneel.Debug.StackTrace.EndFunction("math.isinteger", false)
            return false
        end
    end

    local isinteger = number == math.floor(number)
    Daneel.Debug.StackTrace.EndFunction("math.isinteger", isinteger)
    return isinteger
end
-- used in table.join()
