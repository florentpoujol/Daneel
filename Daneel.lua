
local daneel_exists = false
for key, value in pairs(_G) do
    if key == "Daneel" then
        daneel_exists = true
        break
    end
end
if daneel_exists == false then
    Daneel = {}
end

DANEEL_LOADED = false
DEBUG = false
config = {}

function DaneelDefaultConfig()
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
        scriptPaths = {},

 
        ----------------------------------------------------------------------------------

        input = {
            -- Button names as you defined them in the "Administration > Game Controls" tab of your project.
            -- Button whose name is defined here can be used as HotKeys.
            buttons = {},

            -- Maximum number of frames between two clicks of the left mouse button to be considered as a double click
            doubleClickDelay = 20,
        },


        ----------------------------------------------------------------------------------

        language = {
            -- list of the languages supported by the game
            languageNames = {},

            -- Current language
            current = nil,

            -- Default language
            default = nil,

            -- Value returned when a language key is not found
            keyNotFound = "langkeynotfound",

            -- Tell wether Daneel.Lang.GetLine() search a line key in the default language 
            -- when it is not found in the current language before returning the value of keyNotFound
            searchInDefault = true,
        },


        ----------------------------------------------------------------------------------

        gui = {
            screenSize = CraftStudio.Screen.GetSize(),

            -- Name of the gameObject who has the orthographic camera used to render the HUD
            hudCameraName = "HUDCamera",
            -- the corresponding GameObject, set at runtime
            hudCameraGO = nil,

            -- The gameObject that serve as origin for all GUI elements that are not in a Group, created at runtime
            hudOriginGO = nil,
            hudOriginPosition = Vector3:New(0),

            textDefaultFontName = "GUITextFont",

            checkBoxDefaultState = false, -- false = not checked, true = checked
        },


        ----------------------------------------------------------------------------------

        tween = {
            defaultTweenerParams = {
                id = 0, -- can be anything, not restricted to numbers
                isEnabled = true, -- a disabled tweener won't update but the function like Play(), Pause(), Complete(), Destroy() will have no effect
                isPaused = false,

                delay = 0.0, -- delay before the tweener starts (in the same time unit as the duration (durationType))
                duration = 0.0, -- time or frames the tween (or one loop) should take (in durationType unit)
                durationType = "time", -- the unit of time for delay, duration, elapsed and fullElapsed. Can be "time", "realTime" or "frame"

                startValue = nil, -- it will be the current value of the target's property
                endValue = 0.0,

                loops = 0, -- number of loops to perform (-1 = infinite)
                loopType = "simple", -- type of loop. Can be "simple" (X to Y, repeat), "yoyo" (X to Y, Y to X, repeat)
                
                easeType = "linear", -- type of easing, check the doc or the end of the "Daneel/Lib/Easing" script for all possible values
                
                isRelative = false, -- If false, tween the value TO endValue. If true, tween the value BY endValue.

                ------------
                -- "read-only" properties or properties the user has no interest to change the value of

                hasStarted = false,
                isCompleted = false,
                elapsed = 0, -- elapsed time or frame (in durationType unit), delay excluded
                fullElapsed = 0, -- elapsed time, including loops, excluding delay
                completedLoops = 0,
                diffValue = 0.0, -- endValue - startValue
                value = 0.0, -- current value (between startValue and endValue)
            },
        },


        ----------------------------------------------------------------------------------

        debug = {
            -- Enable/disable Daneel's global debugging features.
            enableDebug = true,

            -- Enable/disable the Stack Trace.
            enableStackTrace = true,
        },


        ----------------------------------------------------------------------------------
        -- Objects (keys = name, value = object)

        -- CraftStudio
        craftStudioObjects = {
            GameObject = GameObject,
            Vector3 = Vector3,
            Quaternion = Quaternion,
            Plane = Plane,
            Ray = Ray,
        },

        craftStudioComponentObjects = {
            ScriptedBehavior = ScriptedBehavior,
            ModelRenderer = ModelRenderer,
            MapRenderer = MapRenderer,
            Camera = Camera,
            Transform = Transform,
            Physics = Physics,
            --TextRenderer = TextRenderer,
            --NetworkSync = NetworkSync,
        },

        assetObjects = {
            Script = Script,
            Model = Model,
            ModelAnimation = ModelAnimation,
            Map = Map,
            TileSet = TileSet,
            Sound = Sound,
            Scene = Scene,
            --Document = Document,
            --Font = Font,
        },
        
        -- Daneel
        daneelObjects = {
            RaycastHit = RaycastHit,
            Vector2 = Vector2,
            ["Daneel.Tween.Tweener"] = Daneel.Tween.Tweener,
        },

        daneelComponentObjects = {
            Hud = Daneel.GUI.Hud,
            CheckBox = Daneel.GUI.CheckBox,
            ProgressBar = Daneel.GUI.ProgressBar,
            Slider = Daneel.GUI.Slider,
        },

        -- custom
        userObjects = {},

        -- other properties created at runtime :
        -- componentObjects : a merge of craftStudioComponentObjects and daneelComponentObjects
        -- componentTypes : the list of the component types (the keys of componentObjects)
        -- daneelComponentTypes
        -- assetTypes
        -- allObjects : a merge of all *Objects tables
    }
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

