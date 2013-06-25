
setmetatable(GameObject, { __call = function(Object, ...) return Object.New(...) end })

function GameObject.__tostring(gameObject)
    if gameObject.inner == nil then
        return "Destroyed gameObject: "..Daneel.Debug.ToRawString(gameObject)
        -- the important here was to prevent throwing an error
    end
    -- returns something like "GameObject: 123456789: 'MyName'"
    local id = tostring(gameObject.inner):sub(3,20)
    return "GameObject"..id..": '"..gameObject:GetName().."'"
end

-- Dynamic getters
function GameObject.__index(gameObject, key)
    if key == "tags" then
        return rawget(gameObject, key)
    end

    if GameObject[key] ~= nil then
        return GameObject[key]
    end

    local ucKey = key:ucfirst()
    local funcName = "Get"..ucKey
    if type(GameObject[funcName]) ~= "nil" then
        return GameObject[funcName](gameObject)
    end

    -- maybe the key is a Script name used to acces the Behavior instance
    local behavior = gameObject:GetScriptedBehavior(ucKey, true)
    if behavior ~= nil then
        rawset(gameObject, key, behavior)
        return behavior
    end

    -- maybe the key is a script alias
    local aliases = config.scriptPaths
    if aliases ~= nil and type(aliases) == "table" then
        local path = aliases[key]
        if path ~= nil then
            behavior = gameObject:GetScriptedBehavior(path, true)
            if behavior ~= nil then
                rawset(gameObject, key, behavior)
                return behavior
            end
        end
    end

    return nil
end

-- Dynamic setters
function GameObject.__newindex(gameObject, key, value)
    local funcName = "Set"..key:ucfirst()
    -- ie: variable "name" call "SetName"
    if GameObject[funcName] ~= nil then
        if key ~= "transform" then -- needed because CraftStudio.CreateGameObject() set the transfom variable on new gameObjects
            return GameObject[funcName](gameObject, value)
        end
    end
    rawset(gameObject, key, value)
end


----------------------------------------------------------------------------------

--- Create a new gameObject and optionally initialize it.
-- @param name (string) The GameObject name.
-- @param params [optional] (table) A table with parameters to initialize the new gameObject with.
-- @return (GameObject) The new gameObject.
function GameObject.New(name, params)
    Daneel.Debug.StackTrace.BeginFunction("GameObject.New", name, params)
    local errorHead = "GameObject.New(name[, params]) : "
    Daneel.Debug.CheckArgType(name, "name", "string", errorHead)
    Daneel.Debug.CheckOptionalArgType(params, "params", "table", errorHead)
    local gameObject = CraftStudio.CreateGameObject(name)
    if params ~= nil then
        gameObject:Set(params)
    end
    Daneel.Debug.StackTrace.EndFunction()
    return gameObject
end

--- Create a new gameObject with the content of the provided scene and optionally initialize it.
-- @param gameObjectName (string) The gameObject name.
-- @param sceneNameOrAsset (string or Scene) The scene name or scene asset.
-- @param params [optional] (table) A table with parameters to initialize the new gameObject with.
-- @return (GameObject) The new gameObject.
function GameObject.Instantiate(gameObjectName, sceneNameOrAsset, params)
    Daneel.Debug.StackTrace.BeginFunction("GameObject.Instantiate", gameObjectName, sceneNameOrAsset, params)
    local errorHead = "GameObject.Instantiate(gameObjectName, sceneNameOrAsset[, params]) : "
    Daneel.Debug.CheckArgType(gameObjectName, "gameObjectName", "string", errorHead)
    Daneel.Debug.CheckArgType(sceneNameOrAsset, "sceneNameOrAsset", {"string", "Scene"}, errorHead)
    Daneel.Debug.CheckOptionalArgType(params, "params", "table", errorHead)

    local scene = Asset.Get(sceneNameOrAsset, "Scene", true)   
    local gameObject = CraftStudio.Instantiate(gameObjectName, scene)
    if params ~= nil then
        gameObject:Set(params)
    end
    Daneel.Debug.StackTrace.EndFunction("GameObject.Instantiate", gameObject)
    return gameObject
