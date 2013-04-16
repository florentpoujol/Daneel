
if config == nil then 
    config = {} 
end


-- Configuration common for all environments
config.common = {
    
    ----------------------------------------------------------------------------------
    
    -- List of the Scripts paths as values and optionally the script alias as the keys.
    -- Setting your scripts here allows you to :
    -- - call getters and setters as if they where variable
    -- - call the ScriptedBehavior on the gameObject via its alias or name
    -- - implement a Behavior:DaneelAwake() function (called before Behvior:Start() and even on scripts that are not ScriptedBehaviors)
    scripts = {
        -- "fully-qualified Script path"
        -- or
        -- alias = "fully-qualified Script path"
    },

    
    ----------------------------------------------------------------------------------
    
    -- Button names as you defined them in the "Administration > Game Controls" tab of your project
    -- Button whose name is defined here can be used as HotKeys
    buttons = {

    },


    ----------------------------------------------------------------------------------
    -- Language

    -- List of the languages supported by the game
    -- you may set the language keys/lines in a 'language[language]' table
    -- ie: the "english" language will have its 'language.english' table
    languages = {
        "english",
        --"french",
        --"german",
        --...
    },

    language = {
        -- Current language
        current = "english",

        -- Default language
        default = "english",

        -- Value returned when a language key is not found
        keyNotFound = "langkeynotfound",

        -- Tell wether Daneel.Lang.GetLine() search a line key in the default language 
        -- when it is not found in the current language before returning the value of keyNotFound
        searchInDefault = true,
    },


    ----------------------------------------------------------------------------------
    -- Debug

    -- Set to true to enable the framework's advanced debugging capabilities.
    -- Set to false when you ship the game.
    debug = false,

    -- Your custom objects and their type returned by Daneel.Debug.GetType()
    -- GetType() will return the type on tables that have the object as metatable
    objects = {
        -- Type (string) = Object (table)
    },
}


config.dev = {
    debug = true
}

config.ship = {
    debug = false
}

