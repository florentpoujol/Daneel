# Features

This page presents some of the features provided by the framework.  
Be sure to also read the pages dedicated to _objects_ and _components_.  
And make sure you explored the _[function reference](function-reference)_ to find out and have detailed info about all the functions you can use.

<table class="page-menu">
	<tr>
		<td>
			<ul>
				<li><a href="#extension-lua-libraries">Extension of Lua base libraries</a></li>
				<li><a href="#dynamic-functions">Dynamic functions</a></li>
				<li><a href="#objects-as-function">Using objects as functions</a></li>
				<li><a href="#instances-id">Instances-id</a></li>
				<li><a href="#printing-out-instances">Printing out instances</a></li>
				<li><a href="#mass-setting">Mass-setting</a></li>
				<li><a href="#events">Events</a></li>
			</ul>
		</td>
		<td>
			<ul>
				<li><a href="#debugging">Debugging</a></li>
				<li><a href="#tween">Tween</a></li>
				<li><a href="#gameobjects">Game objects</a></li>
				<li><a href="#components">Components</a></li>
				<li><a href="#destroying-objects">Destroying objects</a></li>
				<li><a href="#asset">Asset</a></li>
			</ul>
		</td>
		<td>
			<ul>
				<li><a href="#scene">Scene</a></li>
				<li><a href="#raycasting">Raycasting</a></li>
				<li><a href="#input">Input</a></li>
				<li><a href="#time">Time</a></li>
				<li><a href="#screen">Screen</a></li>
				<li><a href="#webplayer">WebPlayer</a></li>
			</ul>
		</td>
	</tr>
</table>

