----------------------------------------------------------------------------------
-- GAMEOBJECT
----------------------------------------------------------------------------------


setmetatable( GameObject, { __call = function(Object, ...) return Object.New(...) end } )

-- returns something like "GameObject: 123456789: 'MyName'"
function GameObject.__tostring( gameObject )
    if rawget( gameObject, "transform" ) == nil then
        return "Destroyed gameObject: " .. Daneel.Debug.ToRawString( gameObject )
        -- the important here was to prevent throwing an error
    end

    return "GameObject: " .. gameObject:GetId() .. ": '" .. gameObject:GetName() .. "'"
end

-- Dynamic getters
function GameObject.__index( gameObject, key )
    if GameObject[ key ] ~= nil then
        return GameObject[ key ]
    end

    -- maybe the key is a script alias
    local path = Daneel.Config.scriptPaths[ key ]
    if path ~= nil then
        local behavior = gameObject:GetScriptedBehavior( path )
        if behavior ~= nil then
            rawset( gameObject, key, behavior )
            return behavior
        end
    end

    if type( key ) == "string" then
        -- or the name of a getter 
        local ucKey = string.ucfirst( key )
        if key ~= ucKey then
            local funcName = "Get" .. ucKey
            
            -- on GameObject
            if GameObject[ funcName ] ~= nil then
                return GameObject[ funcName ]( gameObject )
            end

            if Daneel.Config.allowDynamicComponentFunctionCallOnGameObject then
                -- on a component
                for propName, propValue in pairs( gameObject ) do
                    if type( propValue ) == "table" then
                        local componentObject = getmetatable( propValue )
                        if componentObject ~= nil and table.containsvalue( Daneel.Config.componentObjects, componentObject ) then
                            -- could also check propName, which is the component name (Daneel.Config.componentObjects[ ucfirst( propName ) ] ~= nil)
                            -- propValue is a component instance
                            if componentObject[ funcName ] ~= nil then
                                return componentObject[ funcName ]( propValue )
                            end
                        end
                    end
                end
            end
        end
    end

    return nil
end

-- Dynamic setters
function GameObject.__newindex( gameObject, key, value )
    local ucKey = key
    if type( key ) == "string" then
        ucKey = string.ucfirst( key )
    end
    if key ~= ucKey and key ~= "transform" then -- first letter lowercase
        -- check about Transform is needed because CraftStudio.CreateGameObject() set the transfom variable on new game objects
        -- 26/09/2013 And so what ? If SetTransform() doesn't exist, it's not an issue
        local funcName = "Set" .. ucKey
        -- ie: variable "name" call "SetName"
        if GameObject[ funcName ] ~= nil then
            return GameObject[ funcName ]( gameObject, value )
        end

        if Daneel.Config.allowDynamicComponentFunctionCallOnGameObject then
            -- key could be a setter on a component
            for propName, propValue in pairs( gameObject ) do
                if type( propValue ) == "table" then
                    local componentObject = getmetatable( propValue )
                    if componentObject ~= nil and table.containsvalue( Daneel.Config.componentObjects, componentObject ) then
                        -- propValue is a component instance
                        if componentObject[ funcName ] ~= nil then
                            return componentObject[ funcName ]( propValue, value )
                        end
                    end
                end
            end
        end
    end
    rawset( gameObject, key, value )
end


----------------------------------------------------------------------------------

--- Create a new game object and optionally initialize it.
-- When the first argument is a scene name or asset, the scene may contains only one top-level game object.
-- If it's not the case, the function won't return any game object yet some may have been created (depending on the behavior of CS.AppendScene()).
-- @param name (string or Scene) The game object name or scene name or scene asset.
-- @param params (table) [optional] A table with parameters to initialize the new game object with.
-- @return (GameObject) The new game object.
function GameObject.New( name, params )
    Daneel.Debug.StackTrace.BeginFunction( "GameObject.New", name, params )
    local errorHead = "GameObject.New( name[, params] ) : "
    local argType = Daneel.Debug.CheckArgType( name, "name", {"string", "Scene"}, errorHead )
    Daneel.Debug.CheckOptionalArgType( params, "params", "table", errorHead )
    
    local gameObject = nil
    local scene = Asset.Get( name, "Scene" ) -- scene will be nil if name is a sting ad not a scene path
    if scene ~= nil then
        gameObject = CraftStudio.AppendScene( scene )
    else
        gameObject = CraftStudio.CreateGameObject( name )
    end

    if params ~= nil and gameObject ~= nil then
        gameObject:Set(params)
    end
    Daneel.Debug.StackTrace.EndFunction()
    return gameObject
