# Mouse inputs

This module introduce the `MouseInput` component that enables interactions through local events between game objects and the mouse.  

- [Setup](#setup)
- [Mouse events](#mouse-events)
- [Click events](#click-events)
- [Wheel events](#wheel-events)

<a name="setup"></a>
## Setup

Add a mouse input component on a game object that already has a camera component with `gameObject:AddComponent("MouseInput"[, params])`or `MouseInput.New( gameObject[, params])`.  
When you are in the scene editor, you can add the `MouseInput` scripted behavior instead.

Set some tag(s) on the game objects the component works with (which game objects are checked against the position of the mouse cursor), then pass them as argument of the `mouseInput:SetTags( { "tags" } )` function.
In the scene editor, you can concatenate several tags with a coma in the `tags` field.

Then setup a `"LeftMouse"`, `"RightMouse"`, `"WheelUp"` and `"WheelDown"` button in your game controls (in the `Administration > Game Controls` tab).  
Not setting one of these buttons will throw an harmless error message in the Runtime Report when the game loads. You may setup a button and not bind it to any key to prevent it.

<a name="mouse-events"></a>
## Mouse events

The `OnMouseEnter` event is fired at a game object when it is hovered by the mouse for the first time (it is hovered this frame, but it wasn't the last frame).  

The `OnMouseOver` event is fired at a game object each frame that the mouse moves or a button is clicked, kept down or released and the mouse hovers it.

The `OnMouseExit` event is fired at a game object the frame the mouse stops hovering it (it is not hovered this frame but was hovered the last frame).  

The `isMouveOver` property on a game object tells if it is currently hovered by the mouse. The property is `true` when the game object is hovered, or `false` (or `nil`) otherwise.

Note that a game object may be considered hovered by the mouse even if it's not visible from a camera because it is hidden by another game object in front of it.

<a name="click-events"></a>
## Click events

The `OnClick` (for a single left click (the LeftMouse button was pressed)), `OnDoubleClick` (for a double left click), `OnLeftClickReleased` (the LeftMouse button was released) and `OnRightClick` (the RightMouse button was pressed) events are fired at a game object when the click happens while the mouse hovers the game object.  

A double click is two left clicks separated by no more than 20 frames (1/3 of a second).  
You can update this value at runtime via the `MouseInput.Config.doubleClickDelay` property (a number of frames) or by setting the `MouseInput.UserConfig()` function to return a table with `doubleClickDelay` as key and a number as value. 

	function MouseInput.UserConfig()
		return {
			doubleClickDelay = 20, -- Maximum number of frames between two clicks of the left mouse button to be considered as a double click
		}
	end

<a name="wheel-events"></a>
## Wheel events

If you did setup a `"WheelUp"` and `"WheelDown"` button in you game controls, the `OnWheelUp` and `OnWheelDown` events will be fired at the hovered game objects whenever the mouse wheel is rolled up or down.  
"Wheel up" is rolling the wheel toward you.
