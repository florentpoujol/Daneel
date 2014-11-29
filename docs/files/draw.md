# Draw

The `Draw` object introduces two components.  
As always,  create a new compoent with `gameObject:AddComponent( "ComponentType"[, params] )`.

Check out the function reference for the full list of functions you can use with these components.

- [Line Renderer](#line-renderer)
- [Circle Renderer](#circle-renderer)

<a name="line-renderer"></a>
## Line Renderer

The `LineRenderer` component allows you to easily create a line in the 3D world.  
In addition to the component, you have to setup a model renderer on the game object yourself. The model used for the line should be composed of a single block at a position `0, 0, -8` (in the model editor) with a block size of `16` in all axis.

You can define either the direction and length of the line, either the "end position" (one of the extremities, the other one being at the game object's position).

<a name="circle-renderer"></a>
## Circle Renderer

The `CircleRenderer` component allows you to easily create a circle in the 3D world.  
The game object is the center of the circle which is created in the `x, y` plane.
