

function GameObject.__tostring(go)
    -- same story as components
    local id = tostring(go.inner):sub(2,20)
    return "GameObject: '"..go:GetName().."' "..id
end

-- Dynamic properties for Getters and Setters

function GameObject.__index(go, key) 
    local funcName = "Get"..key:ucfirst()
    
    if GameObject[funcName] ~= nil then
        return GameObject[funcName](go)
    elseif GameObject[key] ~= nil then
        return GameObject[key] -- have to return the function here, not the function return value !
    end
    
    return rawget(go, key)
end


function GameObject.__newindex(go, key, value)
    local funcName = "Set"..key:ucfirst()
    -- ie: variable "name" call "SetName"
    
    if GameObject[funcName] ~= nil then
        return GameObject[funcName](go, value)
    end
    
    rawset(go, key, value)
end



----------------------------------------------------------------------------------


local gameObjectCallSyntaxError = "Function not called from a gameObject. Your must use a colon ( : ) between the gameObject and the method name. Ie : self.gameObject:"


-- Create new gameObject 

-- Apply the content of params to the gameObject in argument.
local function ApplyParamsToGameObject(go, params, errorHead)
    Daneel.StackTrace.BeginFunction("ApplyParamsToGameObject", go, params, errorHead)
    
    if params == nil then
        Daneel.StackTrace.EndFunction("ApplyParamsToGameObject", go)
        return go 
    end

    if errorHead == nil then
        errorHead = "ApplyParamsToGameObject(go, params) : "
    end

    local argType = nil

    -- parent
    if params.parent ~= nil then 
        local parentType = cstype(params.parent)
        if parentType ~= "string" and parentType ~= "GameObject" then
            error(errorHead.."Argument 'params.parent' is of type '"..parentType.."' with value '"..tostring(params.parent).."' instead of 'string' (the parent name) or 'GameObject'.")
        end

        if parentType == "string" then
            local parentName = params.parent
            params.parent = GameObject.Get(parentName)
            
            if params.parent == nil then
                error(errorHead.."Argument 'params.parent' : Parent GameObject with name '"..parentName.."' was not found.")
            end

            parentType = "GameObject"
        end

        if parentType == "GameObject" then
            argType = type(params.parentKeepLocalTransform)
            if argType ~= "nil" and argType ~= "boolean" then
                error(errorHead.."Argument 'params.parentKeepLocalTransform' is of type '"..argType.."' with value '"..tostring(params.parentKeepLocalTransform).."' instead of 'boolean'.")
            end

            go:SetParent(params.parent, params.parentKeepLocalTransform)
        end
    end

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
                go:AddComponent("ModelRenderer")
            end
        else
            if argType ~= "string" and argType ~= "table" then
                error(errorHead.."Argument 'params.modelRenderer' is of type '"..argType.."' with value '"..tostring(params.modelRenderer).."' instead of 'string' or 'table'.")
            end

            go:AddComponent("ModelRenderer", params.modelRenderer)
        end
    end

    if params.mapRenderer ~= nil then
        argType = type(params.mapRenderer)

        if argType == "boolean" then
            if params.mapRenderer == true then
                go:AddComponent("MapRenderer")
            end
        else
            if argType ~= "string" and argType ~= "table" then
                error(errorHead.."Argument 'params.mapRenderer' is of type '"..argType.."' with value '"..tostring(params.mapRenderer).."' instead of 'string' or 'table'.")
            end

            go:AddComponent("MapRenderer", params.mapRenderer)
        end
    end

    if params.camera ~= nil then
        argType = type(params.camera)

        if argType == "boolean" then
            if params.camera == true then
                go:AddComponent("Camera")
            end
        else
            if argType ~= "string" and argType ~= "table" then
                error(errorHead.."Argument 'params.camera' is of type '"..argType.."' with value '"..tostring(params.camera).."' instead of 'string' or 'table'.")
            end

            go:AddComponent("Camera", params.camera)
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

        go:AddComponent("ScriptedBehavior", scriptNameOrAsset)
    end 

    Daneel.StackTrace.EndFunction("ApplyParamsToGameObject", go)
    return go
