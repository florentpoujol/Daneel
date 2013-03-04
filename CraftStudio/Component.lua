
Component = {}
Component.__index = Component


-- Create dynamic Getters and Setter
-- Set the key __index and __newindex on all components objects
function Component.Init()
    local components = table.combine(Daneel.config.componentTypes, Daneel.config.componentObjects)

    for componentType, object in pairs(components) do

        setmetatable(object, Component)

        -- component instances have the coresponding object (ie :ModelRenderer for a ModelRenderer instance)
        -- as metatable but it is hidden.
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

        object["__tostring"] = function(component)
            -- returns something like "ModelRenderer: 123456789"
            -- component.inner is "?: [some ID]"
            return Daneel.Debug.GetType(component)..": "..tostring(component.inner):sub(2,20)
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

    Daneel.StackTrace.BeginFunction("Component.Set", component, params)
    local errorHead = "Component.Set(component, params) : "
    Daneel.Debug.CheckArgType(params, "params", "table", errorHead)
    local componentType = Daneel.Debug.GetType(component)
    local argType = nil

    for key, value in pairs(params) do
        component[key] = value
    end

    Daneel.StackTrace.EndFunction("Component.Set")
end


----------------------------------------------------------------------------------
-- ModelRenderer

local OriginalSetModel = ModelRenderer.SetModel

--- Attach the provided model to the provided modelRenderer
-- @param modelRenderer (ModelRenderer) The modelRenderer
-- @param modelNameOrAsset (string or Model) The model name or asset
function ModelRenderer.SetModel(modelRenderer, modelNameOrAsset)
    Daneel.StackTrace.BeginFunction("ModelRenderer.SetModel", modelRenderer, modelNameOrAsset)
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
end



----------------------------------------------------------------------------------
-- MapRenderer

local OriginalSetMap = MapRenderer.SetMap

--- Attach the provided map to the provided mapRenderer
-- @param mapRenderer (MapRenderer) The mapRenderer
-- @param mapNameOrAsset (string or Map) The map name or asset
function MapRenderer.SetMap(mapRenderer, mapNameOrAsset)
    Daneel.StackTrace.BeginFunction("MapRenderer.SetMap", mapRenderer, mapNameOrAsset)
    local errorHead = "MapRenderer.SetMap(mapRenderer, mapNameOrAsset) : "
    Daneel.Debug.CheckArgType(mapRenderer, "mapRenderer", "MapRenderer", errorHead)
    Daneel.Debug.CheckArgType(mapNameOrAsset, "mapNameOrAsset", {"string", "Map"}, errorHead)
 
    local map = mapNameOrAsset
    if type(mapNameOrAsset) == "string" then
        map = Asset.Get(mapNameOrAsset, "Model")
        if map == nil then
            Daneel.Debug.PrintError(errorHead.."Argument 'mapNameOrAsset' : map with name '"..mapNameOrAsset.."' was not found.")
        end
    end

    OriginalSetMap(mapRenderer, map)
end

