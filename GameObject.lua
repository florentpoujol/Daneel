
local gameObjectCallSyntaxError = "Function not called from a gameObject. Your must use a colon ( : ) between the gameObject and the method name. Ie : self.gameObject:"


-- Create a new gameObject with optionnal initialisation parameters.
-- @param name (string) The GameObject name.
-- @param params (table) The initialisation parameters
-- @return The new gameObject (GameObject)
function GameObject.New(name, params, g)
    if name == GameObject then
        name = params
        params = g
    end

    -- errors
    local errorHead = "GameObject.New(name[, params]) : "

    local argType = type(name)
    if name == nil or argType ~= "string" then
        error(errorHead.."Argument 'name' is of type '"..argType.."' instead of 'string'. Must be the gameObject name.")
    end

    if params == nil then params = {} end

    argType = type(params)
    if argType ~= "table" then
        error(errorHead.."Argument 'params' is of type '"..argType.."' instead of 'table'. This argument is optionnal but if set, it must be a table.")
    end
    
    --
    local go = CraftStudio.CreateGameObject(name)

    go = ApplyParamsToGameObject(go, params, errorHead)    

    return go
end

-- Add a scene as a new gameObject with optionnal initialisation parameters.
-- @param goName (string) The gameObject name.
-- @param sceneName (string) The scene name
-- @param params (table) The initialisation parameters
-- @return (GameObject) The new gameObject 
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
        error(errorHead.."Argument 'gameObjectName' is of type '"..argType.."' instead of 'string'. Must be the gameObject name.")
    end

    argType = type(sceneName)
    if sceneName == nil or argType ~= "string" then
        error(errorHead.."Argument 'sceneName' is of type '"..argType.."' instead of 'string'. Must be the scene name.")
    end

    if params == nil then params = {} end

    argType = type(params)
    if argType ~= "table" then
        error(errorHead.."Argument 'params' is of type '"..argType.."' instead of 'table'. This argument is optionnal but if set, it must be a table.")
    end
    
    --
    local go = CraftStudio.Instantiate(goName, sceneName)

    go = ApplyParamsToGameObject(go, params, errorHead) 

    return go
end

-- Apply the content of params to the gameObject in argument.
local function ApplyParamsToGameObject(go, params, errorHead)
    if params.parent ~= nil then
        local parent = params.parent

        if type(parent) == "string" then
            parent = CraftStudio.FindGameObject(parent)

            if parent == nil then
                error(errorHead.."parent name in parameters '"..params.parent.."' does not match any gameObject.")
            end
        end

        if type(params.parentKeepLocalTransform) == "boolean" then
            go:SetParent(parent, params.keepLocalTransform)
        else
            go:SetParent(parent)
        end
    end

    --  position
    if params.position ~= nil then
        go.transform:SetPosition(params.position)
    end

    if params.localPosition ~= nil then
        go.transform:SetLocalPosition(params.localPosition)
    end

    -- orientation
    if params.orientation ~= nil then
        go.transform:SetOrientation(params.orientation)
    end

    if params.localOrientation ~= nil then
        go.transform:SetLocalOrientation(params.localOrientation)
    end

    -- Euler Angles
    if params.eulerAngles ~= nil then
        go.transform:SetEulerAngles(params.eulerAngles)
    end

    if params.localEulerAngles ~= nil then
        go.transform:SetLocalEulerAngles(params.localEulerAngles)
    end

    -- scale
    if params.scale ~= nil then
        go.transform:SetLocalScale(params.scale)
    end

    -- components
    if params.model ~= nil then
        local model = params.model

        if type(model) == "string" then
            model = CraftStudio.FindAsset(model, "Model")

            if model == nil then
                error(errorHead.."model name in parameters '"..params.model.."' does not match any model.")
            end
        end

        go:CreateComponent("ModelRenderer"):SetModel(model)
    end

    if params.map ~= nil then
        local map = params.map

        if type(map) == "string" then
            map = CraftStudio.FindAsset(map, "Map")

            if map == nil then
                error(errorHead.."map name in parameters '"..params.map.."' does not match any map.")
            end
        end

        go:CreateComponent("MapRenderer"):SetMap(map)
    end

    if params.camera ~= nil then
        go:CreateComponent("Camera")
    end

    -- scripts
    if params.scripts == nil then
        params.scripts = {}
    end

    if params.script ~= nil then
        table.insert(params.scripts, params.script)
    end

    for i, script in ipairs(params.scripts) do
        if type(script) ==  "string" then
            script = CraftStudio.FindAsset(script, "ScriptedBehavior")

            if script == nil then
                error(errorHead.."script name in parameters '"..script.."' does not match any script.")
            end
        end

        go:CreateScripteBehavior(script)
    end 

    return go