end

-- Create a new gameObject with optional initialisation parameters.
-- @param name (string) The GameObject name.
-- @param params (string, GameObject or table) The parent gameObject name, or parent GameObject or a table with parameters to initialize the new gameObject with.
-- @return (GameObject) The new gameObject.
function GameObject.New(name, params)
    Daneel.StackTrace.BeginFunction("GameObject.New", name, params)
    local errorHead = "GameObject.New(name[, params]) : "

    local argType = type(name)
    if name == nil or argType ~= "string" then
        error(errorHead.."Argument 'name' is of type '"..argType.."' with value '"..tostring(name).."' instead of 'string'. Must be the gameObject name.")
    end

    local go = CraftStudio.CreateGameObject(name)
    go = ApplyParamsToGameObject(go, params, errorHead)

    Daneel.StackTrace.EndFunction("GameObject.New", go)
    return go
end

-- Add a scene as a new gameObject with optional initialisation parameters.
-- @param goName (string) The gameObject name.
-- @param scene (string or Scene) The scene name or scene asset.
-- @param params [optional default=nil] (string, GameObject or table) The parent gameObject name, or parent GameObject or a table with parameters to initialize the new gameObject with.
-- @return (GameObject) The new gameObject.
function GameObject.Instantiate(goName, scene, params)
    Daneel.StackTrace.BeginFunction("GameObject.Instantiate", goName, scene, params)
    local errorHead = "GameObject.Instantiate(gameObjectName, sceneName[, params]) : "

    local argType = type(goName)
    if argType ~= "string" then
        error(errorHead.."Argument 'gameObjectName' is of type '"..argType.."' with value '"..tostring(name).."' instead of 'string'. Must be the gameObject name.")
    end

    argType = cstype(scene)
    if argType ~= "string" or argType ~= "Scene" then
        error(errorHead.."Argument 'scene' is of type '"..argType.."' with value '"..tostring(scene).."' instead of 'string' (the scene name) or 'Scene'.")
    end

    if argType == "string" then
        local sceneName = scene
        scene = Asset.Get(sceneName, "Scene")

        if scene == nil then
            error(errorHead.."Argument 'scene' : Scene asset with name '"..sceneName.."' was not found.")
        end
    end
    
    local go = CraftStudio.Instantiate(goName, sceneName)
    go = ApplyParamsToGameObject(go, params, errorHead)

    Daneel.StackTrace.EndFunction("GameObject.Instantiate", go)
    return go
end



----------------------------------------------------------------------------------
-- Miscellaneous


-- Alias of CraftStudio.FindGameObject(name).
-- Get the first gameObject with the specified name.
-- @param name (string) The gameObject name.
-- @return (GameObject) The gameObject or nil if none is found.
function GameObject.Get(name)
    Daneel.StackTrace.BeginFunction("GameObject.Get", name)

    local argType = type(name)
    if name == nil or argType ~= "string" then
        error("GameObject.Get(name) : Argument 'name' is of type '"..argType.."' with value '"..tostring(name).."' instead of 'string'. Must be the gameObject name.")
    end

    local go = CraftStudio.FindGameObject(name)

    Daneel.StackTrace.EndFunction("GameObject.Get", go)
    return go
end


local OriginalSetParent = GameObject.SetParent

