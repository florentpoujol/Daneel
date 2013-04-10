[craftstudio]: http://craftstud.io
[CSscriptingreference]: http://craftstudio.wikia.com/wiki/Scripting_Reference/Index
[Daneelfunctionreference]: http://florent-poujol.fr/content/craftstudio/daneel/doc/
[downloadlink]: http://florent-poujol.fr/content/craftstudio/daneel/craftstudio_daneel_v1.1.0.cspack


# Daneel

Daneel is a framework for [CraftStudio][] that aims to sweeten and shorten the code you write, to extend and render more flexible to use the API, as well as to bring news functionalities.

Daneel never deprecate anything from the current CraftStudio's API which remains usable in its entirety [as described in the scripting reference][CSscriptingreference] on the official wiki.  
Daneel mostly add new objects, new functions on existing objects and sometimes allow to pass different argument types and new arguments on existing functions.

- [Overview](#overview)
- [Installation](#installation)
- [Configuration](#configuration)
- [Loading Daneel](#loading-daneel)
- [Conventions](#conventions)
- [Dynamic getters and setters](#dynamic-getters-and-setters)
- [Dynamic access to components](#dynamic-access-to-components)
- [Mass-setting on gameObjects and components](#mass-setting-on-gameobjects-and-components)
- [Debugging](#debugging)
- [Raycasting](#raycasting)
- [Trigger messages](#trigger-messages)
- [Mouse messages](#mouse-messages)
- [Events](#events)
- [Hotkeys](#hotkeys)
- [Localization](#localization)
- [GUI](#gui)
- [Miscellaneous](#miscellaneous)
- [Functions list](#functions-list)
- [Changelog](#changelog)


## Overview

Call getters and setters as if they were variable :
    
    self.gameObject.name -- same as self.gameObject:GetName()
    self.gameObject.name = "new name" -- same as self.gameObject:SetName("new name")

Access any component (including ScriptedBehaviors with a few configuration) on the gameObject in a similar way, like you can already do with the transform :

    self.gameObject.modelRenderer

    -- the "getters/setters as variable" thing also works on components :
    self.gameObject.mapRenderer.map = "folder/map name" -- you can also see here that you can use the map name instead of the map asset
    
    -- writing this same line "the old way" takes twice as much characters :
    self.gameObject:GetComponent("MapRenderer"):SetMap(CraftStudio.FindAsset("folder/map name", "Map"))

Set variable or call setters in mass on gameObjects and components.
    
    gameObject:Set({
        parent = "my parent name",

        modelRenderer = {
            model = "model name"
        }

        myScript = {
            health = 100
        }
    })


Also : 

- Use the gameObject or asset name instead of the actual object with some functions
- Simpler raycasting with `ray:InstersectsGameObject()` or `ray:Cast()`
- Triggers (they perform a proximity check against some gameObjects and interact with them when they are in range)
- Interact with gameObjects hovered by the mouse
- Events
- Hotkeys (fire events at the push of any button)

You can add the public project `Daneel` in CraftStudio and run the game to test some of these features for yourself and read some script examples.  
Note that the project is only visible in the `Community Projects` when my computer and my local server are up. Also, my IP changes frequently, so if you can't connect but find it in the `Community Projects`, you need to remove the project from your list then add it again.


## Installation 

First [download the package of scripts from this link][downloadlink].

You must then import the package in your project.

- Download the file on your computer
- Go to your project's administration, "Import/Export" section.  
- Click the import button (top right), navigate to the location you downloaded the pack in then click "Open".  
- Navigate to the "Script" tab, select all the scripts then click "Import".


## Configuration

Some features only work if a few configuration is done first.
You will find the configuration table in the `Daneel/Config` script.
    

## Loading Daneel

Daneel needs to be loaded before some of its features work, so you need to add the "Daneel/Behaviors/DaneelBehavior" script as a ScriptedBehavior in your scene.  
Daneel is garanteed to be loaded by the time functions `Behavior:Start()` begin to be called.  
It may also be the case from `Behavior:Awake()` functions, but it is not garanteed (it depends on the GameObject initialization order).

The global variable `DANEEL_LOADED` is equal to `nil` until Daneel is loaded, where its value is set to `true`.

Any scripts whose path is set in `Daneel.config.scripts` may implements a `Behavior:DaneelAwake()` function.  
This function will be called right after Daneel has loaded, before `Behavior:Start()` and **even on scripts that are not ScriptedBehavior**.


## Conventions

* Every getter functions are called GetSomething() instead of FindSomething().
* Every object and function names are pascal-cased, except for functions added to Lua's standard libraries which are all lower-case.
* Every time an argument has to be an asset (like with `modelRenderer:SetModel()`), you may pass the fully-qualified asset name instead.
* Every time an argument has to be a gameObject instance (like with `gameObject:SetParent(parentNameOrInstance[, keepLocalTransform])`), you may pass the gameObject name instead.
* Every time an argument has to be an asset or component type, it is case insensitive.
* Every optional boolean arguments default to false.


## Dynamic getters and setters

Getters and setters functions may be used on *gameOjects, components, assets and GUI elements* as if they were variables. Their names must begin by "Get" or "Set" and have the forth letter upper-case (underscore is allowed). Ie : GetSomething() and Get_something() will work, but Getsomething() or getSomething() won't work.

    
    self.gameObject.transform.localPosition
    -- is the same as
    self.gameObject.transform:GetLocalPosition()

    self.gameObject.name = "a new name"
    -- is the same as 
    self.gameObject:SetName("a new name")
    -- note that only one argument (in addition to the working object) can be passed to the function.

Dynamic getters and setters will also work on your ScriptedBehaviors provided you add their Script's fully-qualified path in `Daneel.config.scripts` :

    Daneel.config = {
        scripts = {
            "MyScript",
            "folder/my other script", 
        }
    }


## Dynamic access to components 

As Daneel introduce the new `gameObject:GetModelRenderer()`, `gameObject:GetMapRenderer()` and `gameObject:GetCamera()` functions, you may now access any component via its variable, like the transform :

    self.gameObject.modelRenderer.model = Asset.GetModel("model name") -- Asset.GetModel() is an helper of Asset.Get(), an alias of CraftStudio.FindAsset()
    -- is the same as
    self.gameObject:GetComponent("ModelRenderer"):SetModel(CraftStudio.FindAsset("model name", "Model"))

### ScriptedBehaviors

ScriptedBehaviors may also be accessed this way.  
It just works right away for those who are not nested in a folder and name is pascal-cased. For instance, with a Script whose name is "MyScript" :

    self.gameObject.myScript
    -- is the same as
    self.gameObject:GetScriptedBehavior(CraftStudio.FindAsset("MyScript", "Script"))

ScriptedBehaviors who are nested in folders and/or name are not pascal-cased, may be accessed via their aliases as you define them in `Daneel.config.scripts`.

    Daneel.config = {
        scripts = {
            "MyScript",
            
            -- alias = "fully-qualified Script path"
            otherScript = "folder/my other script",
        }
    }

    -- in your script, access the scripteBehavior via its alias :
    self.gameObject.otherScript


## Mass-setting on gameObjects and components

Functions `gameObject:Set()` and `component:Set()` accept a "params" argument of type table which allow to set variables or call setters in mass.  

    gameObject:Set({
        parent = "my parent name", -- Set the parent via SetParent()
        myScript = {
            health = 100 -- Set the variable health or call SetHealth(100) if it exists on the 'MyScript' scriptedBaheavior 
        }
    })

    modelRenderer:Set({
        localOrientation = Quaternion:New(1,2,3,4), -- set the local orientation via SetLocalOrientation()
        randomVariable = "random value"
    })


### Component mass-creation and setting on gameObjects

With `gameObject:Set()`, you can easily create new components then optionally initialize them or set existing components (including ScriptedBehaviors).  

    gameObject:Set({
        modelRenderer = {
            model = "Model name"
        }, -- will create a modelRenderer if it does not yet exists, then set its model

        camera = {}, -- will create a camera component then do nothing, or just do nothing
      
        scriptedBehaviors = {
            "script name 2",
            "script name 3", -- will create those ScriptedBehaviors if they don't yet exist
            
            ["script name 4"] = {
                variableOrSetter = value
            } -- will create a ScriptedBehavior if it does not yet exists, then set it
        },

        scriptAlias = {
            variableOrSetter = value
        } -- will set the ScriptedBehavior whose name or alias is 'ScriptAlias'
    })


**Components**

Just set the variable of the same name as the component with the first letter lower case. Set the value as a table of parameters. If the component does not yet exists, it will be created. If you want to create a component without initializing it, just leave the table empty.

You can also mass-set existing components on gameObjects via `gameObject:SetComponent()` or its helpers (`gameObject:SetModelRenderer()` and the likes).
    
    self.gameObject:SetMapRenderer({params})
    
    -- or (with the dynamic component getters)
    self.gameObject.mapRenderer:Set({params})

    -- note that you CAN NOT do the following since the components are cached on the gameObject :
    self.gameObject.mapRenderer = {params}
    -- the variable actually exists on the gameObject, so the dynamic call to Set[ComponentType]() does not work

**ScriptedBehaviors**

To add one or more scriptedBehaviors and maybe initialize them or set existing ScriptedBehaviors, set the variable `scriptedBehaviors` with a table as value.  
This table may contains the script name or asset of new ScriptedBehaviors as value (if you don't want to initialize them) or the script name or asset as key and the parameters table as value (for new or existing ScriptedBehaviors). Existing ScriptedBehaviors may also be set via their name or alias.


## Debugging

For an easy debugging during development, Daneel feature extensive error reporting and a stack trace. Since these features are pretty heavy on function calls, you can turn these on and off (and you should disable debug when you ship your game).  
It's turned off by default, so just set the value of the variable `Daneel.config.debug` to `true` to enable it.

### Error reporting

In every functions introduced or modified by Daneel, every arguments are checked for type and value and a comprehensive error message is thrown if needed.  
For instance, passing false instead of the gameObject's name with `gameObject:GetChild()` would trigger the following error :  

    GameObject.GetChild(gameObject, name[, recursive]) : Argument 'name' is of type 'boolean' with value 'false' instead of 'string'.

### Stack Trace

When an error is triggered, Daneel print a "stack trace" in the Runtime Report.
The stack trace nicely shows the history of function calls within the framework that lead to the error and display values received as argument.  
It reads from top to bottom, the last function called -where the error occurred- at the bottom.  
For instance, when trying to set the model of a ModelRenderer (to a Model that does not exists) via gameObject:Set() :

    ~~~~~ Daneel.Debug.StackTrace ~~~~~
    #01 GameObject.Set(GameObject: 'Object1': 14476932, table: 04DAC148)
    #02 Component.Set(ModelRenderer: 31780825, table: 04DAC238)
    #03 ModelRenderer.SetModel(ModelRenderer: 31780825, "UnknowModel")
    [string "Behavior Daneel/Daneel (0)"]:293: ModelRenderer.SetModel(modelRenderer, modelNameOrAsset) : Argument 'modelNameOrAsset' : model with name 'UnknowModel' was not found.

### Data types

The function `Daneel.Debug.GetType(object)` may returns any of the built-in Lua types or the name of any of the objects introduced by CraftStudio or Daneel : GameObject, ModelRenderer, MapRenderer, Camera, Transform, Script, Model, ModelAnimation, Map, TileSet, Scene, Sound, Ray, RaycastHit, Vector3, Plane or Quaternion.

It can also return your own types as you define them in `Daneel.config.objects`. GetType() will return the type for tables that have the object table as a metatable.


## Raycasting

GameObjects who have the `CastableGameObject` ScriptedBehavior are known as **castable gameObjects**.  
The `RaycastHit` object stores the information regarding the collision between a ray and a gameObject. It may contains the keys distance, normal, hitBlockLocation, adjacentBlockLocation, gameObject and componentType.

The function `ray:IntersectsGameObject(gameObject)` returns a RaycastHit if the ray intersects the gameObject, or nil.  
The function `ray:Cast([gameObjects])` cast the ray against all castable gameObjects (or against the provided set of gameObjects) and returns a table of RaycastHit (which will be empty if no gameObjects have been hit).


## Trigger messages

GameObjects who have the `TriggerableGameObject` ScriptedBehavior are known as **triggerable gameObjects**. They react when they are near triggers.  
Triggers are gameObjects that perform a spherical proximity check each frames against all triggerable gameObjects.  
Triggers must have the `Trigger` ScriptedBehavior and you must set its `radius` public property (don't forget to tick the box).

* When a triggerable gameObject enters a trigger for the first frame (it is in range this frame, but it wasn't the last frame), the message `OnTriggerEnter` is sent on the gameObject.  
* As long as a gameObject stays in range of one or several trigger(s), the message `OnTriggerStay` is sent on the gameObject (each frame, by each trigger the gameObject is in range of).
* The frame a gameObject leaves a trigger's radius (it is not in range this frame but was in range the last frame), the message `OnTriggerExit` is send on the gameObject.

Each of these functions receive the trigger gameObject as argument.

    -- in a ScriptedBehavior attached to a triggerable gameObjects :
    function Behavior:OnTriggerEnter(trigger)
        print("The gameObject of name '"..self.gameObject.name.."' just reach the trigger of name '"..trigger.name.."'.")
    end

    function Behavior:OnTriggerStay(trigger)
        if CraftStudio.Input.WasButtonJustRealeased("Action") then
            print("The 'Action' button was just released while the gameObject of name '"..self.gameObject.name.."' is inside the trigger of name '"..trigger.name.."'.")
        end
    end
    -- a typical use for this is any mechanism that the player can use if he is close enough and press a key


## Mouse messages

GameObjects who have the `MousehoverableGameObject` ScriptedBehavior are known as **mousehoverable gameObjects**. They react when they are hovered by the mouse.  
Add the `CameraMouseOver` ScriptedBehavior to your camera.

* When a mousehoverable gameObject is hovered for the first frame (it is hovered this frame, but it wasn't the last frame), the message `OnMouseEnter` is sent on the gameObject.
* As long as the mouse stays over the gameObject, the message `OnMouseOver` is sent on the gameObject.
* The frame the mouse stop hovering over a mousehoverable gameObject (it is not hovered this frame but was hovered the last frame), the message `OnMouseExit` is send on the gameObject.


## Events

Daneel provide a event system that allows to run functions or messages on gameObjects whenever some events happens during runtime.

You can register global or local functions to be called whenever an event is fired (the function is said to listen to the event).  
Any arguments may be passed to the function when the event is fired.  
    
    local function ALocalFunction(text)
        print(text)
    end

    function Behavior:Awake()
        Daneel.Events.Listen("EventName", ALocalFunction) -- same for global functions

        -- to fire an event, just call the Fire() function
        -- and optionally pass the argument(s) after the event name
        Daneel.Events.Fire("EventName", "Brace for this event !")
    end

You can also make gameObjects to listen to events. By default, the message of the same name as the event will be sent (and optionally broadcasted) on that gameObject (the function `Behavior:EventName()` wil be called if it exists).  
    
    function Behavior:Awake()
        Daneel.Events.Listen("EventName", self.gameObject) -- the message "EventName" will be sent on this gameObject only
        Daneel.Events.Listen("EventName", self.gameObject, "AnotherMessage") -- the message "AnotherMessage" (instead of "OnEventName") will be sent on this gameObject only
        Daneel.Events.Listen("EventName", self.gameObject, "AnotherMessage", true) -- the message "AnotherMessage" will be sent on this gameObject and all of its children
    end

If you want a function or a gameObject to listen to every events, just pass `"any"` as the event name.


## Hotkeys events

Whenever you press one of the button whose name is set in `Daneel.config.buttons`, the events named `On[Button name]ButtonJustPressed`, `On[Button name]ButtonDown` and `On[Button name]ButtonJustReleased` are fired.

The table `Daneel.config.buttons` may be filled with the button names that you defined in the `Administration > Game Controls` tab.

    Daneel.config = {
        buttons = {
            "Action",
            "fire",
        }
    }


## Localization

Daneel allows you to easly localize any strings in your game.

Set the languages your game speaks in in `Daneel.config.languages` and change the current language's name (`Daneel.config.currentLanguage`) if you don't want it to be "english".

Each of the localized strings (the lines) are identified by a key, unique accross all languages. Ideally, the keys should not contains dot and the first-level keys should not be any of the languages name.  
The key/line pairs for each languages are stored in a table which is the value of a global variable with the same name as the language :

    english = {
        key = "value",

        greetings = { -- As ou can see, you may nest the key/line pairs.
            welcome = "Welcome !", 
        }
    }

    french = {
        greetings = { 
            welcome = "Bienvenu !",
        }
    }


### Retriving a line

Use the function `Daneel.Lang.GetLine(key[, replacements])` or its helper, the global function `line(key[, replacements])`.
By default it returns the line in the current language (`Daneel.config.currentLanguage`).
    
    Daneel.Lang.GetLine("key") -- returns "value" 

Chain the keys with dots when the key/line pairs are nested :

    Daneel.Lang.GetLine("greetings.welcome") -- returns "Welcome !" 

Prefix the key with the language name (and add a dot after it) to get a line in any language :

    Daneel.Lang.GetLine("french.greetings.welcome") -- returns "Bienvenu !" event if the currentLanguage is not french

Once Daneel is loaded, the languages tables are put in `Daneel.Lang.lines`, so you also may to get lines this way :

    Daneel.Lang.lines.french.greetings.welcome -- "Bienvenu !"

If a key is not found, it returns `nil` and print the key in the Runtime Report.

### Placeholder and replacements

Your localized strings may contains placeholders that are meant to be replaced with other values before being displayed.  
A paceholder is a word prefixed with a semicolon.  
You may pass a placeholder/replacement table as the second parameter of `GetLine()`.

    english = {
        welcome = "Welcome :playername, have a nice play !"
    }

    Daneel.Lang.GetLine("welcome") -- Welcome :playername, have a nice play !
    Daneel.Lang.GetLine("welcome", { playername = "John" }) -- Welcome John, have a nice play !

When the placeholder is an integer, you may omit it during the call to `GetLine()` :  

    english = {
        welcome = "Welcome :1, have a nice play !"
    }

    Daneel.Lang.GetLine("welcome", { "John" }) -- Welcome John, have a nice play !

Note that any strings, not just the localized strings, may benefits from the placeholder/replacement with `Daneel.Utilities.ReplaceInString(string, replacements)`.

## GUI

Daneel allows to easilly create GUI elments in order to build HUD and prompt the player with information or interact with him.  

### Setup

GUI elments are actually gameObjects parented to the HUD camera.  
The HUD camera is a gameObject with an orthographic camera component, somewhere in your scene away from where the game actually happens. Name it "HUDCamera" or update the value of `Daneel.config.hudCameraName`. If you set an orthographic scale other than 10, update the value of `Daneel.config.hudCameraOrthographicScale`.

Available GUI objects are :
- Daneel.GUI
- GUIText (Daneel.GUI.Text)
- GUICheckbox (Daneel.GUI.Checkbox)
- GUIInput (Daneel.GUI.Input)

### Common element properties

The GUI elments are convenient wrapper around the gameObjects they are made of that allows to easily manipulate them.  
Get and set the object's properties via their appropriate gettter and setter (or their dynamic variable) at any time during creation or afterward.

- Name : be sure that the name is unique during creation, if you want to retrieve an element later by its name with `GUI.Get(name)`.
- Scale : a scale of 1 is very big, so the elments are created with a default scale of 0.2. You may change this value with `Daneel.config.hudElementDefaultScale`.
- Opacity
- Label : this is the text that identifies the element on screen. You may go to the mext line by inserting ":br:" in the string.

*Position*  
Yet they are actually gameObjects in a 3D world, GUI elements are positionned on the 2D plane that is the screen.
Similarly to Vector3, Vector2 has been introduced and must be supplied to `element:SetPosition()`. The origin is the top-left corner of the screen, so the x component is the distance *in pixels* from the left side of the screen. The y component is the distance in pixels from the top of the screen.  
For a screen that is 800x600 pixels wide, {400,300} is the center of the screen while {800,600} is its bottom-right corner.

All GUI element may be created from script with the New(name)

### GUIText

Just some text.

### GUICheckbox

A labelled checkox that has a "checked" state which can be toggled when the user clicks on the checkbox or its label.  
I addition to the usual parameters, you may define a function as the value of the "onClick" property. This function will be called whenever the user click on the chekbox and receive the element as first and only argument.

    local element = GUICheckbox.New("Box1", {
        position = Vector2.New(400, 200),
        
        onClick = function(element)
            print()
        end
    })


## Miscellaneous

### GameObject

* Create a gameObject with `GameObject.New()` or `GameObject.Instantiate()`.
* Get a gameObject with `GameObject.Get()` and get a child with `gameObject:GetChild()`.
* Add a component on a gameObject with `gameObject:AddComponent()` or its helpers `gameObject:AddModelRenderer()` and the likes, as well as `gameObject:AddScriptedBehavior()`.
- Send a message to a gameObject and all of its descendants with `GameObject.BroadcastMessage()`

### Asset 

Get an asset with `Asset.Get()` or its helpers `Asset.GetScript()`, `Asset.GetModel()`, ...

### Scene

Load a scene with `Scene.Load()`, append a scene with `Scene.Append()`.

### Tables as object

Tables returned by `table.new()` or any new table functions introduced by Daneel that returns a table may be used in an object-oriented way. You can also turn any standard table to such table by passing it as argument to table.new().  

    -- you always can do this :
    table.insert(myTable, value)

    -- now, you can also do this (like with strings)
    myTable:insert(value)

The `table` object has also been extended with many functions that ease the manipulation of tables.


## Functions list

[See the full function reference][daneelfunctionreference] for full explanation on arguments and returned values. 
Arguments between square brackets are optional.

### Asset

* Asset.Get(assetName[, assetType])
    * Asset.GetScript(assetName)
    * Asset.GetModel(assetName)
    * Asset.GetModelAnimation(assetName)
    * Asset.GetMap(assetName)
    * Asset.GetTileSet(assetName)
    * Asset.GetScene(assetName)
    * Asset.GetSound(assetName)

### Component

* Component.Set(component, params)
* component:Destroy()

### Daneel.config

- Daneel.config.AddScripts(scripts)

### Daneel.Debug

* Daneel.Debug.CheckArgType(argument, argumentName, expectArgumentType[, errorHead, errorEnd])
* Daneel.Debug.CheckOptionalArgType(argument, argumentName, expectArgumentType[, errorHead, errorEnd])
* Daneel.Debug.CheckComponentType(componentType)
* Daneel.Debug.CheckAssetType(assetType)

* Daneel.Debug.GetType(object[, getLuaTypeOnly])
* error(message[, doNotPrintStacktrace])
* Daneel.Debug.ToRawString(object)

* Daneel.Debug.StackTrace.BeginFunction(functionName[, ...])
* Daneel.Debug.StackTrace.EndFunction()
* Daneel.Debug.StackTrace.Print()

### Daneel.Events

* Daneel.Events.Listen(eventName, function) / Daneel.Events.Listen(eventName, gameObject[, functionName, broadcast])
* Daneel.Events.StopListen(eventName, functionOrGameObject)
* Daneel.Events.Fire(eventName[, ...])

### Daneel.GUI

- Daneel.GUI.Get(name)

For all GUI Elements :

- element:SetName(position)
- element:GetName()
- element:SetPosition(position)
- element:GetPosition()
- element:SetScale(scale)
- element:GetScale([returnAsNumber])
- element:SetOpacity(opacity)
- element:GetOpacity()
- element:SetLabel(label)
- element:GetLabel()
- element:Destroy()

### Daneel.GUI.Checkbox / GUICheckbox

- Daneel.GUI.Checkbox.New(name[, params])
- checkbox:SwitchSate()

### Daneel.GUI.Text / GUIText

- Daneel.GUI.Text.New(name[, params])


### Daneel.Lang

- Daneel.Lang.GetLine(key[, replacements]) / line(key[, replacements])

### Daneel.Utilities

* Daneel.Utilities.CaseProof(name, set)
* Daneel.Utilities.ReplaceInString(string, replacement)

### GameObject

* GameObject.New(name[, params])
* GameObject.Instantiate(name, sceneNameOrObject[, params])
* GameObject.Get(name)

* gameObject:SetParent(parentNameOrInstance[, keepLocalTransform])
* gameObject:GetChild(childName[, recursive])
* gameObject:GetChildren([recursive, includeSelf])
* gameObject:SendMessage(functionName[, data])
* gameObject:BroadcastMessage(functionName[, data])

* gameObject:AddComponent(componentType[, params]) / gameObject:AddComponent("ScriptedBehavior", scriptNameorAsset[, params])
    * gameObject:AddScriptedBehavior(scriptNameOrAsset[, params])
    * gameObject:AddModelRenderer([params])
    * gameObject:AddMapRenderer([params])
    * gameObject:AddCamera([params])

* gameObject:SetComponent(componentType, params) / gameObject:SetComponent("ScriptedBehavior", scriptNameorAsset, params)
    * gameObject:SetScriptedBehavior(scriptNameOrAsset, params)
    * gameObject:SetModelRenderer(params)
    * gameObject:SetMapRenderer(params)
    * gameObject:SetCamera(params)
    * gameObject:SetTransform(params)

* gameObject:GetComponent(componentType[, scriptNameOrAsset])
    * gameObject:GetScriptedBehavior(scriptNameOrAsset)
    * gameObject:GetModelRenderer()
    * gameObject:GetMapRenderer()
    * gameObject:GetCamera()

* gameObject:Destroy()

### math

* math.isinteger(value[, errorIfValueIsNotNumber])

### MapRenderer

* mapRenderer:SetMap(mapNameOrAsset[, keepTileSet])
* mapRenderer:SetTileSet(tileSetNameOrAsset)

### ModelRenderer

* modelRenderer:SetModel(modelNameOrAsset)
* modelRenderer:SetAnimation(animationNameOrAsset)

### Ray

* ray:Cast([gameObjects])
* ray:IntersectsGameObject(gameObjectNameOrInstance)

### RaycastHit

* RaycastHit.New([distance, normal, hitBlockLocation, adjacentBlockLocation, gameObject])

### Scene

* Scene.Load(sceneNameOrAsset)
* Scene.Append(sceneNameOrAsset, gameObjectNameOrInstance)

### string

* string.totable(string)
* string.isoneof(string, set[, ignoreCase])
* string.ucfirst(string)

### table

* table.new([table])
* table.copy(table)
* table.constainskey(table, key)
* table.constainsvalue(table, value[, ignoreCase])
* table.length(table[, keyType])
* table.print(table)
* table.printmetatable(table)
* table.merge(...)
* table.compare(table1, table2)
* table.combine(keys, values[, returnFalseIfNotSameLength])
* table.removevalue(table, value[, singleRemove])
* table.getkeys(table)
* table.getvalues(table)
* table.getkey(table, value)

### Vector2

- Vector2.New(x[, y])


## Changelog

### v1.2.0

- Added GUI elements
- Added Vector2 object
- Added localization capablities (`Daneel.Lang.GetLine(key[, replacement])`)
- Added `Daneel.Utilities.ReplaceInString(string, replacement)`
- Added `string.slpit(string, delimiter)`
- Fixed SetMap that would throw an exception when keepTileSet was false or nil


### v1.1.0

- Separated the user config from the "Daneel" script
- Dynamic getters and setters works on assets too
- Daneel.Debug.getType() may now also return user-defined types
- The error() function now prints the StackTrace, unless told otherwise (Daneel.Debug.PrintError() is removed)
- Default function names when registering a gameObject to an event are not prefixed by "On" anymore
- Fixed various bugs