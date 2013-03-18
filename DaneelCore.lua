
Daneel = {}



----------------------------------------------------------------------------------
-- User Config


Daneel.config = {

    -- List of the Scripts paths as values and optionally the script alias as the keys
    scripts = {
        -- "fully-qualified Script path"
        -- alias = "fully-qualified Script path"
    },

    
    -- List of the button names you defined in the "Administration > Game Controls" tab of your project
    buttons = {

    },


    -- Set to true to enable the framework's advanced debugging capabilities.
    -- Set to false when you ship the game.
    debug = false,
}



----------------------------------------------------------------------------------
----------------------------------------------------------------------------------
-------------------------- DO NOT EDIT BELOW THIS POINT --------------------------
----------------------------------------------------------------------------------
----------------------------------------------------------------------------------


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
        Document = Document
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


-- called from Daneel.Awake()
function Daneel.defaultConfig.Init()
    Daneel.Debug.StackTrace.BeginFunction("Daneel.defaultConfig.Init")
    
    if Daneel.config == nil then
        Daneel.config = table.new()
    else
        Daneel.config = table.new(Daneel.config)
    end
    setmetatable(Daneel.config, Daneel.defaultConfig)

    -- 
    Daneel.defaultConfig.assetTypes = table.getkeys(Daneel.defaultConfig.assetObjects)
    Daneel.defaultConfig.componentTypes = table.getkeys(Daneel.defaultConfig.componentObjects)

    local t = table.new()
    t = t:merge(Daneel.defaultConfig.assetObjects)
    t = t:merge(Daneel.defaultConfig.componentObjects)
    t = t:merge(Daneel.defaultConfig.craftStudioObjects)
    t = t:merge(Daneel.defaultConfig.daneelObjects)
    Daneel.defaultConfig.allObjects = t

    Daneel.config.scripts = table.merge(Daneel.config.daneelScripts, Daneel.config.scripts)
    
    Daneel.Debug.StackTrace.EndFunction("Daneel.defaultConfig.Init")
end



----------------------------------------------------------------------------------
-- Utilities


Daneel.Utilities = {}

--- Make sure that the case of the provided name is correct.
-- by checking against value in the provided set.
-- @param name (string) The name to check the case.
-- @param set (table) A table of value to check the name against.
function Daneel.Utilities.CaseProof(name, set)
    Daneel.Debug.StackTrace.BeginFunction("Daneel.Utilities.CaseProof", name, set)
    local errorHead = "Daneel.Utilities.CaseProof(name, set) : " 
    Daneel.Debug.CheckArgType(name, "name", "string", errorHead)
    Daneel.Debug.CheckArgType(set, "set", "table", errorHead)

    for i, setItem in ipairs(set) do
        if name:lower() == setItem:lower() then
            name = setItem
        end
    end

    Daneel.Debug.StackTrace.EndFunction("Daneel.Utilities.CaseProof", name)
    return name
end



----------------------------------------------------------------------------------
-- Debug

Daneel.Debug = {}


--- Check the provided argument's type against the provided type and display error if they don't match
-- @param argument (mixed) The argument to check
-- @param argumentName (string) The argument name
-- @param expectedArgumentTypes (string or table) The expected argument type(s)
-- @param errorHead [optional] (string) The begining of the error message
-- @param errorEnd [optional] (string) The end of the error message
function Daneel.Debug.CheckArgType(argument, argumentName, expectedArgumentTypes, errorHead, errorEnd, getLuaTypeOnly)
    if Daneel.config.debug == false then return end

    local _errorHead = "Daneel.Debug.CheckArgType(argument, argumentName, expectedArgumentTypes[, errorHead, errorEnd]) : "
    
    local argType = type(argumentName)
    if argType ~= "string" then
        Daneel.Debug.PrintError(_errorHead.."Argument 'argumentName' is of type '"..argType.."' with value '"..tostring(argumentName).."' instead of 'string'.")
    end

    argType = type(expectedArgumentTypes)
    if argType ~= "string" and argType ~= "table" then
        Daneel.Debug.PrintError(_errorHead.."Argument 'expectedArgumentTypes' is of type '"..argType.."' with value '"..tostring(expectedArgumentTypes).."' instead of 'string' or 'table'.")
    end

    if argType == "string" then
        expectedArgumentTypes = {expectedArgumentTypes}
    end

    argType = type(errorHead)
    if arType ~= nil and argType ~= "string" then
        Daneel.Debug.PrintError(_errorHead.."Argument 'errorHead' is of type '"..argType.."' with value '"..tostring(errorHead).."' instead of 'string'.")
    end

    if errorHead == nil then errorHead = "" end

    argType = type(errorEnd)
    if arType ~= nil and argType ~= "string" then
        Daneel.Debug.PrintError(_errorHead.."Argument 'errorEnd' is of type '"..argType.."' with value '"..tostring(errorEnd).."' instead of 'string'.")
    end

    if errorEnd == nil then errorEnd = "" end


    --

    argType = Daneel.Debug.GetType(argument, getLuaTypeOnly)
    
    --for i, expectedType in ipairs(expectedArgumentTypes) do
    for i = 1, #expectedArgumentTypes do
        expectedType = expectedArgumentTypes[i]
        if argType == expectedType then
            return
        end
    end
    
    Daneel.Debug.PrintError(errorHead.."Argument '"..argumentName.."' is of type '"..argType.."' with value '"..tostring(argument).."' instead of '"..table.concat(expectedArgumentTypes, "', '").."'. "..errorEnd)
