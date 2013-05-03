
if Daneel == nil then
    Daneel = {}
end

DANEEL_LOADED = false
DEBUG = false


function DefaultConfig()
    return {
        -- List of the Scripts paths as values and optionally the script alias as the keys.
        -- Ie :
        -- "fully-qualified Script path"
        -- or
        -- alias = "fully-qualified Script path"
        --
        -- Setting a script path here allow you to  :
        -- * Use the dynamic getters and setters
        -- * Use component:Set() (for scripts that are ScriptedBehaviors)
        -- * Call Behavior:DaneelAwake() when Daneel has just loaded, even on scripts that are not ScriptedBehaviors
        -- * If you defined aliases, dynamically access the ScriptedBehavior on the gameObject via its alias
        daneelScripts = {
            "Daneel/Behaviors/DaneelBehavior",
            "Daneel/Behaviors/Trigger",
            "Daneel/Behaviors/TriggerableGameObject",
            "Daneel/Behaviors/CastableGameObject",
            "Daneel/Behaviors/MouseInteractiveGameObject",
            "Daneel/Behaviors/MouseInteractiveCamera",
            "Daneel/Behaviors/GUI/GUIMouseInteractive",
            "Daneel/Behaviors/GUI/CheckBox",
            "Daneel/Behaviors/GUI/Input",
            "Daneel/Behaviors/GUI/WorldText",
        },
        allScripts = {},


        ----------------------------------------------------------------------------------

        input = {
            -- Button names as you defined them in the "Administration > Game Controls" tab of your project.
            -- Button whose name is defined here can be used as HotKeys.
            buttons = {
                "LeftMouse",
                "LeftShift",
                "Delete",
                "LeftArrow",
                "RightArrow",
            },

            -- Maximum number of frames between two clicks of the left mouse button to be considered as a double click
            doubleClickDelay = 20,

            inputKeys = {

            }
        },


        ----------------------------------------------------------------------------------

        language = {
            -- Current language
            current = "english",

            -- Default language
            default = "english",

            -- Value returned when a language key is not found
            keyNotFound = "langkeynotfound",

            -- Tell wether Daneel.Lang.GetLine() search a line key in the default language 
            -- when it is not found in the current language before returning the value of keyNotFound
            searchInDefault = true,
        },


        ----------------------------------------------------------------------------------

        gui = {
            -- Name of the gameObject who has the orthographic camera used to render the HUD
            hudCameraName = "HUDCamera",
            -- the corresponding GameObject, set at runtime
            hudCamera = nil,

            -- The gameObject that serve as origin for all GUI elements that aare not in a Group, created at runtime
            hudOrigin = nil,

            -- The orthographic scale of the HUDCamera
            hudCameraOrthographicScale = 10,

            -- Fully-qualified path of the map used to render text elements
            textMapPath = "Daneel/TextMap",
            emptyTextMapPath = "Daneel/EmptyTextMap",

            -- label's (text) default scale
            textDefaultScale = 0.3,

            -- TileSets used for the text elements
            textColorTileSetPaths = {
                White = "Daneel/ASCII_White",
                Black = "Daneel/ASCII_Black",
                Red = "Daneel/ASCII_Red",
                Green = "Daneel/ASCII_Green",
                Blue = "Daneel/ASCII_Blue",
            },
            textColorTileSets = {
                -- Name (string) = TileSet (TileSet)
            }, -- filled at runtime

            textDefaultColorName = "White",

            -- CheckBox
            checkBox = {
                tileSetPath = nil,

                -- Set the block ID on the TileSet or the letter/sign as a string
                checkedBlock = 251, -- valid mark
                notCheckedBlock = "X",
            },
        },


        ----------------------------------------------------------------------------------

        -- once Daneel has loaded, the userObjects table below will be filled with the types defined in userTypes as the keys and the actual objects as values
        userTypes = {},


        ----------------------------------------------------------------------------------

        -- Enable/disble Daneel's debugging features.
        debug = false,
    
        ----------------------------------------------------------------------------------
        ----------------------------------------------------------------------------------
        -- List of the languages supported by the game.
        -- Automatically filled at runtime with the languages names, based on the keys defined on the 'language' global variable
        languages = {},


        ----------------------------------------------------------------------------------

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
        assetTypes = {}, -- filled at runtime

        componentObjects = {
            ScriptedBehavior = ScriptedBehavior,
            ModelRenderer = ModelRenderer,
            MapRenderer = MapRenderer,
            Camera = Camera,
            Transform = Transform,
            Physics = Physics,
        },
        componentTypes = {},
        
        craftStudioObjects = {
            GameObject = GameObject,
            Vector3 = Vector3,
            Quaternion = Quaternion,
            Plane = Plane,
            Ray = Ray,
        },
        
        daneelTypes = {
            RaycastHit = RaycasHit,
            Vector2 = Vector2,
        },
        daneelTypes = {},

        guiObjects = {
            ["Daneel.GUI.Common"]       = Daneel.GUI.Common,
            ["Daneel.GUI.Group"]        = Daneel.GUI.Group,
            ["Daneel.GUI.Text"]         = Daneel.GUI.Text,
            ["Daneel.GUI.Image"]        = Daneel.GUI.Image,
            ["Daneel.GUI.CheckBox"]     = Daneel.GUI.CheckBox,
            ["Daneel.GUI.Input"]        = Daneel.GUI.Input,
            ["Daneel.GUI.ProgressBar"]  = Daneel.GUI.ProgressBar,
            ["Daneel.GUI.Slider"]       = Daneel.GUI.Slider,
            ["Daneel.GUI.WorldText"]    = Daneel.GUI.WorldText,
        },
        guiTypes = {}, -- filled at runtime
        
        -- list of all types and objects, filled at runtime
        allObjects = {},


        ----------------------------------------------------------------------------------

        -- Rays
        -- list of the gameObjects to cast the ray against by default by ray:Cast()
        -- filled in the CastableGameObjects behavior
        castableGameObjects = {},
        
        -- Triggers
        -- list of the gameObjects to check for proximity by the triggers
        -- filled in the TriggerableGameObject behavior
        triggerableGameObjects = { default = {} },

        -- List of the gameObjects that react to the mouse inputs
        mouseInteractiveGameObjects = {},
    } -- end Daneel.Config.Default
