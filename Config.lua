
config = {
    -- List of the Scripts paths as values and optionally the script alias as the keys.
    -- Ie :
    -- "fully-qualified Script path"
    -- or
    -- alias = "fully-qualified Script path"
    -- Setting a script path here allow you to  :
    -- * Use the dynamic getters and setters
    -- * Use component:Set() (for scripts that are ScriptedBehaviors)
    -- * Implements Behavior:DaneelAwake(). It is called when Daneel has just loaded, even on scripts that are not ScriptedBehaviors
    -- * If you defined aliases, dynamically access the ScriptedBehavior on the gameObject via its alias
    scriptPaths = {
        "Daneel/Behaviors/DaneelBehavior",
        triggerScript = "Daneel/Behaviors/Trigger",
        "Daneel/Behaviors/TriggerableGameObject",
        "Daneel/Behaviors/CastableGameObject",
        "Daneel/Behaviors/MouseInteractiveGameObject",
        "Daneel/Behaviors/MouseInteractiveCamera",
        "Daneel/Behaviors/GUI/GUIMouseInteractive",
        "Daneel/Behaviors/GUI/CheckBox",
        "Daneel/Behaviors/GUI/Input",
        "Daneel/Behaviors/GUI/WorldText",
    },


    ----------------------------------------------------------------------------------

    input = {
        -- Button names as you defined them in the "Administration > Game Controls" tab of your project.
        -- Button whose name is defined here can be used as HotKeys.
        buttons = {
            "LeftMouse",
            "LeftShift",
            "Delete",
            "LeftArrow",
            "RightArrow",
        },

        -- Maximum number of frames between two clicks of the left mouse button to be considered as a double click
        doubleClickDelay = 20,

        inputKeys = {

        }
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


    ----------------------------------------------------------------------------------

    gui = {
        -- Name of the gameObject who has the orthographic camera used to render the HUD
        hudCameraName = "HUDCamera",
        -- the corresponding GameObject, set at runtime
        hudCamera = nil,

        -- The gameObject that serve as origin for all GUI elements that aare not in a Group, created at runtime
        hudOrigin = nil,

        -- The orthographic scale of the HUDCamera
        hudCameraOrthographicScale = 10,

        -- Fully-qualified path of the map used to render text elements
        textMapPath = "Daneel/TextMap",
        emptyTextMapPath = "Daneel/EmptyTextMap",

        -- label's (text) default scale
        textDefaultScale = 0.3,

        -- TileSets used for the text elements
        textColorTileSetPaths = {
            White = "Daneel/ASCII_White",
            Black = "Daneel/ASCII_Black",
            Red = "Daneel/ASCII_Red",
            Green = "Daneel/ASCII_Green",
            Blue = "Daneel/ASCII_Blue",
        },
        textColorTileSets = {
            -- Name (string) = TileSet (TileSet)
        }, -- filled at runtime

        textDefaultColorName = "White",

        -- CheckBox
        checkBox = {
            tileSetPath = nil,

            -- Set the block ID on the TileSet or the letter/sign as a string
            checkedBlock = 251, -- valid mark
            notCheckedBlock = "X",
        },
    },


    ----------------------------------------------------------------------------------

    -- List of your custom object types (their name as a string), to be returned by Daneel.Debug.GetType().
    -- Daneel.Debug.GetType() will return one the types if an object corresponding to one of the types is the metatable of the supllied object.
    -- Ie :
    -- "RaycastHit"
    userTypes = {},


    ----------------------------------------------------------------------------------

    debug = {
        -- Enable/disable Daneel's global debugging features.
        enableDebug = false,

        -- Enable/disable the Stack Trace.
        enabeStackTrace = true,
    }
}

    
--[[
        inputKeys = {
            
            buttonname, => print the buttonName (par default left and right shift + buttonName = BUTTONNAME )

            buttonName = {
                otherButtonName = "value"
            }


            
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

        
    },


    ]]

