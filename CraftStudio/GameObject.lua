

function GameObject.__tostring(go)
    -- same story as components
    local id = tostring(go.inner):sub(2,20)
    return "GameObject: '"..go:GetName().."' "..id
end

-- Dynamic getters
function GameObject.__index(go, key) 
    local funcName = "Get"..key:ucfirst()
    
    if GameObject[funcName] ~= nil then
        return GameObject[funcName](go)
    elseif GameObject[key] ~= nil then
        return GameObject[key] -- have to return the function here, not the function return value !
    end
    
    return rawget(go, key)
end

-- Dynamic setters
function GameObject.__newindex(go, key, value)
    local funcName = "Set"..key:ucfirst()
    -- ie: variable "name" call "SetName"
    
    if GameObject[funcName] ~= nil then
        return GameObject[funcName](go, value)
    end
    
    rawset(go, key, value)
end



----------------------------------------------------------------------------------



--- Create a new gameObject with optional initialisation parameters.
-- @param name (string) The GameObject name.
-- @param params [optional] (string, GameObject or table) The parent gameObject name, or parent GameObject or a table with parameters to initialize the new gameObject with.
-- @return (GameObject) The new gameObject.
function GameObject.New(name, params)
    Daneel.StackTrace.BeginFunction("GameObject.New", name, params)
    local errorHead = "GameObject.New(name[, params]) : "
    Daneel.Debug.CheckArgType(name, "name", "string", errorHead)
    Daneel.Debug.CheckOptionalArgType(params, "params", {"string", "GameObject", "table"}, errorHead)

    if params ~= nil and type(params) ~= "table" then -- param is parent name or gameObject
        params = {parent = params}
    end

    local go = CraftStudio.CreateGameObject(name)
    if params ~= nil then
        go:Set(params)
    end

    Daneel.StackTrace.EndFunction("GameObject.New", go)
    return go
end

--- Add a scene as a new gameObject with optional initialisation parameters.
-- @param goName (string) The gameObject name.
-- @param scene (string or Scene) The scene name or scene asset.
-- @param params [optional] (string, GameObject or table) The parent gameObject name, or parent GameObject or a table with parameters to initialize the new gameObject with.
-- @return (GameObject) The new gameObject.
function GameObject.Instantiate(goName, scene, params)
    Daneel.StackTrace.BeginFunction("GameObject.Instantiate", goName, scene, params)
    local errorHead = "GameObject.Instantiate(gameObjectName, sceneName[, params]) : "
    Daneel.Debug.CheckArgType(goName, "goName", "string", errorHead)
    Daneel.Debug.CheckArgType(scene, "scene", {"string", "Scene"}, errorHead)
    Daneel.Debug.CheckOptionalArgType(params, "params", {"string", "GameObject", "table"}, errorHead)

    if type(scene) == "string" then
        local sceneName = scene
        scene = Asset.Get(sceneName, "Scene")

        if scene == nil then
            daneelerror(errorHead.."Argument 'scene' : Scene asset with name '"..sceneName.."' was not found.")
        end
    end

    if params ~= nil and type(params) ~= "table" then -- param is parent name or gameObject
        params = {parent = params}
    end
    
    local go = CraftStudio.Instantiate(goName, scene)
    if params ~= nil then
        go:Set(params)
    end

    Daneel.StackTrace.EndFunction("GameObject.Instantiate", go)
    return go
end