--- Allow to call getters and setters as if they were variable on the instance of the provided Object.
-- The instances are tables that have the provided object as metatable.
-- Optionaly allow to search in a ancestry of objects.
-- @param Object (mixed) The object.
-- @param ancestors [optional] (mixed) One or several (as a table) objects the Object "inherits" from.
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
function Daneel.Debug.CheckArgType(argument, argumentName, expectedArgumentTypes, p_errorHead)
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

    argType = Daneel.Debug.GetType(argument)
    local luaArgType = type(argument) -- any object (that are tables) will now pass the test even when Daneel.Debug.GetType(argument) does not return "table" 
    for i, expectedType in ipairs(expectedArgumentTypes) do
        if argType == expectedType or luaArgType == expectedType then
            return
        end
    end
    error(p_errorHead.."Argument '"..argumentName.."' is of type '"..argType.."' with value '"..tostring(argument).."' instead of '"..table.concat(expectedArgumentTypes, "', '").."'.")
end

--- If the provided argument is not nil, check the provided argument's type against the provided type(s) and display error if they don't match.
-- @param argument (mixed) The argument to check.
-- @param argumentName (string) The argument name.
-- @param expectedArgumentTypes (string) The expected argument type(s).
-- @param p_errorHead [optional] (string) The beginning of the error message.
-- @param defaultValue [optional] (mixed) The default value to return if 'argument' is nil.
-- @return (mixed) The value of 'argument' if it is non-nil, or the value of 'defaultValue'.
function Daneel.Debug.CheckOptionalArgType(argument, argumentName, expectedArgumentTypes, p_errorHead, defaultValue)
    if DEBUG == false then return defaultValue end
    if argument == nil then return defaultValue end
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

    argType = Daneel.Debug.GetType(argument)
    local luaArgType = type(argument)
    for i, expectedType in ipairs(expectedArgumentTypes) do
        if argType == expectedType or luaArgType == expectedType then
            return argument
        end
    end
    error(p_errorHead.."Optional argument '"..argumentName.."' is of type '"..argType.."' with value '"..tostring(argument).."' instead of '"..table.concat(expectedArgumentTypes, "', '").."'.")
end

--- Return the Lua or CraftStudio type of the provided argument.
-- "CraftStudio types" includes : GameObject, ModelRenderer, MapRenderer, Camera, Transform, Physiscs, Script, Model, ModelAnimation, Map, TileSet, Scene, Sound, Document, Ray, RaycastHit, Vector3, Plane, Quaternion.
-- @param object (mixed) The argument to get the type of.
-- @param OnlyReturnLuaType [optional default=false] (boolean) Tell whether to return only Lua's built-in types (string, number, boolean, table, function, userdata or thread).
-- @return (string) The type.
function Daneel.Debug.GetType(object, OnlyReturnLuaType)
    local errorHead = "Daneel.Debug.GetType(object[, OnlyReturnLuaType]) : "
    -- DO NOT use CheckArgType here since it uses itself GetType() => overflow
    local argType = type(OnlyReturnLuaType)
    if argType ~= "nil" and argType ~= "boolean" then
        error(errorHead.."Argument 'OnlyReturnLuaType' is of type '"..argType.."' with value '"..tostring(OnlyReturnLuaType).."' instead of 'boolean'.")
    end
    if OnlyReturnLuaType == nil then OnlyReturnLuaType = false end
    argType = type(object)
    if OnlyReturnLuaType == false and argType == "table" then
        -- the type is defined by the object's metatable
        local mt = getmetatable(object)
        if mt ~= nil then
            -- the metatable of the ScriptedBehaviors is the corresponding script asset
            -- the metatable of all script assets is the Script object
            if getmetatable(mt) == Script then
                return "ScriptedBehavior"
            end
            -- other types
            if config.allObjects ~= nil then
                for type, object in pairs(config.allObjects) do
                    if mt == object then
                        return type
                    end
                end
            end
        end
    end
    return argType
end

local OriginalError = error

-- prevent to set the new version of error() when DEBUG is false or before the StackTrace is enabled when DEBUG is true.
local function SetNewError()
    --- Print the stackTrace unless told otherwise then the provided error in the console.
    -- Only exists when debug is enabled. When debug in disabled the built-in 'error(message)'' function exists instead.
    -- @param message (string) The error message.
    -- @param doNotPrintStacktrace [optional default=false] (boolean) Set to true to prevent the stacktrace to be printed before the error message.
    function error(message, doNotPrintStacktrace)
        if DEBUG == true and doNotPrintStacktrace ~= true then
            Daneel.Debug.StackTrace.Print()
        end
        OriginalError(message)
    end
end

--- Disable the debug from this point onward.
-- @param info [optional] (string) Some info about why or where you disabled the debug. Will be printed in the Runtime Report.
function Daneel.Debug.Disable(info)
    if info ~= nil then
        info = " : "..tostring(info)
    end
    print("Daneel.Debug.Disable()"..info)
    error = OriginalError
    DEBUG = false
