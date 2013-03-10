[craftstudio]: http://craftstud.io
[CSscriptingreference]: http://craftstudio.wikia.com/wiki/Scripting_Reference/Index
[Daneelscriptingreference]: http://a.com



# Daneeel Framework

Daneel is a framework for [CraftStudio][] that aims to extend and render more flexible to use the API, as well as to bring news fonctionnalities.

Daneel never deprecate anything from the current CraftStudio's API which remains usable in its entirety [as decribed in the scripting reference][CSscriptingreference] on the offical wiki.
Daneel mostly add new objects, new functions on existing objects and sometimes allow to pass different argument types and new arguments on existing functions.


## Conventions

For consistency sake, some convention are observed throughout the framework :

* Every getter fonctions are called GetSomething() and not FindSomething().
* Every object and function names are camel-cased, except for functions added to Lua's standard libraries which are all lowercase.
* Every time an argument has to be an asset, you may pass the fully-qualified asset name instead.
* Every time an argument has to be a gameObject instance, you may pass the gameObject name instead.
* Every time an argument has to be an asset or component type, you may pass the asset or component **object** instead (ie : ModelRenderer instead of "ModelRenderer"). And when you do pass the type as a string, it is case insensitive.
* Every optional boolean arguments default to false.


## Dynamic getters and setters

Getters and setters functions (functions that begins by Get or Set) may be used on gameOjects, components and any scriptedBehaviors as if they were variables :
    
    self.gameObject.transform.localPosition
    -- is the same as
    self.gameObject.transform:GetLocalPosition()

    self.gameObject.name = "a new name"
    -- is the same as 
    self.gameObject:SetName("a new name")
    -- note that only one argument (in addition to the working object) can be passed to the function.

This works even for your own getters (that your defined in your ScriptedBehaviors) but ''does not works'' for your own setters.

As Daneel introduce the new GetModelRenderer(), GetMapRenderer() and GetCamera() functions on gameObjects, you may now access any components via their variable, like the transform :

    self.gameObject.modelRenderer.model = "model name"
    -- is the same as
    self.gameObject:GetComponent("ModelRenderer"):SetModel(CraftStudio.FindAsset("model name", "Model"))


## Dynamic access to ScriptedBehaviors

ScriptedBehaviors whose name are camel-cased and are not nested in a folder may be accessed in the same way as the getters. For instance, with a Script whose name is 'MyScript' :

    self.gameObject.myScript.something
    -- is the same as
    self.gameObject:GetScriptedBehavior(CraftStudio.FindAsset("MyScript", "Script")):GetSomething()

You may define aliases for other ScriptedBehaviors (those who are nested in folders and/or name are not camel-cased) in the config. Those scriptedBehaviors become accessible throught their aliases as above :

    -- in the config, set the 'scriptedBehaviorAliases' table which must contains the aliases as the keys and the fully-qualified Script path as the values
    Daneel.config = {
        scriptedBehaviorAliases = {
            -- alias = "fully-qualified Script path",
            scriptName = "folder/script name",
        }
    }

    -- in your script, access the scripteBehavior with its alias
    self.gameObject.scriptName

Note that with the ScriptedBehaviors only (not with the getters or setters), the case of the alias and especially its first letter matters.
In this example, self.gameObject.ScriptName won't get access to the scriptedBehavior but self.gameObject.ModelRenderer will get access to the modelRenderer.

You may also access the first scriptedBehavior on the gameObject, whatever its name is, via `self.gameObject.scriptedBehavior`.


## Debugging

Daneel's functions features extensive debugging capability.  
Every arguments are checked for type and value and a comprehensive error message is thrown if needed.

For instance, passing false instead of the gameObject's name with gameObject:GetChild() would trigger the following error :  

    GameObject.GetChild(gameObject, name[, recursive]) : Argument 'name' is of type 'boolean' with value 'false' instead of 'string'.

### Daneel's types

The function '''Daneel.Debug.GetType(object)''' is an extension of ''type()'' and may returns any of the built-in Lua types or the name of any of the objects introduced by CraftStudio or Daneel : 

* GameObject
* ModelRenderer, MapRenderer, Camera, Transform
* Script, Model, ModelAnimation, Map, TileSet, Scene, Sound, Document
* Ray, RayastHit, Vector3, Plane, Quaternion
* GUILabel

### Stack Trace

When an error is triggered by '''Danel.Debug.PrintError(errorMessage)''', Daneel print a Stack Trace in the Runtime Report.
The Stack Trace nicely shows the histoy of function calls whithin the framework and display values recieved as argument as well as returned values.


## Mass-setting on gameObjects and components

