
Component = {}


-- Create dynamic Getters and Setter
-- Set the key __index and __newindex on all components objects
function Component.CreateDynamicGettersAndSetter()
    local componentObjects = Daneel.config.componentObjects

    for i, object in pairs(componentObjects) do

        -- Getter
        object["__index"] = function(t, key) 
            local funcName = "Get"..key:ucfirst()
            
            if object[funcName] ~= nil then
                return object[funcName](t)
            elseif object[key] ~= nil then
                return object[key] -- have to return the function here, not the function return value !
            end
            
            return rawget(t, key)
        end

        -- Setter
        object["__newindex"] = function(t, key, value)
            local funcName = "Set"..key:ucfirst()
            
            if object[funcName] ~= nil then
                return object[funcName](t, value)
            end
            
            return rawset(t, key, value)
        end
    end
end



----------------------------------------------------------------------------------


-- set model
-- set map