end

--- Returns the first gameObject that was in the provided scene.
-- @param sceneNameOrAsset (string or Scene) The scene name or scene asset.
-- @param params [optional] (table) A table with parameters to initialize the new gameObject with.
-- @return (GameObject) The gameObject that was in the scene.
function GameObject.NewFromScene(sceneNameOrAsset, params)
    Daneel.Debug.StackTrace.BeginFunction("GameObject.NewFromScene",  sceneNameOrAsset, params)
    local errorHead = "GameObject.NewFromScene(sceneNameOrAsset[, params]) : "
    Daneel.Debug.CheckArgType(sceneNameOrAsset, "sceneNameOrAsset", {"string", "Scene"}, errorHead)
    Daneel.Debug.CheckOptionalArgType(params, "params", "table", errorHead)
    
    local scene = Asset.Get(sceneNameOrAsset, "Scene", true)
    local gameObject = CraftStudio.AppendScene(scene)
    if params ~= nil then
        gameObject:Set(params)
    end
    Daneel.Debug.StackTrace.EndFunction()
    return gameObject
end

--- Apply the content of the params argument to the provided gameObject.
-- @param gameObject (GameObject) The gameObject.
-- @param params (table) A table of parameters to set the gameObject with.
function GameObject.Set(gameObject, params)
    Daneel.Debug.StackTrace.BeginFunction("GameObject.Set", gameObject, params)
    local errorHead = "GameObject.Set(gameObject, params) : "
    Daneel.Debug.CheckArgType(params, "params", "table", errorHead)
    local argType = nil
    
    if params.parent ~= nil then
        -- do that first so that setting a local position works
        gameObject:SetParent(params.parent)
        params.parent = nil
    end
    
    -- components
    local component = nil
    local componentTypes = table.copy(config.componentTypes)
    table.removevalue(componentTypes, "ScriptedBehavior")
    for i, type in ipairs(componentTypes) do
        componentTypes[i] = type:lcfirst()
    end

    for i, componentType in ipairs(componentTypes) do
        if params[componentType] ~= nil then
            Daneel.Debug.CheckArgType(params[componentType], "params."..componentType, "table", errorHead)

            component = gameObject:GetComponent(componentType)
            if component == nil then
                component = gameObject:AddComponent(componentType)
            end

            component:Set(params[componentType])
            params[componentType] = nil
        end
    end

    -- all other keys/values
    for key, value in pairs(params) do
        -- if key is a script path or alias
        if config.scriptPaths[key] ~= nil or table.containsvalue(config.scriptPaths, key) then
            local scriptPath = key
            if config.scriptPaths[key] ~= nil then
                scriptPath = config.scriptPaths[key]
            end
            local component = gameObject:GetScriptedBehavior(scriptPath)
            if component == nil then
                component = gameObject:AddScriptedBehavior(scriptPath)
            end
            component:Set(value)
        elseif key == "tags"  then
            gameObject:RemoveTag()
            gameObject:AddTag(value)
        else
            gameObject[key] = value
        end
    end
    Daneel.Debug.StackTrace.EndFunction()
end


----------------------------------------------------------------------------------
-- Miscellaneous

--- Alias of CraftStudio.FindGameObject(name).
-- Get the first gameObject with the provided name.
-- @param name (string) The gameObject name.
-- @param errorIfGameObjectNotFound [optional default=false] (boolean) Throw an error if the gameObject was not found (instead of returning nil).
-- @return (GameObject) The gameObject or nil if none is found.
function GameObject.Get(name, errorIfGameObjectNotFound)
    Daneel.Debug.StackTrace.BeginFunction("GameObject.Get", name, errorIfGameObjectNotFound)
    if getmetatable(name) == GameObject then
        Daneel.Debug.StackTrace.EndFunction()
        return name
    end
    local errorHead = "GameObject.Get(name[, errorIfGameObjectNotFound]) : "
    Daneel.Debug.CheckArgType(name, "name", "string", errorHead)
    Daneel.Debug.CheckOptionalArgType(errorIfGameObjectNotFound, "errorIfGameObjectNotFound", "boolean", errorHead)
    
    local gameObject = CraftStudio.FindGameObject(name)
    if gameObject == nil and errorIfGameObjectNotFound == true then
        error(errorHead.."GameObject with name '"..name.."' was not found.")
    end
    Daneel.Debug.StackTrace.EndFunction()
    return gameObject