end

--- Check the provided argument's type against the provided type and display error if they don't match
-- @param argument (mixed) The argument to check
-- @param argumentName (string) The argument name
-- @param expectedArgumentTypes (string) The expected argument type
-- @param errorHead [optional] (string) The begining of the error message
-- @param errorEnd [optional] (string) The end of the error message
function Daneel.Debug.CheckOptionalArgType(argument, argumentName, expectedArgumentTypes, errorHead, errorEnd)
    if argument == nil or Daneel.config.debug == false then
        return
    end

    local _errorHead = "Daneel.Debug.CheckOptionalArgType(argument, argumentName, expectedArgumentTypes, errorHead, errorEnd) : "
    
    local argType = type(argumentName)
    if argType ~= "string" then
        Daneel.Debug.PrintError(_errorHead.."Argument 'argumentName' is of type '"..argType.."' with value '"..tostring(argumentName).."' instead of 'string'.")
    end

    argType = type(expectedArgumentTypes)
    if argType ~= "string" and argType ~= "table" then
        Daneel.Debug.PrintError(_errorHead.."Argument 'expectedArgumentTypes' is of type '"..argType.."' with value '"..tostring(expectedArgumentTypes).."' instead of 'string' or 'table'.")
    end

    if argType == "string" then
        expectedArgumentTypes = {expectedArgumentTypes}
    end

    argType = type(errorHead)
    if arType ~= nil and argType ~= "string" then
        Daneel.Debug.PrintError(_errorHead.."Argument 'errorHead' is of type '"..argType.."' with value '"..tostring(errorHead).."' instead of 'string'.")
    end

    if errorHead == nil then errorHead = "" end

    argType = type(errorEnd)
    if arType ~= nil and argType ~= "string" then
        Daneel.Debug.PrintError(_errorHead.."Argument 'errorEnd' is of type '"..argType.."' with value '"..tostring(errorEnd).."' instead of 'string'.")
    end

    if errorEnd == nil then errorEnd = "" end

    --

    argType = Daneel.Debug.GetType(argument)
    for i, expectedType in ipairs(expectedArgumentTypes) do
        if argType == expectedType then
            return
        end
    end
    
    Daneel.Debug.PrintError(errorHead.."Optional argument '"..argumentName.."' is of type '"..argType.."' with value '"..tostring(argument).."' instead of '"..table.concat(expectedArgumentTypes, "', '").."'. "..errorEnd)
end

--- Return the craftStudio Type of the provided argument
-- @param object (mixed) The argument to get the type of
-- @param getLuaTypeOnly [optional default=false] (boolean) Tell wether to look only for Lua's type
-- @return (string) The type
function Daneel.Debug.GetType(object, getLuaTypeOnly)
    local errorHead = "Daneel.Debug.GetType(object[, getLuaTypeOnly]) : "
    local argType = type(getLuaTypeOnly)
    if arType ~= nil and argType ~= "boolean" then
        error(errorHead.."Argument 'getLuaTypeOnly' is of type '"..argType.."' with value '"..tostring(getLuaTypeOnly).."' instead of 'boolean'.")
    end

    if getLuaTypeOnly == nil then getLuaTypeOnly = false end

    --
    argType = type(object)

    if getLuaTypeOnly == false and argType == "table" then
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

--- Alias for error() but print Daneel's stack trace first
-- @param message (string) The error message
function Daneel.Debug.PrintError(message)
    if Daneel.config.debug == false then return end
    Daneel.Debug.StackTrace.Print()
    error(message)
end

--- Check the value of 'componentType' and throw error if it is not one of the valid component types or objects.
-- @param componentType (string, ScriptedBehavior, ModelRenderer, MapRenderer, Camera or Transform)
-- @return (string) The component type as a string with the correct case
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