end


----------------------------------------------------------------------------------
-- Utilities

Daneel.Utilities = {}

--- Make sure that the case of the provided name is correct by checking it against the values in the provided set.
-- @param name (string) The name to check the case of.
-- @param set (string or table) A single value or a table of values to check the name against.
function Daneel.Utilities.CaseProof(name, set)
    Daneel.Debug.StackTrace.BeginFunction("Daneel.Utilities.CaseProof", name, set)
    local errorHead = "Daneel.Utilities.CaseProof(name, set) : " 
    Daneel.Debug.CheckArgType(name, "name", "string", errorHead)
    Daneel.Debug.CheckArgType(set, "set", {"string", "table"}, errorHead)

    if type(set) == "string" then
        set = {set}
    end

    for i, item in ipairs(set) do
        if name:lower() == item:lower() then
            name = item
        end
    end

    Daneel.Debug.StackTrace.EndFunction("Daneel.Utilities.CaseProof", name)
    return name
end

--- Replace placeholders in the provided string with their corresponding provided replacements.
-- @param string (string) The string.
-- @param replacements (table) The placeholders and their replacements ( { placeholder = "replacement", ... } ).
-- @return (string) The string.
function Daneel.Utilities.ReplaceInString(string, replacements)
    Daneel.Debug.StackTrace.BeginFunction("Daneel.Utilities.ReplaceInString", string, replacements)
    local errorHead = "Daneel.Utilities.ReplaceInString(string, replacements) : "
    Daneel.Debug.CheckArgType(string, "string", "string", errorHead)
    Daneel.Debug.CheckArgType(replacements, "replacements", "table", errorHead)
    for placeholder, replacement in pairs(replacements) do
        string = string:gsub(":"..placeholder, replacement)
    end
    Daneel.Debug.StackTrace.EndFunction()
    return string
end

--- Allow to call getters and setters as if they were variable on the provided object.
-- Optionaly allow to search in a ancestry of objects.
-- @param Object (mixed) The object.
-- @param ancestors (mixed) One or several (as a table) objects the Object "inherits" from.
function Daneel.Utilities.AllowDynamicGettersAndSetters(Object, ancestors)
    function Object.__index(instance, key)
        local funcName = "Get"..key:ucfirst()

        if Object[funcName] ~= nil then
            return Object[funcName](instance)
        elseif Object[key] ~= nil then
            return Object[key]
        end

        if ancestors ~= nil then
            for i, Ancestor in ipairs(ancestors) do
                if Ancestor[funcName] ~= nil then
                    return Ancestor[funcName](instance)
                elseif Ancestor[key] ~= nil then
                    return Ancestor[key]
                end
            end
        end

        return nil
    end

    function Object.__newindex(instance, key, value)
        local funcName = "Set"..key:ucfirst()
        if Object[funcName] ~= nil then
            return Object[funcName](instance, value)
        end
        return rawset(instance, key, value)
    end
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
    if DEBUG == false then return end

    local errorHead = "Daneel.Debug.CheckArgType(argument, argumentName, expectedArgumentTypes[, errorHead, errorEnd]) : "
    
    local argType = type(argumentName)
    if argType ~= "string" then
        error(errorHead.."Argument 'argumentName' is of type '"..argType.."' with value '"..tostring(argumentName).."' instead of 'string'.")
    end

    argType = type(expectedArgumentTypes)
    if argType ~= "string" and argType ~= "table" then
        error(errorHead.."Argument 'expectedArgumentTypes' is of type '"..argType.."' with value '"..tostring(expectedArgumentTypes).."' instead of 'string' or 'table'.")
    end

    if argType == "string" then
        expectedArgumentTypes = {expectedArgumentTypes}
    elseif #expectedArgumentTypes <= 0 then
        error(errorHead.."Argument 'expectedArgumentTypes' is an empty table.")
    end

    argType = type(p_errorHead)
    if argType ~= "nil" and argType ~= "string" then
        error(errorHead.."Argument 'p_errorHead' is of type '"..argType.."' with value '"..tostring(p_errorHead).."' instead of 'string'.")
    end

    if p_errorHead == nil then p_errorHead = "" end

    argType = type(p_errorEnd)
    if argType ~= "nil" and argType ~= "string" then
        error(errorHead.."Argument 'p_errorEnd' is of type '"..argType.."' with value '"..tostring(p_errorEnd).."' instead of 'string'.")
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
    
    error(p_errorHead.."Argument '"..argumentName.."' is of type '"..argType.."' with value '"..tostring(argument).."' instead of '"..table.concat(expectedArgumentTypes, "', '").."'. "..p_errorEnd)
