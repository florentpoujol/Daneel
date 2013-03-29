[craftstudio]: http://craftstud.io
[CSscriptingreference]: http://craftstudio.wikia.com/wiki/Scripting_Reference/Index
[Daneelfunctionreference]: http://florent-poujol.fr/content/craftstudio/daneel/doc/
[downloadlink]: http://florent-poujol.fr/content/craftstudio/daneel/craftstudio_daneel_v1.0.0.cspack


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


## Installation 

You can go to the public project `DaneelFramework` and export the scripts in the "Daneel" folder or [download the package][downloadlink].

You must then import the package in your project.

- Download the file on your computer
- Go to your project's administration, "Import/Export" section.  
- Click the import button (top right), navigate to the location you downloaded the pack in then click "Open".  
- Navigate to the "Script" tab, select all the scripts then click "Import".


## Configuration

Some features only work if a few configuration is done first.
You will find the configuration table in the `Daneel/Config` script.
    
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


        -- Set to true to enable the framework's advanced debugging capabilities.
        -- Set to false when you ship the game.
        debug = false,
    }


## Loading Daneel

Daneel needs to be loaded before some of its features work, so you need to add the "Daneel/Behaviors/DaneelBehavior" script as a ScriptedBehavior in your scene.  
Daneel is garanteed to be loaded by the time functions `Behavior:Start()` begin to be called.  
It may also be the case from `Behavior:Awake()` functions, but it is not garanteed (it depends on the GameObject initialization order).

The global variable `DANEEL_LOADED` is equal to `nil` until Daneel is loaded, where its value is set to `true`.

Any scripts whose path is set in `Daneel.config.scripts` may implements a `Behavior:OnDaneelLoaded()` function.  
This function will be called right after Daneel has loaded, before `Behavior:Start()` and **even on scripts that are not ScriptedBehavior**.


## Conventions

* Every getter functions are called GetSomething() instead of FindSomething().
* Every object and function names are pascal-cased, except for functions added to Lua's standard libraries which are all lower-case.
* Every time an argument has to be an asset (like with `modelRenderer:SetModel()`), you may pass the fully-qualified asset name instead.
* Every time an argument has to be a gameObject instance (like with `gameObject:SetParent(parentNameOrInstance[, keepLocalTransform])`), you may pass the gameObject name instead.
* Every time an argument has to be an asset or component **type**, you may pass the asset or component **object** instead (ie : `Asset.Get("Model name", ModelRenderer)` instead of `Asset.Get("Model name", "ModelRenderer")`). And when you do pass the type as a string, it is case insensitive.
* Every optional boolean arguments default to false.


## Dynamic getters and setters

