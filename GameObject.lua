
-- DEPENDENCIES : table.join(), table.containsvalue()
local gameObjectCallSyntaxError = "Function not called from a gameObject. Your must use a colon ( : ) between the gameObject and the method name. Ie : self.gameObject:"


-- Create new gameObject 

-- Apply the content of params to the gameObject in argument.
local function ApplyParamsToGameObject(go, params, errorHead)
    if params == nil then 
        return go 
    end

    if params.parent ~= nil then
        local parent = params.parent

        if type(parent) == "string" then
            parent = GameObject.Get(parent)

            if parent == nil then
                error(errorHead.."Argument 'params.parent' with value '"..params.parent.."' does not match any gameObject.")
            end
        end

        if type(params.parentKeepLocalTransm) == "boolean" then
            go:SetParent(parent, params.keepLocalTransform)
        else
            go:SetParent(parent)
        end
    end

    local argType = nil

    if params.transform ~= nil then
        --  position
        if params.transform.position ~= nil then
            argType = type(params.transform.position)
            if argType ~= "table" then
                error(errorHead.."Argument 'params.transform.position' is of type '"..argType.."' with value '"..tostring(params.transform.position).."' instead of 'table' (Vector3).")
            end

            go.transform:SetPosition(params.transform.position)
        end

        if params.transform.localPosition ~= nil then
            argType = type(params.transform.localPosition)
            if argType ~= "table" then
                error(errorHead.."Argument 'params.transform.localPosition' is of type '"..argType.."' with value '"..tostring(params.transform.localPosition).."' instead of 'table' (Vector3).")
            end

            go.transform:SetLocalPosition(params.transform.localPosition)
        end

        -- orientation
        if params.transform.orientation ~= nil then
            argType = type(params.transform.orientation)
            if argType ~= "table" then
                error(errorHead.."Argument 'params.transform.orientation' is of type '"..argType.."' with value '"..tostring(params.transform.orientation).."' instead of 'table' (Quaternion).")
            end

            go.transform:SetOrientation(params.transform.orientation)
        end

        if params.transform.localOrientation ~= nil then
            argType = type(params.transform.localOrientation)
            if argType ~= "table" then
                error(errorHead.."Argument 'params.transform.localOrientation' is of type '"..argType.."' with value '"..tostring(params.transform.localOrientation).."' instead of 'table' (Quaternion).")
            end

            go.transform:SetLocalOrientation(params.transform.localOrientation)
        end

        -- Euler Angles
        if params.transform.eulerAngles ~= nil then
            argType = type(params.transform.eulerAngles)
            if argType ~= "table" then
                error(errorHead.."Argument 'params.transform.eulerAngles' is of type '"..argType.."' with value '"..tostring(params.transform.eulerAngles).."' instead of 'table' (Vector3).")
            end

            go.transform:SetEulerAngles(params.transform.eulerAngles)
        end

        if params.transform.localEulerAngles ~= nil then
            argType = type(params.transform.localEulerAngles)
            if argType ~= "table" then
                error(errorHead.."Argument 'params.transform.localEulerAngles' is of type '"..argType.."' with value '"..tostring(params.transform.localEulerAngles).."' instead of 'table' (Vector3).")
            end

            go.transform:SetLocalEulerAngles(params.transform.localEulerAngles)
        end

        -- scale
        if params.transform.localScale ~= nil then
            if type(params.transform.localScale) == "number" then
                params.transform.localScale = Vector3:New(params.transform.localScale)
            end

            argType = type(params.transform.localScale)
            if argType ~= "table" then
                error(errorHead.."Argument 'params.transform.localScale' is of type '"..argType.."' with value '"..tostring(params.transform.localScale).."' instead of 'table' (Vector3).")
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
        if argType ~= "string" and argType ~= "table" then
            error(errorHead.."Item n°"..i.." in argument 'params.scriptedBehaviors' is of type '"..argType.."' with value '"..tostring(scriptNameOrAsset).."' instead of 'string' or 'table'.")
        end

        go:AddComponent("ScriptedBehavior", scriptNameOrAsset)
    end 

    return go
end

