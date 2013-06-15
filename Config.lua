
function DaneelConfig()
    return {
        -- List of the Scripts paths as values and optionally the script alias as the keys.
        -- Ie :
        -- "fully-qualified Script path"
        -- or
        -- alias = "fully-qualified Script path"
        --
        -- Setting a script path here allow you to  :
        -- * Use the dynamic getters and setters
        -- * Use component:Set() (for scripts that are ScriptedBehaviors)
        -- * Call Behavior:DaneelAwake() when Daneel has just loaded, even on scripts that are not ScriptedBehaviors
        -- * If you defined aliases, dynamically access the ScriptedBehavior on the gameObject via its alias
        scriptPaths = {
            trigger = "Daneel/Behaviors/Trigger",
        },

 
        ----------------------------------------------------------------------------------

        input = {
            -- Button names as you defined them in the "Administration > Game Controls" tab of your project.
            -- Button whose name is defined here can be used as HotKeys.
            buttons = {},

            -- Maximum number of frames between two clicks of the left mouse button to be considered as a double click
            doubleClickDelay = 20,
        },


        ----------------------------------------------------------------------------------

        language = {
            -- list of the languages supported by the game
            languageNames = {
                
            },

            -- Current language
            current = nil,

            -- Default language
            default = nil,

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
            
            textDefaultFontName = "GUITextFont",

            checkBoxDefaultState = false, -- false = not checked, true = checked
        },


        ----------------------------------------------------------------------------------

        tween = {
            defaultTweenerParams = {
                id = 0, -- can be anything, not restricted to numbers
                isEnabled = true, -- a disabled tweener won't update but the function like Play(), Pause(), Complete(), Destroy() will have no effect
                isPaused = false,

                delay = 0.0, -- delay before the tweener starts (in the same time unit as the duration (durationType))
                duration = 0.0, -- time or frames the tween (or one loop) should take (in durationType unit)
                durationType = "time", -- the unit of time for delay, duration, elapsed and fullElapsed. Can be "time", "realTime" or "frame"

                startValue = nil, -- it will be the current value of the target's property
                endValue = 0.0,

                loops = 0, -- number of loops to perform (-1 = infinite)
                loopType = "simple", -- type of loop. Can be "simple" (X to Y, repeat), "yoyo" (X to Y, Y to X, repeat)
                
                easeType = "linear", -- type of easing, check the doc or the end of the "Daneel/Lib/Easing" script for all possible values
                
                isRelative = false, -- If false, tween the value TO endValue. If true, tween the value BY endValue.
            },
        },


        ----------------------------------------------------------------------------------

        debug = {
            -- Enable/disable Daneel's global debugging features.
            enableDebug = true,

            -- Enable/disable the Stack Trace.
            enableStackTrace = true,
        },


        ----------------------------------------------------------------------------------
        -- Objects (keys = name, value = object)

        userObjects = {},
    }
end