--- Check the value of 'assetType' and throw error if it is not one of the valid asset types or objects.
-- @param assetType (string, Script, Model, ModelAnimation, Map, TileSet, Scene, Sound, Document)
-- @return (string) The asset type as a string with the correct case
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

--- Bypass the __tostring function that may exists on the data's metatable
-- @param data (mixed) The data to be converted to string
-- @return (string) The string 
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
    depth = 1,
}

--- Register a function input in the stack trace
-- @param functionName (string) The function name
-- @param ... [optional] (mixed) Arguments received by the function
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

-- Register a function output in the stack trace
function Daneel.Debug.StackTrace.EndFunction()
    if Daneel.config.debug == false then return end
    -- since 16/05/2013 no arguments is needed anymore, but 
    Daneel.Debug.StackTrace.messages[Daneel.Debug.StackTrace.depth] = nil
    Daneel.Debug.StackTrace.depth = Daneel.Debug.StackTrace.depth - 1
end

--- Print the StackTrace
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

--- Make the specified function listen to the specified event.
-- The function will be called whenever the specified event will be fired.
-- @param eventName (string) The event name.
-- @param _function (function, string or GameObject) The function or the gameObject name or instance.
-- @param functionName [optional default="On[eventName]"] (string) If '_function' is a gameObject name or instance, the name of the function to send the message to
-- @param broadcast [optional default=false] (boolean) If '_function' is a gameObject name or instance, broadcast the message to all the gameObject's childrens
function Daneel.Events.Listen(eventName, _function, functionName, broadcast)
    Daneel.Debug.StackTrace.BeginFunction("Daneel.Events.Listen", eventName, _function)
    local errorHead = "Daneel.Events.Listen(eventName, function) : "
    Daneel.Debug.CheckArgType(eventName, "eventName", "string", errorHead)

    if Daneel.Events.events[eventName] == nil then
        Daneel.Events.events[eventName] = {}
    end

    local functionType = type(_function)
    if functionType == "function" then
        table.insert(Daneel.Events.events[eventName], _function)
    else
        Daneel.Debug.CheckArgType(_function, "_function", {"string", "GameObject"}, errorHead)
        Daneel.Debug.CheckOptionalArgType(functionName, "functionName", "string", errorHead)
        Daneel.Debug.CheckOptionalArgType(broadcast, "broadcast", "boolean", errorHead)

        local gameObject = _function
        if functionType == "string" then
            gameObject = GameObject.Find(_function)
            if gameObject == nil then
                Daneel.Debug.PrintError(errorHead.."Argument '_function' : gameObject with name '".._function.."' was not found in the scene.")
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

--- Make the specified function to stop listen to the specified event.
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
            gameObject = GameObject.Find(functionOrGameObject)
            if gameObject == nil then
                Daneel.Debug.PrintError(errorHead.."Argument 'functionOrGameObject' : gameObject with name '".._function.."' was not found in the scene.")
            end
        end
        
        for i, storedFunc in ipairs(Daneel.Events.events[eventName]) do
            if gameObject == storedFunc.gameObject then
                table.remove(Daneel.Events.events[eventName], i)
                break
            end
        end
    end

    Daneel.Debug.StackTrace.EndFunction("Daneel.Events.StopListen")
end

--- Fire the specified event transmitting along all subsequent parameters to 'eventName' if some exists. 
-- All functions that listen to this event with Daneel.Events.Listen() will be called and receive all parameters.
-- @param eventName (string) The event name.
-- @param ... [optional] a list of parameters to pass along.
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
--


function Daneel.Awake()
    Daneel.Debug.StackTrace.BeginFunction("Daneel.Awake")

    -- Config
    Daneel.defaultConfig.Init()
        
    -- Helpers functions
    Asset.Init()
    Component.Init()
    GameObject.Init()
    
    Daneel.Debug.StackTrace.EndFunction("Daneel.Awake")
end

function Daneel.Start()

end 

function Daneel.Update()
    -- fire an event whenever a registered button is pressed
    for i, buttonName in ipairs(Daneel.config.buttons) do
        if CraftStudio.Input.IsButtonDown(buttonName) then
            Daneel.Events.Fire("On"..buttonName:ucfirst().."ButtonDown")
        end

        if CraftStudio.Input.WasButtonJustPressed(buttonName) then
            Daneel.Events.Fire("On"..buttonName:ucfirst().."ButtonJustPressed")
        end

        if CraftStudio.Input.WasButtonJustReleased(buttonName) then
            Daneel.Events.Fire("On"..buttonName:ucfirst().."ButtonJustReleased")
        end
    end
end