end

--- If the provided argument is not nil, check the provided argument's type against the provided type(s) and display error if they don't match.
-- @param argument (mixed) The argument to check.
-- @param argumentName (string) The argument name.
-- @param expectedArgumentTypes (string) The expected argument type(s).
-- @param p_errorHead [optional] (string) The beginning of the error message.
-- @param p_errorEnd [optional] (string) The end of the error message.
function Daneel.Debug.CheckOptionalArgType(argument, argumentName, expectedArgumentTypes, p_errorHead, p_errorEnd)
    if argument == nil or DEBUG == false then
        return
    end

    local errorHead = "Daneel.Debug.CheckOptionalArgType(argument, argumentName, expectedArgumentTypes, errorHead, errorEnd) : "
    
    local argType = type(argumentName)
    if argType ~= "string" then
        error(errorHead.."Argument 'argumentName' is of type '"..argType.."' with value '"..tostring(argumentName).."' instead of 'string'.")
    end

    argType = type(expectedArgumentTypes)
    if argType ~= "string" and argType ~= "table" then
        error(errorHead.."Argument 'expectedArgumentTypes' is of type '"..argType.."' with value '"..tostring(expectedArgumentTypes).."' instead of 'string' or 'table'.")
    end

    if argType == "string" then
        expectedArgumentTypes = {expectedArgumentTypes}
    elseif #expectedArgumentTypes <= 0 then
        error(errorHead.."Argument 'expectedArgumentTypes' is an empty table.")
    end

    argType = type(p_errorHead)
    if argType ~= "nil" and argType ~= "string" then
        error(errorHead.."Argument 'p_errorHead' is of type '"..argType.."' with value '"..tostring(p_errorHead).."' instead of 'string'.")
    end

    if p_errorHead == nil then errorHead = "" end

    argType = type(p_errorEnd)
    if argType ~= "nil" and argType ~= "string" then
        error(errorHead.."Argument 'p_errorEnd' is of type '"..argType.."' with value '"..tostring(p_errorEnd).."' instead of 'string'.")
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
    
    error(p_errorHead.."Optional argument '"..argumentName.."' is of type '"..argType.."' with value '"..tostring(argument).."' instead of '"..table.concat(expectedArgumentTypes, "', '").."'. "..p_errorEnd)
end

--- Return the Lua or CraftStudio type of the provided argument.
-- "CraftStudio types" includes : GameObject, ModelRenderer, MapRenderer, Camera, Transform, Physiscs, Script, Model, ModelAnimation, Map, TileSet, Scene, Sound, Document, Ray, RaycastHit, Vector3, Plane, Quaternion.
-- @param object (mixed) The argument to get the type of.
-- @param returnLuaTypeOnly [optional default=false] (boolean) Tell whether to return only Lua's built-in types (string, number, boolean, table, function, userdata or thread).
-- @return (string) The type.
function Daneel.Debug.GetType(object, returnLuaTypeOnly)
    local errorHead = "Daneel.Debug.GetType(object[, returnLuaTypeOnly]) : "
    -- DO NOT use CheckArgType here since it uses itself GetType() => overflow
    local argType = type(returnLuaTypeOnly)
    if argType ~= "nil" and argType ~= "boolean" then
        error(errorHead.."Argument 'returnLuaTypeOnly' is of type '"..argType.."' with value '"..tostring(returnLuaTypeOnly).."' instead of 'boolean'.")
    end

    if returnLuaTypeOnly == nil then returnLuaTypeOnly = false end
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
            for type, object in pairs(config.allObjects) do
                if mt == object then
                    return type
                end
            end
        end
    end

    return argType
end

local OriginalError = error

--- Print the stackTrace unless told otherwise then the provided error in the console
-- @param message (string) The error message.
-- @param doNotPrintStacktrace [optional default=false] (boolean) Set to true to prevent the stacktrace to be printed before the error message.
function error(message, doNotPrintStacktrace)
    if DEBUG == true and doNotPrintStacktrace ~= true then
        Daneel.Debug.StackTrace.Print()
    end
    OriginalError(message)
end

--- Check the value of 'componentType', correct its case or convert it to string and throw error if it is not one of the valid component types or objects.
-- @param componentType (string) The component type as a string.
-- @return (string) The correct component type.
function Daneel.Debug.CheckComponentType(componentType)
    Daneel.Debug.StackTrace.BeginFunction("Daneel.Debug.CheckComponentType", componentType)
    local errorHead = "Daneel.Debug.CheckComponentType(componentType) : "
    Daneel.Debug.CheckArgType(componentType, "componentType", "string", errorHead)

    local componentTypes = config.componentTypes
    componentType = Daneel.Utilities.CaseProof(componentType, componentTypes)
    if not componentType:isoneof(componentTypes) then
        error(errorHead.."Argument 'componentType' with value '"..componentType.."' is not one of the valid component types : "..table.concat(componentTypes, ", "))
    end

    Daneel.Debug.StackTrace.EndFunction("Daneel.Debug.CheckComponentType", componentType)
    return componentType
end

