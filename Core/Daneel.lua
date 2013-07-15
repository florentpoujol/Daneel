
DANEEL_LOADED = false
DEBUG = false
config = {}
Daneel = {}

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

            -- Tell wether Daneel.Lang.Get() search a line key in the default language 
            -- when it is not found in the current language before returning the value of keyNotFound
            searchInDefault = true,
        },


        ----------------------------------------------------------------------------------

        debug = {
            -- Enable/disable Daneel's global debugging features.
            enableDebug = true,

            -- Enable/disable the Stack Trace.
            enableStackTrace = true,
        },


        ----------------------------------------------------------------------------------

        -- default components settings
        components = {},


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
            TextRenderer = TextRenderer,
            NetworkSync = NetworkSync,
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
            Font = Font,
        },
        
        -- Daneel
        daneelObjects = {
            RaycastHit = RaycastHit,
        },

        daneelComponentObjects = {},

        -- custom
        userObjects = {},

        -- other properties created at runtime :
        -- componentObjects : a merge of craftStudioComponentObjects and daneelComponentObjects
        -- componentTypes : the list of the component types (the keys of componentObjects)
        -- daneelComponentTypes
        -- assetTypes
        -- allObjects : a merge of all *Objects tables


        ----------------------------------------------------------------------------------

        modules = {
            "GUI",
            "Tween",
        }
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
function Daneel.Utilities.AllowDynamicGettersAndSetters( Object, ancestors )
    function Object.__index( instance, key )

        local uckey = key:ucfirst()
        if key == uckey then 
            -- first letter was already uppercase
            -- it may be a function or a property
            if Object[ key ] ~= nil then
                return Object[ key ]
            end

            if ancestors ~= nil then
                for i, Ancestor in ipairs( ancestors ) do
                    if Ancestor[ key ] ~= nil then
                        return Ancestor[ key ]
                    end
                end
            end

        else
            -- first letter lowercase, search for the corresponding getter

            local funcName = "Get"..uckey

            if Object[ funcName ] ~= nil then
                return Object[ funcName ]( instance )
            elseif Object[ key ] ~= nil then
                return Object[ key ]
            end

            if ancestors ~= nil then
                for i, Ancestor in ipairs( ancestors ) do
                    if Ancestor[ funcName ] ~= nil then
                        return Ancestor[ funcName ]( instance )
                    elseif Ancestor[ key ] ~= nil then
                        return Ancestor[ key ]
                    end
                end
            end
        end

        return nil
    end

    function Object.__newindex(instance, key, value)
        local uckey = key:ucfirst()
        if key ~= uckey then -- first letter lowercase
            local funcName = "Set"..uckey
            if Object[ funcName ] ~= nil then
                return Object[ funcName ]( instance, value )
            end
        end
        -- first letter was already uppercase
        return rawset( instance, key, value )
    end
end

--- Returns the value of any global variable (including nested tables) from its name as a string.
-- When the variable is nested in one or several tables (like Daneel.GUI.Hud), put a dot between the names.
-- @param name (string) The variable name.
-- @return (mixed) The variable value, or nil.
function Daneel.Utilities.GetValueFromName(name)
    Daneel.Debug.StackTrace.BeginFunction("Daneel.Utilities.GetValueFromName", name)
    local errorHead = "Daneel.Utilities.GetValueFromName(name) : "
    Daneel.Debug.CheckArgType(name, "name", "string", errorHead)
    
    local value = nil
    if name:find(".") == nil then
        if Daneel.Utilities.GlobalExists(name) == true then
            value = _G[name]
        end
        Daneel.Debug.StackTrace.EndFunction()
        return value
    
    else
        local subNames = name:split(".")
        local varName = table.remove(subNames, 1)
        if Daneel.Utilities.GlobalExists(varName) == true then
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
-- Since CraftStudio uses Strict.lua, you can not write (variable == nil), nor (_G[variable] == nil).
-- Only works for first-level global variables. Check if Daneel.Utilities.GetValueFromName() returns nil for the same effect with nested tables.
-- @param name (string) The variable name.
-- @return (boolean) True if it exists, false otherwise.
function Daneel.Utilities.GlobalExists(name)
    Daneel.Debug.StackTrace.BeginFunction("Daneel.Utilities.GlobalExists", name)
    Daneel.Debug.CheckArgType(name, "name", "string", "Daneel.Utilities.GlobalExists(name) : ")
    
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