end


-- Alias of CraftStudio.FindGameObject(name).
-- Get the gameObject that has the specified name
-- @param name (string) The gameObject name
-- @return (GameObject) The gameObject or nil if none is found
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
-- @param name (string) The parent name
-- @param keepLocalTransform [optionnal] (boolean) Carry over the game object's local transform instead of the global one.
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
-- @param name (string) The child name
-- @param recursive [optionnal] (boolean=false) Search for the child in all descendants
-- @return (GameObject) The child or nil if none is found
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


-- Get all descendants of the gameObject
-- @param includeSelf [optionnal] (boolean=false) Include the gameObject in the children
-- @return (table) The children
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
-- Uses GameObject:SendMessage() on the gameObject and all children of its children
-- @param methodName (string) The method name
-- @param data [optionnal] (table) The data to pass along the method call
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

    for i, child in allChildren do
        child:SendMessage(methodName, data)
    end
end


--------------------------------------------------
-- Components
--------------------------------------------------





-- Add components

-- Add a component to the gameObject and optionnaly set the model, map or script asset.
-- @param componentType (string) The Component type
-- @param asset [optionnal] (string or asset) The model, map or script name or asset to initialize the new component with
function GameObject:AddComponent(componentType, asset)
    local errorHead = "GameObject:AddComponent(componentType[, asset or asset name]) : "

    if getmetatable(self) ~= GameObject then 
        error(errorHead..gameObjectCallSyntaxError.."AddComponent()")
    end

    local argType = type(componentType)
    if argType ~= "string" then
        error(errorHead.."Argument 'componentType' is of type '" .. argType .. "' instead of 'string'. Must the component type.")
    end

    componentType = Daneel.utilities.CaseProof(componentType, Daneel.config.componentTypes)

    -- get the asset if name is given
    -- it's done here because we need the asset right away if it's a script
    if asset ~= nil and type(asset) == "string" then
        local assetType = Daneel.config.componentTypeToAssetType[componentType]
        local assetName = asset
        asset = CraftStudio.FindAsset(assetName, assetType)

        if asset == nil then
            error(errorHead.."Asset not found. Component type='"..componentType.."', asset type='"..assetType.."', asset name'"..assetName.."'")
        end
    end

    -- 
    local component = nil

    if Daneel.utilities.IsScript(componentType) then
        component = self:CreateScriptedBehavior(asset)
    else
        component = self:CreateComponent(componentType)

        if asset ~= nil then
            if componentType == "ModelRenderer" then
                component:SetModel(asset)
            elseif componentType == "MapRenderer" then
                component:SetMap(asset)
            end
        end
    end

    return component
end

-- Add a ScriptedBehavior to the gameObject.
-- @param assetNameOrAsset (string or asset) The script name or asset
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

-- Add a ScriptedBehavior to the gameObject.
-- @param assetNameOrAsset (string or asset) The script name or asset
function GameObject:AddScript(assetNameOrAsset)
    local errorHead = "GameObject:AddScript(assetNameOrAsset) : "

    if getmetatable(self) ~= GameObject then
        error(errorHead..gameObjectCallSyntaxError.."AddScript()")
    end

    if type(assetNameOrAsset) == nil then
        error(errorHead.."Argument 'assetNameOrAsset' is nil. Must be the script name or the script asset.")
    end

    return self:AddComponent("ScriptedBehavior", assetNameOrAsset)
end

-- Add a ModelRenderer component to the gameObject.
function GameObject:AddModelRenderer()
    local errorHead = "GameObject:AddModelRenderer() : "

    if getmetatable(self) ~= GameObject then
        error(errorHead..gameObjectCallSyntaxError.."AddModelRenderer()")
    end

    return self:AddComponent("ModelRenderer")
end

-- Add a ModelRenderer component to the gameObject and set its model.
-- @param assetNameOrAsset (string or asset) The model name or asset
function GameObject:AddModel(assetNameOrAsset)
    local errorHead = "GameObject:AddModel(assetNameOrAsset) : "

    if getmetatable(self) ~= GameObject then
        error(errorHead..gameObjectCallSyntaxError.."AddModel()")
    end

    if type(assetNameOrAsset) == nil then
        error(errorHead.."Argument 'assetNameOrAsset' is nil. Must be the model name or the model asset.")
    end

    return self:AddComponent("ModelRenderer", assetNameOrAsset)