end

--- Check the value of 'componentType', correct its case and throw error if it is not one of the valid component types.
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

--- Check the value of 'assetType', correct its case and throw error if it is not one of the valid asset types.
-- @param assetType (string) The asset type as a string.
-- @return (string) The correct asset type.
function Daneel.Debug.CheckAssetType(assetType)
    Daneel.Debug.StackTrace.BeginFunction("Daneel.Debug.CheckAssetType", assetType)
    local errorHead = "Daneel.Debug.CheckAssetType(assetType) : "
    Daneel.Debug.CheckArgType(assetType, "assetType", "string", errorHead)

    assetType = Daneel.Utilities.CaseProof(assetType, config.assetTypes)
    if not assetType:isoneof(config.assetTypes) then
        error(errorHead.."Argument 'assetType' with value '"..assetType.."' is not one of the valid asset types : "..table.concat(config.assetTypes, ", "))
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

--- Returns the name as a string of the global variable (including nested tables) whose value is provided.
-- This only works if the value of the variable is a table or a function.
-- When the variable is nested in one or several tables (like Daneel.GUI.Text), its name must have been set in the 'userTypes' variable in the config.
-- @param value (table or function) Any global variable, any object from CraftStudio or Daneel or objects whse name is set in 'userTypes' in the config.
-- @return (string) The name, or nil.
function Daneel.Debug.GetNameFromValue(value)
    Daneel.Debug.StackTrace.BeginFunction("Daneel.Debug.GetNameFromValue", value)
    local errorHead = "Daneel.Debug.GetNameFromValue(value) : "
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

--- Returns the value of any global variable (including nested tables) from its name as a string.
-- When the variable is nested in one or several tables (like Daneel.GUI.Text), put a dot between the names.
-- @param name (string) The variable name.
-- @return (mixed) The variable value, or nil.
function Daneel.Debug.GetValueFromName(name)
    Daneel.Debug.StackTrace.BeginFunction("Daneel.Debug.GetValueFromName", name)
    local errorHead = "Daneel.Debug.GetValueFromName(name) : "
    Daneel.Debug.CheckArgType(name, "name", "string", errorHead)
    local value = nil
    if name:find(".") == nil then
        if Daneel.Debug.GlobalExists(name) == true then
            value = _G[name]
        end
        Daneel.Debug.StackTrace.EndFunction()
        return value
    else
        local subNames = name:split(".")
        local varName = table.remove(subNames, 1)
        if Daneel.Debug.GlobalExists(varName) == true then
            value = _G[varName]
        end
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

--- Tell wether the provided global variable name exists (is non-nil).
-- Only works for first-level global variables.
-- Since CraftStudio uses Strict.lua, you can not write (variable == nil), nor (_G[variable] == nil).
-- @param name (string) The variable name.
-- @return (boolean) True if it exists, false otherwise.
function Daneel.Debug.GlobalExists(name)
    Daneel.Debug.StackTrace.BeginFunction("Daneel.Debug.GlobalExists", name)
    Daneel.Debug.CheckArgType(name, "name", "string", "Daneel.Debug.GlobalExists(name) : ")
    local exists = false
    for key, value in pairs(_G) do
        if key == name then
            exists = true
            break
        end
    end
    Daneel.Debug.StackTrace.EndFunction()
    return exists
end


----------------------------------------------------------------------------------
-- StackTrace

Daneel.Debug.StackTrace = { messages = {} }

--- Register a function input in the stack trace.
-- @param functionName (string) The function name.
-- @param ... [optional] (mixed) Arguments received by the function.
function Daneel.Debug.StackTrace.BeginFunction(functionName, ...)
    if DEBUG == false or config.debug.enableStackTrace == false then return end
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
    if DEBUG ~= true or config.debug.enableStackTrace ~= true then return end
    -- since 16/05/2013 no arguments is needed anymore, since the StackTrace only keeps open functions calls and never keep returned values
    -- I didn't rewrote all the calls to EndFunction() 
    table.remove(Daneel.Debug.StackTrace.messages)
end

--- Print the StackTrace.
function Daneel.Debug.StackTrace.Print()
    if DEBUG ~= true or config.debug.enableStackTrace ~= true then return end
    local messages = Daneel.Debug.StackTrace.messages
    Daneel.Debug.StackTrace.messages = {}
    print("~~~~~ Daneel.Debug.StackTrace ~~~~~")
    if #messages <= 0 then
        print("No message in the StackTrace.")
    else
        for i, msg in ipairs(messages) do
            if i < 10 then
                i = "0"..i
            end
            print("#"..i.." "..msg)
        end
    end
end


----------------------------------------------------------------------------------
-- Event

Daneel.Event = { 
    events = {},
    fireAtRealTime = {},
    fireAtTime = {},
    fireAtFrame = {},
}