--- A more flexible version of Lua's built-in tonumber() function.
-- Returns the first continuous series of numbers found in the text version of the provided data een if it is prefixed or suffied by other characters.
-- @param data (mixed) Usualy string or userdata.
-- @param (number) The number, or nil.
function Daneel.Utilities.ToNumber( data )
    Daneel.Debug.StackTrace.BeginFunction( "Daneel.Utilities.ToNumber", data )
    local errorHead = "Daneel.Utilities.ToNumber( data ) : "
    if data == nil then
        error( errorHead .. "Argument 'data' is nil." )
    end

    local number = tonumber( data )
    if number == nil then
        number = ""
        data = tostring( data ):totable()

        for i, char in ipairs( data ) do
            if tonumber( char ) ~= nil then
                number = number .. char
            elseif number ~= "" then
                break
            end
        end

        number = tonumber( number )
    end

    Daneel.Debug.StackTrace.EndFunction()
    return number
end


----------------------------------------------------------------------------------
-- Debug

Daneel.Debug = {}

--- Check the provided argument's type against the provided type(s) and display error if they don't match.
-- @param argument (mixed) The argument to check.
-- @param argumentName (string) The argument name.
-- @param expectedArgumentTypes (string or table) The expected argument type(s).
-- @param p_errorHead [optional] (string) The beginning of the error message.
-- @return (mixed) The argument's type.
function Daneel.Debug.CheckArgType(argument, argumentName, expectedArgumentTypes, p_errorHead)
    if DEBUG == false then return Daneel.Debug.GetType(argument) end
    local errorHead = "Daneel.Debug.CheckArgType(argument, argumentName, expectedArgumentTypes[, p_errorHead]) : "
    
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
            return expectedType
        end
    end
    error(p_errorHead.."Argument '"..argumentName.."' is of type '"..argType.."' with value '"..tostring(argument).."' instead of '"..table.concat(expectedArgumentTypes, "', '").."'.")
end

--- If the provided argument is not nil, check the provided argument's type against the provided type(s) and display error if they don't match.
-- @param argument (mixed) The argument to check.
-- @param argumentName (string) The argument name.
-- @param expectedArgumentTypes (string or table) The expected argument type(s).
-- @param p_errorHead [optional] (string) The beginning of the error message.
-- @param defaultValue [optional] (mixed) The default value to return if 'argument' is nil.
-- @return (mixed) The value of 'argument' if it's non-nil, or the value of 'defaultValue'.
function Daneel.Debug.CheckOptionalArgType(argument, argumentName, expectedArgumentTypes, p_errorHead, defaultValue)
    if argument == nil then return defaultValue end
    if DEBUG == false then return argument end
    local errorHead = "Daneel.Debug.CheckOptionalArgType(argument, argumentName, expectedArgumentTypes[, p_errorHead, defaultValue]) : "
    
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
-- When the variable is nested in one or several tables (like Daneel.GUI.Hud), it must have been set in the 'userObject' table in the config if not already part of CraftStudio or Daneel.
-- @param value (table or function) Any global variable, any object from CraftStudio or Daneel or objects whose name is set in 'userObjects' in the config.
-- @return (string) The name, or nil.
function Daneel.Debug.GetNameFromValue(value)
    Daneel.Debug.StackTrace.BeginFunction("Daneel.Debug.GetNameFromValue", value)
    local errorHead = "Daneel.Debug.GetNameFromValue(value) : "
    if value == nil then
        error(errorHead.." Argument 'value' is nil.")
    end
    local result = table.getkey(config.allObjects, value)
    if result == nil then
        result = table.getkey(_G, value)
    end
    Daneel.Debug.StackTrace.EndFunction()
    return result
end