-- Set the gameOject's parent. 
-- Optionnaly carry over the gameObject's local transform instead of the global one.
-- @param gameObject (GameObject) The gameObject
-- @param parentNameOrObject (string or GameObject) The parent name or GameObject.
-- @param keepLocalTransform [optional default=false] (boolean) Carry over the game object's local transform instead of the global one.
function GameObject.SetParent(go, parentNameOrObject, keepLocalTransform)
    Daneel.StackTrace.EndFunction("GameObject.SetParent", go, parentNameOrObject, keepLocalTransform)
    local errorHead = "GameObject.SetParent(gameObject, parentNameOrObject[, keepLocalTransform]) : "

    local argType = cstype(go)
    if argType ~= "GameObject" then
        error(errorHead.."Argument 'gameObject' is of type '"..argType.."' with value '"..tostring(parentNameOrObject).."' instead of 'GameObject'.")
    end

    argType = cstype(parentNameOrObject)
    if argType ~= "string" and argType ~= "GameObject" then
        error(errorHead.."Argument 'parentNameOrObject' is of type '"..argType.."' with value '"..tostring(parentNameOrObject).."' instead of 'string' or 'GameObject'. Must the parent gameObject name or GameObject.")
    end

    argType = type(keepLocalTransform)
    if argType ~= "nil" and argType ~= "boolean" then
        error(errorHead.."Argument 'keepLocalTransform' is of type '"..argType.."' with value '"..tostring(keepLocalTransform).."' instead of 'boolean'.")
    end
    
    if keepLocalTransform == nil then
        keepLocalTransform = false
    end

    local parent = parentNameOrObject

    if type(parent) == "string" then
        parent = GameObject.Get(parentNameOrObject)

        if parent == nil then
            error(errorHead.."Argument 'parentNameOrObject' : Parent GameObject with name '"..parentNameOrObject.."' was not found.")
        end
    end
      
    OriginalSetParent(go, parent, keepLocalTransform)
    Daneel.StackTrace.EndFunction("GameObject.SetParent")
end


-- Alias of GameObject:FindChild().
-- Find the first gameObject's child with the specified name.
-- @param gameObject (GameObject) The gameObject
-- @param name (string) The child name.
-- @param recursive [optional default=false] (boolean) Search for the child in all descendants.
-- @return (GameObject) The child or nil if none is found.
function GameObject.GetChild(go, name, recursive)
    Daneel.StackTrace.BeginFunction("GameObject.GetChild", go, name, recursive)
    local errorHead = "GameObject.GetChild(gameObject, name[, recursive]) : "

    local argType = cstype(go)
    if argType ~= "GameObject" then
        error(errorHead.."Argument 'gameObject' is of type '"..argType.."' with value '"..tostring(parentNameOrObject).."' instead of 'GameObject'.")
    end

    argType = type(name)
    if argType ~= "string" then
        error(errorHead.."Argument 'name' is of type '"..argType.."' with value '"..tostring(name).."' instead of 'string'. Must the child gameObject name.")
    end

    argType = type(recursive)
    if recursive ~= nil and argType ~= "boolean" then
        error(errorHead.."Argument 'recursive' is of type '"..argType.."' with value '"..tostring(recursive).."' instead of 'boolean'.")
    end

    local child = go:FindChild(name, recursive)

    Daneel.StackTrace.EndFunction("GameObject.GetChild", child)
    return child
end


local OriginalGetChildren = GameObject.GetChildren

-- Get all descendants of the gameObject.
-- @param gameObject (GameObject) The gameObject
-- @param recursive [optional default=false] (boolean) Look for all descendants instead of just the first generation
-- @param includeSelf [optional default=false] (boolean) Include the gameObject in the children.
-- @return (table) The children.
function GameObject.GetChildren(go, recursive, includeSelf)
    Daneel.StackTrace.BeginFunction("GameObject.GetChildren", go, recursive, includeSelf)
    local errorHead = "GameObject.GetChildrenRecursive(gameObject, [recursive]) : "

    local argType = cstype(go)
    if argType ~= "GameObject" then
        error(errorHead.."Argument 'gameObject' is of type '"..argType.."' with value '"..tostring(parentNameOrObject).."' instead of 'GameObject'.")
    end

    argType = type(recursive)
    if recursive ~= nil and argType ~= "boolean" then
        error(errorHead.."Argument 'recursive' is of type '"..argType.."' with value '"..tostring(includeSelf).."' instead of 'boolean'.")
    end

    argType = type(includeSelf)
    if includeSelf ~= nil and argType ~= "boolean" then
        error(errorHead.."Argument 'includeSelf' is of type '"..argType.."' with value '"..tostring(includeSelf).."' instead of 'boolean'.")
    end

    local allChildren = table.new()
    
    if includeSelf == true then
        allChildren = table.new({go})
    end

    local selfChildren = OriginalGetChildren(go)
    
    if recursive == true then
        -- get the rest of the children
        for i, child in ipairs(selfChildren) do
            allChildren = table.join(allChildren, child:GetChildren(true, true))
        end
    else
        allChildren = allChildren:join(selfChildren)
    end

    Daneel.StackTrace.EndFunction("GameObject.GetChildren", allChildren)
    return allChildren
