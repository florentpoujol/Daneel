
if Daneel == nil then 
    Daneel = {}
end

Daneel.config = {

    -- List of the Scripts paths as values and optionally the script alias as the keys.
    -- Ie :
    -- "fully-qualified Script path"
    -- or
    -- alias = "fully-qualified Script path"
    scripts = {

    },

    
    -- Button names as you defined them in the "Administration > Game Controls" tab of your project
    -- Button whose name is defined here can be used as HotKeys
    buttons = {

    },


    ----------------------------------------------------------------------------------
    -- Language

    languages = {
        -- List of the languages supported by the game
        "english",


        -- Game's default language
        -- If a line key is not found in the current language, it will try to find the key in the default language 
        -- before returning the value of keyNotFound
        default = "english",

        -- Current language
        current = "english",

        -- Value returned when a language key is not found
        keyNotFound = "langkeynotfound",
    },


    ----------------------------------------------------------------------------------
    -- Debug

    -- Your custom objects and their type returned by Daneel.Debug.GetType()
    -- GetType() will return the type on tables that have the object as metatable
    -- Ie :
    -- Type (string) = Object (table)
    objects = {

    },

    -- Set to true to enable the framework's advanced debugging capabilities.
    -- Set to false when you ship the game.
    debug = false,
}
