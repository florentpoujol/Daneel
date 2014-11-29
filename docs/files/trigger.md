# Trigger

The `Trigger` component automatically checks the proximity of the game object against other game objects and interact with those who are within a certain distance or inside a model or map.

- [Setup](#setup)
- [Trigger events](#trigger-events)

<a name="setup"></a>
## Setup

Add a Trigger component on a game object with `gameObject:AddComponent("Trigger"[, params])`or `Trigger.New( gameObject[, params])`.  
When you are in the scene editor, you can add the `Trigger` scripted behavior instead.

To define which game objects the trigger will check its proximity against, fill the `tags` table on the trigger to the tag(s) the game objects to check have.  
In the scene editor, you can concatenate several tags with a coma in the `tags` field.

The `updateInterval` property on the trigger is the number of frames between two checks.  
Set it to a value strictly inferior to 1 to prevent the trigger events to be fired.  
However, you can get the list of the game objects in range at any time via the `trigger:GetGameObjectsInRange()` function.

The trigger's shape may be a sphere which radius is the value of the `range` public property (when strictly positive).  
Or it can be defined by the shape of a model or a map (on the game object). In this case, leave the `range` public property to 0.  


<a name="trigger-events"></a>
## Trigger events

The `OnTriggerEnter` event is fired at a game object and the trigger when it enters the trigger for the first frame (it is in range this frame, but it wasn't the last frame).

The `OnTriggerStay` event is fired each frame (every [`updateInterval`] frames) at a game object and each triggers it is in range of as long as it stays in range of one or several trigger(s).

The `OnTriggerExit` event is fired at a game object and the trigger the frame it leaves the trigger (it is not in range this frame but was in range the last frame).

Each of these events pass along the trigger game object or the checked game object as first and only argument.

    -- in a scripted behavior attached to a game object :
    function Behavior:OnTriggerEnter( data )
        local triggerGO = data[1]
        print( "The game object of name '"..self.gameObject.name.."' just reach the trigger of name '"..triggerGO.name.."'." )
    end

    function Behavior:OnTriggerStay( data )
        local triggerGO = data[1]
        if CraftStudio.Input.WasButtonJustRealeased( "Fire" ) then
            print( "The 'Fire' button was just released while the game object of name '"..self.gameObject.name.."' is inside the trigger of name '"..triggerGO.name.."'." )
        end
    end

    ----------
    -- where self.gameObject has a trigger component :
    
    self.gameObject:AddEventListener( "OnTriggerExit", function( gameObjet )
        print( "The game object of name '"..gameObject.name.."' just exited the trigger of name '"..self.gameObject.name.."'." )
    end )
