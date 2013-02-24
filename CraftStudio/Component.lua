
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

-- transform
    --[[if params.transform ~= nil then
        --  position
        if params.transform.position ~= nil then
            argType = cstype(params.transform.position)
            if argType ~= "Vector3" then
                error(errorHead.."Argument 'params.transform.position' is of type '"..argType.."' with value '"..tostring(params.transform.position).."' instead of 'Vector3'.")
            end

            go.transform:SetPosition(params.transform.position)
        end

        if params.transform.localPosition ~= nil then
            argType = cstype(params.transform.localPosition)
            if argType ~= "Vector3" then
                error(errorHead.."Argument 'params.transform.localPosition' is of type '"..argType.."' with value '"..tostring(params.transform.localPosition).."' instead of 'Vector3'.")
            end

            go.transform:SetLocalPosition(params.transform.localPosition)
        end

        -- orientation
        if params.transform.orientation ~= nil then
            argType = cstype(params.transform.orientation)
            if argType ~= "Quaternion" then
                error(errorHead.."Argument 'params.transform.orientation' is of type '"..argType.."' with value '"..tostring(params.transform.orientation).."' instead of 'Quaternion'.")
            end

            go.transform:SetOrientation(params.transform.orientation)
        end

        if params.transform.localOrientation ~= nil then
            argType = cstype(params.transform.localOrientation)
            if argType ~= "Quaternion" then
                error(errorHead.."Argument 'params.transform.localOrientation' is of type '"..argType.."' with value '"..tostring(params.transform.localOrientation).."' instead of 'Quaternion'.")
            end

            go.transform:SetLocalOrientation(params.transform.localOrientation)
        end

        -- Euler Angles
        if params.transform.eulerAngles ~= nil then
            argType = cstype(params.transform.eulerAngles)
            if argType ~= "Vector3" then
                error(errorHead.."Argument 'params.transform.eulerAngles' is of type '"..argType.."' with value '"..tostring(params.transform.eulerAngles).."' instead of 'Vector3'.")
            end

            go.transform:SetEulerAngles(params.transform.eulerAngles)
        end

        if params.transform.localEulerAngles ~= nil then
            argType = cstype(params.transform.localEulerAngles)
            if argType ~= "Vector3" then
                error(errorHead.."Argument 'params.transform.localEulerAngles' is of type '"..argType.."' with value '"..tostring(params.transform.localEulerAngles).."' instead of 'Vector3'.")
            end

            go.transform:SetLocalEulerAngles(params.transform.localEulerAngles)
        end

        -- scale
        if params.transform.localScale ~= nil then
            if type(params.transform.localScale) == "number" then
                params.transform.localScale = Vector3:New(params.transform.localScale)
            end

            argType = cstype(params.transform.localScale)
            if argType ~= "Vector3" then
                error(errorHead.."Argument 'params.transform.localScale' is of type '"..argType.."' with value '"..tostring(params.transform.localScale).."' instead of 'Vector3'.")
            end

            go.transform:SetLocalScale(params.transform.localScale)
        end
    end -- end if params.transform ~= nil

    -- other components
    if params.modelRenderer ~= nil then
        argType = type(params.modelRenderer)

        if argType == "boolean" then
            if params.modelRenderer == true then
                gameObject:AddComponent("ModelRenderer")
            end
        else
            if argType ~= "string" and argType ~= "table" then
                error(errorHead.."Argument 'params.modelRenderer' is of type '"..argType.."' with value '"..tostring(params.modelRenderer).."' instead of 'string' or 'table'.")
            end

            gameObject:AddComponent("ModelRenderer", params.modelRenderer)
        end
    end

    if params.mapRenderer ~= nil then
        argType = type(params.mapRenderer)

        if argType == "boolean" then
            if params.mapRenderer == true then
                gameObject:AddComponent("MapRenderer")
            end
        else
            if argType ~= "string" and argType ~= "table" then
                error(errorHead.."Argument 'params.mapRenderer' is of type '"..argType.."' with value '"..tostring(params.mapRenderer).."' instead of 'string' or 'table'.")
            end

            gameObject:AddComponent("MapRenderer", params.mapRenderer)
        end
    end

    if params.camera ~= nil then
        argType = type(params.camera)

        if argType == "boolean" then
            if params.camera == true then
                gameObject:AddComponent("Camera")
            end
        else
            if argType ~= "string" and argType ~= "table" then
                error(errorHead.."Argument 'params.camera' is of type '"..argType.."' with value '"..tostring(params.camera).."' instead of 'string' or 'table'.")
            end

            gameObject:AddComponent("Camera", params.camera)
        end
    end

    -- scripts
    if params.scriptedBehaviors == nil then
        params.scriptedBehaviors = {}
    end

    if params.scriptedBehavior ~= nil then
        table.insert(params.scriptedBehaviors, params.scriptedBehavior)
    end

    for i, scriptNameOrAsset in ipairs(params.scriptedBehaviors) do
        argType = type(scriptNameOrAsset)
        if argType ~= "string" and argType ~= "Script" then
            error(errorHead.."Item n°"..i.." in argument 'params.scriptedBehaviors' is of type '"..argType.."' with value '"..tostring(scriptNameOrAsset).."' instead of 'string' or 'table/Script'.")
        end

        gameObject:AddComponent("ScriptedBehavior", scriptNameOrAsset)
    end 
]]


