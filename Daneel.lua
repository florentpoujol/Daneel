-- v1.1.0
-- 21/03/2013

if Daneel == nil then
    Daneel = {}
end


----------------------------------------------------------------------------------
-- Defaul Config

Daneel.defaultConfig = {

    -- Objects (keys = name, value = object)
    assetObjects = {
        Script = Script,
        Model = Model,
        ModelAnimation = ModelAnimation,
        Map = Map,
        TileSet = TileSet,
        Sound = Sound,
        Scene = Scene,
        --Document = Document
    },

    componentObjects = {
        ScriptedBehavior = ScriptedBehavior,
        ModelRenderer = ModelRenderer,
        MapRenderer = MapRenderer,
        Camera = Camera,
        Transform = Transform,
    },
    
    craftStudioObjects = {
        GameObject = GameObject,
        Vector3 = Vector3,
        Quaternion = Quaternion,
        Plane = Plane,
        Ray = Ray,
    },
    
    daneelObjects = {
        RaycastHit = RayCastHit,
        Component = Component,
        Asset = Asset,
    },

    -- Rays
    -- list of the gameObjects to cast the ray against by default by ray:Cast()
    -- filled in the CastableGameObjects behavior
    castableGameObjects = {},
    
    -- Triggers
    -- list of gameObjects check for rpoximity by the triggers
    -- filled in the TriggerableGameObject behavior
    triggerableGameObjects = {},

    -- List of gameObject that react to the mouse input
    mousehoverableGameObjects = {},


    -- Scripts
    daneelScripts = {
        "Daneel/Behaviors/Trigger",
        "Daneel/Behaviors/TriggerableGameObject",
        "Daneel/Behaviors/CastableGameObject",
        "Daneel/Behaviors/MousehoverableGameObject",
    }
}

Daneel.defaultConfig.__index = Daneel.defaultConfig


----------------------------------------------------------------------------------
-- Utilities

Daneel.Utilities = {}

--- Make sure that the case of the provided name is correct by checking it against the values in the provided set.
-- @param name (string) The name to check the case of.
-- @param set (table) A table of values to check the name against.
function Daneel.Utilities.CaseProof(name, set)
    Daneel.Debug.StackTrace.BeginFunction("Daneel.Utilities.CaseProof", name, set)
    local errorHead = "Daneel.Utilities.CaseProof(name, set) : " 
    Daneel.Debug.CheckArgType(name, "name", "string", errorHead)
    Daneel.Debug.CheckArgType(set, "set", "table", errorHead)

    for i, item in ipairs(set) do
        if name:lower() == item:lower() then
            name = item
        end
    end

    Daneel.Debug.StackTrace.EndFunction("Daneel.Utilities.CaseProof", name)
    return name
end


----------------------------------------------------------------------------------
-- Debug

Daneel.Debug = {}