--- Check the value of 'assetType', correct its case or convert it to string and throw error if it is not one of the valid asset types or objects.
-- @param assetType (string) The asset type as a string.
-- @return (string) The correct asset type.
function Daneel.Debug.CheckAssetType(assetType)
    Daneel.Debug.StackTrace.BeginFunction("Daneel.Debug.CheckAssetType", assetType)
    local errorHead = "Daneel.Debug.CheckAssetType(assetType) : "
    Daneel.Debug.CheckArgType(assetType, "assetType", "string", errorHead)

    local assetTypes = config.assetTypes
    assetType = Daneel.Utilities.CaseProof(assetType, assetTypes)
    if not assetType:isoneof(assetTypes) then
        error(errorHead.."Argument 'assetType' with value '"..assetType.."' is not one of the valid asset types : "..table.concat(assetTypes, ", "))
    end

    Daneel.Debug.StackTrace.EndFunction("Daneel.Debug.CheckAssetType", assetType)
    return assetType
end

--- Bypass the __tostring() function that may exists on the data's metatable.
-- @param data (mixed) The data to be converted to string.
-- @return (string) The string.
function Daneel.Debug.ToRawString(data)
    local text = nil
    local mt = getmetatable(data)
    if mt ~= nil then
        if mt.__tostring ~= nil then
            local mttostring = mt.__tostring
            mt.__tostring = nil
            text = tostring(data)
            mt.__tostring = mttostring
        end
    end
    if text == nil then 
        text = tostring(data)
    end
    return text
end

--- Return the name of the global variable (including nested tables) whose value is provided.
-- When the variable is nested in one or several tables (like Daneel.GUI.Text), its name and value must have been set in the 'userObjects' variable in the config.
-- @param object (table or function) Any global variable, any object from CraftStudio or Daneel or objects defined in 'userObjects' in the config.
-- @return (string) The name, or nil. 
function Daneel.Debug.GetNameFromValue(value)
    Daneel.Debug.StackTrace.BeginFunction("Daneel.Debug.GetObjectName", value)
    local errorHead = "Daneel.Debug.GetObjectName(value) : "
    if value == nil then
        if DEBUG == true then
            print("WARNING : "..errorHead.." Argument 'value' is nil. Returning nil.")
        end
        Daneel.Debug.StackTrace.EndFunction()
        return nil
    end
    local result = table.getkey(config.allObjects, value)
    if result == nil then
        result = table.getkey(_G, value)
    end
    Daneel.Debug.StackTrace.EndFunction()
    return result
end

--- Return the value of any global variable (including nested tables) from its name as a string.
-- When the variable is nested in one or several tables (like Daneel.GUI.Text), put a dot between the names.
-- @param name (string) The variable name.
-- @param (mixed) The variable value, or nil.
function Daneel.Debug.GetValueFromName(name)
    Daneel.Debug.StackTrace.BeginFunction("Daneel.Debug.GetValueFromName")
    local errorHead = "Daneel.Debug.GetValueFromName(name)"
    Daneel.Debug.CheckArgType(name, "name", "string", errorHead)
    if name:find(".") == nil then
        Daneel.Debug.StackTrace.EndFunction()
        return _G[name]
    else
        local subNames = name:split(".")
        local varName = table.remove(subTypes, 1)
        local value = _G[varName]
        if value == nil then
            if DEBUG == true then
                print("WARNING : "..errorHead.." : variable '"..varName.."' (from provided name '"..name.."' ) does not exists. Returning nil.")
            end
            Daneel.Debug.StackTrace.EndFunction()
            return nil
        end
        for i, _key in ipairs(subNames) do
            varName = varName..".".._key
            if value[_key] == nil then
                if DEBUG == true then
                    print("WARNING : "..errorHead.." : variable '"..varName.."' (from provided name '"..name.."' ) does not exists. Returning nil.")
                end
                Daneel.Debug.StackTrace.EndFunction()
                return nil
            else
                value = value[_key]
            end
        end
        Daneel.Debug.StackTrace.EndFunction()
        return value
    end
end


----------------------------------------------------------------------------------
-- StackTrace

Daneel.Debug.StackTrace = { messages = {} }

--- Register a function input in the stack trace.
-- @param functionName (string) The function name.
-- @param ... [optional] (mixed) Arguments received by the function.
function Daneel.Debug.StackTrace.BeginFunction(functionName, ...)
    if DEBUG == false then return end
    local errorHead = "Daneel.Debug.StackTrace.BeginFunction(functionName[, ...]) : "
    Daneel.Debug.CheckArgType(functionName, "functionName", "string", errorHead)

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
    if DEBUG == false then return end
    -- since 16/05/2013 no arguments is needed anymore, since the StackTrace only keeps open functions calls and never keep returned values
    -- I didn't rewrote all the calls to EndFunction() 
    table.remove(Daneel.Debug.StackTrace.messages)
end

--- Print the StackTrace.
function Daneel.Debug.StackTrace.Print()
    if DEBUG == false then return end
    local messages = Daneel.Debug.StackTrace.messages
    Daneel.Debug.StackTrace.messages = {}
     
    print("~~~~~ Daneel.Debug.StackTrace ~~~~~")

    for i, msg in ipairs(messages) do
        if i < 10 then
            i = "0"..i
        end
        print("#"..i.." "..msg)
    end
end


----------------------------------------------------------------------------------
-- Event

Daneel.Event = { 
    events = { any = {} },
    fireAtFrame = {},
    fireAtTime = {},
}