-- OLD FROM ADD COMPONENT

-- apply params
    --[[if componentType == "ModelRenderer" then
        -- animation
        if params.animation ~= nil then
            local animation = params.animation
            
            if type(animation) == "string" then
                animation = Asset.Get(params.animation, "ModelAnimation")
            end

            if cstype(animation) ~= "ModelAnimation" then
                error(errorHead.."Argument 'params.animation' is of type '"..cstype(params.animation).."' with value '"..tostring(params.animation).."' instead of 'string' (ModelAnimatin name) or 'ModelAnimation'.")
            end

            component:SetAnimation(animation)
        end

        -- AnimationPlayback
        if params.startAnimationPlayback ~= nil then
            local startAnimationPlayback = params.startAnimationPlayback
            
            argType = type(startAnimationPlayback)
            if argType ~= "boolean" then
                error(errorHead.."Argument 'params.startAnimationPlayback' is of type '"..argType.."' with value '"..tostring(startAnimationPlayback).."' instead of 'boolean'.")
            end

            component:StartAnimationPlayback(startAnimationPlayback)
        end

        -- AnimationTime
        if params.setAnimationTime ~= nil then
            local setAnimationTime = tonumber(params.setAnimationTime)
            
            if type(setAnimationTime) ~= "number"  then
                error(errorHead.."Could not convert argument 'params.setAnimationTime' to number because it is of type '"..type(params.setAnimationTime).."' with value '"..tostring(params.setAnimationTime)..".")
            end

            component:SetAnimationTime(setAnimationTime)
        end

        -- Model
        if params.model ~= nil then
            local model = params.model
            
            if type(model) == "string" then
                model = Asset.Get(params.model, "Model")
            end

            if cstype(model) ~= "Model" then
                error(errorHead.."Argument 'params.model' is of type '"..type(params.model).."' with value '"..tostring(params.model).."' instead of 'string' (the model name) of 'Model'.")
            end

            component:SetModel(model)
        end

        -- Opacity
        if params.opacity ~= nil then
            local opacity = tonumber(params.opacity)
            
            if type(opacity) ~= "number" then
                error(errorHead.."Could not convert argument 'params.opacity' to number because it is of type '"..type(params.opacity).."' with value '"..tostring(params.opacity)..".")
            end

            component:SetOpacity(opacity)
        end
    elseif componentType == "MapRenderer" then
        -- Map
        if params.map ~= nil then
            local map = params.map
            
            if type(map) == "string" then
                map = Asset.Get(params.map, "Map")
            end

            if cstype(map) ~= "Map" then
                error(errorHead.."Argument 'params.map' is of type '"..type(params.map).."' with value '"..tostring(params.map).."' instead of 'string' (the Map name) or 'Map'.")
            end

            component:SetMap(map)
        end

        -- TileSet
        if params.tileSet ~= nil then
            local tileSet = params.tileSet
            
            if type(tileSet) == "string" then
                tileSet = Asset.Get(params.tileSet, "TileSet")
            end

            if cstype(tileSet) ~= "TileSet" then
                error(errorHead.."Argument 'params.tileSet' is of type '"..type(params.tileSet).."' with value '"..tostring(params.tileSet).."' instead of 'string' (the TileSet name) or 'TileSet'.")
            end

            component:SetTileSet(tileSet)
        end

        -- Opacity
        if params.opacity ~= nil then
            local opacity = tonumber(params.opacity)
            
            if type(opacity) ~= "number" then
                error(errorHead.."Could not convert argument 'params.opacity' to number because it is of type '"..type(params.opacity).."' with value '"..tostring(params.opacity)..".")
            end

            component:SetOpacity(opacity)
        end
    elseif componentType == "Camera" then
        -- projection mode
        if params.projectionMode ~= nil then
            local projectionMode = params.projectionMode
            
            if params.projectionMode ~= Camera.ProjectionMode.Perspective and params.projectionMode ~= Camera.ProjectionMode.Orthographic then
                error(errorHead.."Argument 'params.projectionMode' is not 'Camera.ProjectionMode.Perspective' or 'Camera.ProjectionMode.Orthographic'. Must be one of those.")
            end

            component:SetProjectionMode(params.projectionMode)
        end

        -- fov
        if params.fov ~= nil then
            local fov = tonumber(params.fov)
            
            if type(fov) ~= "number" then
                error(errorHead.."Could not convert argument 'params.fov' to number because it is of type '"..type(params.fov).."' with value '"..tostring(params.fov)..".")
            end

            component:SetFov(fov)
        end

        -- orthographicScale
        if params.orthographicScale ~= nil then
            local orthographicScale = tonumber(params.orthographicScale)
            
            if type(orthographicScale) ~= "number" then
                error(errorHead.."Could not convert argument 'params.orthographicScale' to number because it is of type '"..type(params.orthographicScale).."' with value '"..tostring(params.orthographicScale)..".")
            end

            component:SetOrthographicScale(orthographicScale)
        end

        -- renderViewportPosition
        if params.renderViewportPosition ~= nil then
            local renderViewportPosition = params.renderViewportPosition
            
            if type(renderViewportPosition) ~= "table" then
                error(errorHead.."Argument 'params.renderViewportPosition' is of type '"..type(params.renderViewportPosition).."' with value '"..tostring(params.renderViewportPosition).." instead of 'table'.")
            end

            renderViewportPosition.x = tonumber(renderViewportPosition.x)
            renderViewportPosition.y = tonumber(renderViewportPosition.y)

            if renderViewportPosition.x == nil or renderViewportPosition.y == nil or (renderViewportPosition.x == nil and renderViewportPosition.y == nil) then
                error(errorHead.."Argument 'params.renderViewportPosition' is missing key 'x' and/or 'y'. Their value must be number or string.")
            end

            component:SetRenderViewportPosition(renderViewportPosition.x, renderViewportPosition.y)
        end

        -- renderViewportSize
        if params.renderViewportSize ~= nil then
            local renderViewportSize = params.renderViewportSize
            
            if type(renderViewportSize) ~= "table" then
                error(errorHead.."Argument 'params.renderViewportSize' is of type '"..type(params.renderViewportSize).."' with value '"..tostring(params.renderViewportSize).." instead of 'table'.")
            end

            renderViewportSize.width = tonumber(renderViewportSize.width)
            renderViewportSize.height = tonumber(renderViewportSize.height)

            if renderViewportSize.width == nil or renderViewportSize.height == nil or (renderViewportSize.width == nil and renderViewportSize.height == nil) then
                error(errorHead.."Argument 'params.renderViewportSize' is missing key 'width' and/or 'height'. Their value must be number or string.")
            end

            component:SetRenderViewportSize(renderViewportSize.width, renderViewportSize.height)
        end
    end
    ]]