<!--
- [Extension of Lua base libraries](/#extension-lua-libraries) 
- [Dynamic functions](#dynamic-functions)
- [Using objects as functions to create instances](#objects-as-function)
- [Instances Id](#instances-id)
- [Printing out instances](#printing-out-instances)
- [GameObject Tags](#gameObject-tags)           
- [Mass-setting](#mass-setting)
- [Debugging](#debugging)
- [Events](#events)
- [Modules](#modules)
- [Tween](#tween)
- [Asset](#asset)
- [Components](#components)
- [Destroying objects](#destroying-objects)
- [Game objects](#game-objects)
    - [Getting game objects](#getting-game-objects)
- [Input](#input)
- [Raycasting](#raycasting)
- [Scene](#scene)
- [Screen](#screen)
- [Time object](#time-object)
- [Web Player](#webplayer)
-->

<a name="extension-lua-libraries"></a>
## Extension of Lua's standard libraries

Daneel introduce a lot of new functions in Lua's standard `math`, `string` and `table` libraries.  
All these functions are pure Lua and are not dependent on Daneel or CraftStudio so you can use them in any Lua project.  
[You can check them out on Daneel's GitHub repo](https://github.com/florentpoujol/Daneel/blob/develop/src/Lua.lua).

Some noteworthy functions :

- `table.containsvalue( t, value )` tell if the table contains the value.
- `table.removevalue( t, value )` remove all occurrences of the value in the table.
- `table.getvalue( t, "foo.bar.whatever" )` search inside a hierarchy of tables.
- `string.split( s, delimiter )` splits the string in several chunks.
- `string.trim( s )` remove the white spaces at the beginning and end of a string.
- `string.ucfirst( s )` and `string.lcfirst( s )` change the case of the first letter to uppercase or lowercase, respectively.
- `table.print( t )` and `table.printr( t )` (r for recursive) beautifully prints the content of the table (see examples below).
- `table.merge( t1, t2 )` merge (with optional recursion) several tables together. `table.mergein( t1, t2 )` does it inside the first table as argument.

Ie :

	local t1 = { 1, 2, key = "value" }
	local t2 = { 3, key = "other value", otherKey = "value" }
	table.mergein( t1, t2 )
	
	table.print( t1 ) -- this print in the Runtime Report :
	~~~~~ table.print(table: 080A3C88) ~~~~~ Start ~~~~~
	1	3
	2	2
	key	other value
	otherKey	value
	~~~~~ table.print(table: 080A3C88) ~~~~~ End ~~~~~

	t1.t1 = t1
	t1.t2 = {
		1, key = "value", t1 = t1,
		t3 = { otherKey = 1, 2 }
	}

	table.printr( t1 ) -- this print in the Runtime Report :
	~~~~~ table.printr(table: 080A3C88) ~~~~~ Start ~~~~~
	1	3
	2	2
	"t2"	table: 082C85A0
	| - - - 1	1
	| - - - "t3"	table: 081B8330
	| - - - | - - - 1	2
	| - - - | - - - "otherKey"	1
	| - - - "key"	"value"
	| - - - "t1"	Table currently being printed: table: 080A3C88
	"t1"	Table currently being printed: table: 080A3C88
	"key"	"other value"
	"otherKey"	"value"
	~~~~~ table.printr(table: 080A3C88) ~~~~~ End ~~~~~


<a name="dynamic-functions"></a>
## Dynamic functions

Getters and setters functions can be accessed in a dynamic way, as if they were simple properties on game objects, components and assets.

The name of the functions must begin by `Get` or `Set` and have the forth letter upper-case (underscore is allowed).  
Ie : `GetSomething()` and `Get_something()` will work, but `Getsomething()` or `getSomething()` won't work.

    local pos = self.gameObject.transform.localPosition
    -- is the same as
    local pos = self.gameObject.transform:GetLocalPosition()

    self.gameObject.name = "a new name"
    -- is the same as 
    self.gameObject:SetName( "a new name" )
    -- note that only one argument (in addition to the object the function works on) can be passed to the function.

You can enable this behavior on any of your objects with `Daneel.Utilities.AllowDynamicGettersAndSetters(Object[, ancestors])`. The `Object` argument should be the metatable of the instances you want to use this feature on. 


<a name="objects-as-function"></a>
## Using objects as functions to create instances

You may create instances of `GameObject`, `Vector3`, `Vector2`, `Quaternion`, `Plane`, `Ray`, `RaycastHit`, `Tween.Tweener` and `Tween.Timer` without the `New()` function, just by using the object as if it was a function :

    Vector3( 10 ) -- same as  Vector3:New( 10 )
    Tween.Timer( 2, function() ... end ) -- same as Tween.Timer.New( 2, function() ... end )

<a name="instances-id"></a>
## Instances Id

Game objects, components and other object instances (like [tweeners](tween)) have a unique Id that you can get via `instance:GetId()`.   
Data objects like `Vector3` don't have ids.

If you need to generate such unique Id, `Daneel.Utilities.GetId()` returns a strictly positive integer incremented every times.

<a name="printing-out-instances"></a>
## Printing out instances

Game objects, components, assets and most other objects will nicely prints themselves in the Runtime Report when passed to the `print()` function. The type of the instance is followed by its Id and other relevant data like a game object name or an asset path. Ie :
    
    GameObject: 123456789: 'MyObject'
    ModelRenderer: 123456789
    Model: 123456789: 'Folder/ModelName'
    Vector3: { x=123, y=456.7, z=89 }

You can use `Daneel.Debug.ToRawString()` to bypass this behavior and return the memory address of the table instead.


<a name="mass-setting"></a>
## Mass-setting

The `Set(params)` function that you may call on game objects, components and a few other object ([tweeners](tween) for instance) accept a `params` argument of type table which allow to set properties or call setters in mass.  
Mass-setting is used by every functions that have a `params` argument.

    self.gameObject.textRenderer:Set({
        alignment = "right", -- Set the text renderer's alignment via TextRenderer.SetAlignment()
        randomVariable = "random value"
    })

    self.gameObject:Set({
        parent = "my parent name", -- Set the parent via GameObject.SetParent()

        modelRenderer = {
            opacity = 0.5 -- Set the  model renderer's opacity to 0.5 via ModelRenderer.SetOpacity()
        }
    })

Note that with `gameObject:Set()`, components that are set but don't exists yet will be created.  
Ie: in the example above, if the game object hadn't a model renderer, it would be created before being set.


<a name="events"></a>
## Events

Events are at the core of the communication between many systems introduced by Daneel.   
Learn how they work on the [event page](event).

<a name="debugging"></a>
## Debugging

Daneel provides extensive error reporting for all its functions.  
Learn more about this on the [debugging page](debug).

<a name="tween"></a>
## Tween

The Tween object allow you to create timers as well as tweeners that enables you to automate the animation of object properties.  
Learn more about this on the [Tween page](tween).

Example of animation :

 	-- fade out animation in 0.5 second with callback function when the animation has completed
    self.gameObject:Animate( "opacity", 0, 0.5, function(go) ... end )


<a name="gameobjects"></a>
## Game objects

Create a game object with `GameObject.New()` or `GameObject.Instantiate()`.

Add a component on a game object with `gameObject:AddComponent(componentType[, params])` (also works for scripted behaviors and [custom components](#components)).  

Send a message to a game object and all of its descendants with `gameObject:BroadcastMessage()`.

The `GameObject` object has been extended with many functions, check out the [function reference](function-reference) to learn about all of them.

<a name="gameobject-tags"></a>
### Tags

Tags are a convenient way to group or flag game object(s).  

Manage tags on game objects with `gameObject:AddTag()`, `gameObject:GetTags()`, `gameObject:RemoveTag()`, `gameObject:HasTag()`.  
A game object may have several tags and a same tag may be used by several game objects.  

Get all game object(s) that have all of the provided tag(s) with `GameObject.GetWithTag()`.  
Note that this function never returns dead game objects.

Use the `Tags` scripted behavior to add tags to game objects while in the scene editor (concatenate several tags with a coma).  

The tags on a game object are automatically removed when it is destroyed with `gameObject:Destroy()`.

<a name="getting-game-objects"></a>
### Getting game objects

Get a game object with `GameObject.Get(name)` and get a child with `gameObject:GetChild([name, recursive])`. The `name` argument in `GetChild()` is optional so that writing `gameObject.child` returns the first child (if any) of the game object.   
The `name` argument in these functions may be a hierarchy of game objects (several names separated by dots). The functions will return the lowest child in the hierarchy (the last name) that has the specified ancestry.  

With `GameObject.Get()`, the hierarchy must be continuous but you may skip levels with `GetChild()` when the `recursive` argument is `true`.
    
    -- Suppose we have the following hierarchy : World > Map > Background > Model

    local gameObject = GameObject.Get( "World" ) -- returns the first game object named "World"

    GameObject.Get( "Map" ) -- returns the first game object named "Map"
    -- is equivalent to :
    gameObject:GetChild( "Map" )

    GameObject.Get( "Map.Background" ) -- return the first child named "Background" of the first game object named "Map"
    -- is equivalent to :
    GameObject.Get( "Map" ):GetChild( "Background" )
    gameObject:GetChild( "Background", true ) -- gameObject:GetChild( "Background" ) returns nil
    gameObject:GetChild( "Map.Background" )

    
    GameObject.Get( "Map.Background.Model" )
    -- is equivalent to : 
    gameObject:GetChild( "Map.Background.Model" )
    gameObject:GetChild( "Map.Model", true )
    gameObject:GetChild( "Model", true )


<a name="components"></a>
## Components

You may call `component:Set(params)`, `component:Destroy()` and `component:GetId()` on any components, built-in (`Transform`, `ModelRenderer`, ...) or custom ones (`GUI.Hud`, `Trigger`, ...).

Custom components are components that are not introduced by CraftStudio. Learn how to create them [through modules](modules).

The framework introduce a total of nine new components :

- [`MouseInput`](mouse-input) enables you to easily make game objects react to mouse inputs.
- [`Trigger`](trigger) enables you to implement distance-based behaviors between game objects.
- The [`GUI`](gui) components will come handy when you are about to create a HUD and other UI elements (text input, multi-line text, progress bar, toggle button, ...).


<a name="destroying-objects"></a>
## Destroying objects

All destroyed objects (with `object:Destroy()` or `CS.Destroy()`) gets the `isDestroyed` property set to `true` and the `OnDestroy` local event fired at.


<a name="asset"></a>
## Asset 

Get an asset with `Asset.Get( path[, type] )`.  
You can use the asset object as a function, it is a shortcut for the `Get` function`:
    
    Asset( "my asset name" )
    -- is the same as
    Asset.Get( "my asset name" )
    CS.FindAsset( "my asset name" )

Get an asset path with `asset:GetPath()`.  
Get an asset name with `asset:GetName()`. The name is the last segment of the path.

    -- for an asset whose path is "folder/folder 2/My Asset Name"
    asset:GetPath() -- returns "folder/folder 2/My Asset Name"
    -- remember you can also use the dynamic functions with assets, so 'asset.path' would works too

    asset.name -- (or asset:GetName()) returns "My Asset Name"

Every functions that expected an asset object as argument, now also accept an asset path (as a string).  
This, combined with the dynamic functions allows to write very short instructions :

	self.gameObejct.modelRenderer.model = "Folder/My Model"
	-- instead of
	self.gameObject.modelRenderer:SetModel( CraftStudio.FindAsset( "Folder/My Model", "Model" ) )


<a name="scene"></a>
## Scene

Load a scene with `Scene.Load()`, append a scene with `Scene.Append()`.  
Loading a scene fires the global event `OnNewSceneWillLoad` before the scene is actually loaded.  
The `Scene.current` property holds the current scene's asset (it is `nil` until `Scene.Load()` or `CS.LoadScene()` is called for the first time).


<a name="raycasting"></a>
## Raycasting

The `RaycastHit` object stores the information regarding the collision between a ray and a game object. It may contains the keys `distance`, `normal`, `hitBlockLocation`, `adjacentBlockLocation`, `hitPosition` (the coordinates in scene units), `hitObject` (the component or the plane that has been hit) and `gameObject`.

The function `ray:IntersectsGameObject(gameObjectNameOrInstance)` returns a raycastHit (a `RaycastHit` instance) if the ray intersects the game object, or nil.  

The function `ray:Cast(gameObjects[, sortByDistance])` cast the ray against the provided set of game objects and returns a table of raycastHits (which will be empty if no game object has been hit).  
The table may be sorted by distance, the closest hit being the first item in the returned table.

The functions `ray:IntersectsModelRenderer()`, `ray:IntersectsMapRenderer()`, `ray:IntersectsTextRenderer()` and `ray:IntersectsPlane()` may return a raycastHit instead of several values if their third argument is `true`.


<a name="input"></a>
## Input

You can check if the mouse is locked or not via the `CS.Input.isMouseLocked` property (a boolean).  
You may toggle the locked state of the mouse with the `CS.Input.ToggleMouseLock()` function.


<a name="time"></a>
## Time

The Time object provides several properties that lets you keep track of time.  

- Daneel.Time.frameCount

The number of frames since the game started.

- Daneel.Time.realTime

The time in seconds -since the game started- at which the last frame started. Not affected by the time scale.

- Daneel.Time.realDeltaTime

The time in second it took for the last frame to complete. Not affected by the time scale.  
Multipling a speed 'per second' by `realDeltaTime` (or `deltaTime`) effectively turns it into a speed 'per frame'.

- Daneel.Time.time

The time in seconds -since the game started- at which the last frame started.  
Unlike the real time, the time is affected by the time scale. That means that it may increase or decrease and may be superior or inferior to the real time.

- Daneel.Time.deltaTime

The variation of `Daneel.Time.time` since the last frame. It may be inferior, equal or superior to zero.  

- Daneel.Time.timeScale

The scale at which the time is passing.  
This affect directly `Daneel.Time.deltaTime` (deltaTime = realDeltaTime * timeScale) and thus the rate at which `Daneel.Time.time` increase or decrease.

When the time scale has a negative value, `Daneel.Time.deltaTime` also has a negative value and `Daneel.Time.time` decreases.


<a name="screen"></a>
## Screen

`CS.Screen.aspectRatio` is the screen's aspect ratio.


<a name="webplayer"></a>
## Webplayer

The `CS.IsWebPlayer` property is `true` when the game runs in the web player (`false` otherwise).
