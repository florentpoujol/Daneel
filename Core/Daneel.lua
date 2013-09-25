-- Daneel.lua
-- Contains most of Daneel's core fonctionnalities.
--
-- Last modified for v1.2.0
-- Copyright © 2013 Florent POUJOL, published under the MIT licence.

if CS.DaneelModules == nil then
    CS.DaneelModules = {}
end

Daneel = { isLoaded = false }
D = Daneel

----------------------------------------------------------------------------------
-- Config

function Daneel.DefaultConfig()
    return {
        -- Button names as you defined them in the "Administration > Game Controls" tab of your project.
        -- Button whose name is defined here can be used as HotKeys.
        buttonNames = {
            -- Ie: "Fire",
        },
    
        debug = {
            enableDebug = false, -- Enable/disable Daneel's global debugging features (error reporting + stacktrace).
            enableStackTrace = false, -- Enable/disable the Stack Trace.
        },
        
        ----------------------------------------------------------------------------------
      
        componentObjects = {},
        componentTypes = {},
        objects = {},
    }
end
Daneel.Config = Daneel.DefaultConfig()


----------------------------------------------------------------------------------
-- Utilities

Daneel.Utilities = {}

--- Make sure that the case of the provided name is correct by checking it against the values in the provided set.
-- @param name (string) The name to check the case of.
-- @param set (string or table) A single value or a table of values to check the name against.
function Daneel.Utilities.CaseProof( name, set )
    Daneel.Debug.StackTrace.BeginFunction( "Daneel.Utilities.CaseProof", name, set )
    local errorHead = "Daneel.Utilities.CaseProof( name, set ) : " 
    Daneel.Debug.CheckArgType( name, "name", "string", errorHead )
    Daneel.Debug.CheckArgType( set, "set", {"string", "table"}, errorHead )

    if type( set ) == "string" then
        set = { set }
    end
    local lname = name:lower()
    for i, item in pairs( set ) do
        if lname == item:lower() then
            name = item
            break
        end
    end
    Daneel.Debug.StackTrace.EndFunction()
    return name
end

--- Replace placeholders in the provided string with their corresponding provided replacements.
-- @param string (string) The string.
-- @param replacements (table) The placeholders and their replacements ( { placeholder = "replacement", ... } ).
-- @return (string) The string.
function Daneel.Utilities.ReplaceInString( string, replacements )
    Daneel.Debug.StackTrace.BeginFunction( "Daneel.Utilities.ReplaceInString", string, replacements )
    local errorHead = "Daneel.Utilities.ReplaceInString( string, replacements ) : "
    Daneel.Debug.CheckArgType( string, "string", "string", errorHead )
    Daneel.Debug.CheckArgType( replacements, "replacements", "table", errorHead )
    
    for placeholder, replacement in pairs( replacements ) do
        string = string:gsub( ":"..placeholder, replacement )
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
-- When the variable is nested in one or several tables (like CS.Input), put a dot between the names.
-- @param name (string) The variable name.
-- @return (mixed) The variable value, or nil.
function Daneel.Utilities.GetValueFromName( name )
    Daneel.Debug.StackTrace.BeginFunction( "Daneel.Utilities.GetValueFromName", name )
    local errorHead = "Daneel.Utilities.GetValueFromName( name ) : "
    Daneel.Debug.CheckArgType( name, "name", "string", errorHead )
    
    local value = nil
    if name:find( ".", 1, true ) ~= nil then
        local subNames = name:split( "." )
        local varName = table.remove( subNames, 1 )

        if Daneel.Utilities.GlobalExists( varName ) then
            value = _G[ varName ]
        end
        if value == nil then
            if Daneel.Config.debug.enableDebug then
                print( "WARNING : "..errorHead.." : variable '"..varName.."' (from provided name '"..name.."' ) does not exists. Returning nil." )
            end
            Daneel.Debug.StackTrace.EndFunction()
            return nil
        end
        
        for i, _key in ipairs( subNames ) do
            varName = varName .. "." .. _key
            if value[ _key ] == nil then
                if Daneel.Config.debug.enableDebug then
                    print( "WARNING : "..errorHead.." : variable '"..varName.."' (from provided name '"..name.."' ) does not exists. Returning nil." )
                end
                Daneel.Debug.StackTrace.EndFunction()
                return nil
            else
                value = value[ _key ]
            end
        end
    else
        for k, v in pairs( _G ) do
            if k == name then
                value = v
                break
            end
        end
    end

    Daneel.Debug.StackTrace.EndFunction()
    return value
end

