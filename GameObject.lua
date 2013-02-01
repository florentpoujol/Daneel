
local gameObjectCallSyntaxError = "Function called from a gameObject. Your must use a colon ( : ) between the gameObject and the method name. Ie : self.gameObject:"


-- Create a new gameObject with optionnal initialisation parameters.
-- @param name string - The GameObject name.
-- @param params table - The initialisation parameters
-- @return The new gameObject (GameObject)
function GameObject.New(name, params, g)
    if name == GameObject then
        name = params
        params = g
    end

    -- errors
    local errorHead = "GameObject.New(name[, params]) : "

    local varType = type(name)
    if name == nil or varType ~= "string" then
        error(errorHead .. "Argument 'name' is of type '" .. varType .. "' instead of 'string'. Must be the gameObject name.")
    end

    if params == nil then params = {} end

    varType = type(params)
    if varType ~= "table" then
        error(errorHead .. "Argument 'params' is of type '" .. varType .. "' instead of 'table'. This argument is optionnal but if set, it must be a table.")
    end
    
    --
    local go = CraftStudio.CreateGameObject(name)

    go = ApplyParamsToGameObject(go, params, errorHead)    

    return go
end

-- Add a scene as a new gameObject with optionnal initialisation parameters.
-- @param goName string - The gameObject name.
-- @param sceneName string - The scene name
-- @param params table - The initialisation parameters
-- @return The new gameObject (GameObject)
function GameObject.Instantiate(goName, sceneName, params, g)
    if goName == GameObject then
        goName = sceneName
        sceneName = params
        params = g
    end

    -- errors
    local errorHead = "GameObject.Instantiate(gameObjectName, sceneName[, params]) : "

    local varType = type(goName)
    if goName == nil or varType ~= "string" then
        error(errorHead .. "Argument 'gameObjectName' is of type '" .. varType .. "' instead of 'string'. Must be the gameObject name.")
    end

    varType = type(sceneName)
    if sceneName == nil or varType ~= "string" then
        error(errorHead .. "Argument 'sceneName' is of type '" .. varType .. "' instead of 'string'. Must be the scene name.")
    end

    if params == nil then params = {} end

    varType = type(params)
    if varType ~= "table" then
        error(errorHead .. "Argument 'params' is of type '" .. varType .. "' instead of 'table'. This argument is optionnal but if set, it must be a table.")
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
                error(errorHead .. "parent name in parameters '" .. params.parent .. "' does not match any gameObject.")
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
                error(errorHead .. "model name in parameters '" .. params.model .. "' does not match any model.")
            end
        end

        go:CreateComponent("ModelRenderer"):SetModel(model)
    end

    if params.map ~= nil then
        local map = params.map

        if type(map) == "string" then
            map = CraftStudio.FindAsset(map, "Map")

            if map == nil then
                error(errorHead .. "map name in parameters '" .. params.map .. "' does not match any map.")
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
                error(errorHead .. "script name in parameters '" .. script .. "' does not match any script.")
            end
        end

        go:CreateScripteBehavior(script)
    end 

    return go
end


-- Alias of CraftStudio.FindGameObject(name).
-- Get the gameObject that has the specified name
-- @param name string - The gameObject name
-- @return The gaeObject (GameObject) or nil if none is found
function GameObject.Get(name, g)
    if name == GameObject then
        name = g
    end

    local varType = type(name)
    if name == nil or varType ~= "string" then
        error("GameObject.Get(gameObjectName) : Argument 'gameObjectName' is of type '" .. varType .. "' instead of 'string'. Must be the gameObject name.")
    end

    return CraftStudio.FindGameObject(name)
end


-- Set the gameOject's parent. 
-- Optionnaly carry over the gameObject's local transform instead of the global one.
-- @param name string - The parent name
-- @param keepLocalTransform (optionnal) boolean - Carry over the game object's local transform instead of the global one.
function GameObject:SetParentByName(name, keepLocalTransform)
    local errorHead = "GameObject:SetParentByName(name[, keepLocalTransform]) : "

    if getmetatable(self) ~= GameObject then
        error(errorHead .. gameObjectCallSyntaxError .. "SetParentByName()")
    end

    local varType = type(name)
    if name == nil or varType ~= "string" then
        error(errorHead .. "Argument 'name' is of type '" .. varType .. "' instead of 'string'. Must the parent gameObject name.")
    end

    varType = type(keepLocalTransform)
    if keepLocalTransform ~= nil and varType ~= "boolean" then
        error(errorHead .. "Argument 'keepLocalTransform' is of type '" .. varType .. "' instead of 'boolean'.")
    end

    --

    local go = GameObject.Get(name)

    if go == nil then
        error(errorHead .. "The gameObject name '" .. name .. "' does not match any gameObject in the scene.")
    end

    self:SetParent(go, keepLocalTransform)
end