end


-- Tries to call a method with the specified name on all the scripted behaviors attached to the gameObject
-- or any of its descendants. 
-- The data argument can be nil or a table you want the method to receive as its first (and only) argument.
-- If none of the scripted behaviors attached to the game object or its children have a method matching the specified name, nothing happens. 
-- Uses GameObject:SendMessage() on the gameObject and all children of its children.
-- @param gameObject (GameObject) The gameObject
-- @param methodName (string) The method name.
-- @param data [optional] (table) The data to pass along the method call.
function GameObject.BroadcastMessage(go, methodName, data)
    Daneel.StackTrace.BeginFunction("GameObject.BroadcastMessage", go, methodName, data)
    local errorHead = "GameObject.BroadcastMessage(gameObject, methodName[, data]) : "

    Daneel.Debug.CheckArgType(go, "gameObject", "GameObject", errorHead)
    Daneel.Debug.CheckArgType(methodName, "methodName", "string", errorHead)
    Daneel.Debug.CheckOptionalArgType(data, "data", "table", errorHead)

    local allChildren = table.join({go}, go:GetChildren())

    for i, child in ipairs(allChildren) do
        child:SendMessage(methodName, data)
    end

    Daneel.StackTrace.EndFunction("GameObject.BroadcastMessage")
end



----------------------------------------------------------------------------------
-- Add components


-- Add a component to the gameObject and optionaly initialize it.
-- @param gameObject (GameObject) The gameObject
-- @param componentType (string) The Component type.
-- @param params [optional] (string, Script, Model, Map or table) The Script, Model or Map name or asset, or a table of parameters to initialize the new component with.
-- @return (ScriptedBehavior, Model, Map or Camera) The component .
function GameObject.AddComponent(go, componentType, params)
    Daneel.StackTrace.BeginFunction("GameObject.AddComponent")
    local errorHead = "GameObject.AddComponent(gameObject, componentType[, params]) : "

    Daneel.Debug.CheckArgType(go, "gameObject", "GameObject", errorHead)
    Daneel.Debug.CheckArgType(componentType, "componentType", "string", errorHead)
    
    componentType = Daneel.Utilities.CaseProof(componentType, Daneel.config.componentTypes)

    if not table.containsvalue(Daneel.config.componentTypes, componentType) then
        error(errorHead.."Argument 'componentType' with value '"..componentType.."' is not one of the valid component types : "..table.concat(componentType, ", "))
    end

    if params == nil then params = {} end
    argType = cstype(params)

    -- params is the asset name (script, model or map)
    if argType == "string" then
        local assetType = Daneel.config.componentTypeToAssetType[componentType]
        local assetName = params
        local asset = Asset.Get(assetName, assetType)
        
        if asset == nil then
            error(errorHead.."Asset not found. Component type='"..componentType.."', asset type='"..assetType.."', asset name='"..assetName.."'.")
        end

        params = { [assetType:lower()] = asset }
    end

    -- params is an asset (script model or map)
    if table.containsvalue({"Script", "Model", "Map"}, argType) then
        params = { [argType:lower()] = params }
    end
    -- else : should be a params table


    -- ScriptedBehavior
    if componentType == "ScriptedBehavior" then
        if params.script == nil then
            error(errorHead.."Argument 'componentType' is 'ScriptedBehavior' but argument 'params.script' is nil.")
        end
        
        return go:CreateScriptedBehavior(params.script)
    end

    -- other componentTypes
    local component = go:CreateComponent(componentType)


    -- apply params
    if componentType == "ModelRenderer" then
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

    Daneel.StackTrace.EndFunction("GameObject.AddComponent")
    return component