end

local OriginalSetParent = GameObject.SetParent

--- Set the gameObject's parent. 
-- Optionaly carry over the gameObject's local transform instead of the global one.
-- @param gameObject (GameObject) The gameObject.
-- @param parentNameOrInstance [optional] (string or GameObject) The parent name or gameObject (or nil to remove the parent).
-- @param keepLocalTransform [optional default=false] (boolean) Carry over the game object's local transform instead of the global one.
function GameObject.SetParent(gameObject, parentNameOrInstance, keepLocalTransform)
    Daneel.Debug.StackTrace.BeginFunction("GameObject.SetParent", gameObject, parentNameOrInstance, keepLocalTransform)
    local errorHead = "GameObject.SetParent(gameObject, [parentNameOrInstance, keepLocalTransform]) : "
    Daneel.Debug.CheckArgType(gameObject, "gameObject", "GameObject", errorHead)
    Daneel.Debug.CheckOptionalArgType(parentNameOrInstance, "parentNameOrInstance", {"string", "GameObject"}, errorHead)
    keepLocalTransform = Daneel.Debug.CheckOptionalArgType(keepLocalTransform, "keepLocalTransform", "boolean", errorHead, false)

    local parent = nil
    if parentNameOrInstance ~= nil then
        parent = GameObject.Get(parentNameOrInstance, true)
    end
    OriginalSetParent(gameObject, parent, keepLocalTransform)
    Daneel.Debug.StackTrace.EndFunction()
end

--- Alias of GameObject:FindChild().
-- Find the first gameObject's child with the provided name.
-- If the name is not provided, it returns the first child.
-- @param gameObject (GameObject) The gameObject.
-- @param name [optional] (string) The child name.
-- @param recursive [optional default=false] (boolean) Search for the child in all descendants instead of just the first generation.
-- @return (GameObject) The child or nil if none is found.
function GameObject.GetChild(gameObject, name, recursive)
    Daneel.Debug.StackTrace.BeginFunction("GameObject.GetChild", gameObject, name, recursive)
    local errorHead = "GameObject.GetChild(gameObject, name[, recursive]) : "
    Daneel.Debug.CheckArgType(gameObject, "gameObject", "GameObject", errorHead)
    Daneel.Debug.CheckOptionalArgType(name, "name", "string", errorHead)
    Daneel.Debug.CheckOptionalArgType(recursive, "recursive", "boolean", errorHead)
    
    local child = nil
    if name == nil then
        local children = gameObject:GetChildren()
        child = children[1]
    else
        child = gameObject:FindChild(name, recursive)
    end
    Daneel.Debug.StackTrace.EndFunction()
    return child
end

local OriginalGetChildren = GameObject.GetChildren

--- Get all descendants of the gameObject.
-- @param gameObject (GameObject) The gameObject.
-- @param recursive [optional default=false] (boolean) Look for all descendants instead of just the first generation.
-- @param includeSelf [optional default=false] (boolean) Include the gameObject in the children.
-- @return (table) The children.
function GameObject.GetChildren(gameObject, recursive, includeSelf)
    Daneel.Debug.StackTrace.BeginFunction("GameObject.GetChildren", gameObject, recursive, includeSelf)
    local errorHead = "GameObject.GetChildrenRecursive(gameObject[, recursive, includeSelf]) : "
    Daneel.Debug.CheckArgType(gameObject, "gameObject", "GameObject", errorHead)
    Daneel.Debug.CheckOptionalArgType(recursive, "recursive", "boolean", errorHead)
    Daneel.Debug.CheckOptionalArgType(includeSelf, "includeSelf", "boolean", errorHead)
    
    local allChildren = table.new()
    if includeSelf == true then
        allChildren:insert(gameObject)
    end
    local selfChildren = OriginalGetChildren(gameObject)
    if recursive == true then
        -- get the rest of the children
        for i, child in ipairs(selfChildren) do
            allChildren = allChildren:merge(child:GetChildren(true, true))
        end
    else
        allChildren = allChildren:merge(selfChildren)
    end
    Daneel.Debug.StackTrace.EndFunction("GameObject.GetChildren", allChildren)
    return allChildren
