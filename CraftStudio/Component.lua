
Component = {}
Component.__index = Component


-- Create dynamic Getters and Setter
-- Set the key __index and __newindex on all components objects
function Component.Init()
    local components = Daneel.config.componentObjects
    for componentType, object in pairs(components) do

        if componentType ~= "Script" then
            -- component instances have the coresponding object (ie :ModelRenderer for a ModelRenderer instance)
            -- as metatable but it is hidden (except for ScriptedBehaviors).
            -- Plus, the inner variable is unreadable, at least not like it is for the Assets (CraftStudioCommon.ProjectData.[AssetType])
            -- The purpose of the componentType variable here is to be read by Daneel.Debug.GetType() function (in the Utilities script)
            object.componentType = componentType

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
        end

        object["__tostring"] = function(component)
            -- returns something like "ModelRenderer: 123456789 - table: 051C42D0"
            -- component.inner is "?: [some ID]"
            return Daneel.Debug.GetType(component)..": "..tostring(component.inner):sub(2,20).." - "..tostring(component)
        end
    end

    -- Dynamic getters and setter on Scripts
    for i, path in ipairs(Daneel.config.scripts) do
        local script = Asset.Get(path, "Script")

        if script ~= nil then
            -- Dynamic getters
            function script.__index(scriptedBehavior, key)
                local funcName = "Get"..key:ucfirst()
                              
                if script[funcName] ~= nil then
                    return script[funcName](scriptedBehavior)
                elseif script[key] ~= nil then
                    return script[key]
                end
                
                return rawget(scriptedBehavior, key)
            end

            -- Dynamic setters
            function script.__newindex(scriptedBehavior, key, value)
                local funcName = "Set"..key:ucfirst()
                              
                if script[funcName] ~= nil then
                    return script[funcName](scriptedBehavior, value)
                end
                
                return rawset(scriptedBehavior, key, value)
            end
        else
            print("WARNING : item n°"..i.." with value '"..path.."' in Daneel.config.scriptPaths is not a valid script path.")
        end
    end
end

--- Apply the content of the params argument to the component in argument.
-- @param component (Scriptedbehavior, ModelRenderer, MapRenderer, Camera or Transform) The component
-- @param params (table) A table of parameters to initialize the new component with.
function Component.Set(component, params)
    if params == nil then
        return component
    end

    Daneel.Debug.StackTrace.BeginFunction("Component.Set", component, params)
    local errorHead = "Component.Set(component, params) : "
    Daneel.Debug.CheckArgType(params, "params", "table", errorHead)
    local componentType = Daneel.Debug.GetType(component)
    local argType = nil

    for key, value in pairs(params) do
        component[key] = value
    end

    Daneel.Debug.StackTrace.EndFunction("Component.Set", component)
end

--- Destory the provided component, removing it from the gameObject
-- @param component (ScriptedBehavior, ModelRenderer, MapRenderer, Camera or Transform) The component
function Component.Destroy(component)
    Daneel.Debug.StackTrace.BeginFunction("Component.Destroy", component)
    local errorHead = "Component.Destroy(component) : "
    Daneel.Debug.CheckArgType(component, "component", {"ScriptedBehavior", "ModelRenderer", "MapRenderer", "Camera", "Transform"}, errorHead)
    CraftStudio.Destroy(component)
    Daneel.Debug.StackTrace.EndFunction("Component.Destroy")
end



----------------------------------------------------------------------------------
-- ModelRenderer

local OriginalSetModel = ModelRenderer.SetModel

--- Attach the provided model to the provided modelRenderer
-- @param modelRenderer (ModelRenderer) The modelRenderer
-- @param modelNameOrAsset (string or Model) The model name or asset
function ModelRenderer.SetModel(modelRenderer, modelNameOrAsset)
    Daneel.Debug.StackTrace.BeginFunction("ModelRenderer.SetModel", modelRenderer, modelNameOrAsset)
    local errorHead = "ModelRenderer.SetModel(modelRenderer, modelNameOrAsset) : "
    Daneel.Debug.CheckArgType(modelRenderer, "modelRenderer", "ModelRenderer", errorHead)
    Daneel.Debug.CheckArgType(modelNameOrAsset, "modelNameOrAsset", {"string", "Model"}, errorHead)

    local model = modelNameOrAsset
    if type(modelNameOrAsset) == "string" then
        model = Asset.Get(modelNameOrAsset, "Model")
        if model == nil then
            Daneel.Debug.PrintError(errorHead.."Argument 'modelNameOrAsset' : model with name '"..modelNameOrAsset.."' was not found.")
        end
    end

    OriginalSetModel(modelRenderer, model)
    Daneel.Debug.StackTrace.EndFunction("ModelRenderer.SetModel")
end



----------------------------------------------------------------------------------
-- MapRenderer

local OriginalSetMap = MapRenderer.SetMap

--- Attach the provided map to the provided mapRenderer
-- @param mapRenderer (MapRenderer) The mapRenderer
-- @param mapNameOrAsset (string or Map) The map name or asset
function MapRenderer.SetMap(mapRenderer, mapNameOrAsset)
    Daneel.Debug.StackTrace.BeginFunction("MapRenderer.SetMap", mapRenderer, mapNameOrAsset)
    local errorHead = "MapRenderer.SetMap(mapRenderer, mapNameOrAsset) : "
    Daneel.Debug.CheckArgType(mapRenderer, "mapRenderer", "MapRenderer", errorHead)
    Daneel.Debug.CheckArgType(mapNameOrAsset, "mapNameOrAsset", {"string", "Map"}, errorHead)
 
    local map = mapNameOrAsset
    if type(mapNameOrAsset) == "string" then
        map = Asset.Get(mapNameOrAsset, "Map")
        if map == nil then
            Daneel.Debug.PrintError(errorHead.."Argument 'mapNameOrAsset' : map with name '"..mapNameOrAsset.."' was not found.")
        end
    end

    OriginalSetMap(mapRenderer, map)
    Daneel.Debug.StackTrace.EndFunction("MapRenderer.SetMap")
end