end

-- Add AddComponent helpers
-- ie : go:AddModelRenderer()
local function CreateAddComponentHelpers()
    for i, componentType in ipairs(Daneel.config.componentTypes) do
        if componentType ~= "Transform" then
            
            GameObject["Add"..componentType] = function(go, params)
                Daneel.StackTrace.BeginFunction("GameObject.Add"..componentType, go, params)
                local errorHead = "GameObject.Add"..componentType.."(gameObject[, params]) : "
                
                Daneel.Debug.CheckArgType(go, "gameObject", "GameObject", errorHead)

                local component = go:AddComponent(componentType, params)
                Daneel.StackTrace.EndFunction("GameObject.Add"..componentType)
                return component
            end

        end
    end
end



----------------------------------------------------------------------------------
-- Get components


local OriginalGetScriptedBehavior = GameObject.GetScriptedBehavior

-- Get the specified ScriptedBehavior instance attached to the gameObject.
-- @param gameObject (GameObject) The gameObject
-- @param scriptNameOrAsset (string or Script) The script name or asset.
-- @return (ScriptedBehavior) The ScriptedBehavior instance.
function GameObject.GetScriptedBehavior(go, scriptNameOrAsset)
    Daneel.StackTrace.BeginFunction("GameObject.GetScriptedBehavior", go, scriptNameOrAsset)
    local errorHead = "GameObject.GetScriptedBehavior(gameObject, scriptNameOrAsset) : "

    Daneel.Debug.CheckArgType(go, "gameObject", "GameObject", errorHead)

    local argType = cstype(scriptNameOrAsset)
    if argType ~= "string" and argType ~= "Script" then
        error(errorHead.."Argument 'scriptNameOrAsset' is of type '"..argType.."' with value '"..tostring(scriptNameOrAsset).."' instead of 'string' (the Script name) or 'Script'.")
    end

    local script = scriptNameOrAsset

    if argType == "string" then
        script = Asset.Get(scriptNameOrAsset, "Script")
        
        if script == nil then
            error(errorHead.."Argument 'scriptNameOrAsset' : Script asset with name '"..scriptNameOrAsset.."' was not found.")
        end
    end

    local component = OriginalGetScriptedBehavior(go, script)
    Daneel.StackTrace.EndFunction("GameObject.GetScriptedBehavior", component)
    return component
end

-- Add GetComponent helpers
-- ie : go:GetModelRenderer()
local function CreateGetComponentHelpers()
    for i, componentType in ipairs(Daneel.config.componentTypes) do
        if componentType ~= "ScriptedBehavior" then

            GameObject["Get"..componentType] = function(go)
                Daneel.StackTrace.BeginFunction("GameObject.Get"..componentType, go)
                local errorHead = "GameObject.Get"..componentType.."(gameObject) : "
                
                Daneel.Debug.CheckArgType(go, "gameObject", "GameObject", errorHead)

                local component = go:GetComponent(componentType)
                Daneel.StackTrace.EndFunction("GameObject.Get"..componentType)
                return component
            end

        end
    end
end



----------------------------------------------------------------------------------
-- Has component