--- Check the provided argument's type against the provided type(s) and display error if they don't match.
-- @param argument (mixed) The argument to check.
-- @param argumentName (string) The argument name.
-- @param expectedArgumentTypes (string or table) The expected argument type(s).
-- @param p_errorHead [optional] (string) The beginning of the error message.
-- @param p_errorEnd [optional] (string) The end of the error message.
function Daneel.Debug.CheckArgType(argument, argumentName, expectedArgumentTypes, p_errorHead, p_errorEnd)
    if Daneel.config.debug == false then return end

    local errorHead = "Daneel.Debug.CheckArgType(argument, argumentName, expectedArgumentTypes[, errorHead, errorEnd]) : "
    
    local argType = type(argumentName)
    if argType ~= "string" then
        Daneel.Debug.PrintError(errorHead.."Argument 'argumentName' is of type '"..argType.."' with value '"..tostring(argumentName).."' instead of 'string'.")
    end

    argType = type(expectedArgumentTypes)
    if argType ~= "string" and argType ~= "table" then
        Daneel.Debug.PrintError(errorHead.."Argument 'expectedArgumentTypes' is of type '"..argType.."' with value '"..tostring(expectedArgumentTypes).."' instead of 'string' or 'table'.")
    end

    if argType == "string" then
        expectedArgumentTypes = {expectedArgumentTypes}
    end

    argType = type(p_errorHead)
    if arType ~= nil and argType ~= "string" then
        Daneel.Debug.PrintError(errorHead.."Argument 'p_errorHead' is of type '"..argType.."' with value '"..tostring(errorHead).."' instead of 'string'.")
    end

    if p_errorHead == nil then p_errorHead = "" end

    argType = type(p_errorEnd)
    if arType ~= nil and argType ~= "string" then
        Daneel.Debug.PrintError(errorHead.."Argument 'p_errorEnd' is of type '"..argType.."' with value '"..tostring(errorEnd).."' instead of 'string'.")
    end

    if p_errorEnd == nil then p_errorEnd = "" end

    --
    argType = Daneel.Debug.GetType(argument)
    local luaArgType = type(argument) -- any object (that are tables) will now pass the test even when Daneel.Debug.GetType(argument) does not return "table" 
    for i, expectedType in ipairs(expectedArgumentTypes) do
        if argType == expectedType or luaArgType == expectedType then
            return
        end
    end
    
    Daneel.Debug.PrintError(p_errorHead.."Argument '"..argumentName.."' is of type '"..argType.."' with value '"..tostring(argument).."' instead of '"..table.concat(expectedArgumentTypes, "', '").."'. "..p_errorEnd)
end

--- If the provided argument is not nil, check the provided argument's type against the provided type(s) and display error if they don't match.
-- @param argument (mixed) The argument to check.
-- @param argumentName (string) The argument name.
-- @param expectedArgumentTypes (string) The expected argument type(s).
-- @param p_errorHead [optional] (string) The beginning of the error message.
-- @param p_errorEnd [optional] (string) The end of the error message.
function Daneel.Debug.CheckOptionalArgType(argument, argumentName, expectedArgumentTypes, p_errorHead, p_errorEnd)
    if argument == nil or Daneel.config.debug == false then
        return
    end

    local errorHead = "Daneel.Debug.CheckOptionalArgType(argument, argumentName, expectedArgumentTypes, errorHead, errorEnd) : "
    
    local argType = type(argumentName)
    if argType ~= "string" then
        Daneel.Debug.PrintError(errorHead.."Argument 'argumentName' is of type '"..argType.."' with value '"..tostring(argumentName).."' instead of 'string'.")
    end

    argType = type(expectedArgumentTypes)
    if argType ~= "string" and argType ~= "table" then
        Daneel.Debug.PrintError(errorHead.."Argument 'expectedArgumentTypes' is of type '"..argType.."' with value '"..tostring(expectedArgumentTypes).."' instead of 'string' or 'table'.")
    end

    if argType == "string" then
        expectedArgumentTypes = {expectedArgumentTypes}
    end

    argType = type(p_errorHead)
    if arType ~= nil and argType ~= "string" then
        Daneel.Debug.PrintError(errorHead.."Argument 'p_errorHead' is of type '"..argType.."' with value '"..tostring(errorHead).."' instead of 'string'.")
    end

    if p_errorHead == nil then errorHead = "" end

    argType = type(p_errorEnd)
    if arType ~= nil and argType ~= "string" then
        Daneel.Debug.PrintError(errorHead.."Argument 'p_errorEnd' is of type '"..argType.."' with value '"..tostring(errorEnd).."' instead of 'string'.")
    end

    if p_errorEnd == nil then p_errorEnd = "" end

    --
    argType = Daneel.Debug.GetType(argument)
    local luaArgType = type(argument)
    for i, expectedType in ipairs(expectedArgumentTypes) do
        if argType == expectedType or luaArgType == expectedType then
            return
        end
    end
    
    Daneel.Debug.PrintError(p_errorHead.."Optional argument '"..argumentName.."' is of type '"..argType.."' with value '"..tostring(argument).."' instead of '"..table.concat(expectedArgumentTypes, "', '").."'. "..p_errorEnd)
end