Functions gameObject:Set() and component:Set() accept a "params" argument of type table which allow to set variables or call setters in mass.

 gameObject:Set({
    parent = "my parent name", -- Set the parent via SetParent()
    myScript = {
        health = 100 -- Set the variable health on the 'MyScript' scriptedBaheavior or call SetHealth(100) if it exists
    }
 })

 modelRenderer:Set({
    localOrientation = Quaternion:New(1,2,3,4), -- set the local orientation via SetLocalOrientation()
    randomVariable = "random value"
 })


### Component mass-creation and setting on gameObjects

Example :

 gameObject:Set({
    modelRenderer = {
        model = "Model name"
    }, -- will create a modelRenderer if it does not yet exists, then set its model

    camera = {}, -- will create a camera component then do nothing, or just do nothing

    scriptedBehavior = "Script name", -- will create a ScriptedBehavior with the "Script name" script and if it does not yet exists
    
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


'''Components'''

Just set the variable of the same name as the component with the first letter lower case. Set the value as a table of parameters. If the component does not yet exists, it will be created. If you want to create a component without initializing it, just leave the table empty.

You can mass-set existing components on gameObject via gameObject:SetComponent() or its helpers (SetModelRenderer() and the likes).
    
    self.gameObject:SetMapRenderer([params])
    -- or, with the dynamic access to the components
    self.gameObject.mapRenderer:Set([params])

'''ScriptedBehaviors'''

If you want to add one scriptedBehavior, set the variable "scriptedBehavior" with the script name or asset as value.
If you want to create one or more scriptedBehaviors and maybe initialize them, or set existing ScriptedBehaviors, set the variable 'scriptedBehaviors' (with an 's' at the end) with a table as value.
This table may contains the scripts name or asset of new ScriptedBehaviors as value (if you don't want to initialize them) or the script name or asset as key and the parameters table as value (for new or existing ScriptedBehaviors).
Existing ScriptedBehaviors may also be set via their name or alias.


## Raycasting

GameObject who have the "Daneel/Behaviors/CastableGameObject" ScriptedBehavior are known as '''castable gameObjects'''.
The '''RaycastHit''' object stores the information regarding the collision between a ray and a gameObject. It may contains the keys ''distance'', ''normal'', ''hitBlockLocation'', ''adjacentBlockLocation'', ''gameObject'' and ''component''.

The function ray:Cast([gameObjects]) cast the ray against all castable gameObjects (or against the provided set of gameObjects) and returns a table of RaycastHit (or an empty table if no gameObjects have been hit).


## Events

Daneel provide a flexible event system.
You can register any function, including behavior function


---

##  List of functions

[See the full scripting reference][daneelscriptingreference] for full explanation on arguments and returned values.  
Arguments between square brackets are optional.

### Asset

* Asset.Get(assetName[, assetType])
* Asset.GetModel(assetName)
* Asset.GetModelAnimation(assetName)
* Asset.GetMap(assetName)
* Asset.GetTileSet(assetName)
* Asset.GetScene(assetName)
* Asset.GetScript(assetName)
* Asset.GetDocument(assetName)
* Asset.GetSound(assetName)

* Asset.GetType(asset)
* Asset.IsOfType(asset, assetType)

### Component

* Component.Set(component, params)

### Daneel.Debug

* Daneel.Debug.CheckArgType(argument, argumentName, expectArgumenType[, errorHead, errorEnd])
* Daneel.Debug.CheckOptionalArgType(argument, argumentName, expectArgumenType[, errorHead, errorEnd])
* Daneel.Debug.GetType(object)
* Daneel.Debug.PrintError(message)

### Daneel.Events

* Daneel.Events.Listen(eventName, function) / Daneel.Events.Listen(eventName, gameObject[, functionName, broadcast])
* Daneel.Events.StopListen(eventName, functionOrGameObject)
* Daneel.Events.Fire(eventName[, ...])

### Daneel.StackTrace

* Daneel.StackTrace.BeginFunction(functionName[, ...])
* Daneel.StackTrace.EndFunction(functionName[, ...])
* Daneel.StackTrace.Print([length])

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

* gameObject:AddComponent(componentType[, params, scriptedBehaviorParams])
* gameObject:AddScriptedBehavior(scriptNameOrAsset[, params])
* gameObject:AddModelRenderer([params])
* gameObject:AddMapRenderer([params])
* gameObject:AddCamera([params])

* gameObject:SetComponent(componentType, params)
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
* gameObject:DestroyComponent(input[, strict])
* gameObject:DestroyScriptedBehavior(scriptNameOrAsset)
* gameObject:DestroyModelRenderer()
* gameObject:DestroyMapRenderer()
* gameObject:DestroyCamera()

### GUILabel

* GUILabel.New(name[, params])
* guiLabel:Refresh()
* guiLabel:SetPosition()
* guiLabel:SetScale(scale)
* guiLabel:SetText(text)
* guiLabel:Destroy()

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