--- Check if the provided argument's value in found in the provided expected value(s).
-- When that's not the case, return the value of the 'defaultValue' argument, or throws an error when the 'defaultArgument' is nil. 
-- Arguments of type string are considered case-insensitive. The case will be corrected but no error will be thrown.
-- When 'expectedArgumentValues' is of type table, it is always considered as a table of several expected values.
-- @param argument (mixed) The argument to check.
-- @param argumentName (string) The argument name.
-- @param expectedArgumentValues (mixed) The expected argument values(s).
-- @param p_errorHead [optional] (string) The beginning of the error message.
-- @param defaultValue [optional] (mixed) The optional default value.
-- @return (mixed) The argument's value (one of the expected argument values or default value)
function Daneel.Debug.CheckArgValue(argument, argumentName, expectedArgumentValues, p_errorHead, defaultValue)
    Daneel.Debug.StackTrace.BeginFunction("Daneel.Debug.CheckArgValue", argument, argumentName, expectedArgumentValues, p_errorHead)
    local errorHead = "Daneel.Debug.CheckArgValue(argument, argumentName, expectedArgumentValues[, p_errorHead]) : "
    Daneel.Debug.CheckArgType(argumentName, "argumentName", "string", errorHead)
    if expectedArgumentValues == nil then
        error(errorHead.."Argument 'expectedArgumentValues' is nil.")
    end
    Daneel.Debug.CheckOptionalArgType(p_errorHead, "p_errorHead", "string", errorHead)
 
    if type(expectedArgumentValues) ~= "table" then
        expectedArgumentValues = { expectedArgumentValues }
    elseif #expectedArgumentValues == 0 then
        error(errorHead.."Argument 'expectedArgumentValues' is an empty table.")
    end

    local correctValue = false
    if type(argument) == "string" then
        for i, expectedValue in ipairs(expectedArgumentValues) do
            if argument:lower() == expectedValue:lower() then
                argument = expectedValue
                correctValue = true
                break
            end
        end
    else
        for i, expectedValue in ipairs(expectedArgumentValues) do
            if argument == expectedValue then
                correctValue = true
                break
            end
        end
    end

    if not correctValue then
        if defaultValue ~= nil then
            argument = defaultValue
        else
            for i, value in ipairs(expectedArgumentValues) do
                expectedArgumentValues[i] = tostring(value)
            end
            error(p_errorHead.."The value '"..tostring(argument).."' of argument '"..argumentName.."' is not one of '"..table.concat(expectedArgumentValues, "', '").."'.")
        end
    end
    Daneel.Debug.StackTrace.EndFunction()
    return argument
end


----------------------------------------------------------------------------------
-- StackTrace

Daneel.Debug.StackTrace = { messages = {} }

--- Register a function input in the stack trace.
-- @param functionName (string) The function name.
-- @param ... [optional] (mixed) Arguments received by the function.
function Daneel.Debug.StackTrace.BeginFunction(functionName, ...)
    if DEBUG == false or config.debug.enableStackTrace == false then return end
    if #Daneel.Debug.StackTrace.messages > 200 then 
        print("WARNING : your StackTrace is more than 200 items long ! Emptying the StackTrace now. Did you forget to write a 'EndFunction()' somewhere ?")
        Daneel.Debug.StackTrace.messages = {}
    end
    local errorHead = "Daneel.Debug.StackTrace.BeginFunction(functionName[, ...]) : "
    Daneel.Debug.CheckArgType(functionName, "functionName", "string", errorHead)
    local msg = functionName.."( "
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
    msg = msg.." )"
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
        local listeners = Daneel.Event.events[eventName]
        if listeners ~= nil then
            table.removevalue(listeners, functionOrObject)
        end
    end
    Daneel.Debug.StackTrace.EndFunction()
end

--- Remove the provided function or object from the listeners and scheduled events lists.
-- @param functionOrObject (function, userdata or table)
function Daneel.Event.Clean(functionOrObject)
    Daneel.Debug.StackTrace.BeginFunction("Daneel.Event.Clean", functionOrObject)
    local errorHead = "Daneel.Event.Clean(functionOrObject) : "
    Daneel.Debug.CheckArgType(functionOrObject, "functionOrObject", {"table", "function", "userdata"}, errorHead)

    for eventName, listeners in pairs(Daneel.Event.events) do
        table.removevalue(listeners, functionOrObject)
    end
    -- scheduled events
    for time, events in pairs(Daneel.Event.fireAtRealTime) do
        for i = #events, 1, -1 do
            if events[i].object == functionOrObject then
                table.remove(events, i)
            end
        end
    end
    for time, events in pairs(Daneel.Event.fireAtTime) do
        for i = #events, 1, -1 do
            if events[i].object == functionOrObject then
                table.remove(events, i)
            end
        end
    end
    for time, events in pairs(Daneel.Event.fireAtFrame) do
        for i = #events, 1, -1 do
            if events[i].object == functionOrObject then
                table.remove(events, i)
            end
        end
    end
    Daneel.Debug.StackTrace.EndFunction()
end

