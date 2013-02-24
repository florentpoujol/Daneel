
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



function Component.New(gameObject, componentType, params)

end

function Component.Set(component, params)

    -- transform
    if params.transform ~= nil then
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
end

