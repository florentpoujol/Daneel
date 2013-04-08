
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
        "Daneel/Behaviors/DaneelBehavior",
        "Daneel/Behaviors/Trigger",
        "Daneel/Behaviors/TriggerableGameObject",
        "Daneel/Behaviors/CastableGameObject",
        "Daneel/Behaviors/MousehoverableGameObject",
    },

    
    -- Button names as you defined them in the "Administration > Game Controls" tab of your project
    -- Button whose name is defined here can be used as HotKeys
    buttons = {

    },


    ----------------------------------------------------------------------------------
    -- Language

    -- The languages supported by the game
    languages = {
        "english",
    },
    
    -- Game's current and default language
    currentLanguage = "english",


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