-- Create a new gameObject with optional initialisation parameters.
-- @param name (string) The GameObject name.
-- @param params (string or table) The parent gameObject The initialisation parameters.
-- @return The new gameObject (GameObject).
function GameObject.New(name, params, g)
    if name == GameObject then
        name = params
        params = g
    end

    -- errors
    local errorHead = "GameObject.New(name[, params]) : "

    local argType = type(name)
    if name == nil or argType ~= "string" then
        error(errorHead.."Argument 'name' is of type '"..argType.."' with value '"..tostring(name).."' instead of 'string'. Must be the gameObject name.")
    end

    if params == nil then params = {} end

    argType = type(params)
    if argType ~= "table" then
        error(errorHead.."Argument 'params' is of type '"..argType.."' with value '"..tostring(params).."' instead of 'table'. This argument is optional but if set, it must be a table.")
    end
    
    --
    local go = CraftStudio.CreateGameObject(name)

    go = ApplyParamsToGameObject(go, params, errorHead)    

    return go
end

-- Add a scene as a new gameObject with optional initialisation parameters.
-- @param goName (string) The gameObject name.
-- @param sceneName (string) The scene name.
-- @param params (table) The initialisation parameters.
-- @return (GameObject) The new gameObject.
function GameObject.Instantiate(goName, sceneName, params, g)
    if goName == GameObject then
        goName = sceneName
        sceneName = params
        params = g
    end

    -- errors
    local errorHead = "GameObject.Instantiate(gameObjectName, sceneName[, params]) : "

    local argType = type(goName)
    if goName == nil or argType ~= "string" then
        error(errorHead.."Argument 'gameObjectName' is of type '"..argType.."' with value '"..tostring(name).."' instead of 'string'. Must be the gameObject name.")
    end

    argType = type(sceneName)
    if sceneName == nil or argType ~= "string" then
        error(errorHead.."Argument 'sceneName' is of type '"..argType.."' with value '"..tostring(sceneName).."' instead of 'string'. Must be the scene name.")
    end

    if params == nil then params = {} end

    argType = type(params)
    if argType ~= "table" then
        error(errorHead.."Argument 'params' is of type '"..argType.."' with value '"..tostring(params).."' instead of 'table'. This argument is optional but if set, it must be a table.")
    end
    
    --
    local go = CraftStudio.Instantiate(goName, sceneName)

    go = ApplyParamsToGameObject(go, params, errorHead) 

    return go
end


-- Alias of CraftStudio.FindGameObject(name).
-- Get the gameObject that has the specified name.
-- @param name (string) The gameObject name.
-- @return (GameObject) The gameObject or nil if none is found.
function GameObject.Get(name, g)
    if name == GameObject then
        name = g
    end

    local argType = type(name)
    if name == nil or argType ~= "string" then
        error("GameObject.Get(gameObjectName) : Argument 'gameObjectName' is of type '"..argType.."' instead of 'string'. Must be the gameObject name.")
    end

    return CraftStudio.FindGameObject(name)
end


-- Set the gameOject's parent. 
-- Optionnaly carry over the gameObject's local transform instead of the global one.
-- @param name (string) The parent name.
-- @param keepLocalTransform [optional] (boolean) Carry over the game object's local transform instead of the global one.
function GameObject:SetParentByName(name, keepLocalTransform)
    local errorHead = "GameObject:SetParentByName(name[, keepLocalTransform]) : "

    if getmetatable(self) ~= GameObject then
        error(errorHead..gameObjectCallSyntaxError.."SetParentByName()")
    end

    local argType = type(name)
    if name == nil or argType ~= "string" then
        error(errorHead.."Argument 'name' is of type '"..argType.."' instead of 'string'. Must the parent gameObject name.")
    end

    argType = type(keepLocalTransform)
    if keepLocalTransform ~= nil and argType ~= "boolean" then
        error(errorHead.."Argument 'keepLocalTransform' is of type '"..argType.."' instead of 'boolean'.")
    end

    --

    local go = GameObject.Get(name)

    if go == nil then
        error(errorHead.."The gameObject name '"..name.."' does not match any gameObject in the scene.")
    end

    self:SetParent(go, keepLocalTransform)
end


-- Alias of GameObject:FindChild().
-- Find the first gameObject's child with the specified name.
-- @param name (string) The child name.
-- @param recursive [optional] (boolean=false) Search for the child in all descendants.
-- @return (GameObject) The child or nil if none is found.
function GameObject:GetChild(name, recursive)
    local errorHead = "GameObject:GetChild(name[, recursive]) : "

    if getmetatable(self) ~= GameObject then
        error(errorHead..gameObjectCallSyntaxError.."GetChild()")
    end

    local argType = type(name)
    if name == nil or argType ~= "string" then
        error(errorHead.."Argument 'name' is of type '"..argType.."' instead of 'string'. Must the child gameObject name.")
    end

    argType = type(recursive)
    if recursive ~= nil and argType ~= "boolean" then
        error(errorHead.."Argument 'recursive' is of type '"..argType.."' instead of 'boolean'.")
    end

    return self:FindChild(name, recursive)