--- Make the provided function listen to the provided event.
-- The function will be called whenever the provided event will be fired.
-- @param eventName (string) The event name.
-- @param p_function (function, string or GameObject) The function (not the function name) or the gameObject name or instance.
-- @param functionName [optional default="[eventName]"] (string) If 'p_function' is a gameObject name or instance, the name of the function to send the message to.
-- @param broadcast [optional default=false] (boolean) If 'p_function' is a gameObject name or instance, tell whether to broadcast the message to all the gameObject's childrens (if true).
function Daneel.Event.Listen(eventName, p_function, functionName, broadcast)
    Daneel.Debug.StackTrace.BeginFunction("Daneel.Event.Listen", eventName, p_function)
    local errorHead = "Daneel.Event.Listen(eventName, function) : "
    Daneel.Debug.CheckArgType(eventName, "eventName", "string", errorHead)

    if Daneel.Event.events[eventName] == nil then
        Daneel.Event.events[eventName] = {}
    end

    local functionType = type(p_function)
    if functionType == "function" then
        if not table.containsvalue(Daneel.Event.events[eventName], p_function) then
            table.insert(Daneel.Event.events[eventName], p_function)
        end
    else
        Daneel.Debug.CheckArgType(p_function, "p_function", {"string", "GameObject"}, errorHead)
        Daneel.Debug.CheckOptionalArgType(functionName, "functionName", "string", errorHead)
        Daneel.Debug.CheckOptionalArgType(broadcast, "broadcast", "boolean", errorHead)

        local gameObject = p_function
        if functionType == "string" then
            gameObject = GameObject.Get(p_function)
            if gameObject == nil then
                error(errorHead.."Argument 'p_function' : gameObject with name '"..p_function.."' was not found in the scene.")
            end
        end

        if functionName == nil then
            functionName = eventName
        end

        if broadcast == nil then
            broadcast = false
        end

        table.insert(Daneel.Event.events[eventName], {
            gameObject = gameObject,
            functionName = functionName,
            broadcast = broadcast
        })
    end

    Daneel.Debug.StackTrace.EndFunction("Daneel.Event.Listen")
end

--- Make the provided function or gameObject to stop listen to the provided event.
-- @param eventName (string) The event name.
-- @param functionOrGameObject (function, string or GameObject) The function, or the gameObject name or instance.
function Daneel.Event.StopListen(eventName, functionOrGameObject)
    Daneel.Debug.StackTrace.BeginFunction("Daneel.Event.StopListen", eventName, functionOrGameObject)
    local errorHead = "Daneel.Event.StopListen(eventName, functionOrGameObject) : "
    Daneel.Debug.CheckArgType(eventName, "eventName", "string", errorHead)
    
    local functionType = type(functionOrGameObject)
    if functionType == "function" then
        for i, storedFunc in ipairs(Daneel.Event.events[eventName]) do
            if functionOrGameObject == storedFunc then
                table.remove(Daneel.Event.events[eventName], i)
                break
            end
        end
    else
        local gameObject = functionOrGameObject
        if functionType == "string" then
            gameObject = GameObject.Get(functionOrGameObject)
            if gameObject == nil then
                error(errorHead.."Argument 'functionOrGameObject' : gameObject with name '".._function.."' was not found in the scene.")
            end
        end
        
        for i, storedFunc in ipairs(Daneel.Event.events[eventName]) do
            if type(storedFunc) == "table" and gameObject == storedFunc.gameObject then
                table.remove(Daneel.Event.events[eventName], i)
                break
            end
        end
    end

    Daneel.Debug.StackTrace.EndFunction("Daneel.Event.StopListen")
end

--- Fire the provided event transmitting along all subsequent parameters to 'eventName' if some exists. 
-- All functions that listen to this event will be called and receive all parameters.
-- @param eventName (string) The event name.
-- @param ... [optional] Argument(s) to pass along.
function Daneel.Event.Fire(eventName, ...)
    if arg == nil then
        Daneel.Debug.StackTrace.BeginFunction("Daneel.Event.Fire", eventName, nil)
        arg = {}
    else
        Daneel.Debug.StackTrace.BeginFunction("Daneel.Event.Fire", eventName, unpack(arg))
    end
    
    Daneel.Debug.CheckArgType(eventName, "eventName", "string", "Daneel.Event.Fire(eventName[, ...]) : ")
    
    local functions = table.new(Daneel.Event.events[eventName]):merge(Daneel.Event.events["any"])
    for i, func in ipairs(functions) do
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
                table.remove(Daneel.Event.events[eventName], i)
            end
        else
            -- func is nil (a priori), function has been destroyed (probably was a public function on a destroyed ScriptedBehavior)
            table.remove(Daneel.Event.events[eventName], i)
        end
    end

    Daneel.Debug.StackTrace.EndFunction("Daneel.Event.Fire")
end

--- Queue and event to be fired at a particular frame.
-- If the provided frame is the current frame or an anterior frame, it will never be fired.
-- @param frame (number) The frame at which to fire the event. 
-- @param eventName (string) The event name.
-- @param ... [optional] Argument(s) to pass along.
function Daneel.Event.FireAtFrame(frame, eventName, ...)
    Daneel.Debug.BeginFunction("Daneel.Event.FireAtFrame", frame, eventName, arg)
    local errorHead = "Daneel.Event.FireAtFrame(frame, eventName[, ...]) : "
    Daneel.Debug.CheckArgType(frame, "frame", "number", errorHead)
    Daneel.Debug.CheckArgType(eventName, "eventName", "string", errorHead)
    
    if Daneel.Event.fireAtFrame[frame] == nil then
        Daneel.Event.fireAtFrame[frame] = {}
    end
    table.insert(Daneel.Event.fireAtFrame[frame], {
        name = eventName,
        args = arg
    })
    Daneel.Debug.StackTrace.EndFunction()
