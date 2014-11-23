# Mouse inputs

This module enables interactions (fire events, mostly) between game objects and the mouse.  
Require the [tags functionalities](/docs/craftstudio#tags) (the `CraftStudio` script).

- [Setup](#setup)
- [Mouse events](#mouse-events)
- [Click events](#click-events)
- [Wheel events](#wheel-events)

<a name="setup"></a>
## Setup

Add the `Mouse Input` script as a scripted behavior to a game object with a `Camera` component.

Set the `tags` public property (concatenate several tags with a coma).  

The `OnMouseOverInterval` property is the number of frames between two firing of the `OnMouseOver` event (when a game object is hovered). Leave it at `0` (or any negative value) if you are not using this event.

Setup a `"LeftMouse"`, `"RightMouse"`, `"WheelUp"` and `"WheelDown"` button in your game controls (in the `Administration > Game Controls` tab).  
Not setting one of these buttons will throw an harmless error message in the Runtime Report when the module loads. You may setup a button and not bind it to any key to prevent it.


<a name="mouse-events"></a>
## Mouse events

The `OnMouseEnter` event is fired at a game object when it is hovered by the mouse for the first time (it is hovered this frame, but it wasn't the last frame).  

The `OnMouseOver` event is fired each `OnMouseOverInterval` frame (+ each button click) on a game object as long as the mouse hovers it.

The `OnMouseExit` event is fired at a game object the frame the mouse stops hovering it (it is not hovered this frame but was hovered the last frame).  

The `isMouveOver` property on a game object tells if it is currently hovered by the mouse. The property is `true` when the game object is hovered, or `false` (or `nil`) otherwise.

Note that a game object may be considered hovered by the mouse even if it's not visible from a camera because it is hidden by another game object in front of it.


<a name="click-events"></a>
## Click events

The `OnClick` (for a single left click), `OnDoubleClick` (for a double left click) and `OnRightClick` events are fired at a game object when the click happens while the mouse hovers the game object.  

A double click is two left clicks separated by no more than 20 frames (1/3 of a second).  
You can update this value at runtime via the `MouseInput.Config.doubleClickDelay` variable (a number of frames) or by setting the `MouseInput.UserConfig()` global function to return a table with `doubleClickDelay` as key and a number as value. 

	function MouseInput.UserConfig()
		return {
			doubleClickDelay = 20, -- Maximum number of frames between two clicks of the left mouse button to be considered as a double click
		}
	end


<a name="wheel-events"></a>
## Wheel events

If you did setup a `"WheelUp"` and `"WheelDown"` button in you game controls, the `OnWheelUp` and `OnWheelDown` events will be fired whenever the mouse wheel is rolled up or down.  
"Wheel up" is rolling the wheel toward you.