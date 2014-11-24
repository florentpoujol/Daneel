-- Lang.lua
-- Update the TextRenderer or GUI.TextArea component on the game object with the localized string whose key is provided.
-- Allow to register the game object for the localized text to be updated when the language changes.
--
-- Last modified for v1.5.0
-- Copyright © 2013-2014 Florent POUJOL, published under the MIT license.

Lang = {
    dictionariesByLanguage = { english = {} },
    cache = {},
    gameObjectsToUpdate = {},
    doNotCallUpdate = true, -- let here ! Read in Daneel.Load() to not include Lang.Update() to the list of functions to be called every frames.
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

--------------------------------------------------------------------------------

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
    ["Lang.RegisterForUpdate"] = { { "gameObject", "GameObject" }, { "key", "string" }, { "replacements", "table", isOptional = true } },
    ["Lang.Update"] = { { "language", "string" } },
} )