--- Apply the content of the params argument to the gameObject in argument.
-- @param gameObject (GameObject) The gameObject
-- @param params (table)
-- @return (GameObject) The gameObject
function GameObject.Set(gameObject, params)
    if params == nil then
        return gameObject
    end

    Daneel.StackTrace.BeginFunction("GameObject.Set", gameObject, params)
    local errorHead = "GameObject.Set(gameObject, params) : "
    Daneel.Debug.CheckArgType(params, "params", "table", errorHead)
    local argType = nil

    -- name
    if params.name ~= nil then
        Daneel.Debug.CheckArgType(params.name, "params.name", "string", errorHead)
        gameObject:SetName(params.name)
    end

    -- parent
    if params.parent ~= nil then 
        Daneel.Debug.CheckArgType(params.parent, "params.parent", {"string", "GameObject"}, errorHead)
        Daneel.Debug.CheckOptionalArgType(params.parentKeepLocalTransform, "params.parentKeepLocalTransform", "boolean", errorHead)
        gameObject:SetParent(params.parent, params.parentKeepLocalTransform)
    end

    local component = nil

    -- scripts
    if params.scriptedBehaviors == nil then
        params.scriptedBehaviors = {}
    end

    if params.scriptedBehavior ~= nil then
        table.insert(params.scriptedBehaviors, params.scriptedBehavior)
    end

    for i, script in pairs(params.scriptedBehaviors) do
        argType = Daneel.Debug.GetType(script)
        if argType ~= "string" and argType ~= "Script" and argType ~= "table" then
            daneelerror(errorHead.."Item n°"..i.." in argument 'params.scriptedBehaviors' is of type '"..argType.."' with value '"..tostring(scriptNameOrAsset).."' instead of 'string', 'Script' or 'table'.")
        end

        local scriptParams = nil
        if argType == "table" then
            scriptParams = script
            script = i
        end

        component = gameObject:GetScriptedBehavior(script)
        
        if component == nil then
            component = gameObject:AddScriptedBehavior(script)
        end

        if scriptParams ~= nil then
            component:Set(scriptParams)
        end
    end 

    -- others components
    for i, componentType in ipairs({"modelRenderer", "mapRenderer", "camera"}) do
        if params[componentType] ~= nil then
            Daneel.Debug.CheckArgType(params[componentType], "params."..componentType, "table", errorHead)
            local ComponentType = componentType:ucfirst()
            component = gameObject:GetComponent(ComponentType)
            
            if component == nil then
                component = gameObject:AddComponent(ComponentType)
            end

            component:Set(params[componentType])
        end
    end

    if params.transform ~= nil then
        Daneel.Debug.CheckArgType(params.transform, "params.transform", "table", errorHead)
        gameObject.transform:Set(params.transform)
    end

    Daneel.StackTrace.EndFunction("GameObject.Set", gameObject)
    return gameObject
end


----------------------------------------------------------------------------------
-- Miscellaneous


--- Alias of CraftStudio.FindGameObject(name).
-- Get the first gameObject with the specified name.
-- @param name (string) The gameObject name.
-- @return (GameObject) The gameObject or nil if none is found.
function GameObject.Get(name)
    Daneel.StackTrace.BeginFunction("GameObject.Get", name)

    local argType = type(name)
    if argType ~= "string" then
        error("GameObject.Get(name) : Argument 'name' is of type '"..argType.."' with value '"..tostring(name).."' instead of 'string'. Must be the gameObject name.")
    end

    local go = CraftStudio.FindGameObject(name)

    Daneel.StackTrace.EndFunction("GameObject.Get", go)
    return go
end


local OriginalSetParent = GameObject.SetParent

--- Set the gameOject's parent. 
-- Optionnaly carry over the gameObject's local transform instead of the global one.
-- @param gameObject (GameObject) The gameObject
-- @param parent (string or GameObject) The parent name or gameObject.
-- @param keepLocalTransform [optional default=false] (boolean) Carry over the game object's local transform instead of the global one.
-- @return (GameObject) The gameObject.
function GameObject.SetParent(gameObject, parent, keepLocalTransform)
    Daneel.StackTrace.EndFunction("GameObject.SetParent", gameObject, parent, keepLocalTransform)
    local errorHead = "GameObject.SetParent(gameObject, parent[, keepLocalTransform]) : "
    Daneel.Debug.CheckArgType(gameObject, "gameObject", "GameObject", errorHead)
    Daneel.Debug.CheckArgType(parent, "parent", {"string", "GameObject"}, errorHead)
    Daneel.Debug.CheckOptionalArgType(keepLocalTransform, "keepLocalTransform", "boolean", errorHead)
    
    if keepLocalTransform == nil then
        keepLocalTransform = false
    end

    if type(parent) == "string" then
        local parentName = parent
        parent = GameObject.Get(parentName)

        if parent == nil then
            daneelerror(errorHead.."Argument 'parent' : Parent gameObject with name '"..parentName.."' was not found.")
        end
    end
      
    OriginalSetParent(go, parent, keepLocalTransform)
    Daneel.StackTrace.EndFunction("GameObject.SetParent")
