# Triggers

A trigger is a game object that checks its proximity against other game objects and interact with those who are within a certains distance or within a model or map.  
Require the [tags functionalities](/docs/craftstudio#tags) (the `CraftStudio` script).

- [Setup](#setup)
- [Trigger events](#trigger-events)
- [Function reference](#function-reference)


<a name="setup"></a>
## Setup

Add the `Trigger` script as a scripted behavior on a game object.  
You can get the scripted behavior instance via the `trigger` property on the game object.

Set the `tags` public property (concatenate several tags with a coma). The trigger will check its proximity against the game objects that have at least one of these tags.  

The `updateInterval` property is the number of frames between two checks.  
Set it to a value strictly inferior to 1 to prevent the trigger events to be fired.  
However, you can get the list of the game objects in range at any time via the `trigger:GetGameObjectsInRange()` function.

The trigger's shape may be a sphere which radius is the value of the `range` public property (when strictly positive).  
Or it can be defined by the shape of a model or a map (on the game object). In this case, leave the `range` public property to 0.  


<a name="trigger-events"></a>
## Trigger events

The `OnTriggerEnter` event is fired at a game object and the trigger when it enters the trigger for the first frame (it is in range this frame, but it wasn't the last frame).

The `OnTriggerStay` event is fired each frame (each `updateInterval`) at a game object and each triggers it is in range of as long as it stays in range of one or several trigger(s).

The `OnTriggerExit` event is fired at a game object and the trigger the frame it leaves the trigger (it is not in range this frame but was in range the last frame).

Each of these events pass along the trigger or the game object as first and only argument.

    -- in a scripted behavior attached to a game object :
    function Behavior:OnTriggerEnter( data )
        local trigger = data[1]
        print( "The game object of name '"..self.gameObject.name.."' just reach the trigger of name '"..trigger.name.."'." )
    end

    function Behavior:OnTriggerStay( data )
        local trigger = data[1]
        if CraftStudio.Input.WasButtonJustRealeased( "Fire" ) then
            print( "The 'Fire' button was just released while the game object of name '"..self.gameObject.name.."' is inside the trigger of name '"..trigger.name.."'." )
        end
    end

    ----------
    -- in a scripted behavior attached to a trigger :
    function Behavior:OnTriggerExit( data )
        local gameObject = data[1]
        print( "The game object of name '"..gameObject.name.."' just exited the trigger of name '"..self.gameObject.name.."'." )
    end


<a name="function-reference"></a>
## Function reference

<table class="function_list">
    
        <tr>
            <td class="name"><a href="#Behavior:GetGameObjectsInRange">Behavior:GetGameObjectsInRange</a>(  )</td>
            <td class="summary">Get the gameObjets that are within range of that trigger.</td>
        </tr>
    
        <tr>
            <td class="name"><a href="#Behavior:IsGameObjectInRange">Behavior:IsGameObjectInRange</a>( gameObject, triggerPosition )</td>
            <td class="summary">Tell whether the provided game object is in range of the trigger.</td>
        </tr>
    
</table>

<dl class="function">
    
        
<dt><a name="Behavior:GetGameObjectsInRange"></a><h3>Behavior:GetGameObjectsInRange(  )</h3></dt>
<dd>
Get the gameObjets that are within range of that trigger.
<br><br>


    <strong>Return value:</strong>
    <ul>(table) The list of the gameObjects in range (empty if none in range).</ul>

</dd>
<hr>
    
        
<dt><a name="Behavior:IsGameObjectInRange"></a><h3>Behavior:IsGameObjectInRange( gameObject, triggerPosition )</h3></dt>
<dd>
Tell whether the provided game object is in range of the trigger.
<br><br>

    <strong>Parameters:</strong>
    <ul>
        
        <li>
          gameObject (GameObject) The gameObject.
        </li>
        
        <li>
          triggerPosition (Vector3) [optional] The trigger's current position.
        </li>
        
    </ul>


    <strong>Return value:</strong>
    <ul>(boolean) True or false.</ul>

</dd>
<hr>
    
</dl>