end

--- Create a new game object with the content of the provided scene and optionally initialize it.
-- @param gameObjectName (string) The game object name.
-- @param sceneNameOrAsset (string or Scene) The scene name or scene asset.
-- @param params [optional] (table) A table with parameters to initialize the new game object with.
-- @return (GameObject) The new game object.
function GameObject.Instantiate(gameObjectName, sceneNameOrAsset, params)
    Daneel.Debug.StackTrace.BeginFunction("GameObject.Instantiate", gameObjectName, sceneNameOrAsset, params)
    local errorHead = "GameObject.Instantiate( gameObjectName, sceneNameOrAsset[, params] ) : "
    Daneel.Debug.CheckArgType(gameObjectName, "gameObjectName", "string", errorHead)
    Daneel.Debug.CheckArgType(sceneNameOrAsset, "sceneNameOrAsset", {"string", "Scene"}, errorHead)
    Daneel.Debug.CheckOptionalArgType(params, "params", "table", errorHead)

    local scene = Asset.Get(sceneNameOrAsset, "Scene", true)
    local gameObject = CraftStudio.Instantiate(gameObjectName, scene)
    if params ~= nil then
        gameObject:Set( params )
    end
    Daneel.Debug.StackTrace.EndFunction()
    return gameObject
end

--- Apply the content of the params argument to the provided game object.
-- @param gameObject (GameObject) The game object.
-- @param params (table) A table of parameters to set the game object with.
function GameObject.Set( gameObject, params )
    Daneel.Debug.StackTrace.BeginFunction( "GameObject.Set", gameObject, params )
    local errorHead = "GameObject.Set( gameObject, params ) : "
    Daneel.Debug.CheckArgType( gameObject, "gameObject", "GameObject", errorHead )
    Daneel.Debug.CheckArgType( params, "params", "table", errorHead )
    local argType = nil
    
    if params.parent ~= nil then
        -- do that first so that setting a local position works
        gameObject:SetParent( params.parent )
        params.parent = nil
    end

    if params.transform ~= nil then
        gameObject.transform:Set( params.transform )
        params.transform = nil
    end
    
    -- components
    for i, componentType in pairs( Daneel.Config.componentTypes ) do
        local component = nil

        if componentType ~= "ScriptedBehavior" then
            componentType = componentType:lower()

            -- check if params has a key for that component
            local componentParams = nil
            for key, value in pairs( params ) do
                if key:lower() == componentType then
                    componentParams = value
                    Daneel.Debug.CheckArgType( componentParams, "params."..key, "table", errorHead )
                    break
                end
            end

            if componentParams ~= nil then
                -- check if gameObject has a key for that component
                for key, value in pairs( gameObject ) do
                    if key:lower() == componentType then
                        component = value
                        break
                    end
                end
                
                if component == nil then -- can work for built-in components when their property on the game object has been unset for some reason
                    component = gameObject:GetComponent( componentType )
                end
                
                if component == nil then
                    component = gameObject:AddComponent( componentType )
                end

                component:Set( componentParams )
                table.removevalue( params, componentParams )
            end
        end
    end

    -- all other keys/values
    for key, value in pairs( params ) do

        -- if key is a script alias or a script path
        if Daneel.Config.scriptPaths[key] ~= nil or table.containsvalue( Daneel.Config.scriptPaths, key ) then
            local scriptPath = key
            if Daneel.Config.scriptPaths[key] ~= nil then
                scriptPath = Daneel.Config.scriptPaths[key]
            end

            local component = gameObject:GetScriptedBehavior( scriptPath )
            if component == nil then
                component = gameObject:AddComponent( scriptPath )
            end
            
            component:Set(value)

        elseif key == "tags"  then
            gameObject:RemoveTag()
            gameObject:AddTag( value )

        else
            gameObject[key] = value
        end
    end
    Daneel.Debug.StackTrace.EndFunction()
end


----------------------------------------------------------------------------------
-- Miscellaneous