-- Check if the gameObject has the specified component.
-- @param gameObject (GameObject) The gameObject
-- @param componentType (string) The Component type.
-- @return (boolean) True if the gameObject has the component, false otherwise
function GameObject.HasComponent(go, componentType)
    Daneel.StackTrace.BeginFunction("GameObject.HasComponent", go, componentType)
    local errorHead = "GameObject.HasComponent(gameObject, componentType) : "

    Daneel.Debug.CheckArgType(go, "gameObject", "GameObject", errorHead)
    Daneel.Debug.CheckArgType(componentType, "componentType", "string", errorHead)

    local componentTypes = Daneel.config.componentTypes
    componentType = Daneel.Utilities.CaseProof(componentType, componentTypes)

    if not componentType:isOneOf(componentTypes) then
        error(errorHead.."Argument 'componentType' with value '"..componentType.."' is not one of the valid component types : "..table.concat(componentTypes, ", "))
    end

    local hasComponent = (go:GetComponent(componentType) ~= nil)
    Daneel.StackTrace.EndFunction("GameObject.HasComponent", hasComponent)
    return hasComponent
end

-- Add GetComponent helpers
-- ie : go:GetModelRenderer()
local function CreateHasComponentHelpers()
    for i, componentType in ipairs(Daneel.config.componentTypes) do
        
        GameObject["Has"..componentType] = function(go)
            Daneel.StackTrace.BeginFunction("GameObject.Has"..componentType, go)
            local errorHead = "GameObject.Has"..componentType.."(gameObject) : "
            
            Daneel.Debug.CheckArgType(go, "gameObject", "GameObject", errorHead)

            local hasComponent = go:HasComponent(componentType)
            Daneel.StackTrace.EndFunction("GameObject.Has"..componentType, hasComponent)
            return hasComponent
        end

    end
end



----------------------------------------------------------------------------------
-- Destroy gameObjects and components


-- Destroy the gameObject
-- @param gameObject (GameObject) The gameObject
function GameObject.Destroy(go)
    Daneel.StackTrace.BeginFunction("GameObject.Destroy", go)
    local errorHead = "GameObject.Destroy(gameObject) : "
    
    Daneel.Debug.CheckArgType(go, "gameObject", "GameObject", errorHead)
    
    CraftSudio.Destroy(go)
    Daneel.StackTrace.EndFunction("GameObject.Destroy")
end


-- Destroy a component from the gameObject.
-- Argument 'input' can be :
-- the component type (string) (the function will destroy the first component of that type), 
-- the component itself (ScriptedBehavior, Model, Map or Camera),
-- or a script name or asset (string or Script) (the function will destroy the ScriptedBehavior that uses this Script),
-- 
-- @param gameObject (GameObject) The gameObject
-- @param input (mixed) See function description.
-- @param strict [optional default=false] (boolean) If true, returns an error when the function can't find the component to destroy.
-- @return (boolean) True if the component has been succesfully destroyed, false otherwise.
function GameObject.DestroyComponent(go, input, strict)
    Daneel.StackTrace.BeginFunction("GameObject.DestroyComponent", go, input, strict)
    local errorHead = "GameObject.DestroyComponent(gameObject, input[, strict]) : "

    Daneel.Debug.CheckArgType(go, "gameObject", "GameObject", errorHead)

    local argType = cstype(input)
    local allowedTypes = {"string", "Script", "table"}
    
    if not argType:IsOneOf(allowedTypes) then
        error(errorHead.."Argument 'input' is of type '"..argType.."' with value '"..tostring(input).."' instead of '"..table.concat(allowedTypes, "', '").."'.")
    end

    Daneel.Debug.CheckOptionalArgType(strict, "strict", "boolean", errorHead)

    if strict == nil then strict = false end

    local component = nil
    local stringError = ""
    --argType = cstype(input)

    -- input is a component ?
    if argType == "table" then 
        -- Components have a gameObject and a inner variable
        -- But I found no way to check if the table is actally a component or not, or which component is it
        -- because the metatable on components is hidden
        if input.inner ~= nil and input.gameObject ~= nil then
            component = input    
        else
            stringError = errorHead.."Argument 'input' is of type 'table' with value '"..tostring(input).."' but not a component."
        end

    -- input is a script asset
    elseif argType == "Script" then
        component = go:GetScriptedBehavior(input)

        if component == nil then
            stringError = errorHead.."Argument 'input' : Couldn't find a ScriptedBehavior corresponding to the specified Script asset on this gameObject."
        end

    -- string (component type or script name)
    elseif argType == "string" then
        input = Daneel.Utilities.CaseProof(input, Daneel.config.componentTypes)

        -- component type
        if table.containsvalue(Daneel.config.componentTypes, input) then
            component = go:GetComponent(input)

            if component == nil then
                stringError = errorHead.."Argument 'input' : Couldn't find the specified component type '"..input.."' on this gameObject."
            end

        -- or script name
        else 
            component = go:GetScriptedBehaviorByName(input)

            if component == nil then
                stringError = errorHead.."Argument 'input' with value '"..input.."' is a string but not a component type nor a script asset name."
            end
        end
    end

    if component == nil then
        if stringError == "" then
            stringError = errorHead.."Couldn't find the component to destroy on this gameObject."
        end
        
        if strict then
            error(stringError)
        else
            print(stringError)
            return false
        end
    end

    CraftStudio.Destroy(component)
    Daneel.StackTrace.EndFunction("GameObject.DestroyComponent", true)
    return true