Getters and setters functions may be used on gameOjects, components and assets as if they were variables. Their names must begin by "Get" or "Set" and have the forth letter upper-case (underscore is allowed). Ie : GetSomething() and Get_something() will works, but Getsomething() or getSomething() won't work.

    
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

    -- alias = "fully-qualified Script path"
    Daneel.config = {
        scripts = {
            "MyScript",
            otherScript = "folder/my other script",
        }
    }

    -- in your script, access the scripteBehavior with its alias :
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

        scriptedBehavior = "Script name", -- will create a ScriptedBehavior with the "Script name" script if it does not yet exists
        
        scriptedBehaviors = {
            "script name 2",
            "script name 3", -- will create those ScriptedBehaviors if they don't yet exists
            
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

If you want to add just one scriptedBehavior, you can set the variable `scriptedBehavior` with the script name or asset as value.  
If you want to add one or more scriptedBehaviors and maybe initialize them or set existing ScriptedBehaviors, set the variable `scriptedBehaviors` (with an "s" at the end) with a table as value.  
This table may contains the script name or asset of new ScriptedBehaviors as value (if you don't want to initialize them) or the script name or asset as key and the parameters table as value (for new or existing ScriptedBehaviors). Existing ScriptedBehaviors may also be set via their name or alias.


## Debugging

For an easy debugging during development, Daneel feature extensive error reporting and a stack trace. Since these features are pretty heavy on function calls, you can turn these on and off (and you should disable debug when you ship your game).  
It's turned off by default, so just set the value of the variable `Daneel.config.debug` to `true` to enable it.

This affect the functions `Daneel.Debug.CheckArgType()`, `Daneel.Debug.CheckOptionalArgType()`, `Daneel.Debug.PrintError()` plus the functions in `Daneel.Debug.StackTrace`.

### Error reporting

In every functions introduced or modified by Daneel, every arguments are checked for type and value and a comprehensive error message is thrown if needed.  
For instance, passing false instead of the gameObject's name with `gameObject:GetChild()` would trigger the following error :  

    GameObject.GetChild(gameObject, name[, recursive]) : Argument 'name' is of type 'boolean' with value 'false' instead of 'string'.

### Stack Trace

When an error is triggered by `Danel.Debug.PrintError(message)`, Daneel print a "stack trace" in the Runtime Report.
The stack trace nicely shows the history of function calls within the framework that lead to the error and display values received as argument as well as returned values.  
It reads from top to bottom, the last function called -where the error occurred- at the bottom.  
For instance, when trying to set the model of a ModelRenderer (to a Model that does not exists) via gameObject:Set() :

    ~~~~~ Daneel.Debug.StackTrace ~~~~~
    #01 GameObject.Set(GameObject: 'Object1': 14476932, table: 04DAC148)
    #02 Component.Set(ModelRenderer: 31780825, table: 04DAC238)
    #03 ModelRenderer.SetModel(ModelRenderer: 31780825, "UnknowModel")
    [string "Behavior Daneel/Daneel (0)"]:293: ModelRenderer.SetModel(modelRenderer, modelNameOrAsset) : Argument 'modelNameOrAsset' : model with name 'UnknowModel' was not found.

### Data types

The function `Daneel.Debug.GetType(object)` is an extension of Lua's built-in `type()` and may returns any of the built-in Lua types or the name of any of the objects introduced by CraftStudio or Daneel : GameObject, ModelRenderer, MapRenderer, Camera, Transform, Script, Model, ModelAnimation, Map, TileSet, Scene, Sound, Ray, RaycastHit, Vector3, Plane, Quaternion


## Raycasting

GameObjects who have the `CastableGameObject` ScriptedBehavior are known as **castable gameObjects**.  
The `RaycastHit` object stores the information regarding the collision between a ray and a gameObject. It may contains the keys *distance*, *normal*, *hitBlockLocation*, *adjacentBlockLocation*, *gameObject* and *componentType*.

The function `ray:IntersectsGameObject(gameObject)` returns a RaycastHit if the ray intersected the gameObject, or nil.  
The function `ray:Cast([gameObjects])` cast the ray against all castable gameObjects (or against the provided set of gameObjects) and returns a table of RaycastHit (which will be empty if no gameObjects have been hit).


## Trigger messages

GameObjects who have the `TriggerableGameObject` ScriptedBehavior are known as **triggerable gameObjects**. They react when they are near triggers.  
Triggers are gameObjects that perform a spherical proximity check each frames against all triggerable gameObjects.  
Triggers must have the `Trigger` ScriptedBehavior and you must set its `radius` public property (don't forget to tick the box).

* When a triggerable gameObject enters a trigger for the first frame (it is in range this frame, but it wasn't the last frame), the message `OnTriggerEnter` is sent on the gameObject.  
* As long as a gameObject stays under a trigger's radius, the message `OnTriggerStay` is sent on the gameObject (each frame, by each trigger the gameObject is in range of).
* The frame a gameObject leaves the trigger's radius (it is not in range this frame but was in range the last frame), the message `OnTriggerExit` is send on the gameObject.

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

You can also make gameObjects to listen to events. By default, the message "On[Event name]" will be sent (and optionally broadcasted) on that gameObject.  
    
    function Behavior:Awake()
        Daneel.Events.Listen("EventName", self.gameObject) -- the message "OnEventName" will be sent on this gameObject only
        Daneel.Events.Listen("EventName", self.gameObject, "AnotherMessage") -- the message "AnotherMessage" (instead of "OnEventName") will be sent on this gameObject only
        Daneel.Events.Listen("EventName", self.gameObject, "AnotherMessage", true) -- the message "AnotherMessage" will be sent on this gameObject and all of its children
    end


## Hotkeys events

Whenever you press one of the button whose name is set in `Daneel.config.buttons`, the events named `On[Button name]ButtonDown`, `On[Button name]ButtonJustPressed` and `On[Button name]ButtonJustReleased` are fired.

The table `Daneel.config.buttons` may be filled with the button names that you defined in the `Administration > Game Controls` tab.

    Daneel.config = {
        buttons = {
            -- the list of the button names as they appear in CraftStudio in the "Game Controls" tab :
            "Action",
            "fire",
        }
    }


## Miscellaneous

### GameObject

* Create a gameObject with `GameObject.New()` or `GameObject.Instanciate()`.
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

The `table` object has also been extended with many functions that ease the manipulation of table.


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

### Daneel.Debug

* Daneel.Debug.CheckArgType(argument, argumentName, expectArgumentType[, errorHead, errorEnd])
* Daneel.Debug.CheckOptionalArgType(argument, argumentName, expectArgumentType[, errorHead, errorEnd])
* Daneel.Debug.CheckComponentType(componentType)
* Daneel.Debug.CheckAssetType(assetType)

* Daneel.Debug.GetType(object, getLuaTypeOnly)
* Daneel.Debug.PrintError(message)
* error(message[, doNotPrintStacktrace])
* Daneel.Debug.ToRawString(object)

* Daneel.Debug.StackTrace.BeginFunction(functionName[, ...])
* Daneel.Debug.StackTrace.EndFunction()
* Daneel.Debug.StackTrace.Print()

### Daneel.Events

* Daneel.Events.Listen(eventName, function) / Daneel.Events.Listen(eventName, gameObject[, functionName, broadcast])
* Daneel.Events.StopListen(eventName, functionOrGameObject)
* Daneel.Events.Fire(eventName[, ...])

### Daneel.Utilities

* Daneel.Utilities.CaseProof(name, set)

### GameObject

* GameObject.New(name[, params])
* GameObject.Instanciate(name, sceneNameOrObject[, params])
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

* math.isinteger(value[, strict])

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
* table.combine(keys, values[, strict])
* table.removevalue(table, value[, singleRemove])
* table.getkeys(table)
* table.getvalues(table)
* table.getkey(table, value)


## Changelog

### v1.1.0

- The error() function now prints the StackTrace, unless told otherwise
- Separated the user config from the "Daneel" script
- Dynamic getters and setters works on assets too
- Fixed several bugs