--- Make the provided function or object listen to the provided event(s).
-- The function will be called whenever the provided event will be fired.
-- @param eventName (string or table) The event name (or names in a table).
-- @param functionOrObject (function or table) The function (not the function name) or the object.
function Daneel.Event.Listen(eventName, functionOrObject)
    Daneel.Debug.StackTrace.BeginFunction("Daneel.Event.Listen", eventName, functionOrObject)
    local errorHead = "Daneel.Event.Listen(eventName, functionOrObject) : "
    Daneel.Debug.CheckArgType(eventName, "eventName", {"string", "table"}, errorHead)
    Daneel.Debug.CheckArgType(functionOrObject, "functionOrObject", {"table", "function", "userdata"}, errorHead)
    local eventNames = eventName
    if type(eventName) == "string" then
        eventNames = { eventName }
    end
    for i, eventName in ipairs(eventNames) do
        if Daneel.Event.events[eventName] == nil then
            Daneel.Event.events[eventName] = {}
        end
        if not table.containsvalue(Daneel.Event.events[eventName], functionOrObject) then
            table.insert(Daneel.Event.events[eventName], functionOrObject)
        end
    end
    Daneel.Debug.StackTrace.EndFunction()
end

--- Make the provided function or object to stop listen to the provided event(s).
-- @param eventName (string or table) The event name (or names in a table).
-- @param functionOrObject (function, string or GameObject) The function, or the gameObject name or instance.
function Daneel.Event.StopListen(eventName, functionOrObject)
    Daneel.Debug.StackTrace.BeginFunction("Daneel.Event.StopListen", eventName, functionOrObject)
    local errorHead = "Daneel.Event.StopListen(eventName, functionOrObject) : "
    Daneel.Debug.CheckArgType(eventName, "eventName", "string", errorHead)
    Daneel.Debug.CheckArgType(functionOrObject, "functionOrObject", {"table", "function"}, errorHead)
    local eventNames = eventName
    if type(eventName) == "string" then
        eventNames = { eventName }
    end
    for i, eventName in ipairs(eventNames) do
        local objects = Daneel.Event.events[eventName]
        if objects ~= nil and table.containsvalue(objects, functionOrObject) then
            table.removevalue(objects, functionOrObject)
        end
    end
    Daneel.Debug.StackTrace.EndFunction("Daneel.Event.StopListen")
end

--- Fire the provided event on the provided objects (or the one that listen to it),
-- or call the provided function,
-- transmitting along all subsequent arguments if some exists. <br>
-- Allowed set of arguments are : <br>
-- (eventName[, ...]) <br>
-- (object, eventName[, ...]) <br>
-- (function[, ...])
-- @param object [optional] (table) The object to which fire the event at. If nil or abscent, will send the event to its listeners.
-- @param eventName (string) The event name.
-- @param ... [optional] Some arguments to pass along.
function Daneel.Event.Fire(object, eventName,  ...)
    Daneel.Debug.StackTrace.BeginFunction("Daneel.Event.Fire", object, eventName, unpack(arg))
    local errorHead = "Daneel.Event.Fire([object, ]eventName[, ...]) : "
    
    local argType = type(object)
    if argType == "string" then
        if eventName ~= nil then
            table.insert(arg, 1, eventName)
        end
        eventName = object
        object = nil
    elseif argType == "function" or argType == "userdata" then
        if eventName ~= nil then
            table.insert(arg, 1, eventName)
        end
        object(unpack(arg))
        Daneel.Debug.StackTrace.EndFunction()
        return
    end

    Daneel.Debug.CheckOptionalArgType(object, "object", "table", errorHead)
    Daneel.Debug.CheckArgType(eventName, "eventName", "string", errorHead)
    
    local listeners = { object }
    if object == nil and Daneel.Event.events[eventName] ~= nil then
        listeners = Daneel.Event.events[eventName]
    end

    for i, listener in ipairs(listeners) do
        local _type = type(listener)
        if _type == "function" or _type == "userdata" then
            listener(unpack(arg))
        else
            -- an object
            -- look for the value of the EventName property on the object
            local funcOrMessage = listener[eventName]
            if funcOrMessage == nil then 
                funcOrMessage = eventName
            end

            _type = type(funcOrMessage)
            if _type == "function" or _type == "userdata" then
                funcOrMessage(unpack(arg))
            else
                local sendMessage = true
                local gameObject = listener
                if getmetatable(gameObject) ~= GameObject then
                    gameObject = listener.gameObject
                    if getmetatable(gameObject) ~= GameObject then
                        sendMessage = false
                        if listener[eventName] ~= nil and DEBUG == true then
                            -- only prints the debug when the user setted up the event property because otherwise
                            -- it would print it every time an event has not been set up (which is OK) on an arbitrary object like a tweener
                            print(errorHead.."Can't fire event '"..eventName.."' by sending message '"..funcOrMessage.."' on object '"..tostring(listener).."'  because it not a gameObject and has no 'gameObject' property.")                      
                        end
                    end
                end
                if sendMessage == true then
                    gameObject:SendMessage(funcOrMessage, arg)
                end
            end
        end
    end
    Daneel.Debug.StackTrace.EndFunction()
end