end

-- TODO vérifier les instances des component

-- Destroy a ScriptedBehavior form the gameObject.
-- If argument 'scriptNameOrAsset' is set with a script name or a script asset, the function will try to destroy the ScriptedBehavior that use this script.
-- If the argument is not set, it will destroy the first ScriptedBehavior on this gameObejct
-- @param gameObject (GameObject) The gameObject
-- @param scriptNameOrAsset [optional] (string or Script) The script name or asset.
-- @return (boolean) True if the component has been succesfully destroyed, false otherwise.
function GameObject.DestroyScriptedBehavior(go, scriptNameOrAsset)
    Daneel.StackTrace.BeginFunction("GameObject.DestroyScriptedBehavior", go, scriptNameOrAsset)
    local errorHead = "GameObject.DestroyScriptedBehavior(go[, scriptNameOrAsset]) : "

    Daneel.Debug.CheckArgType(go, "gameObject", "GameObject", errorHead)

    local argType = cstype(scriptNameOrAsset)
    if argType ~= "nil" and argType ~= "string" and argType ~= "Script" then
        error(errorHead.."Optional argument 'scriptNameOrAsset' is of type '"..argType.."' with value '"..tostring(scriptNameOrAsset).."' instead of 'string' or 'Script'.")
    end

    if scriptNameOrAsset == nil then
        scriptNameOrAsset = "ScriptedBehavior"
    end
    
    go:DestroyComponent(scriptNameOrAsset)
    Daneel.StackTrace.EndFunction("GameObject.DestroyScriptedBehavior")
end

-- Add DestroyComponent helpers
-- ie : go:DestroyModelRenderer()
local function CreateDestroyComponentHelpers()
    for i, componentType in ipairs(Daneel.config.componentTypes) do
        if componentType ~= "Transform" or componentType ~= "ScriptedBehavior" then

            GameObject["Destroy"..componentType] = function(go)
                Daneel.StackTrace.BeginFunction("GameObject.Destroy"..componentType, go)
                local errorHead = "GameObject.Destroy"..componentType.."(gameObject) : "
                
                Daneel.Debug.CheckArgType(go, "gameObject", "GameObject", errorHead)

                go:DestroyComponent(componentType)
                Daneel.StackTrace.EndFunction("GameObject.Destroy"..componentType)
            end

        end
    end
end



----------------------------------------------------------------------------------

function GameObject.Init()
    CreateAddComponentHelpers()
    CreateGetComponentHelpers()
    CreateHasComponentHelpers()
    CreateDestroyComponentHelpers()
end

