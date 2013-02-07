
-- DEPENDENCIES : table.join(), table.containsvalue()
local gameObjectCallSyntaxError = "Function not called from a gameObject. Your must use a colon ( : ) between the gameObject and the method name. Ie : self.gameObject:"


-- Create new gameObject 

-- Apply the content of params to the gameObject in argument.
local function ApplyParamsToGameObject(go, params, errorHead)
    if params == nil then 
        return go 
    end

    if errorHead == nil then
        errorHead = "ApplyParamsToGameObject(go, params) : "
    end

    local argType = nil

    -- parent
    if params.parent == nil then 
        local parentType = cstype(params.parent)
        if parentType ~= "string" and parentType ~= "GameObject" then
            error(errorHead.."Argument 'params.parent' is of type '"..parentType.."' with value '"..tostring(params.parent).."' instead of 'string' (the parent name) or 'GameObject'.")
        end

        if parentType == "string" then
            local parentName = params.parent
            local params.parent = GameObject.Get(parentName)
            
            if params.parent == nil then
                error(errorHead.."Argument 'params.parent' : Parent GameObject with name '"..parentName.."' was not found.")
            end

            parentType = "GameObject"
        end

        if parentType == "GameObject" then
            argType = type(params.parentKeepLocalTransform)
            if argType ~= nil and argType ~= "boolean" then
                error(errorHead.."Argument 'params.parentKeepLocalTransform' is of type '"..argType.."' with value '"..tostring(params.parentKeepLocalTransform).."' instead of 'boolean'.")
            end

            go:SetParent(parent, params.parentKeepLocalTransform)
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
        argType = cstype(scriptNameOrAsset)
        if argType ~= "string" and argType ~= "Script" then
            error(errorHead.."Item n°"..i.." in argument 'params.scriptedBehaviors' is of type '"..argType.."' with value '"..tostring(scriptNameOrAsset).."' instead of 'string' or 'table/Script'.")
        end

        go:AddComponent("ScriptedBehavior", scriptNameOrAsset)
    end 

    return go
end

-- Create a new gameObject with optional initialisation parameters.
-- @param name (string) The GameObject name.
-- @param params (string, GameObject or table) The parent gameObject name, or parent GameObject or a table with parameters to initialize the new gameObject with.
-- @return (GameObject) The new gameObject.
function GameObject.New(name, params, g)
    if name == GameObject then
        name = params
        params = g
    end

    local errorHead = "GameObject.New(name[, params]) : "

    local argType = type(name)
    if name == nil or argType ~= "string" then
        error(errorHead.."Argument 'name' is of type '"..argType.."' with value '"..tostring(name).."' instead of 'string'. Must be the gameObject name.")
    end

    local go = CraftStudio.CreateGameObject(name)

    return ApplyParamsToGameObject(go, params, errorHead)
end

-- Add a scene as a new gameObject with optional initialisation parameters.
-- @param goName (string) The gameObject name.
-- @param scene (string or Scene) The scene name or scene asset.
-- @param params [optional default=nil] (string, GameObject or table) The parent gameObject name, or parent GameObject or a table with parameters to initialize the new gameObject with.
-- @return (GameObject) The new gameObject.
function GameObject.Instantiate(goName, scene, params, g)
    if goName == GameObject then
        goName = sceneName
        sceneName = params
        params = g
    end

    -- errors
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

    return ApplyParamsToGameObject(go, params, errorHead)
end


-- Alias of CraftStudio.FindGameObject(name).
-- Get the first gameObject with the specified name.
-- @param name (string) The gameObject name.
-- @return (GameObject) The gameObject or nil if none is found.
function GameObject.Get(name, g)
    if name == GameObject then
        name = g
    end

    local argType = type(name)
    if name == nil or argType ~= "string" then
        error("GameObject.Get(gameObjectName) : Argument 'gameObjectName' is of type '"..argType.."' with value '"..tostring(name).."' instead of 'string'. Must be the gameObject name.")
    end

    return CraftStudio.FindGameObject(name)
end


