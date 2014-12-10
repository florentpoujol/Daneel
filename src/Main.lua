-- Daneel.lua
-- Contains Daneel's core functionalities.
--
-- Last modified for v1.5.0
-- Copyright © 2013-2014 Florent POUJOL, published under the MIT license.

Daneel = {}

Daneel.modules = { moduleNames = {} }
setmetatable( Daneel.modules, {
    __newindex = function( _, moduleName, moduleObject ) -- "_" argument is Daneel.modules object
        table.insert( Daneel.modules.moduleNames, moduleName )
        rawset( Daneel.modules, moduleName, moduleObject )
    end
} )

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

----------------------------------------------------------------------------------
-- Utilities

Daneel.Utilities = {}

-- Deprecated since v1.5.0
Daneel.Utilities.CaseProof = string.fixcase

--- Replace placeholders in the provided string with their corresponding provided replacements.
-- The placeholders are any piece of string prefixed by a semicolon.
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
Daneel.Utilities.ToNumber = tonumber2

local buttonExists = {} -- Button names are keys, existence (false or true) is value

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

--- Returns an integer greater than 0 and incremented by 1 from the last time the function was called.
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

----------------------------------------------------------------------------------
-- Debug

Daneel.Debug = {}

-- error reporting info
local s = "string"
local b = "boolean"
local n = "number"
local t = "table"
local f = "function"
local u = "userdata"
local v3 = "Vector3"
local _s = { "s", s }
local _t = { "t", t }

Daneel.Debug.functionArgumentsInfo = {
    ["math.isinteger"] = { { "number" } },
    ["math.lerp"] = {
        { "a", n },
        { "b", n },
        { "factor", n },
        { "easing", s, isOptional = true }
    },
    ["math.warpangle"] = { { "angle", n } },
    ["math.round"] = { { "value", n }, { "decimal", n, isOptional = true } },
    ["math.truncate"] = { { "value", n }, { "decimal", n, isOptional = true } },
    ["tonumber2"] = { { "data" } },
    ["math.clamp"] = { { "value", n }, { "min", n }, { "max", n } },

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
        { "delimiterIsPattern", b, isOptional = true },
    },
    ["string.reverse"] = { _s },
    ["string.fixcase"] = { _s, { "set", { s, t } } },

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
    ["table.copy"] = { _t, { "recursive", b, isOptional = true } },
    ["table.containsvalue"] = { _t, { "value" }, { "ignoreCase", b, isOptional = true } },
    ["table.isarray"] = { _t, { "strict", b, isOptional = true } },
    ["table.shift"] = { _t, { "returnKey", b, isOptional = true } },
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
}