--- Fire the provided event on the provided objects (or the one that listen to it),
-- or call the provided function,
-- transmitting along all subsequent arguments if some exists. <br>
-- Allowed set of arguments are : <br>
-- (eventName[, ...]) <br>
-- (object, eventName[, ...]) <br>
-- (function[, ...])
-- @param object [optional] (table, function or userdata) The object to which fire the event at. If nil or abscent, will send the event to its listeners.
-- @param eventName (string) The event name.
-- @param ... [optional] Some arguments to pass along.
function Daneel.Event.Fire(object, eventName,  ...)
    Daneel.Debug.StackTrace.BeginFunction("Daneel.Event.Fire", object, eventName, unpack(arg))
    local errorHead = "Daneel.Event.Fire([object, ]eventName[, ...]) : "
    
    local argType = type(object)
    if argType == "string" or argType == "nil" then
        -- no object provided, fire on the listeners
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
        
        -- ensure that the event is not fired on a dead gameObject or component

        local _type = type(listener)
        if _type == "function" or _type == "userdata" then
            listener(unpack(arg))
        else -- an object
            --if the object is a gameObject or a component, check the inner variable
            local mt = getmetatable(listener)
            local isGameObjectOrComponent = ( mt == GameObject or table.containsvalue(config.componentObjects, mt) )
            if 
                listener.isDestroyed ~= true and
                (not isGameObjectOrComponent or listener.inner ~= nil)
                -- OK if
                -- not destroyed and (gameObject or component) and inner exists
                -- not destroyed and any object
            then
                local message = eventName

                -- look for the value of the EventName property on the object
                local funcOrMessage = listener[eventName]
                _type = type(funcOrMessage)
                if _type == "function" or _type == "userdata" then
                    funcOrMessage(unpack(arg))
                elseif _type == "string" then
                    message = funcOrMessage
                end

                -- always try to send the message, even when funcOrMessage was a function
                local sendMessage = true
                local gameObject = listener
                
                if getmetatable(gameObject) ~= GameObject then
                    gameObject = listener.gameObject
                    
                    if getmetatable(gameObject) ~= GameObject then
                        sendMessage = false
                        
                        if type(listener[eventName]) == "string" and DEBUG == true then
                            -- the user obviously wanted to send a message but the object is not a gameObject and has no gameObject property

                            -- only prints the debug when the user setted up the event property because otherwise
                            -- it would print it every time an event has not been set up (which is OK) on an non-gameObject object like a tweener
                            print(errorHead.."Can't fire event '"..eventName.."' by sending message '"..message.."' on object '"..tostring(listener).."'  because it not a gameObject and has no 'gameObject' property.")                      
                        end
                    end
                end
                if sendMessage then
                    gameObject:SendMessage(message, arg)
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

Daneel.Lang = { lines = {}, gameObjectsToUpdate = {} }

--- Get the localized line identified by the provided key.
-- @param key (string) The language key.
-- @param replacements [optional] (table) The placeholders and their replacements.
-- @return (string) The line.
function Daneel.Lang.Get(key, replacements)
    Daneel.Debug.StackTrace.BeginFunction("Daneel.Lang.Get", key, replacements)
    local errorHead = "Daneel.Lang.Get(key[, replacements]) : "
    Daneel.Debug.CheckArgType(key, "key", "string", errorHead)
    local currentLanguage = config.language.current
    local defaultLanguage = config.language.default
    local searchInDefault = config.language.searchInDefault

    local keys = key:split(".")
    local language = currentLanguage
    if keys[1]:isoneof(config.language.languageNames) then
        language = table.remove(keys, 1)
    end
    
    local noLangKey = table.concat(keys, ".") -- rebuilt the key, but without the language

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
                lines = Daneel.Lang.Get(defaultLanguage.."."..noLangKey, replacements)
            else -- already default language or don't want to search in
                lines = config.language.keyNotFound
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

--- Register a gameObject to update its TextRenderer whenever the language will be updated by Daneel.Lang.Update().
-- @param gameObject (GameObject) The gameObject.
-- @param key (string) The language key.
-- @param replacements [optional] (table) The placeholders and their replacements.
function Daneel.Lang.RegisterForUpdate(gameObject, key, replacements)
    Daneel.Debug.StackTrace.BeginFunction("Daneel.Lang.RegisterForUpdate", gameObject, key, replacements)
    local errorHead = "Daneel.Lang.RegisterForUpdate(gameObject, key[, replacements]) : "
    Daneel.Debug.CheckArgType(gameObject, "gameObject", "GameObject", errorHead)
    Daneel.Debug.CheckArgType(key, "key", "string", errorHead)
    Daneel.Debug.CheckOptionalArgType(replacements, "replacements", "table", errorHead)

    Daneel.Lang.gameObjectsToUpdate[gameObject] = {
        key = key,
        replacements = replacements,
    }
    Daneel.Debug.StackTrace.EndFunction()
end

