[craftstudio]: http://craftstud.io
[CSscriptingreference]: http://craftstudio.wikia.com/wiki/Scripting_Reference/Index
[Daneelscriptingreference]: http://a.com



# Daneel Framework

Daneel is a framework for [CraftStudio][] that aims to extend and render more flexible to use the API, as well as to bring news fonctionnalities.

Daneel never deprecate anything from the current CraftStudio's API which remains usable in its entirety [as decribed in the scripting reference][CSscriptingreference] on the offical wiki.  
Daneel mostly add new objects, new functions on existing objects and sometimes allow to pass different argument types and new arguments on existing functions.


## Conventions

Some convention are observed throughout the framework :

* Every getter fonctions are called GetSomething() and not FindSomething().
* Every object and function names are camel-cased, except for functions added to Lua's standard libraries which are all lowercase.
* Every time an argument has to be an asset (like with `modelRenderer:SetModel()`), you may pass the fully-qualified asset name instead.
* Every time an argument has to be a gameObject instance (like with `gameObject:SetParent()`), you may pass the gameObject name instead.
* Every time an argument has to be an asset or component **type**, you may pass the asset or component **object** instead (ie : `Asset.Get("Model name", ModelRenderer)` instead of `Asset.Get("Model name", "ModelRenderer")`). And when you do pass the type as a string, it is case insensitive.
* Every optional boolean arguments default to false.


## Dynamic getters and setters

Getters and setters functions (functions that begins by Get or Set) may be used on gameOjects, components as if they were variables :
    
    self.gameObject.transform.localPosition
    -- is the same as
    self.gameObject.transform:GetLocalPosition()

    self.gameObject.name = "a new name"
    -- is the same as 
    self.gameObject:SetName("a new name")
    -- note that only one argument (in addition to the working object) can be passed to the function.

As Daneel introduce the new `gameObject:GetModelRenderer()`, `gameObject:GetMapRenderer()` and `gameObject:GetCamera()` functions, you may now access any components via their variable, like the transform :

    self.gameObject.modelRenderer.model = "model name"
    -- is the same as
    self.gameObject:GetComponent("ModelRenderer"):SetModel(CraftStudio.FindAsset("model name", "Model"))

Dynamic getters and setters will also work for your scripts (not just the ScriptedBehaviors) provided you add their fully-qualified path in `Daneel.config.scripts` :

    Daneel.config = {
        scripts = {
            "MyScript",
            "folder/MyOtherScript", 
        }
    }


## Dynamic access to ScriptedBehaviors

ScriptedBehaviors whose name are camel-cased and are not nested in a folder may be accessed as if they were variable. For instance, with a Script whose name is 'MyScript' :

    self.gameObject.myScript
    -- is the same as
    self.gameObject:GetScriptedBehavior(CraftStudio.FindAsset("MyScript", "Script"))

You may define aliases for other ScriptedBehaviors (those who are nested in folders and/or name are not camel-cased) in `Daneel.config.scripts`. Those scriptedBehaviors become accessible via their aliases as above :

    -- alias = "fully-qualified Script path"
    Daneel.config = {
        scripts = {
            "MyScript",
            myOtherScript = "folder/MyOtherScript",
        }
    }

    -- in your script, access the scripteBehavior with its alias :
    self.gameObject.myOtherScript

Note that with the ScriptedBehaviors only (not with the getters or setters), the case of the alias and especially its first letter matters.  
In this example, `self.gameObject.MyOtherScript` won't get access to the scriptedBehavior but `self.gameObject.ModelRenderer` will get access to the modelRenderer.


## Debugging

Daneel's functions features extensive debugging capability.  
Every arguments are checked for type and value and a comprehensive error message is thrown if needed.

For instance, passing false instead of the gameObject's name with `gameObject:GetChild()` would trigger the following error :  

    GameObject.GetChild(gameObject, name[, recursive]) : Argument 'name' is of type 'boolean' with value 'false' instead of 'string'.

### Data types