local _transform = { "transform", "Transform" }
table.mergein( Daneel.Debug.functionArgumentsInfo, {
    ["Daneel.Utilities.ReplaceInString"] = { { "string", s }, { "replacements", t } },
    ["Daneel.Utilities.ButtonExists"] = { { "buttonName", s } },

    ["Transform.SetPosition"] =             { _transform, { "position", v3 } },
    ["Transform.SetLocalPosition"] =        { _transform, { "position", v3 } },
    ["Transform.SetEulerAngles"] =          { _transform, { "angles", v3 } },
    ["Transform.SetLocalEulerAngles"] =     { _transform, { "angles", v3 } },
    ["Transform.RotateEulerAngles"] =       { _transform, { "angles", v3 } },
    ["Transform.RotateLocalEulerAngles"] =  { _transform, { "angles", v3 } },
    ["Transform.Move"] =            { _transform, { "offset", v3 } },
    ["Transform.MoveLocal"] =       { _transform, { "offset", v3 } },
    ["Transform.MoveOriented"] =    { _transform, { "offset", v3 } },
    ["Transform.LookAt"] =          { _transform, { "target", v3 } },
    ["Transform.SetOrientation"] =      { _transform, { "orientation", "Quaternion" } },
    ["Transform.SetLocalOrientation"] = { _transform, { "orientation", "Quaternion" } },
    ["Transform.Rotate"] =              { _transform, { "orientation", "Quaternion" } },
    ["Transform.RotateLocal"] =         { _transform, { "orientation", "Quaternion" } },
} )

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

            if Daneel.Config.objectsByType ~= nil then
                for type, object in pairs( Daneel.Config.objectsByType ) do
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
    local result = table.getkey(Daneel.Config.objectsByType, value)
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

    local originalFunction = table.getvalue( _G, name )
    local originalFunctionName = name
    
    local script = argsData.script -- script asset. If set, the function is a public behavior function
    if script ~= nil then
        -- name is "Folder/ScriptName.FunctionName"
        local nameChunks = string.split( name, "." )
        local scriptPath = nameChunks[1]
        local funcName = nameChunks[2]
        originalFunctionName = funcName
        originalFunction = script[ funcName ]  

        if not script.toStringIsSet then
            script.__tostring = function( sb )
                local id = Daneel.Utilities.GetId( sb ) or "[no id]"
                return "ScriptedBehavior: "..id..": '"..scriptPath.."'"
            end
            script.toStringIsSet = true
            -- __tostring() already exists on each scripted behavior but does not seems to do much
        end

        -- make sure that the first argument is the ScriptedBehavior instance      
        local firstArg = argsData[1]
        if firstArg == nil or firstArg[2] ~= "ScriptedBehavior" then
            table.insert( argsData, 1, { name = "self", type = "ScriptedBehavior" } )
        end
    end

    if originalFunction ~= nil then
        local includeInStackTrace = argsData.includeInStackTrace or Daneel.Config.debug.enableStackTrace

        local errorHead = name.."( "
        for i, arg in ipairs( argsData ) do
            if arg.name == nil then arg.name = arg[1] end
            errorHead = errorHead..arg.name..", "
        end

        errorHead = errorHead:sub( 1, #errorHead-2 ) -- removes the last coma+space
        errorHead = errorHead.." ) : "

        local newFunction = function( ... )
            local funcArgs = { ... }

            if includeInStackTrace then
                Daneel.Debug.StackTrace.BeginFunction( name, ... )
            end

            for i, arg in ipairs( argsData ) do
                arg.type = arg.type or arg[2]

                if arg.type ~= nil then
                    if arg.isOptional == true then 
                        Daneel.Debug.CheckOptionalArgType( funcArgs[ i ], arg.name, arg.type, errorHead )
                    else
                        Daneel.Debug.CheckArgType( funcArgs[ i ], arg.name, arg.type, errorHead )
                    end

                elseif funcArgs[ i ] == nil and not arg.isOptional then
                    error( errorHead.."Argument '"..arg.name.."' is nil." )
                end
            end
            
            local returnValues = { originalFunction( ... ) }
            
            if includeInStackTrace then
                Daneel.Debug.StackTrace.EndFunction()
            end

            return unpack( returnValues )
        end

        if script ~= nil then
            script[ originalFunctionName ] = newFunction
        else
            table.setvalue( _G, name, newFunction )
        end
    else
        print( "Daneel.Debug.RegisterFunction(): Function with name '"..name.."' was not found." )
    end
end

--- Register all functions of a scripted behavior to be included in the stacktrace.
-- Within a script, the 'Behavior' variable is the script asset.
-- @param script (Script) The script asset.
function Daneel.Debug.RegisterScript( script )
    if not Daneel.Config.debug.enableDebug then return end

    if type( script ) ~= "table" or getmetatable( script ) ~= Script then
        error("Daneel.Debug.SetupScript(script): Provided argument is not a script asset. Within a script, the 'Behavior' variable is the script asset.")
    end
    local infos = Daneel.Debug.functionArgumentsInfo
    local forbiddenNames = { "Update", "inner" }
    -- Awake, is never included in the stacktrace anyway because CraftStudio
    -- keeps the reference to the function first set in the script.
    -- Overloading it at runtime has no effect.
    -- 05/12/2014 It isn't the case for Start()

    local scriptPath = Map.GetPathInPackage( script )
    for name, func in pairs( script ) do
        local fullName = scriptPath.."."..name
        if 
            not name:startswith("__") and
            not table.containsvalue( forbiddenNames, name ) and
            infos[fullName] == nil
        then
            infos[fullName] = { script = script }
        end
    end
end

--- Register all functions of an object to be included in the stacktrace.
-- @param objectName (string or table) The object's name or object.
function Daneel.Debug.RegisterObject( objectName )
    if not Daneel.Config.debug.enableDebug then return end

    local originalArgument = objectName
    local object = nil
    
    if type(objectName) == "table" then
        object = objectName
        objectName = Daneel.Debug.GetNameFromValue( object )
    else
        object = table.getvalue(Daneel.Config.objectsByType, objectName)
        if object == nil then
            object = table.getvalue(_G, objectName)
        end
    end
        
    if object == nil or objectName == nil then
        print("Daneel.Debug.RegisterObject(): object or name not found", originalArgument, objectName, object)
        return
    end
    
    local infos = Daneel.Debug.functionArgumentsInfo
    local forbiddenNames = { "Load", "DefaultConfig", "UserConfig", "Awake", "Start", "Update", "New", "inner", "GetId", "GetName" }
    
    for name, func in pairs( object ) do
        if type( func ) == "function" or type( func ) == "userdata" then
            local fullName = objectName.."."..name
            
            if 
                not name:startswith("__") and
                not name:startswith("o") and
                not table.containsvalue( forbiddenNames, name ) and
                infos[fullName] == nil
            then 
                infos[fullName] = {}
            end
        end
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
    events = {}, -- listeners by events - emptied when a new scene is loaded in CraftStudio.LoadScene()
    persistentEvents = {}, -- not emptied
}

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
            -- check that the persistent listener is not a game object or a component (that are always destroyed when the scene loads)
            if isPersistent == true and listenerType == "table" then
                local mt = getmetatable( functionOrObject )
                if mt ~= nil and mt == GameObject or table.containsvalue( Daneel.Config.componentObjectsByType, mt ) then
                    if Daneel.Config.debug.enableDebug then
                        print( errorHead.."Game objects and components can't be persistent listeners", functionOrObject )
                    end
                    isPersistent = false
                end
            end

            local eventList = Daneel.Event.events
            if isPersistent == true then
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
    if argType == "string" then
        -- no object provided, fire on the listeners
        if eventName ~= nil then
            table.insert( arg, 1, eventName )
        end
        eventName = object
        object = nil
    
    elseif argType ~= "nil" then
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
    for i=1, #listeners do
        local listener = listeners[i]

        local listenerType = type( listener )
        if listenerType == "function" or listenerType == "userdata" then
            if listener( unpack( arg ) ) == false then
                table.insert( listenersToBeRemoved, listener )
            end

        else -- an object
            local mt = getmetatable( listener )
            local listenerIsAlive = not listener.isDestroyed
            if mt == GameObject and listener.inner == nil then
                listenerIsAlive = false
            end
            if listenerIsAlive then -- ensure that the event is not fired on a dead game object or component
                local functions = {} -- list of listener functions attached to this object
                if listener.listenersByEvent ~= nil and listener.listenersByEvent[ eventName ] ~= nil then
                    functions = listener.listenersByEvent[ eventName ]
                end

                -- Look for the value of the EventName property on the object
                local func = rawget( listener, eventName )
                -- Using rawget() prevent a 'Behavior function' to be called as a regular function when the listener is a ScriptedBehavior
                -- because the function exists on the Script object and not on the ScriptedBehavior (the listener),
                -- in which case rawget() returns nil
                if func ~= nil then
                    table.insert( functions, func )
                end

                -- call all listener functions
                for j=1, #functions do
                    functions[j]( ... )
                end

                -- always try to send the message if the object is a game object
                if mt == GameObject then
                    local go = arg[1]
                    if go == listener then
                        -- don't send the first argument when it is the listener game
                        table.remove( arg, 1 )
                    end
                    if #arg == 1 and type( arg[1] ) == "table" then
                        -- directly send the table if there is no other argument
                        arg = arg[1]
                    end
                    listener:SendMessage( eventName, arg )
                end
            end
        end

    end -- end for listeners

    
    for i=1, #listenersToBeRemoved do
        Daneel.Event.StopListen( eventName, listenersToBeRemoved[i] )
    end
    Daneel.Debug.StackTrace.EndFunction()