end


--- Alias of GameObject:FindChild().
-- Find the first gameObject's child with the specified name.
-- @param gameObject (GameObject) The gameObject
-- @param name (string) The child name.
-- @param recursive [optional default=false] (boolean) Search for the child in all descendants.
-- @return (GameObject) The child or nil if none is found.
function GameObject.GetChild(go, name, recursive)
    Daneel.StackTrace.BeginFunction("GameObject.GetChild", go, name, recursive)
    local errorHead = "GameObject.GetChild(gameObject, name[, recursive]) : "

    local argType = Daneel.Debug.GetType(go)
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

--- Get all descendants of the gameObject.
-- @param gameObject (GameObject) The gameObject
-- @param recursive [optional default=false] (boolean) Look for all descendants instead of just the first generation
-- @param includeSelf [optional default=false] (boolean) Include the gameObject in the children.
-- @return (table) The children.
function GameObject.GetChildren(go, recursive, includeSelf)
    Daneel.StackTrace.BeginFunction("GameObject.GetChildren", go, recursive, includeSelf)
    local errorHead = "GameObject.GetChildrenRecursive(gameObject, [recursive]) : "

    local argType = Daneel.Debug.GetType(go)
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


--- Tries to call a method with the specified name on all the scripted behaviors attached to the gameObject
-- or any of its descendants. 
-- The data argument can be nil or a table you want the method to receive as its first (and only) argument.
-- If none of the scripted behaviors attached to the game object or its children have a method matching the specified name, nothing happens. 
-- Uses GameObject:SendMessage() on the gameObject and all children of its children.
-- @param gameObject (GameObject) The gameObject
-- @param functionName (string) The method name.
-- @param data [optional] (table) The data to pass along the method call.
function GameObject.BroadcastMessage(go, functionName, data)
    Daneel.StackTrace.BeginFunction("GameObject.BroadcastMessage", go, functionName, data)
    local errorHead = "GameObject.BroadcastMessage(gameObject, functionName[, data]) : "

    Daneel.Debug.CheckArgType(go, "gameObject", "GameObject", errorHead)
    Daneel.Debug.CheckArgType(functionName, "functionName", "string", errorHead)
    Daneel.Debug.CheckOptionalArgType(data, "data", "table", errorHead)

    local allChildren = table.join({go}, go:GetChildren())

    for i, child in ipairs(allChildren) do
        child:SendMessage(functionName, data)
    end

    Daneel.StackTrace.EndFunction("GameObject.BroadcastMessage")
end



----------------------------------------------------------------------------------
-- Add components