end

local OriginalSendMessage = GameObject.SendMessage

--- Tries to call a method with the provided name on all the scriptedBehaviors attached to the gameObject. 
-- The data argument can be nil or a table you want the method to receive as its first (and only) argument.
-- If none of the scripteBehaviors attached to the gameObject or its children have a method matching the provided name, nothing happens. 
-- @param gameObject (GameObject) The gameObject.
-- @param functionName (string) The method name.
-- @param data [optional] (table) The data to pass along the method call.
function GameObject.SendMessage(gameObject, functionName, data)
    Daneel.Debug.StackTrace.BeginFunction("GameObject.SendMessage", gameObject, functionName, data)
    local errorHead = "GameObject.SendMessage(gameObject, functionName[, data]) : "
    Daneel.Debug.CheckArgType(gameObject, "gameObject", "GameObject", errorHead)
    Daneel.Debug.CheckArgType(functionName, "functionName", "string", errorHead)
    Daneel.Debug.CheckOptionalArgType(data, "data", "table", errorHead)
    
    OriginalSendMessage(gameObject, functionName, data)
    Daneel.Debug.StackTrace.EndFunction("GameObject.SendMessage")
end

--- Tries to call a method with the provided name on all the scriptedBehaviors attached to the gameObject or any of its descendants. 
-- The data argument can be nil or a table you want the method to receive as its first (and only) argument.
-- If none of the scripteBehaviors attached to the gameObject or its children have a method matching the provided name, nothing happens. 
-- @param gameObject (GameObject) The gameObject.
-- @param functionName (string) The method name.
-- @param data [optional] (table) The data to pass along the method call.
function GameObject.BroadcastMessage(gameObject, functionName, data)
    Daneel.Debug.StackTrace.BeginFunction("GameObject.BroadcastMessage", gameObject, functionName, data)
    local errorHead = "GameObject.BroadcastMessage(gameObject, functionName[, data]) : "
    Daneel.Debug.CheckArgType(gameObject, "gameObject", "GameObject", errorHead)
    Daneel.Debug.CheckArgType(functionName, "functionName", "string", errorHead)
    Daneel.Debug.CheckOptionalArgType(data, "data", "table", errorHead)
    
    local allGos = gameObject:GetChildren(true, true) -- the gameObject + all of its children
    for i, go in ipairs(allGos) do
        go:SendMessage(functionName, data)
    end
    Daneel.Debug.StackTrace.EndFunction("GameObject.BroadcastMessage")
end


----------------------------------------------------------------------------------
-- Add components

