# Tutorials

- [How to animate game objects](#animate-game-objects)
- [How to use timers](#timer)
- [How to know if an object is close to another object, or inside an area](#trigger)
- How to create a clickable button with mouse over effects. (Mouse inputs, Tags)
- How to allow players to enter their name (GUI.Input)

<a name="animate-game-objects"></a>
## How to animate game objects

By animations, we mean something like rotating, sliding, fading whole game objects or hierarchy of game objects.  
Something that is not possible (or suitable) to do with model animations.

- move an item of a menu when the mouse hovers it
- open/close a door by sliding or rotating it
- a black screen that fades out or in (becomes transparent/opaque) at the beginning or end of a level.
- ...

The `GameObject.Animate()` function is there to easily fulfill that purpose.  
Its four first arguments are `gameObject, property, endValue, duration`. It's less complicated than it seems.

The function will change the value of the specified property of one of the game object's component during the specified duration, toward the specified value.

The property to use obviously depends on what effect or movement you want :

- move : `position` or `localPosition`
- rotate : `eulerAngles` or `localEulerAngles` (you could have worked with the `orientation` to create a rotation, too, but they are not supported here)
- fade in or out : `opacity`

You can actually animate any property that has a couple of getter/setter (the functions that begin by `Get` or `Set`, like `transform:GetPosition()`) on a component.

Here is some example:
    
    -- slides an object by 2 units on the X axis over 1 second
    self.gameObject:Animate( "localPosition", Vector3(2,0,0), 1 )

    -- rotates an object by 90° on the Y axis over 1 second  
    self.gameObject:Animate( "localEulerAngles", Vector3(0,90,0), 1 )
    
    -- fades a renderer out
    self.gameObject:Animate( "opacity", 0, 2 )
    -- It does matter here if the game object has a model, map, text or circle renderer,
    -- or even a text area, the correct component (that provide `Get/SetOpacity()`) will automatically be found

You can even animate the text of a text renderer in order to create the effect where the text is displayed one letter after the other.

    -- displays the text in 5 second (4 letters per second)
    self.gameObject:Animate( "text", "The text to display", 5 )

The fifth argument of the `Animate()` function is a function that is called when the animation has completed. This can be used to prevent something to happen before that time.

For instance in the following scenario (a door that open/close), the door can't start to open or close if it is currently openning or closing.

    function Behavior:Open()
        if not self.isAnimating then
            self.isAnimating = true
            self.gameObject:Animate( "localPosition", Vector3(2,0,0), 1, function() 
                self.isAnimating = false
            end )
        end
    end

    function Behavior:Close()
        if not self.isAnimating then
            self.isAnimating = true
            self.gameObject:Animate( "localPosition", Vector3(0), 1, function() 
                self.isAnimating = false
            end )
        end
    end


The `Animate()` function returns an object of type `Tween.Tweener`. You can learn more about tweeners, the objects that actually handle the animation on the [Tween](/docs/tween#tweener) page.


<a name="timer"></a>
## How to use timers

A timer as one goal : executing something (a function) after some time has passed.

Create a timer with the `New()` function on the `Tween.Timer` object :

    local timer = Tween.Timer.New( time, whatToDo )
    -- or you can also omit to use explicitely the `New()` function :
    local timer = Tween.Timer( time, whatToDo )

The `time` parameter is the time in seconds (a number) it will take for the timer to complete.

The `whatToDo` parameter is a function that will be executed when the timer completes.

An object of type `Tween.Tweener` is returned, so you have as much control over timers than you have over tweeners.

    Tween.Timer( 2, function()
        self.gameObject:Destroy()
    end )

This will destroy the game object in 2 seconds

Timers can also loop, which means they can be set to execute the function more than once.  
Pass `true` as the third parameter (after the function) :

    Tween.Timer( 1, function()
        Player:GiveHealth( 2 )
    end, true )

This code would give 2 health to the player every seconds

Timers count time backward, so you may check the `value` or `elapsed` properties on the timer object to know how many time remains, or has passed, respectively.
    
    function Behavior:Start()
        self.timer = Tween.Timer.New( 10*60, function()
            print( "The eggs are cooked !" )
        end )
    end

    function Behavior:Update()
        print( "The eggs are cooking for already ".. self.timer.elapsed .." seconds." )

        print( self.timer.value / 60 .." minutes remains before they are ready !" )
    end


<a name="trigger"></a>
## How to know if an object is close to another object, or inside an area

You must [use a trigger component](/docs/trigger).

Imagine you have an NPC and you want to "activate" it when the player is close enough (ie: an enemy start chasing the player or an character start talking to it).

The player game object has a "player" tag.


Add the Trigger script as a scripted behavior on your NPC. Then you have to set the trigger's public properties :



First the `tags` property :  
Tags are a way to label or group game objects. Several game object may have the same tag, they are then part of the same (virtual) group.

In our case, the player object would have the `"player"` tag for instance.  
Set `player` in the trigger's Tags field, so that the trigger works with the game object that has this tag (our player).
Again, several game object may have the same tag, and the trigger may also work with several tags.

Then set the `range` public property to the distance at which the NPC must detect the player.  
From this point, the script will automatically checks for the distance between the NPC and the player.

When the player and the NPC gets close enough, the `OnTriggerEnter` [event](/docs/events) is fired at the trigger and at the player.

That means that any `OnTriggerEnter()` function that exist in a scripted behavior on the NPC or player wil be called.

    function Behavior:OnTriggerEnter( playerGameObject )

    end




Sometimes, using the `range` public property is not apropriate, because it actually create a spherical shape, whose range is the radius, and you want more control over the shape of the area.

The solution is to shape the model with a model

lke the finish line of a race
