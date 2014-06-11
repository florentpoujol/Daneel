-- Daneel.lua
-- Contains Daneel's core functionalities.
--
-- Last modified for v1.5.0
-- Copyright © 2013-2014 Florent POUJOL, published under the MIT license.

Daneel = {}

Daneel.modules = { moduleNames = {} }
setmetatable( Daneel.modules, {
    __newindex = function( _, moduleName, moduleObject ) -- _ argument is Daneel.modules object
        table.insert( Daneel.modules.moduleNames, moduleName )
        rawset( Daneel.modules, moduleName, moduleObject )
    end
} )

Daneel.functionsDebugInfo = {}


----------------------------------------------------------------------------------
-- Some Lua functions are overridden here with some Daneel-specific stuffs

function string.split( s, delimiter, delimiterIsPattern )
    local chunks = {}

    if delimiterIsPattern then
        local delimiterStartIndex, delimiterEndIndex = s:find( delimiter )

        if delimiterStartIndex ~= nil then
            local pattern = delimiter
            delimiter = s:sub( delimiterStartIndex, delimiterEndIndex )
            if string.startswith( s, delimiter ) then
                s = s:sub( #delimiter+1, #s )
            end
            if not s:endswith( delimiter ) then
                s = s .. delimiter
            end

            if CS.IsWebPlayer then
                -- CS Webplayer specific part :
                -- in the webplayer,  "(.-)"..delimiter  is translated into  "(.*)"..delimiter  which seems to create an infinite loop
                -- "(.+)"..delimiter   does not work either in the webplayer
                for match in s:gmatch( "([^"..pattern.."]+)"..pattern ) do
                    table.insert( chunks, match )
                end
            else
                for match in s:gmatch( "(.-)"..pattern ) do
                    table.insert( chunks, match )
                end
            end
        end

    else -- plain text delimiter
        if s:find( delimiter, 1, true ) ~= nil then
            if string.startswith( s, delimiter ) then
                s = s:sub( #delimiter+1, #s )
            end
            if not s:endswith( delimiter ) then
                s = s .. delimiter
            end

            local chunk = ""
            local ts = string.totable( s )
            local i = 1

            while i <= #ts do
                local char = ts[i]
                if char == delimiter or s:sub( i, i-1 + #delimiter ) == delimiter then
                    table.insert( chunks, chunk )
                    chunk = ""
                    i = i + #delimiter
                else
                    chunk = chunk..char
                    i = i + 1
                end
            end

            if #chunk > 0 then
                table.insert( chunks, chunk )
            end
        end
    end

    if #chunks == 0 then
        chunks = { s }
    end

    return chunks
end

-- Deprecated since v1.4.0
function table.deepmerge( ... )
    return table.merge( ..., true )
end

function table.print(t)
    if t == nil then
        print("table.print( t ) : Provided table is nil.")
        return
    end

    local tableString = tostring(t)
    local rawTableString = Daneel.Debug.ToRawString(t)
    if tableString ~= rawTableString then
        tableString = tableString.." / "..rawTableString
    end
    print("~~~~~ table.print("..tableString..") ~~~~~ Start ~~~~~")

    local func = pairs
    if table.getlength(t) == 0 then
        print("Table is empty.")
    elseif table.isarray( t ) then
        func = ipairs -- just to be sure that the entries are printed in order
    end

    for key, value in func(t) do
        print(key, value)
    end

    print("~~~~~ table.print("..tableString..") ~~~~~ End ~~~~~")
end

function table.getlength( t, keyType )
    local length = 0
    if keyType ~= nil then
        keyType = keyType:lower()
    end
    for key, value in pairs( t ) do
        if
            keyType == nil or
            type( key ) == keyType or
            Daneel.Debug.GetType( key ):lower() == keyType
        then
            length = length + 1
        end
    end
    return length
end


-- debug info
local s = "string"
local b = "boolean"
local n = "number"
local t = "table"
local f = "function"
local u = "userdata"
local _s = { "s", s }
local _t = { "t", t }

table.mergein( Daneel.functionsDebugInfo, {
    ["math.isinteger"] = { { "number" } },
    ["math.lerp"] = {
        { "a", n },
        { "b", n },
        { "factor", n },
        { "easing", s, isOptional = true }
    },
    ["math.warpangle"] = { { "angle", n } },
    ["math.round"] = {
        { "value", n },
        { "decimal", n, isOptional = true }
    },
    ["tonumber2"] = { { "data" } },

    ["string.totable"] = { _s },
    ["string.ucfirst"] = { _s },
    ["string.lcfirst"] = { _s },
    ["string.trimstart"] = { _s },
    ["string.trimend"] = { _s },
    ["string.trim"] = { _s },
    ["string.endswith"] = { _s, { "chunk", s } },
    ["string.startswith"] = { _s, { "chunk", s } },
    ["string.split"] = { _s,
        { "delimiter", s },
        { "delimiterIsPattern", b, defaultValue = false },
    },

    ["table.print"] = {}, -- just for the stacktrace
    ["table.merge"] = {},
    ["table.mergein"] = {},
    ["table.getkeys"] = { _t },
    ["table.getvalues"] = { _t },
    ["table.reverse"] = { _t },
    ["table.reindex"] = { _t },
    ["table.getvalue"] = { _t, { "keys", s } },
    ["table.setvalue"] = { _t, { "keys", s } },
    ["table.getkey"] = { _t, { "value" } },
    ["table.copy"] = { _t, { "recursive", b, defaultValue = false } },
    ["table.containsvalue"] = { _t, { "value" }, { "ignoreCase", b, defaultValue = false } },
    ["table.isarray"] = { _t, { "strict", b, defaultValue = true } },
    ["table.shift"] = { _t, { "returnKey", b, defaultValue = false } },
    ["table.getlength"] = { _t, { "keyType", s, isOptional = true } },
    ["table.havesamecontent"] = { { "table1", t }, { "table2", t } },
    ["table.combine"] = { _t,
        { "values", "table" },
        { "returnFalseIfNotSameLength", b, isOptional = true }
    },
    ["table.removevalue"] = { _t,
        { "value" },
        { "maxRemoveCount", n, isOptional = true }
    },
    ["table.sortby"] = { _t,
        { "property", s },
        { "orderBy", s, isOptional = true },
    },
} )


----------------------------------------------------------------------------------
-- Utilities

Daneel.Utilities = {}

--- Make sure that the case of the provided name is correct by checking it against the values in the provided set.
-- @param name (string) The name to check the case of.
-- @param set (string or table) A single value or a table of values to check the name against.
function Daneel.Utilities.CaseProof( name, set )
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
    return name
end

--- Replace placeholders in the provided string with their corresponding provided replacements.
-- The placeholders are any pice of string prefixed by a semicolon.
-- @param string (string) The string.
-- @param replacements (table) The placeholders and their replacements ( { placeholder = "replacement", ... } ).
-- @return (string) The string.
function Daneel.Utilities.ReplaceInString( string, replacements )
    for placeholder, replacement in pairs( replacements ) do
        string = string:gsub( ":"..placeholder, replacement )
    end
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

-- Deprecated since v1.5.0
-- Alias of tonumber2()
function Daneel.Utilities.ToNumber( data )
    return tonumber2( data )
end

local buttonExists = {} -- Button names are in key, existance (false or true) is in value

--- Tell whether the provided button name exists amongst the Game Controls, or not.
-- If the button name does not exists, it will print an error in the Runtime Report but it won't kill the script that called the function.
-- CS.Input.ButtonExists is an alias of Daneel.Utilities.ButtonExists.
-- @param buttonName (string) The button name.
-- @return (boolean) True if the button name exists, false otherwise.
function Daneel.Utilities.ButtonExists( buttonName )
    if buttonExists[ buttonName ] == nil then
        buttonExists[ buttonName ] = Daneel.Debug.Try( function()
            CS.Input.WasButtonJustPressed( buttonName )
        end )
    end
    return buttonExists[ buttonName ]
end


Daneel.Utilities.id = 0

--- Returns an interger greater than 0 and incremented by 1 from the last time the funciton was called.
-- If an object is provided, returns the object's id (if no id is found, it is set).
-- @param object (table) [optional] An object.
-- @return (number) The id.
function Daneel.Utilities.GetId( object )
    if object ~= nil and type( object ) == "table" then
        local id = rawget( object, "id" )
        if id ~= nil then
            return id
        end
        id = Daneel.Utilities.GetId()
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
        Daneel.Utilities.id = Daneel.Utilities.id + 1
        return Daneel.Utilities.id
    end
end

-- for backward compatibility, Cache object is deprecated since v1.5.0
Daneel.Cache = {
    GetId = Daneel.Utilities.GetId
}

table.mergein( Daneel.functionsDebugInfo, {
    ["Daneel.Utilities.CaseProof"] = { { "name", s }, { "set", { s, t } } },
    ["Daneel.Utilities.ReplaceInString"] = { { "string", s }, { "replacements", t } },
    ["Daneel.Utilities.ButtonExists"] = { { "buttonName", s } }
} )


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

oerror = error

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
        oerror(message)
    end
end

--- Disable the debug from this point onward.
-- @param info [optional] (string) Some info about why or where you disabled the debug. Will be printed in the Runtime Report.
function Daneel.Debug.Disable(info)
    if info ~= nil then
        info = " : "..tostring(info)
    end
    print("Daneel.Debug.Disable()"..info)
    error = oerror
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

--- Overload a function to call debug functions before and after it is itself called.
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
        if arg.name == nil then arg.name = arg[1] end
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
                if arg.type == nil then
                    arg.type = arg[2]
                    if arg.type == nil and arg.defaultValue ~= nil then
                        arg.type = type( arg.defaultValue )
                    end
                end

                if arg.type ~= nil then
                    if arg.defaultValue ~= nil or arg.isOptional == true then
                        funcArgs[ i ] = Daneel.Debug.CheckOptionalArgType( funcArgs[ i ], arg.name, arg.type, errorHead, arg.defaultValue )
                    else
                        Daneel.Debug.CheckArgType( funcArgs[ i ], arg.name, arg.type, errorHead )
                    end

                elseif funcArgs[ i ] == nil and not arg.isOptional then
                    error( errorHead.."Argument '"..arg.name.."' is nil." )
                end

                if arg.value ~= nil then
                    funcArgs[ i ] = Daneel.Debug.CheckArgValue( funcArgs[ i ], arg.name, arg.value, errorHead, arg.defaultValue )
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
    local errorHead = "Daneel.Event.Listen( eventName, functionOrObject[, isPersistent] ) : "
    local listenerType = type( functionOrObject )
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
    if argType == "string" or argType == "nil" then -- checking for nil because argument can be expressly omitted when just supplying the eventName
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

--- Register a game object to listen a particular event.
-- @param gameObject (GameObject) The game object.
-- @param eventName (string) The event name.
-- @param _function (function) The function to call when the event is fired at the game object.
function GameObject.On( gameObject, eventName, _function )
    if not string.startswith( eventName, "On" ) then
        eventName = "On"..eventName
    end
    gameObject[ eventName ] = _function
    Daneel.Event.Listen( eventName, _function )
    Daneel.Event.Fire( "GameObject.On", gameObject, eventName, _function )
end

table.mergein( Daneel.functionsDebugInfo, {
    ["Daneel.Event.Listen"] = { { "eventName", { s, t } }, { "functionOrObject", {t, f, u} }, { "isPersistent", defaultValue = false } },
    ["GameObject.On"] = { { "gameObject", "GameObject" }, { "eventName", s }, { "_function", f } },
} )


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
-- Storage

Daneel.Storage = {}

--- Store locally on the computer the provided data under the provided name.
-- @param name (string) The name of the data.
-- @param data (mixed) The data to store. May be nil.
-- @param callback (function) [optional] The function called when the save has completed. The potential error (as a string) is passed to the callback first and only argument (nil if no error).
function Daneel.Storage.Save( name, data, callback )
    if data ~= nil and type( data ) ~= "table" then
        data = {
            value = data,
            isSavedByDaneel = true
        }
    end
    CS.Storage.Save( name, data, function( error )
        if error ~= nil then
            if Daneel.Config.debug.enableDebug then
                print( "Daneel.Storage.Save( name, data[, callback] ) : Error saving with name, data and error : ", name, data, error.message )
            end
        end

        if callback ~= nil then
            if error == nil then
                error = {}
            end
            callback( error.message )
        end
    end )
end

--- Load data stored locally on the computer under the provided name. The load operation may not be instantaneous.
-- The function will return the queried value (or defaultValue) if it completes right away, otherwise it returns nil.
-- @param name (string) The name of the data.
-- @param defaultValue (mixed) [optional] The value that is returned if no data is found.
-- @param callback (function) [optional] The function called when the data is loaded. The value and the potential error (as a string) (ni if no error) are passed as first and second argument, respectively.
-- @return (mixed) The data.
function Daneel.Storage.Load( name, defaultValue, callback )
    if callback == nil and type( defaultValue ) == "function" then
        callback = defaultValue
        defaultValue = nil
    end
    local value = nil
    CS.Storage.Load( name, function( error, data )
        if error ~= nil then
            if Daneel.Config.debug.enableDebug then
                print( "Daneel.Storage.Load( name[, defaultValue, callback] ) : Error loading with name, default value and error", name, defaultValue, error.message )
            end
            data = nil
        end

        value = defaultValue

        if data ~= nil then
            if type( data ) == "table" and data.value ~= nil and data.isSavedByDaneel then
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
    return value
end

table.mergein( Daneel.functionsDebugInfo, {
    ["Daneel.Storage.Save"] = { { "name", s }, { "data", isOptional = true }, { "callback", "function", isOptional = true } },
    ["Daneel.Storage.Load"] = { { "name", s }, { "defaultValue", isOptional = true }, { "callback", "function", isOptional = true } }
} )


----------------------------------------------------------------------------------
-- Config, loading

-- Config - Loading
function Daneel.DefaultConfig()
    local config = {
        debug = {
            enableDebug = false, -- Enable/disable Daneel's global debugging features (error reporting + stacktrace).
            enableStackTrace = false, -- Enable/disable the Stack Trace.
        },

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


-- load Daneel at the start of the game
function Daneel.Load()
    if Daneel.isLoaded then return end
    Daneel.isLoading = true

    -- load Daneel config
    local userConfig = Daneel.UserConfig
    if type( userConfig ) == "function" then
        userConfig = userConfig()
    end
    if userConfig ~= nil then
        table.mergein( Daneel.Config, userConfig, true )
    end

    -- load modules config
    for i, name in ipairs( Daneel.modules.moduleNames ) do
        local module = Daneel.modules[ name ]

        if module.isConfigLoaded ~= true then
            module.isConfigLoaded = true

            if module.Config == nil then
                local config = module.DefaultConfig
                if type( config ) == "function" then
                    config = config()
                end
                if config == nil then
                    config = {}
                end
                module.Config = config
            end

            local userConfig = module.UserConfig
            if type( userConfig ) == "function" then
                userConfig = userConfig()
            end
            if userConfig ~= nil then
                table.mergein( module.Config, userConfig, true )
            end

            if module.Config.objects ~= nil then
                table.mergein( Daneel.Config.objects, module.Config.objects )
            end

            if module.Config.componentObjects ~= nil then
                table.mergein( Daneel.Config.componentObjects, module.Config.componentObjects )
                table.mergein( Daneel.Config.objects, module.Config.componentObjects )
            end
        end
    end

    table.mergein( Daneel.Config.objects, Daneel.Config.componentObjects, Daneel.Config.assetObjects )

    Daneel.SetComponents( Daneel.Config.componentObjects )
    table.mergein( Daneel.Config.componentTypes, table.getkeys( Daneel.Config.componentObjects ) )

    if Daneel.Config.debug.enableDebug then
        if Daneel.Config.debug.enableStackTrace then
            Daneel.Debug.SetNewError()
        end

        -- overload functions with debug (error reporting + stacktrace)
        for funcName, data in pairs( Daneel.functionsDebugInfo ) do
            Daneel.Debug.RegisterFunction( funcName, data )
        end
    end

    -- enable nice printing + dynamic acces of getters/setters on assets
    for assetType, assetObject in pairs( Daneel.Config.assetObjects ) do
        table.insert( Daneel.Config.assetTypes, assetType )
        Daneel.Utilities.AllowDynamicGettersAndSetters( assetObject, { Asset } )

        assetObject["__tostring"] = function( asset )
            return  assetType .. ": " .. Daneel.Utilities.GetId( asset ) .. ": '" .. Map.GetPathInPackage( asset ) .. "'"
        end
    end

    -- ScriptAlias
    for alias, path in pairs( Daneel.Config.scriptPaths ) do
        local script = CraftStudio.FindAsset( path, "Script" )

        if script ~= nil then
            Daneel.Utilities.AllowDynamicGettersAndSetters( script, { Script, Component } )

            script["__tostring"] = function( scriptedBehavior )
                return "ScriptedBehavior: " .. Daneel.Utilities.GetId( scriptedBehavior ) .. ": '" .. path .. "'"
            end
        else
            Daneel.Config.scriptPaths[ alias ] = nil
            if Daneel.Config.debug.enableDebug then
                print( "Daneel.Load() : item with key '" .. alias .. "' and value '" .. path .. "' in 'Daneel.Config.scriptPaths' ('DaneelUserConfig()'') is not a valid script path." )
            end
        end
    end

    CS.IsWebPlayer = ( type( Camera.ProjectionMode.Orthographic ) == "number" ) -- "userdata" in native runtimes

    Daneel.Debug.StackTrace.BeginFunction( "Daneel.Load" )

    -- Load modules
    for i, name in ipairs( Daneel.modules.moduleNames ) do
        local module = Daneel.modules[ name ]
        if module.isLoaded ~= true then
            module.isLoaded = true
            if type( module.Load ) == "function" then
                module.Load()
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
    for i, name in ipairs( Daneel.modules.moduleNames ) do
        local module = Daneel.modules[ name ]
        if module.doNotCallUpdate ~= true then
            if type( module.Update ) == "function" and not table.containsvalue( Daneel.moduleUpdateFunctions, module.Update ) then
                table.insert( Daneel.moduleUpdateFunctions, module.Update )
            end
        end
    end

    Daneel.Debug.StackTrace.EndFunction()
end -- end Daneel.Load()


----------------------------------------------------------------------------------
-- Runtime

-- luadoc stop
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


    -- Awake modules
    for i, name in ipairs( Daneel.modules.moduleNames ) do
        local module = Daneel.modules[ name ]
        if type( module.Awake ) == "function" then
            module.Awake()
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
    for i, name in ipairs( Daneel.modules.moduleNames ) do
        local module = Daneel.modules[ name ]
        if type( module.Start ) == "function" then
            module.Start()
        end
    end

    if Daneel.Config.debug.enableDebug then
        print("~~~~~ Daneel started ~~~~~")
    end

    Daneel.Event.Fire( "OnStart" )
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
    for i, func in ipairs( Daneel.moduleUpdateFunctions ) do
        func()
    end
end
