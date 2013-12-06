-- Lang.lua
-- Update the TextRenderer or GUI.TextArea component on the game object with the localized string whose key is provided.
-- Allow to register the game object for the localized text to be updated when the language changes.
--
-- Last modified for v1.3
-- Copyright © 2013 Florent POUJOL, published under the MIT license.

Lang = {
    lines = {},
    gameObjectsToUpdate = {},
    cache = {},
    doNotCallUpdate = true -- tell Daneel not to call Update() when the module is loaded
}

if CS.DaneelModules == nil then
    CS.DaneelModules = {}
end
CS.DaneelModules[ "Lang" ] = Lang

function Lang.DefaultConfig()
    return {
        default = nil, -- Default language
        current = nil, -- Current language
        searchInDefault = true, -- Tell whether Lang.Get() search a line key in the default language 
        -- when it is not found in the current language before returning the value of keyNotFound
        keyNotFound = "langkeynotfound", -- Value returned when a language key is not found
    }
end

function Lang.Load()
    local defaultLanguage = nil

    for key, value in pairs( _G ) do
        if key:find( "^Lang%u" ) ~= nil and type( value ) == "function" then
            local language = (key:gsub( "Lang", "" ))
            local language = language:lower()
            if language ~= "userconfig" then
                Lang.lines[ language ] = value()

                if defaultLanguage == nil then
                    defaultLanguage = language
                end
            end
        end
    end

    if defaultLanguage == nil then -- no language function found
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


----------------------------------------------------------------------------------

--- Get the localized line identified by the provided key.
-- @param key (string) The language key.
-- @param replacements (table) [optional] The placeholders and their replacements.
-- @return (string) The line.
function Lang.Get( key, replacements )
    if replacements == nil and Lang.cache[ key ] ~= nil then
        return Lang.cache[ key ]
    end

    if not Daneel.isLoaded then -- 17/10  was Daneel.isAwake. Any reason ?
        Daneel.LateLoad( "Lang.Get" )
    end

    Daneel.Debug.StackTrace.BeginFunction( "Lang.Get", key, replacements )
    local errorHead = "Lang.Get( key[, replacements] ) : "
    Daneel.Debug.CheckArgType( key, "key", "string", errorHead )

    local currentLanguage = Lang.Config.current
    local defaultLanguage = Lang.Config.default
    local searchInDefault = Lang.Config.searchInDefault
    local cache = true

    local keys = string.split( key, "." )
    local language = currentLanguage
    if Lang.lines[ keys[1]:lower() ] then
        language = table.remove( keys, 1 )
        language = language:lower()
    end
    
    local noLangKey = table.concat( keys, "." ) -- rebuilt the key, but without the language
    local fullKey = language .. "." .. noLangKey 
    if replacements == nil and Lang.cache[ fullKey ] ~= nil then
        Daneel.Debug.StackTrace.EndFunction()
        return Lang.cache[ fullKey ]
    end

    local lines = Lang.lines[ language ]
    if lines == nil then
        error( errorHead.."Language '"..language.."' does not exists" )
    end

    for i, _key in ipairs(keys) do
        if lines[_key] == nil then
            -- key was not found
            -- search for it in the default language
            if language ~= defaultLanguage and searchInDefault == true then
                cache = false
                lines = Lang.Get( defaultLanguage.."."..noLangKey, replacements )
            else -- already default language or don't want to search in
                lines = Lang.Config.keyNotFound
            end

            break
        end
        lines = lines[ _key ]
    end

    -- lines should be the searched string by now
    local line = lines
    if type( line ) ~= "string" then
        error( errorHead.."Localization key '"..key.."' does not lead to a string but to : '"..tostring(line).."'." )
    end

    -- process replacements
    if replacements ~= nil then
        line = Daneel.Utilities.ReplaceInString( line, replacements )
    elseif cache and line ~= Lang.Config.keyNotFound then
        Lang.cache[ key ] = line -- ie: "greetings.welcome"
        Lang.cache[ fullKey ] = line -- ie: "english.greetings.welcome"
    end

    Daneel.Debug.StackTrace.EndFunction()
    return line
end

--- Register a game object to update its text renderer whenever the language will be updated by Lang.Update().
-- @param gameObject (GameObject) The gameObject.
-- @param key (string) The language key.
-- @param replacements (table) [optional] The placeholders and their replacements (has no effect when the 'key' argument is a function).
function Lang.RegisterForUpdate( gameObject, key, replacements )
    Daneel.Debug.StackTrace.BeginFunction( "Lang.RegisterForUpdate", gameObject, key, replacements )
    local errorHead = "Lang.RegisterForUpdate( gameObject, key[, replacements] ) : "
    Daneel.Debug.CheckArgType( gameObject, "gameObject", "GameObject", errorHead )
    Daneel.Debug.CheckArgType( key, "key", "string", errorHead)
    Daneel.Debug.CheckOptionalArgType( replacements, "replacements", "table", errorHead )

    Lang.gameObjectsToUpdate[gameObject] = {
        key = key,
        replacements = replacements,
    }
    Daneel.Debug.StackTrace.EndFunction()
end

--- Update the current language and the text of all game objects that have registered via Lang.RegisterForUpdate().
-- Updates the text renderer or text area component.
-- Fire the OnLangUpdate event.
-- @param language (string) The new current language.
function Lang.Update( language )
    if not Daneel.isLoaded then
        Daneel.LateLoad(  "Lang.update" )
    end

    Daneel.Debug.StackTrace.BeginFunction( "Lang.Update", language )
    local errorHead = "Lang.Update( language ) : "
    Daneel.Debug.CheckArgType( language, "language", "string", errorHead )
    language = Daneel.Debug.CheckArgValue( language, "language", table.getkeys( Lang.lines ), errorHead )
    
    Lang.cache = {} -- ideally only the items that do not begins by a language name should be deleted
    Lang.Config.current = language
    for gameObject, data in pairs( Lang.gameObjectsToUpdate ) do
        if gameObject.inner == nil then
            Lang.gameObjectsToUpdate[ gameObject ] = nil
        else
            local text = Lang.Get( data.key, data.replacements )
            
            if gameObject.textArea ~= nil then
                gameObject.textArea:SetText( text )
            elseif gameObject.textRenderer ~= nil then
                gameObject.textRenderer:SetText( text )
            
            elseif Daneel.Config.debug.enableDebug then
                print( "WARNING : " .. errorHead .. tostring( gameObject ) .. " does not have a TextRenderer or GUI.TextArea component." )
            end
        end
    end

    Daneel.Event.Fire( "OnLangUpdate" )
    Daneel.Debug.StackTrace.EndFunction()
end


----------------------------------------------------------------------------------
-- runtime

--[[PublicProperties
key string ""
registerForUpdate boolean false
/PublicProperties]]

function Behavior:Awake()
    if not Daneel.isLoaded then
        Daneel.LateLoad(  "Lang:Awake" )
    end
end

function Behavior:Start()
    if string.trim( self.key ) ~= "" then
        if self.gameObject.textArea ~= nil then
            self.gameObject.textArea:SetText( Lang.Get( self.key ) )
        elseif self.gameObject.textRenderer ~= nil then
            self.gameObject.textRenderer:SetText( Lang.Get( self.key ) )
        end

        if self.registerForUpdate then
            Lang.RegisterForUpdate( self.gameObject, self.key )
        end
    end
end