end

-- Add a MapRenderer to the gameObject.
function GameObject:AddMapRenderer()
    local errorHead = "GameObject:AddMapRenderer() : "

    if getmetatable(self) ~= GameObject then
        error(errorHead..gameObjectCallSyntaxError.."AddMapRenderer()")
    end

    return self:AddComponent("MapRenderer")
end

-- Add a MapRenderer component to the gameObject and set its map 
-- @param assetNameOrAsset (string or asset) The model name or asset
function GameObject:AddMap(assetNameOrAsset)
    local errorHead = "GameObject:AddMap(assetNameOrAsset) : "

    if getmetatable(self) ~= GameObject then
        error(errorHead..gameObjectCallSyntaxError.."AddMap()")
    end

    if type(assetNameOrAsset) == nil then
        error(errorHead.."Argument 'assetNameOrAsset' is nil. Must be the map name or the map asset.")
    end

    return self:AddComponent("MapRenderer", assetNameOrAsset)
end

-- Add a Camera component to the gameObject.
function GameObject:AddCamera()
    local errorHead = "GameObject:AddCamera() : "

    if getmetatable(self) ~= GameObject then
        error(errorHead..gameObjectCallSyntaxError.."AddCamera()")
    end

    return self:AddComponent("MapRenderer")
end


-- Get components

-- Get the specified ScriptedBehavior instance attached to the gameObject
-- @param scriptNameOrAsset (string or asset) The script name or asset
-- @return (ScriptedBehavior) The ScriptedBehavior instance
function GameObject:GetScriptedBehavior(scriptNameOrAsset)
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

-- Get the specified ScriptedBehavior instance attached to the gameObject
-- @param scriptNameOrAsset (string or asset) The script name or asset
-- @return (ScriptedBehavior) The ScriptedBehavior instance
function GameObject:GetScript(scriptNameOrAsset)
    local errorHead = "GameObject:GetScript(scriptNameOrAsset) : "

    if getmetatable(self) ~= GameObject then 
        error(errorHead..gameObjectCallSyntaxError.."GetScript()")
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

-- Get the first ModelRenderer component attached to the gameObject
-- @return (ModelRenderer) The ModelRenderer component
function GameObject:GetModelRenderer()
    local errorHead = "GameObject:GetModelRenderer() : "

    if getmetatable(self) ~= GameObject then 
        error(errorHead..gameObjectCallSyntaxError.."GetModelRenderer()")
    end

    return self:GetComponent("ModelRenderer")
end

-- Get the first MapRenderer component attached to the gameObject
-- @return (MapRenderer) The MapRenderer component
function GameObject:GetMapRenderer()
    local errorHead = "GameObject:GetMapRenderer() : "

    if getmetatable(self) ~= GameObject then 
        error(errorHead..gameObjectCallSyntaxError.."GetMapRenderer()")
    end

    return self:GetComponent("MapRenderer")
end

-- Get the first Camera component attached to the gameObject
-- @return (Camera) The Camera component
function GameObject:GetCamera()
    local errorHead = "GameObject:GetCamera() : "

    if getmetatable(self) ~= GameObject then 
        error(errorHead..gameObjectCallSyntaxError.."GetCamera()")
    end

    return self:GetComponent("Camera")
end

-- Get the Transform component attached to the gameObject
-- @return (Transform) The Transform component
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


-- Destroy the specified component from the specified gameObject
function GameObject:DestroyComponent(componentNameOrAsset, g)
    local errorHead = "GameObject.DestroyComponent(componentNameOrAsset) : "

    if getmetatable(self) ~= GameObject then
        error(errorHead..gameObjectCallSyntaxError.."DestroyComponent()")
    end

    local argType = type(componentNameOrAsset)
    if componentNameOrAsset == nil then
        error(errorHead.."Argument 'componentNameOrAsset' is nil. Must be the component itself, the component type or the script name.")
    end



    if argType == "table" then
        component = componentNameOrAsset
    else
        if table.containsvalue(Daneel.config.componentTypes, componentNameOrAsset) then

        end
    end

    CraftStudio.Destroy(component)
end


function GameObject:DestroyScript(scriptNameOrAsset)

end

function GameObject:DestroyModelRenderer()
    local errorHead = "GameObject.DestroyModelRenderer() : "

    if getmetatable(self) ~= GameObject then
        error(errorHead..gameObjectCallSyntaxError.."DestroyModelRenderer()")
    end

    self:DestroyComponent(self:GetModelRenderer())
end