--- Return the Lua or CraftStudio type of the provided argument.
-- "CraftStudio types" includes : GameObject, ModelRenderer, MapRenderer, Camera, Transform, Script, Model, ModelAnimation, Map, TileSet, Scene, Sound, Document, Ray, RaycastHit, Vector3, Plane, Quaternion
-- @param object (mixed) The argument to get the type of.
-- @param returnLuaTypeOnly [optional default=false] (boolean) Tell whether to return only Lua's built-in types (string, number, boolean, table, function, userdata or thread).
-- @return (string) The type.
function Daneel.Debug.GetType(object, returnLuaTypeOnly)
    local errorHead = "Daneel.Debug.GetType(object[, returnLuaTypeOnly]) : "
    local argType = type(returnLuaTypeOnly)
    if arType ~= nil and argType ~= "boolean" then
        error(errorHead.."Argument 'returnLuaTypeOnly' is of type '"..argType.."' with value '"..tostring(returnLuaTypeOnly).."' instead of 'boolean'.")
    end

    if returnLuaTypeOnly == nil then returnLuaTypeOnly = false end

    --
    argType = type(object)

    if returnLuaTypeOnly == false and argType == "table" then
        -- for all other cases, the type is defined by the object's metatable
        local mt = getmetatable(object)

        if mt ~= nil then
            -- the metatable of the ScriptedBahaviors is the corresponding script asset
            -- the metatable of all script assets is Script
            if getmetatable(mt) == Script then
                return "ScriptedBehavior"
            end

            -- other types
            for type, object in pairs(Daneel.config.allObjects) do
                if mt == object then
                    return type
                end
            end
        end
    end

    return argType
end

--- Alias for error() but print Daneel's stack trace first.
-- @param message (string) The error message.
function Daneel.Debug.PrintError(message)
    if Daneel.config.debug == false then return end
    Daneel.Debug.StackTrace.Print()
    error(message)
end

local OrginalError = error

--- Print the stackTrace then the provided error in the console
-- @param message (string) The error message.
-- @param doNotPrintStacktrace [optional default=false] (boolean) Set to true to prevent the stacktrace to be printed before the error message.
function error(message, doNotPrintStacktrace)
    if Daneel.config.debug == true and doNotPrintStacktrace ~= true then
        Daneel.Debug.StackTrace.Print()
    end
    OriginalError(message)
end

--- Check the value of 'componentType', correct its case or convert it to string and throw error if it is not one of the valid component types or objects.
-- @param componentType (string, ScriptedBehavior, ModelRenderer, MapRenderer, Camera or Transform) The component type as a string or the asset object.
-- @return (string) The correct component type.
function Daneel.Debug.CheckComponentType(componentType)
    Daneel.Debug.StackTrace.BeginFunction("Daneel.Debug.CheckComponentType", componentType)
    local errorHead = "Daneel.Debug.CheckComponentType(componentType) : "
    Daneel.Debug.CheckArgType(componentType, "componentType", {"string", unpack(Daneel.config.componentTypes)}, errorHead)

    -- if componentType is an object
    if type(componentType) ~= "string" then
        componentType = table.getkey(Daneel.config.componentObjects, componentType)
    end

    local componentTypes = Daneel.config.componentTypes
    componentType = Daneel.Utilities.CaseProof(componentType, componentTypes)
    if not componentType:isoneof(componentTypes) then
        Daneel.Debug.PrintError(errorHead.."Argument 'componentType' with value '"..componentType.."' is not one of the valid component types : "..table.concat(componentTypes, ", "))
    end

    Daneel.Debug.StackTrace.EndFunction("Daneel.Debug.CheckComponentType", componentType)
    return componentType
end

