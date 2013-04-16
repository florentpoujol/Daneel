
if config == nil then 
    config = {} 
end

-- Configuration common for all environments
config.common = {
    
    -- Config environement
    environments = {
        "dev",
        "ship",
    },

    environment = "common",
    


    ----------------------------------------------------------------------------------
    -- List of the Scripts paths as values and optionally the script alias as the keys.
    -- Setting your scripts here allows you to :
    -- * call getters and setters as if they where variable
    -- * call the ScriptedBehavior on the gameObject via its alias or name
    -- * implement a Behavior:DaneelAwake() function (called before Start())
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
    languages = {
        "english",
        --"french",
        --"german",
        --...
    },

    language = {
        -- Game's default language
        -- If a line key is not found in the current language, it will try to find the key in the default language 
        -- before returning the value of keyNotFound
        default = "english",

        -- Current language
        current = "english",

        -- Value returned when a language key is not found
        keyNotFound = "langkeynotfound",
    },


    

    -- Your custom objects and their type returned by Daneel.Debug.GetType()
    -- GetType() will return the type on tables that have the object as metatable
    objects = {
        -- Type (string) = Object (table)      

    },

    -- Set to true to enable the framework's advanced debugging capabilities.
    -- Set to false when you ship the game.
    debug = false,
}


config.dev = {
    debug = true
}

config.ship = {
    
}

config.environment = "dev"