--- Alias of CraftStudio.FindGameObject(name).
-- Get the first game object with the provided name.
-- @param name (string) The game object name.
-- @param errorIfGameObjectNotFound [optional default=false] (boolean) Throw an error if the game object was not found (instead of returning nil).
-- @return (GameObject) The game object or nil if none is found.
function GameObject.Get( name, errorIfGameObjectNotFound ) 
    if getmetatable(name) == GameObject then
        return name
    end

    Daneel.Debug.StackTrace.BeginFunction( "GameObject.Get", name, errorIfGameObjectNotFound )
    local errorHead = "GameObject.Get( name[, errorIfGameObjectNotFound] ) : "
    Daneel.Debug.CheckArgType( name, "name", "string", errorHead )
    Daneel.Debug.CheckOptionalArgType( errorIfGameObjectNotFound, "errorIfGameObjectNotFound", "boolean", errorHead )
    

    local gameObject = nil
    local names = string.split( name, "." )
    
    gameObject = CraftStudio.FindGameObject( names[1] )
    if gameObject == nil and errorIfGameObjectNotFound == true then
        error( errorHead.."GameObject with name '" .. names[1] .. "' (from '" .. name .. "') was not found." )
    end

    if gameObject ~= nil then
        local originalName = name
        local fullName = table.remove( names, 1 )

        for i, name in ipairs( names ) do
            gameObject = gameObject:GetChild( name )
            fullName = fullName .. "." .. name

            if gameObject == nil then
                if errorIfGameObjectNotFound == true then
                    error( errorHead.."GameObject with name '" .. fullName .. "' (from '" .. originalName .. "') was not found." )
                end

                break
            end
        end
    end

    Daneel.Debug.StackTrace.EndFunction()
    return gameObject
end

--- Returns the game object's internal unique identifier.
-- @param gameObject (GameObject) The game object.
-- @return (number) The id.
function GameObject.GetId( gameObject )
    return Daneel.Cache.GetId( gameObject )
end

local OriginalSetParent = GameObject.SetParent

--- Set the game object's parent. 
-- Optionaly carry over the game object's local transform instead of the global one.
-- @param gameObject (GameObject) The game object.
-- @param parentNameOrInstance [optional] (string or GameObject) The parent name or game object (or nil to remove the parent).
-- @param keepLocalTransform [optional default=false] (boolean) Carry over the game object's local transform instead of the global one.
function GameObject.SetParent(gameObject, parentNameOrInstance, keepLocalTransform)
    Daneel.Debug.StackTrace.BeginFunction("GameObject.SetParent", gameObject, parentNameOrInstance, keepLocalTransform)
    local errorHead = "GameObject.SetParent(gameObject, [parentNameOrInstance, keepLocalTransform]) : "
    Daneel.Debug.CheckArgType(gameObject, "gameObject", "GameObject", errorHead)
    Daneel.Debug.CheckOptionalArgType(parentNameOrInstance, "parentNameOrInstance", {"string", "GameObject"}, errorHead)
    keepLocalTransform = Daneel.Debug.CheckOptionalArgType(keepLocalTransform, "keepLocalTransform", "boolean", errorHead, false)

    local parent = nil
    if parentNameOrInstance ~= nil then
        parent = GameObject.Get(parentNameOrInstance, true)
    end
    OriginalSetParent(gameObject, parent, keepLocalTransform)
    Daneel.Debug.StackTrace.EndFunction()
end

--- Alias of GameObject.FindChild().
-- Find the first game object's child with the provided name.
-- If the name is not provided, it returns the first child.
-- @param gameObject (GameObject) The game object.
-- @param name [optional] (string) The child name (may be hyerarchy of names separated by dots).
-- @param recursive [optional default=false] (boolean) Search for the child in all descendants instead of just the first generation.
-- @return (GameObject) The child or nil if none is found.
function GameObject.GetChild( gameObject, name, recursive )
    Daneel.Debug.StackTrace.BeginFunction( "GameObject.GetChild", gameObject, name, recursive )
    local errorHead = "GameObject.GetChild( gameObject, name[, recursive] ) : "
    Daneel.Debug.CheckArgType( gameObject, "gameObject", "GameObject", errorHead )
    Daneel.Debug.CheckOptionalArgType( name, "name", "string", errorHead )
    recursive = Daneel.Debug.CheckOptionalArgType( recursive, "recursive", "boolean", errorHead, false )
    
    local child = nil
    if name == nil then
        local children = gameObject:GetChildren()
        child = children[1]
    else
        local names = string.split( name, "." )
        for i, name in ipairs( names ) do
            gameObject = gameObject:FindChild( name, recursive )

            if gameObject == nil then
                break
            end
        end
        child = gameObject
    end
    Daneel.Debug.StackTrace.EndFunction()
    return child
