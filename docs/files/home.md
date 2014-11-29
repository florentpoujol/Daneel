[craftstudio]: http://craftstud.io
[CSscriptingreference]: http://wiki.craftstud.io/Reference/Scripting

# Daneel

Daneel is a scripting framework for [CraftStudio][] that aim to :

- bring __all new__ functionalities,
- __extend__ and render __more flexible__ to use CraftStudio's API,
- __sweeten and shorten__ the code you write.

Daneel never deprecate anything from the current CraftStudio's API which remains usable in its entirety [as described in the scripting reference][CSscriptingreference] on the official wiki.  
Daneel mostly add new objects, new functions on existing objects and sometimes allow to pass different argument types and new arguments on existing functions.


<a name="overview"></a>
## Overview

Call getters and setters as if they were properties :
    
    self.gameObject.name -- same as self.gameObject:GetName()
    self.gameObject.name = "new name" -- same as self.gameObject:SetName("new name")

    -- this also works on components and assets
    self.gameObject.mapRenderer.map = Asset.Get( "folder/map name", "Map" )
    
Various extensions (new functions, different argument's types or all new arguments) of the base API :
    
    GameObject.New( name, params )
    gameObject:AddComponent( type, params )
    
    GameObject.Get( name ) -- 'name' may be a hierarchy of object "Parent.Child.GrandChild"
    
    Asset.Get( path, type )
    
    -- set assets using the asset name instead of the asset object :
    gameObject.modelRenderer:SetModel( "Folder/Model" )
    gameObject.textRenderer.font = "MyFont"
    
    -- create instances of objects without writing the New() function
    Vector3( 0, 1, 2 ) -- same as Vector3:New( 0, 1, 2 )
    
    -- create component, set properties or call setters in mass on game objects and components :
    gameObject:Set( {
        parent = "my parent name",

        modelRenderer = {
            model = "model name"
        },
    } )

Categories and group game objects with tags :
    
    -- Set this game object has being an "enemy"
    self.gameObject:AddTag( "enemies" )

    -- Get all game objects that have one or several tag(s) :
    local airborneEnemies = GameObject.GetWithTag( {"enemies", "airborne"} )
    local allEnenmies = GameObject.GetWithTag( "enemies" )

Extension of Lua's standard `table`, `string` and `math` libraries :

    table.containsvalue( t, v )
    table.removevalue( t, v )
    table.mergein( t1, t2 )
    table.print( t ) -- and table.printr( t ) for recursively printing tables as value
    table.getvalue( t, "foo.bar" )
    ...

    string.split( s, delimiter )
    string.trim( s )
    string.ucfirst( s )
    ...

Manage code with events :
    
    Daneel.Event.Listen( "EventName", function() ... end )
    Daneel.Event.Listen( "EventName", self.gameObject )
    Daneel.Event.Fire( "EventName" ) -- fires the "EventName" global event on its listeners

    self.gameObject:AddEventListener( "EventName", function( arg1, arg2 ) ... end )
    self.gameObject:FireEvent( "EventName", arg1, arg2 ) -- also send the "EventName" message on the game object


Enable mouse input events :
    
    self.gameObject:AddEventListener( "OnMouseEnter", function( gameObject )
        local scale = gameObject.transform.localScale
        scale = scale * 0.3
        gameObject.transform.localScale = scale
    end )
    -- OnMouseOver
    -- OnMouseExit

    self.gameObject.OnClick = function() 
        CS.Exit()
    end
    -- OnLeftClickReleased
    -- OnDoubleClick
    -- OnRightClick

Easily create HUDs and user interfaces with the GUI components : hud, toggles (checkbox and radio buttons), progress bars, text inputs, sliders and text areas (multiline texts).

Easily create animations and timers with tweeners.

    Tween.Timer( 5, function() self.gameObject:Destroy() end )

    -- heart beat effect
    Tween.Tweener( self.gameObject.transform, "localScale", 0.2, 1, {
        loops = -1,
        loopType = "yoyo"
    } )

    -- fade out animation in 0.5 second with callback function when the animation has completed
    self.gameObject:Animate( "opacity", 0, 0.5, function(go) ... end )

Set thousands of colors on models and texts renderers.

    self.gameObject.modelRenderer.color = Color( 255, 150, 0 ) -- some orange
    print(self.gameObject.modelRenderer.color.hex) -- prints "FF9600"

    self.gameObject.textRenderer.color = Color.red

Detect closeness between game objets with triggers :

    self.gameObject:AddEventListener( "OnTriggerEnter", function( trigger )
        print( "The game object of name '"..self.gameObject.name.."' just reach the trigger of name '"..trigger.name.."'." )
    end )

Keep track of time :

    Daneel.Time.deltaTime -- time in second between to frames
    Daneel.Time.timeScale -- ratio at which the time flows
    ...


Localize strings :

    self.gameObject.textRenderer.text = Lang.Get( "ui.buttons.exitgame" )
    Lang.RegisterForUpdate( self.gameObject, "ui.buttons.exitgame" )

    Lang.Update( "french" )


Some noteworthy conventions are also followed throughtout the framework :

- Every getter functions are called `GetSomething()` instead of `FindSomething()`.
- Every object and function names are pascal-cased, except for functions added to Lua's standard libraries which are all lower-case.
- Every time an argument has to be an asset or component type, it is case insensitive.
