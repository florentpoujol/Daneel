# Tween

The `Tween` object allows you to create and manipulate `Tweeners` and `Timers`.  

- [Tweener](#tweener)
- [Timer](#timer)
- [Game object animation](#gameobject-animate)

<a name="tweener"></a>
## Tween.Tweener

`Tweener`s are objects that interpolate a value or the property of an object from a `startValue` to an `endValue` during a `duration`, optionally using an `easing` equation.  

Tweeners can work with `number`, `Vector2`, `Vector3` and `string` (it display the text one letter at a time).  

The "property" may be virtual in that it just need to match the name of a couple of getter/setter (ie : `"position"` for `transform:Get/SetPosition()`). 

Create a tweener using one of the following constructors :

- `Tween.Tweener.New( target, property, endValue, duration[, params] )`
- `Tween.Tweener.New( startValue, endValue, duration[, params] )`
- `Tween.Tweener.New( params )`

### Parameters

The properties of a tweener you can set are described below. Except for the ones that are arguments of the contructors, they are all optionnals.  
Like for game objects and components, you may mass-set properties on tweeners during their creation or afterward via `tweener:Set({params})`.

- `target` (table) : Any object or table that has the specified property (or corresponding getter/setter).
- `property` (string) : The target's property to animate the value of.
- `startValue` (number, Vector2, Vector3 or string) : The value to starts the tweener at. If not set, it will be set at the current value of the target's property.
- `endValue` (number, Vector2, Vector3 or string) : The value to ends the tweener at.
- `duration` (number) : The time or frames the tweener (one loop, actually) should take (in `durationType` units).
- `durationType` (string) [default="time"] : The unit of time for `delay`, `duration`, `elapsed` and `fullElapsed`. Can be `"time"`, `"realTime"` or `"frame"`. If set to `"time"`, the tweener is tied to [the time scale](/docs/features#time-object).
- `isEnabled` (boolean) [true]: A disabled tweener won't update and the functions like `Play()`, `Pause()`, `Complete()`, `Destroy()` will have no effect.
- `isPaused` (boolean) [false] : A paused tweener doesn't update.
- `delay` (number) [0] : The delay before the tweener starts (in `durationType` unit). The delay do not updates when the tweener is paussed. 
- `loops` (number) [1] : The number of loops to run. Set to `-1` for an infinite loop. Tweeners always run at least one loop, so a value of 0 or 1 does not make any differences.
- `loopType` (string) ["simple"] : The type of the loop. Possible values are `"simple"` (X to Y, and repeat) or `"yoyo"` (X to Y the first loop, then Y to X the next loop, and repeat)
- `isRelative` (boolean) [false] : Tell wether `endValue` is an absolute value or is relative to `startValue`. If false, tween the value TO endValue. If true, tween the value BY endValue.
- `destroyOnComplete` (boolean) [true] : Tell wether to destroy the tweener when it completes. You may reuse non-destroyed tweeners by restarting them with the `Restart()` function.
- `destroyOnSceneLoad` (boolean) [true] : Tell wether to destroy the tweener when a new scene is loaded
- `easeType` (string) ["linear"] : The type of easing to apply to the value. This will impact how the value change over time. Possible values are :
	- linear
	- inQuad, outQuad, inOutQuad, outInQuad
	- inCubic, outCubic, inOutCubic, outInCubic
	- inQuart, outQuart, inOutQuart, outInQuart
	- inQuint, outQuint, inOutQuint, outInQuint
	- inSine, outSine, inOutSine, outInSine
	- inExpo, outExpo, inOutExpo, outInExpo
	- inCirc, outCirc, inOutCirc, outInCirc
	- inElastic, outElastic, inOutElastic, outInElastic
	- inBack, outBack, inOutBack, outInBack
	- inBounce, outBounce, inOutBounce, outInBounce

Other properties :

- `Id`
- `value` (number) : The current value.
- `hasStarted` (boolean) : Become true when the tweener started updating the value (stays false as long as the delay is superior to zero).
- `isCompleted` (boolean) : True when all loops are completed. The tweener then stops running.
- `elapsed` (number) : The time or frames (in `durationType` unit) that have passed since the beginning of the current loop, delay and pauses excluded.
- `fullElapsed` (number) : The total time or frames (in `durationType` unit) that have passed since the tweener started, delay and pauses excluded.
- `completedLoops` (number) : The number of loops that have been completed.


### Easing functions

Easing functions impact how the tweener's value change over time.
They can be divided into several big families:

- `linear` is the default interpolation. It’s the simplest easing function.
- `quad`, `cubic`, `quart`, `quint`, `expo`, `sine` and `circ` are all "smooth" curves that will make transitions look natural.
- The `elastic` family simulates inertia in the easing, like an elastic gum.
- The `back` family starts by moving the interpolation slightly "backwards" before moving it forward.
- The `bounce` family simulates the motion of an object bouncing.

Each family (except linear) has 4 variants:

- `in` starts slow, and accelerates at the end
- `out` starts fast, and decelerates at the end
- `inOut` starts and ends slow, but it’s fast in the middle
- `outIn` starts and ends fast, but it’s slow in the middle


### Control functions

You may control how the tweener runs via the following functions. The same result may be achieved by setting the corresponding properties (`isEnabled`, `isPaused`, etc...) but the functions also fire the corresponding event. 

- `Pause()` : pause the tweener and fires the `OnPause` event at the tweener.
- `Play()` : unpause the tweener and fires the `OnPlay` event at the tweener.
- `Update()` : update the tweener and fires the `OnUpdate` event at the tweener.
- `Complete()` : complete the tweener and fires the `OnComplete` event at the tweener.
- `Restart()` : completely restart the tweener, including the loops. The `OnStart` event will be fired again the next time the tweener starts
- `Destroy()` : disable the tweener and remove it from the list of tweener.

You may fast-forward or (fast-rewind) a tweener by changing the value of the `elapsed` property then by calling the `Update()` function.  


### Tweener events

They are fired at the tweener, passing the tweener as first and only argument.

- `OnStart` : when the tweener starts, when the delay is equal to zero (only called once, before the first loop begins). May be called again if the tweener is restarted via `Restart()`.
- `OnPause` : when the tweener is paused via `Pause()`.
- `OnPlay` : when the tweener is unpaused via `Play()`.
- `OnUpdate` : when the tweener is updated.
- `OnLoopComplete` : when the tweener has completed one loop and at least one loop remains to complete.
- `OnComplete` : when the tweener has completed all its loops (never called for infinite loops).

### Examples
	
	function Behavior:Start()
		-- Example 1 :
		Tween.Tweener.New( self.gameObject.modelRenderer, "opacity", 0, 10, { 
	        loops = -1,
	        loopType = "yoyo",
	        durationType = "frame",
	        OnUpdate = function( tweener ) print( "The model's opacity is " .. tweener.value ) end,
	   	} )
	   	-- this tweener makes the model's opacity goes down to 0 then back up to 1 in 20 frames


	   	-- Example 2 :
	   	-- tweener also makes great timers :
	   	local tweener = Tween.Tweener.New( 10, 0, 10, { 
	   		isPaused = true,

	   		OnUpdate = function( tweener )
	   			self.gameObject.textRenderer.text = math.floor( tweener.value )
	   		end
	   	} )
	   	tweener.OnComplete = function() print("Boom !") end
	   	tweener:Play()
	   	-- in this example, the tweener "count" from 10 to 0 in 10 seconds and displays the time remaining via a textRenderer, then prints "Boom !" when the time is up


	   	-- Example 3 :
	   	Tween.Tweener.New( {
	   		target = self.gameObject.transform,
	   		property = "localScale",
	   		startValue = Vector3:New(0.7),
	   		endValue = Vector3:New(1),
	   		duration = 1, -- time
	        loops = -1,
	        loopType = "yoyo",
	   	} )
	   	-- in this example, we animate the game object's local scale to create a "heart beat" effect
	end

<a name="timer"></a>
## Timer

The `Tween.Timer` object, which only provides the `New()` function, is just a convenient interface to create tweeners used as timers.  

Create a timer with one of the following constructors (which return a regular tweener) : 

- `Tween.Timer.New( duration, OnComplete[, params] )`
- `Tween.Timer.New( duration, OnLoopComplete, true[, params] )`

The first one creates a one-time timer which calls the function provided as second argument at the end of the duration.  
The second one creates an infinite looping timer which calls the provided function everytime the duration passes.

In both cases, the tweener's `endValue` is `0` while `startValue` has the value of the `duration`.  
You may customize the tweener (time unit, paused state, etc...) via the optional `params` argument.


	Tween.Timer.New( 5, CS.Exit ) -- exit the game in 5 seconds 
	-- is the same as :
	Tween.Tweener.New( 5, 0, 5, {
		OnComplete = CS.Exit
	} )


	Tween.Timer.New( 10, function() self:DoSomethingRepeatedly() end, true ) 
	-- call self:DoSomethingRepeatedly() every 10 seconds

	-- is the same as :
	Tween.Tweener.New( 10, 0, 10, {
		loops = -1,
		OnLoopComplete = function()
			self:DoSomethingRepeatedly()
		end
	})

<a name="gameobject-animate"></a>
## Game object animations

To easily works with tweeners and game objects, you can use the following function : `GameObject.Animate(gameObject, property, endValue, duration[, onCompleteCallback, params])`.

Ie : 

    self.gameObject:Animate( "opacity", 0, 1, function() self.gameObject:Destroy() end )
    -- this fades the opacity of the game object's (model, map or text) renderer to 0 in 1 second then destroy the game object

This also works with custom components :
    
    -- The Hud component introduced by the GUI module :
    local slideInTweener = self.gameObject:Animate("localPosition", Vector2(10,0), 1, { easeType = "inElastic" })
    -- in this case, the Animate() function will automatically detect that the target component is the hud component and not the transform

    -- The LineRenderer component introduced by the Draw module :
    self.gameObject:Animate("length", 10, 1)
    -- this updates the line renderer's length to 10 units over the course of 1 second

Remember that the "property" may be virtual in that it just need to match the name of a couple of getter/setter. Ie :

- `"opacity"` for `modelRenderer:Get/SetOpacity()`, also works for the map, circle and text renderers, as well as for the text area.
- `"length"` for `lineRenderer:Get/SetLength()`.
- `"position"` for `transform:Get/SetPosition()`, also works for the hud component.
- `"text"` for `textRenderer:Get/SetText()`. __Doesn't automatically work__ for text areas, you have to specify the target (the text area component) via the `params` table.
- ...
