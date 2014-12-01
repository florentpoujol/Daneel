# Trigger

The `Trigger` component automatically checks the proximity of the game object against other game objects and interact with those who are within a certain distance or inside a model or map.

- [Setup](#setup)
- [Trigger events](#trigger-events)

<a name="setup"></a>
## Setup

Add a Trigger component on a game object with `gameObject:AddComponent("Trigger"[, params])`or `Trigger.New( gameObject[, params])`.  
When you are in the scene editor, you can add the `Trigger` scripted behavior instead.

Set some tags on the game objects the trigger will check its proximity against, then pass them as argument of the `trigger:SetTags( { "tags" } )` function.
In the scene editor, you can concatenate several tags with a coma in the `tags` field.

The trigger's update interval is the number of frames between two automatic checks (and fire of the trigger events).  
Set the update interval via the `trigger:SetUpdateInterval(updateInterval)` function to a value strictly inferior to 1 to prevent the trigger events to be fired. The default update interval is of 6 frames (10 updates per second.  

If the update interval is below 1, the trigger events won't be fired at all. However, you can get the list of the game objects in range at any time via the `trigger:GetGameObjectsInRange()` function.

The value of the trigger's range define the shape of the trigger's area. Set it via the `trigger:SetRange(range)` function. The default range is of 1 unit.  
The trigger's shape may be a sphere which radius is the value of its range (in scene units) when it's strictly positive.  
Or it can be defined by the shape of a model or a map (on the trigger's game object) when the range is 0.


<a name="trigger-events"></a>
## Trigger events

The `OnTriggerEnter` event is fired at a game object and the trigger when it enters the trigger for the first frame (it is in range this frame, but it wasn't the last frame).

The `OnTriggerStay` event is fired each frame (every [`updateInterval`] frames) at a game object and each triggers it is in range of as long as it stays in range of one or several trigger(s).

The `OnTriggerExit` event is fired at a game object and the trigger the frame it leaves the trigger (it is not in range this frame but was in range the last frame).

Each of these events pass along the game object it is fired at as first argument and trigger game object or the checked game object as second argument.

    -- In a scripted behavior attached to a game object whose proximity is checked by a trigger:
    function Behavior:OnTriggerEnter( data )
        local go = data[1] -- in this context, go == self.gameObject
        local triggerGO = data[2]
        print( "The game object of name '"..go.name.."' just reach the trigger of name '"..triggerGO.name.."'." )
    end

    function Behavior:OnTriggerStay( data )
        local triggerGO = data[2]
        if CraftStudio.Input.WasButtonJustRealeased( "Fire" ) then
            print( "The 'Fire' button was just released while the game object of name '"..self.gameObject.name.."' is inside the trigger of name '"..triggerGO.name.."'." )
        end
    end

    ----------
    -- where self.gameObject has a trigger component :
    
    self.gameObject:AddEventListener( "OnTriggerExit", function( triggerGO, gameObjet )
        -- in this context triggerGO == self.gameObject

        print( "The game object of name '"..gameObject.name.."' just exited the trigger of name '"..triggerGO.name.."'." )
    end )