-- Alias of GameObject:FindChild().
-- Find the first gameObject's child with the specified name.
-- @param name The child name
-- @param recursive (optionnal) Search for the child in all descendants
-- @return The child (GameObject) or nil if none is found
function GameObject:GetChild(name, recursive)
    local errorHead = "GameObject:GetChild(name[, recursive]) : "

    if getmetatable(self) ~= GameObject then
        error(errorHead .. gameObjectCallSyntaxError .. "GetChild()")
    end

    local varType = type(name)
    if name == nil or varType ~= "string" then
        error(errorHead .. "Argument 'name' is of type '" .. varType .. "' instead of 'string'. Must the child gameObject name.")
    end

    varType = type(recursive)
    if recursive ~= nil and varType ~= "boolean" then
        error(errorHead .. "Argument 'recursive' is of type '" .. varType .. "' instead of 'boolean'.")
    end

    return self:FindChild(name, recursive)
end


-- Get all descendants of the gameObject
-- @param includeSelf (optionnal) - boolean - Include the gameObject in the children - default=false
-- @return table - The children
function GameObject:GetChildrenRecursive(includeSelf)
    local errorHead = "GameObject:GetChildrenRecursive() : "

    if getmetatable(self) ~= GameObject then
        error(errorHead .. gameObjectCallSyntaxError .. "GetChildrenRecursive()")
    end

    local varType = type(includeSelf)
    if includeSelf ~= nil and varType ~= "boolean" then
        error(errorHead .. "Argument 'includeSelf' is of type '" .. varType .. "' instead of 'boolean'.")
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
-- @param methodName string - The method name
-- @param data (optionnal) string - The data to pass along the method call
function GameObject:BroadcastMessage(methodName, data)
    local errorHead = "GameObject:BroadcastMessage(methodName[, data]) : "

    if getmetatable(self) ~= GameObject then
        error(errorHead .. gameObjectCallSyntaxError .. "BroadcastMessage()")
    end

    local varType = type(methodName)
    if name == nil or varType ~= "string" then
        error(errorHead .. "Argument 'name' is of type '" .. varType .. "' instead of 'string'. Must the method name.")
    end

    varType = type(data)
    if data ~= nil and varType ~= "table" then
        error(errorHead .. "Argument 'data' is of type '" .. varType .. "' instead of 'table'. If set, must be a table.")
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


-- tell wether the text is a script
local function IsScript(text)
    scripts = {"script", "scriptedbehavior"}
    text = text:lower()

    for i, value in ipairs(scripts) do
        if value == text then
            return true
        end
    end

    return false
end

-- Correspondance between the component type (the keys) and the asset type (the values)
local assetTypeFromComponentType = {
    Script = "Script",
    ModelRenderer = "Model",
    MapRenderer = "Map",
}


-- Add a component to the gameObject and optionnaly set the model, map or script asset.
-- @param componentType The Compoenent type
-- @param asset (optionnal) The model, map or script name or asset to initialize the new component with
function GameObject:AddComponent(componentType, asset)
    local errorHead = "GameObject:AddComponent(componentType[, asset or asset name]) : "

    if getmetatable(self) ~= GameObject then -- pas appelé depuis un gameObject
        error(errorHead .. gameObjectCallSyntaxError .. "AddComponent()")
    end

    if componentType == nil or type(componentType) ~= "string" then
        error(errorHead .. "Argument 'componentType' is nil or not a string. Must be the component type.")
    end

    -- get the asset if name is given
    -- it's done here because we need the asset right away if it's a script
    if asset ~= nil and type(asset) == "string" then
        local assetType = assetTypeFromComponentType[componentType]
        local assetName = asset
        asset = CraftStudio.FindAsset(assetName, assetType)

        if asset == nil then
            error(errorHead .. "Asset not found. Component type='" .. componentType .. "', asset type='" .. assetType .. "', asset name'" .. assetName .. "'")
        end
    end

    -- 
    local component = nil

    if IsScript(componentType) then
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
-- @param assetNameOrAsset The script name or asset
function GameObject:AddScript(assetNameOrAsset)
    local errorHead = "GameObject:AddScript(assetNameOrAsset) : "

    if getmetatable(self) ~= GameObject then
        error(errorHead .. gameObjectCallSyntaxError .. "AddScript()")
    end

    if type(assetNameOrAsset) == nil then
        error(errorHead .. "Argument 'assetNameOrAsset' is nil. Must be the script name or the script asset.")
    end

    return self:AddComponent("Script", assetNameOrAsset)
end

-- Add a ModelRenderer component to the gameObject.
function GameObject:AddModelRenderer()
    local errorHead = "GameObject:AddModelRenderer() : "

    if getmetatable(self) ~= GameObject then
        error(errorHead .. gameObjectCallSyntaxError .. "AddModelRenderer()")
    end

    return self:AddComponent("ModelRenderer")
end