-- Set the gameOject's parent by name. 
-- Optionnaly carry over the gameObject's local transform instead of the global one.
-- @param name (string) The parent name.
-- @param keepLocalTransform [optional default=false] (boolean) Carry over the game object's local transform instead of the global one.
function GameObject:SetParentByName(name, keepLocalTransform)
    local errorHead = "GameObject:SetParentByName(name[, keepLocalTransform]) : "

    if cstype(self) ~= "GameObject" then
        error(errorHead..gameObjectCallSyntaxError.."SetParentByName()")
    end

    local argType = type(name)
    if argType ~= "string" then
        error(errorHead.."Argument 'name' is of type '"..argType.."' with value '"..tostring(name).."' instead of 'string'. Must the parent gameObject name.")
    end

    argType = type(keepLocalTransform)
    if argType ~= nil and argType ~= "boolean" then
        error(errorHead.."Argument 'keepLocalTransform' is of type '"..argType.."' with value '"..tostring(keepLocalTransform).."' instead of 'boolean'.")
    end

    local parent = GameObject.Get(name)

    if parent == nil then
        error(errorHead.."Argument 'name' : Parent GameObject with name '"..name.."' was not found.")
    end

    self:SetParent(go, keepLocalTransform)
end


-- Alias of GameObject:FindChild().
-- Find the first gameObject's child with the specified name.
-- @param name (string) The child name.
-- @param recursive [optional default=false] (boolean) Search for the child in all descendants.
-- @return (GameObject) The child or nil if none is found.
function GameObject:GetChild(name, recursive)
    local errorHead = "GameObject:GetChild(name[, recursive]) : "

    if cstype(self) ~= "GameObject" then
        error(errorHead..gameObjectCallSyntaxError.."GetChild()")
    end

    local argType = type(name)
    if argType ~= "string" then
        error(errorHead.."Argument 'name' is of type '"..argType.."' with value '"..tostring(name).."' instead of 'string'. Must the child gameObject name.")
    end

    argType = type(recursive)
    if recursive ~= nil and argType ~= "boolean" then
        error(errorHead.."Argument 'recursive' is of type '"..argType.."' with value '"..tostring(recursive).."' instead of 'boolean'.")
    end

    return self:FindChild(name, recursive)
end


-- Get all descendants of the gameObject.
-- @param includeSelf [optional default=false] (boolean) Include the gameObject in the children.
-- @return (table) The children.
function GameObject:GetChildrenRecursive(includeSelf)
    local errorHead = "GameObject:GetChildrenRecursive() : "

    if cstype(self) ~= "GameObject" then
        error(errorHead..gameObjectCallSyntaxError.."GetChildrenRecursive()")
    end

    local argType = type(includeSelf)
    if includeSelf ~= nil and argType ~= "boolean" then
        error(errorHead.."Argument 'includeSelf' is of type '"..argType.."' with value '"..tostring(includeSelf).."' instead of 'boolean'.")
    end

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

    if cstype(self) ~= "GameObject" then
        error(errorHead..gameObjectCallSyntaxError.."BroadcastMessage()")
    end

    local argType = type(methodName)
    if argType ~= "string" then
        error(errorHead.."Argument 'name' is of type '"..argType.."' with value '"..tostring(methodName).."' instead of 'string'. Must the method name.")
    end

    argType = type(data)
    if data ~= nil and argType ~= "table" then
        error(errorHead.."Argument 'data' is of type '"..argType.."' with value '"..tostring(data).."' instead of 'table'. If set, must be a table.")
    end

    local allChildren = table.join({self}, self:GetChildrenRecursive())

    for i, child in ipairs(allChildren) do
        child:SendMessage(methodName, data)
    end
end


-- Add components

