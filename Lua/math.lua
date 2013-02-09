
-- Tell wether the provided number is an integer.
-- @param number The number to check.
-- @param strict [optionnal] (boolean=false) If true, the function returns an error when the 'number' argument is not a number.
function math.isinteger(number, strict)
    local argType = type(number)
    if argType ~= "number" then
        if strict ~= nil and strict == true then
            error("math.isinterger(number[, strict]) : Argument 'number' is of type '"..argType.."' instead of 'number'.")
        else
            return false
        end
    end

    return number == math.floor(number)
end
-- used in table.join()