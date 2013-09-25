-- Lang.lua
-- Update the TextRenderer or TextArea component on the game object with the localized string whose key is provided.
-- Allow to register the game object for the localized text to be updated when the language changes.
--
-- Since v1.2.1
-- Last modified for v1.2.1
-- Copyright © 2013 Florent POUJOL, published under the MIT licence.


Lang = { lines = {}, gameObjectsToUpdate = {}, cache = {} }

if CS.DaneelModules == nil then
    CS.DaneelModules = {}
end
CS.DaneelModules[ "Lang" ] = {}

function Lang.Config()
    return {
        languageNames = {}, -- list of the languages supported by the game
        
        current = nil, -- Current language
        default = nil, -- Default language
        searchInDefault = true, -- Tell wether Lang.Get() search a line key in the default language 
        -- when it is not found in the current language before returning the value of keyNotFound
        keyNotFound = "langkeynotfound", -- Value returned when a language key is not found
    }
end

function Lang.Load()
    for i, language in ipairs( Lang.Config.languageNames ) do
        local functionName = "Lang" .. language:ucfirst()

        if Daneel.Utilities.GlobalExists( functionName ) then
            Lang.lines[language] = _G[ functionName ]()
        elseif Daneel.Config.debug.enableDebug then
            print( "lang.Load() : WARNING : Can't load the language '"..language.."' because the global function "..functionName.."() does not exists." )
        end
    end

    if Lang.Config.default == nil then
        Lang.Config.default = Lang.Config.languageNames[1]
    end

    if Lang.Config.current == nil then
        Lang.Config.current = Lang.Config.default
    end

    Lang.Update2 = Lang.Update
    Lang.Update = nil
end

function Lang.Awake()
    if Lang.Update == nil and Lang.Update2 ~= nil then
        Lang.Update = Lang.Update2
    end

    Lang.gameObjectsToUpdate = {}
end

-- Lang.Start runs before every other Behavior:Start() function of the scene
function Lang.Start()
    if Lang.Config.current ~= nil then
        Lang.Update( Lang.Config.current )
    end
end


----------------------------------------------------------------------------------

--- Get the localized line identified by the provided key.
-- @param key (string) The language key.
-- @param replacements [optional] (table) The placeholders and their replacements.
-- @return (string) The line.
function Lang.Get( key, replacements )
    if replacements == nil and Lang.cache[ key ] ~= nil then
        Daneel.Debug.StackTrace.EndFunction()
        return Lang.cache[ key ]
    end

    Daneel.Debug.StackTrace.BeginFunction( "Lang.Get", key, replacements )
    local errorHead = "Lang.Get( key[, replacements] ) : "
    Daneel.Debug.CheckArgType( key, "key", "string", errorHead )
    local currentLanguage = Lang.Config.current
    local defaultLanguage = Lang.Config.default
    local searchInDefault = Lang.Config.searchInDefault

    local keys = key:split( "." )
    local language = currentLanguage
    if table.containsvalue( Lang.Config.languageNames, keys[1] ) then
        language = table.remove( keys, 1 )
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
            if Daneel.Config.debug.enableDebug then
                print( errorHead.."Localization key '"..key.."' was not found in '"..language.."' language ." )
            end

            -- search for it in the default language
            if language ~= defaultLanguage and searchInDefault == true then  
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
    else
        Lang.cache[ key ] = line -- ie: "greetings.welcome"
        Lang.cache[ fullKey ] = line -- ie: "english.greetings.welcome"
    end

    Daneel.Debug.StackTrace.EndFunction()
    return line
end

--- Register a gameObject to update its TextRenderer whenever the language will be updated by Lang.Update().
-- @param gameObject (GameObject) The gameObject.
-- @param key (string) The language key.
-- @param replacements [optional] (table) The placeholders and their replacements (has no effect when the 'key' argument is a function).
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

--- Update the current language and the text of all gameObjects that have registered via Lang.RegisterForUpdate().
-- Updates the TextRenderer or GUI.TextArea component.
-- Fire the OnLangUpdate event.
-- @param language (string) The new current language.
function Lang.Update( language )
    Daneel.Debug.StackTrace.BeginFunction( "Lang.Update", language )
    local errorHead = "Lang.Update( language ) : "
    Daneel.Debug.CheckArgType( language, "language", "string", errorHead )
    language = Daneel.Debug.CheckArgValue( language, "language", Lang.Config.languageNames, errorHead )
    
    Lang.cache = {} -- ideally only the items that do not begins by a language name should be deleted
    Lang.Config.current = language
    for gameObject, data in pairs( Lang.gameObjectsToUpdate ) do
        local text = Lang.Get( data.key, data.replacements )
        
        if gameObject.textArea ~= nil then
            gameObject.textArea:SetText( text )
        elseif gameObject.textRenderer ~= nil then
            gameObject.textRenderer:SetText( text )
        
        elseif Daneel.Config.debug.enableDebug then
            print( "WARNING : " .. errorHead .. tostring( gameObject ) .. " does not have a TextRenderer or TextArea component." )
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

function Behavior:Start()
    if self.key:trim() ~= "" then
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