--- Add a component to the gameObject and optionally initialize it.
-- @param gameObject (GameObject) The gameObject.
-- @param componentType (string) The component type.
-- @param params [optional] (string, Script or table) A table of parameters to initialize the new component with or, if componentType is 'ScriptedBehavior', the mandatory script name or asset.
-- @param scriptedBehaviorParams [optional] (table) A table of parameters to initialize the new ScriptedBehavior with.
-- @return (ScriptedBehavior, ModelRenderer, MapRenderer, Camera or Physics) The component.
function GameObject.AddComponent(gameObject, componentType, params, scriptedBehaviorParams)
    Daneel.Debug.StackTrace.BeginFunction("GameObject.AddComponent", gameObject, componentType, params, scriptedBehaviorParams)
    local errorHead = "GameObject.AddComponent(gameObject, componentType[, params, scriptedBehaviorParams]) : "
    Daneel.Debug.CheckArgType(gameObject, "gameObject", "GameObject", errorHead)
    componentType = Daneel.Debug.CheckComponentType(componentType)
    if componentType == "Transform" and DEBUG == true then
        print(errorHead.."Can't add a transform component because gameObjects may only have one transform.")
        Daneel.Debug.StackTrace.EndFunction()
        return
    end

    local component = nil

    -- ScriptedBehavior
    if componentType == "ScriptedBehavior" then
        Daneel.Debug.CheckArgType(params, "params", {"string", "Script"}, errorHead)
        local script = Asset.Get(params, "Script", true)
        Daneel.Debug.CheckOptionalArgType(scriptedBehaviorParams, "scriptedBehaviorParams", "table", errorHead)
        params = scriptedBehaviorParams
        component = gameObject:CreateScriptedBehavior(script)
        
    -- other componentTypes
    else
        Daneel.Debug.CheckOptionalArgType(params, "params", "table", errorHead)

        if componentType:isoneof(config.daneelComponentTypes) then
            component = Daneel.GUI[componentType].New(gameObject)
        else
            component = gameObject:CreateComponent(componentType)
        end
    end

    if params ~= nil then
        component:Set(params)
    end   
    Daneel.Event.Fire(component, "OnNewComponent", component)
    Daneel.Debug.StackTrace.EndFunction()
    return component
end

--- Add a ScriptedBehavior to the gameObject and optionally initialize it.
-- @param gameObject (GameObject) The gameObject.
-- @param scriptNameOrAsset (string or Script) The script name or asset.
-- @param params [optional] (table) A table of parameters to initialize the new component with.
-- @return (ScriptedBehavior) The component.
function GameObject.AddScriptedBehavior(gameObject, scriptNameOrAsset, params) 
    Daneel.Debug.StackTrace.BeginFunction("GameObject.AddScriptedBehavior", gameObject, scriptNameOrAsset, params)
    local errorHead = "GameObject.AddScriptedBehavior(gameObject, scriptNameOrAsset[, params]) : "
    Daneel.Debug.CheckArgType(gameObject, "gameObject", "GameObject", errorHead)
    
    local component = gameObject:AddComponent("ScriptedBehavior", scriptNameOrAsset, params)
    Daneel.Debug.StackTrace.EndFunction("GameObject.AddScriptedBehavior", component)
    return component
end

--- Add a ModelRenderer to the gameObject and optionally initialize it.
-- @param gameObject (GameObject) The gameObject.
-- @param params [optional] (table) A table of parameters to initialize the new component with.
-- @return (ModelRenderer) The component.
function GameObject.AddModelRenderer(gameObject, params) end

--- Add a MapRenderer to the gameObject and optionally initialize it.
-- @param gameObject (GameObject) The gameObject.
-- @param params [optional] (table) A table of parameters to initialize the new component with.
-- @return (MapRenderer) The component.
function GameObject.AddMapRenderer(gameObject, params) end

--- Add a Camera to the gameObject and optionally initialize it.
-- @param gameObject (GameObject) The gameObject.
-- @param params [optional] (table) A table of parameters to initialize the new component with.
-- @return (Camera) The component.
function GameObject.AddCamera(gameObject, params) end

--- Add a Physics component to the gameObject and optionally initialize it.
-- @param gameObject (GameObject) The gameObject.
-- @param params [optional] (table) A table of parameters to initialize the new component with.
-- @return (Physics) The component.
function GameObject.AddPhysics(gameObject, params) end

--- Add a TextRenderer component to the gameObject and optionally initialize it.
-- @param gameObject (GameObject) The gameObject.
-- @param params [optional] (table) A table of parameters to initialize the new component with.
-- @return (TextRenderer) The component.
function GameObject.AddTextRenderer(gameObject, params) end

--- Add a NetworkSync component to the gameObject and optionally initialize it.
-- @param gameObject (GameObject) The gameObject.
-- @param params [optional] (table) A table of parameters to initialize the new component with.
-- @return (NetworkSync) The component.
function GameObject.AddNetworkSync(gameObject, params) end

