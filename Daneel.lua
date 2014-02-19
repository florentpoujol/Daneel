-- Daneel.lua
-- Contains Daneel's core functionalities.
--
-- Last modified for v1.4.0
-- Copyright © 2013-2014 Florent POUJOL, published under the MIT license.

Daneel = {}

-- Config, loading and Runtime at the end

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
-- The placeholders are any pice of string prefixed by a semicolon.
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

--- Allow to call getters and setters as if they were variable on the instance of the provided object.
-- The instances are tables that have the provided object as metatable.
-- Optionally allow to search in a ancestry of objects.
-- @param Object (mixed) The object.
-- @param ancestors (table) [optional] A table with one or several objects the Object "inherits" from.
function Daneel.Utilities.AllowDynamicGettersAndSetters( Object, ancestors )
    function Object.__index( instance, key )
        local ucKey = key
        if type( key ) == "string" then
            ucKey = string.ucfirst( key )
        end

        if key == ucKey then 
            -- first letter was already uppercase or key is not if type string
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
            local funcName = "Get"..ucKey

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

    function Object.__newindex( instance, key, value )
        local ucKey = key
        if type( key ) == "string" then
            ucKey = string.ucfirst( key )
        end

        if key ~= ucKey then -- first letter lowercase
            local funcName = "Set"..ucKey
            if Object[ funcName ] ~= nil then
                return Object[ funcName ]( instance, value )
            end
        end
        -- first letter was already uppercase or key not of type string
        return rawset( instance, key, value )
    end
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
        local pattern = "(%d+)"
        if data:find( ".", 1, true ) then
            pattern = "(%d+%.%d+)"
        end
        number = data:match( (data:gsub( pattern, "(%1)" )) )
        number = tonumber( number )
    end
    Daneel.Debug.StackTrace.EndFunction()
    return number
end

local buttonExists = {} -- Button names are in key, existance (false or true) is in value

--- Tell whether the provided button name exists amongst the Game Controls, or not.
-- If the button name does not exists, it will print an error in the Runtime Report but it won't kill the script that called the function.
-- CS.Input.ButtonExists is an alias of Daneel.Utilities.ButtonExists.
-- @param buttonName (string) The button name.
-- @return (boolean) True if the button name exists, false otherwise.
function Daneel.Utilities.ButtonExists( buttonName )
    Daneel.Debug.StackTrace.BeginFunction( "Daneel.Utilities.ButtonExists", buttonName )
    local errorHead = "Daneel.Utilities.ButtonExists( buttonName ) : "
    Daneel.Debug.CheckArgType( buttonName, "buttonName", "string", errorHead )

    if buttonExists[ buttonName ] == nil then
        buttonExists[ buttonName ] = Daneel.Debug.Try( function()
            CS.Input.WasButtonJustPressed( buttonName )
        end )
    end

    Daneel.Debug.StackTrace.EndFunction()
    return buttonExists[ buttonName ]
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
function Daneel.Debug.CheckArgType( argument, argumentName, expectedArgumentTypes, p_errorHead )
    if type( argument ) == "table" and getmetatable( argument ) == GameObject and argument.inner == nil then
        error( p_errorHead .. "Provided argument '" .. argumentName .. "' is a destroyed game object '" .. tostring(argument) )
        -- should do that for destroyed components too
    end

    if not Daneel.Config.debug.enableDebug then 
        return Daneel.Debug.GetType( argument ) 
    end
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
    if not Daneel.Config.debug.enableDebug then return argument end
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
function Daneel.Debug.SetNewError()
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
    -- 18/10/2013 removed the stacktrace as it caused a stack overflow when printing out destroyed game objects
    if data == nil and Daneel.Config.debug.enableDebug then
        print( "WARNING : Daneel.Debug.ToRawString( data ) : Argument 'data' is nil.")
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
    return text
end

--- Returns the name as a string of the global variable (including nested tables) whose value is provided.
-- This only works if the value of the variable is a table or a function.
-- When the variable is nested in one or several tables (like GUI.Hud), it must have been set in the 'objects' table in the config.
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

--- Check if the provided argument's value is in the provided expected value(s).
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
    Daneel.Debug.StackTrace.BeginFunction("Daneel.Debug.CheckArgValue", argument, argumentName, expectedArgumentValues, p_errorHead)
    local errorHead = "Daneel.Debug.CheckArgValue(argument, argumentName, expectedArgumentValues[, p_errorHead, defaultValue]) : "
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

local DaneelScriptAsset = Behavior
Daneel.Debug.tryGameObject = nil -- The game object Daneel.Debug.Try() works with

--- Allow to test out a piece of code without killing the script if the code throws an error.
-- If the code throw an error, it will be printed in the Runtime Report but it won't kill the script that calls Daneel.Debug.Try().
-- Does not protect against exceptions thrown by CraftStudio.
-- @param _function (function or userdata) The function containing the code to try out.
-- @return (boolean) True if the code runs without errors, false otherwise.
function Daneel.Debug.Try( _function )
    Daneel.Debug.StackTrace.BeginFunction( "Daneel.Debug.Try", _function )
    local errorHead = "Daneel.Debug.Try( _function ) : "
    Daneel.Debug.CheckArgType( _function, "_function", {"function", "userdata"}, errorHead )

    local gameObject = Daneel.Debug.tryGameObject
    if gameObject == nil or gameObject.inner == nil then
        gameObject = CraftStudio.CreateGameObject( "Daneel_Debug_Try" )
        Daneel.Debug.tryGameObject = gameObject
    end

    local success = false
    gameObject:CreateScriptedBehavior( DaneelScriptAsset, {
        debugTry = true,
        testFunction = _function, 
        successCallback = function() success = true end  
    } )

    Daneel.Debug.StackTrace.EndFunction()
    return success
end

--- Overload a function to calls to debug functions before and after it is itself called.
-- Called from Daneel.Load()
-- @param name (string) The function name
-- @param argsData (table) Mostly the list of arguments. may contains the 'includeInStackTrace' key.
function Daneel.Debug.RegisterFunction( name, argsData )
    if not Daneel.Config.debug.enableDebug then return end

    local includeInStackTrace = true
    if not Daneel.Config.debug.enableStackTrace then
        includeInStackTrace = false
    elseif argsData.includeInStackTrace ~= nil then
        includeInStackTrace = argsData.includeInStackTrace
    end

    local errorHead = name.."( "
    for i, arg in ipairs( argsData ) do
        errorHead = errorHead..arg.name..", "
    end

    errorHead = errorHead:sub( 1, #errorHead-2 ) -- removes the last coma+space
    errorHead = errorHead.." ) : "
    
    --
    local originalFunction = table.getvalue( _G, name )

    if originalFunction ~= nil then
        local newFunction = function( ... )
            local funcArgs = { ... }

            if includeInStackTrace then
                Daneel.Debug.StackTrace.BeginFunction( name, ... )
            end

            for i, arg in ipairs( argsData ) do
                if arg.type == nil and arg.defaultValue ~= nil then
                    arg.type = type( arg.defaultValue )
                end

                if arg.type ~= nil then
                    if arg.defaultValue ~= nil or arg.isOptional == true then
                        funcArgs[ i ] = Daneel.Debug.CheckOptionalArgType( funcArgs[ i ], arg.name, arg.type, errorHead, arg.defaultValue )
                    else
                        Daneel.Debug.CheckArgType( funcArgs[ i ], arg.name, arg.type, errorHead )
                    end

                elseif funcArgs[ i ] == nil then
                    error( errorHead.."Argument '"..arg.name.."' is nil." )
                end
            end

            local returnValues = { originalFunction( unpack( funcArgs ) ) } -- use unpack here to take into account the values that may have been modified by CheckOptionalArgType()

            if includeInStackTrace then
                Daneel.Debug.StackTrace.EndFunction()
            end

            return unpack( returnValues )
        end

        table.setvalue( _G, name, newFunction )
    else
        print( "Daneel.Debug.RegisterFunction() : Function with name '"..name.."' was not found in the global table _G." )
    end
end


----------------------------------------------------------------------------------
-- StackTrace

Daneel.Debug.StackTrace = { messages = {} }

--- Register a function call in the stack trace.
-- @param functionName (string) The function name.
-- @param ... [optional] (mixed) Arguments received by the function.
function Daneel.Debug.StackTrace.BeginFunction( functionName, ... )
    if 
        not Daneel.Config.debug.enableDebug or 
        not Daneel.Config.debug.enableStackTrace
    then 
        return 
    end

    if #Daneel.Debug.StackTrace.messages > 200 then 
        print( "WARNING : your StackTrace is more than 200 items long ! Emptying the StackTrace now. Did you forget to write a 'EndFunction()' somewhere ?" )
        Daneel.Debug.StackTrace.messages = {}
    end

    local errorHead = "Daneel.Debug.StackTrace.BeginFunction( functionName[, ...] ) : "
    Daneel.Debug.CheckArgType( functionName, "functionName", "string", errorHead )

    local msg = functionName .. "( "
    local arg = {...}

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
    if 
        not Daneel.Config.debug.enableDebug or 
        not Daneel.Config.debug.enableStackTrace
    then 
        return 
    end
    -- since 16/05/2013 no arguments is needed anymore, since the StackTrace only keeps open functions calls and never keep returned values
    -- I didn't rewrote all the calls to EndFunction() 
    table.remove( Daneel.Debug.StackTrace.messages )
end

--- Prints the StackTrace.
function Daneel.Debug.StackTrace.Print()
    if 
        not Daneel.Config.debug.enableDebug or 
        not Daneel.Config.debug.enableStackTrace
    then 
        return 
    end

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
    events = {}, -- emptied when a new scene is loaded in CraftStudio.LoadScene()
    persistentEvents = {}, -- not emptied
}