end

--- Queue and event to be fired at a particular time.
-- If the provided time is the current time or an anterior time, it will never be fired.
-- @param frame (number) The frame at which to fire the event.
-- @param eventName (string) The event name.
-- @param ... [optional] Argument(s) to pass along.
function Daneel.Event.FireAtTime(time, eventName, ...)
    Daneel.Debug.BeginFunction("Daneel.Event.FireAtTime", time, eventName, arg)
    local errorHead = "Daneel.Event.FireAtTime(time, eventName[, ...]) : "
    Daneel.Debug.CheckArgType(time, "time", "number", errorHead)
    Daneel.Debug.CheckArgType(eventName, "eventName", "string", errorHead)

    if Daneel.Event.fireAtTime[time] == nil then
        Daneel.Event.fireAtTime[time] = {}
    end
    table.insert(Daneel.Event.fireAtTime[time], {
        name = eventName,
        args = arg
    })
    Daneel.Debug.StackTrace.EndFunction()
end


----------------------------------------------------------------------------------
-- Lang

Daneel.Lang = { lines = {} }

--- Get the localized line identified by the provided key.
-- @param key (string) The language key.
-- @param replacements [optional] (table) The placeholders and their replacements.
-- @return (string) The line.
function Daneel.Lang.GetLine(key, replacements)
    Daneel.Debug.StackTrace.BeginFunction("Daneel.Lang.GetLine", key, replacements)
    local errorHead = "Daneel.Lang.GetLine(key[, replacements]) : "
    Daneel.Debug.CheckArgType(key, "key", "string", errorHead)
    local currentLanguage = config.language.current
    local defaultLanguage = config.language.default

    local keys = key:split(".")
    local language = currentLanguage
    if keys[1]:isoneof(config.languages) then
        language = table.remove(keys)
    end
    
    local noLangKey = table.concat(keys, ".") -- the key, but without the language

    local lines = Daneel.Lang.lines[language]
    if lines == nil then
        error(errorHead.."Language '"..language.."' does not exists")
    end

    for i, _key in ipairs(keys) do
        if lines[_key] == nil then
            -- key was not found
            if DEBUG == true then
                print(errorHead.."Localization key '"..key.."' was not found in '"..language.."' language .")
            end

            -- search for it in the default language
            if language ~= defaultLanguage and config.language.searchInDefault == true then  
                lines = Daneel.Lang.GetLine(defaultLanguage.."."..noLangKey, replacements)
            else -- already default language or don't want to search in
                lines =  config.language.keyNotFound
            end

            break
        end
        lines = lines[_key]
    end

    -- line should be the searched string by now
    local line = lines
    if type(line) ~= "string" then
        error(errorHead.."Localization key '"..key.."' does not lead to a string but to : '"..tostring(line).."'.")
    end

    -- process replacements
    if replacements ~= nil then
        line = Daneel.Utilities.ReplaceInString(line, replacements)
    end

    Daneel.Debug.StackTrace.EndFunction()
    return line
end

--- Get the localized line identified by the provided key.
-- Alias for Daneel.Lang.GetLine().
-- @param key (string) The language key.
-- @param replacements [optional] (table) The placeholders and their replacements.
-- @return (string) The line.
function line(key, replacements)
    return Daneel.Lang.GetLine(key, replacements)
end


----------------------------------------------------------------------------------
-- Time

Daneel.Time = {
    time = -1,
    deltaTime = -1,
    fixedTime = -1,
    fixedDeltaTime = 0.02,
    frameCount = 0,
    timeScale = 1.0,
}
-- see below in Daneel.Update()


----------------------------------------------------------------------------------
-- Config

Daneel.Config = {} 

--- Get the value associated with the provided key in the configuration.
-- @param key (string) The configuration key. May be prefixed by an environment name.
-- @param default (mixed) The default value to return instead of nil if the the key is not found.
-- @return (mixed) The configuration value. 
function Daneel.Config.Get(key, default)
    Daneel.Debug.StackTrace.BeginFunction("Daneel.Config.Get", key, default)
    local errorHead = "Daneel.Config.Get(key[, default]) : "
    Daneel.Debug.CheckArgType(key, "key", "string", errorHead)

    local keys = key:split(".")
     local environments = config.environments
    local environment = config.environment
    if keys[1]:isoneof(environments) then -- get the environment from the key
        environment = table.remove(keys, 1)
    end
    if environment == nil then -- not specified in the key nor in config
        environment = config.environment -- "default"
    end
    local noEnvKey = table.concat(keys, ".") -- the key, but without the environment

    local configTable = config[environment]
    if configTable == nil then
        error(errorHead.."Environment '"..environment.."' is not a valid configuration environment.")
    end
    
    for i, key in ipairs(keys) do
        if configTable[key] == nil then
            
            -- key was not found in current environment, search for it in the default environment
            if environment ~= "default" then
                Daneel.Debug.StackTrace.EndFunction()
                return Daneel.Config.Get("default."..noEnvKey, default)
            
            -- already default env, return default value
            else
                Daneel.Debug.StackTrace.EndFunction()
                return default
            end
        end

        configTable = configTable[key]
    end
    -- configTable should be the searched config value by now

    Daneel.Debug.StackTrace.EndFunction()
    return configTable