--- Add a Hud component to the gameObject and optionally initialize it.
-- @param gameObject (GameObject) The gameObject.
-- @param params [optional] (table) A table of parameters to initialize the new component with.
-- @return (Daneel.GUI.Hud) The component.
function GameObject.AddHud(gameObject, params) end

--- Add a CheckBox component to the gameObject and optionally initialize it.
-- @param gameObject (GameObject) The gameObject.
-- @param params [optional] (table) A table of parameters to initialize the new component with.
-- @return (Daneel.GUI.CheckBox) The component.
function GameObject.AddCheckBox(gameObject, params) end

--- Add a ProgressBar component to the gameObject and optionally initialize it.
-- @param gameObject (GameObject) The gameObject.
-- @param params [optional] (table) A table of parameters to initialize the new component with.
-- @return (Daneel.GUI.ProgressBar) The component.
function GameObject.AddProgressBar(gameObject, params) end

--- Add a Slider component to the gameObject and optionally initialize it.
-- @param gameObject (GameObject) The gameObject.
-- @param params [optional] (table) A table of parameters to initialize the new component with.
-- @return (Daneel.GUI.Slider) The component.
function GameObject.AddSlider(gameObject, params) end

-- The actual code of the helpers is generated at runtime in Daneel.Awake()
-- The declaration are written here to shows up in the documentation generated by LuaDoc


----------------------------------------------------------------------------------
-- Set Component

--- Set the component of the provided type on the gameObject with the provided parameters.
-- @param gameObject (GameObject) The gameObject.
-- @param componentType (string) The component type.
-- @param params (string, Script or table) A table of parameters to set the component with or, if componentType is 'ScriptedBehavior', the script name or asset.
-- @param scriptedBehaviorParams [optional] (table) If componentType is 'ScriptedBehavior', the mandatory table of parameters to set the ScriptedBehavior with.
function GameObject.SetComponent(gameObject, componentType, params, scriptedBehaviorParams)
    Daneel.Debug.StackTrace.BeginFunction("GameObject.SetComponent", gameObject, componentType, params, scriptedBehaviorParams)
    local errorHead = "GameObject.SetComponent(gameObject, componentType, params[, scriptedBehaviorParams]) : "
    Daneel.Debug.CheckArgType(gameObject, "gameObject", "GameObject", errorHead)
    componentType = Daneel.Debug.CheckComponentType(componentType)
    
    local component = nil

    -- ScriptedBehavior
    if componentType == "ScriptedBehavior" then
        Daneel.Debug.CheckArgType(params, "params", {"string", "Script"}, errorHead)
        local script = Asset.Get(params, "Script")
        Daneel.Debug.CheckArgType(scriptedBehaviorParams, "scriptedBehaviorParams", "table", errorHead)
        params = scriptedBehaviorParams
        component = gameObject:GetScriptedBehavior(script)
        
    -- other componentTypes
    else
        Daneel.Debug.CheckArgType(params, "params", "table", errorHead)
        component = gameObject:GetComponent(componentType)
    end

    if component == nil then
        error(errorHead.."Component of type '"..componentType.."' was not found.")
    else
        component:Set(params)
    end

    Daneel.Debug.StackTrace.EndFunction("GameObject.SetComponent")
end

--- Set the ScriptedBehavior component on the gameObject with the provided parameters.
-- @param gameObject (GameObject) The gameObject.
-- @param scriptNameOrAsset (string or Script) The script name or asset.
-- @param params (table) A table of parameters to set the component with.
function GameObject.SetScriptedBehavior(gameObject, scriptNameOrAsset, params)
    Daneel.Debug.StackTrace.BeginFunction("GameObject.SetScriptedBehavior", gameObject, scriptNameOrAsset, params)
    local errorHead = "GameObject.SetScriptedBehavior(gameObject, scriptNameOrAsset, params) : "
    Daneel.Debug.CheckArgType(gameObject, "gameObject", "GameObject", errorHead)
    
    local component = gameObject:SetComponent("ScriptedBehavior", scriptNameOrAsset, params)
    Daneel.Debug.StackTrace.EndFunction("GameObject.SetScriptedBehavior")