--- Add a component to the gameObject and optionaly initialize it.
-- @param gameObject (GameObject) The gameObject
-- @param componentType (string) The Component type.
-- @param params [optional] (string, Script or table) The script name or asset, or a table of parameters to initialize the new component with. If componentType is 'ScriptedBehavior', this argument is not optional.
-- @return (ScriptedBehavior, ModelRenderer, MapRenderer, Camera or Transform) The component.
function GameObject.AddComponent(gameObject, componentType, params)
    Daneel.StackTrace.BeginFunction("GameObject.AddComponent")
    local errorHead = "GameObject.AddComponent(gameObject, componentType[, params]) : "
    Daneel.Debug.CheckArgType(go, "gameObject", "GameObject", errorHead)
    Daneel.Debug.CheckArgType(componentType, "componentType", Daneel.config.componentTypes, errorHead)
    
    componentType = Daneel.Utilities.CaseProof(componentType, Daneel.config.componentTypes)
    
    if componentType == "Transform" then
        print(errorHead.."WARNING : Can't add a transform because gameObjects may only have one transform.")
        Daneel.StackTrace.EndFunction("GameObject.AddComponent", gameObject.transform)
        return gameObject.transform
    end

    local component = nil

    -- ScriptedBehavior
    if componentType == "ScriptedBehavior" then
        Daneel.Debug.CheckArgType(params, "params", {"string", "Script", "table"}, errorHead)
        local script = nil
        if type(params) == "table" then
            for _script, _params in pairs(params) do
                script = _script
                params = _params
                break
            end

            -- I shouldn't really use CheckArgType here since they are not really arguments ...
            Daneel.Debug.CheckArgType(script, "script", {"string", "Script"}, errorHead)
            Daneel.Debug.CheckArgType(params, "params", "table", errorHead)
        end

        component = gameObject:CreateScriptedBehavior(script)
    else
        -- other componentTypes
        Daneel.Debug.CheckOptionalArgType(params, "params", "table", errorHead)
        component = gameObject:CreateComponent(componentType)
    end

    if params ~= nil then
        component:Set(params)
    end   

    Daneel.StackTrace.EndFunction("GameObject.AddComponent", component)
    return component
end

local OriginalCreateScriptedBehavior = GameObject.CreateScriptedBehavior

--- Create a ScritedBahevior on the provided gameObject
-- @param gameObject (GameObject) The gameObject
-- @param params (string, Script, table) The script name or asset or a table of parameters to initialize the new component with.
-- @return (ScriptedBehavior) The component.
function GameObject.CreateScriptedBehavior(gameObject, script)
    -- local argType = Daneel.Debug.GetType(params)

    -- if argType == "string" then
    --     local assetType = Daneel.config.componentTypeToAssetType[componentType]
    --     local assetName = params
    --     local asset = Asset.Get(assetName, assetType)
        
    --     if asset == nil then
    --         error(errorHead.."Asset not found. Component type='"..componentType.."', asset type='"..assetType.."', asset name='"..assetName.."'.")
    --     end

    --     params = { [assetType:lower()] = asset }
    -- end


    -- if params.script == nil then
    --     error(errorHead.."Argument 'componentType' is 'ScriptedBehavior' but argument 'params.script' is nil.")
    -- end
end

--- Add a ScriptedBehavior to the gameObject and optionaly initialize it.
-- @param gameObject (GameObject) The gameObject
-- @param params (string, Script, table) The script name or asset or a table of parameters to initialize the new component with.
-- @return (ScriptedBehavior) The component.
function GameObject.AddScriptedBehavior(gameObject, params) end

--- Add a ModelRenderer to the gameObject and optionaly initialize it.
-- @param gameObject (GameObject) The gameObject
-- @param params [optional] (table) A table of parameters to initialize the new component with.
-- @return (ModelRenderer) The component.
function GameObject.AddModelRenderer(gameObject, params) end

--- Add a MapRenderer to the gameObject and optionaly initialize it.
-- @param gameObject (GameObject) The gameObject
-- @param params [optional] (table) A table of parameters to initialize the new component with.
-- @return (MapRenderer) The component.
function GameObject.AddMapRenderer(gameObject, params) end

--- Add a Camera to the gameObject and optionaly initialize it.
-- @param gameObject (GameObject) The gameObject
-- @param params [optional] (table) A table of parameters to initialize the new component with.
-- @return (Camera) The component.
function GameObject.AddCamera(gameObject, params) end

-- The actual code of the helpers is generated at runtime in GameObject.Init() below
-- The declaration are written here to shows up in the documentation generated by LuaDoc