local EventNamesTestedForHotKeys = {} -- Event names are keys, value is true.

--- Make the provided function or object listen to the provided event(s).
-- The function will be called whenever the provided event will be fired.
-- @param eventName (string or table) The event name (or names in a table).
-- @param functionOrObject (function or table) The function (not the function name) or the object.
-- @param isPersistent (boolean) [default=false] Tell whether the listener automatically stops to listen to any event when a new scene is loaded. Always false when the listener is a game object or a component.
function Daneel.Event.Listen( eventName, functionOrObject, isPersistent )
    Daneel.Debug.StackTrace.BeginFunction( "Daneel.Event.Listen", eventName, functionOrObject )
    local errorHead = "Daneel.Event.Listen( eventName, functionOrObject ) : "
    Daneel.Debug.CheckArgType( eventName, "eventName", {"string", "table"}, errorHead )
    local listenerType = Daneel.Debug.CheckArgType( functionOrObject, "functionOrObject", {"table", "function", "userdata"}, errorHead )
    isPersistent = Daneel.Debug.CheckOptionalArgType( isPersistent, "isPersistent", "boolean", errorHead, false )
    
    local eventNames = eventName
    if type( eventName ) == "string" then
        eventNames = { eventName }
    end
    for i, eventName in pairs( eventNames ) do
        if Daneel.Event.events[ eventName ] == nil then
            Daneel.Event.events[ eventName ] = {}
        end
        if Daneel.Event.persistentEvents[ eventName ] == nil then
            Daneel.Event.persistentEvents[ eventName ] = {}
        end

        if 
            not table.containsvalue( Daneel.Event.events[ eventName ], functionOrObject ) and 
            not table.containsvalue( Daneel.Event.persistentEvents[ eventName ], functionOrObject ) 
        then
            -- check for hotkeys (button names in the event name)
            if not EventNamesTestedForHotKeys[ eventName ] then
                EventNamesTestedForHotKeys[ eventName ] = true

                local a,a, buttonName = eventName:find( "^On(.+)ButtonJustPressed$" )
                if buttonName == nil then
                    a,a, buttonName = eventName:find( "^On(.+)ButtonJustReleased$" )
                end
                if buttonName == nil then
                    a,a, buttonName = eventName:find( "^On(.+)ButtonDown$" )
                end

                if buttonName ~= nil then
                    if not Daneel.isLoaded then
                        Daneel.LateLoad( "Daneel.Event.Listen" )
                        -- need to load here because hotkeys events are not fired if Daneel isn't loaded
                    end

                    if Daneel.Utilities.ButtonExists( buttonName ) then
                        table.insert( Daneel.Config.hotKeys, buttonName )
                    elseif Daneel.Config.debug.enableDebug then
                        print( errorHead .. "You tried to listen to the '" .. eventName .. "' event but the '" .. buttonName .. "' button does not exists in the Game Controls." )
                    end
                end
            end

            -- check that the persisten listener is not a game object or a component (that are always destroyed when the scene loads)
            if isPersistent and listenerType == "table" then
                local mt = getmetatable( functionOrObject )
                if mt ~= nil and (mt == GameObject or table.containsvalue( Daneel.Config.componentObjects, mt )) then
                    if Daneel.Config.debug.enableDebug then
                        print( errorHead.."Game objects and components can't be persistent listeners", functionOrObject )
                    end
                    isPersistent = false
                end
            end

            local eventList = Daneel.Event.events
            if isPersistent then
                eventList = Daneel.Event.persistentEvents
            end

            table.insert( eventList[ eventName ], functionOrObject )
        end
    end
    Daneel.Debug.StackTrace.EndFunction()
end

--- Make the provided function or object to stop listen to the provided event(s).
-- @param eventName (string or table) [optional] The event name or names in a table or nil to stop listen to every events.
-- @param functionOrObject (function, string or GameObject) The function, or the game object name or instance.
function Daneel.Event.StopListen( eventName, functionOrObject )
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
        eventNames = table.merge( table.getkeys( Daneel.Event.events ), table.getkeys( Daneel.Event.persistentEvents ) )
    end

    for i, eventName in pairs( eventNames ) do
        local listeners = Daneel.Event.events[ eventName ]
        if listeners ~= nil then
            table.removevalue( listeners, functionOrObject )
        end
        listeners = Daneel.Event.persistentEvents[ eventName ]
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
function Daneel.Event.Fire( object, eventName, ... )
    local arg = {...}
    Daneel.Debug.StackTrace.BeginFunction( "Daneel.Event.Fire", object, eventName, ... )
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
    if object == nil then
        if Daneel.Event.events[ eventName ] ~= nil then
            listeners = Daneel.Event.events[ eventName ]
        end
        if Daneel.Event.persistentEvents[ eventName ] ~= nil then
            listeners = table.merge( listeners, Daneel.Event.persistentEvents[ eventName ] )
        end
    end

    local listenersToBeRemoved = {}
    for i, listener in ipairs( listeners ) do
        
        local listenerType = type( listener )
        if listenerType == "function" or listenerType == "userdata" then
            if listener( unpack( arg ) ) == false then
                table.insert( listenersToBeRemoved, listener )
            end

        else -- an object
            local mt = getmetatable( listener )
            if listener.isDestroyed ~= true or (mt == GameObject and listener.inner ~= nil)  then -- ensure that the event is not fired on a dead game object or component
                local message = eventName

                -- look for the value of the EventName property on the object
                local funcOrMessage = rawget( listener, eventName )
                -- Using rawget() prevent a 'Behavior function' to be called as a regular function when the listener is a ScriptedBehavior
                -- because the function exists on the Script object and not on the ScriptedBehavior (the listener),
                -- in which case rawget() returns nil

                local _type = type( funcOrMessage )
                if _type == "function" or _type == "userdata" then
                    if funcOrMessage( unpack( arg ) ) == false then
                        table.insert( listenersToBeRemoved, listener )
                    end
                elseif _type == "string" then
                    message = funcOrMessage
                end

                -- always try to send the message, even when funcOrMessage was a function
                if mt == GameObject then
                    listener:SendMessage( message, arg )
                end
            end
        end

    end -- end for listeners

    if #listenersToBeRemoved > 0 then
        for i, listener in pairs( listenersToBeRemoved ) do
            Daneel.Event.StopListen( eventName, listener )
        end
    end
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

----------------------------------------------------------------------------------
-- Cache

Daneel.Cache = {
    ucfirst = {},
    lcfirst = {},
    id = 0,
}

--- Returns an interger greater than 0 and incremented by 1 from the last time the funciton was called.
-- If an object is provided, returns the object's id (if no id is found, it is set).
-- @param object (table) [optional] An object. 
-- @return (number) The id.
function Daneel.Cache.GetId( object )
    if object ~= nil and type( object ) == "table" then
        local id = rawget( object, "id" )
        if id ~= nil then
            return id
        end
        id = Daneel.Cache.GetId()
        if object.inner ~= nil and not CS.IsWebPlayer then -- in the webplayer, tostring(object.inner) will just be table, so id will be nil
            -- object.inner : 
            -- "CraftStudioRuntime.InGame.GameObject: 4620049" (of type userdata)
            -- "CraftStudioCommon.ProjectData.[AssetType]: [some ID]"
            id = tonumber( tostring( object.inner ):match( "%d+" ) )
        end
        if id == nil then
            id = "[no id]"
        end
        rawset( object, "id", id )
        return id
    else
        Daneel.Cache.id = Daneel.Cache.id + 1
        return Daneel.Cache.id
    end
end


----------------------------------------------------------------------------------
-- Storage

Daneel.Storage = {}