end


-- Get all descendants of the gameObject.
-- @param includeSelf [optional] (boolean=false) Include the gameObject in the children.
-- @return (table) The children.
function GameObject:GetChildrenRecursive(includeSelf)
    local errorHead = "GameObject:GetChildrenRecursive() : "

    if getmetatable(self) ~= GameObject then
        error(errorHead..gameObjectCallSyntaxError.."GetChildrenRecursive()")
    end

    local argType = type(includeSelf)
    if includeSelf ~= nil and argType ~= "boolean" then
        error(errorHead.."Argument 'includeSelf' is of type '"..argType.."' instead of 'boolean'.")
    end

    -- 

    local allChildren = {}

    if includeSelf == true then
        allChildren = {self}
    end

    local selfChildren = self:GetChildren()
    
    for i, child in ipairs(selfChildren) do
        allChildren = table.join(allChildren, child:GetChildrenRecursive(true))
    end

    return allChildren
end


-- Tries to call a method with the specified name on all the scripted behaviors attached to the gameObject
-- or any of its descendants. 
-- The data argument can be nil or a table you want the method to receive as its first (and only) argument.
-- If none of the scripted behaviors attached to the game object or its children have a method matching the specified name, nothing happens. 
-- Uses GameObject:SendMessage() on the gameObject and all children of its children.
-- @param methodName (string) The method name.
-- @param data [optional] (table) The data to pass along the method call.
function GameObject:BroadcastMessage(methodName, data)
    local errorHead = "GameObject:BroadcastMessage(methodName[, data]) : "

    if getmetatable(self) ~= GameObject then
        error(errorHead..gameObjectCallSyntaxError.."BroadcastMessage()")
    end

    local argType = type(methodName)
    if name == nil or argType ~= "string" then
        error(errorHead.."Argument 'name' is of type '"..argType.."' instead of 'string'. Must the method name.")
    end

    argType = type(data)
    if data ~= nil and argType ~= "table" then
        error(errorHead.."Argument 'data' is of type '"..argType.."' instead of 'table'. If set, must be a table.")
    end

    --

    local allChildren = table.join({self}, self:GetChildrenRecursive())

    for i, child in ipairs(allChildren) do
        child:SendMessage(methodName, data)
    end
end


-- Add components