end

-- SetComponent helpers do not exist since it makes more sense (?) to use self.gameObject.component:Set()


----------------------------------------------------------------------------------
-- Get components

--- Get the first component of the provided type attached to the gameObject.
-- @param gameObject (GameObject) The gameObject.
-- @param componentType (string) The component type.
-- @param scriptNameOrAsset [optional] (string or Script) If componentType is "ScriptedBehavior", the mandatory script name or asset.
-- @return (ScriptedBehavior, ModelRenderer, MapRenderer, Camera, Transform or Physics) The component instance, or nil if none is found.
function GameObject.GetComponent(gameObject, componentType, scriptNameOrAsset)
    Daneel.Debug.StackTrace.BeginFunction("GameObject.GetComponent", gameObject, componentType, scriptNameOrAsset)
    local errorHead = "GameObject.GetComponent(gameObject, componentType[, scriptNameOrAsset]) : "
    Daneel.Debug.CheckArgType(gameObject, "gameObject", "GameObject", errorHead)
    componentType = Daneel.Debug.CheckComponentType(componentType)
    
    local component = nil
    if componentType == "ScriptedBehavior" then
        Daneel.Debug.CheckArgType(scriptNameOrAsset, "scriptNameOrAsset", {"string", "Script"}, errorHead)
        component = gameObject:GetScriptedBehavior(scriptNameOrAsset)
    else
        component = gameObject[componentType:lcfirst()]
    end
    Daneel.Debug.StackTrace.EndFunction("GameObject.GetComponent", component)
    return component
end

local OriginalGetScriptedBehavior = GameObject.GetScriptedBehavior

--- Get the provided ScriptedBehavior instance attached to the gameObject.
-- @param gameObject (GameObject) The gameObject.
-- @param scriptNameOrAsset (string or Script) The script name or asset.
-- @return (ScriptedBehavior) The ScriptedBehavior instance.
function GameObject.GetScriptedBehavior(gameObject, scriptNameOrAsset, calledFrom__index)
    -- why do I check if the call comes from __index ?
    if calledFrom__index ~= true then
        Daneel.Debug.StackTrace.BeginFunction("GameObject.GetScriptedBehavior", gameObject, scriptNameOrAsset)
        local errorHead = "GameObject.GetScriptedBehavior(gameObject, scriptNameOrAsset) : "
        Daneel.Debug.CheckArgType(gameObject, "gameObject", "GameObject", errorHead)
        Daneel.Debug.CheckArgType(scriptNameOrAsset, "scriptNameOrAsset", {"string", "Script"}, errorHead)
    end

    local script = scriptNameOrAsset
    if type(scriptNameOrAsset) == "string" then
        script = Asset.Get(scriptNameOrAsset, "Script")
        if script == nil then
            if calledFrom__index == true then
                return nil
            else
                error(errorHead.."Argument 'scriptNameOrAsset' : Script asset with name '"..scriptNameOrAsset.."' was not found.")
            end 
        end
    end
    local component = OriginalGetScriptedBehavior(gameObject, script)
    if calledFrom__index ~= true then
        Daneel.Debug.StackTrace.EndFunction("GameObject.GetScriptedBehavior", component)
    end
    return component
end

-- GetComponent helpers does not exists since the components are accessible on the gameObject via their "variable" like the transform


----------------------------------------------------------------------------------
-- Destroy gameObject

--- Destroy the gameObject at the end of this frame.
-- @param gameObject (GameObject) The gameObject.
function GameObject.Destroy(gameObject)
    Daneel.Debug.StackTrace.BeginFunction("GameObject.Destroy", gameObject)
    local errorHead = "GameObject.Destroy(gameObject) : "
    Daneel.Debug.CheckArgType(gameObject, "gameObject", "GameObject", errorHead)

    CraftStudio.Destroy(gameObject)
    Daneel.Debug.StackTrace.EndFunction()