-- Add a component to the gameObject and optionaly initialize it.
-- @param componentType (string) The Component type.
-- @param params [optional] (string, Script, Model, Map or table) The Script, Model or Map name or asset, or a table of parameters to initialize the new component with.
-- @return (ScriptedBehavior, Model, Map or Camera) The component .
function GameObject:AddComponent(componentType, params)
    local errorHead = "GameObject:AddComponent(componentType[, params]) : "

    if cstype(self) ~= "GameObject" then 
        error(errorHead..gameObjectCallSyntaxError.."AddComponent()")
    end

    local argType = type(componentType)
    if argType ~= "string" then
        error(errorHead.."Argument 'componentType' is of type '"..argType.."' with value '"..tostring(componentType).."' instead of 'string'. Must the component type.")
    end

    componentType = Daneel.core.CaseProof(componentType, Daneel.config.componentTypes)

    if not table.containsvalue(Daneel.config.componentTypes, componentType) then
        error(errorHead.."Argument 'componentType' with value '"..componentType.."' is not one of the valid component types : "..table.concat(componentType, ", "))
    end


    if params == nil then params = {} end
    argType = cstype(params)

    -- params is the asset name (script model or map)
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
        -- else : should be a params table
    end


    -- ScriptedBehavior
    if componentType == "ScriptedBehavior" then
        if params.script == nil then
            error(errorHead.."Argument 'componenetType' is 'ScriptedBehavior' but argument 'params.script' is nil.")
        end

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

            if renderViewportPosition.x == nil or renderViewportPosition.y == nil or (renderViewportPosition.x == nil and renderViewportPosition.y == nil) then
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

            if renderViewportSize.width == nil or renderViewportSize.height == nil or (renderViewportSize.width == nil and renderViewportSize.height == nil) then
                error(errorHead.."Argument 'params.renderViewportSize' is missing key 'width' and/or 'height'. Their value must be number or string.")
            end

            component:SetRenderViewportSize(renderViewportSize.width, renderViewportSize.height)
        end
    end

    return component
end

-- Add a ScriptedBehavior to the gameObject.
-- @param assetNameOrAsset (string or asset) The script name or asset.
-- @return (ScriptedBehavior) The ScriptedBehavior component.
function GameObject:AddScriptedBehavior(assetNameOrAsset)
    local errorHead = "GameObject:AddScriptedBehavior(assetNameOrAsset) : "

    if cstype(self) ~= "GameObject" then
        error(errorHead..gameObjectCallSyntaxError.."AddScriptedBehavior()")
    end

    local argType = cstype(assetNameOrAsset)
    if argType ~= "string" and argType ~= "ScriptedBehavior" then
        error(errorHead.."Argument 'assetNameOrAsset' is of type '"..argType.."' with value '"..tostring(assetNameOrAsset).."' instead of 'string' (the Script name) or 'Script'.")
    end

    return self:AddComponent("ScriptedBehavior", assetNameOrAsset)
end

-- Add a ModelRenderer component to the gameObject and optionaly initialize it.
-- @param params [optional] (string, Model or table) The model name or asset, or a table of parameters to initialize the new ModelRenderer with.
-- @return (ModelRenderer) The ModelRenderer component.
function GameObject:AddModelRenderer(params)
    local errorHead = "GameObject:AddModelRenderer([params]) : "

    if cstype(self) ~= "GameObject" then
        error(errorHead..gameObjectCallSyntaxError.."AddModelRenderer()")
    end

    return self:AddComponent("ModelRenderer", params)
end

-- Add a MapRenderer to the gameObject and optionaly initialize it.
-- @param params [optional] (string, Map or table) The map name or asset, or a table of parameters to initialize the new MapRenderer with.
-- @return (Map) The Map component.
function GameObject:AddMapRenderer(params)
    local errorHead = "GameObject:AddMapRenderer([params]) : "

    if cstype(self) ~= "GameObject" then
        error(errorHead..gameObjectCallSyntaxError.."AddMapRenderer()")
    end

    return self:AddComponent("MapRenderer", params)
end


-- Add a Camera component to the gameObject and optionaly initialize it.
-- @param params [optional] (table) A table of parameters to initialize the new camera with.
-- @return (Camera) The Camera component.
function GameObject:AddCamera(params)
    local errorHead = "GameObject:AddCamera([params]) : "

    if cstype(self) ~= "GameObject" then
        error(errorHead..gameObjectCallSyntaxError.."AddCamera()")
    end

    return self:AddComponent("Camera", params)
end


-- Get components