-- Add a component to the gameObject and optionaly set the model, map or script asset.
-- @param componentType (string) The Component type.
-- @param params [optional] (string or table) The Script, Model or Map name or asset, or a table of parameters to initialize the new component with.
-- @return (table) The component.
function GameObject:AddComponent(componentType, params)
    local errorHead = "GameObject:AddComponent(componentType[, params]) : "

    if getmetatable(self) ~= GameObject then 
        error(errorHead..gameObjectCallSyntaxError.."AddComponent()")
    end

    local argType = type(componentType)
    if argType ~= "string" then
        error(errorHead.."Argument 'componentType' is of type '"..argType.."' with value '"..tostring(componentType).."' instead of 'string'. Must the component type.")
    end

    componentType = Daneel.core.CaseProof(componentType, Daneel.config.componentTypes)

    if not table.containsvalue(Daneel.config.componentTypes, componentType) then
        error(errorHead.."Argument 'componentType' ["..componentType.."] is not one of the valid component types : "..table.concat(componentType, ", "))
    end


    if params == nil then params = {} end

    -- params is asset name (script model or map)
    if type(params) == "string" then
        local assetType = Daneel.config.componentTypeToAssetType[componentType]
        local assetName = params
        local asset = Asset.Get(assetName, assetType)
        
        if asset == nil then
            error(errorHead.."Asset not found. Component type='"..componentType.."', asset type='"..assetType.."', asset name='"..assetName.."'.")
        end

        params = { [assetType:lower()] = asset }
    end

    -- params is asset (script model or map)
    if type(params) == "table" then
        local assetType = Asset.GetType(params)

        if assetType ~= nil and table.containsvalue({"string", "model", "map"}, assetType, true) then
            params = { [assetType:lower()] = params }
        end
        -- else : should be a params table
    end


    -- ScriptedBehavior
    if componentType == "ScriptedBehavior" then
        return self:CreateScriptedBehavior(params.script)
    end

    -- other componentTypes
    local component = self:CreateComponent(componentType)

    -- apply params
    if componentType == "ModelRenderer" then
        -- animation
        if params.animation ~= nil then
            local animation = params.animation
            
            if type(animation) == "string" then
                animation = Asset.Get(params.animation, "ModelAnimation")
            end

            if animation == nil or not Asset.IsModelAnimation(animation) then
                error(errorHead.."Argument 'params.animation' ["..tostring(params.animation).."] is not a ModelAnimation asset or name.")
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

            if model == nil or not Asset.IsModel(model) then
                error(errorHead.."Argument 'params.model' of type '"..type(params.model).."' with value '"..tostring(params.model).."' is not a Model asset or name.")
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

            if map == nil or not Asset.IsMap(map) then
                error(errorHead.."Argument 'params.map' of type '"..type(params.map).."' with value '"..tostring(params.map).."' is not a Map asset or name.")
            end

            component:SetMap(map)
        end

        -- TileSet
        if params.tileSet ~= nil then
            local tileSet = params.tileSet
            
            if type(tileSet) == "string" then
                tileSet = Asset.Get(params.tileSet, "TileSet")
            end

            if tileSet == nil or not Asset.IsTileSet(tileSet) then
                error(errorHead.."Argument 'params.tileSet' of type '"..type(params.tileSet).."' with value '"..tostring(params.tileSet).."' is not a TileSet asset or name.")
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
            local renderViewportPosition = params.renderViewportPosition)
            
            if type(renderViewportPosition) ~= "table" then
                error(errorHead.."Argument 'params.renderViewportPosition' is of type '"..type(params.renderViewportPosition).."' with value '"..tostring(params.renderViewportPosition).." instead of 'table'.")
            end

            renderViewportPosition.x = tonumber(renderViewportPosition.x)
            renderViewportPosition.y = tonumber(renderViewportPosition.y)

            if renderViewportPosition.x == nil or renderViewportPosition.y == nil then
                error(errorHead.."Argument 'params.renderViewportPosition' is missing key 'x' and/or 'y'. Their value must be number or string.")
            end

            component:SetRenderViewportPosition(renderViewportPosition.x, renderViewportPosition.y)
        end

        -- renderViewportSize
        if params.renderViewportSize ~= nil then
            local renderViewportSize = params.renderViewportSize)
            
            if type(renderViewportSize) ~= "table" then
                error(errorHead.."Argument 'params.renderViewportSize' is of type '"..type(params.renderViewportSize).."' with value '"..tostring(params.renderViewportSize).." instead of 'table'.")
            end

            renderViewportSize.width = tonumber(renderViewportSize.width)
            renderViewportSize.height = tonumber(renderViewportSize.height)

            if renderViewportSize.width == nil or renderViewportSize.height == nil then
                error(errorHead.."Argument 'params.renderViewportSize' is missing key 'width' and/or 'height'. Their value must be number or string.")
            end

            component:SetRenderViewportSize(renderViewportSize.width, renderViewportSize.height)
        end
    end

    return component
end

-- Add a ScriptedBehavior to the gameObject.
-- @param assetNameOrAsset (string or asset) The script name or asset.
-- @return (table) The component.
function GameObject:AddScriptedBehavior(assetNameOrAsset)
    local errorHead = "GameObject:AddScriptedBehavior(assetNameOrAsset) : "

    if getmetatable(self) ~= GameObject then
        error(errorHead..gameObjectCallSyntaxError.."AddScriptedBehavior()")
    end

    if type(assetNameOrAsset) == nil then
        error(errorHead.."Argument 'assetNameOrAsset' is nil. Must be the script name or the script asset.")
    end

    return self:AddComponent("ScriptedBehavior", assetNameOrAsset)
end

-- Add a ModelRenderer component to the gameObject and optionaly set its model.
-- @param params [optional] (table) The model name or asset, or a table of parameters to initialize the new ModelRenderer with.
-- @return (table) The component.
function GameObject:AddModelRenderer(params)
    local errorHead = "GameObject:AddModelRenderer([params]) : "

    if getmetatable(self) ~= GameObject then
        error(errorHead..gameObjectCallSyntaxError.."AddModelRenderer()")
    end

    return self:AddComponent("ModelRenderer", params)
end