end

--- Fire an event at the provided game object.
-- @param gameObject (GameObject) The game object.
-- @param eventName (string) The event name.
-- @param ... [optional] Some arguments to pass along.
function GameObject.FireEvent( gameObject, eventName, ... )
    Daneel.Event.Fire( gameObject, eventName, ... )
end

--- Add a listener function for the specified local event on this object.
-- @param object (table) The object.
-- @param eventName (string) The name of the event to listen to.
-- @param listener (function or userdata) The listener function.
function Daneel.Event.AddEventListener( object, eventName, listener )
    if object.listenersByEvent == nil then
        object.listenersByEvent = {}
    end
    if object.listenersByEvent[ eventName ] == nil then
        object.listenersByEvent[ eventName ] = {}
    end
    if not table.containsvalue( object.listenersByEvent[ eventName ], listener ) then
        table.insert( object.listenersByEvent[ eventName ], listener )
    elseif Daneel.Debug.enableDebug == true then
        print("Daneel.Event.AddEventListener(): "..tostring(listener).." already listen for event '"..eventName.."' on object: ", object)
    end
end

--- Add a listener function for the specified local event on this game object.
-- Alias of Daneel.Event.AddEventListener().
-- @param gameObject (GameObject) The game object.
-- @param eventName (string) The name of the event to listen to.
-- @param listener (function or userdata) The listener function.
function GameObject.AddEventListener( gameObject, eventName, listener )
    Daneel.Event.AddEventListener( gameObject, eventName, listener )
end

--- Remove the specified listener for the specified local event on this object
-- @param object (table) The object.
-- @param eventName (string) The name of the event.
-- @param listener (function or userdata) [optional] The listener function to remove. If nil, all listeners will be removed for the specified event.
function Daneel.Event.RemoveEventListener( object, eventName, listener )
    if object.listenersByEvent ~= nil and object.listenersByEvent[ eventName ] ~= nil then
        if listener ~= nil then
            table.removevalue( object.listenersByEvent[ eventName ], listener )
        else
            object.listenersByEvent[ eventName ] = nil
        end
    end
end

--- Remove the specified listener for the specified local event on this game object
-- @param gameObject (table) The game object.
-- @param eventName (string) The name of the event.
-- @param listener (function or userdata) [optional] The listener function to remove. If nil, all listeners will be removed for the specified event.
function GameObject.RemoveEventListener( gameObject, eventName, listener )
    Daneel.Event.RemoveEventListener( gameObject, eventName, listener )
end