end

local OriginalGetChildren = GameObject.GetChildren

--- Get all descendants of the game object.
-- @param gameObject (GameObject) The game object.
-- @param recursive [optional default=false] (boolean) Look for all descendants instead of just the first generation.
-- @param includeSelf [optional default=false] (boolean) Include the game object in the children.
-- @return (table) The children.
function GameObject.GetChildren( gameObject, recursive, includeSelf )
    Daneel.Debug.StackTrace.BeginFunction( "GameObject.GetChildren", gameObject, recursive, includeSelf )
    local errorHead = "GameObject.GetChildren( gameObject[, recursive, includeSelf] ) : "
    Daneel.Debug.CheckArgType( gameObject, "gameObject", "GameObject", errorHead )
    Daneel.Debug.CheckOptionalArgType( recursive, "recursive", "boolean", errorHead )
    Daneel.Debug.CheckOptionalArgType( includeSelf, "includeSelf", "boolean", errorHead )

    local allChildren = OriginalGetChildren( gameObject )

    if recursive then
        for i, child in ipairs( table.copy( allChildren ) ) do
            allChildren = table.merge( allChildren, child:GetChildren( true ) )
        end
    end

    if includeSelf then
        table.insert( allChildren, 1, gameObject )
    end
    Daneel.Debug.StackTrace.EndFunction()
    return allChildren
end

local OriginalSendMessage = GameObject.SendMessage

--- Tries to call a method with the provided name on all the scriptedBehaviors attached to the game object. 
-- The data argument can be nil or a table you want the method to receive as its first (and only) argument.
-- If none of the scripteBehaviors attached to the game object or its children have a method matching the provided name, nothing happens. 
-- @param gameObject (GameObject) The game object.
-- @param functionName (string) The method name.
-- @param data [optional] (table) The data to pass along the method call.
function GameObject.SendMessage(gameObject, functionName, data)
    Daneel.Debug.StackTrace.BeginFunction("GameObject.SendMessage", gameObject, functionName, data)
    local errorHead = "GameObject.SendMessage(gameObject, functionName[, data]) : "
    Daneel.Debug.CheckArgType(gameObject, "gameObject", "GameObject", errorHead)
    Daneel.Debug.CheckArgType(functionName, "functionName", "string", errorHead)
    Daneel.Debug.CheckOptionalArgType(data, "data", "table", errorHead)
    
    if Daneel.Config.debug.enableDebug then
        -- prevent an error of type "La référence d'objet n'est pas définie à une instance d'un objet." to stops the script that sends the message
        local success = Daneel.Debug.Try( function()
            OriginalSendMessage( gameObject, functionName, data )
        end )

        if not success then
            local dataText = "No data"
            local length = 0
            if data ~= nil then
                length = table.getlength( data )
                dataText = "Data with "..length.." entries"
            end
            print( errorHead.."Error sending message with parameters : ", gameObject, functionName, dataText )
            if length > 0 then
                table.print( data )
            end
        end
    else
        OriginalSendMessage( gameObject, functionName, data )
    end

    Daneel.Debug.StackTrace.EndFunction()
end

--- Tries to call a method with the provided name on all the scriptedBehaviors attached to the game object or any of its descendants. 
-- The data argument can be nil or a table you want the method to receive as its first (and only) argument.
-- If none of the scripteBehaviors attached to the game object or its children have a method matching the provided name, nothing happens. 
-- @param gameObject (GameObject) The game object.
-- @param functionName (string) The method name.
-- @param data [optional] (table) The data to pass along the method call.
function GameObject.BroadcastMessage(gameObject, functionName, data)
    Daneel.Debug.StackTrace.BeginFunction("GameObject.BroadcastMessage", gameObject, functionName, data)
    local errorHead = "GameObject.BroadcastMessage(gameObject, functionName[, data]) : "
    Daneel.Debug.CheckArgType(gameObject, "gameObject", "GameObject", errorHead)
    Daneel.Debug.CheckArgType(functionName, "functionName", "string", errorHead)
    Daneel.Debug.CheckOptionalArgType(data, "data", "table", errorHead)
    
    local allGos = gameObject:GetChildren(true, true) -- the game object + all of its children
    for i, go in ipairs(allGos) do
        go:SendMessage(functionName, data)
    end
    Daneel.Debug.StackTrace.EndFunction()
end