----------------------------------------------------------------------------------
-- Get components


local OriginalGetScriptedBehavior = GameObject.GetScriptedBehavior

--- Get the specified ScriptedBehavior instance attached to the gameObject.
-- @param gameObject (GameObject) The gameObject
-- @param scriptNameOrAsset (string or Script) The script name or asset.
-- @return (ScriptedBehavior) The ScriptedBehavior instance.
function GameObject.GetScriptedBehavior(gameObject, scriptNameOrAsset)
    Daneel.StackTrace.BeginFunction("GameObject.GetScriptedBehavior", gameObject, scriptNameOrAsset)
    local errorHead = "GameObject.GetScriptedBehavior(gameObject, scriptNameOrAsset) : "
    Daneel.Debug.CheckArgType(gameObject, "gameObject", "GameObject", errorHead)
    Daneel.Debug.CheckArgType(scriptNameOrAsset, "scriptNameOrAsset", {"string", "Script"}, errorHead)

    local script = scriptNameOrAsset

    if type(scriptNameOrAsset) == "string" then
        script = Asset.Get(scriptNameOrAsset, "Script")
        if script == nil then
            Daneel.Debug.PrintError(errorHead.."Argument 'scriptNameOrAsset' : Script asset with name '"..scriptNameOrAsset.."' was not found.")
        end
    end

    local component = OriginalGetScriptedBehavior(gameObject, script)
    Daneel.StackTrace.EndFunction("GameObject.GetScriptedBehavior", component)
    return component
end

-- + helpers, see in Init() below


----------------------------------------------------------------------------------
-- Destroy gameObjects and components


--- Destroy the gameObject
-- @param gameObject (GameObject) The gameObject
function GameObject.Destroy(go)
    Daneel.StackTrace.BeginFunction("GameObject.Destroy", go)
    local errorHead = "GameObject.Destroy(gameObject) : "
    
    Daneel.Debug.CheckArgType(go, "gameObject", "GameObject", errorHead)
    
    CraftSudio.Destroy(go)
    Daneel.StackTrace.EndFunction("GameObject.Destroy")
end


--- Destroy a component from the gameObject.
-- Argument 'input' can be :
-- the component object (possible values : ScriptedBehavior, Model, Map or Camera),
-- the component type as a case-insensitive string (the function will destroy the first component of that type), 
-- the component instance (of type ScriptedBehavior, Model, Map or Camera),
-- or a script name or asset (string or Script) (the function will destroy the ScriptedBehavior that uses this Script),
-- @param gameObject (GameObject) The gameObject
-- @param input (mixed) See function description.
-- @param strict [optional default=false] (boolean) If true, returns an error when the function can't find the component to destroy.
-- @return (boolean) True if the component has been succesfully destroyed, false otherwise.
function GameObject.DestroyComponent(gameObject, input, strict)
    Daneel.StackTrace.BeginFunction("GameObject.DestroyComponent", gameObject, input, strict)
    local errorHead = "GameObject.DestroyComponent(gameObject, input[, strict]) : "
    Daneel.Debug.CheckArgType(gameObject, "gameObject", "GameObject", errorHead)
    Daneel.Debug.CheckOptionalArgType(strict, "strict", "boolean", errorHead)
    if strict == nil then 
        strict = false 
    end

    local inputType = Daneel.Debug.GetType(input)
    local component = nil

    -- input is component object ?
    if table.containsvalue(Daneel.config.componentObjects, input) then
        component = gameObject:GetComponent(
            table.getkey(Daneel.config.components, input)
        )
    
    -- input is component type ?
    elseif input:isoneof(Daneel.config.componentTypes, true) then
        component = gameObject:GetComponent(
            Danel.Utilities.CaseProof(input, Daneel.config.componentTypes)
        )

    -- input is script name or asset ?
    elseif inputType == "string" or inputType == "Script" then
        component = gameObject:GetScriptedBehavior(input)
    
    -- at this point input must be component instance

    -- not a component instance ?
    elseif not inputType:isoneof(Daneel.config.componentTypes) then
        Daneel.Debug.PrintError(errorHead.."Argument 'input' not correct. It is of type '"..inputType.."' with value '"..tostring(input).."'. Check the function description for allowed values.")
    end

  
    if component == nil then
        _error = errorHead.."Couldn't find the component to destroy on this gameObject."
                
        if strict then
            Daneel.Debug.PrintError(_error)
        else
            print("WARNING : ".._error)
            Daneel.StackTrace.EndFunction("GameObject.DestroyComponent", false)
            return false
        end
    end

    CraftStudio.Destroy(component)
    Daneel.StackTrace.EndFunction("GameObject.DestroyComponent", true)
    return true
