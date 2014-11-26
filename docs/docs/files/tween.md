# Tween

The `Tween` object allows you to create and manipulate `Tweeners` and `Timers`.  
Require the `CraftStudio` script.  

- [Configuration](#configuration)
- [Tweener](#tweener)
- [Timer](#timer)
- [GameObject helper functions](#helper-functions)
- [Function reference](#function-reference)

<a name="configuration"></a>
## Configuration

You may update the default tweener properties via a `Tween.UserConfig()` global variable.

	function Tween.UserConfig()
		return {
			-- tweeners default parameters
			tweener = {
	            isEnabled = true, -- a disabled tweener won't update and the function like Play(), Pause(), Complete(), Destroy() will have no effect
	            isPaused = false,

	            delay = 0.0, -- delay before the tweener starts (in the same time unit as the duration (durationType))
	            duration = 0.0, -- time or frames the tween (or one loop) should take (in durationType unit)
	            durationType = "time", -- the unit of time for delay, duration, elapsed and fullElapsed. Can be "time", "realTime" or "frame"

	            startValue = nil, -- it will be the current value of the target's property
	            endValue = 0.0,

	            loops = 0, -- number of loops to perform (-1 = infinite)
	            loopType = "simple", -- type of loop. Can be "simple" (X to Y, repeat), "yoyo" (X to Y, Y to X, repeat)
	            
	            easeType = "linear", -- type of easing, check the doc or the end of the "Daneel/Tween" script for all possible values
	            
	            isRelative = false, -- If false, tween the value TO endValue. If true, tween the value BY endValue.

	            destroyOnComplete = true, -- tell wether to destroy the tweener (true) when it completes
	            destroyOnSceneLoad = true, -- tell wether to destroy the tweener (true) when a new scene is loaded
	        }
	    }
	end

<a name="tweener"></a>
## Tween.Tweener

`Tweener`s are objects that interpolate a value or the property of an object from a `startValue` to an `endValue` during a `duration`, optionally using an `easing` equation.  

Tweeners can work with `number`, `Vector2`, `Vector3` as well as text (`string`) (it display the text one letter at a time).  

The "property" may be virtual in that it just need to match the name of a couple of getter/setter (ie : `"position"` for `transform:Get/SetPosition()`). 

Create a tweener using one of the following constructors :

- `Tween.Tweener.New( target, property, endValue, duration[, params] )`
- `Tween.Tweener.New( startValue, endValue, duration[, params] )`
- `Tween.Tweener.New( params )`

### Parameters

The properties of a tweener you can set are described below. Except or the ones that are arguments of the contructors, they are all optionnals. Their default value may be changed via the config as explained above.  
Like for game objects and components, you may mass-set properties on tweeners during their creation or afterward via `tweener:Set({params})`.

- `target` (table) : Any object or table that has the specified property (or corresponding getter/setter).
- `property` (string) : The target's property to animate the value of.
- `startValue` (number, Vector2, Vector3 or string) : The value to starts the tweener at. If not set, it will be set at the current value of the target's property.
- `endValue` (number, Vector2, Vector3 or string) : The value to ends the tweener at.
- `duration` (number) : The time or frames the tweener (one loop, actually) should take (in `durationType` units).
- `durationType` (string) : The unit of time for `delay`, `duration`, `elapsed` and `fullElapsed`. Can be `"time"`, `"realTime"` or `"frame"`. If set to `"time"`, the tweener is tied to [the time scale](/docs/daneel#time-object).
- `isEnabled` (boolean) : A disabled tweener won't update and the functions like `Play()`, `Pause()`, `Complete()`, `Destroy()` will have no effect.
- `isPaused` (boolean) : A paused tweener doesn't update.
- `delay` (number) : The delay before the tweener starts (in `durationType` unit). The delay do not updates when the tweener is paussed. 
- `loops` (number) : The number of loops to run. Set to `-1` for an infinite loop. Tweeners always run at least one loop, so a value of 0 or 1 does not make any differences.
- `loopType` (string) : The type of the loop. Possible values are `"simple"` (X to Y, and repeat) or `"yoyo"` (X to Y the first loop, then Y to X the next loop, and repeat)
- `isRelative` (boolean) : Tell wether `endValue` is an absolute value or is relative to `startValue`. If false, tween the value TO endValue. If true, tween the value BY endValue.
- `destroyOnComplete` (boolean) : Tell wether to destroy the tweener when it completes. You may reuse non-destroyed tweeners by restarting them with the `Restart()` function.
- `destroyOnSceneLoad` (boolean) : Tell wether to destroy the tweener when a new scene is loaded
- `easeType` (string) : The type of easing to apply to the value. This will impact how the value change over time. Possible values are :
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

- linear is the default interpolation. It’s the simplest easing function.
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

<a name="helper-functions"></a>
## Helper functions

To easily works with tweeners and game objects, the Tween module also adds the two following functions :

- `GameObject.Animate(gameObject, property, endValue, duration[, onCompleteCallback, params])`
- `GameObject.AnimateAndDestroy()`

`AnimateAndDestroy()` is the same  as `Animate()` but automatically destroy the game object when the tweener completes. This behavior is overridden if you set the OnComplete callback yourself.

Ie : 

    self.gameObject:Animate( "opacity", 0, 1, function() self.gameObject:Destroy() end )
    -- this fades the opacity of the game object's (model, map or text) renderer to 0 in 1 second then destroy the game object

    -- this does the same:
    self.gameObject:AnimateAndDestroy("opacity", 0, 1)

This also works with the components introduced by modules :
    
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


<a name="function-reference"></a>
## Function Reference

<table class="function_list">
    
        <tr>
            <td class="name"><a href="#GameObject.Animate">GameObject.Animate</a>( gameObject, property, endValue, duration, onCompleteCallback, params )</td>
            <td class="summary">Creates an animation (a tweener) with the provided parameters.</td>
        </tr>
    
        <tr>
            <td class="name"><a href="#GameObject.AnimateAndDestroy">GameObject.AnimateAndDestroy</a>( gameObject, property, endValue, duration, params )</td>
            <td class="summary">Creates an animation (a tweener) with the provided parameters and destroy the game object when the tweener has completed.</td>
        </tr>
    
        <tr>
            <td class="name"><a href="#Tween.Timer.New">Tween.Timer.New</a>( duration, callback, isInfiniteLoop, params )</td>
            <td class="summary">Creates a new tweener via one of the two allowed constructors : <br> Timer.New(duration, OnCompleteCallback[, params]) <br> Timer.New(duration, OnLoopCompleteCallback, true[, params]) <br> </td>
        </tr>
    
        <tr>
            <td class="name"><a href="#Tween.Tweener.Complete">Tween.Tweener.Complete</a>( tweener )</td>
            <td class="summary">Complete the tweener fire the OnComple event.</td>
        </tr>
    
        <tr>
            <td class="name"><a href="#Tween.Tweener.Destroy">Tween.Tweener.Destroy</a>( tweener )</td>
            <td class="summary">Destroy the tweener.</td>
        </tr>
    
        <tr>
            <td class="name"><a href="#Tween.Tweener.New">Tween.Tweener.New</a>( target, property, endValue, duration, onCompleteCallback, params )</td>
            <td class="summary">Creates a new tweener via one of the three allowed constructors : <br> Tweener.New(target, property, endValue, duration[, params]) <br> Tweener.New(startValue, endValue, duration[, params]) <br> Tweener.New(params) </td>
        </tr>
    
        <tr>
            <td class="name"><a href="#Tween.Tweener.Pause">Tween.Tweener.Pause</a>( tweener )</td>
            <td class="summary">Pause the tweener and fire the OnPause event.</td>
        </tr>
    
        <tr>
            <td class="name"><a href="#Tween.Tweener.Play">Tween.Tweener.Play</a>( tweener )</td>
            <td class="summary">Unpause the tweener and fire the OnPlay event.</td>
        </tr>
    
        <tr>
            <td class="name"><a href="#Tween.Tweener.Restart">Tween.Tweener.Restart</a>( tweener )</td>
            <td class="summary">Completely restart the tweener.</td>
        </tr>
    
        <tr>
            <td class="name"><a href="#Tween.Tweener.Update">Tween.Tweener.Update</a>( tweener, deltaDuration )</td>
            <td class="summary">Update the tweener's value based on the tweener's elapsed property.</td>
        </tr>
    
</table>

<dl class="function">
    
        
<dt><a name="GameObject.Animate"></a><h3>GameObject.Animate( gameObject, property, endValue, duration, onCompleteCallback, params )</h3></dt>
<dd>
Creates an animation (a tweener) with the provided parameters.
<br><br>

    <strong>Parameters:</strong>
    <ul>
        
        <li>
          gameObject 
        </li>
        
        <li>
          property (string) The name of the property to animate.
        </li>
        
        <li>
          endValue (number, Vector2, Vector3 or string) The value the property should have at the end of the duration.
        </li>
        
        <li>
          duration (number) The time (in seconds) or frame it should take for the property to reach endValue.
        </li>
        
        <li>
          onCompleteCallback (function) [optional] The function to execute when the tweener has completed.
        </li>
        
        <li>
          params (table) [optional] A table of parameters.
        </li>
        
    </ul>


    <strong>Return value:</strong>
    <ul>(Tweener) The tweener.</ul>

</dd>
<hr>
    
        
<dt><a name="GameObject.AnimateAndDestroy"></a><h3>GameObject.AnimateAndDestroy( gameObject, property, endValue, duration, params )</h3></dt>
<dd>
Creates an animation (a tweener) with the provided parameters and destroy the game object when the tweener has completed.
<br><br>

    <strong>Parameters:</strong>
    <ul>
        
        <li>
          gameObject (GameObject) The game object.
        </li>
        
        <li>
          property (string) The name of the property to animate.
        </li>
        
        <li>
          endValue (number, Vector2, Vector3 or string) The value the property should have at the end of the duration.
        </li>
        
        <li>
          duration (number) The time (in seconds) or frame it should take for the property to reach endValue.
        </li>
        
        <li>
          params (table) [optional] A table of parameters.
        </li>
        
    </ul>


    <strong>Return value:</strong>
    <ul>(Tweener) The tweener.</ul>

</dd>
<hr>
    
        
<dt><a name="Tween.Timer.New"></a><h3>Tween.Timer.New( duration, callback, isInfiniteLoop, params )</h3></dt>
<dd>
Creates a new tweener via one of the two allowed constructors : <br> Timer.New(duration, OnCompleteCallback[, params]) <br> Timer.New(duration, OnLoopCompleteCallback, true[, params]) <br>
<br><br>

    <strong>Parameters:</strong>
    <ul>
        
        <li>
          duration (number) The time or frame it should take for the timer or one loop to complete.
        </li>
        
        <li>
          callback (function or userdata) The function that gets called when the OnComplete or OnLoopComplete event are fired.
        </li>
        
        <li>
          isInfiniteLoop [optional default=false] (boolean) Tell wether the timer loops indefinitely.
        </li>
        
        <li>
          params [optional] (table) A table of parameters.
        </li>
        
    </ul>


    <strong>Return value:</strong>
    <ul>(Tweener) The tweener.</ul>

</dd>
<hr>
    
        
<dt><a name="Tween.Tweener.Complete"></a><h3>Tween.Tweener.Complete( tweener )</h3></dt>
<dd>
Complete the tweener fire the OnComple event.
<br><br>

    <strong>Parameters:</strong>
    <ul>
        
        <li>
          tweener (Tween.Tweener) The tweener.
        </li>
        
    </ul>


</dd>
<hr>
    
        
<dt><a name="Tween.Tweener.Destroy"></a><h3>Tween.Tweener.Destroy( tweener )</h3></dt>
<dd>
Destroy the tweener.
<br><br>

    <strong>Parameters:</strong>
    <ul>
        
        <li>
          tweener (Tween.Tweener) The tweener.
        </li>
        
    </ul>


</dd>
<hr>
    
        
<dt><a name="Tween.Tweener.New"></a><h3>Tween.Tweener.New( target, property, endValue, duration, onCompleteCallback, params )</h3></dt>
<dd>
Creates a new tweener via one of the three allowed constructors : <br> Tweener.New(target, property, endValue, duration[, params]) <br> Tweener.New(startValue, endValue, duration[, params]) <br> Tweener.New(params)
<br><br>

    <strong>Parameters:</strong>
    <ul>
        
        <li>
          target (table) An object.
        </li>
        
        <li>
          property (string) The name of the propertty to animate.
        </li>
        
        <li>
          endValue (number) The value the property should have at the end of the duration.
        </li>
        
        <li>
          duration (number) The time or frame it should take for the property to reach endValue.
        </li>
        
        <li>
          onCompleteCallback (function) [optional] The function to execute when the tweener has completed.
        </li>
        
        <li>
          params (table) [optional] A table of parameters.
        </li>
        
    </ul>


    <strong>Return value:</strong>
    <ul>(Tweener) The Tweener.</ul>

</dd>
<hr>
    
        
<dt><a name="Tween.Tweener.Pause"></a><h3>Tween.Tweener.Pause( tweener )</h3></dt>
<dd>
Pause the tweener and fire the OnPause event.
<br><br>

    <strong>Parameters:</strong>
    <ul>
        
        <li>
          tweener (Tween.Tweener) The tweener.
        </li>
        
    </ul>


</dd>
<hr>
    
        
<dt><a name="Tween.Tweener.Play"></a><h3>Tween.Tweener.Play( tweener )</h3></dt>
<dd>
Unpause the tweener and fire the OnPlay event.
<br><br>

    <strong>Parameters:</strong>
    <ul>
        
        <li>
          tweener (Tween.Tweener) The tweener.
        </li>
        
    </ul>


</dd>
<hr>
    
        
<dt><a name="Tween.Tweener.Restart"></a><h3>Tween.Tweener.Restart( tweener )</h3></dt>
<dd>
Completely restart the tweener.
<br><br>

    <strong>Parameters:</strong>
    <ul>
        
        <li>
          tweener (Tween.Tweener) The tweener.
        </li>
        
    </ul>


</dd>
<hr>
    
        
<dt><a name="Tween.Tweener.Update"></a><h3>Tween.Tweener.Update( tweener, deltaDuration )</h3></dt>
<dd>
Update the tweener's value based on the tweener's elapsed property. Fire the OnUpdate event. This allows the tweener to fast-forward to a certain time.
<br><br>

    <strong>Parameters:</strong>
    <ul>
        
        <li>
          tweener (Tween.Tweener) The tweener.
        </li>
        
        <li>
          deltaDuration [optional] (number) <strong>Only used internaly.</strong> If nil, the tweener's value will be updated based on the current value of tweener.elapsed.
        </li>
        
    </ul>


</dd>
<hr>
    
</dl>