--- Check the value of 'assetType', correct its case or convert it to string and throw error if it is not one of the valid asset types or objects.
-- @param assetType (string, Script, Model, ModelAnimation, Map, TileSet, Scene or Sound) The asset type as a string or the asset object.
-- @return (string) The correct asset type.
function Daneel.Debug.CheckAssetType(assetType)
    Daneel.Debug.StackTrace.BeginFunction("Daneel.Debug.CheckAssetType", assetType)
    local errorHead = "Daneel.Debug.CheckAssetType(assetType) : "
    Daneel.Debug.CheckArgType(assetType, "assetType", {"string", unpack(Daneel.config.assetTypes)}, errorHead)

    -- if assetType is an object
    if type(assetType) ~= "string" then
        assetType = table.getkey(Daneel.config.assetObjects, assetType)
    end

    local assetTypes = Daneel.config.assetTypes
    assetType = Daneel.Utilities.CaseProof(assetType, assetTypes)
    if not assetType:isoneof(assetTypes) then
        Daneel.Debug.PrintError(errorHead.."Argument 'assetType' with value '"..assetType.."' is not one of the valid asset types : "..table.concat(assetTypes, ", "))
    end

    Daneel.Debug.StackTrace.EndFunction("Daneel.Debug.CheckAssetType", assetType)
    return assetType
end

--- Bypass the __tostring() function that may exists on the data's metatable.
-- @param data (mixed) The data to be converted to string.
-- @return (string) The string.
function Daneel.Debug.ToRawString(data)
    local text = tostring(data)
    
    local mt = getmetatable(data)
    if mt ~= nil then
        if mt.__tostring ~= nil then
            local mttostring = mt.__tostring
            mt.__tostring = nil
            text = tostring(data)
            mt.__tostring = mttostring
        end
    end
    
    return text
end


----------------------------------------------------------------------------------
-- StackTrace

Daneel.Debug.StackTrace = { 
    messages = {},
    depth = 0,
}