-- Get the specified ScriptedBehavior instance attached to the gameObject.
-- @param scriptNameOrAsset (string or Script) The script name or asset.
-- @return (ScriptedBehavior) The ScriptedBehavior instance.
function GameObject:GetScriptedBehaviorByName(scriptNameOrAsset)
    local errorHead = "GameObject:GetScriptedBehavior(scriptNameOrAsset) : "

    if cstype(self) ~= "GameObject" then 
        error(errorHead..gameObjectCallSyntaxError.."GetScriptedBehavior()")
    end

    local argType = cstype(scriptNameOrAsset)
    if argType ~= "string" and argType ~= "ScriptedBehavior" then
        error(errorHead.."Argument 'scriptNameOrAsset' is of type '"..argType.."' with value '"..tostring(scriptNameOrAsset).."' instead of 'string' (the Script name) or 'Script'.")
    end

    if argType == "string" then
        local script = Asset.Get(scriptNameOrAsset, "Script")
        
        if script == nil then
            error(errorHead.."Argument 'scriptNameOrAsset' : Script asset with name '"..scriptNameOrAsset.."' was not found.")
        end
    end

    return self:GetScriptedBehavior(script)
end

-- Get the first ModelRenderer component attached to the gameObject.
-- @return (ModelRenderer) The ModelRenderer component.
function GameObject:GetModelRenderer()
    local errorHead = "GameObject:GetModelRenderer() : "

    if cstype(self) ~= "GameObject" then 
        error(errorHead..gameObjectCallSyntaxError.."GetModelRenderer()")
    end

    return self:GetComponent("ModelRenderer")
end

-- Get the first MapRenderer component attached to the gameObject.
-- @return (MapRenderer) The MapRenderer component.
function GameObject:GetMapRenderer()
    local errorHead = "GameObject:GetMapRenderer() : "

    if cstype(self) ~= "GameObject" then 
        error(errorHead..gameObjectCallSyntaxError.."GetMapRenderer()")
    end

    return self:GetComponent("MapRenderer")
end

-- Get the first Camera component attached to the gameObject.
-- @return (Camera) The Camera component.
function GameObject:GetCamera()
    local errorHead = "GameObject:GetCamera() : "

    if cstype(self) ~= "GameObject" then 
        error(errorHead..gameObjectCallSyntaxError.."GetCamera()")
    end

    return self:GetComponent("Camera")
end

-- Get the Transform component attached to the gameObject.
-- @return (Transform) The Transform component.
function GameObject:GetTransform()
    local errorHead = "GameObject:GetTransform() : "

    if cstype(self) ~= "GameObject" then 
        error(errorHead..gameObjectCallSyntaxError.."GetTransform()")
    end

    return self:GetComponent("Transform")
end


-- Destroy things

-- Destroy the gameObject
function GameObject:Destroy()
    local errorHead = "GameObject:Destroy() : "

    if cstype(self) ~= "GameObject" then 
        error(errorHead..gameObjectCallSyntaxError.."Destroy()")
    end

    CraftSudio.Destroy(self)
end