-- Add a MapRenderer to the gameObject.
-- @param params [optional] (table) The map name or asset, or a table of parameters to initialize the new MapRenderer with.
-- @return (table) The component.
function GameObject:AddMapRenderer(params)
    local errorHead = "GameObject:AddMapRenderer([params]) : "

    if getmetatable(self) ~= GameObject then
        error(errorHead..gameObjectCallSyntaxError.."AddMapRenderer()")
    end

    return self:AddComponent("MapRenderer", params)
end


-- Add a Camera component to the gameObject.
-- @param params [optional] (table) A table of parameters to initialize the new camera with.
-- @return (table) The component.
function GameObject:AddCamera(params)
    local errorHead = "GameObject:AddCamera([params]) : "

    if getmetatable(self) ~= GameObject then
        error(errorHead..gameObjectCallSyntaxError.."AddCamera()")
    end

    return self:AddComponent("Camera", params)
end


-- Get components

-- Get the specified ScriptedBehavior instance attached to the gameObject.
-- @param scriptNameOrAsset (string or asset) The script name or asset.
-- @return (ScriptedBehavior) The ScriptedBehavior instance.
function GameObject:GetScriptedBehaviorByName(scriptNameOrAsset)
    local errorHead = "GameObject:GetScriptedBehavior(scriptNameOrAsset) : "

    if getmetatable(self) ~= GameObject then 
        error(errorHead..gameObjectCallSyntaxError.."GetScriptedBehavior()")
    end

    if scriptNameOrAsset == nil then
        error(errorHead.."Argument 'scriptNameOrAsset' is nil. Must be the script name or the script asset")
    end

    if scriptNameOrAsset ~= nil and type(scriptNameOrAsset) == "string" then
        local script = CraftStudio.FindAsset(scriptNameOrAsset, "Script")
        
        if script == nil then
            error(errorHead.."Script asset not found. Script name='"..scriptNameOrAsset.."'")
        end
    end

    return self:GetScriptedBehavior(script)
end

-- Get the first ModelRenderer component attached to the gameObject.
-- @return (ModelRenderer) The ModelRenderer component.
function GameObject:GetModelRenderer()
    local errorHead = "GameObject:GetModelRenderer() : "

    if getmetatable(self) ~= GameObject then 
        error(errorHead..gameObjectCallSyntaxError.."GetModelRenderer()")
    end

    return self:GetComponent("ModelRenderer")
end

-- Get the first MapRenderer component attached to the gameObject.
-- @return (MapRenderer) The MapRenderer component.
function GameObject:GetMapRenderer()
    local errorHead = "GameObject:GetMapRenderer() : "

    if getmetatable(self) ~= GameObject then 
        error(errorHead..gameObjectCallSyntaxError.."GetMapRenderer()")
    end

    return self:GetComponent("MapRenderer")
end

-- Get the first Camera component attached to the gameObject.
-- @return (Camera) The Camera component.
function GameObject:GetCamera()
    local errorHead = "GameObject:GetCamera() : "

    if getmetatable(self) ~= GameObject then 
        error(errorHead..gameObjectCallSyntaxError.."GetCamera()")
    end

    return self:GetComponent("Camera")
end

-- Get the Transform component attached to the gameObject.
-- @return (Transform) The Transform component.
function GameObject:GetTransform()
    local errorHead = "GameObject:GetTransform() : "

    if getmetatable(self) ~= GameObject then 
        error(errorHead..gameObjectCallSyntaxError.."GetTransform()")
    end

    return self:GetComponent("Transform")
end


-- Destroy things

-- Destroy the gameObject
function GameObject:Destroy()
    local errorHead = "GameObject:Destroy() : "

    if getmetatable(self) ~= GameObject then 
        error(errorHead..gameObjectCallSyntaxError.."Destroy()")
    end

    CraftSudio.Destroy(self)
end