-- Store locally on the computer the provided data under the provided name.
-- @param name (string) The name of the data.
-- @param data (mixed) The data to store. May be nil.
-- @param callback (function) [optional] The function called when the save has completed. The potential error (as a string) is passed to the callback first and only argument (nil if no error).
function Daneel.Storage.Save( name, data, callback )
    Daneel.Debug.StackTrace.BeginFunction( "Daneel.Storage.Save", name, data )
    local errorHead = "Daneel.Storage.Save( name, data ) : "
    Daneel.Debug.CheckArgType( name, "name", "string", errorHead )
    Daneel.Debug.CheckOptionalArgType( callback, "callback", "function", errorHead )

    if data ~= nil and type( data ) ~= "table" then
        data = { 
            value = data,
            isSavedByDaneel = true
        }
    end

    CS.Storage.Save( name, data, function( error )
        if error ~= nil then
            if Daneel.Config.debug.enableDebug then
                print( errorHead .. "Error saving with name, data and error : ", name, data, error.message )
            end
        end

        if callback ~= nil then
            if error == nil then
                error = {}
            end
            callback( error.message )
        end
    end )

    Daneel.Debug.StackTrace.EndFunction()
end

-- Load data stored locally on the computer under the provided name. The load operation may not be instantaneous.
-- The function will return the queried value (or defaultValue) if it completes right away, otherwise it returns nil.
-- @param name (string) The name of the data.
-- @param defaultValue (mixed) The value that is returned if no data is found.
-- @param callback (function) [optional] The function called when the data is loaded. The value and the potential error (as a string) (ni if no error) are passed as first and second argument, respectively.
-- @return (mixed) The data.
function Daneel.Storage.Load( name, defaultValue, callback )
    Daneel.Debug.StackTrace.BeginFunction( "Daneel.Storage.Load", name, defaultValue )
    local errorHead = "Daneel.Storage.Load( name, defaultValue ) : "
    Daneel.Debug.CheckArgType( name, "name", "string", errorHead )
    if callback == nil and type( defaultValue ) == "function" then
        callback = defaultValue
        defaultValue = nil
    end
    Daneel.Debug.CheckOptionalArgType( callback, "callback", "function", errorHead )

    local value = nil

    CS.Storage.Load( name, function( error, data )
        if error ~= nil then
            if Daneel.Config.debug.enableDebug then
                print( errorHead .. "Error loading with name, default value and error", name, defaultValue, error.message )
            end
            data = nil
        end
        
        value = defaultValue

        if data ~= nil then
            if data.value ~= nil and data.isSavedByDaneel then
                value = data.value
            else
                value = data
            end
        end

        if callback ~= nil then
            if error == nil then
                error = {}
            end
            callback( value, error.message )
        end
    end )
    
    Daneel.Debug.StackTrace.EndFunction()
    return value
end


----------------------------------------------------------------------------------
-- CRAFTSTUDIO
----------------------------------------------------------------------------------

setmetatable( Vector3, { __call = function(Object, ...) return Object:New(...) end } )
setmetatable( Quaternion, { __call = function(Object, ...) return Object:New(...) end } )
setmetatable( Plane, { __call = function(Object, ...) return Object:New(...) end } )


----------------------------------------------------------------------------------
-- Assets

Asset = {}
Asset.__index = Asset
setmetatable( Asset, { __call = function(Object, ...) return Object.Get(...) end } )

local assetPathTypes =  { "string" }
--- Alias of CraftStudio.FindAsset( assetPath[, assetType] ).
-- Get the asset of the specified name and type.
-- The first argument may be an asset object, so that you can check if a variable was an asset object or name (and get the corresponding object).
-- @param assetPath (string or one of the asset type) The fully-qualified asset name or asset object.
-- @param assetType [optional] (string) The asset type as a case-insensitive string.
-- @param errorIfAssetNotFound [optional default=false] Throw an error if the asset was not found (instead of returning nil).
-- @return (One of the asset type) The asset, or nil if none is found.
function Asset.Get( assetPath, assetType, errorIfAssetNotFound )
    Daneel.Debug.StackTrace.BeginFunction( "Asset.Get", assetPath, assetType, errorIfAssetNotFound )
    local errorHead = "Asset.Get( assetPath[, assetType, errorIfAssetNotFound] ) : "

    if assetPath == nil then
        if Daneel.Config.debug.enableDebug then
            error( errorHead.."Argument 'assetPath' is nil." )
        end
        Daneel.Debug.StackTrace.EndFunction()
        return nil
    end

    if #assetPathTypes == 1 then
        assetPathTypes = table.merge( assetPathTypes, Daneel.Config.assetTypes )
        -- the assetPath can be an asset or the asset path (string)
        -- this is done here because there is no garantee that Daneel.Config.assetTypes will already exist in the global scope
    end
    local argType = Daneel.Debug.CheckArgType( assetPath, "assetPath", assetPathTypes, errorHead )
    
    if assetType ~= nil then
        Daneel.Debug.CheckArgType( assetType, "assetType", "string", errorHead )
        assetType = Daneel.Debug.CheckArgValue( assetType, "assetType", Daneel.Config.assetTypes, errorHead )
    end

    -- just return the asset if assetPath is already an object
    if table.containsvalue( Daneel.Config.assetTypes, argType ) then
        if assetType ~= nil and argType ~= assetType then 
            error( errorHead.."Provided asset '"..assetPath.."' has a different type '"..argType.."' than the provided 'assetType' argument '"..assetType.."'." )
        end
        Daneel.Debug.StackTrace.EndFunction()
        return assetPath
    end
    -- else assetPath is always an actual asset path as a string
    
    Daneel.Debug.CheckOptionalArgType( errorIfAssetNotFound, "errorIfAssetNotFound", "boolean", errorHead )

    -- check if assetPath is a script alias
    local scriptAlias = assetPath
    if Daneel.Config.scriptPaths[ scriptAlias ] ~= nil then 
        assetPath = Daneel.Config.scriptPaths[ scriptAlias ]
        assetType = "Script"
    end

    -- get asset
    local asset = nil
    if assetType == nil then
        asset = CraftStudio.FindAsset( assetPath )
    else
        asset = CraftStudio.FindAsset( assetPath, assetType )
    end

    if asset == nil and errorIfAssetNotFound then
        if assetType == nil then
            assetType = "asset"
        end
        error( errorHead .. "Argument 'assetPath' : " .. assetType .. " with name '" .. assetPath .. "' was not found." )
    end

    Daneel.Debug.StackTrace.EndFunction()
    return asset
end

--- Returns the path of the provided asset.
-- @param asset (One of the asset types) The asset instance.
-- @return (string) The fully-qualified asset path.
function Asset.GetPath( asset )
    Daneel.Debug.StackTrace.BeginFunction( "Asset.GetPath", asset )
    local errorHead = "Asset.GetPath( asset ) : "
    Daneel.Debug.CheckArgType( asset, "asset", Daneel.Config.assetTypes, errorHead )
    local path = Map.GetPathInPackage( asset )
    Daneel.Debug.StackTrace.EndFunction()
    return path
end

--- Returns the name of the provided asset.
-- @param asset (One of the asset types) The asset instance.
-- @return (string) The name (the last segment of the fully-qualified path).
function Asset.GetName( asset )
    Daneel.Debug.StackTrace.BeginFunction( "Asset.GetName", asset )
    local errorHead = "Asset.GetName( asset ) : "
    Daneel.Debug.CheckArgType( asset, "asset", Daneel.Config.assetTypes, errorHead )
    local name = Asset.GetPath( asset ):gsub( "^(.*/)", "" ) 
    rawset( asset, "name", name )
    Daneel.Debug.StackTrace.EndFunction()
    return name
end

--- Returns the asset's internal unique identifier.
-- @param asset (any asset type) The asset.
-- @return (number) The id.
function Asset.GetId( asset )
    return Daneel.Cache.GetId( asset )
end

-- fix for Map.GetPathInPackage() that returns an error when the asset was dynamically loaded
local OriginalMapGetPathInPackage = Map.GetPathInPackage

function Map.GetPathInPackage( asset )
    local path = rawget( asset, "path" )
    if path == nil then
        path = OriginalMapGetPathInPackage( asset )
    end
    return path
end

local OriginalMapLoadFromPackage = Map.LoadFromPackage

function Map.LoadFromPackage( path, callback )
    OriginalMapLoadFromPackage( path, function( map )
        if map ~= nil then
            rawset( map, "path", path )
        end
        callback( map )
    end )
end


----------------------------------------------------------------------------------
-- Components

Component = {}
Component.__index = Component