-- Destroy a component from the gameObject.
-- Argument 'input' can be :
-- the component type (string) (the function will destroy the first component of that type), 
-- the component itself (ScriptedBehavior, Model, Map or Camera),
-- or a script name or asset (string or Script) (the function will destroy the ScriptedBehavior that uses this Script),
-- 
-- @param input (mixed) See function description.
-- @param strict [optional default=false] (boolean) If true, returns an error when the function can't find the component to destroy.
-- @return (boolean) True if the component has been succesfully destroyed, false otherwise.
function GameObject:DestroyComponent(input, strict)
    local errorHead = "GameObject:DestroyComponent(input[, strict]) : "

    if cstype(self) ~= "GameObject" then
        error(errorHead..gameObjectCallSyntaxError.."DestroyComponent()")
    end

    local argType = cstype(input)
    local allowedTypes = {"string", "Script", "table"}
    
    if not table.constainsvalue(allowedTypes, argType) then
        error(errorHead.."Argument 'input' is of type '"..argType.."' with value '"..tostring(input).."' instead of '"..table.concat(allowedTypes, "', '").."'.")
    end

    local argType = type(strict)
    if argType ~= nil and argType ~= "boolean" then
        error(errorHead.."Argument 'strict' is of type '"..argType.."' with value '"..tostring(strict).."' instead of 'boolean'.")
    end

    if strict == nil then strict = false end

    local component = nil
    local stringError = ""
    local argType = cstype(input)

    -- input is a component ?
    if argType == "table" then 

        -- Components have a gameObject and a inner variable
        -- But I find no way to check if the table is actally a component or not, or which component is it
        if input.inner ~= nil and input.gameObject ~= nil then
            component = input    
        else
            stringError = errorHead.."Argument 'input' is of type 'table' with value '"..tostring(input).."' but not a component."
        end

    -- input is a script asset
    elseif argType == "Script" then
        component = self:GetScriptedBehavior(input)

        if component == nil then
            stringError = errorHead.."Argument 'input' : Couldn't find a ScriptedBehavior corresponding to the specified Script asset on this gameObject."
        end

    -- string (component type or script name)
    elseif argType == "string" then
        input = Daneel.core.CaseProof(input, Daneel.config.componentTypes)

        -- component type
        if table.containsvalue(Daneel.config.componentTypes, input) then
            component = self:GetComponent(input)

            if component == nil then
                stringError = errorHead.."Argument 'input' : Couldn't find the specified component type '"..input.."' on this gameObject."
            end

        -- or script name
        else 
            component = self:GetScriptedBehaviorByName(input)

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
    return true
end

-- TODO vérifier les instances des component

-- Destroy a ScriptedBehavior form the gameObject.
-- If argument 'scriptNameOrAsset' is set with a script name or a script asset, the function will try to destroy the ScriptedBehavior that use this script.
-- If the argument is not set, it will destroy the first ScriptedBehavior on this gameObejct
-- @param scriptNameOrAsset [optional] (string or Script) The script name or asset.
-- @return (boolean) True if the component has been succesfully destroyed, false otherwise.
function GameObject:DestroyScriptedBehavior(scriptNameOrAsset)
    local errorHead = "GameObject.DestroyScriptedBehavior([scriptNameOrAsset]) : "

    if cstype(self) ~= "GameObject" then
        error(errorHead..gameObjectCallSyntaxError.."DestroyScriptedBehavior()")
    end

    local argType = cstype(scriptNameOrAsset)
    if argType ~= nil and argType ~= "string" and argType ~= "Script" then
        error(errorHead.."Argument 'scriptNameOrAsset' is of type '"..argType.."' with value '"..tostring(scriptNameOrAsset).."' instead of 'string' or 'Script'.")
    end

    if scriptNameOrAsset == nil then
        return self:DestroyComponent("ScriptedBehavior")
    else
        return self:DestroyComponent(scriptNameOrAsset)
    end
end

-- Destroy the first ModelRenderer component from the gameObject.
-- @return (boolean) True if the component has been succesfully destroyed, false otherwise.
function GameObject:DestroyModelRenderer()
    local errorHead = "GameObject.DestroyModelRenderer() : "

    if cstype(self) ~= "GameObject" then
        error(errorHead..gameObjectCallSyntaxError.."DestroyModelRenderer()")
    end

    return self:DestroyComponent("ModelRenderer")
end

-- Destroy the first MapRenderer component from the gameObject.
-- @return (boolean) True if the component has been succesfully destroyed, false otherwise.
function GameObject:DestroyMapRenderer()
    local errorHead = "GameObject.DestroyMapRenderer() : "

    if cstype(self) ~= "GameObject" then
        error(errorHead..gameObjectCallSyntaxError.."DestroyMapRenderer()")
    end

    return self:DestroyComponent("MapRenderer")
end

-- Destroy the first Camera component from the gameObject.
-- @return (boolean) True if the component has been succesfully destroyed, false otherwise.
function GameObject:DestroyCamera()
    local errorHead = "GameObject.DestroyCamera() : "

    if cstype(self) ~= "GameObject" then
        error(errorHead..gameObjectCallSyntaxError.."DestroyCamera()")
    end

    return self:DestroyComponent("Camera")
end

