# Overview

Daneel is a framework for [CraftStudio](http://craftstu.io) that aims to sweeten and extends the API as well as to bring news fonctionnalities.


# Daneel and the existing CraftStudio's API

Daneel never deprecate anything from the current CraftStudio's API. The whole API remains usable in its entirety as decribed in the [scripting reference]() on the offical wiki.
Daneel mostly add new objects and functions (on existing objects) and sometimes allow to pass different argument type on existing functions.



# Conventions

* Every fonctions that get something are called GetSomething() and not FindSomething().
* Every object and function name are camelcased, variable names are  **except** for Lua's standard libraries extension that have every name all lower cases.
* Every time an argument has to be an asset or gameObject, you may pass the asset or gameObject **name** instead.
* Every time an argument has to be an asset or component type, you may pass the actuall asset's or component's object instead of it's name. And When you do pass the name as a string, it is case insensitive.
* Every optional boolean argument are defaulted to false.


# Dynamic getters and setters

Getters and setters functions (functions that begins by Get or Set) may be used on gameOject and components as if they were variable.
Ie :
self.gameObject:GetComponent("ModelRenderer"):SetModel(CraftStudio.FindAsset("model name"))
-- this line above can be written as the one below :
self.gameObject.modelRenderer.model = "model name"


# Debugging

Daneel's functions features extensive debugging capability.
Every argument are checked for value and type and a cromprehensive error message is thrown.

Ie passing false as the gameObject's name  with gmeObject:GetChild() would trigger the following error :
GameObject.GetChild(gameObject, name[, recursive]) : Argument 'name' is of type 'boolean' with value 'false' instead of 'string'.

## Stack Trace

When an error is triggered, Daneel print a Stack Trace in the Runtime Report.
The Stack Trace nicely inform of the histoy of function calls whithin the framework and display values received as argument as well as values returned by functions.



#  List of functions

See the scripting reference for full explation on arguments and returned values.

## Asset

* Asset.Get(assetName[, assetType])
* Asset.Get[asset type](assetName)   ie : Asset.GetModel("model name")
* Asset.GetType(asset)
* Asset.IsOfType(asset, assetType)
* Asset.Is[asset type](asset)   ie : Asset.IsScript(asset)

## Daneel.Debug

* Daneel.Debug.CheckArgType(argument, argumentName, expectArgumenType[, errorStart, errorEnd])
* Daneel.Debug.CheckOptionalArgType(argument, argumentName, expectArgumenType[, errorStart, errorEnd])
* cstype() 

## Daneel.Events

* Daneel.Events.Listen(eventName, function)
* Daneel.Events.StopListen(eventName, function)
* Daneel.Events.Fire(eventName[, ...])

## Daneel.StackTrace

* Daneel.StackTrace.BeginFunction(functionName[, ...])
* Daneel.StackTrace.EndFunction(functionName[, ...])
* Daneel.StackTrace.Print(length)
* daneelerror() -- like Lua's built-in error() but print the stack trace in the Runtime Report first

## Daneel.Utilities



## GameObject

* GameObject.New(name[, params])
* GameObject.Instanciate(goName, sceneName[, params])
* GameObject.Get(name)

* gameObject:SetParent(parentNameOrObject[, keepLocalTransform])
* gameObject:GetChild(childName[, recursive])
* gameObject:GetChildren([recursive, includeSelf])
* gameObject:BroadcastMessage(functionName[, data])

* gameObject:AddComponent(componentType[, params])
* gameObject:Add[component type]([params])      ie : gameObject:AddMapRederer()

* gameObject:GetComponent(componentType)
* gameObject:GetScriptedBehavior(scriptNameOrAsset)
* gameObject:Get[component type]()          ie : gameObject:GetCamera()

* gameObject:HasComponent(componentType)
* gameObject:Has[component type]()

* gameObject:Destroy()
* gameObject:DestroyComponent(input[, strict])
* gameObject:DestroyScriptedBehavior(input[, strict])
* gameObject:Destroy[component type]()      ie : gameObject:DestroyModelRenderer()

## GUILabel

* GUILabel.New(name[, params])
* guiLabel:Refresh()
* guiLabel:SetPosition()
* guiLabel:SetScale(scale)
* guiLabel:SetText(text)
* guiLabel:Destroy()

## math

Extension of lua's standard math library
* math.isinteger(value[, strict])

## Ray

* ray:Cast()
* ray:IntersectGameObject(gameObject)

## RaycastHit

* RaycastHit.New([distance, normal, hitBlockLocation, adjacentBlockLocation, gameObject])

## string

Extension of lua's standard table library
* string.totable(string)
* string.isoneof(string, table[, ignoreCase])
* string.ucfirst(string)

## table

Extension of lua's standard table library

* table.new([table])
* table.new([...])
Tables returned by table.new() are said to be *dynamic* and may be used in an object-oriented way :
t = table.new()
t:insert(pos, value)

All table functions that returne a tabl, returns a dynamic table.

* table.copy(table)
* table.constainskey(table, key)
* table.constainsvalue(table, value[, ignoreCase])
* table.length(table[, keyType])
The variable *length* can be used as a shortcut to call table.length() on dynamic tables :
t.length

* table.print()
* table.printmetatable()
* table.merge(...)
table.merge() is implicitely sed when used the + operato on two dynamic tables :
t = t1 + t2
* table.compare(table1, table2)
* tabe.combine(keys, values[, strict])
* table.removevalue(table, value[, singleRemove])