-- Destroy a component from the gameObject.
-- Argument 'input' can be the component itself (a table),
-- the component type (a string) (the function will destroy the first component of that type),
-- a script asset (a table) the function will destroy the ScriptedBehavior that uses this Script,
-- the name of a script asset (a string) the function will destroy the ScriptedBehavior that uses the Script asset of the specified name.
-- @param input (mixed) See function description.
-- @param strict [optional] (boolean=false) If true, returns an error when the function can't find the component to destroy.
-- @return (boolean) True if the component has been succesfully destroyed, false otherwise.
function GameObject:DestroyComponent(input, strict)
    local errorHead = "GameObject:DestroyComponent(input) : "

    if getmetatable(self) ~= GameObject then
        error(errorHead..gameObjectCallSyntaxError.."DestroyComponent()")
    end

    local argType = type(input)
    if argType ~= "string" and argType ~= "table" then
        error(errorHead.."Argument 'input' is of type '"..argType.."' instead of 'string' or 'table'. Must be the component itself (a table), the component type (a string), an asset (a table) or an asset name (a string).")
    end

    local argType = type(strict)
    if strict ~= nil and argType ~= "boolean" then
        error(errorHead.."Argument 'strict' is of type '"..argType.."' instead of 'boolean'.")
    end

    if strict == nil then strict = false end

    local component = nil
    local stringError = ""

    -- decide if input is a component or an asset
    if argType == "table" then 
        -- input is a component 
        -- Components have a gameObject and a inner variable
        -- But I find no way to check if the table is actally a component or not, or which component is it
        if input.inner ~= nil and input.gameObject ~= nil then
            component = input    

        -- input is a script asset
        elseif Asset.IsScript(input) then
            component = self:GetScriptedBehavior(input)

            if component == nil then
                stringError = errorHead.."Couldn't find a ScriptedBehavior corresponding to the specified Script asset on this gameObject."
            end

        else
            stringError = errorHead.."Argument 'input' is a table but not a component nor a script asset."
        end

    -- string (component type or script name)
    else 
        input = Daneel.core.CaseProof(input, Daneel.config.componentTypes)

        if table.containsvalue(Daneel.config.componentTypes, input) then
            component = self:GetComponent(input)

            if component == nil then
                stringError = errorHead.."Couldn't find the specified component type '"..input.."' on this gameObject."
            end
        else -- must be a script asset name
            component = self:GetScriptedBehaviorByName(input)

            if component == nil then
                stringError = errorHead.."Argument 'input' ["..input.."] is a string but not a component type nor a script asset name."
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
    return true
end

-- TODO vérifier les instances des component

-- Destroy a ScriptedBehavior form the gameObject.
-- If argument 'scriptNameOrAsset' is set with a script name or a script asset, the function will try to destroy the ScriptedBehavior that use this script.
-- If the argument is not set, it will destroy the first ScriptedBehavior on this gameObejct
-- @param scriptNameOrAsset [optional] (string=nil) The script name or asset.
-- @return (boolean) True if the component has been succesfully destroyed, false otherwise.
function GameObject:DestroyScriptedBehavior(scriptNameOrAsset)
    local errorHead = "GameObject.DestroyScriptedBehavior(scriptNameOrAsset) : "

    if getmetatable(self) ~= GameObject then
        error(errorHead..gameObjectCallSyntaxError.."DestroyScriptedBehavior(scriptNameOrAsset)")
    end

    local argType = type(scriptNameOrAsset)
    if scriptNameOrAsset ~= nil and argType ~= "string" and argType ~= "table" then
        error(errorHead.."Argument 'scriptNameOrAsset' is of type '"..argType.."' instead of 'string' or 'table'.")
    end

    if scriptNameOrAsset == nil then
        return self:DestroyComponent("ScriptedBehavior")
    else
        return self:DestroyComponent(scriptNameOrAsset)
    end
end

-- Destroy the first ModelRenderer form the gameObject.
-- @return (boolean) True if the component has been succesfully destroyed, false otherwise.
function GameObject:DestroyModelRenderer()
    local errorHead = "GameObject.DestroyModelRenderer() : "

    if getmetatable(self) ~= GameObject then
        error(errorHead..gameObjectCallSyntaxError.."DestroyModelRenderer()")
    end

    return self:DestroyComponent(self:GetModelRenderer())
end

-- Destroy the first MapRenderer form the gameObject.
-- @return (boolean) True if the component has been succesfully destroyed, false otherwise.
function GameObject:DestroyMapRenderer()
    local errorHead = "GameObject.DestroyMapRenderer() : "

    if getmetatable(self) ~= GameObject then
        error(errorHead..gameObjectCallSyntaxError.."DestroyMapRenderer()")
    end

    return self:DestroyComponent(self:GetMapRenderer())
end

-- Destroy the first Camera form the gameObject.
-- @return (boolean) True if the component has been succesfully destroyed, false otherwise.
function GameObject:DestroyCamera()
    local errorHead = "GameObject.DestroyCamera() : "

    if getmetatable(self) ~= GameObject then
        error(errorHead..gameObjectCallSyntaxError.."DestroyCamera()")
    end

    return self:DestroyComponent(self:GetCamera())
end

