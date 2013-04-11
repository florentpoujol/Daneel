
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

    inputKeys = {
        --[[
        buttonname, => print the buttonName (par default left and right shift + buttonName = BUTTONNAME )

        buttonName = {
            otherButtonName = "value"
        }


        ]]

        ['"'] = {
            LeftShift = "3",
            --RightAlt = "#",
        },

        "a", 
        "b",
    },


    -- Your custom objects and their type returned by Daneel.Debug.GetType()
    -- GetType() will return the type on tables that have the object as metatable
    -- Ie :
    -- type (string) = Object (table)
    objects = {

    },


    -- The languages supported by the game
    languages = {
        "english",
    },
    
    -- Game's current and default language
    currentLanguage = "english",


    ----------------------------------------------------------------------------------
    -- GUI

    -- Name of the gameObject who has the orthographic camera used to render the HUD
    hudCameraName = "HUDCamera",

    -- The orthographic scale of the HUDCamera
    hudCameraOrthographicScale = 10,

    -- Fully-qualified path of the map used to render text components
    textMapPath = "Daneel/TextMap",
    emptyTextMapPath = "Daneel/EmptyTextMap",

    -- GUI element's default scale
    hudElementDefaultScale = 0.2,


    

    -- Set to true to enable the framework's advanced debugging capabilities.
    -- Set to false when you ship the game.
    debug = false,
}