end


----------------------------------------------------------------------------------
-- Tags

GameObject.tags = {
    mouseInteractive = {},
}

--- Add the provided tag(s) to the provided gameObject.
-- @param gameObject (GameObject) The gameObject.
-- @param tag (string or table) One or several tag(s) (as a string or table of strings).
function GameObject.AddTag(gameObject, tag)
    Daneel.Debug.StackTrace.BeginFunction("GameObject.AddTag", gameObject, tag)
    local errorHead = "GameObject.AddTag(gameObject, tag)"
    Daneel.Debug.CheckArgType(gameObject, "gameObject", "GameObject", errorHead)
    Daneel.Debug.CheckArgType(tag, "tag", {"string", "table"}, errorHead)
    
    local tags = tag
    if type(tags) == "string" then
        tags = { tags }
    end
    if gameObject.tags == nil then
        gameObject.tags = table.new()
    end
    for i, tag in ipairs(tags) do
        if not table.containsvalue(gameObject.tags, tag) then
            table.insert(gameObject.tags, tag)
        end
        if GameObject.tags[tag] == nil then
            GameObject.tags[tag] = { gameObject }
        else
            table.insert(GameObject.tags[tag], gameObject)
        end
    end
    Daneel.Debug.StackTrace.EndFunction()
end

--- Remove the provided tag(s) from the provided gameObject.
-- If the 'tag' argument is not provided, all tag of the gameObject will be removed.
-- @param gameObject (GameObject) The gameObject.
-- @param tag [optional] (string or table) One or several tag(s) (as a string or table of strings).
function GameObject.RemoveTag(gameObject, tag)
    if gameObject.tags == nil then return end
    Daneel.Debug.StackTrace.BeginFunction("GameObject.RemoveTag", gameObject, tag)
    local errorHead = "GameObject.RemoveTag(gameObject[, tag])"
    Daneel.Debug.CheckArgType(gameObject, "gameObject", "GameObject", errorHead)
    tag = Daneel.Debug.CheckOptionalArgType(tag, "tag", {"string", "table"}, errorHead, gameObject.tags)
    
    local tags = tag
    if type(tags) == "string" then
        tags = { tags }
    end
    for i, tag in ipairs(tags) do
        table.removevalue(gameObject.tags, tag)
        if GameObject.tags[tag] ~= nil then
            table.removevalue(GameObject.tags[tag], gameObject)
        end
    end
    Daneel.Debug.StackTrace.EndFunction()
end

--- Tell wether the provided gameObject has all (or at least one of) the provided tag.
-- @param gameObject (GameObject) The gameObject.
-- @param tag (string or table) One or several tag (as a string or table of strings).
-- @param atLeastOneTag [default=false] (boolean) If true, returns true if the gameObject has AT LEAST one of the tag (instead of ALL the tag).
-- @return (boolean) True
function GameObject.HasTag(gameObject, tag, atLeastOneTag)
    if gameObject.tags == nil then return false end
    Daneel.Debug.StackTrace.BeginFunction("GameObject.HasTag", gameObject, tag, atLeastOneTag)
    local errorHead = "GameObject.HasTag(gameObject, tag)"
    Daneel.Debug.CheckArgType(gameObject, "gameObject", "GameObject", errorHead)
    Daneel.Debug.CheckArgType(tag, "tag", {"string", "table"}, errorHead, {})
    Daneel.Debug.CheckOptionalArgType(atLeastOneTag, "atLeastOneTag", "boolean", errorHead)

    local tags = tag
    if type(tags) == "string" then
        tags = { tags }
    end
    local hasTags = false
    if atLeastOneTag == true then
        for i, tag in ipairs(tags) do
            if table.containsvalue(gameObject.tags, tag) then
                hasTags = true
                break
            end
        end
    else
        hasTags = true
        for i, tag in ipairs(tags) do
            if not table.containsvalue(gameObject.tags, tag) then
                hasTags = false
                break
            end
        end
    end
    Daneel.Debug.StackTrace.EndFunction()
    return hasTags
end
