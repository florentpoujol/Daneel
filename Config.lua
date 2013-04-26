
if config == nil then 
    config = {} 
end


config.default = {
    
    -- Current environment.
    -- Change the value if you define your own environment(s)
    environment = "default",


    ----------------------------------------------------------------------------------

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
        "Daneel/Behaviors/DaneelBehavior",
        "Daneel/Behaviors/Trigger",
        "Daneel/Behaviors/TriggerableGameObject",
        "Daneel/Behaviors/CastableGameObject",
        "Daneel/Behaviors/MouseInteractiveGameObject",
        "Daneel/Behaviors/MouseInteractiveCamera",

        "Daneel/Behaviors/GUI/GUIMouseInteractive",
        "Daneel/Behaviors/GUI/CheckBox",
        "Daneel/Behaviors/GUI/Input",
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
    }


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

        -- The orthographic scale of the HUDCamera
        hudCameraOrthographicScale = 10,

        -- Fully-qualified path of the map used to render text elements
        textMapPath = "Daneel/TextMap",
        emptyTextMapPath = "Daneel/EmptyTextMap",

        -- label's (text) default scale
        hudLabelDefaultScale = 0.3,

        -- TileSets used for the text elements
        colorsTileSetPaths = {
            "Daneel/Text_White",
            "Daneel/Text_Black",
            "Daneel/Text_Red",
            "Daneel/Text_Green",
            "Daneel/Text_Blue",
        },

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
    -- "RaycasHit"
    -- "Daneel.GUI.Text"
    userTypes = {

    },

    -- once Daneel has loaded, the userObjects table below will be filled with the types defined in userTypes as the keys and the actual objects as values
    userObjects = {},


    ----------------------------------------------------------------------------------

    -- Enable/disble Daneel's debugging features.
    debug = false,




    ----------------------------------------------------------------------------------
    -- DO NOT EDIT BELOW
    ----------------------------------------------------------------------------------


    -- list of the environment names, filled at runtime.
    environments = {},

    -- List of the languages supported by the game.
    -- Automatically filled at runtime with the languages names, based on the keys defined on the 'language' global variable
    languages = {},


    ----------------------------------------------------------------------------------

    -- Objects (keys = name, value = object)
    assetObjects = {
        Script = Script,
        Model = Model,
        ModelAnimation = ModelAnimation,
        Map = Map,
        TileSet = TileSet,
        Sound = Sound,
        Scene = Scene,
        --Document = Document
    },
    assetTypes = {}, -- filled at runtime

    componentObjects = {
        ScriptedBehavior = ScriptedBehavior,
        ModelRenderer = ModelRenderer,
        MapRenderer = MapRenderer,
        Camera = Camera,
        Transform = Transform,
        Physics = Physics,
    },
    componentTypes = {},
    
    craftStudioObjects = {
        GameObject = GameObject,
        Vector3 = Vector3,
        Quaternion = Quaternion,
        Plane = Plane,
        Ray = Ray,
    },
    
    daneelTypes = {
        "RaycastHit",
        "Vector2",
    },
    daneelObjects = {},

    guiTypes = {
        "Daneel.GUI.Common",
        "Daneel.GUI.Group",
        "Daneel.GUI.Text",
        "Daneel.GUI.Image",
        "Daneel.GUI.CheckBox",
        "Daneel.GUI.Input",
        "Daneel.GUI.ProgressBar",
        "Daneel.GUI.Slider",
        "Daneel.GUI.WorldText",
    },
    guiObjects = {}, -- filled at runtime
      
    -- list of all types and objects, filled at runtime
    allObjects = {},


    ----------------------------------------------------------------------------------

    -- Rays
    -- list of the gameObjects to cast the ray against by default by ray:Cast()
    -- filled in the CastableGameObjects behavior
    castableGameObjects = {},
    
    -- Triggers
    -- list of the gameObjects to check for proximity by the triggers
    -- filled in the TriggerableGameObject behavior
    triggerableGameObjects = {},

    -- List of the gameObjects that react to the mouse inputs
    mouseInteractiveGameObjects = {},
}


    
--[[
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

        
    },


    