----------------------------------------------------------------------------------
-- Add components

--- Add a component to the game object and optionally initialize it.
-- @param gameObject (GameObject) The game object.
-- @param componentType (string or Script) The component type, or script asset, path or alias (can't be Transform or ScriptedBehavior).
-- @param params [optional] (string, Script or table) A table of parameters to initialize the new component with or, if componentType is 'ScriptedBehavior', the mandatory script name or asset.
-- @return (mixed) The component.
function GameObject.AddComponent( gameObject, componentType, params )
    Daneel.Debug.StackTrace.BeginFunction( "GameObject.AddComponent", gameObject, componentType, params )
    local errorHead = "GameObject.AddComponent( gameObject, componentType[, params] ) : "
    Daneel.Debug.CheckArgType( gameObject, "gameObject", "GameObject", errorHead )
    Daneel.Debug.CheckArgType( componentType, "componentType", {"string", "Script"}, errorHead )
    componentType = Daneel.Debug.CheckArgValue( componentType, "componentType", Daneel.Config.componentTypes, errorHead, componentType )
    Daneel.Debug.CheckOptionalArgType( params, "params", "table", errorHead )    

    local component = nil
    
    if Daneel.Config.componentObjects[ componentType ] == nil then
        -- componentType is not one of the component types
        -- it may be a script path, alias or asset
        local script = Asset.Get( componentType, "Script" )
        if script == nil then
            if Daneel.Config.debug.enableDebug then
                error( errorHead.."Provided component type '"..tostring(componentType).."' in not one of the component types, nor a script asset, path or alias." )
            end
            Daneel.Debug.StackTrace.EndFunction()
            return
        end

        if params == nil then
            params = {}
        end
        component = gameObject:CreateScriptedBehavior( script, params )
        params = nil
    
    elseif Daneel.DefaultConfig().componentObjects[ componentType ] ~= nil then
        -- built-in component type
        if componentType == "Transform" then
            if Daneel.Config.debug.enableDebug then
                print( errorHead.."Can't add a transform component because gameObjects may only have one transform." )
            end
            Daneel.Debug.StackTrace.EndFunction()
            return
        elseif componentType == "ScriptedBehavior" then
            if Daneel.Config.debug.enableDebug then
                print( errorHead.."To add a scripted behavior, pass the script asset, path or alias instead of 'ScriptedBehavior' as argument 'componentType'." )
            end
            Daneel.Debug.StackTrace.EndFunction()
            return
        end

        component = gameObject:CreateComponent( componentType )

        local defaultComponentParams = Daneel.Config[ string.lcfirst( componentType ) ]
        if defaultComponentParams ~= nil then
            params = table.merge( defaultComponentParams, params )
        end

    else
        -- custom component type
        local componentObject = Daneel.Config.componentObjects[ componentType ]

        if componentObject ~= nil and type( componentObject.New ) == "function" then
            component = componentObject.New( gameObject )
        else
            if Daneel.Config.debug.enableDebug then
                error( errorHead.."Custom component of type '"..componentType.."' does not provide a New() function; Can't create the component." )
            end
            Daneel.Debug.StackTrace.EndFunction()
            return
        end
    end
    
    if params ~= nil and component ~= nil then
        component:Set( params )
    end

    Daneel.Event.Fire( gameObject, "OnNewComponent", component )
    Daneel.Debug.StackTrace.EndFunction()
    return component
end


----------------------------------------------------------------------------------
-- Get components

local OriginalGetComponent = GameObject.GetComponent
local OriginalGetScriptedBehavior = GameObject.GetScriptedBehavior

--- Get the first component of the provided type attached to the game object.
-- @param gameObject (GameObject) The game object.
-- @param componentType (string or Script) The component type, or script asset, path or alias.
-- @return (One of the component types) The component instance, or nil if none is found.
function GameObject.GetComponent( gameObject, componentType )
    Daneel.Debug.StackTrace.BeginFunction( "GameObject.GetComponent", gameObject, componentType )
    local errorHead = "GameObject.GetComponent( gameObject, componentType ) : "
    Daneel.Debug.CheckArgType( gameObject, "gameObject", "GameObject", errorHead )
    local argType = Daneel.Debug.CheckArgType( componentType, "componentType", {"string", "Script"}, errorHead )
    componentType = Daneel.Debug.CheckArgValue( componentType, "componentType", Daneel.Config.componentTypes, errorHead, componentType )
    
    local lcComponentType = componentType
    if argType == "string" then
        lcComponentType = string.lcfirst( componentType )
    end
    local component = nil
    if lcComponentType ~= "scriptedBehavior" then
        component = gameObject[ lcComponentType ]
    end
    
    if component == nil then
        if Daneel.DefaultConfig().componentObjects[ componentType ] ~= nil then
            component = OriginalGetComponent( gameObject, componentType )
        elseif Daneel.Config.componentObjects[ componentType ] == nil then -- not a custom component either
            local script = Asset.Get( componentType, "Script", true ) -- componentType is the script path or asset
            component = OriginalGetScriptedBehavior( gameObject, script )
        end
    end

    Daneel.Debug.StackTrace.EndFunction()
    return component
end

--- Get the provided scripted behavior instance attached to the game object.
-- @param gameObject (GameObject) The game object.
-- @param scriptNameOrAsset (string or Script) The script name or asset.
-- @return (ScriptedBehavior) The ScriptedBehavior instance.
function GameObject.GetScriptedBehavior( gameObject, scriptNameOrAsset )
    Daneel.Debug.StackTrace.BeginFunction( "GameObject.GetScriptedBehavior", gameObject, scriptNameOrAsset )
    local errorHead = "GameObject.GetScriptedBehavior( gameObject, scriptNameOrAsset ) : "
    Daneel.Debug.CheckArgType( gameObject, "gameObject", "GameObject", errorHead )
    Daneel.Debug.CheckArgType( scriptNameOrAsset, "scriptNameOrAsset", {"string", "Script"}, errorHead )

    local script = Asset.Get( scriptNameOrAsset, "Script", true )
    local component = OriginalGetScriptedBehavior( gameObject, script )
    Daneel.Debug.StackTrace.EndFunction()
    return component
end


----------------------------------------------------------------------------------
-- Destroy game object

--- Destroy the game object at the end of this frame.
-- @param gameObject (GameObject) The game object.
function GameObject.Destroy( gameObject )
    Daneel.Debug.StackTrace.BeginFunction( "GameObject.Destroy", gameObject )
    local errorHead = "GameObject.Destroy( gameObject ) : "
    Daneel.Debug.CheckArgType( gameObject, "gameObject", "GameObject", errorHead )

    for i, go in pairs( gameObject:GetChildren( true, true ) ) do -- recursive, include self
        go:RemoveTag()
    end

    for key, value in pairs( gameObject ) do
        if key ~= "inner" and type( value ) == "table" then -- in the Webplayer inner is a regular object, considered of type table and not userdata
            Daneel.Event.Fire( value, "OnDestroy", value )
        end
    end

    CraftStudio.Destroy( gameObject )
    Daneel.Debug.StackTrace.EndFunction()
end


----------------------------------------------------------------------------------
-- Tags

GameObject.Tags = {}
-- GameObject.Tags is emptied in Daneel:Awake()

--- Returns the game object(s) that have all the provided tag(s).
-- @param tag (string or table) One or several tag(s) (as a string or table of strings).
-- @return (table) The game object(s) (empty if none is found).
function GameObject.GetWithTag( tag )
    Daneel.Debug.StackTrace.BeginFunction( "GameObject.GetWithTag", tag )
    local errorHead = "GameObject.GetWithTag( tag ) : "
    local argType = Daneel.Debug.CheckArgType( tag, "tag", {"string", "table"}, errorHead )

    local tags = tag
    if argType == "string" then
        tags = { tags }
    end

    local gameObjectsWithTag = {}
    local reindex = false

    for i, tag in pairs( tags ) do
        local gameObjects = GameObject.Tags[ tag ]
        if gameObjects ~= nil then
            for j, gameObject in pairs( gameObjects ) do
                if gameObject.inner ~= nil then
                    if gameObject:HasTag( tags ) and not table.containsvalue( gameObjectsWithTag, gameObject ) then
                        table.insert( gameObjectsWithTag, gameObject )
                    end
                else
                    gameObjects[ j ] = nil
                    reindex = true
                end
            end
            if reindex then
                GameObject.Tags[ tag ] = table.reindex( gameObjects )
                reindex = false
            end
        end
    end

    Daneel.Debug.StackTrace.EndFunction()
    return gameObjectsWithTag
end

--- Returns the tag(s) of the provided game object.
-- @param gameObject (GameObject) The game object.
-- @return (table) The tag(s) (empty if the game object has no tag).
function GameObject.GetTags( gameObject )
    Daneel.Debug.StackTrace.BeginFunction( "GameObject.GetTags", gameObject )
    local errorHead = "GameObject.GetTags( gameObject ) : "
    Daneel.Debug.CheckArgType( gameObject, "gameObject", "GameObject", errorHead )

    local tags = {}

    for tag, gameObjects in pairs( GameObject.Tags ) do
        if table.containsvalue( gameObjects, gameObject ) then
            table.insert( tags, tag )
        end
    end

    Daneel.Debug.StackTrace.EndFunction()
    return tags
end

--- Add the provided tag(s) to the provided game object.
-- @param gameObject (GameObject) The game object.
-- @param tag (string or table) One or several tag(s) (as a string or table of strings).
function GameObject.AddTag( gameObject, tag )
    Daneel.Debug.StackTrace.BeginFunction( "GameObject.AddTag", gameObject, tag )
    local errorHead = "GameObject.AddTag( gameObject, tag ) : "
    Daneel.Debug.CheckArgType( gameObject, "gameObject", "GameObject", errorHead )
    Daneel.Debug.CheckArgType( tag, "tag", {"string", "table"}, errorHead )
    
    local tags = tag
    if type( tags ) == "string" then
        tags = { tags }
    end

    for i, tag in pairs( tags ) do
        if GameObject.Tags[ tag ] == nil then
            GameObject.Tags[ tag ] = { gameObject }
        elseif not table.containsvalue( GameObject.Tags[ tag ], gameObject ) then
            table.insert( GameObject.Tags[ tag ], gameObject )
        end
    end

    Daneel.Debug.StackTrace.EndFunction()
end

--- Remove the provided tag(s) from the provided game object.
-- If the 'tag' argument is not provided, all tag of the game object will be removed.
-- @param gameObject (GameObject) The game object.
-- @param tag [optional] (string or table) One or several tag(s) (as a string or table of strings).
function GameObject.RemoveTag( gameObject, tag )
    Daneel.Debug.StackTrace.BeginFunction( "GameObject.RemoveTag", gameObject, tag )
    local errorHead = "GameObject.RemoveTag( gameObject[, tag] ) : "
    Daneel.Debug.CheckArgType( gameObject, "gameObject", "GameObject", errorHead )
    Daneel.Debug.CheckOptionalArgType( tag, "tag", {"string", "table"}, errorHead )
    
    local tags = tag
    if type( tags ) == "string" then
        tags = { tags }
    end

    for tag, gameObjects in pairs( GameObject.Tags ) do
        if tags == nil or table.containsvalue( tags, tag ) then
            table.removevalue( GameObject.Tags[ tag ], gameObject )
        end
    end
    Daneel.Debug.StackTrace.EndFunction()
end

--- Tell whether the provided game object has all (or at least one of) the provided tag(s).
-- @param gameObject (GameObject) The game object.
-- @param tag (string or table) One or several tag (as a string or table of strings).
-- @param atLeastOneTag [default=false] (boolean) If true, returns true if the game object has AT LEAST one of the tag (instead of ALL the tag).
-- @return (boolean) True
function GameObject.HasTag( gameObject, tag, atLeastOneTag )
    Daneel.Debug.StackTrace.BeginFunction( "GameObject.HasTag", gameObject, tag, atLeastOneTag )
    local errorHead = "GameObject.HasTag( gameObject, tag ) : "
    Daneel.Debug.CheckArgType( gameObject, "gameObject", "GameObject", errorHead )
    Daneel.Debug.CheckArgType( tag, "tag", {"string", "table"}, errorHead )
    Daneel.Debug.CheckOptionalArgType( atLeastOneTag, "atLeastOneTag", "boolean", errorHead )

    local tags = tag
    if type(tags) == "string" then
        tags = { tags }
    end
    local hasTags = false
    if atLeastOneTag == true then
        for i, tag in pairs( tags ) do
            if GameObject.Tags[ tag ] ~= nil and table.containsvalue( GameObject.Tags[ tag ], gameObject ) then
                hasTags = true
                break
            end
        end
    else
        hasTags = true
        for i, tag in pairs( tags ) do
            if GameObject.Tags[ tag ] == nil or not table.containsvalue( GameObject.Tags[ tag ], gameObject ) then
                hasTags = false
                break
            end
        end
    end

    Daneel.Debug.StackTrace.EndFunction()
    return hasTags
end