--- Update the current language and the text of all gameObjects that have registered via Daneel.Lang.RegisterForUpdate()
-- Fire the OnLangUpdate event.
-- @param language (string) The new current language.
function Daneel.Lang.Update(language)
    Daneel.Debug.StackTrace.BeginFunction("Daneel.Lang.Update", language)
    local errorHead = "Daneel.Lang.Update(language) : "
    Daneel.Debug.CheckArgType(language, "language", "string", errorHead)
    language = Daneel.Debug.CheckArgValue(language, "language", config.language.languageNames, errorHead)
    
    config.language.current = language
    for gameObject, data in pairs(Daneel.Lang.gameObjectsToUpdate) do
        if gameObject.textRenderer ~= nil then
            gameObject.textRenderer.text = Daneel.Lang.Get(data.key, data.replacements)
        elseif DEBUG then
            print("WARNING : "..errorHead..tostring(gameObject).." does not have a TextRenderer component.")
        end
    end
    Daneel.Event.Fire("OnLangUpdate")
    Daneel.Debug.StackTrace.EndFunction()
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

    -- load default config, modules config, then user config
    config = DaneelDefaultConfig()
    -- do this once here to get the user list of modules
    -- if Daneel.Utilities.GlobalExists("DaneelConfig") and DaneelConfig().modules ~= nil then
    --     config.modules = table.deepmerge(config.modules, DaneelConfig().modules)
    -- end

    for i, module in ipairs(config.modules) do
        local functionName = "DaneelConfigModule"..module
        if Daneel.Utilities.GlobalExists(functionName) then
            config = table.deepmerge(config, _G[functionName]())
        end
    end
    
    if Daneel.Utilities.GlobalExists("DaneelConfig") then
        config = table.deepmerge(config, DaneelConfig())
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
        local script = CraftStudio.FindAsset(path, "Script")
        if script ~= nil then
            Daneel.Utilities.AllowDynamicGettersAndSetters(script, { Script, Component })

            script['__tostring'] = function(scriptedBehavior)
                return "ScriptedBehavior"..tostring(scriptedBehavior.inner):sub(2, 20)
            end
        else
            config.scriptPaths[i] = nil
            if DEBUG == true then
                print("WARNING : item with key '"..i.."' and value '"..path.."' in 'config.scriptPaths' is not a valid script path.")
            end
        end
    end

    -- Components
    for componentType, componentObject in pairs(config.componentObjects) do
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
        if Daneel.Utilities.GlobalExists(functionName) == true then
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

    -- Load modules 
    for i, module in ipairs(config.modules) do
        local functionName = "DaneelLoadModule"..module
        if Daneel.Utilities.GlobalExists(functionName) then
            _G[functionName]()
        end
    end

    DANEEL_LOADED = true
    if DEBUG == true then
        print("~~~~~ Daneel is loaded ~~~~~")
    end

    -- check for module update function
    -- do this now so that I don't have to call Daneel.Utilities.GlobalExists() every frame for every modules below
    config.moduleUpdateFunctions = {}
    for i, module in ipairs(config.modules) do
        local functionName = "DaneelUpdateModule"..module
        if Daneel.Utilities.GlobalExists(functionName) and type(_G[functionName]) == "function" then
            table.insert(config.moduleUpdateFunctions, _G[functionName])
        end
    end

    Daneel.Debug.StackTrace.EndFunction()
end -- end Daneel.Load()


-- called from DaneelBehavior Behavior:Awake()
function Daneel.Awake()
    Daneel.Load()
    Daneel.Debug.StackTrace.messages = {}
    Daneel.Debug.StackTrace.BeginFunction("Daneel.Awake")


    Daneel.Event.Listen("OnSceneLoad", function()
        GameObject.tags = {}
        Daneel.Lang.gameObjectsToUpdate = {}
    end)


    -- Awake modules 
    for i, module in ipairs(config.modules) do
        local functionName = "DaneelAwakeModule"..module
        if Daneel.Utilities.GlobalExists(functionName) then
            _G[functionName]()
        end
    end

    -- Awakening is over
    if DEBUG == true then
        print("~~~~~ Daneel is awake ~~~~~")
    end

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
        local ButtonName = buttonName:ucfirst()

        if CraftStudio.Input.WasButtonJustPressed(buttonName) then
            Daneel.Event.Fire("On"..ButtonName.."ButtonJustPressed")
        end

        if CraftStudio.Input.IsButtonDown(buttonName) then
            Daneel.Event.Fire("On"..ButtonName.."ButtonDown")
        end

        if CraftStudio.Input.WasButtonJustReleased(buttonName) then
            Daneel.Event.Fire("On"..ButtonName.."ButtonJustReleased")
        end
    end

    -- Update modules 
    for i, _function in ipairs(config.moduleUpdateFunctions) do
        _function()
    end
end
