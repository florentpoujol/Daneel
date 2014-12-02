# Event

Events are a way to call functions or send messages, whenever something happens during runtime, with or without the need for the script that fires an event to be aware of all the receivers.

'Function' refers in this page to any kind of functions : anonymous, local, global, 'Behavior' (scripted behaviors public functions) as well as 'userdata' (CraftStudio's functions).  

- [Global events](#global-events)
- [Local events](#local-events)
- [Functions as listener](#functions-as-listener)
- [Objects as listener](#objects-as-listener)
- [Daneel's events](#daneels-events)


<a name="global-events"></a>
## Global events

Global events are fired to any function or object that listen to it.
Make a function or an object listen to one or several events with `Daneel.Event.Listen(eventName, functionOrObject[, isPersistent])`.
    
    local function Foo() end
    function Behavior:Bar() end

    Daneel.Event.Listen( "eventName", function() end ) -- anonymous
    Daneel.Event.Listen( "eventName", Foo ) -- local or global function
    Daneel.Event.Listen( "eventName", self.Bar ) -- 'Behavior'. Note that in this case, the 'self' variable will not exists automatically (like with messages) in the function 
    -- in this case it is best to make the game object listen to the event
    Daneel.Event.Listen( "eventName", CraftStudio.Exit ) -- userdata

    Daneel.Event.Listen( "eventName", self.gameObject ) -- object. Works with any objects (tables), not just game objects or components


Use `Daneel.Event.StopListen([eventNames, ]functionOrObject)` to stop a function or object from listening to one or several global events (or any global event if the eventNames argument is omited or nil).

A **persistent listener** keeps listening to events accross scenes, which is not the case for the other listeners which automatically stop to listen to any event when a new scene is loaded.  
To make a listener persistent, just pass `true` (default is `false`) as the third argument of `Daneel.Event.Listen()`.  
Note that game objects and components can't be persistent listeners.

Fire a global event with `Daneel.Event.Fire(eventName[, ...])`. Any subsequent arguments to the event name are passed along to the listeners.

    local function Foo( arg1, arg2 )
        print( arg1.." | "..arg2 )
    end
    
    Daneel.Event.Listen( "FooBar", Foo )

    Daneel.Event.Fire( "FooBar", "first arg", 2 )
    -- will prints "first arg | 2"


<a name="local-events"></a>
## Local events

Local events are fired at a single listener object with `Daneel.Event.Fire(listenerObject, eventName[, ...])`.


<a name="functions-as-listener"></a>
## Functions as listener

Listener functions may automatically stop to listen to the event they listen to by returning `false`. It also works for functions on objects (see below).

    Daneel.Event.Listen( "AnEvent", function()
        -- do something one
        -- ...
        return false -- then stop to listen
    end )


<a name="objects-as-listener"></a>
## Objects as listener

When an (local or global) event is fired at an object, several functions on this object will be called.

You can add or remove functions to be called on an object for a specified event with `Daneel.Event.AddEventListener( object, eventName, listenerFunction )` and `Daneel.Event.RemoveEventListener( object, eventName, listenerFunction )`.  

Functions added via `AddEventListener()` are added in a `listenersByEvent` dictionary on the object. Keys are the event names, values are list of functions.

Optionally, you can also set a function as the value of a property with the same name as the event. (ie : `object.OnFooBar` for an event named `"OnFooBar"`).

Note that game objects have the following shortcuts : `GameObject.AddEventListener( eventname, listenerFunction )`, `GameObject.RemoveEventListener( eventname, listenerFunction )`, `GameObject.FireEvent( eventname )`.  
    
    local func = function() 
        print("Left click pressed on ", self.gameObject)
    end
    self.gameObject:AddEventListener( "OnLeftClick", func )

    Daneel.Event.Fire( self.gameObject, "OnLeftClick" )
    -- this prints one line :
    -- "Left click pressed on ?GameObject: 123456789: GameObjectName"
    -- also sends the message "OnLeftClick" on this game object and calls any Behavior:OnLeftClick() functions


    self.gameObject:AddEventListener( "OnLeftClick", function( data ) 
        print("Another left lick listener.", data)
    end )
    self.gameObject.OnLeftClick = function() 
        print("Yet another left lick catcher.")
    end
    self.gameObject:RemoveEventListener( "OnLeftClick", func )

    self.gameObject:FireEvent( "OnLeftClick", "Click !" )
    -- this prints two lines (and sends the "OnLeftClick" message) :
    -- "Another left lick listener.?Click !"
    -- "Yet another left lick catcher."


    local object = { OnLeftClick = function() print("Click !") end }
    Daneel.Event.AddEventListener( object, "OnLeftClick", function() print("Click2 !") end )
    Daneel.Event.Fire( object, "OnLeftClick" ) 
    -- This prints "Click !" and "Click2 !".
    -- Since the object is not a game object, no message is sent.
    
When the object is also a `GameObject` the message of the same name as the event is sent.  
In that case the event's arguments are bundled in a table passed as the message's first and only argument with these conditions :

- the game object the message is sent on is not passed when it is the event's first argument (because it's readily available in behavior's public functions),
- if a table is the only (remaining) argument, is is passed directly, instead of being bundled in another table.

Some example :

    -- 1)
    Daneel.Event.Fire( gameObject, "OnEvent", gameObject, 1, 2 ) -- two arguments in addition of the game object
    function Behavior:OnEvent( data )
        -- data contains 1 and 2 as first and seconds argument, respectively
    end

    -- 2)
    Daneel.Event.Fire( gameObject, "OnEvent", gameObject, gameObject.transform, 2 ) -- two arguments in addition of the game object
    function Behavior:OnEvent( data )
        -- data contains the transform component and 2 as first and seconds argument, respectively
    end

    -- 3)
    Daneel.Event.Fire( gameObject, "OnEvent", gameObject, gameObject.transform ) -- a table as single additional argument
    function Behavior:OnEvent( transform )
        -- the transform argument is already the transform component
    end

    -- 4)
    Daneel.Event.Fire( gameObject, "OnEvent", gameObject.transform )
    function Behavior:OnEvent( transform )
        -- the transform argument is already the transform component
    end


<a name="daneels-events"></a>
## Daneel's events

Here the list of all events fired by Daneel :

Global events :

- `OnNewSceneWillLoad` fired by `CS.LoadScene()` or `Scene.Load()` **before** a scene is loaded, receive the scene asset as first argument.

Local events fired at game objects :

- `OnNewComponent` when a new component is created with `GameObject.AddComponent()`. The newly created component is passed as first argument.

Local events fired at any objects :

- `OnDestroy` is fired at the objects destroyed by `CraftStudio.Destroy()` (also `gameObject:Destroy()`, `component:Destroy()`, ...) the same frame as the function call, before the object is actually removed/destroyed.