--- Tell wether the provided global variable name exists (is non-nil).
-- Since CraftStudio uses Strict.lua, you can not write (variable == nil), nor (_G[variable] == nil).
-- Only works for first-level global variables. Check if Daneel.Utilities.GetValueFromName() returns nil for the same effect with nested tables.
-- @param name (string) The variable name.
-- @return (boolean) True if it exists, false otherwise.
function Daneel.Utilities.GlobalExists( name )
    Daneel.Debug.StackTrace.BeginFunction( "Daneel.Utilities.GlobalExists", name )
    Daneel.Debug.CheckArgType( name, "name", "string", "Daneel.Utilities.GlobalExists( name ) : " )
    
    local exists = false
    for key, value in pairs( _G ) do
        if key == name then
            exists = true
            break
        end
    end
    Daneel.Debug.StackTrace.EndFunction()
    return exists
end

--- A more flexible version of Lua's built-in tonumber() function.
-- Returns the first continuous series of numbers found in the text version of the provided data even if it is prefixed or suffied by other characters.
-- @param data (mixed) Usually string or userdata.
-- @return (number) The number, or nil.
function Daneel.Utilities.ToNumber( data )
    Daneel.Debug.StackTrace.BeginFunction( "Daneel.Utilities.ToNumber", data )
    local errorHead = "Daneel.Utilities.ToNumber( data ) : "
    if data == nil then
        error( errorHead .. "Argument 1 'data' is nil." )
    end

    local number = tonumber( data )
    if number == nil then
        data = tostring( data )
        number = data:match( (data:gsub( "(%d+)", "(%1)" )) )
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
    if Daneel.Config.debug.enableDebug == false then return Daneel.Debug.GetType(argument) end
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
    if Daneel.Config.debug.enableDebug == false then return argument end
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

-- For instances of objects, the type is the name of the metatable of the provided object, if the metatable is a first-level global variable. 
-- Will return "ScriptedBehavior" when the provided object is a scripted behavior instance (yet ScriptedBehavior is not its metatable).
-- @param object (mixed) The argument to get the type of.
-- @param luaTypeOnly (boolean) [optional default=false] Tell whether to return only Lua's built-in types (string, number, boolean, table, function, userdata or thread).
-- @return (string) The type.
function Daneel.Debug.GetType( object, luaTypeOnly )
    local errorHead = "Daneel.Debug.GetType( object[, luaTypeOnly] ) : "
    -- DO NOT use CheckArgType here since it uses itself GetType() => overflow
    local argType = type( luaTypeOnly )
    if argType ~= "nil" and argType ~= "boolean" then
        error(errorHead.."Argument 'luaTypeOnly' is of type '"..argType.."' with value '"..tostring(luaTypeOnly).."' instead of 'boolean'.")
    end
    if luaTypeOnly == nil then luaTypeOnly = false end

    argType = type( object )
    if not luaTypeOnly and argType == "table" then
        -- the type is defined by the object's metatable
        local mt = getmetatable( object )
        if mt ~= nil then
            -- the metatable of the scripted behaviors is the corresponding script asset ('Behavior' in the script)
            -- the metatable of all script assets is the Script object
            if getmetatable( mt ) == Script then
                return "ScriptedBehavior"
            end

            if Daneel.Config.objects ~= nil then
                for type, object in pairs( Daneel.Config.objects ) do
                    if mt == object then
                        return type
                    end
                end
            end

            for type, object in pairs( _G ) do
                if mt == object then
                    return type
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
        if Daneel.Config.debug.enableDebug and doNotPrintStacktrace ~= true then
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
    Daneel.Config.debug.enableDebug = false
end

--- Bypass the __tostring() function that may exists on the data's metatable.
-- @param data (mixed) The data to be converted to string.
-- @return (string) The string.
function Daneel.Debug.ToRawString( data )
    Daneel.Debug.StackTrace.BeginFunction( "Daneel.Utilities.GlobalExists", data )
    if data == nil and Daneel.Config.debug.enableDebug then
        print( "WARNING : Daneel.Debug.ToRawString( data ) : Argument 'data' is nil.")
        Daneel.Debug.StackTrace.EndFunction()
        return nil
    end

    local text = nil
    local mt = getmetatable( data )
    if mt ~= nil then
        if mt.__tostring ~= nil then
            local mttostring = mt.__tostring
            mt.__tostring = nil
            text = tostring( data )
            mt.__tostring = mttostring
        end
    end
    if text == nil then 
        text = tostring( data )
    end
    Daneel.Debug.StackTrace.EndFunction()
    return text
end

