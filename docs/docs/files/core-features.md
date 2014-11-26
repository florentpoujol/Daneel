# Core features

This page presents some of the features deemed as the most important ones to be aware of.

<table class="page-menu">
	<tr>
		<td>
			<ul>
				<li><a href="#extension-lua-libraries">Extension of Lua base libraries</a></li>
				<li><a href="#dynamic-functions">Dynamic functions</a></li>
				<li><a href="#objects-as-function">Using objects as functions to create instances</a></li>
				<li><a href="#instances-id">Instances-id</a></li>
				<li><a href="#printing-out-instances">Printing out instances</a></li>
				<li><a href="#gameobject-tags">GameObject Tags</a></li>
			</ul>
		</td>
		<td>
			<ul>
				<li><a href="#mass-setting">Mass-setting</a></li>
				<li><a href="#debugging">Debugging</a></li>
				<li><a href="#events">Events</a></li>
				<li><a href="#modules">Modules</a></li>
				<li><a href="#tween">Tween</a></li>
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
-->

<a name="extension-lua-libraries"></a>
# Extension of Lua's standard libraries

Daneel introduce a lot of new functions in Lua's standard `math`, `string` and `table` libraries.  
All these functions are pure Lua and are not dependent on Daneel or CraftStudio so you can use them in any Lua project.  
[You can check them out on Daneel's GitHub repo](https://github.com/florentpoujol/Daneel/blob/master/framework/Lua.lua).


<a name="dynamic-functions"></a>
# Dynamic functions

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

Game objects, components and other object instances (like [tweeners](/docs/tween)) have a unique Id that you can get via `instance:GetId()`.   
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


<a name="gameobject-tags"></a>
## GameObject Tags

Tags are a convenient way to group or flag game object(s).  

Manage tags on game objects with `gameObject:AddTag()`, `gameObject:GetTags()`, `gameObject:RemoveTag()`, `gameObject:HasTag()`.  
A game object may have several tags and a same tag may be used by several game objects.  

Get all game object(s) that have all of the provided tag(s) with `GameObject.GetWithTag()`.  
Note that this function never returns dead game objects.

Use the `Tags` scripted behavior to add tags to game objects while in the scene editor (concatenate several tags with a coma).  

The tags on a game object are automatically removed when it is destroyed with `gameObject:Destroy()`. 


<a name="mass-setting"></a>
## Mass-setting

The `Set(params)` function that you may call on game objects, components and a few other object ([tweeners](/docs/tween) for instance) accept a `params` argument of type table which allow to set properties or call setters in mass.  
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


<a name="debugging"></a>
## Debugging

Daneel provides extensive error reporting for all its functions.  
Learn more about this on the [debugging page](/docs/debugging).

<a name="events"></a>
## Events

Events are at the core of the communication between many systems introduced by Daneel.   
Learn how they work on the [events page](/docs/events).


<a name="modules"></a>
## Modules

A module is a particular object that Daneel works with when it is loaded and during runtime.   
They are also the way to create custom components.  
Learn more about them on the [modules page](/docs/modules).

<a name="tween"></a>
## Tween

The Tween object allow you to create timers as well as tweeners that enables you to automate the animation of object properties.  
Learn more about this on the [Tween page](/docs/tween).

Example of animation

 	-- fade out animation in 0.5 second with callback function when the animation has completed
    self.gameObject:Animate( "opacity", 0, 0.5, function(go) ... end )