The function `Daneel.Debug.GetType(object)` is an extension of Lua's built-in `type()` and may returns any of the built-in Lua types or the name of any of the objects introduced by CraftStudio or Daneel : GameObject, ModelRenderer, MapRenderer, Camera, Transform, Script, Model, ModelAnimation, Map, TileSet, Scene, Sound, Document, Ray, RaycastHit, Vector3, Plane, Quaternion

### Stack Trace

When an error is triggered by `Danel.Debug.PrintError(errorMessage)`, Daneel print a Stack Trace in the Runtime Report.
The Stack Trace nicely shows the histoy of function calls whithin the framework and display values recieved as argument as well as returned values.


## Mass-setting on gameObjects and components

Functions `gameObject:Set()` and `component:Set()` accept a "params" argument of type table which allow to set variables or call setters in mass.  
Ie :

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

With `gameObject:Set()`, you can easily create new components then optionnaly initialize them or set existing components (including ScriptedBehaviors).  
Ie :

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

    -- or even (with the dynamic component setters) (this does not works for ScriptedBehaviors)
    self.gameObject.mapRenderer = {params}

**ScriptedBehaviors**

If you want to add one scriptedBehavior, set the variable `scriptedBehavior` with the script name or asset as value.  
If you want to add one or more scriptedBehaviors and maybe initialize them, or set existing ScriptedBehaviors, set the variable `scriptedBehaviors` (with an "s" at the end) with a table as value.  
This table may contains the script name or asset of new ScriptedBehaviors as value (if you don't want to initialize them) or the script name or asset as key and the parameters table as value (for new or existing ScriptedBehaviors). Existing ScriptedBehaviors may also be set via their name or alias.


## Events

Daneel provide a flexible event system that allows to run functions or messages on gameObjects whenever some events happens during runtime.  
You can register any function (global, local or Behavior functions) to be called whenever an event is fired (the function is said to listen to the event).  
Any arguments may be passed to the function when the event is fired.  
Ie :
    
    local function ALocalFunction(text)
        print(text)
    end

    function Behavior:APublicFunction(text)
        print(text)
    end

    function Behavior:Awake()
        Daneel.Event.Listen("EventName", ALocalFunction) -- same for global functions
        Daneel.Event.Listen("EventName", self.APublicFunction) -- do not add the parenthesis after the function name

        -- to fire an event, just call the Fire() function
        -- and optionally pass the argument(s) after the event name
        Daneel.Event.Fire("EventName", "Brace for this event !")
    end

You can also make gameObjects to listen to events. By default, the message "On[Event name]" will be sent (and optionnaly broadcasted) on that gameObject.  
Ie :
    
    function Behavior:Awake()
        Daneel.Event.Listen("EventName", self.gameObject) -- the message "OnEventName" will be sent to this gameObject only
        Daneel.Event.Listen("EventName", self.gameObject, "AnotherMessage") -- the message "AnotherMessage" will be sent to this gameObject only
        Daneel.Event.Listen("EventName", self.gameObject, "AnotherMessage", true) -- the message "AnotherMessage" will be sent to this gameObject and all of its children
    end


## Raycasting

GameObjects who have the `CastableGameObject` ScriptedBehavior are known as **castable gameObjects**.  
The ``RaycastHit` object stores the information regarding the collision between a ray and a gameObject. It may contains the keys *distance*, *normal*, *hitBlockLocation*, *adjacentBlockLocation*, *gameObject* and *componentType*.

The function `ray:Cast([gameObjects])` cast the ray against all castable gameObjects (or against the provided set of gameObjects) and returns a table of RaycastHit (which will be empty if no gameObjects have been hit).


## Trigger messages

GameObjects who have the `TriggerableGameObject` ScriptedBehavior are known as **triggerable gameObjects**. They react when they are near triggers.  
Triggers are gameObjects that perform a spherical proximity check each frames against all triggerable gameObjects.  
Triggers must have the `Trigger` ScriptedBehavior and you must set its `radius` public property.

* When a triggerable gameObject enters a trigger for the first frame (it is in range this frame, but it wasn't the last frame), the message `OnTriggerEnter` is sent on the gameObject.  
* As long as a gameObject stays under a trigger's radius, the message `OnTriggerStay` is sent on the gameObject (each frame, by each trigger the gameObject is in range of).
* The frame a gameObject leaves the trigger's radius (it is not in range this frame but was in range the last frame), the message `OnTriggerExit` is send on the gameObject.

Each of these functions receive the trigger gameObject as argument.

Ie :

    -- in a ScriptedBehavior attached to a triggerable gameObjects :
    function Behavior:OnTriggerEnter(trigger)
        print("The gameObject of name '"..self.gameObject.name.."' just reach the trigger of name '"..trigger.name.."'.")
    end

    function Behavior:OnTriggerStay(trigger)
        if CraftStudio.Input.WasButtonJustRealeased("Action") then
            print("The 'Action' button was just released while the gameObject of name '"..self.gameObject.name.."' is inside the trigger of name '"..trigger.name.."'.")
        end
    end
    -- a typical use for this is any mechanism that the player can use if he is close enought and press a key


## Mouse messages

GameObjects who have the `MousehoverableGameObject` ScriptedBehavior are known as **mousehoverable gameObjects**. They react when they are hovered by the mouse.

* When a mousehoverable gameObject is hovered for the first frame (it is hovered this frame, but it wasn't the last frame), the message `OnMouseEnter` is sent on the gameObject.
* As long as the mouse stays over the gameObject, the message `OnMouseOver` is sent on the gameObject.
* The frame the mouse stop hovering over a mousehoverable gameObject (it is not hovered this frame but was hovered the last frame), the message `OnMouseExit` is send on the gameObject.


## Hotkeys events

Whenever you press one of the button whose name is set in `Daneel.config.input.buttons`, the events nammed `On[Button name]ButtonDown`, `On[Button name]ButtonJustPressed` and `On[Button name]ButtonJustReleased` are fired.

The table `Daneel.config.input.buttons` may be filled with the button names that you defined in the `Administration > Game Controls` tab.

Ie :

    Daneel.config.input = {
        buttons = {
            -- the list of the button names as they appear in CraftStudio in the "Game Controls" tab :
            "Action",
            "fire",
        }
    }


---

##  List of functions

[See the full scripting reference][daneelscriptingreference] for full explanation on arguments and returned values. 
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
    * Asset.GetDocument(assetName)

### Component

* Component.Set(component, params)
* component:Destroy()

### Daneel.Debug

* Daneel.Debug.CheckArgType(argument, argumentName, expectArgumentType[, errorHead, errorEnd])
* Daneel.Debug.CheckOptionalArgType(argument, argumentName, expectArgumentType[, errorHead, errorEnd])
* Daneel.Debug.CheckComponentType(componentType)
* Daneel.Debug.CheckAssetType(assetType)
  
* Daneel.Debug.GetType(object)
* Daneel.Debug.PrintError(message)
  
* Daneel.Debug.StackTrace.BeginFunction(functionName[, ...])
* Daneel.Debug.StackTrace.EndFunction(functionName[, ...])
* Daneel.Debug.StackTrace.Print()

### Daneel.Events

* Daneel.Events.Listen(eventName, function) / Daneel.Events.Listen(eventName, gameObject[, functionName, broadcast])
* Daneel.Events.StopListen(eventName, functionOrGameObject)
* Daneel.Events.Fire(eventName[, ...])

### Daneel.Utilities

* Daneel.Utilities.CaseProof(name, set)

### GameObject

* GameObject.New(name[, params])
* GameObject.Instanciate(name, sceneName[, params])
* GameObject.Get(name)

* gameObject:SetParent(parentNameOrObject[, keepLocalTransform])
* gameObject:GetChild(childName[, recursive])
* gameObject:GetChildren([recursive, includeSelf])
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

* mapRenderer:SetMap(mapNameOrAsset)

### ModelRenderer

* modelRenderer:SetModel(modelNameOrAsset)

### Ray

* ray:Cast([gameObjects])
* ray:IntersectsGameObject(gameObject)

### RaycastHit

* RaycastHit.New([distance, normal, hitBlockLocation, adjacentBlockLocation, gameObject])

### string

* string.totable(string)
* string.isoneof(string, set[, ignoreCase])
* string.ucfirst(string)

### table

* table.new([...])
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

