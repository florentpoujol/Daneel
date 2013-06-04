
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

        -- default Font path for text and checkbox
        textDefaultFontName = "Daneel/GUITextFont",
        
        checkBoxDefaultState = false, -- false = not checked, true = checked
    },


    ----------------------------------------------------------------------------------

    tween = {
        defaultTweenParams = {
            isEnabled = true,
            isPaused = false,

            delay = 0.0, -- delay before start (in the same unit (durationType) than the duration)
            duration = 0.0, -- time or frame the tween (or one loop) should take
            durationType = "Time", -- unit for for delay, duration, elapsed, fullElapsed. Can be Time, RealTime or Frame

            startValue = nil,
            endValue = 0.0,

            loops = 0, -- number of remaining loops to perform (-1 = infinite)
            loopType = "simple", -- type of loop. Can be "simple" (X to Y, repeat), "yoyo" (X to Y, Y to X, repeat)
            
            easeType = "linear", -- type of easing, check the doc for all possible values
            
            isRelative = false, -- If false, tween the value TO endValue. If true, tween the value BY endValue.
            broadcastCallbacks = false, -- broadcast (instead of send) the callbacks when they are messages
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
        enableStackTrace = true,
    },
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

