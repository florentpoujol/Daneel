[craftstudio]: http://craftstud.io
[CSscriptingreference]: http://craftstudio.wikia.com/wiki/Scripting_Reference/Index
[Daneelscriptingreference]: http://a.com



# Daneeel Framework

Daneel is a framework for [CraftStudio][] that aims to extend and render more flexible to use the API, as well as to bring news fonctionnalities.

Daneel never deprecate anything from the current CraftStudio's API which remains usable in its entirety [as decribed in the scripting reference][CSscriptingreference] on the offical wiki.  
Daneel mostly add new objects, new functions on existing objects and sometimes allow to pass different argument types on existing functions.


## Conventions

For consistency sake, some convention are observed throughout the framework :

* Every getter fonctions are called GetSomething() and not FindSomething().
* Every object and function names are camel-cased, except for functions added to Lua's standard libraries which are all lowercase.
* Every time an argument has to be an asset, you may pass the fully-qualified asset name instead.
* Every time an argument has to be a gameObject instance, you may pass the gameObject name instead.
* Every time an argument has to be an asset or component type, you may pass the asset or component **object** instead (ie : ModelRenderer instead of "ModelRenderer"). And When you do pass the type as a string, it is case insensitive.
* Every optional boolean arguments default to false.


## Dynamic getters and setters

Getters and setters functions (functions that begins by Get or Set) may be used on gameOjects and components as if they were variables :

    self.gameObject.modelRenderer.model = "model name"
    -- is a shortcut for :
    self.gameObject:GetComponent("ModelRenderer"):SetModel(CraftStudio.FindAsset("model name", "Model"))


## Debugging

Daneel's functions features extensive debugging capability.  
Every arguments are checked for type and value and a comprehensive error message is thrown if needed.

For instance, passing false as the gameObject's name with gmeObject:GetChild() would trigger the following error :  

    GameObject.GetChild(gameObject, name[, recursive]) : Argument 'name' is of type 'boolean' with value 'false' instead of 'string'.

### Stack Trace

When an error is triggered, Daneel print a Stack Trace in the Runtime Report.
The Stack Trace nicely shows of the histoy of function calls whithin the framework and display values recieved as argument as well as returned values.


## Mass-Setting

Functions GameObject.New(), GameObject.Instanciate() and GameObject.AddComponent() accept an optional argument "params" that may have diffferent kind of values.
Params may be the gameObject's parent's name (as a string) or instance (GameObject) or a table to fully initialize the new gameObject or its components.

Here are they keys
* parent : the gameObject's parent's name (as a string) or instance (GameObject)
* transform : a tabe with data to initialize the transform component with. Keys may include
 * position : a Vector3
 * localPosition : a Quaternion
 * orientation : a Quaternion
 * localOrientation : a Vector3
 * euleurAngles : a Vector3
 * localEulerAngles : a Vector3
 * localScale : a Vector3 or a number

* modelRenderer : true to add an empty component, 
 *






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

### Daneel.Debug

* Daneel.Debug.CheckArgType(argument, argumentName, expectArgumenType[, errorHead, errorEnd])
* Daneel.Debug.CheckOptionalArgType(argument, argumentName, expectArgumenType[, errorHead, errorEnd])
* Daneel.Debug.GetType(object) 
* Daneel.Debug.PrintError(message)

### Daneel.Events

* Daneel.Events.Listen(eventName, function)
* Daneel.Events.StopListen(eventName, function)
* Daneel.Events.Fire(eventName[, ...])

### Daneel.StackTrace

* Daneel.StackTrace.BeginFunction(functionName[, ...])
* Daneel.StackTrace.EndFunction(functionName[, ...])
* Daneel.StackTrace.Print(length)

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

* gameObject:AddComponent(componentType[, params])
* gameObject:AddScriptedBehavior([params])
* gameObject:AddModelRenderer([params])
* gameObject:AddMapRenderer([params])
* gameObject:AddCamera([params])

* gameObject:SetComponent(componentType, params)
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

### Ray

* ray:Cast()
* ray:IntersectsGameObject(gameObject)

### RaycastHit

* RaycastHit.New([distance, normal, hitBlockLocation, adjacentBlockLocation, gameObject])

### string

* string.totable(string)
* string.isoneof(string, table[, ignoreCase])
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