--- Apply the content of the params argument to the provided component.
-- @param component (any component's type) The component.
-- @param params (table) A table of parameters to set the component with.
function Component.Set(component, params)
    Daneel.Debug.StackTrace.BeginFunction("Component.Set", component, params)
    local errorHead = "Component.Set(component, params) : "
    Daneel.Debug.CheckArgType(component, "component", Daneel.Config.componentTypes, errorHead)
    Daneel.Debug.CheckArgType(params, "params", "table", errorHead)

    for key, value in pairs(params) do
        component[key] = value
    end
    Daneel.Debug.StackTrace.EndFunction()
end

--- Destroy the provided component, removing it from the game object.
-- Note that the component is removed only at the end of the current frame.
-- @param component (any component type) The component.
function Component.Destroy( component )
    Daneel.Debug.StackTrace.BeginFunction( "Component.Destroy", component )
    local errorHead = "Component.Destroy( component ) : "
    Daneel.Debug.CheckArgType( component, "component", Daneel.Config.componentTypes, errorHead )

    table.removevalue( component.gameObject, component )    
    CraftStudio.Destroy( component )
    Daneel.Debug.StackTrace.EndFunction()
end

--- Returns the component's internal unique identifier.
-- @param component (any component type) The component.
-- @return (number) The id.
function Component.GetId( component )
    -- no Debug because is used in __tostring
    return Daneel.Cache.GetId( component )
end


----------------------------------------------------------------------------------
-- Transform

local OriginalSetLocalScale = Transform.SetLocalScale

--- Set the transform's local scale.
-- @param transform (Transform) The transform component.
-- @param scale (number or Vector3) The global scale.
function Transform.SetLocalScale(transform, scale)
    Daneel.Debug.StackTrace.BeginFunction("Transform.SetLocalScale", transform, scale)
    local errorHead = "Transform.SetLocalScale(transform, scale) : "
    Daneel.Debug.CheckArgType(transform, "transform", "Transform", errorHead)
    local argType = Daneel.Debug.CheckArgType(scale, "scale", {"number", "Vector3"}, errorHead)

    if argType == "number" then
        scale = Vector3:New(scale)
    end
    OriginalSetLocalScale(transform, scale)
    Daneel.Debug.StackTrace.EndFunction()
end

--- Set the transform's global scale.
-- @param transform (Transform) The transform component.
-- @param scale (number or Vector3) The global scale.
function Transform.SetScale(transform, scale)
    Daneel.Debug.StackTrace.BeginFunction("Transform.SetScale", transform, scale)
    local errorHead = "Transform.SetScale(transform, scale) : "
    Daneel.Debug.CheckArgType(transform, "transform", "Transform", errorHead)
    local argType = Daneel.Debug.CheckArgType(scale, "scale", {"number", "Vector3"}, errorHead)

    if argType == "number" then
        scale = Vector3:New(scale)
    end

    local parent = transform.gameObject:GetParent()
    if parent ~= nil then
        scale = scale / parent.transform:GetScale()
    end
    transform:SetLocalScale( scale )
    Daneel.Debug.StackTrace.EndFunction()
end

--- Get the transform's global scale.
-- @param transform (Transform) The transform component.
-- @return (Vector3) The global scale.
function Transform.GetScale(transform)
    Daneel.Debug.StackTrace.BeginFunction("Transform.GetScale", transform)
    local errorHead = "Transform.GetScale(transform) : "
    Daneel.Debug.CheckArgType(transform, "transform", "Transform", errorHead)

    local scale = transform:GetLocalScale()
    local parent = transform.gameObject:GetParent()
    if parent ~= nil then
        scale = scale * parent.transform:GetScale()
    end
    Daneel.Debug.StackTrace.EndFunction()
    return scale
end


----------------------------------------------------------------------------------
-- ModelRenderer

local OriginalSetModel = ModelRenderer.SetModel

--- Attach the provided model to the provided modelRenderer.
-- @param modelRenderer (ModelRenderer) The modelRenderer.
-- @param modelNameOrAsset (string or Model) [optional] The model name or asset, or nil.
function ModelRenderer.SetModel( modelRenderer, modelNameOrAsset )
    Daneel.Debug.StackTrace.BeginFunction( "ModelRenderer.SetModel", modelRenderer, modelNameOrAsset )
    local errorHead = "ModelRenderer.SetModel( modelRenderer[, modelNameOrAsset] ) : "
    Daneel.Debug.CheckArgType( modelRenderer, "modelRenderer", "ModelRenderer", errorHead )
    Daneel.Debug.CheckOptionalArgType( modelNameOrAsset, "modelNameOrAsset", {"string", "Model"}, errorHead )

    local model = nil
    if modelNameOrAsset ~= nil then
        model = Asset.Get( modelNameOrAsset, "Model", true )
    end
    OriginalSetModel( modelRenderer, model )
    Daneel.Debug.StackTrace.EndFunction()
end

local OriginalSetAnimation = ModelRenderer.SetAnimation

--- Set the specified animation for the modelRenderer's current model.
-- @param modelRenderer (ModelRenderer) The modelRenderer.
-- @param animationNameOrAsset (string or ModelAnimation) [optional] The animation name or asset, or nil.
function ModelRenderer.SetAnimation( modelRenderer, animationNameOrAsset )
    Daneel.Debug.StackTrace.BeginFunction( "ModelRenderer.SetAnimation", modelRenderer, animationNameOrAsset )
    local errorHead = "ModelRenderer.SetAnimation( modelRenderer[, animationNameOrAsset] ) : "
    Daneel.Debug.CheckArgType( modelRenderer, "modelRenderer", "ModelRenderer", errorHead )
    Daneel.Debug.CheckOptionalArgType( animationNameOrAsset, "animationNameOrAsset", {"string", "ModelAnimation"}, errorHead )

    local animation = nil 
    if animationNameOrAsset ~= nil then
        animation = Asset.Get( animationNameOrAsset, "ModelAnimation", true )
    end
    OriginalSetAnimation( modelRenderer, animation )
    Daneel.Debug.StackTrace.EndFunction()
end

--- Apply the content of the params argument to the provided model renderer.
-- @param modelRenderer (ModelRenderer) The model renderer.
-- @param params (table) A table of parameters to set the component with.
function ModelRenderer.Set( modelRenderer, params )
    Daneel.Debug.StackTrace.BeginFunction( "ModelRenderer.Set", modelRenderer, params )
    local errorHead = "ModelRenderer.Set( modelRenderer, params ) : "
    Daneel.Debug.CheckArgType( modelRenderer, "modelRenderer", "ModelRenderer", errorHead )
    Daneel.Debug.CheckArgType( params, "params", "table", errorHead )

    if params.model ~= nil then
        modelRenderer:SetModel( params.model )
        params.model = nil
    end

    if params.animationTime ~= nil and params.animation ~= nil then
        modelRenderer:SetAnimation( params.animation )
        params.animation = nil
    end

    Component.Set( modelRenderer, params )
    Daneel.Debug.StackTrace.EndFunction()
end


----------------------------------------------------------------------------------
-- MapRenderer

local OriginalSetMap = MapRenderer.SetMap

--- Attach the provided map to the provided map renderer.
-- @param mapRenderer (MapRenderer) The map renderer.
-- @param mapNameOrAsset (string or Map) [optional] The map name or asset, or nil.
-- @param replaceTileSet (boolean) [optional default=true] Replace the current TileSet by the one set for the provided map in the map editor. 
function MapRenderer.SetMap( mapRenderer, mapNameOrAsset, replaceTileSet )
    Daneel.Debug.StackTrace.BeginFunction( "MapRenderer.SetMap", mapRenderer, mapNameOrAsset, replaceTileSet )
    local errorHead = "MapRenderer.SetMap( mapRenderer[, mapNameOrAsset, replaceTileSet] ) : "
    Daneel.Debug.CheckArgType( mapRenderer, "mapRenderer", "MapRenderer", errorHead )
    Daneel.Debug.CheckOptionalArgType( mapNameOrAsset, "mapNameOrAsset", {"string", "Map"}, errorHead )
    Daneel.Debug.CheckOptionalArgType( replaceTileSet, "replaceTileSet", "boolean", errorHead )

    local map = nil
    if mapNameOrAsset ~= nil then
        map = Asset.Get( mapNameOrAsset, "Map", true )
    end

    if replaceTileSet ~= nil then
        OriginalSetMap(mapRenderer, map, replaceTileSet)
    else
        OriginalSetMap(mapRenderer, map)
    end
    Daneel.Debug.StackTrace.EndFunction()
end

local OriginalSetTileSet = MapRenderer.SetTileSet

--- Set the specified tileSet for the mapRenderer's map.
-- @param mapRenderer (MapRenderer) The mapRenderer.
-- @param tileSetNameOrAsset (string or TileSet) [optional] The tileSet name or asset, or nil.
function MapRenderer.SetTileSet( mapRenderer, tileSetNameOrAsset )
    Daneel.Debug.StackTrace.BeginFunction("MapRenderer.SetTileSet", mapRenderer, tileSetNameOrAsset )
    local errorHead = "MapRenderer.SetTileSet( mapRenderer[, tileSetNameOrAsset] ) : "
    Daneel.Debug.CheckArgType( mapRenderer, "mapRenderer", "MapRenderer", errorHead )
    Daneel.Debug.CheckOptionalArgType( tileSetNameOrAsset, "tileSetNameOrAsset", {"string", "TileSet"}, errorHead )

    local tileSet = nil
    if tileSetNameOrAsset ~= nil then
        tileSet = Asset.Get( tileSetNameOrAsset, "TileSet", true )
    end
    OriginalSetTileSet( mapRenderer, tileSet )
    Daneel.Debug.StackTrace.EndFunction()
end

--- Apply the content of the params argument to the provided map renderer.
-- @param mapRenderer (MapRenderer) The map renderer.
-- @param params (table) A table of parameters to set the component with.
function MapRenderer.Set( mapRenderer, params )
    Daneel.Debug.StackTrace.BeginFunction( "MapRenderer.Set", mapRenderer, params )
    local errorHead = "MapRenderer.Set( mapRenderer, params ) : "
    Daneel.Debug.CheckArgType( mapRenderer, "mapRenderer", "MapRenderer", errorHead )
    Daneel.Debug.CheckArgType( params, "params", "table", errorHead )

    if params.map ~= nil then
        mapRenderer:SetMap( params.map )
        -- set the map here in case of the tileSet property is set too
        params.map = nil
    end

    Component.Set( mapRenderer, params )
    Daneel.Debug.StackTrace.EndFunction()
end


----------------------------------------------------------------------------------
-- TextRenderer

local OriginalSetFont = TextRenderer.SetFont

--- Set the provided font to the provided text renderer.
-- @param textRenderer (TextRenderer) The text renderer.
-- @param fontNameOrAsset (string or Font) [optional] The font name or asset, or nil.
function TextRenderer.SetFont( textRenderer, fontNameOrAsset )
    Daneel.Debug.StackTrace.BeginFunction( "TextRenderer.SetFont", textRenderer, fontNameOrAsset )
    local errorHead = "TextRenderer.SetFont( textRenderer[, fontNameOrAsset] ) : "
    Daneel.Debug.CheckArgType( textRenderer, "textRenderer", "TextRenderer", errorHead )
    Daneel.Debug.CheckOptionalArgType( fontNameOrAsset, "fontNameOrAsset", {"string", "Font"}, errorHead )

    local font = nil
    if fontNameOrAsset ~= nil then
        font = Asset.Get( fontNameOrAsset, "Font", true )
    end
    OriginalSetFont( textRenderer, font )
    Daneel.Debug.StackTrace.EndFunction()
end

local OriginalSetAlignment = TextRenderer.SetAlignment

--- Set the text's alignment.
-- @param textRenderer (TextRenderer) The textRenderer.
-- @param alignment (string or TextRenderer.Alignment) The alignment. Values (case-insensitive when of type string) may be "left", "center", "right", TextRenderer.Alignment.Left, TextRenderer.Alignment.Center or TextRenderer.Alignment.Right.
function TextRenderer.SetAlignment(textRenderer, alignment)
    Daneel.Debug.StackTrace.BeginFunction("TextRenderer.SetAlignment", textRenderer, alignment)
    local errorHead = "TextRenderer.SetAlignment(textRenderer, alignment) : "
    Daneel.Debug.CheckArgType(textRenderer, "textRenderer", "TextRenderer", errorHead)
    local argType = Daneel.Debug.CheckArgType(alignment, "alignment", {"string", "userdata", "number"}, errorHead) -- number because enum returns a number in the webplayer

    if argType == "string" then
        local default = "Center"
        if Daneel.Config.textRenderer ~= nil and Daneel.Config.textRenderer.alignment ~= nil then
            default = Daneel.Config.textRenderer.alignment
        end
        alignment = Daneel.Debug.CheckArgValue( alignment, "alignment", {"Left", "Center", "Right"}, errorHead, default )
        alignment = TextRenderer.Alignment[ alignment ]
    end
    OriginalSetAlignment( textRenderer, alignment )
    Daneel.Debug.StackTrace.EndFunction()
end

--- Update the game object's scale to make the text appear the provided width.
-- @param textRenderer (TextRenderer) The textRenderer.
-- @param width (number) The text's width in scene units.
function TextRenderer.SetTextWidth( textRenderer, width )
    Daneel.Debug.StackTrace.BeginFunction("TextRenderer.SetTextWidth", textRenderer, width)
    local errorHead = "TextRenderer.SetTextWidth(textRenderer, width) : "
    Daneel.Debug.CheckArgType(textRenderer, "textRenderer", "TextRenderer", errorHead)
    local argType = Daneel.Debug.CheckArgType(width, "width", "number", errorHead)

    local widthScaleRatio = textRenderer:GetTextWidth() / textRenderer.gameObject.transform:GetScale()
    textRenderer.gameObject.transform:SetScale( width / widthScaleRatio )
    Daneel.Debug.StackTrace.EndFunction()
end


----------------------------------------------------------------------------------
-- Camera

local OriginalSetProjectionMode = Camera.SetProjectionMode

--- Sets the camera projection mode.
-- @param camera (Camera) The camera.
-- @param projectionMode (string or Camera.ProjectionMode) The projection mode. Possible values are "perspective", "orthographic" (as a case-insensitive string), Camera.ProjectionMode.Perspective or Camera.ProjectionMode.Orthographic.
function Camera.SetProjectionMode( camera, projectionMode )
    Daneel.Debug.StackTrace.BeginFunction( "Camera.SetProjectionMode", camera, projectionMode )
    local errorHead = "Camera.SetProjectionMode( camera, projectionMode ) : "
    Daneel.Debug.CheckArgType( camera, "camera", "Camera", errorHead)
    local argType = Daneel.Debug.CheckArgType( projectionMode, "projectionMode", {"string", "userdata", "number"}, errorHead )

    if argType == "string" then
        local default = "Perspective"
        if Daneel.Config.camera ~= nil and Daneel.Config.camera.projectionMode ~= nil then
            default = Daneel.Config.camera.projectionMode
        end
        projectionMode = Daneel.Debug.CheckArgValue( projectionMode, "projectionMode", {"Perspective", "Orthographic"}, errorHead, default )
        projectionMode = Camera.ProjectionMode[ projectionMode ]
    end

    OriginalSetProjectionMode( camera, projectionMode )
    Daneel.Debug.StackTrace.EndFunction()
end

--- Apply the content of the params argument to the provided camera.
-- @param camera (Camera) The camera.
-- @param params (table) A table of parameters to set the component with.
function Camera.Set( camera, params )
    Daneel.Debug.StackTrace.BeginFunction( "Camera.Set", camera, params )
    local errorHead = "Camera.Set( camera, params ) : "
    Daneel.Debug.CheckArgType( camera, "camera", "Camera", errorHead )
    Daneel.Debug.CheckArgType( params, "params", "table", errorHead )

    if params.projectionMode ~= nil then
        camera:SetProjectionMode( params.projectionMode )
        params.projectionMode = nil
    end

    Component.Set( camera, params )
    Daneel.Debug.StackTrace.EndFunction()
end


----------------------------------------------------------------------------------
-- Ray

setmetatable( Ray, { __call = function(Object, ...) return Object:New(...) end } )

--- Check the collision of the ray against the provided set of game objects.
-- @param ray (Ray) The ray.
-- @param gameObjects (table) The set of game objects to cast the ray against.
-- @param sortByDistance [optional default=false] (boolean) Sort the raycastHit by increasing distance in the returned table.
-- @return (table) A table of RaycastHits (will be empty if the ray didn't intersects anything).
function Ray.Cast( ray, gameObjects, sortByDistance )
    Daneel.Debug.StackTrace.BeginFunction( "Ray.Cast", ray, gameObjects, sortByDistance )
    local errorHead = "Ray.Cast( ray, gameObjects[, sortByDistance] ) : "
    Daneel.Debug.CheckArgType( ray, "ray", "Ray", errorHead )
    Daneel.Debug.CheckArgType( gameObjects, "gameObjects", "table", errorHead )
    Daneel.Debug.CheckOptionalArgType( sortByDistance, "sortByDistance", "boolean", errorHead )
    
    local hits = {}
    for i, gameObject in pairs( gameObjects ) do
        if gameObject.inner ~= nil then
            local raycastHit = ray:IntersectsGameObject( gameObject )
            if raycastHit ~= nil then
                table.insert( hits, raycastHit )
            end
        end
    end
    if sortByDistance == true then
        hits = table.sortby( hits, "distance" )
    end

    Daneel.Debug.StackTrace.EndFunction()
    return hits
end

--- Check if the ray intersect the specified game object.
-- @param ray (Ray) The ray.
-- @param gameObjectNameOrInstance (string or GameObject) The game object instance or name.
-- @return (RaycastHit) A raycastHit with the if there was a collision, or nil.
function Ray.IntersectsGameObject( ray, gameObjectNameOrInstance )
    Daneel.Debug.StackTrace.BeginFunction( "Ray.IntersectsGameObject", ray, gameObjectNameOrInstance )
    local errorHead = "Ray.IntersectsGameObject( ray, gameObjectNameOrInstance ) : "
    Daneel.Debug.CheckArgType( ray, "ray", "Ray", errorHead )
    Daneel.Debug.CheckArgType( gameObjectNameOrInstance, "gameObjectNameOrInstance", {"string", "GameObject"}, errorHead )
    
    local gameObject = GameObject.Get( gameObjectNameOrInstance, true )
    local raycastHit = nil

    if gameObject.inner == nil then
        -- should not happend since CheckArgType() returns an error when the game object is dead
        return nil
    end

    local component = gameObject.modelRenderer
    if component ~= nil then
        raycastHit = ray:IntersectsModelRenderer( component, true )
    end

    if raycastHit == nil then
        component = gameObject.mapRenderer
        if component ~= nil then
            raycastHit = ray:IntersectsMapRenderer( component, true )
        end
    end

    if raycastHit == nil then
        component = gameObject.textRenderer
        if component ~= nil then
            raycastHit = ray:IntersectsTextRenderer( component, true )
        end
    end

    if raycastHit ~= nil then
        raycastHit.gameObject = gameObject
    end

    Daneel.Debug.StackTrace.EndFunction()
    return raycastHit
end

local OriginalIntersectsPlane = Ray.IntersectsPlane

-- Check if the ray intersects the provided plane and returns the distance of intersection or a raycastHit.
-- @param ray (Ray) The ray.
-- @param plane (Plane) The plane.
-- @param returnRaycastHit (boolean) [optional default=false] Tell if the hit infos must be returned as a raycastHit.
-- @return (number or RaycastHit) The distance of intersection (if any) or a raycastHit with the 'distance' and 'hitLocation' properties (if any).
function Ray.IntersectsPlane( ray, plane, returnRaycastHit )
    -- 08/08/13 removed reference to plane in BeginFunction and CheckArgType
    -- because Plane.__tostring is wrong, causes 'var self is not declared'
    Daneel.Debug.StackTrace.BeginFunction( "Ray.IntersectsPlane", ray, nil, returnRaycastHit )
    local errorHead = "Ray.IntersectsPlane( ray, plane[, returnRaycastHit] ) : "
    Daneel.Debug.CheckArgType( ray, "ray", "Ray", errorHead )
    --Daneel.Debug.CheckArgType( plane, "plane", "Plane", errorHead )
    returnRaycastHit = Daneel.Debug.CheckOptionalArgType( returnRaycastHit, "returnRaycastHit", "boolean", errorHead, false )

    local distance = OriginalIntersectsPlane( ray, plane )
    if returnRaycastHit and distance ~= nil then
        local raycastHit = RaycastHit.New({
            distance = distance,
            hitLocation = ray.position + ray.direction * distance,
            hitObject = plane,
        })

        distance = raycastHit
    end

    Daneel.Debug.StackTrace.EndFunction()
    return distance
end

local OriginalIntersectsModelRenderer = Ray.IntersectsModelRenderer

-- Check if the ray intersects the provided modelRenderer.
-- @param ray (Ray) The ray.
-- @param modelRenderer (ModelRenderer) The modelRenderer.
-- @param returnRaycastHit (boolean) [optional default=false] Tell if the hit infos must be returned as a raycastHit.
-- @return (number or RaycastHit) The distance of intersection (if any) or a raycastHit with the 'distance', 'normal' and 'hitLocation' properties (if any).
-- @return (Vector3) If 'returnRaycastHit' argument is false : the normal of the hit face, or nil
function Ray.IntersectsModelRenderer( ray, modelRenderer, returnRaycastHit )
    Daneel.Debug.StackTrace.BeginFunction( "Ray.IntersectsModelRenderer", ray, modelRenderer, returnRaycastHit )
    local errorHead = "Ray.IntersectsModelRenderer( ray, modelRenderer[, returnRaycastHit] ) : "
    Daneel.Debug.CheckArgType( ray, "ray", "Ray", errorHead )
    Daneel.Debug.CheckArgType( modelRenderer, "modelRenderer", "ModelRenderer", errorHead )
    returnRaycastHit = Daneel.Debug.CheckOptionalArgType( returnRaycastHit, "returnRaycastHit", "boolean", errorHead, false )

    local distance, normal = OriginalIntersectsModelRenderer( ray, modelRenderer )
    if returnRaycastHit and distance ~= nil then
        local raycastHit = RaycastHit.New({
            distance = distance,
            normal = normal,
            hitLocation = ray.position + ray.direction * distance,
            hitObject = modelRenderer,
            gameObject = modelRenderer.gameObject,
        })

        distance = raycastHit
        normal = nil
    end

    Daneel.Debug.StackTrace.EndFunction()
    return distance, normal
end

local OriginalIntersectsMapRenderer = Ray.IntersectsMapRenderer

-- Check if the ray intersects the provided mapRenderer.
-- @param ray (Ray) The ray.
-- @param mapRenderer (MapRenderer) The mapRenderer.
-- @param returnRaycastHit (boolean) [optional default=false] Tell if the hit infos must be returned as a raycastHit.
-- @return (number or RaycastHit) The distance of intersection (if any) or a raycastHit with the 'distance', 'normal', 'hitBlockLocation', 'adjacentBlockLocation' and 'hitLocation' properties (if any).
-- @return (Vector3) If 'returnRaycastHit' argument is false : the normal of the hit face, or nil
-- @return (Vector3) If 'returnRaycastHit' argument is false : the location of the block hit, or nil
-- @return (Vector3) If 'returnRaycastHit' argument is false : the location of the adjacent block, or nil
function Ray.IntersectsMapRenderer( ray, mapRenderer, returnRaycastHit )
    Daneel.Debug.StackTrace.BeginFunction( "Ray.IntersectsMapRenderer", ray, mapRenderer, returnRaycastHit )
    local errorHead = "Ray.IntersectsMapRenderer( ray, mapRenderer[, returnRaycastHit] ) : "
    Daneel.Debug.CheckArgType( ray, "ray", "Ray", errorHead )
    Daneel.Debug.CheckArgType( mapRenderer, "mapRenderer", "MapRenderer", errorHead )
    returnRaycastHit = Daneel.Debug.CheckOptionalArgType( returnRaycastHit, "returnRaycastHit", "boolean", errorHead, false )

    local distance, normal, hitBlockLocation, adjacentBlockLocation = OriginalIntersectsMapRenderer( ray, mapRenderer )
    if hitBlockLocation ~= nil then
        setmetatable( hitBlockLocation, Vector3 )
    end
    if adjacentBlockLocation ~= nil then
        setmetatable( adjacentBlockLocation, Vector3 )
    end

    if returnRaycastHit and distance ~= nil then
        local raycastHit = RaycastHit.New({
            distance = distance,
            normal = normal,
            hitBlockLocation = hitBlockLocation,
            adjacentBlockLocation = adjacentBlockLocation,
            hitLocation = ray.position + ray.direction * distance,
            hitObject = mapRenderer,
            gameObject = mapRenderer.gameObject,
        })

        distance = raycastHit
        normal = nil
        hitBlockLocation = nil
        adjacentBlockLocation = nil
    end

    Daneel.Debug.StackTrace.EndFunction()
    return distance, normal, hitBlockLocation, adjacentBlockLocation
end

local OriginalIntersectsTextRenderer = Ray.IntersectsTextRenderer

-- Check if the ray intersects the provided textRenderer.
-- @param ray (Ray) The ray.
-- @param textRenderer (TextRenderer) The textRenderer.
-- @param returnRaycastHit (boolean) [optional default=false] Tell if the hit infos must be returned as a raycastHit.
-- @return (number or RaycastHit) The distance of intersection (if any) or a raycastHit with the 'distance', 'normal' and 'hitLocation' properties (if any).
-- @return (Vector3) If 'returnRaycastHit' argument is false : the normal of the hit face, or nil
function Ray.IntersectsTextRenderer( ray, textRenderer, returnRaycastHit )
    Daneel.Debug.StackTrace.BeginFunction( "Ray.IntersectsTextRenderer", ray, textRenderer, returnRaycastHit )
    local errorHead = "Ray.IntersectsTextRenderer( ray, textRenderer[, returnRaycastHit] ) : "
    Daneel.Debug.CheckArgType( ray, "ray", "Ray", errorHead )
    Daneel.Debug.CheckArgType( textRenderer, "textRenderer", "TextRenderer", errorHead )
    returnRaycastHit = Daneel.Debug.CheckOptionalArgType( returnRaycastHit, "returnRaycastHit", "boolean", errorHead, false )

    local distance, normal = OriginalIntersectsTextRenderer( ray, textRenderer )
    if returnRaycastHit and distance ~= nil then
        local raycastHit = RaycastHit.New({
            distance = distance,
            normal = normal,
            hitLocation = ray.position + ray.direction * distance,
            hitObject = textRenderer,
            gameObject = textRenderer.gameObject,
        })

        Daneel.Debug.StackTrace.EndFunction()
        return raycastHit
    end

    Daneel.Debug.StackTrace.EndFunction()
    return distance, normal
end


----------------------------------------------------------------------------------
-- RaycastHit

RaycastHit = {}
RaycastHit.__index = RaycastHit
setmetatable( RaycastHit, { __call = function(Object, ...) return Object.New(...) end } )

function RaycastHit.__tostring( instance )
    local msg = "RaycastHit: { "
    local first = true
    for key, value in pairs( instance ) do
        if first then
            msg = msg..key.."="..tostring( value )
            first = false
        else
            msg = msg..", "..key.."="..tostring( value )
        end
    end

    return msg.." }"
end

--- Create a new RaycastHit
-- @return (RaycastHit) The raycastHit.
function RaycastHit.New( data )
    Daneel.Debug.StackTrace.BeginFunction( "RaycastHit.New", data )
    local errorHead = "RaycastHit.New( [data] ) : "
    data = Daneel.Debug.CheckOptionalArgType( data, "data", "table", errorHead, {} )

    local raycastHit = setmetatable( data, RaycastHit )
    Daneel.Debug.StackTrace.EndFunction()
    return raycastHit
end


----------------------------------------------------------------------------------
-- Scene

--- Alias of CraftStudio.LoadScene().
-- Schedules loading the specified scene after the current tick (frame) (1/60th of a second) has completed.
-- When the new scene is loaded, all of the current scene's game objects will be removed.
-- Calling this function doesn't immediately stops the calling function. As such, you might want to add a return statement afterwards. 
-- @param sceneNameOrAsset (string or Scene) The scene name or asset.
function Scene.Load( sceneNameOrAsset )
    Daneel.Debug.StackTrace.BeginFunction( "Scene.Load", sceneNameOrAsset )
    local errorHead = "Scene.Load( sceneNameOrAsset ) : "
    Daneel.Debug.CheckArgType( sceneNameOrAsset, "sceneNameOrAsset", {"string", "Scene"}, errorHead )

    CraftStudio.LoadScene( sceneNameOrAsset )
    Daneel.Debug.StackTrace.EndFunction()
end

local OriginalLoadScene = CraftStudio.LoadScene

--- Schedules loading the specified scene after the current tick (1/60th of a second) has completed.
-- When the new scene is loaded, all of the current scene's game objects will be removed.
-- Calling this function doesn't immediately stops the calling function. As such, you might want to add a return statement afterwards. 
-- @param sceneNameOrAsset (string or Scene) The scene name or asset.
function CraftStudio.LoadScene( sceneNameOrAsset )
    Daneel.Debug.StackTrace.BeginFunction( "CraftStudio.LoadScene", sceneNameOrAsset )
    local errorHead = "CraftStudio.LoadScene( sceneNameOrAsset ) : "
    Daneel.Debug.CheckArgType( sceneNameOrAsset, "sceneNameOrAsset", {"string", "Scene"}, errorHead )

    local scene = Asset.Get( sceneNameOrAsset, "Scene", true )
    
    Daneel.Event.Fire( "OnSceneLoad", scene )
    Daneel.Event.events = {} -- do this here to make sure that any events that might be fired from OnSceneLoad-catching function are indeed fired
    Scene.current = scene

    Daneel.Debug.StackTrace.EndFunction()
    OriginalLoadScene( scene )
end

--- Alias of CraftStudio.AppendScene().
-- Appends the specified scene to the game by instantiating all of its game objects. Contrary to CraftStudio.LoadScene, this doesn't unload the current scene nor waits for the next tick: it happens right away.
-- You can optionally specify a parent game object which will be used as a root for adding all game objects. 
-- Returns the game object appended if there was only one root game object in the provided scene.
-- @param sceneNameOrAsset (string or Scene) The scene name or asset.
-- @param parentNameOrInstance [optional] (string or GameObject) The parent game object name or instance.
-- @return (GameObject) The appended game object, or nil.
function Scene.Append( sceneNameOrAsset, parentNameOrInstance )
    Daneel.Debug.StackTrace.BeginFunction( "Scene.Append", sceneNameOrAsset, parentNameOrInstance )
    local errorHead = "Scene.Append( sceneNameOrAsset[, parentNameOrInstance] ) : "
    Daneel.Debug.CheckArgType( sceneNameOrAsset, "sceneNameOrAsset", {"string", "Scene"}, errorHead )
    Daneel.Debug.CheckOptionalArgType( parentNameOrInstance, "parentNameOrInstance", {"string", "GameObject"}, errorHead )

    local scene = Asset.Get( sceneNameOrAsset, "Scene", true )
    local parent = nil
    if parentNameOrInstance ~= nil then
        parent = GameObject.Get( parentNameOrInstance, true )
    end
    local gameObject = CraftStudio.AppendScene( scene, parent )

    Daneel.Debug.StackTrace.EndFunction()
    return gameObject
end


----------------------------------------------------------------------------------

local OriginalDestroy = CraftStudio.Destroy

--- Removes the specified game object (and all of its descendants) or the specified component from its game object.
-- You can also optionally specify a dynamically loaded asset for unloading (See Map.LoadFromPackage ).
-- Sets the 'isDestroyed' property to 'true' and fires the 'OnDestroy' event on the object.
-- @param object (GameObject, a component or a dynamically loaded asset) The game object, component or a dynamically loaded asset (like a map loaded with Map.LoadFromPackage).
function CraftStudio.Destroy( object )
    Daneel.Debug.StackTrace.BeginFunction( "CraftStudio.Destroy", object )
    if type( object ) == "table" then
        Daneel.Event.Fire( object, "OnDestroy", object )
        Daneel.Event.StopListen( object ) -- remove from listener list
        object.isDestroyed = true
    end
    OriginalDestroy( object )
    Daneel.Debug.StackTrace.EndFunction()
end


----------------------------------------------------------------------------------

CS.Input.isMouseLocked = false

local OriginalLockMouse = CS.Input.LockMouse
function CS.Input.LockMouse()
    CS.Input.isMouseLocked = true
    OriginalLockMouse()
end

local OriginalUnlockMouse = CS.Input.UnlockMouse
function CS.Input.UnlockMouse()
    CS.Input.isMouseLocked = false
    OriginalUnlockMouse()
end

--- Toggle the locked state of the mouse, which can be accessed via the CS.Input.isMouseLocked property.
function CS.Input.ToggleMouseLock()
    if CS.Input.isMouseLocked then
        CS.Input.UnlockMouse()
    else
        CS.Input.LockMouse()
    end
end


----------------------------------------------------------------------------------
-- Config, loading

-- Enables the dynamic accessors on the components
-- write the __tostring function
function Daneel.SetComponents( components )    
    for componentType, componentObject in pairs( components ) do
        Daneel.Utilities.AllowDynamicGettersAndSetters( componentObject, { Component } )

        if componentType ~= "ScriptedBehavior" then
            componentObject["__tostring"] = function( component )
                return componentType .. ": " .. component:GetId()
            end
        end
    end
end


-- Config - Loading
function Daneel.DefaultConfig()
    local config = {  
        debug = {
            enableDebug = false, -- Enable/disable Daneel's global debugging features (error reporting + stacktrace).
            enableStackTrace = false, -- Enable/disable the Stack Trace.

            functionsDebugInfo = {},
        },

        allowDynamicComponentFunctionCallOnGameObject = true,
       
        ----------------------------------------------------------------------------------
        
        -- List of the Scripts paths as values and optionally the script alias as the keys.
        -- Ie :
        -- "fully-qualified Script path"
        -- or
        -- alias = "fully-qualified Script path"
        --
        -- Setting a script path here allow you to  :
        -- * Use the dynamic getters and setters
        -- * Use component:Set() (for scripted behaviors)
        -- * Use component:GetId() (for scripted behaviors)
        -- * If you defined aliases, dynamically access the scripted behavior on the game object via its alias
        scriptPaths = {},

        -- Default CraftStudio's components settings (except Transform)
        -- textRenderer = { font = "MyFont" },

        hotKeys = {}, -- button names that throws events On[ButtonName]JustPressed... 
        -- filled in Daneel.Event.Listen

        objects = {
            GameObject = GameObject,
            Vector3 = Vector3,
            Quaternion = Quaternion,
            Plane = Plane,
            Ray = Ray,
            RaycastHit = RaycastHit,
        },

        componentObjects = {
            ScriptedBehavior = ScriptedBehavior,
            ModelRenderer = ModelRenderer,
            MapRenderer = MapRenderer,
            Camera = Camera,
            Transform = Transform,
            Physics = Physics,
            TextRenderer = TextRenderer,
            NetworkSync = NetworkSync,
        },
        componentTypes = {},

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
        assetTypes = {},
    }

    return config
end

Daneel.Config = Daneel.DefaultConfig()
Daneel.SetComponents( Daneel.Config.componentObjects ) -- called here for the built-in components, is called another time after the modules and user config gets loaded

-- Assets
for assetType, assetObject in pairs( Daneel.Config.assetObjects ) do
    table.insert( Daneel.Config.assetTypes, assetType )
    Daneel.Utilities.AllowDynamicGettersAndSetters( assetObject, { Asset } )

    assetObject["__tostring"] = function( asset )
        return  assetType .. ": " .. Daneel.Cache.GetId( asset ) .. ": '" .. Map.GetPathInPackage( asset ) .. "'"
    end
end

Daneel.Config.componentTypes = table.getkeys( Daneel.Config.componentObjects ) -- put here so that table.getkeys() don't throw error because Daneel.Debug doesn't exists


-- load Daneel at the start of the game
function Daneel.Load()
    if Daneel.isLoaded then return end
    Daneel.isLoading = true

    -- load Daneel config
    if table.getvalue( _G, "DaneelUserConfig" ) ~= nil and type( DaneelUserConfig ) == "function" then 
        Daneel.Config = table.merge( Daneel.Config, DaneelUserConfig(), true ) -- use Daneel.Config here since some of its values may have been modified already by some momdules
    end

    -- load modules config
    for name, _module in pairs( CS.DaneelModules ) do
        if _module.isConfigLoaded ~= true then
            _module.isConfigLoaded = true

            if _module.Config == nil then
                _module.Config = {}
            end
            if type( _module.DefaultConfig ) == "function" then
                _module.Config = _module.DefaultConfig()
            end
            
            local userConfig = {}
            local functionName = name .. "UserConfig"
            if table.getvalue( _G, functionName ) ~= nil and type( _G[ functionName ] ) == "function" then
                _module.Config = table.merge( _module.Config, _G[ functionName ](), true )
            end

            if _module.Config.objects ~= nil then
                Daneel.Config.objects = table.merge( Daneel.Config.objects, _module.Config.objects )
            end

            if _module.Config.componentObjects ~= nil then
                Daneel.Config.componentObjects = table.merge( Daneel.Config.componentObjects, _module.Config.componentObjects )
                Daneel.Config.objects = table.merge( Daneel.Config.objects, _module.Config.componentObjects )
            end

            if _module.Config.functionsDebugInfo ~= nil then
                Daneel.Config.debug.functionsDebugInfo = table.merge( Daneel.Config.debug.functionsDebugInfo, _module.Config.functionsDebugInfo )
            end
        end
    end
    
    Daneel.Config.objects = table.merge( Daneel.Config.objects, Daneel.Config.componentObjects, Daneel.Config.assetObjects )
    
    Daneel.SetComponents( Daneel.Config.componentObjects )
    Daneel.Config.componentTypes = table.getkeys( Daneel.Config.componentObjects )


    if Daneel.Config.debug.enableDebug then
        if Daneel.Config.debug.enableStackTrace then
            Daneel.Debug.SetNewError()
        end

        -- overload functions with debug (error reporting + stacktrace)
        for funcName, data in pairs( Daneel.Config.debug.functionsDebugInfo ) do
            Daneel.Debug.RegisterFunction( funcName, data )
        end
    end

    -- ScriptAlias
    for alias, path in pairs( Daneel.Config.scriptPaths ) do
        local script = CraftStudio.FindAsset( path, "Script" )

        if script ~= nil then
            Daneel.Utilities.AllowDynamicGettersAndSetters( script, { Script, Component } )

            script["__tostring"] = function( scriptedBehavior )
                return "ScriptedBehavior: " .. Daneel.Cache.GetId( scriptedBehavior ) .. ": '" .. path .. "'"
            end
        else
            Daneel.Config.scriptPaths[ alias ] = nil
            if Daneel.Config.debug.enableDebug then
                print( "Daneel.Load() : item with key '" .. alias .. "' and value '" .. path .. "' in 'Daneel.Config.scriptPaths' ('DaneelUserConfig()'') is not a valid script path." )
            end
        end
    end

    if type( Camera.ProjectionMode.Orthographic ) == "number" then -- "userdata" in native runtimes
        CS.IsWebPlayer = true
    end

    Daneel.Debug.StackTrace.BeginFunction( "Daneel.Load" )

    -- Load modules 
    for i, _module in pairs( CS.DaneelModules ) do
        if _module.isLoaded ~= true then
            _module.isLoaded = true
            if type( _module.Load ) == "function" then
                _module.Load()
            end
        end
    end

    Daneel.isLoaded = true
    Daneel.isLoading = false
    if Daneel.Config.debug.enableDebug then
        print( "~~~~~ Daneel loaded ~~~~~" )
    end

    -- check for module update functions
    Daneel.moduleUpdateFunctions = {}
    for i, _module in pairs( CS.DaneelModules ) do
        if _module.doNotCallUpdate ~= true then
            if type( _module.Update ) == "function" and not table.containsvalue( Daneel.moduleUpdateFunctions, _module.Update ) then
                table.insert( Daneel.moduleUpdateFunctions, _module.Update )
            end
        end
    end

    Daneel.Debug.StackTrace.EndFunction()
end -- end Daneel.Load()

-- Called at runtime by code that needs Daneel to be loaded but it isn't yet.
function Daneel.LateLoad( source )
    if Daneel.isLateLoading or Daneel.isAwake then return end
    Daneel.isLateLoading = true
    
    print( "~~~~~~ Daneel Late Load ~~~~~~", source )
    local go = CS.CreateGameObject( "Daneel Late Load" )
    go:CreateScriptedBehavior( DaneelScriptAsset ) -- DaneelScriptAsset is set above, before Utilities.ButtonExists()
end


----------------------------------------------------------------------------------
-- Runtime
local luaDocStop = ""

function Behavior:Awake()
    if self.debugTry == true then
        CraftStudio.Destroy( self )
        self.testFunction()
        -- testFunction() may throw an error, kill the scripted behavior and not call the success callback
        -- but it won't kill the script that created the scripted behavior (the one that called Daneel.Debug.Try())
        self.successCallback()
        return
    end

    if table.getvalue( _G, "LOAD_DANEEL" ) ~= nil and LOAD_DANEEL == false then -- just for tests purposes
        return
    end
    
    if Daneel.isAwake then
        if Daneel.Config.debug.enableDebug then
            print( "Daneel:Awake() : You tried to load Daneel twice ! This time the 'Daneel' scripted behavior was on " .. tostring( self.gameObject ) )
        end
        CS.Destroy( self )
        return
    end
    Daneel.isAwake = true
    Daneel.Event.Listen( "OnSceneLoad", function() Daneel.isAwake = false end )

    Daneel.Load()
    Daneel.Debug.StackTrace.messages = {}
    Daneel.Debug.StackTrace.BeginFunction( "Daneel.Awake" )
    

    -- remove all dead game objects from GameObject.Tags
    if Daneel.isLateLoading then
        -- can't do GameObject.Tags = {} because of Daneel late loading, it would discard alive game objects that are already added as tags
        for tag, gameObjects in pairs( GameObject.Tags ) do
            for i, gameObject in pairs( gameObjects ) do
                if gameObject.inner == nil then
                    gameObjects[i] = nil
                end
            end
            
            GameObject.Tags[ tag ] = table.reindex( gameObjects )
        end
    else
        GameObject.Tags = {}
    end


    -- Awake modules 
    for i, _module in pairs( CS.DaneelModules ) do
        if type( _module.Awake ) == "function" then
            _module.Awake()
        end
    end

    if Daneel.Config.debug.enableDebug then
        print("~~~~~ Daneel awake ~~~~~")
    end

    Daneel.Event.Fire( "OnAwake" )

    Daneel.Debug.StackTrace.EndFunction()
end 

function Behavior:Start()
    if self.debugTry then
        return
    end

    Daneel.Debug.StackTrace.BeginFunction( "Daneel.Start" )

    -- Start modules 
    for i, _module in pairs( CS.DaneelModules ) do
        if type( _module.Start ) == "function" then
            _module.Start()
        end
    end

    if Daneel.Config.debug.enableDebug then
        print("~~~~~ Daneel started ~~~~~")
    end

    Daneel.Event.Fire( "OnStart" )

    Daneel.isLateLoading = nil
    Daneel.Debug.StackTrace.EndFunction()
end 

function Behavior:Update()
    if self.debugTry then
        return
    end

    -- Time
    local currentTime = os.clock()
    Daneel.Time.realDeltaTime = currentTime - Daneel.Time.realTime
    Daneel.Time.realTime = currentTime

    Daneel.Time.deltaTime = Daneel.Time.realDeltaTime * Daneel.Time.timeScale
    Daneel.Time.time = Daneel.Time.time + Daneel.Time.deltaTime

    Daneel.Time.frameCount = Daneel.Time.frameCount + 1

    -- HotKeys
    -- fire an event whenever a registered button is pressed
    for i, buttonName in pairs( Daneel.Config.hotKeys ) do
        if CraftStudio.Input.WasButtonJustPressed( buttonName ) then
            Daneel.Event.Fire( "On"..buttonName.."ButtonJustPressed" )
        end

        if CraftStudio.Input.IsButtonDown( buttonName ) then
            Daneel.Event.Fire( "On"..buttonName.."ButtonDown" )
        end

        if CraftStudio.Input.WasButtonJustReleased( buttonName ) then
            Daneel.Event.Fire( "On"..buttonName.."ButtonJustReleased" )
        end
    end

    -- Update modules 
    for i, func in pairs( Daneel.moduleUpdateFunctions ) do
        func()
    end
end

-- sublime text regexes to produce the no coment version :
-- "--.*"
-- "^\s*\n"