end


--- Set the value associated with the provided key in the configuration.
-- @param key (string) The configuration key. May be prefixed by an environment name.
-- @param value [optional] (mixed) The new value. If the argument is ommitted, the new value is conidered as nil.
function Daneel.Config.Set(key, value)
    Daneel.Debug.StackTrace.BeginFunction("Daneel.Config.Set", key, value)
    local errorHead = "Daneel.Config.Set(key, value) : "
    Daneel.Debug.CheckArgType(key, "key", "string", errorHead)

    local keys = key:split(".")
    local environments = config.environments
    local environment = config.common.environment
    if keys[1]:isoneof(environments) then -- get the environment from the key
        environment = table.remove(keys, 1)
    end 
    if environment == nil then -- not specified in the key nor in config.common
        environment = config.environment -- "common"
    end
    local configTable = config[environment]
    if configTable == nil then
        error(errorHead.."Environment '"..environment.."' is not a valid configuration environment.")
    end
    
    local errorKey = environment

    for i, key in ipairs(keys) do
        if type(configTable) ~= "table" then
            error(errorHead.."Configuration key '"..errorKey.."' is already set and is of type '"..type(configTable).."' instead of 'table'.")
        else
            if i == #keys then
                configTable[key] = value
            else
                if configTable[key] == nil then
                    configTable[key] = {}
                end

                configTable = configTable[key]
            end
        end

        errorKey = errorKey.."."..key
    end
    
    Daneel.Debug.StackTrace.EndFunction()
end


----------------------------------------------------------------------------------
-- Runtime
local luaDocStop = ""

-- called from DaneelBehavior Behavior:Awake()
function Daneel.Awake()
    config = table.deepmerge(DefaultConfig(), config)
    DEBUG = config.debug

    -- built assetTypes and componentTypes
    config.assetTypes = table.getkeys(config.assetObjects)
    config.componentTypes = table.getkeys(config.componentObjects)

    -- built daneelObjects, guiObjects and userObjects
    config.guiTypes = table.getkeys(config.guiObjects)
    --config.userObjects = table.foreach(Daneel.Config.Get('userTypes'), GetObjectFromType)
    
    -- all objects (for use in GetType())
    config.allObjects = table.merge(
        config.assetObjects,
        config.componentObjects,
        config.craftStudioObjects,
        config.daneelObjects,
        config.guiObjects,
        --config.userObjects
    )


    -- scripts
    -- Dynamic getters and setter on Scripts
    for i, path in pairs(config.scriptsPaths) do
        local script = Asset.Get(path, "Script") -- Asset.Get() helpers does not yet exists
        if script ~= nil then
            Daneel.Utilities.AllowDynamicGettersAndSetters(script, {Script, Component})

            script['__tostring'] = function(scriptedBehavior)
                return "ScriptedBehavior"..tostring(scriptedBehavior.inner):sub(2, 20)
            end
        else
            config.scriptsPaths[i] = nil
            if DEBUG == true then
                print("WARNING : item with key '"..i.."' and value '"..path.."' in 'config.scriptsPaths' is not a valid script path.")
            end
        end
    end


    -- Components
    for componentType, componentObject in pairs(config.componentObjects) do
        -- GameObject.AddComponent helpers
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

        -- Components getters-setter-tostring
        Daneel.Utilities.AllowDynamicGettersAndSetters(componentObject, { Component })

        if componentType ~= "ScriptedBehavior" then
            componentObject["__tostring"] = function(component)
                -- returns something like "ModelRenderer: 123456789"
                -- component.inner is "?: [some ID]"
                return componentType..tostring(component.inner):sub(2, 20) -- leave 2 as the starting index, only the transform has an extra space
            end
        end
    end


    -- Assets
    for assetType, assetObject in pairs(config.assetObjects) do
        -- Get helpers : GetModelRenderer() ...
        Asset["Get"..assetType] = function(assetName)
            Daneel.Debug.StackTrace.BeginFunction("Asset.Get"..assetType, assetName)
            local errorHead = "Asset.Get"..assetType.."(assetName) : "
            Daneel.Debug.CheckArgType(assetName, "assetName", "string", errorHead)
            local asset = Asset.Get(assetName, assetType)
            Daneel.Debug.StackTrace.EndFunction("Asset.Get"..assetType, asset)
            return asset
        end

        Daneel.Utilities.AllowDynamicGettersAndSetters(assetObject)

        assetObject["__tostring"] = function(asset)
            -- print something like : "Model: 123456789"
            -- asset.inner is "CraftStudioCommon.ProjectData.[AssetType]: [some ID]"
            -- CraftStudioCommon.ProjectData. is 30 characters long
            return tostring(asset.inner):sub(31, 60)
        end
    end


    -- Languages
    if language ~= nil then
        Daneel.Lang.lines = languages
        config.languages = table.getkeys(language)
    end


    -- GUI
    for guiType, guiObject in pairs(config.guiObjects) do
        Daneel.Utilities.AllowDynamicGettersAndSetters(guiObject, { Daneel.GUI.Common })
        
        function guiObject.__tostring(element)
            return guiType..": '"..element._name.."'"
        end
    end

    config.gui.hudCamera = GameObject.Get(config.gui.hudCameraName)

    -- setting pixelToUnits  
    local screenSize = CraftStudio.Screen.GetSize()
    -- get the smaller side of the screen (usually screenSize.y, the height)
    local smallSideSize = screenSize.y
    if screenSize.x < screenSize.y then
        smallSideSize = screenSize.x
    end

    -- The orthographic scale value (in units) is equivalent to the smallest side size of the screen (in pixel)
    -- pixelsToUnits (in units/pixels) is the correspondance between screen pixels and 3D world units
    Daneel.GUI.pixelsToUnits = config.gui.hudCameraOrthographicScale / smallSideSize

    config.gui.hudOrigin = GameObject.New("HUDOrigin", {parent = config.gui.hudCamera})
    config.gui.hudOrigin.transform.localPosition = Vector3:New(
        -screenSize.x * Daneel.GUI.pixelsToUnits / 2, 
        screenSize.y * Daneel.GUI.pixelsToUnits / 2,
        0
    )
    -- the HUDOrigin is now at the top-left corner of the screen

    -- Color TileSets
    local textColorTileSetPaths = config.gui.textColorTileSetPaths
    local textDefaultColorName = config.gui.textDefaultColorName
    if textDefaultColorName ~= nil and not table.containskey(textColorTileSetPaths, textDefaultColorName) then
        if DEBUG == true then
            print("WARNING : 'gui.textDefaultColorName' with value '"..textDefaultColorName.."' is not one of the valid color name : "..table.concat(textColorTileSetPaths:getkeys(), "', '").."'")
        end
        for color, tileSet in pairs(textColorTileSetPaths) do
            Daneel.Config.Set("gui.textDefaultColorName", color)
            break
        end
    end

    for name, path in pairs(textColorTileSetPaths) do
        local tileSet = Asset.Get(path, "TileSet")
        if tileSet == nil then
            print("WARNING : item with key '"..name.."' and value '"..path.."' in 'gui.textColorTileSetPaths' is not a valid TileSet path.")
        else
            config.gui.textColorTileSets[name] = tileSet
        end
    end

    -- CheckBox
    local tileSetPath = config.gui.checkBox.tileSetPath
    if tileSetPath ~= nil then
        local asset = Asset.Get(tileSetPath, "TileSet")
        if asset ~= nil then
            config.gui.checkBox.tileSet = asset
        elseif DEBUG == true then
            print("WARNING : 'gui.checkBox.tileSetPath' with value '"..tileSetPath.."' is not a valid TileSet path.")
        end
    end
    

    -- Awakening is over
    DANEEL_LOADED = true

    if DEBUG == true then
        print("~~~~~ Daneel is loaded ~~~~~")
    end

    -- call DaneelAwake()
    for i, path in pairs(scriptPaths) do
        local script = Asset.GetScript(path)
        if script ~= nil and type(script.DaneelAwake) == "function" then
            script:DaneelAwake()
        end
    end