-- Add a ModelRenderer component to the gameObject and set its model.
-- @param assetNameOrAsset The model name or asset
function GameObject:AddModel(assetNameOrAsset)
    local errorHead = "GameObject:AddModel(assetNameOrAsset) : "

    if getmetatable(self) ~= GameObject then
        error(errorHead .. gameObjectCallSyntaxError .. "AddModel()")
    end

    if type(assetNameOrAsset) == nil then
        error(errorHead .. "Argument 'assetNameOrAsset' is nil. Must be the model name or the model asset.")
    end

    return self:AddComponent("ModelRenderer", assetNameOrAsset)
end

-- Add a MapRenderer to the gameObject.
function GameObject:AddMapRenderer()
    local errorHead = "GameObject:AddMapRenderer() : "

    if getmetatable(self) ~= GameObject then
        error(errorHead .. gameObjectCallSyntaxError .. "AddMapRenderer()")
    end

    return self:AddComponent("MapRenderer")
end

-- Add a MapRenderer component to the gameObject and set its map 
-- @param assetNameOrAsset The model name or asset
function GameObject:AddMap(assetNameOrAsset)
    local errorHead = "GameObject:AddMap(assetNameOrAsset) : "

    if getmetatable(self) ~= GameObject then
        error(errorHead .. gameObjectCallSyntaxError .. "AddMap()")
    end

    if type(assetNameOrAsset) == nil then
        error(errorHead .. "Argument 'assetNameOrAsset' is nil. Must be the map name or the map asset.")
    end

    return self:AddComponent("MapRenderer", assetNameOrAsset)
end

-- Add a Camera component to the gameObject.
function GameObject:AddCamera()
    local errorHead = "GameObject:AddCamera() : "

    if getmetatable(self) ~= GameObject then
        error(errorHead .. gameObjectCallSyntaxError .. "AddCamera()")
    end

    return self:AddComponent("MapRenderer")
end


-- Get the specified ScriptedBehavior instance attached to the gameObject
-- @param scriptNameOrAsset The script name or asset
-- @return The ScriptedBehavior instance
function GameObject:GetScript(scriptNameOrAsset)
    local errorHead = "GameObject:GetScript(scriptNameOrAsset) : "

    if getmetatable(self) ~= GameObject then -- pas appelé depuis un gameObject
        error(errorHead .. gameObjectCallSyntaxError .. "GetScript()")
    end

    if scriptNameOrAsset == nil then
        error(errorHead .. "Argument 'scriptNameOrAsset' is nil. Must be the script name or the script asset")
    end

    if scriptNameOrAsset ~= nil and type(scriptNameOrAsset) == "string" then
        local script = CraftStudio.FindAsset(scriptNameOrAsset, "Script")
        
        if script == nil then
            error(errorHead .. "Script asset not found. Script name='" .. scriptNameOrAsset .. "'")
        end
    end

    return self:GetScriptedBehavior(script)
end

-- Get the first ModelRenderer component attached to the gameObject
-- @return The ModelRenderer component
function GameObject:GetModelRenderer()
    local errorHead = "GameObject:GetModelRenderer() : "

    if getmetatable(self) ~= GameObject then -- pas appelé depuis un gameObject
        error(errorHead .. gameObjectCallSyntaxError .. "GetModelRenderer()")
    end

    return self:GetComponent("ModelRenderer")
end

-- Get the first MapRenderer component attached to the gameObject
-- @return The MapRenderer component
function GameObject:GetMapRenderer()
    local errorHead = "GameObject:GetMapRenderer() : "

    if getmetatable(self) ~= GameObject then -- pas appelé depuis un gameObject
        error(errorHead .. gameObjectCallSyntaxError .. "GetMapRenderer()")
    end

    return self:GetComponent("MapRenderer")
end

-- Get the first Camera component attached to the gameObject
-- @return The Camera component
function GameObject:GetCamera()
    local errorHead = "GameObject:GetCamera() : "

    if getmetatable(self) ~= GameObject then -- pas appelé depuis un gameObject
        error(errorHead .. gameObjectCallSyntaxError .. "GetCamera()")
    end

    return self:GetComponent("Camera")
end

-- Get the Transform component attached to the gameObject
-- @return The Transform component
function GameObject:GetTransform()
    local errorHead = "GameObject:GetTransform() : "

    if getmetatable(self) ~= GameObject then -- pas appelé depuis un gameObject
        error(errorHead .. gameObjectCallSyntaxError .. "GetTransform()")
    end

    return self:GetComponent("Transform")
end


-- Destroy the gameObject
function GameObject:Destroy()
    local errorHead = "GameObject:Destroy() : "

    if getmetatable(self) ~= GameObject then -- pas appelé depuis un gameObject
        error(errorHead .. gameObjectCallSyntaxError .. "Destroy()")
    end

    CraftSudio.Destroy(self)
end

