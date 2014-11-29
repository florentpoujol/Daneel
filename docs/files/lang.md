# Localization

The `Lang` object allows you to easily localize any strings in your game.  

- [Setup and configuration](#setup)
- [Retrieving a line](#retrieving-a-line)
- [Placeholders and Replacements](#placeholders-and-replacements)
- [Updating the language](#updating-the-language)
- [Working in the scene editor](#scene)
- [Function reference](#function-reference)


<a name="setup"></a>
## Setup and configuration

The `Lang` object exposes some configuration variables. Set any of them via a `Lang.UserConfig` table or function that return a table :

    function Lang.UserConfig()
        return {
            default = nil, -- default language
            current = nil, -- current language
            
            searchInDefault = true, -- Tell whether Lang.Get() search a line key in the default language 
            -- when it is not found in the current language before returning the value of keyNotFound
            keyNotFound = "langkeynotfound", -- Value returned when a language key is not found
        }
    end

Each of the localized strings (the lines) are identified by a key, unique across all languages. The keys must not contains dot and the first-level keys must not be any of the languages name.  

The key/line pairs for each languages must be set in a table as value of the language name in the `Lang.dictionariesByLanguage` object.

    Lang.UserConfig = {
        default = "english", -- lower case
        current = "french", 
    }

    Lang.dictionariesByLanguage.english = { -- names in lower case too
        key = "value",

        greetings = { -- you may nest the key/line pairs.
            welcome = "Welcome !", 
        }
    }

    Lang.dictionariesByLanguage.french = {
        greetings = { 
            welcome = "Bienvenu !",
        }
    }


<a name="retrieving-a-line"></a>
## Retrieving a line

Use the `Lang.Get(key[, replacements])` function.
By default it returns the line in the current language.
    
    Lang.Get( "key" ) -- returns "value" when the default language is "English"

Chain the keys with dots when the key/line pairs are nested :

    Lang.Get( "greetings.welcome" ) -- returns "Welcome !" 

Prefix the key with the language name (case-insensitive) (with a dot after it) to get a line in any language :

    Lang.Get( "french.greetings.welcome" ) -- returns "Bienvenu !" even if the current language is not french

If a key is not found in a particular language, it is searched for in the default language before returning the value of the `keyNotFound` variable in the config. To prevent Get() to search for a missing key in the default language, set the value of `searchInDefault` variable in the config to `false`.


<a name="placeholders-and-replacements"></a>
## Placeholders and replacements

Your localized strings may contains placeholders that are meant to be replaced with other values before being displayed.  
A placeholder is a sequence of any characters prefixed with a semicolon.  
You may pass a placeholder/replacement table as the second parameter of `Lang.Get()`.
    
    Lang.dictionariesByLanguage.english = {
        welcome = "Welcome :playername, have a nice play !"
    }

    Lang.Get( "welcome" ) -- returns "Welcome :playername, have a nice play !"
    Lang.Get( "welcome", { playername = "John" } ) -- returns "Welcome John, have a nice play !"

Note that any strings, not just the localized strings, may benefits from the placeholder/replacement with `Daneel.Utilities.ReplaceInString(string, replacements)`.


<a name="updating-the-language"></a>
## Updating the language

You may register the game objects that display a text via a `TextRenderer` or `GUI.TextArea` ([see the GUI script](/docs/gui#textarea)) with `Lang.RegisterForUpdate(gameObject, key[, replacements])`, or listen to the `OnLangUpdate` global event in order to automatically update the languages lines when the current language is modified.

Call `Lang.Update(language)` with the new current language as argument to update the current language and fire the `OnLangUpdate` global event.  
You can get the current language at any time via the `Lang.Config.current` property.

    gameObject.textRenderer.text = Lang.Get( "welcome" )
    Lang.RegisterForUpdate( gameObject, "welcome" )

    print( gameObject.textRenderer.text ) -- "Welcome :playername, have a nice play !"
    Lang.Update( "french" ) -- Always use lower case language name
    print( gameObject.textRenderer.text ) -- "Bienvenu :playername, bon jeu !"

    -- Just listen to the OnLangUpdate event to update something else than a TextRenderer or a GUI.TextArea
    -- in this example, the text of a GUI.Toggle component
    Daneel.Event.Listen( "OnLangUpdate", function()
        gameObject.toggle.text = Lang.Get( "Whatever" )
    end )


<a name="scene"></a>
## Working in the scene editor

The `Lang` script may be added as a scripted behavior on any game object to update its text renderer or text area (`GUI.TextArea`) when the scene loads and optionally to register the game object for update.
