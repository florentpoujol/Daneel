-- Lang.lua
-- Update the TextRenderer or TextArea component on the game object with the localized string whose key is provided.
-- Allow to register the game object for the localized text to be updated when the language changes.
--
-- Since v1.2.1
-- Last modified for v1.2.1
-- Copyright © 2013 Florent POUJOL, published under the MIT licence.


function DaneelConfigModuleLang()
    DaneelLang = Daneel.Lang

    return {
        languageNames = {}, -- list of the languages supported by the game
        
        current = nil, -- Current language
        default = nil, -- Default language
        searchInDefault = true, -- Tell wether Daneel.Lang.Get() search a line key in the default language 
        -- when it is not found in the current language before returning the value of keyNotFound
        keyNotFound = "langkeynotfound", -- Value returned when a language key is not found
    }
end

function DaneelLoadModuleLang()
    for i, language in ipairs( Daneel.Config.language.languageNames ) do
        local functionName = "DaneelLanguage"..language:ucfirst()

        if Daneel.Utilities.GlobalExists( functionName ) then
            Daneel.Lang.lines[language] = _G[ functionName ]()
        elseif Daneel.Config.debug.enableDebug == true then
            print( "DaneelLoadModuleLang() : WARNING : Can't load the language '"..language.."' because the global function "..functionName.."() does not exists." )
        end
    end

    if Daneel.Config.language.default == nil then
        Daneel.Config.language.default = Daneel.Config.language.languageNames[1]
    end

    if Daneel.Config.language.current == nil then
        Daneel.Config.language.current = Daneel.Config.language.default
    end
end


----------------------------------------------------------------------------------

DaneelLang = { lines = {}, gameObjectsToUpdate = {} }

--- Get the localized line identified by the provided key.
-- @param key (string) The language key.
-- @param replacements [optional] (table) The placeholders and their replacements.
-- @return (string) The line.
function DaneelLang.Get( key, replacements )
    if replacements == nil and Daneel.Cache.lang[ key ] ~= nil then
        Daneel.Debug.StackTrace.EndFunction()
        return Daneel.Cache.lang[ key ]
    end

    Daneel.Debug.StackTrace.BeginFunction( "Daneel.Lang.Get", key, replacements )
    local errorHead = "Daneel.Lang.Get( key[, replacements] ) : "
    Daneel.Debug.CheckArgType( key, "key", "string", errorHead )
    local currentLanguage = Daneel.Config.language.current
    local defaultLanguage = Daneel.Config.language.default
    local searchInDefault = Daneel.Config.language.searchInDefault

    local keys = key:split( "." )
    local language = currentLanguage
    if table.containsvalue( Daneel.Config.language.languageNames, keys[1] ) then
        language = table.remove( keys, 1 )
    end
    
    local noLangKey = table.concat( keys, "." ) -- rebuilt the key, but without the language
    local fullKey = language .. "." .. noLangKey 
    if replacements == nil and Daneel.Cache.lang[ fullKey ] ~= nil then
        Daneel.Debug.StackTrace.EndFunction()
        return Daneel.Cache.lang[ fullKey ]
    end

    local lines = Daneel.Lang.lines[ language ]
    if lines == nil then
        error( errorHead.."Language '"..language.."' does not exists" )
    end

    for i, _key in ipairs(keys) do
        if lines[_key] == nil then
            -- key was not found
            if DEBUG == true then
                print( errorHead.."Localization key '"..key.."' was not found in '"..language.."' language ." )
            end

            -- search for it in the default language
            if language ~= defaultLanguage and searchInDefault == true then  
                lines = Daneel.Lang.Get( defaultLanguage.."."..noLangKey, replacements )
            else -- already default language or don't want to search in
                lines = Daneel.Config.language.keyNotFound
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
        Daneel.Cache.lang[ key ] = line -- ie: "greetings.welcome"
        Daneel.Cache.lang[ fullKey ] = line -- ie: "english.greetings.welcome"
    end

    Daneel.Debug.StackTrace.EndFunction()
    return line
end

--- Register a gameObject to update its TextRenderer whenever the language will be updated by Daneel.Lang.Update().
-- @param gameObject (GameObject) The gameObject.
-- @param key (string) The language key.
-- @param replacements [optional] (table) The placeholders and their replacements (has no effect when the 'key' argument is a function).
function DaneelLang.RegisterForUpdate( gameObject, key, replacements )
    Daneel.Debug.StackTrace.BeginFunction( "Daneel.Lang.RegisterForUpdate", gameObject, key, replacements )
    local errorHead = "Daneel.Lang.RegisterForUpdate( gameObject, key[, replacements] ) : "
    Daneel.Debug.CheckArgType( gameObject, "gameObject", "GameObject", errorHead )
    Daneel.Debug.CheckArgType( key, "key", "string", errorHead)
    Daneel.Debug.CheckOptionalArgType( replacements, "replacements", "table", errorHead )

    Daneel.Lang.gameObjectsToUpdate[gameObject] = {
        key = key,
        replacements = replacements,
    }
    Daneel.Debug.StackTrace.EndFunction()
end

--- Update the current language and the text of all gameObjects that have registered via Daneel.Lang.RegisterForUpdate().
-- Updates the TextRenderer or GUI.TextArea component.
-- Fire the OnLangUpdate event.
-- @param language (string) The new current language.
function DaneelLang.Update( language )
    Daneel.Debug.StackTrace.BeginFunction( "Daneel.Lang.Update", language )
    local errorHead = "Daneel.Lang.Update( language ) : "
    Daneel.Debug.CheckArgType( language, "language", "string", errorHead )
    language = Daneel.Debug.CheckArgValue( language, "language", Daneel.Config.language.languageNames, errorHead )
    
    Daneel.Cache.lang = {} -- ideally only the items that do not begins by a language name should be deleted
    Daneel.Config.language.current = language
    for gameObject, data in pairs( Daneel.Lang.gameObjectsToUpdate ) do
        local text = Daneel.Lang.Get( data.key, data.replacements )
        
        if gameObject.textArea ~= nil then
            gameObject.textArea:SetText( text )
        elseif gameObject.textRenderer ~= nil then
            gameObject.textRenderer:SetText( text )
        
        elseif DEBUG then
            print( "WARNING : " .. errorHead .. tostring( gameObject ) .. " does not have a TextRenderer or TextArea component." )
        end
    end

    Daneel.Event.Fire( "OnLangUpdate" )
    Daneel.Debug.StackTrace.EndFunction()
end


----------------------------------------------------------------------------------
-- Scripted Behavior part

--[[PublicProperties
key string ""
registerForUpdate boolean false
/PublicProperties]]

function Behavior:Start()
    if self.key:trim() ~= "" then
        if self.gameObject.textArea ~= nil then
            self.gameObject.textArea:SetText( Daneel.Lang.Get( self.key ) )
        elseif self.gameObject.textRenderer ~= nil then
            self.gameObject.textRenderer:SetText( Daneel.Lang.Get( self.key ) )
        end

        if self.registerForUpdate then
            Daneel.Lang.RegisterForUpdate( self.gameObject, self.key )
        end
    end
end