end -- end Daneel.Awake()


function Daneel.Update()
    -- Time
    local currentTime = os.clock()
    Daneel.Time.deltaTime = currentTime - Daneel.Time.time
    Daneel.Time.time = currentTime
    Daneel.Time.frameCount = Daneel.Time.frameCount + 1

    -- call fixed update if it's the time
    -- using math.ceil() and *100 prevent a fixed frame not to be called if it was planned like a millisecond later
    -- 10.12345 => 1012
    if math.ceil(Daneel.Time.time*100) >= math.ceil((Daneel.Time.fixedTime + Daneel.Time.fixedDeltaTime)*100) then
        Daneel.Time.fixedTime = Daneel.Time.time
        Daneel.Event.Fire("FixedUpdate")
    end


    -- Delayed events
    if Daneel.Event.fireAtFrame[Daneel.Time.frameCount] ~= nil then
        for i, event in ipairs(Daneel.Event.fireAtFrame[Daneel.Time.frameCount]) do
            if event.args == nil then
                event.args = {}
            end
            Daneel.Event.Fire(event.name, unpack(event.args))
        end
        Daneel.Event.fireAtFrame[Daneel.Time.frameCount] = nil
    end

    local times = {}
    for time, events in pairs(Daneel.Event.fireAtTime) do
        if time <= Daneel.Time.time then
            table.insert(times, time)
        end
    end
    table.sort(times)
    for i, time in ipairs(times) do
        for i, event in ipairs(Daneel.Event.fireAtTime[time]) do
            if event.args == nil then
                event.args = {}
            end
            Daneel.Event.Fire(event.name, unpack(event.args))
        end
    end


    -- HotKeys
    -- fire an event whenever a registered button is pressed
    for i, buttonName in ipairs(config.input.buttons) do
        if CraftStudio.Input.WasButtonJustPressed(buttonName) then
            Daneel.Event.Fire("On"..buttonName:ucfirst().."ButtonJustPressed")
        end

        if CraftStudio.Input.IsButtonDown(buttonName) then
            Daneel.Event.Fire("On"..buttonName:ucfirst().."ButtonDown")
        end

        if CraftStudio.Input.WasButtonJustReleased(buttonName) then
            Daneel.Event.Fire("On"..buttonName:ucfirst().."ButtonJustReleased")
        end
    end
end
