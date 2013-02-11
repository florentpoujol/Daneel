
-- Dynamic properties for Getters and Setters

-- ModelRenderer
function ModelRenderer.__index(t, key) 
    local funcName = "Get"..key:ucfirst()
    
    if ModelRenderer[funcName] ~= nil then
        return ModelRenderer[funcName](t)
    elseif ModelRenderer[key] ~= nil then
        return ModelRenderer[key] -- have to return the function here, not the function return value !
    end
    
    return rawget(t, key)
end

function ModelRenderer.__newindex(t, key, value)
    local funcName = "Set"..key:ucfirst()
    
    if ModelRenderer[funcName] ~= nil then
        return ModelRenderer[funcName](t, value)
    end
    
    return rawset(t, key, value)
end


-- MapRenderer
function MapRenderer.__index(t, key) 
    local funcName = "Get"..key:ucfirst()
    
    if MapRenderer[funcName] ~= nil then
        return MapRenderer[funcName](t)
    elseif MapRenderer[key] ~= nil then
        return MapRenderer[key] -- have to return the function here, not the function return value !
    end
    
    return rawget(t, key)
end

function MapRenderer.__newindex(t, key, value)
    local funcName = "Set"..key:ucfirst()
    
    if MapRenderer[funcName] ~= nil then
        return MapRenderer[funcName](t, value)
    end
    
    return rawset(t, key, value)
end


-- Camera
function Camera.__index(t, key) 
    local funcName = "Get"..key:ucfirst()
    
    if Camera[funcName] ~= nil then
        return Camera[funcName](t)
    elseif Camera[key] ~= nil then
        return Camera[key] -- have to return the function here, not the function return value !
    end
    
    return rawget(t, key)
end

function Camera.__newindex(t, key, value)
    local funcName = "Set"..key:ucfirst()
    
    if Camera[funcName] ~= nil then
        return Camera[funcName](t, value)
    end
    
    return rawset(t, key, value)
end


-- Transform
function Transform.__index(t, key) 
    local funcName = "Get"..key:ucfirst()
    
    if Transform[funcName] ~= nil then
        return Transform[funcName](t)
    elseif Transform[key] ~= nil then
        return Transform[key] -- have to return the function here, not the function return value !
    end
    
    return rawget(t, key)
end

function Transform.__newindex(t, key, value)
    local funcName = "Set"..key:ucfirst()
    
    if Transform[funcName] ~= nil then
        return Transform[funcName](t, value)
    end
    
    return rawset(t, key, value)
end


----------------------------------------------------------------------------------


-- set model
-- set map


