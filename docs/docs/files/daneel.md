# Daneel

__This script is mandatory.__  
It must be the second top-most script in Daneel's folder, just below the `Lua` script.

- [Debugging](/docs/daneel/debugging)
- [Events](/docs/daneel/events)
- [Modules](/docs/daneel/modules)
- [Function Reference](/docs/daneel/function-reference)

---

- [Dynamic functions](#dynamic-functions)
- [Instances Id](#instances-id)
- [Printing out instances](#printing-out-instances)
- [Time object](#time-object)
- [Web Player](#webplayer)


<a name="dynamic-functions"></a>
# Dynamic functions

Getters and setters functions can be accessed in a dynamic way, as if they were simple variables on game objects, components and assets.

Their names must begin by `Get` or `Set` and have the forth letter upper-case (underscore is allowed).  
Ie : `GetSomething()` and `Get_something()` will work, but `Getsomething()` or `getSomething()` won't work.

    local pos = self.gameObject.transform.localPosition
    -- is the same as
    local pos = self.gameObject.transform:GetLocalPosition()

    self.gameObject.name = "a new name"
    -- is the same as 
    self.gameObject:SetName( "a new name" )
    -- note that only one argument (in addition to the object the function works on) can be passed to the function.

You can enable this behavior on any of your objects with `Daneel.Utilities.AllowDynamicGettersAndSetters(Object[, ancestors])`. The `Object` argument should be the metatable of the instances you want to use this feature on. 


<a name="instances-id"></a>
## Instances Id

Game objects, components and other object instances (like [tweeners](/docs/tween)) have a unique Id that you can get via `instance:GetId()`.

If you need to generate such unique Id, `Daneel.Utilities.GetId()` returns a strictly positive integer incremented every times.


<a name="printing-out-instances"></a>
## Printing out instances

Game objects, components, assets and other objects will nicely prints themselves in the Runtime Report when passed to the `print()` function. The type of the instance is followed by its Id and other relevant data like a game object name or an asset path. Ie :
    
    GameObject: 123456789: 'MyObject'
    ModelRenderer: 123456789
    Model: 123456789: 'Folder/ModelName'

You can use `Daneel.Debug.ToRawString()` to bypass this behavior and return the memory address of the table instead.


<a name="time-object"></a>
## Time Object

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


<a name="webplayer"></a>
## Webplayer

The `CS.IsWebPlayer` property is `true` when the game runs in the web player (`false` otherwise).
