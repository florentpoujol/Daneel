
-- DEPENDENCIES : table.join(), table.containsvalue()
local gameObjectCallSyntaxError = "Function not called from a gameObject. Your must use a colon ( : ) between the gameObject and the method name. Ie : self.gameObject:"


-- Create new gameObject 

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

        if type(params.parentKeepLocalTransm) == "boolean" then
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

-- Create a new gameObject with optionnal initialisation parameters.
-- @param name (string) The GameObject name.
-- @param params (table) The initialisation parameters.
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
-- @param name (string) The child name.
-- @param recursive [optionnal] (boolean=false) Search for the child in all descendants.
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
-- @param includeSelf [optionnal] (boolean=false) Include the gameObject in the children.
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
-- @param data [optionnal] (table) The data to pass along the method call.
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

-- Add a component to the gameObject and optionnaly set the model, map or script asset.
-- @param componentType (string) The Component type.
-- @param asset [optionnal] (string or asset) The model, map or script name or asset to initialize the new component with.
-- @return (table) The component.
function GameObject:AddComponent(componentType, asset)
    local errorHead = "GameObject:AddComponent(componentType[, asset or asset name]) : "

    if getmetatable(self) ~= GameObject then 
        error(errorHead..gameObjectCallSyntaxError.."AddComponent()")
    end

    local argType = type(componentType)
    if argType ~= "string" then
        error(errorHead.."Argument 'componentType' is of type '" .. argType .. "' instead of 'string'. Must the component type.")
    end

    componentType = Daneel.core.CaseProof(componentType, Daneel.config.componentTypes)

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

    if Daneel.core.IsScript(componentType) then
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

-- Add a ScriptedBehavior to the gameObject.
-- @param assetNameOrAsset (string or asset) The script name or asset.
-- @return (table) The component.
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
-- @return (table) The component.
function GameObject:AddModelRenderer()
    local errorHead = "GameObject:AddModelRenderer() : "

    if getmetatable(self) ~= GameObject then
        error(errorHead..gameObjectCallSyntaxError.."AddModelRenderer()")
    end

    return self:AddComponent("ModelRenderer")
end

-- Add a ModelRenderer component to the gameObject and set its model.
-- @param assetNameOrAsset (string or asset) The model name or asset.
-- @return (table) The component.
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
-- @return (table) The component.
function GameObject:AddMapRenderer()
    local errorHead = "GameObject:AddMapRenderer() : "

    if getmetatable(self) ~= GameObject then
        error(errorHead..gameObjectCallSyntaxError.."AddMapRenderer()")
    end

    return self:AddComponent("MapRenderer")
end

-- Add a MapRenderer component to the gameObject and set its map.
-- @param assetNameOrAsset (string or asset) The model name or asset.
-- @return (table) The component.
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
-- @return (table) The component.
function GameObject:AddCamera()
    local errorHead = "GameObject:AddCamera() : "

    if getmetatable(self) ~= GameObject then
        error(errorHead..gameObjectCallSyntaxError.."AddCamera()")
    end

    return self:AddComponent("MapRenderer")
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
-- @param strict [optionnal] (boolean=false) If true, returns an error when the function can't find the component to destroy.
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
-- @param scriptNameOrAsset [optionnal] (string=nil) The script name or asset.
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

