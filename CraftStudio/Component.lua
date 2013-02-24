
Component = {}
Component.__index = Component

function Component.__tostring(component)
    -- this has the advantage to return the asset ID that follows the
    return tostring(asset.inner):sub(31, 60)
end

-- Create dynamic Getters and Setter
-- Set the key __index and __newindex on all components objects
function Component.Init()
    local components = table.combine(Daneel.config.componentTypes, Daneel.config.componentObjects)

    for componentType, object in pairs(components) do

        setmetatable(object, Component)

        -- component instances have the coresponding object (ie :ModelRenderer for a ModelRenderer instance)
        -- as metatable but it is hidden.
        -- Plus, the inner variable is unreadable, at least not like it is for the Assets (CraftStudioCommon.ProjectData.[AssetType])
        -- The purpose of the csType variable here is to be read by cstype() function (in the Utilities script)
        object.csType = componentType


        -- Dynamic Getters
        object["__index"] = function(t, key) 
            local funcName = "Get"..key:ucfirst()
            
            if object[funcName] ~= nil then
                return object[funcName](t)
            elseif object[key] ~= nil then
                return object[key] -- have to return the function here, not the function return value !
            end
            
            return rawget(t, key)
        end

        -- Dynamic Setters
        object["__newindex"] = function(t, key, value)
            local funcName = "Set"..key:ucfirst()
            
            if object[funcName] ~= nil then
                return object[funcName](t, value)
            end
            
            return rawset(t, key, value)
        end

        object["__tostring"] = function(component)
            -- returns something like "ModelRenderer: 123456789"
            -- component.inner is "?: [some ID]"
            return cstype(component)..tostring(component.inner):sub(2,20)
        end
    end
end


-- Apply the content of the params argument to the component in argument.
-- @param component (Scriptedbehavior, ModelRenderer, MapRenderer, Camera or Transform) The component
-- @param params (table) A table of parameters to initialize the new component with.
-- @return (Scriptedbehavior, ModelRenderer, MapRenderer, Camera or Transform) The component
function Component.Set(component, params)
    if params == nil then
        return component
    end

    Daneel.StackTrace.BeginFunction("Component.Set", component, params)
    local errorHead = "Component.Set(component, params) : "
    Daneel.Debug.CheckArgType(params, "params", "table", errorHead)
    local componentType = cstype(component)
    local argType = nil

    for key, value in pairs(params) do
        component[key] = value
    end

    Daneel.StackTrace.BeginFunction("Component.Set")
end
