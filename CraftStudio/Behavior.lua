
local B = Behavior -- for some reason Behavior is not accessible from within a Behavior function

-- Dynamic getters
function Behavior.__index(scriptedBehavior, key) 
    local funcName = "Get"..key:ucfirst()
    
    if B[funcName] ~= nil then
        return B[funcName](scriptedBehavior)
    elseif B[key] ~= nil then
        return B[key] -- have to return the function here, not the function return value !
    end
    
    return rawget(scriptedBehavior, key)
end

-- Dynamic setters
function Behavior.__newindex(scriptedBehavior, key, value)
    local funcName = "Set"..key:ucfirst()
    
    if B[funcName] ~= nil then
        return B[funcName](scriptedBehavior, value)
    end
    
    rawset(scriptedBehavior, key, value)
end