end

--- Destroy a ScriptedBehavior from the gameObject.
-- If argument 'scriptNameOrAsset' is set with a script name or a script asset, the function will try to destroy the ScriptedBehavior that use this script.
-- If the argument is not set, it will destroy the first ScriptedBehavior on this gameObejct
-- @param gameObject (GameObject) The gameObject
-- @param scriptNameOrAsset [optional default=ScriptedBehavior] (string or Script) The script name or asset.
-- @return (boolean) True if the component has been succesfully destroyed, false otherwise.
function GameObject.DestroyScriptedBehavior(gameObject, scriptNameOrAsset)
    Daneel.StackTrace.BeginFunction("GameObject.DestroyScriptedBehavior", gameObject, scriptNameOrAsset)
    local errorHead = "GameObject.DestroyScriptedBehavior(gameObject[, scriptNameOrAsset]) : "
    Daneel.Debug.CheckArgType(gameObject, "gameObject", "GameObject", errorHead)
    Daneel.Debug.CheckOptionalArgType(scriptNameOrAsset, "scriptNameOrAsset", {"string", "Script"}, errorHead)
    
    if scriptNameOrAsset == nil then
        scriptNameOrAsset = "ScriptedBehavior"
    end
    
    local success = gameObject:DestroyComponent(scriptNameOrAsset)
    Daneel.StackTrace.EndFunction("GameObject.DestroyScriptedBehavior", success)
    return success
end

--- Destroy the first ModelRenderer from the gameObject.
-- @param gameObject (GameObject) The gameObject
-- @return (boolean) True if the component has been succesfully destroyed, false otherwise.
function GameObject.DestroyModelRenderer(gameObject) end

--- Destroy the first MapRenderer from the gameObject.
-- @param gameObject (GameObject) The gameObject
-- @return (boolean) True if the component has been succesfully destroyed, false otherwise.
function GameObject.DestroyMapRenderer(gameObject) end

--- Destroy the first Camera from the gameObject.
-- @param gameObject (GameObject) The gameObject
-- @return (boolean) True if the component has been succesfully destroyed, false otherwise.
function GameObject.DestroyCamera(gameObject) end



----------------------------------------------------------------------------------

function GameObject.Init()
    
    for i, componentType in ipairs(Daneel.config.componentTypes) do
        
        -- AddComponent helpers
        -- ie : go:AddModelRenderer()
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

        -- GetComponent helpers
        -- ie : go:GetModelRenderer()
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

        -- DestroyComponent helpers
        -- ie : go:DestroyModelRenderer()
        GameObject["Destroy"..componentType] = function(go)
            Daneel.StackTrace.BeginFunction("GameObject.Destroy"..componentType, go)
            local errorHead = "GameObject.Destroy"..componentType.."(gameObject) : "
            Daneel.Debug.CheckArgType(go, "gameObject", "GameObject", errorHead)

            local success = go:DestroyComponent(componentType)
            Daneel.StackTrace.EndFunction("GameObject.Destroy"..componentType, success)
            return success
        end

    end -- end for
end