--- Register a function input in the stack trace.
-- @param functionName (string) The function name.
-- @param ... [optional] (mixed) Arguments received by the function.
function Daneel.Debug.StackTrace.BeginFunction(functionName, ...)
    if Daneel.config.debug == false then return end
    local errorHead = "Daneel.Debug.StackTrace.BeginFunction(functionName[, ...]) : "
    Daneel.Debug.CheckArgType(functionName, "functionName", "string", errorHead)

    Daneel.Debug.StackTrace.depth = Daneel.Debug.StackTrace.depth + 1

    local msg = functionName.."("

    if #arg > 0 then
        for i, argument in ipairs(arg) do
            if type(argument) == "string" then
                msg = msg..'"'..tostring(argument)..'", '
            else
                msg = msg..tostring(argument)..", "
            end
        end

        msg = msg:sub(1, #msg-2) -- removes the last coma+space
    end

    msg = msg..")"

    table.insert(Daneel.Debug.StackTrace.messages, msg)
end

--- Closes a successful function call, removing it from the stacktrace.
function Daneel.Debug.StackTrace.EndFunction()
    if Daneel.config.debug == false then return end
    -- since 16/05/2013 no arguments is needed anymore, since the StackTrace only keeps open functions calls and never keep returned values
    -- I didn't rewrote all the calls to EndFunction() 
    Daneel.Debug.StackTrace.messages[Daneel.Debug.StackTrace.depth] = nil
    Daneel.Debug.StackTrace.depth = Daneel.Debug.StackTrace.depth - 1
end

--- Print the StackTrace.
function Daneel.Debug.StackTrace.Print()
    if Daneel.config.debug == false then return end
    local messages = Daneel.Debug.StackTrace.messages
    
    print("~~~~~ Daneel.Debug.StackTrace ~~~~~")

    for i, msg in ipairs(messages) do
        if i < 10 then
            i = "0"..i
        end
        print("#"..i.." "..msg)
    end
end


----------------------------------------------------------------------------------
-- Events

Daneel.Events = { events = {} }

--- Make the provided function listen to the provided event.
-- The function will be called whenever the provided event will be fired.
-- @param eventName (string) The event name.
-- @param p_function (function, string or GameObject) The function (not the function name) or the gameObject name or instance.
-- @param functionName [optional default="On[eventName]"] (string) If 'p_function' is a gameObject name or instance, the name of the function to send the message to.
-- @param broadcast [optional default=false] (boolean) If 'p_function' is a gameObject name or instance, tell whether to broadcast the message to all the gameObject's childrens (if true).
function Daneel.Events.Listen(eventName, p_function, functionName, broadcast)
    Daneel.Debug.StackTrace.BeginFunction("Daneel.Events.Listen", eventName, p_function)
    local errorHead = "Daneel.Events.Listen(eventName, function) : "
    Daneel.Debug.CheckArgType(eventName, "eventName", "string", errorHead)

    if Daneel.Events.events[eventName] == nil then
        Daneel.Events.events[eventName] = {}
    end

    local functionType = type(p_function)
    if functionType == "function" then
        table.insert(Daneel.Events.events[eventName], p_function)
    else
        Daneel.Debug.CheckArgType(p_function, "p_function", {"string", "GameObject"}, errorHead)
        Daneel.Debug.CheckOptionalArgType(functionName, "functionName", "string", errorHead)
        Daneel.Debug.CheckOptionalArgType(broadcast, "broadcast", "boolean", errorHead)

        local gameObject = p_function
        if functionType == "string" then
            gameObject = GameObject.Get(p_function)
            if gameObject == nil then
                Daneel.Debug.PrintError(errorHead.."Argument 'p_function' : gameObject with name '"..p_function.."' was not found in the scene.")
            end
        end

        if functionName == nil then
            functionName = "On"..eventName
        end

        if broadcast == nil then
            broadcast = false
        end

        table.insert(Daneel.Events.events[eventName], {
            gameObject = gameObject,
            functionName = functionName,
            broadcast = broadcast
        })
    end

    Daneel.Debug.StackTrace.EndFunction("Daneel.Events.Listen")
end
-- TODO check if a global function, registered several times for the same event is called several times

--- Make the provided function or gameObject to stop listen to the provided event.
-- @param eventName (string) The event name.
-- @param functionOrGameObject (function, string or GameObject) The function, or the gameObject name or instance.
function Daneel.Events.StopListen(eventName, functionOrGameObject)
    Daneel.Debug.StackTrace.BeginFunction("Daneel.Events.StopListen", eventName, functionOrGameObject)
    local errorHead = "Daneel.Events.StopListen(eventName, functionOrGameObject) : "
    Daneel.Debug.CheckArgType(eventName, "eventName", "string", errorHead)
    
    local functionType = type(functionOrGameObject)
    if functionType == "function" then
        for i, storedFunc in ipairs(Daneel.Events.events[eventName]) do
            if functionOrGameObject == storedFunc then
                table.remove(Daneel.Events.events[eventName], i)
                break
            end
        end
    else
        local gameObject = functionOrGameObject
        if functionType == "string" then
            gameObject = GameObject.Get(functionOrGameObject)
            if gameObject == nil then
                Daneel.Debug.PrintError(errorHead.."Argument 'functionOrGameObject' : gameObject with name '".._function.."' was not found in the scene.")
            end
        end
        
        for i, storedFunc in ipairs(Daneel.Events.events[eventName]) do
            if type(storedFunc) == "table" and gameObject == storedFunc.gameObject then
                table.remove(Daneel.Events.events[eventName], i)
                break
            end
        end
    end

    Daneel.Debug.StackTrace.EndFunction("Daneel.Events.StopListen")
end

--- Fire the provided event transmitting along all subsequent parameters to 'eventName' if some exists. 
-- All functions that listen to this event will be called and receive all parameters.
-- @param eventName (string) The event name.
-- @param ... [optional] A list of parameters to pass along.
function Daneel.Events.Fire(eventName, ...)
    if arg == nil then
        Daneel.Debug.StackTrace.BeginFunction("Daneel.Events.Fire", eventName, nil)
        arg = {}
    else
        Daneel.Debug.StackTrace.BeginFunction("Daneel.Events.Fire", eventName, unpack(arg))
    end
    
    Daneel.Debug.CheckArgType(eventName, "eventName", "string", "Daneel.Events.Fire(eventName[, parameters]) : ")
    
    if Daneel.Events.events[eventName] == nil then 
        Daneel.Debug.StackTrace.EndFunction("Daneel.Events.Fire")
        return
    end
    
    for i, func in ipairs(Daneel.Events.events[eventName]) do
        local functionType = type(func)
        if functionType == "function" then
            func(unpack(arg))
        elseif functionType == "table" then
            if func.gameObject ~= nil then
                if func.broadcast then
                    func.gameObject:BroadcastMessage(func.functionName, arg)
                else
                    func.gameObject:SendMessage(func.functionName, arg)
                end
            else
                table.remove(Daneel.Events.events[eventName], i)
            end
        else
            -- func is nil (a priori), function has been destroyed (probably was a public function on a destroyed ScriptedBehavior)
            table.remove(Daneel.Events.events[eventName], i)
        end
    end

    Daneel.Debug.StackTrace.EndFunction("Daneel.Events.Fire")
end


----------------------------------------------------------------------------------
-- Initialization
local luaDocStop = ""

function Daneel.InitConfig()
    setmetatable(Daneel.config, Daneel.defaultConfig)

    Daneel.defaultConfig.assetTypes = {}
    for key, value in pairs(Daneel.defaultConfig.assetObjects) do
        table.insert(Daneel.defaultConfig.assetTypes, key)
    end

    Daneel.defaultConfig.componentTypes = {}
    for key, value in pairs(Daneel.defaultConfig.componentObjects) do
        table.insert(Daneel.defaultConfig.componentTypes, key)
    end

    -- all objects (for use in GetType())
    Daneel.defaultConfig.allObjects = {}
    local allObjects = {Daneel.defaultConfig.assetObjects, Daneel.defaultConfig.componentObjects, Daneel.defaultConfig.craftStudioObjects, Daneel.defaultConfig.daneelObjects}

    for i, t in ipairs(allObjects) do
        for key, value in pairs(t) do
            Daneel.defaultConfig.allObjects[key] = value
        end
    end

    -- scripts
    for alias, path in pairs(Daneel.config.daneelScripts) do
        if type(alias) == "number" and alias == math.floor(alias) then -- is integer
            table.insert(Daneel.config.scripts, path)
        else
            Daneel.config.scripts[alias] = path
        end
    end

    for componentType, componentObject in ipairs(Daneel.config.componentObjects) do

        -- GameObject

        -- AddComponent helpers
        -- ie : gameObject:AddModelRenderer()
        if componentType ~= "Transform" and componentType ~= "ScriptedBehavior" then 
            GameObject["Add"..componentType] = function(gameObject, params)
                Daneel.Debug.StackTrace.BeginFunction("GameObject.Add"..componentType, gameObject, params)
                local errorHead = "GameObject.Add"..componentType.."(gameObject[, params]) : "
                Daneel.Debug.CheckArgType(gameObject, "gameObject", "GameObject", errorHead)

                local component = gameObject:AddComponent(componentType, params)
                Daneel.Debug.StackTrace.EndFunction("GameObject.Add"..componentType, component)
                return component
            end
        end

        -- SetComponent helpers
        -- ie : gameObject:SetModelRenderer()
        if componentType ~= "ScriptedBehavior" then 
            GameObject["Set"..componentType] = function(gameObject, params)  
                Daneel.Debug.StackTrace.BeginFunction("GameObject.Set"..componentType, gameObject, params)
                local errorHead = "GameObject.Set"..componentType.."(gameObject, params) : "
                Daneel.Debug.CheckArgType(gameObject, "gameObject", "GameObject", errorHead)

                local component = gameObject:SetComponent(componentType, params)
                Daneel.Debug.StackTrace.EndFunction("GameObject.Set"..componentType)
            end
        end

        -- Components

        if componentType ~= "ScriptedBehavior" then
            -- Dynamic Getters
            componentObject["__index"] = function(component, key) 
                local funcName = "Get"..key:ucfirst()
                
                if componentObject[funcName] ~= nil then
                    return componentObject[funcName](component)
                elseif componentObject[key] ~= nil then
                    return componentObject[key] -- have to return the function here, not the function return value !
                end

                if Component[funcName] ~= nil then
                    return Component[funcName](component)
                elseif Component[key] ~= nil then
                    return Component[key] -- have to return the function here, not the function return value !
                end
                
                return nil
            end
            print(componentType.." index")

            -- Dynamic Setters
            componentObject["__newindex"] = function(component, key, value)
                local funcName = "Set"..key:ucfirst()
                
                if componentObject[funcName] ~= nil then
                    return componentObject[funcName](component, value)
                end
                
                return rawset(component, key, value)
            end
            print(componentType.." New index")
        end

        componentObject["__tostring"] = function(component)
            -- returns something like "ModelRenderer: 123456789"
            -- component.inner is "?: [some ID]"
            return componentType..tostring(component.inner):sub(2, 20) -- leave 2 as the starting index, only the transform ahave an extra space
        end
        print(componentType.." to string")
    end -- end for componentObjects

    -- Dynamic getters and setter on Scripts
    for i, path in pairs(Daneel.config.scripts) do
        local script = CraftStudio.FindAsset(path, "Script") -- not sure if Asset.Get() already exists

        if script ~= nil then
            -- Dynamic getters
            function script.__index(scriptedBehavior, key)
                local funcName = "Get"..key:ucfirst()
                              
                if script[funcName] ~= nil then
                    return script[funcName](scriptedBehavior)
                elseif script[key] ~= nil then
                    return script[key]
                end

                if Script[funcName] ~= nil then
                    return Script[funcName](scriptedBehavior)
                elseif Script[key] ~= nil then
                    return Script[key]
                end

                if Component[funcName] ~= nil then
                    return Component[funcName](scriptedBehavior)
                elseif Component[key] ~= nil then
                    return Component[key]
                end
                
                return nil
            end

            -- Dynamic setters
            function script.__newindex(scriptedBehavior, key, value)
                local funcName = "Set"..key:ucfirst()
                              
                if script[funcName] ~= nil then
                    return script[funcName](scriptedBehavior, value)
                end
                
                return rawset(scriptedBehavior, key, value)
            end

            --
            function script.__tostring(scriptedBehavior)
                return "ScriptedBehavior"..tostring(scriptedBehavior.inner):sub(2, 20)
            end
        else
            print("WARNING : item with key '"..i.."' and value '"..path.."' in Daneel.config.scripts is not a valid script path.")
        end
    end

    -- assets
    for assetType, object in pairs(Daneel.config.assetObjects) do
        -- Get helpers : GetModelRenderer() ...
        Asset["Get"..assetType] = function(assetName)
            Daneel.Debug.StackTrace.BeginFunction("Asset.Get"..assetType, assetName)
            local errorHead = "Asset.Get"..assetType.."(assetName) : "
            Daneel.Debug.CheckArgType(assetName, "assetName", "string", errorHead)
            local asset = Asset.Get(assetName, assetType)
            Daneel.Debug.StackTrace.EndFunction("Asset.Get"..assetType, asset)
            return asset
        end

        object["__tostring"] = function(asset)
            -- print something like : "Model: 123456789 - table: 0512A528"
            -- asset.inner is "CraftStudioCommon.ProjectData.[AssetType]: [some ID]"
            -- CraftStudioCommon.ProjectData. is 30 characters long
            return tostring(asset.inner):sub(31, 60)
        end
    end
end -- end Daneel.InitConfig()


if Daneel.config ~= nil then
    Daneel.InitConfig()
end
-- otherwise, the Config.lua file has not been read yat and the function Daneel.InitConfig() will be run from this file instead


----------------------------------------------------------------------------------
-- Runtime
local luaDocStop = ""

function Daneel.Update()
    -- HotKeys
    -- fire an event whenever a registered button is pressed
    for i, buttonName in ipairs(Daneel.config.buttons) do
        if CraftStudio.Input.WasButtonJustPressed(buttonName) then
            Daneel.Events.Fire("On"..buttonName:ucfirst().."ButtonJustPressed")
        end

        if CraftStudio.Input.IsButtonDown(buttonName) then
            Daneel.Events.Fire("On"..buttonName:ucfirst().."ButtonDown")
        end

        if CraftStudio.Input.WasButtonJustReleased(buttonName) then
            Daneel.Events.Fire("On"..buttonName:ucfirst().."ButtonJustReleased")
        end
    end
end