--- Schedule an event to be fired or a function to be called at a particular real time.
-- Allowed set of arguments are : <br>
-- (realTime, eventName[, ...]) <br>
-- (realTime, object, eventName[, ...]) <br>
-- (realTime, function[, ...])
-- @param realTime (number) The real time at which to fire the event.
-- @param object [optional] (table) The object to which fire the event at. If nil or abscent, will send the event to its listeners.
-- @param eventName (string) The event name.
-- @param ... [optional] Argument(s) to pass along.
function Daneel.Event.FireAtRealTime(realTime, object, eventName, ...)
    Daneel.Debug.StackTrace.BeginFunction("Daneel.Event.FireAtTime", realTime, object, eventName, arg)
    local errorHead = "Daneel.Event.FireAtTime(realTime[, object], ]eventName[, ...]) : "
    Daneel.Debug.CheckArgType(realTime, "realTime", "number", errorHead)
    
    local argType = type(object)
    if argType == "string" then
        if eventName ~= nil then
            table.insert(arg, 1, eventName)
        end
        eventName = object
        object = nil


    elseif argType == "function" or argType == "userdata" then
        if eventName ~= nil then
            table.insert(arg, 1, eventName)
        end
        eventName = nil

    elseif argType ~= "table" then
        error(errorHead.."Argument 'object' with value '"..tostring(object).."' is not if type 'string', 'table', 'function' or 'userdata'.")
    end

    if Daneel.Event.fireAtTime[realTime] == nil then
        Daneel.Event.fireAtTime[realTime] = {}
    end
    table.insert(Daneel.Event.fireAtRealTime[realTime], {
        object = object, -- function or object
        name = eventName, -- may be nil
        args = arg 
    })
    Daneel.Debug.StackTrace.EndFunction()
end

--- Schedule an event to be fired or a function to be called at a particular time.
-- Allowed set of arguments are : <br>
-- (time, eventName[, ...]) <br>
-- (time, object, eventName[, ...]) <br>
-- (time, function[, ...])
-- @param time (number) The time at which to fire the event.
-- @param object [optional] (table) The object to which fire the event at. If nil or abscent, will send the event to its listeners.
-- @param eventName (string) The event name.
-- @param ... [optional] Argument(s) to pass along.
function Daneel.Event.FireAtTime(time, object, eventName, ...)
    Daneel.Debug.StackTrace.BeginFunction("Daneel.Event.FireAtTime", time, object, eventName, arg)
    local errorHead = "Daneel.Event.FireAtTime(time[, object], eventName[, ...]) : "
    Daneel.Debug.CheckArgType(time, "time", "number", errorHead)
    
    local argType = type(object)
    if argType == "string" then
        if eventName ~= nil then
            table.insert(arg, 1, eventName)
        end
        eventName = object
        object = nil


    elseif argType == "function" or argType == "userdata" then
        if eventName ~= nil then
            table.insert(arg, 1, eventName)
        end
        eventName = nil

    elseif argType ~= "table" then
        error(errorHead.."Argument 'object' with value '"..tostring(object).."' is not if type 'string', 'table', 'function' or 'userdata'.")
    end

    if Daneel.Event.fireAtTime[time] == nil then
        Daneel.Event.fireAtTime[time] = {}
    end
    table.insert(Daneel.Event.fireAtTime[time], {
        object = object,
        name = eventName,
        args = arg
    })
    Daneel.Debug.StackTrace.EndFunction()
end