--- Returns the name as a string of the global variable (including nested tables) whose value is provided.
-- This only works if the value of the variable is a table or a function.
-- When the variable is nested in one or several tables (like GUI.Hud), it must have been set in the 'userObject' table in the config if not already part of CraftStudio or Daneel.
-- @param value (table or function) Any global variable, any object from CraftStudio or Daneel or objects whose name is set in 'userObjects' in the Daneel.Config.
-- @return (string) The name, or nil.
function Daneel.Debug.GetNameFromValue(value)
    Daneel.Debug.StackTrace.BeginFunction("Daneel.Debug.GetNameFromValue", value)
    local errorHead = "Daneel.Debug.GetNameFromValue(value) : "
    if value == nil then
        error(errorHead.." Argument 'value' is nil.")
    end
    local result = table.getkey(Daneel.Config.objects, value)
    if result == nil then
        result = table.getkey(_G, value)
    end
    Daneel.Debug.StackTrace.EndFunction()
    return result
end

--- Check if the provided argument's value in found in the provided expected value(s).
-- When that's not the case, return the value of the 'defaultValue' argument, or throws an error when it is nil. 
-- Arguments of type string are considered case-insensitive. The case will be corrected but no error will be thrown.
-- When 'expectedArgumentValues' is of type table, it is always considered as a table of several expected values.
-- @param argument (mixed) The argument to check.
-- @param argumentName (string) The argument name.
-- @param expectedArgumentValues (mixed) The expected argument values(s).
-- @param p_errorHead [optional] (string) The beginning of the error message.
-- @param defaultValue [optional] (mixed) The optional default value.
-- @return (mixed) The argument's value (one of the expected argument values or default value)
function Daneel.Debug.CheckArgValue(argument, argumentName, expectedArgumentValues, p_errorHead, defaultValue)
    if not Daneel.isLoaded then 
        if argument == nil and defaultValue ~= nil then
            return defaultValue
        end
        return argument
    end

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
function Daneel.Debug.StackTrace.BeginFunction( functionName, ... )
    if Daneel.Config.debug.enableDebug == false or Daneel.Config.debug.enableStackTrace == false then return end

    if #Daneel.Debug.StackTrace.messages > 200 then 
        print( "WARNING : your StackTrace is more than 200 items long ! Emptying the StackTrace now. Did you forget to write a 'EndFunction()' somewhere ?" )
        Daneel.Debug.StackTrace.messages = {}
    end

    local errorHead = "Daneel.Debug.StackTrace.BeginFunction( functionName[, ...] ) : "
    Daneel.Debug.CheckArgType( functionName, "functionName", "string", errorHead )

    local msg = functionName .. "( "

    if #arg > 0 then
        for i, argument in ipairs( arg ) do
            if type( argument) == "string" then
                msg = msg .. '"' .. tostring( argument ) .. '", '
            else
                msg = msg .. tostring( argument ) .. ", "
            end
        end

        msg = msg:sub( 1, #msg-2 ) -- removes the last coma+space
    end

    msg = msg .. " )"

    table.insert( Daneel.Debug.StackTrace.messages, msg )
end

--- Closes a successful function call, removing it from the stacktrace.
function Daneel.Debug.StackTrace.EndFunction()
    if Daneel.Config.debug.enableDebug == false or Daneel.Config.debug.enableStackTrace == false then return end
    -- since 16/05/2013 no arguments is needed anymore, since the StackTrace only keeps open functions calls and never keep returned values
    -- I didn't rewrote all the calls to EndFunction() 
    table.remove( Daneel.Debug.StackTrace.messages )
end

--- Print the StackTrace.
function Daneel.Debug.StackTrace.Print()
    if Daneel.Config.debug.enableDebug == false or Daneel.Config.debug.enableStackTrace == false then return end

    local messages = Daneel.Debug.StackTrace.messages
    Daneel.Debug.StackTrace.messages = {}

    print( "~~~~~ Daneel.Debug.StackTrace ~~~~~" )

    if #messages <= 0 then
        print( "No message in the StackTrace." )
    else
        for i, msg in ipairs( messages ) do
            if i < 10 then
                i = "0"..i
            end
            print( "#" .. i .. " " .. msg )
        end
    end
end


----------------------------------------------------------------------------------
-- Event

Daneel.Event = { 
    events = {},
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
function Daneel.Event.StopListen( eventName, functionOrObject)
    if type( eventName ) ~= "string" then
        functionOrObject = eventName
        eventName = nil 
    end

    Daneel.Debug.StackTrace.BeginFunction( "Daneel.Event.StopListen", eventName, functionOrObject )
    local errorHead = "Daneel.Event.StopListen( eventName, functionOrObject ) : "
    Daneel.Debug.CheckOptionalArgType( eventName, "eventName", "string", errorHead )
    Daneel.Debug.CheckArgType( functionOrObject, "functionOrObject", {"table", "function"}, errorHead )
    
    local eventNames = eventName
    if type( eventName ) == "string" then
        eventNames = { eventName }
    end
    if eventNames == nil then
        eventNames = table.getkeys( Daneel.Event.events )
    end

    for i, eventName in pairs( eventNames ) do
        local listeners = Daneel.Event.events[ eventName ]
        if listeners ~= nil then
            table.removevalue( listeners, functionOrObject )
        end
    end
    Daneel.Debug.StackTrace.EndFunction()
end

--- Fire the provided event at the provided object or the one that listen to it,
-- transmitting along all subsequent arguments if some exists. <br>
-- Allowed set of arguments are : <br>
-- (eventName[, ...]) <br>
-- (object, eventName[, ...]) <br>
-- @param object [optional] (table) The object to which fire the event at. If nil or abscent, will send the event to its listeners.
-- @param eventName (string) The event name.
-- @param ... [optional] Some arguments to pass along.
function Daneel.Event.Fire( object, eventName,  ... )
    Daneel.Debug.StackTrace.BeginFunction( "Daneel.Event.Fire", object, eventName, unpack( arg ) )
    local errorHead = "Daneel.Event.Fire( [object, ]eventName[, ...] ) : "
    
    local argType = type( object )
    if argType == "string" or argType == "nil" then -- 17/09/13 why checking for nil ?
        -- no object provided, fire on the listeners
        if eventName ~= nil then
            table.insert( arg, 1, eventName )
        end
        eventName = object
        object = nil

    else
        Daneel.Debug.CheckArgType( object, "object", "table", errorHead )
        Daneel.Debug.CheckArgType( eventName, "eventName", "string", errorHead )
    end

    
    local listeners = { object }
    if object == nil and Daneel.Event.events[ eventName ] ~= nil then
        listeners = Daneel.Event.events[ eventName ]
    end

    for i, listener in ipairs( listeners ) do
        
        local listenerType = type( listener )
        if listenerType == "function" or listenerType == "userdata" then
            listener( unpack( arg ) )

        else -- an object
            if listener.isDestroyed ~= true then -- ensure that the event is not fired on a dead gameObject or component
                local message = eventName

                -- look for the value of the EventName property on the object
                local funcOrMessage = listener[ eventName ]

                local _type = type( funcOrMessage )
                if _type == "function" or _type == "userdata" then
                    -- prevent a 'Behavior function' to be called as a regular function when the listener is a ScriptedBehavior
                    -- because the functin exist on the Script object and not on the ScriptedBehavior (the listener),
                    -- in which case rawget() returns nil
                    if rawget( listener, eventName ) == funcOrMessage then
                        funcOrMessage( unpack( arg ) )
                    end

                elseif _type == "string" then
                    message = funcOrMessage
                end

                -- always try to send the message, even when funcOrMessage was a function
                if getmetatable( listener ) == GameObject then
                    listener:SendMessage( message, arg )
                end
            end
        end

    end -- end for listeners
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
}
-- see below in Daneel.Update()


----------------------------------------------------------------------------------
-- Cache

Daneel.Cache = {
    totable = {},
    ucfirst = {},
    lcfirst = {},

    id = 0,
    GetId = function()
        Daneel.Cache.id = Daneel.Cache.id + 1
        return Daneel.Cache.id
    end,
}


----------------------------------------------------------------------------------
-- Load

local moduleUpdateFunctions = {} -- see end of Daneel.Load() and end of Daneel.update()

-- load Daneel at the start of the game
function Daneel.Load()
    if Daneel.isLoaded then return end

    -- load modules config
    local configLoaded = {}
    for name, _module in pairs( CS.DaneelModules ) do
        if configLoaded[ _module ] == nil then
            configLoaded[ _module ] = true

            if _module.Config == nil then
                _module.Config = {}
            end
            if type( _module.DefaultConfig ) == "function" then
                _module.Config = _module.DefaultConfig()
            end

            local userConfig = {}
            local functionName = name .. "UserConfig"
            if Daneel.Utilities.GlobalExists( functionName ) then
                userConfig = _G[ functionName ]
                if type( userConfig ) == "function" then
                    userConfig = userConfig()
                end
            end
            
            _module.Config = table.deepmerge( _module.Config, userConfig )


            if _module.Config.objects ~= nil then
                Daneel.Config.objects = table.merge( Daneel.Config.objects, _module.Config.objects )
            end

            if _module.Config.componentObjects ~= nil then
                Daneel.Config.componentObjects = table.merge( Daneel.Config.componentObjects, _module.Config.componentObjects )
                Daneel.Config.componentTypes = table.getkeys( Daneel.Config.componentObjects )
                
                Daneel.Config.objects = table.merge( Daneel.Config.objects, _module.Config.componentObjects )
            end
        end
    end

    local userConfig = {}
    if Daneel.Utilities.GlobalExists( "DaneelUserConfig" ) then
        userConfig = DaneelUserConfig()
    end
    Daneel.Config = table.deepmerge( Daneel.Config, userConfig ) -- use Daneel.Config here since some of its values may have been modified already by some momdules
    
    if Daneel.Config.debug.enableDebug and Daneel.Config.debug.enableStackTrace then
        SetNewError()
    end

    Daneel.Debug.StackTrace.BeginFunction( "Daneel.Load" )

    -- Load modules 
    local moduleLoaded = {}
    for i, _module in pairs( CS.DaneelModules ) do
        if moduleLoaded[ _module ] == nil then
            moduleLoaded[ _module ] = true
            if type( _module.Load ) == "function" then
                _module.Load()
            end
        end
    end

    Daneel.isLoaded = true
    if Daneel.Config.debug.enableDebug then
        print( "~~~~~ Daneel loaded ~~~~~" )
    end

    -- check for module update functions
    -- do this now so that I don't have to call Daneel.Utilities.GlobalExists() every frame for every modules below in Behavior:Update()
    moduleLoaded = {}
    for i, _module in pairs( CS.DaneelModules ) do
        if moduleLoaded[ _module ] == nil then
            moduleLoaded[ _module ] = true
            if type( _module.Update ) == "function" then
                table.insert( moduleUpdateFunctions, _module.Update )
            end
        end
    end

    Daneel.Debug.StackTrace.EndFunction()
end -- end Daneel.Load()


----------------------------------------------------------------------------------
-- Runtime

function Behavior:Awake()
    Daneel.Load()
    Daneel.Debug.StackTrace.messages = {}
    Daneel.Debug.StackTrace.BeginFunction( "Daneel.Awake" )

    -- Awake modules 
    local moduleLoaded = {}
    for i, _module in pairs( CS.DaneelModules ) do
        if moduleLoaded[ _module ] == nil then
            moduleLoaded[ _module ] = true
            if type( _module.Awake ) == "function" then
                _module.Awake()
            end
        end
    end

    if Daneel.Config.debug.enableDebug then
        print("~~~~~ Daneel awake ~~~~~")
    end

    Daneel.Debug.StackTrace.EndFunction()
end 

function Behavior:Start()
    Daneel.Debug.StackTrace.BeginFunction( "Daneel.Start" )

    -- Start modules 
    local moduleLoaded = {}
    for i, _module in pairs( CS.DaneelModules ) do
        if moduleLoaded[ _module ] == nil then
            moduleLoaded[ _module ] = true
            if type( _module.Start ) == "function" then
                _module.Start()
            end
        end
    end

    if Daneel.Config.debug.enableDebug then
        print("~~~~~ Daneel started ~~~~~")
    end

    Daneel.Debug.StackTrace.EndFunction()
end 

function Behavior:Update()
    -- Time
    local currentTime = os.clock()
    Daneel.Time.realDeltaTime = currentTime - Daneel.Time.realTime
    Daneel.Time.realTime = currentTime

    Daneel.Time.deltaTime = Daneel.Time.realDeltaTime * Daneel.Time.timeScale
    Daneel.Time.time = Daneel.Time.time + Daneel.Time.deltaTime

    Daneel.Time.frameCount = Daneel.Time.frameCount + 1

    -- HotKeys
    -- fire an event whenever a registered button is pressed
    for i, buttonName in pairs( Daneel.Config.buttonNames ) do
        local ButtonName = buttonName:ucfirst()

        if CraftStudio.Input.WasButtonJustPressed( buttonName ) then
            Daneel.Event.Fire( "On"..ButtonName.."ButtonJustPressed" )
        end

        if CraftStudio.Input.IsButtonDown( buttonName ) then
            Daneel.Event.Fire( "On"..ButtonName.."ButtonDown" )
        end

        if CraftStudio.Input.WasButtonJustReleased( buttonName ) then
            Daneel.Event.Fire( "On"..ButtonName.."ButtonJustReleased" )
        end
    end

    -- Update modules 
    for i, func in pairs( moduleUpdateFunctions ) do
        func()
    end
end
