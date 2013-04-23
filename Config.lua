
if config == nil then 
    config = {} 
end


-- Configuration common for all environments
config.common = {
    
    environment = "common",


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
    
    input = {
        -- Button names as you defined them in the "Administration > Game Controls" tab of your project
        -- Button whose name is defined here can be used as HotKeys
        buttons = {
            "LeftMouse",
            "LeftShift",
            "Delete",
            "LeftArrow",
            "RightArrow",
        },

        inputKeys = {
            --[[
            buttonname, => print the buttonName (par default left and right shift + buttonName = BUTTONNAME )

            buttonName = {
                otherButtonName = "value"
            }


            ]]
            "a", "b", "c", "d", "e", "f", "g", "h", "i", "j", "k", "l", "m", "n", "o", "p", "q", "r", "s", "t", "u", "v", "w", "x", "y", "z",

            Space = " ", 

            -- num pad
            Divide = "/", Multiply = "*", Substract = "-", Add = "+",
            NumPad0 = "0", NumPad1 = "1", NumPad2 = "2", NumPad3 = "3", NumPad4 = "4",
            NumPad5 = "5", NumPad6 = "6", NumPad7 = "7", NumPad8 = "8", NumPad9 = "9",
            -- /num pad

            D1 = {
                "&",
                LeftShift = "1",
            },

            D2 = {
                "é",
                LeftShift = "2",
                RightAlt = "~",
            },

            D3 = {
                '"',
                LeftShift = "3",
                RightAlt = "#",
            },

            D4 = {
                "'",
                LeftShift = "4",
                RightAlt = "{",
            },

            D5 = {
                "(",
                LeftShift = "5",
                RightAlt = "[",
            },

            D6 = {
                "-",
                LeftShift = "6",
                RightAlt = "|",
            },

            D7 = {
                "è",
                LeftShift = "7",
                RightAlt = "`",
            },

            D7 = {
                "è",
                LeftShift = "7",
                RightAlt = "`",
            },

            D8 = {
                "_",
                LeftShift = "8",
                RightAlt = "\"",
            },

            D9 = {
                "ç",
                LeftShift = "9",
                RightAlt = "^",
            },

            D0 = {
                "à",
                LeftShift = "0",
                RightAlt = "@",
            },

        },

        -- Maximum number of frames between two clicks of the left mouse button to be considered as a double click
        doubleClickDelay = 20,
    },


    ----------------------------------------------------------------------------------

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

    -- Once Danee is loaded, you may get the list of the laguage names with the 'languages' key.


    ----------------------------------------------------------------------------------
    
    gui = {
        -- Name of the gameObject who has the orthographic camera used to render the HUD
        hudCameraName = "HUDCamera",

        -- The orthographic scale of the HUDCamera
        hudCameraOrthographicScale = 10,

        -- Fully-qualified path of the map used to render text components
        textMapPath = "Daneel/TextMap",
        emptyTextMapPath = "Daneel/EmptyTextMap",

        -- GUI element's default scale
        hudLabelDefaultScale = 0.3,

        -- hud
        colorsTileSetPaths = {

        },

        textDefaultColorName = "Red",

        -- CheckBox
        checkBox = {
            tileSetPath = nil,
            checkedBlock = nil,
            notCheckedBlock = nil,
        },
    },


    ----------------------------------------------------------------------------------
    
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