--- Schedule an event to be fired or a function to be called at a particular frame.
-- Allowed set of arguments are : <br>
-- (frame, eventName[, ...]) <br>
-- (frame, object, eventName[, ...]) <br>
-- (frame, function[, ...])
-- @param frame (number) The frame at which to fire the event. 
-- @param object [optional] (table) The object to which fire the event at. If nil or abscent, will send the event to its listeners.
-- @param eventName (string) The event name.
-- @param ... [optional] Argument(s) to pass along.
function Daneel.Event.FireAtFrame(frame, object, eventName, ...)
    Daneel.Debug.StackTrace.BeginFunction("Daneel.Event.FireAtFrame", frame, eventName, arg)
    local errorHead = "Daneel.Event.FireAtFrame(frame[, object], eventName[, ...]) : "
    Daneel.Debug.CheckArgType(frame, "frame", "number", errorHead)
    
    local argType = type(object)
    if argType == "string" then
        if eventName ~= nil then
            table.insert(arg, 1, eventName)
        end
        eventName = object
        object = nil


    elseif argType == "function" or argType == "userdata" then
        if eventName ~= nil then
            table.insert(arg, 1, eventName)
        end
        eventName = nil

    elseif argType ~= "table" then
        error(errorHead.."Argument 'object' with value '"..tostring(object).."' is not if type 'string', 'table', 'function' or 'userdata'.")
    end 
    
    if Daneel.Event.fireAtFrame[frame] == nil then
        Daneel.Event.fireAtFrame[frame] = {}
    end
    table.insert(Daneel.Event.fireAtFrame[frame], {
        object = object,
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
function Daneel.Lang.Get(key, replacements)
    Daneel.Debug.StackTrace.BeginFunction("Daneel.Lang.GetLine", key, replacements)
    local errorHead = "Daneel.Lang.GetLine(key[, replacements]) : "
    Daneel.Debug.CheckArgType(key, "key", "string", errorHead)
    local currentLanguage = config.language.current
    local defaultLanguage = config.language.default
    local searchInDefault = config.language.searchInDefault

    local keys = key:split(".")
    local language = currentLanguage
    if keys[1]:isoneof(config.language.languageNames) then
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
            if language ~= defaultLanguage and searchInDefault == true then  
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


----------------------------------------------------------------------------------
-- Time

Daneel.Time = {
    realTime = 0.0,
    realDeltaTime = 0.0,

    time = 0.0,
    deltaTime = 0.0,
    timeScale = 1.0,

    frameCount = 0,

    timedUpdates = {
        -- scriptedBehavior = { timedDeltaTime, lastTimedUpdate } 
    },
}
-- see below in Daneel.Update()


----------------------------------------------------------------------------------
-- Runtime
local luaDocStop = ""

-- load Daneel at the start of the game
function Daneel.Load()
    if DANEEL_LOADED == true then return end

    if Daneel.Debug.GlobalExists("DaneelConfig") then
        config = table.deepmerge(DaneelDefaultConfig(), DaneelConfig())
    else
        config = DaneelDefaultConfig()
    end
    
    DEBUG = config.debug.enableDebug
    if DEBUG == true and config.debug.enableStackTrace == true then
        SetNewError()
    end

    -- Objects
    config.componentObjects = table.merge(
        config.craftStudioComponentObjects,
        config.daneelComponentObjects
    )
    config.componentTypes = table.getkeys(config.componentObjects)
    config.daneelComponentTypes = table.getkeys(config.daneelComponentObjects)
    config.assetTypes = table.getkeys(config.assetObjects)
    
    -- all objects (for use in GetType())
    config.allObjects = table.merge(
        config.craftStudioObjects,
        config.assetObjects,
        config.daneelObjects,
        config.componentObjects,
        config.userObjects
    )

    Daneel.Debug.StackTrace.BeginFunction("Daneel.Load")

    -- Scripts
    for i, path in pairs(config.scriptPaths) do
        local script = Asset.Get(path, "Script") -- Asset.Get() helpers does not exist yet
        if script ~= nil then
            Daneel.Utilities.AllowDynamicGettersAndSetters(script, { Script, Component })

            script['__tostring'] = function(scriptedBehavior)
                return "ScriptedBehavior"..tostring(scriptedBehavior.inner):sub(2, 20)
            end
        else
            if math.isinteger(i) then
                table.remove(config.scriptPaths, i)
            else
                config.scriptPaths[i] = nil
            end
            if DEBUG == true then
                print("WARNING : item with key '"..i.."' and value '"..path.."' in 'config.scriptPaths' is not a valid script path.")
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
    for i, language in ipairs(config.language.languageNames) do
        local functionName = "DaneelLanguage"..language:ucfirst()
        if Daneel.Debug.GlobalExists(functionName) == true then
            Daneel.Lang.lines[language] = _G[functionName]()
        elseif DEBUG == true then
            print("WARNING : Can't load the language '"..language.."' because the global function "..functionName.."() does not exists.")
        end
    end
    if config.language.default == nil then
        config.language.default = config.language.languageNames[1]
    end
    if config.language.current == nil then
        config.language.current = config.language.default
    end

    -- Tween
    if Daneel.Tween ~= nil then
        if Daneel.Debug.GlobalExists("GetEasingEquations") then
            Daneel.Tween.Ease = GetEasingEquations()
        else
            error("Daneel.Load() : Daneel.Tween object exists but the 'Easing' file is missing.")
        end
    end

    DANEEL_LOADED = true
    Daneel.Debug.StackTrace.EndFunction()
end -- end Daneel.Load()


-- called from DaneelBehavior Behavior:Awake()
function Daneel.Awake()
    Daneel.Load()
    Daneel.Debug.StackTrace.BeginFunction("Daneel.Awake")

    -- GUI
    -- setting pixelToUnits  
    config.gui.screenSize = CraftStudio.Screen.GetSize()
    -- get the smaller side of the screen (usually screenSize.y, the height)
    local smallSideSize = config.gui.screenSize.y
    if config.gui.screenSize.x < config.gui.screenSize.y then
        smallSideSize = config.gui.screenSize.x
    end

    config.gui.hudCameraGO = GameObject.Get(config.gui.hudCameraName)

    if config.gui.hudCameraGO ~= nil then
        -- The orthographic scale value (in units) is equivalent to the smallest side size of the screen (in pixel)
        -- pixelsToUnits (in units/pixels) is the correspondance between screen pixels and 3D world units
        Daneel.GUI.pixelsToUnits = 10 / smallSideSize
        --Daneel.GUI.pixelsToUnits = config.gui.hudCameraGO.camera.orthographicScale / smallSideSize

        config.gui.hudOriginGO = GameObject.New("HUDOrigin", { parent = config.gui.hudCameraGO })
        config.gui.hudOriginGO.transform.localPosition = Vector3:New(
            -config.gui.screenSize.x * Daneel.GUI.pixelsToUnits / 2, 
            config.gui.screenSize.y * Daneel.GUI.pixelsToUnits / 2,
            0
        )
        -- the HUDOrigin is now at the top-left corner of the screen
        config.gui.hudOriginPosition = config.gui.hudOriginGO.transform.position
    end

    -- Awakening is over
    if DEBUG == true then
        print("~~~~~ Daneel is awake ~~~~~")
    end

    Daneel.Event.Fire("DaneelAwake")
    Daneel.Debug.StackTrace.EndFunction()
end 

-- called from DaneelBehavior Behavior:Update()
function Daneel.Update()
    -- Time
    local currentTime = os.clock()
    Daneel.Time.realDeltaTime = currentTime - Daneel.Time.realTime
    Daneel.Time.realTime = currentTime

    Daneel.Time.deltaTime = Daneel.Time.realDeltaTime * Daneel.Time.timeScale
    Daneel.Time.time = Daneel.Time.time + Daneel.Time.deltaTime

    Daneel.Time.frameCount = Daneel.Time.frameCount + 1

    -- Scheduled events
    -- frame
    if Daneel.Event.fireAtFrame[Daneel.Time.frameCount] ~= nil then
        for i, event in ipairs(Daneel.Event.fireAtFrame[Daneel.Time.frameCount]) do
            if event.name == nil then
                Daneel.Event.Fire(event.object, unpack(event.args))
            else
                Daneel.Event.Fire(event.object, event.name, unpack(event.args))
            end
        end
        Daneel.Event.fireAtFrame[Daneel.Time.frameCount] = nil
    end

    -- real time
    local realTimes = {}
    for realTime, events in pairs(Daneel.Event.fireAtRealTime) do
        if realTime <= Daneel.Time.realTime then
            table.insert(realTimes, realTime)
        end
    end
    table.sort(realTimes)
    for i, realTime in ipairs(realTimes) do
        for i, event in ipairs(Daneel.Event.fireAtRealTime[realTime]) do
            if event.name == nil then
                Daneel.Event.Fire(event.object, unpack(event.args))
            else
                Daneel.Event.Fire(event.object, event.name, unpack(event.args))
            end
        end
        Daneel.Event.fireAtRealTime[realTime] = nil
    end

    -- time
    local times = {}
    for time, events in pairs(Daneel.Event.fireAtTime) do
        if time <= Daneel.Time.time then
            table.insert(times, time)
        end
    end
    table.sort(times)
    for i, time in ipairs(times) do
        for i, event in ipairs(Daneel.Event.fireAtTime[time]) do
            if event.name == nil then
                Daneel.Event.Fire(event.object, unpack(event.args))
            else
                Daneel.Event.Fire(event.object, event.name, unpack(event.args))
            end
        end
        Daneel.Event.fireAtTime[time] = nil
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

    -- Tween
    if Daneel.Tween ~= nil then
        Daneel.Tween.Update()
    end
end


----------------------------------------------------------------------------------
-- Vector 2

Vector2 = {}
Vector2.__index = Vector2
setmetatable(Vector2, { __call = function(Object, ...) return Object.New(...) end })

function Vector2.__tostring(vector2)
    return "Vector2: { x="..vector2.x..", y="..vector2.y.." }"
end

--- Creates a new Vector2 intance.
-- @param x (number or string) The vector's x component.
-- @param y [optional] (number or string) The vector's y component. If nil, will be equal to x. 
-- @return (Vector2) The new instance.
function Vector2.New(x, y)
    Daneel.Debug.StackTrace.BeginFunction("Vector2.New", x, y)
    local errorHead = "Vector2.New(x, y) : "
    Daneel.Debug.CheckArgType(x, "x", {"string", "number"}, errorHead)
    Daneel.Debug.CheckOptionalArgType(y, "y", {"string", "number"}, errorHead)
    if y == nil then y = x end
    local vector = setmetatable({ x = x, y = y }, Vector2)
    Daneel.Debug.StackTrace.EndFunction()
    return vector
end

--- Allow to add two Vector2 by using the + operator.
-- Ie : vector1 + vector2
-- @param a (Vector2) The left member.
-- @param b (Vector2) The right member.
-- @return (Vector2) The new vector.
function Vector2.__add(a, b)
    Daneel.Debug.StackTrace.BeginFunction("Vector2.__add", a, b)
    local errorHead = "Vector2.__add(a, b) : "
    Daneel.Debug.CheckArgType(a, "a", "Vector2", errorHead)
    Daneel.Debug.CheckArgType(b, "b", "Vector2", errorHead)
    a = Vector2.New(a.x + b.x, a.y + b.y)
    Daneel.Debug.StackTrace.EndFunction()
    return a
end

--- Allow to substract two Vector2 by using the - operator.
-- Ie : vector1 - vector2
-- @param a (Vector2) The left member.
-- @param b (Vector2) The right member.
-- @return (Vector2) The new vector.
function Vector2.__sub(a, b)
    Daneel.Debug.StackTrace.BeginFunction("Vector2.__sub", a, b)
    local errorHead = "Vector2.__sub(a, b) : "
    Daneel.Debug.CheckArgType(a, "a", "Vector2", errorHead)
    Daneel.Debug.CheckArgType(b, "b", "Vector2", errorHead)
    a = Vector2.New(a.x - b.x, a.y - b.y)
    Daneel.Debug.StackTrace.EndFunction()
    return a
end

--- Allow to multiply two Vector2 or a Vector2 and a number by using the * operator.
-- @param a (Vector2 or number) The left member.
-- @param b (Vector2 or number) The right member.
-- @return (Vector2) The new vector.
function Vector2.__mul(a, b)
    Daneel.Debug.StackTrace.BeginFunction("Vector2.__mull", a, b)
    local errorHead = "Vector2.__mul(a, b) : "
    Daneel.Debug.CheckArgType(a, "a", {"Vector2", "number"}, errorHead)
    Daneel.Debug.CheckArgType(b, "b", {"Vector2", "number"}, errorHead)
    local newVector = 0
    if type(a) == "number" then
        newVector = Vector2.New(a * b.x, a * b.y)
    elseif type(b) == "number" then
        newVector = Vector2.New(a.x * b, a.y * b)
    else
        newVector = Vector2.New(a.x * b.x, a.y * b.y)
    end
    Daneel.Debug.StackTrace.EndFunction()
    return newVector
end

--- Allow to divide two Vector2 or a Vector2 and a number by using the / operator.
-- @param a (Vector2 or number) The numerator.
-- @param b (Vector2 or number) The denominator. Can't be equal to 0.
-- @return (Vector2) The new vector.
function Vector2.__div(a, b)
    Daneel.Debug.StackTrace.BeginFunction("Vector2.__div", a, b)
    local errorHead = "Vector2.__div(a, b) : "
    Daneel.Debug.CheckArgType(a, "a", {"Vector2", "number"}, errorHead)
    Daneel.Debug.CheckArgType(b, "b", {"Vector2", "number"}, errorHead)
    local newVector = 0
    if type(a) == "number" then
        if b.x == 0 or b.y == 0 then
            error(errorHead.."One of the components of the denominator is equal to 0. Can't divide by 0 ! b.x="..b.x.." b.y="..b.y)
        end
        newVector = Vector2.New(a / b.x, a / b.y)
    elseif type(b) == "number" then
        if b == 0 then
            error(errorHead.."The denominator is equal to 0 ! Can't divide by 0 !")
        end
        newVector = Vector2.New(a.x / b, a.y / b)
    else
        if b.x == 0 or b.y == 0 then
            error(errorHead.."One of the components of the denominator is equal to 0. Can't divide by 0 ! b.x="..b.x.." b.y="..b.y)
        end
        newVector = Vector2.New(a.x / b.x, a.y / b.y)
    end
    Daneel.Debug.StackTrace.EndFunction()
    return newVector
end

--- Allow to inverse a vector2 using the - operator.
-- @param vector (Vector2) The vector.
-- @return (Vector2) The new vector.
function Vector2.__unm(vector)
    Daneel.Debug.StackTrace.BeginFunction("Vector2.__unm", vector)
    local errorHead = "Vector2.__unm(vector) : "
    Daneel.Debug.CheckArgType(vector, "vector", "Vector2", errorHead)
    local vector = Vector2.New(-vector.x, -vector.y)
    Daneel.Debug.StackTrace.EndFunction()
    return vector
end

--- Allow to raise a Vector2 to a power using the ^ operator.
-- @param vector (Vector2) The vector.
-- @param exp (number) The power to raise the vector to.
-- @return (Vector2) The new vector.
function Vector2.__pow(vector, exp)
    Daneel.Debug.StackTrace.BeginFunction("Vector2.__pow", vector, exp)
    local errorHead = "Vector2.__pow(vector, exp) : "
    Daneel.Debug.CheckArgType(vector, "vector", "Vector2", errorHead)
    Daneel.Debug.CheckArgType(exp, "exp", "number", errorHead)
    vector = Vector2.New(vector.x ^ exp, vector.y ^ exp)
    Daneel.Debug.StackTrace.EndFunction()
    return vector
end

--- Allow to check for the equality between two Vector2 using the == comparison operator.
-- @param a (Vector2) The left member.
-- @param b (Vector2) The right member.
-- @return (boolean) True if the same components of the two vectors are equal (a.x=b.x and a.y=b.y)
function Vector2.__eq(a, b)
    Daneel.Debug.StackTrace.BeginFunction("Vector2.__eq", a, b)
    local errorHead = "Vector2.__eq(a, b) : "
    Daneel.Debug.CheckArgType(a, "a", "Vector2", errorHead)
    Daneel.Debug.CheckArgType(b, "b", "Vector2", errorHead)
    local eq = ((a.x == b.x) and (a.y == b.y))
    Daneel.Debug.StackTrace.EndFunction()
    return eq
end

--- Return the length of the vector.
-- @param vector (Vector2) The vector.
function Vector2.GetLength(vector)
    return math.sqrt(vector.x^2 + vector.y^2)
end