local _go = { "gameObject", "GameObject" }
table.mergein( Daneel.Debug.functionArgumentsInfo, {
    ["Daneel.Event.Listen"] = { { "eventName", { s, t } }, { "functionOrObject", {t, f, u} }, { "isPersistent", b, isOptional = true } },
    ["GameObject.FireEvent"] = { _go, { "eventName", s } },
    ["Daneel.Event.AddEventListener"] = { { "object", "table" }, { "eventName", s }, { "listener", { f, u } } },
    ["GameObject.AddEventListener"] =   { _go, { "eventName", s }, { "listener", { f, u } } },
    ["Daneel.Event.RemoveEventListener"] = { { "object", "table" }, { "eventName", s }, { "listener", { f, u }, isOptional = true } },
    ["GameObject.RemoveEventListener"] = { _go, { "eventName", s }, { "listener", { f, u }, isOptional = true } },
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
-- Config, loading

function Daneel.DefaultConfig()
    local config = {
        debug = {
            enableDebug = false, -- Enable/disable Daneel's global debugging features (error reporting + stacktrace).
            enableStackTrace = false, -- Enable/disable the Stack Trace.
        },

        -- this table define the object's type names, returned by Daneel.Debug.GetType()
        objectsByType = {
            GameObject = GameObject,
            Vector3 = Vector3,
            Quaternion = Quaternion,
            Plane = Plane,
            Ray = Ray,
        },

        componentObjectsByType = {
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

        assetObjectsByType = {
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
Daneel.Config.assetTypes = table.getkeys( Daneel.Config.assetObjectsByType ) -- needed in the CraftStudio script before Daneel is loaded

-- load Daneel at the start of the game
function Daneel.Load()
    if Daneel.isLoaded then return end
    Daneel.isLoading = true

    -- load Daneel config
    local userConfig = nil
    if Daneel.UserConfig ~= nil then
        table.mergein( Daneel.Config, Daneel.UserConfig(), true )
    end

    -- load modules config
    for i, name in ipairs( Daneel.modules.moduleNames ) do
        local module = Daneel.modules[ name ]

        if module.isConfigLoaded ~= true then
            module.isConfigLoaded = true

            if module.Config == nil then
                if module.DefaultConfig ~= nil then
                    module.Config = module.DefaultConfig()
                else
                    module.Config = {}
                end
            end

            if module.UserConfig ~= nil then
                table.mergein( module.Config, module.UserConfig(), true )
            end

            if module.Config.objectsByType ~= nil then
                table.mergein( Daneel.Config.objectsByType, module.Config.objectsByType )
            end

            if module.Config.componentObjectsByType ~= nil then
                table.mergein( Daneel.Config.componentObjectsByType, module.Config.componentObjectsByType )
                table.mergein( Daneel.Config.objectsByType, module.Config.componentObjectsByType )
            end
        end
    end

    table.mergein( Daneel.Config.objectsByType, Daneel.Config.componentObjectsByType, Daneel.Config.assetObjectsByType )

    -- Enable nice printing + dynamic access of getters/setters on components
    for componentType, componentObject in pairs( Daneel.Config.componentObjectsByType ) do
        Daneel.Utilities.AllowDynamicGettersAndSetters( componentObject, { Component } )

        if componentType ~= "ScriptedBehavior" then
            componentObject["__tostring"] = function( component )
                return componentType .. ": " .. component:GetId()
            end
        end
    end

    table.mergein( Daneel.Config.componentTypes, table.getkeys( Daneel.Config.componentObjectsByType ) )

    -- Enable nice printing + dynamic access of getters/setters on assets
    for assetType, assetObject in pairs( Daneel.Config.assetObjectsByType ) do
        Daneel.Utilities.AllowDynamicGettersAndSetters( assetObject, { Asset } )

        assetObject["__tostring"] = function( asset )
            return  assetType .. ": " .. Daneel.Utilities.GetId( asset ) .. ": '" .. Map.GetPathInPackage( asset ) .. "'"
        end
    end

    -- setup error reporting + stack trace
    if Daneel.Config.debug.enableDebug then
        if Daneel.Config.debug.enableStackTrace then
            Daneel.Debug.SetNewError()
        end

        -- overload functions with debug (error reporting + stacktrace)
        for funcName, data in pairs( Daneel.Debug.functionArgumentsInfo ) do
            Daneel.Debug.RegisterFunction( funcName, data )
        end
    end

    CS.IsWebPlayer = type( Camera.ProjectionMode.Orthographic ) == "number" -- "userdata" in native runtimes

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
function Behavior.Awake( self )
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
            print( "Daneel:Awake() : You tried to load Daneel twice ! The 'Daneel' scripted behavior is on two game objects inside the same scene. This time, it was on " .. tostring( self.gameObject ) )
        end
        CS.Destroy( self )
        return
    end
    Daneel.isAwake = true
    Daneel.Event.Listen( "OnNewSceneWillLoad", function() Daneel.isAwake = false end )

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

function Behavior.Start( self )
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

function Behavior.Update( self )
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

    -- Update modules
    for i=1, #Daneel.moduleUpdateFunctions do
        Daneel.moduleUpdateFunctions[i]()
    end
end

--------------------------------------------------------------------------------
-- Mouse Input component
-- Enable mouse interactions with game objects when added to a game object with a camera component.

MouseInput = { 
    buttonExists = { LeftMouse = false, RightMouse = false, WheelUp = false, WheelDown = false },
    
    frameCount = 0,
    lastLeftClickFrame = 0,

    components = {}, -- array of mouse input components
}
Daneel.modules.MouseInput = MouseInput

function MouseInput.DefaultConfig()
    return {
        doubleClickDelay = 20, -- Maximum number of frames between two clicks of the left mouse button to be considered as a double click

        componentObjectsByType = {
            MouseInput = MouseInput,
        },
    }
end
MouseInput.Config = MouseInput.DefaultConfig()

function MouseInput.Load()
    for buttonName, _ in pairs( MouseInput.buttonExists ) do
        MouseInput.buttonExists[ buttonName ] = Daneel.Utilities.ButtonExists( buttonName )
    end

    MouseInput.lastLeftClickFrame = -MouseInput.Config.doubleClickDelay
end

function MouseInput.Awake()
    MouseInput.components = {}
end

-- Loop on the MouseInput.components.
-- Works with the game objects that have at least one of the component's tag.
-- Check the position of the mouse against these game objects.
-- Fire events accordingly.
function MouseInput.Update()
    MouseInput.frameCount = MouseInput.frameCount + 1
    
    local mouseDelta = CS.Input.GetMouseDelta()
    local mouseIsMoving = false
    if mouseDelta.x ~= 0 or mouseDelta.y ~= 0 then
        mouseIsMoving = true
    end

    local leftMouseJustPressed = false
    local leftMouseDown = false
    local leftMouseJustReleased = false
    if MouseInput.buttonExists.LeftMouse then
        leftMouseJustPressed = CS.Input.WasButtonJustPressed( "LeftMouse" )
        leftMouseDown = CS.Input.IsButtonDown( "LeftMouse" )
        leftMouseJustReleased = CS.Input.WasButtonJustReleased( "LeftMouse" )
    end

    local rightMouseJustPressed = false
    if MouseInput.buttonExists.RightMouse then
        rightMouseJustPressed = CS.Input.WasButtonJustPressed( "RightMouse" )
    end

    local wheelUpJustPressed = false
    if MouseInput.buttonExists.WheelUp then
        wheelUpJustPressed = CS.Input.WasButtonJustPressed( "WheelUp" )
    end

    local wheelDownJustPressed = false
    if MouseInput.buttonExists.WheelDown then
        wheelDownJustPressed = CS.Input.WasButtonJustPressed( "WheelDown" )
    end
    
    if 
        mouseIsMoving == true or
        leftMouseJustPressed == true or 
        leftMouseDown == true or
        leftMouseJustReleased == true or 
        rightMouseJustPressed == true or
        wheelUpJustPressed == true or
        wheelDownJustPressed == true
    then
        local doubleClick = false
        if leftMouseJustPressed then
            doubleClick = ( MouseInput.frameCount <= MouseInput.lastLeftClickFrame + MouseInput.Config.doubleClickDelay )   
            MouseInput.lastLeftClickFrame = MouseInput.frameCount
        end

        local reindexComponents = false
        
        for i=1, #MouseInput.components do
            local component = MouseInput.components[i]
            local mi_gameObject = component.gameObject -- mouse input game object

            if mi_gameObject.inner ~= nil and not mi_gameObject.isDestroyed and mi_gameObject.camera ~= nil then
                local ray = mi_gameObject.camera:CreateRay( CS.Input.GetMousePosition() )
                
                for j=1, #component._tags do
                    local tag = component._tags[j]
                    local gameObjects = GameObject.GetWithTag( tag )

                    for k=1, #gameObjects do
                        local gameObject = gameObjects[k]
                        -- gameObject is the game object whose position is checked against the raycasthit
                            
                        local raycastHit = ray:IntersectsGameObject( gameObject )
                        if raycastHit ~= nil then
                            -- the mouse pointer is over the gameObject
                            if not gameObject.isMouseOver then
                                gameObject.isMouseOver = true
                                Daneel.Event.Fire( gameObject, "OnMouseEnter", gameObject )
                            end

                        elseif gameObject.isMouseOver == true then
                            -- the gameObject was still hovered the last frame
                            gameObject.isMouseOver = false
                            Daneel.Event.Fire( gameObject, "OnMouseExit", gameObject )
                        end
                        
                        if gameObject.isMouseOver == true then
                            Daneel.Event.Fire( gameObject, "OnMouseOver", gameObject, raycastHit )

                            if leftMouseJustPressed == true then
                                Daneel.Event.Fire( gameObject, "OnClick", gameObject )

                                if doubleClick == true then
                                    Daneel.Event.Fire( gameObject, "OnDoubleClick", gameObject )
                                end
                            end

                            if leftMouseDown == true and mouseIsMoving == true then
                                Daneel.Event.Fire( gameObject, "OnDrag", gameObject )
                            end

                            if leftMouseJustReleased == true then
                                Daneel.Event.Fire( gameObject, "OnLeftClickReleased", gameObject )
                            end

                            if rightMouseJustPressed == true then
                                Daneel.Event.Fire( gameObject, "OnRightClick", gameObject )
                            end

                            if wheelUpJustPressed == true then
                                Daneel.Event.Fire( gameObject, "OnWheelUp", gameObject )
                            end
                            if wheelDownJustPressed == true then
                                Daneel.Event.Fire( gameObject, "OnWheelDown", gameObject )
                            end
                        end
                    end -- for gameObjects with current tag
                end -- for component._tags
            else
                -- this component's game object is dead or has no camera component
                MouseInput.components[i] = nil
                reindexComponents = true
            end -- gameObject is alive
        end -- for MouseInput.components

        if reindexComponents == true then
            MouseInput.components = table.reindex( MouseInput.components )
        end
    end -- if mouseIsMoving, ...
end -- end MouseInput.Update() 

--- Create a new MouseInput component.
-- @param gameObject (GameObject) The game object.
-- @param params (table) [optional] A table of parameters.
-- @return (MouseInput) The new component.
function MouseInput.New( gameObject, params )
    if gameObject.camera == nil then
        error( "MouseInput.New(gameObject, params) : "..tostring(gameObject).." has no Camera component." )
        return
    end

    local component = { _tags = {} }
    component.gameObject = gameObject
    gameObject.mouseInput = component
    setmetatable( component, MouseInput )  
    if params ~= nil then
        component:Set( params )
    end

    table.insert( MouseInput.components, component )
    return component
end

--- Set tag(s) of the game objects the component works with.
-- @param mouseInput (MouseInput) The mouse input component.
-- @param tags (string or table) The tag(s) of the game objects the component works with.
function MouseInput.SetTags( mouseInput, tags )
    if type( tags ) == "string" then
        tags = {tags}
    end
    mouseInput._tags = tags
end

--- Return the tag(s) of the game objects the component works with.
-- @param mouseInput (MouseInput) The mouse input component.
-- @return (table) The tag(s) of the game objects the component works with.
function MouseInput.GetTags( mouseInput )
    return mouseInput._tags
end

local _mo = { "mouseInput", "MouseInput" }
table.mergein( Daneel.Debug.functionArgumentsInfo, {
    ["MouseInput.New"] = { _go, { "params", "table", isOptional = true } },
    ["MouseInput.SetTags"] = { _mo, { "tags", { s, t } } },
    ["MouseInput.GetTags"] = { _mo },
} )

--------------------------------------------------------------------------------
-- Trigger component

Trigger = {
    frameCount = 0,
    components = {},
}
Daneel.modules.Trigger = Trigger

function Trigger.DefaultConfig()
    return {
        componentObjectsByType = {
            Trigger = Trigger,
        },
    }
end
Trigger.Config = Trigger.DefaultConfig()

function Trigger.Awake()
    Trigger.components = {}
end

function Trigger.Update()
    Trigger.frameCount = Trigger.frameCount + 1
    local reindexComponents = false

    for i=1, #Trigger.components do
        local trigger = Trigger.components[i]
        local triggerGameObject = trigger.gameObject

        if triggerGameObject.inner ~= nil and not triggerGameObject.isDestroyed then
            if trigger._updateInterval > 1 and Trigger.frameCount % trigger._updateInterval == 0 then
                local triggerPosition = triggerGameObject.transform:GetPosition()
                
                for j=1, #trigger._tags do
                    local tag = trigger._tags[j]
                    local gameObjects = GameObject.GetWithTag( tag )

                    for k=1, #gameObjects do
                        local gameObject = gameObjects[k]
                        -- gameObject is the game object whose position is checked against the trigger's
                        if gameObject ~= triggerGameObject then    

                            local gameObjectIsInRange = trigger:IsGameObjectInRange( gameObject, triggerPosition )
                            local gameObjectWasInRange = table.containsvalue( trigger.gameObjectsInRangeLastUpdate, gameObject )

                            if gameObjectIsInRange then
                                if gameObjectWasInRange then
                                    -- already in this trigger
                                    Daneel.Event.Fire( gameObject, "OnTriggerStay", gameObject, triggerGameObject )
                                    Daneel.Event.Fire( triggerGameObject, "OnTriggerStay", triggerGameObject, gameObject )
                                else
                                    -- just entered the trigger
                                    table.insert( trigger.gameObjectsInRangeLastUpdate, gameObject )
                                    Daneel.Event.Fire( gameObject, "OnTriggerEnter", gameObject, triggerGameObject )
                                    Daneel.Event.Fire( triggerGameObject, "OnTriggerEnter", triggerGameObject, gameObject )
                                end
                            elseif gameObjectWasInRange then
                                -- was in the trigger, but not anymore
                                table.removevalue( trigger.gameObjectsInRangeLastUpdate, gameObject )
                                Daneel.Event.Fire( gameObject, "OnTriggerExit", gameObject, triggerGameObject )
                                Daneel.Event.Fire( triggerGameObject, "OnTriggerExit", triggerGameObject, gameObject )
                            end
                        end
                    end -- for gameObjects with current tag
                end -- for component._tags
            end -- it's time to update this trigger
        else
            -- this component's game object is dead
            Trigger.components[i] = nil
            reindexComponents = true
        end -- game object is alive
    end -- for Trigger.components

    if reindexComponents == true then
        Trigger.components = table.reindex( Trigger.components )
    end
end

--- Create a new Trigger component.
-- @param gameObject (GameObject) The game object.
-- @param params (table) [optional] A table of parameters.
-- @return (Trigger) The new component.
function Trigger.New( gameObject, params )
    local trigger = {
        _range = 1,
        _updateInterval = 5,
        _tags = {},
        gameObjectsInRangeLastUpdate = {},
    }
    trigger.gameObject = gameObject
    gameObject.trigger = trigger
    setmetatable( trigger, Trigger )
    if params ~= nil then
        trigger:Set( params )
    end
    table.insert( Trigger.components, trigger )
    return trigger
end

--- Set tag(s) of the game objects the component works with.
-- @param trigger (Trigger) The trigger component.
-- @param tags (string or table) The tag(s) of the game objects the component works with.
function Trigger.SetTags( trigger, tags )
    if type( tags ) == "string" then
        tags = {tags}
    end
    trigger._tags = tags
end

--- Return the tag(s) of the game objects the component works with.
-- @param trigger (Trigger) The trigger component.
-- @return (table) The tag(s) of the game objects the component works with.
function Trigger.GetTags( trigger )
    return trigger._tags
end

--- Set the range of the trigger.
-- @param trigger (Trigger) The trigger component.
-- @param range (number) The range of the trigger. Must be >= 0. Set to 0 to use the trigger's map or model as area.
function Trigger.SetRange( trigger, range )
    trigger._range = math.clamp( range, 0, 9999 )
end

--- Get the range of the trigger.
-- @param trigger (Trigger) The trigger component.
-- @return (number) The range of the trigger.
function Trigger.GetRange( trigger )
    return trigger._range
end

--- Set the interval (in frames) at which the trigger is automatically updated.
-- A value < 1 will prevent the trigger to be automatically updated.
-- @param trigger (Trigger) The trigger component.
-- @param updateInterval (number) The update interval in frames. Must be >= 0
function Trigger.SetUpdateInterval( trigger, updateInterval )
    trigger._updateInterval = math.clamp( updateInterval, 0, 9999 )
end

--- Get the interval (in frames) at which the trigger is automatically updated.
-- @param trigger (Trigger) The trigger component.
-- @return (number) The update interval (in frames) of the trigger.
function Trigger.GetUpdateInterval( trigger )
    return trigger._updateInterval
end

--- Get the gameObjects that are within range of that trigger.
-- @param trigger (Trigger) The trigger component.
-- @return (table) The list of the gameObjects in range (empty if none in range).
function Trigger.GetGameObjectsInRange( trigger )
    local triggerPosition = trigger.gameObject.transform:GetPosition() 
    local gameObjectsInRange = {}
    for i=1, #trigger._tags do
        local gameObjects = GameObject.GetWithTag( trigger._tags[i] )
        for j=1, #gameObjects do
            local gameObject = gameObjects[j]
            if 
                gameObject ~= trigger.gameObject and
                trigger:IsGameObjectInRange( gameObject, triggerPosition )
            then
                table.insertonce( gameObjectsInRange, gameObject )
            end
        end
    end
    return gameObjectsInRange
end

--- Tell whether the provided game object is in range of the trigger.
-- @param trigger (Trigger) The trigger component.
-- @param gameObject (GameObject) The gameObject.
-- @param triggerPosition (Vector3) [optional] The trigger's current position.
-- @return (boolean) True or false.
function Trigger.IsGameObjectInRange( trigger, gameObject, triggerPosition )
    local errorHead = "Behavior:IsGameObjectInRange( gameObject[, triggerPosition] )"
    local triggerGameObject = trigger.gameObject
    if triggerPosition == nil then
        triggerPosition = triggerGameObject.transform:GetPosition()
    end 

    local gameObjectIsInTrigger = false
    local directionToGameObject = gameObject.transform:GetPosition() - triggerPosition
    local sqrDistanceToGameObject = directionToGameObject:SqrLength()

    if trigger._range > 0 and sqrDistanceToGameObject <= trigger._range ^ 2 then
        gameObjectIsInTrigger = true

    elseif trigger._range <= 0 then
        if trigger.ray == nil then
            trigger.ray = Ray.New( Vector3.New(0), Vector3.New(0) )
        end
        local ray = trigger.ray
        ray.position = triggerPosition
        ray.direction = directionToGameObject -- ray from the trigger to the game object
        
        local distanceToTriggerAsset = nil -- distance to trigger model or map
        if triggerGameObject.modelRenderer ~= nil then
            distanceToTriggerAsset = ray:IntersectsModelRenderer( triggerGameObject.modelRenderer )
        elseif triggerGameObject.mapRenderer ~= nil then
            distanceToTriggerAsset = ray:IntersectsMapRenderer( triggerGameObject.mapRenderer )
        end

        -- if the gameObject has a model or map, replace the distance to the game object with the distance to the asset
        if gameObject.modelRenderer ~= nil then
            sqrDistanceToGameObject = ray:IntersectsModelRenderer( gameObject.modelRenderer ) ^ 2
        elseif gameObject.mapRenderer ~= nil then
            sqrDistanceToGameObject = ray:IntersectsMapRenderer( gameObject.mapRenderer ) ^ 2
        end

        if distanceToTriggerAsset ~= nil and sqrDistanceToGameObject <= distanceToTriggerAsset ^ 2 then
            -- distance from the trigger to the game object is inferior to the distance from the trigger to the trigger's model or map
            -- that means the GO is inside of the model/map
            -- the ray goes through the GO origin before intersecting the asset 
            gameObjectIsInTrigger = true
        end
    end

    return gameObjectIsInTrigger
end

local _trigger = { "trigger", "Trigger" }
table.mergein( Daneel.Debug.functionArgumentsInfo, {
    ["Trigger.New"] = { _go, { "params", "table", isOptional = true } },
    ["Trigger.SetTags"] = { _trigger, { "tags", { s, t } } },
    ["Trigger.GetTags"] = { _trigger },
    ["Trigger.SetRange"] = { _trigger, { "range", n } },
    ["Trigger.GetRange"] = { _trigger },
    ["Trigger.SetUpdateInterval"] = { _trigger, { "updateInterval", n } },
    ["Trigger.GetUpdateInterval"] = { _trigger },
    ["Trigger.GetGameObjectsInRange"] = { _trigger },
    ["Trigger.IsGameObjectInRange"] = { _trigger, _go, { "triggerPosition", "Vector3", isOptional = true } },
} )

--------------------------------------------------------------------------------
-- Language - Localization

Lang = {
    dictionariesByLanguage = { english = {} },
    cache = {},
    gameObjectsToUpdate = {},
    doNotCallUpdate = true, -- let that here ! It's read in Daneel.Load() to not include Lang.Update() to the list of functions to be called every frames.
}

Daneel.modules.Lang = Lang

function Lang.DefaultConfig()
    return {
        default = nil, -- Default language
        current = nil, -- Current language
        searchInDefault = true, -- Tell whether Lang.Get() search a line key in the default language 
        -- when it is not found in the current language before returning the value of keyNotFound
        keyNotFound = "langkeynotfound", -- Value returned when a language key is not found
    }
end
Lang.Config = Lang.DefaultConfig()

function Lang.Load()
    local defaultLanguage = nil

    for lang, dico in pairs( Lang.dictionariesByLanguage ) do
        local llang = lang:lower()
        if llang ~= lang then
            Lang.dictionariesByLanguage[ llang ] = dico
            Lang.dictionariesByLanguage[ lang ] = nil
        end

        if defaultLanguage == nil then
            defaultLanguage = llang
        end
    end

    if defaultLanguage == nil then -- no dictionary found
        if Daneel.Config.debug.enableDebug == true then
            error("Lang.Load(): No dictionary found in Lang.dictionariesByLanguage !")
        end
        return
    end
    
    if Lang.Config.default == nil then
        Lang.Config.default = defaultLanguage
    end
    Lang.Config.default = Lang.Config.default:lower()

    if Lang.Config.current == nil then
        Lang.Config.current = Lang.Config.default
    end
    Lang.Config.current = Lang.Config.current:lower()
end

function Lang.Start() 
    if Lang.Config.current ~= nil then
        Lang.Update( Lang.Config.current )
    end
end

--- Get the localized line identified by the provided key.
-- @param key (string) The language key.
-- @param replacements (table) [optional] The placeholders and their replacements.
-- @return (string) The line.
function Lang.Get( key, replacements )
    if replacements == nil and Lang.cache[ key ] ~= nil then
        return Lang.cache[ key ]
    end

    local currentLanguage = Lang.Config.current
    local defaultLanguage = Lang.Config.default
    local searchInDefault = Lang.Config.searchInDefault
    local cache = true

    local keys = string.split( key, "." )
    local language = currentLanguage
    if Lang.dictionariesByLanguage[ keys[1] ] ~= nil then
        language = table.remove( keys, 1 )
    end
    
    local noLangKey = table.concat( keys, "." ) -- rebuilt the key, but without the language
    local fullKey = language .. "." .. noLangKey 
    if replacements == nil and Lang.cache[ fullKey ] ~= nil then
        return Lang.cache[ fullKey ]
    end

    local dico = Lang.dictionariesByLanguage[ language ]
    local errorHead = "Lang.Get(key[, replacements]): "
    if dico == nil then
        error( errorHead.."Language '"..language.."' does not exists", key, fullKey )
    end

    for i=1, #keys do
        local _key = keys[i]
        if dico[_key] == nil then
            -- key was not found in this language
            -- search for it in the default language
            if searchInDefault == true and language ~= defaultLanguage then
                cache = false
                dico = Lang.Get( defaultLanguage.."."..noLangKey, replacements )
            else -- already default language or don't want to search in
                dico = Lang.Config.keyNotFound or "keynotfound"
            end

            break
        end
        dico = dico[ _key ]
        -- dico is now a nested table in the dictionary, or a searched string (or the keynotfound string)
    end

    -- dico should be the searched (or keynotfound) string by now
    local line = dico
    if type( line ) ~= "string" then
        error( errorHead.."Localization key '"..key.."' does not lead to a string but to : '"..tostring(line).."'.", key, fullKey )
    end

    -- process replacements
    if replacements ~= nil then
        line = Daneel.Utilities.ReplaceInString( line, replacements )
    elseif cache == true and line ~= Lang.Config.keyNotFound then
        Lang.cache[ key ] = line -- ie: "greetings.welcome"
        Lang.cache[ fullKey ] = line -- ie: "english.greetings.welcome"
    end

    return line
end

--- Register a game object to update its text renderer whenever the language will be updated by Lang.Update().
-- @param gameObject (GameObject) The gameObject.
-- @param key (string) The language key.
-- @param replacements (table) [optional] The placeholders and their replacements.
function Lang.RegisterForUpdate( gameObject, key, replacements )
    Lang.gameObjectsToUpdate[gameObject] = {
        key = key,
        replacements = replacements,
    }
end

--- Update the current language and the text of all game objects that have registered via Lang.RegisterForUpdate(). <br>
-- Fire the OnLangUpdate event.
-- @param language (string) The new current language.
function Lang.Update( language )
    language = Daneel.Debug.CheckArgValue( language, "language", table.getkeys( Lang.dictionariesByLanguage ), "Lang.Update(language): " )
    
    Lang.cache = {} -- ideally only the items that do not begins by a language name should be deleted
    Lang.Config.current = language
    for gameObject, data in pairs( Lang.gameObjectsToUpdate ) do
        if gameObject.inner == nil or gameObject.isDestroyed == true then
            Lang.gameObjectsToUpdate[ gameObject ] = nil
        else
            local text = Lang.Get( data.key, data.replacements )
            
            if gameObject.textArea ~= nil then
                gameObject.textArea:SetText( text )
            elseif gameObject.textRenderer ~= nil then
                gameObject.textRenderer:SetText( text )
            
            elseif Daneel.Config.debug.enableDebug then
                print( "Lang.Update(language): WARNING : "..tostring( gameObject ).." has no TextRenderer or GUI.TextArea component." )
            end
        end
    end

    Daneel.Event.Fire( "OnLangUpdate" )
end

table.mergein( Daneel.Debug.functionArgumentsInfo, {
    ["Lang.Get"] = { { "key", "string" }, { "replacements", "table", isOptional = true } },
    ["Lang.RegisterForUpdate"] = { _go, { "key", "string" }, { "replacements", "table", isOptional = true } },
    ["Lang.Update"] = { { "language", "string" } },
} )
