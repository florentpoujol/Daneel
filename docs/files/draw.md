# Draw

The `Draw` script introduces a series of game object components.

- [Line Renderer](#line-renderer)
- [Circle Renderer](#circle-renderer)
- [Function reference](#function-reference)

<a name="line-renderer"></a>
## Line Renderer

The `LineRenderer` component allows you to easily create a line in the 3D world.  
In addition to the component, you have to setup a model renderer on the game object yourself. The model used for the line should be composed of a single block at `0, 0, -8` with a block size of `16` in all axis.

You can define either the direction and length of the line, either the "end position" (one of the extremities, the one one being at the game object's position).

<a name="circle-renderer"></a>
## Circle Renderer

The `CircleRenderer` component allows you to easily create a circle in the 3D world.  
The game object is the center of the circle which is created in the `x, y` plane.


<a name="function-reference"></a>
## Function reference

<table class="function_list">
    
        <tr>
            <td class="name"><a href="#Draw.CircleRenderer.Draw">Draw.CircleRenderer.Draw</a>( circle )</td>
            <td class="summary">Draw the circle renderer.</td>
        </tr>
    
        <tr>
            <td class="name"><a href="#Draw.CircleRenderer.GetModel">Draw.CircleRenderer.GetModel</a>( circle )</td>
            <td class="summary">Returns the circle renderer's segment's model.</td>
        </tr>
    
        <tr>
            <td class="name"><a href="#Draw.CircleRenderer.GetRadius">Draw.CircleRenderer.GetRadius</a>( circle )</td>
            <td class="summary">Returns the circle renderer's radius.</td>
        </tr>
    
        <tr>
            <td class="name"><a href="#Draw.CircleRenderer.GetSegmentCount">Draw.CircleRenderer.GetSegmentCount</a>( circle )</td>
            <td class="summary">Returns the circle renderer's number of segments.</td>
        </tr>
    
        <tr>
            <td class="name"><a href="#Draw.CircleRenderer.GetWidth">Draw.CircleRenderer.GetWidth</a>( circle )</td>
            <td class="summary">Returns the circle renderer's segment's width (and height).</td>
        </tr>
    
        <tr>
            <td class="name"><a href="#Draw.CircleRenderer.New">Draw.CircleRenderer.New</a>( gameObject, params )</td>
            <td class="summary">Creates a new circle renderer component.</td>
        </tr>
    
        <tr>
            <td class="name"><a href="#Draw.CircleRenderer.Set">Draw.CircleRenderer.Set</a>( circle, params )</td>
            <td class="summary">Apply the content of the params argument to the provided circle renderer.</td>
        </tr>
    
        <tr>
            <td class="name"><a href="#Draw.CircleRenderer.SetModel">Draw.CircleRenderer.SetModel</a>( circle, model )</td>
            <td class="summary">Sets the circle renderer segment's model.</td>
        </tr>
    
        <tr>
            <td class="name"><a href="#Draw.CircleRenderer.SetRadius">Draw.CircleRenderer.SetRadius</a>( circle, radius, draw )</td>
            <td class="summary">Sets the circle renderer's radius.</td>
        </tr>
    
        <tr>
            <td class="name"><a href="#Draw.CircleRenderer.SetSegmentCount">Draw.CircleRenderer.SetSegmentCount</a>( circle, count, draw )</td>
            <td class="summary">Sets the circle renderer's segment count.</td>
        </tr>
    
        <tr>
            <td class="name"><a href="#Draw.CircleRenderer.SetWidth">Draw.CircleRenderer.SetWidth</a>( circle, width )</td>
            <td class="summary">Sets the circle renderer segment's width.</td>
        </tr>
    
        <tr>
            <td class="name"><a href="#Draw.LineRenderer.Draw">Draw.LineRenderer.Draw</a>( line )</td>
            <td class="summary">Draw the line renderer.</td>
        </tr>
    
        <tr>
            <td class="name"><a href="#Draw.LineRenderer.GetDirection">Draw.LineRenderer.GetDirection</a>( line )</td>
            <td class="summary">Returns the line renderer's direction.</td>
        </tr>
    
        <tr>
            <td class="name"><a href="#Draw.LineRenderer.GetEndPosition">Draw.LineRenderer.GetEndPosition</a>( line )</td>
            <td class="summary">Returns the line renderer's end position.</td>
        </tr>
    
        <tr>
            <td class="name"><a href="#Draw.LineRenderer.GetLength">Draw.LineRenderer.GetLength</a>( line )</td>
            <td class="summary">Returns the line renderer's length.</td>
        </tr>
    
        <tr>
            <td class="name"><a href="#Draw.LineRenderer.GetWidth">Draw.LineRenderer.GetWidth</a>( line )</td>
            <td class="summary">Returns the line renderer's width.</td>
        </tr>
    
        <tr>
            <td class="name"><a href="#Draw.LineRenderer.New">Draw.LineRenderer.New</a>( gameObject, params )</td>
            <td class="summary">Creates a new LineRenderer component.</td>
        </tr>
    
        <tr>
            <td class="name"><a href="#Draw.LineRenderer.Set">Draw.LineRenderer.Set</a>( line, params )</td>
            <td class="summary">Apply the content of the params argument to the provided line renderer.</td>
        </tr>
    
        <tr>
            <td class="name"><a href="#Draw.LineRenderer.SetDirection">Draw.LineRenderer.SetDirection</a>( line, direction, useDirectionAsLength, draw )</td>
            <td class="summary">Set the line renderer's direction.</td>
        </tr>
    
        <tr>
            <td class="name"><a href="#Draw.LineRenderer.SetEndPosition">Draw.LineRenderer.SetEndPosition</a>( line, endPosition, draw )</td>
            <td class="summary">Set the line renderer's end position.</td>
        </tr>
    
        <tr>
            <td class="name"><a href="#Draw.LineRenderer.SetLength">Draw.LineRenderer.SetLength</a>( line, length, draw )</td>
            <td class="summary">Set the line renderer's length.</td>
        </tr>
    
        <tr>
            <td class="name"><a href="#Draw.LineRenderer.SetWidth">Draw.LineRenderer.SetWidth</a>( line, width, draw )</td>
            <td class="summary">Set the line renderer's width (and height).</td>
        </tr>
    
</table>

<dl class="function">
    
        
<dt><a name="Draw.CircleRenderer.Draw"></a><h3>Draw.CircleRenderer.Draw( circle )</h3></dt>
<dd>
Draw the circle renderer. Updates the game object based on the circle renderer's properties. Fires the OnDraw event at the circle renderer.
<br><br>

    <strong>Parameters:</strong>
    <ul>
        
        <li>
          circle (CircleRenderer) The circle renderer.
        </li>
        
    </ul>


</dd>
<hr>
    
        
<dt><a name="Draw.CircleRenderer.GetModel"></a><h3>Draw.CircleRenderer.GetModel( circle )</h3></dt>
<dd>
Returns the circle renderer's segment's model.
<br><br>

    <strong>Parameters:</strong>
    <ul>
        
        <li>
          circle (CircleRenderer) The circle renderer.
        </li>
        
    </ul>


    <strong>Return value:</strong>
    <ul>(Model) The model asset.</ul>

</dd>
<hr>
    
        
<dt><a name="Draw.CircleRenderer.GetRadius"></a><h3>Draw.CircleRenderer.GetRadius( circle )</h3></dt>
<dd>
Returns the circle renderer's radius.
<br><br>

    <strong>Parameters:</strong>
    <ul>
        
        <li>
          circle (CircleRenderer) The circle renderer.
        </li>
        
    </ul>


    <strong>Return value:</strong>
    <ul>(number) The radius (in scene units).</ul>

</dd>
<hr>
    
        
<dt><a name="Draw.CircleRenderer.GetSegmentCount"></a><h3>Draw.CircleRenderer.GetSegmentCount( circle )</h3></dt>
<dd>
Returns the circle renderer's number of segments.
<br><br>

    <strong>Parameters:</strong>
    <ul>
        
        <li>
          circle (CircleRenderer) The circle renderer.
        </li>
        
    </ul>


    <strong>Return value:</strong>
    <ul>(number) The segment count.</ul>

</dd>
<hr>
    
        
<dt><a name="Draw.CircleRenderer.GetWidth"></a><h3>Draw.CircleRenderer.GetWidth( circle )</h3></dt>
<dd>
Returns the circle renderer's segment's width (and height).
<br><br>

    <strong>Parameters:</strong>
    <ul>
        
        <li>
          circle (CircleRenderer) The circle renderer.
        </li>
        
    </ul>


    <strong>Return value:</strong>
    <ul>(number) The width (in scene units).</ul>

</dd>
<hr>
    
        
<dt><a name="Draw.CircleRenderer.New"></a><h3>Draw.CircleRenderer.New( gameObject, params )</h3></dt>
<dd>
Creates a new circle renderer component.
<br><br>

    <strong>Parameters:</strong>
    <ul>
        
        <li>
          gameObject (GameObject) The game object.
        </li>
        
        <li>
          params (table) A table of parameters.
        </li>
        
    </ul>


    <strong>Return value:</strong>
    <ul>(CircleRenderer) The new component.</ul>

</dd>
<hr>
    
        
<dt><a name="Draw.CircleRenderer.Set"></a><h3>Draw.CircleRenderer.Set( circle, params )</h3></dt>
<dd>
Apply the content of the params argument to the provided circle renderer. Overwrite Component.Set().
<br><br>

    <strong>Parameters:</strong>
    <ul>
        
        <li>
          circle (CircleRenderer) The circle renderer.
        </li>
        
        <li>
          params (table) A table of parameters.
        </li>
        
    </ul>


</dd>
<hr>
    
        
<dt><a name="Draw.CircleRenderer.SetModel"></a><h3>Draw.CircleRenderer.SetModel( circle, model )</h3></dt>
<dd>
Sets the circle renderer segment's model.
<br><br>

    <strong>Parameters:</strong>
    <ul>
        
        <li>
          circle (CircleRenderer) The circle renderer.
        </li>
        
        <li>
          model (string or Model) The segment's model name or asset.
        </li>
        
    </ul>


</dd>
<hr>
    
        
<dt><a name="Draw.CircleRenderer.SetRadius"></a><h3>Draw.CircleRenderer.SetRadius( circle, radius, draw )</h3></dt>
<dd>
Sets the circle renderer's radius.
<br><br>

    <strong>Parameters:</strong>
    <ul>
        
        <li>
          circle (CircleRenderer) The circle renderer.
        </li>
        
        <li>
          radius (number) The radius (in scene units).
        </li>
        
        <li>
          draw (boolean) [default=true] Tell whether to re-draw immediately the circle renderer.
        </li>
        
    </ul>


</dd>
<hr>
    
        
<dt><a name="Draw.CircleRenderer.SetSegmentCount"></a><h3>Draw.CircleRenderer.SetSegmentCount( circle, count, draw )</h3></dt>
<dd>
Sets the circle renderer's segment count.
<br><br>

    <strong>Parameters:</strong>
    <ul>
        
        <li>
          circle (CircleRenderer) The circle renderer.
        </li>
        
        <li>
          count (number) The segment count (can't be lower than 3).
        </li>
        
        <li>
          draw (boolean) [default=true] Tell whether to re-draw immediately the circle renderer.
        </li>
        
    </ul>


</dd>
<hr>
    
        
<dt><a name="Draw.CircleRenderer.SetWidth"></a><h3>Draw.CircleRenderer.SetWidth( circle, width )</h3></dt>
<dd>
Sets the circle renderer segment's width.
<br><br>

    <strong>Parameters:</strong>
    <ul>
        
        <li>
          circle (CircleRenderer) The circle renderer.
        </li>
        
        <li>
          width (number) The segment's width (and height).
        </li>
        
    </ul>


</dd>
<hr>
    
        
<dt><a name="Draw.LineRenderer.Draw"></a><h3>Draw.LineRenderer.Draw( line )</h3></dt>
<dd>
Draw the line renderer. Updates the game object based on the line renderer's properties. Fires the OnDraw event on the line renderer.
<br><br>

    <strong>Parameters:</strong>
    <ul>
        
        <li>
          line (LineRenderer) The line renderer.
        </li>
        
    </ul>


</dd>
<hr>
    
        
<dt><a name="Draw.LineRenderer.GetDirection"></a><h3>Draw.LineRenderer.GetDirection( line )</h3></dt>
<dd>
Returns the line renderer's direction.
<br><br>

    <strong>Parameters:</strong>
    <ul>
        
        <li>
          line (LineRenderer) The line renderer.
        </li>
        
    </ul>


    <strong>Return value:</strong>
    <ul>(Vector3) The direction.</ul>

</dd>
<hr>
    
        
<dt><a name="Draw.LineRenderer.GetEndPosition"></a><h3>Draw.LineRenderer.GetEndPosition( line )</h3></dt>
<dd>
Returns the line renderer's end position.
<br><br>

    <strong>Parameters:</strong>
    <ul>
        
        <li>
          line (LineRenderer) The line renderer.
        </li>
        
    </ul>


    <strong>Return value:</strong>
    <ul>(Vector3) The end position.</ul>

</dd>
<hr>
    
        
<dt><a name="Draw.LineRenderer.GetLength"></a><h3>Draw.LineRenderer.GetLength( line )</h3></dt>
<dd>
Returns the line renderer's length.
<br><br>

    <strong>Parameters:</strong>
    <ul>
        
        <li>
          line (LineRenderer) The line renderer.
        </li>
        
    </ul>


    <strong>Return value:</strong>
    <ul>(number) The length (in scene units).</ul>

</dd>
<hr>
    
        
<dt><a name="Draw.LineRenderer.GetWidth"></a><h3>Draw.LineRenderer.GetWidth( line )</h3></dt>
<dd>
Returns the line renderer's width.
<br><br>

    <strong>Parameters:</strong>
    <ul>
        
        <li>
          line (LineRenderer) The line renderer.
        </li>
        
    </ul>


    <strong>Return value:</strong>
    <ul>(number) The width.</ul>

</dd>
<hr>
    
        
<dt><a name="Draw.LineRenderer.New"></a><h3>Draw.LineRenderer.New( gameObject, params )</h3></dt>
<dd>
Creates a new LineRenderer component.
<br><br>

    <strong>Parameters:</strong>
    <ul>
        
        <li>
          gameObject (GameObject) The game object.
        </li>
        
        <li>
          params (table) A table of parameters.
        </li>
        
    </ul>


    <strong>Return value:</strong>
    <ul>(LineRenderer) The new component.</ul>

</dd>
<hr>
    
        
<dt><a name="Draw.LineRenderer.Set"></a><h3>Draw.LineRenderer.Set( line, params )</h3></dt>
<dd>
Apply the content of the params argument to the provided line renderer. Overwrite Component.Set().
<br><br>

    <strong>Parameters:</strong>
    <ul>
        
        <li>
          line (LineRenderer) The line renderer.
        </li>
        
        <li>
          params (table) A table of parameters.
        </li>
        
    </ul>


</dd>
<hr>
    
        
<dt><a name="Draw.LineRenderer.SetDirection"></a><h3>Draw.LineRenderer.SetDirection( line, direction, useDirectionAsLength, draw )</h3></dt>
<dd>
Set the line renderer's direction. It also updates line renderer's end position.
<br><br>

    <strong>Parameters:</strong>
    <ul>
        
        <li>
          line (LineRenderer) The line renderer.
        </li>
        
        <li>
          direction (Vector3) The direction.
        </li>
        
        <li>
          useDirectionAsLength (boolean) [default=false] Tell whether to update the line renderer's length based on the provided direction's vector length.
        </li>
        
        <li>
          draw (boolean) [default=true] Tell whether to re-draw immediately the line renderer.
        </li>
        
    </ul>


</dd>
<hr>
    
        
<dt><a name="Draw.LineRenderer.SetEndPosition"></a><h3>Draw.LineRenderer.SetEndPosition( line, endPosition, draw )</h3></dt>
<dd>
Set the line renderer's end position. It also updates the line renderer's direction and length.
<br><br>

    <strong>Parameters:</strong>
    <ul>
        
        <li>
          line (LineRenderer) The line renderer.
        </li>
        
        <li>
          endPosition (Vector3) The end position.
        </li>
        
        <li>
          draw (boolean) [default=true] Tell whether to re-draw immediately the line renderer.
        </li>
        
    </ul>


</dd>
<hr>
    
        
<dt><a name="Draw.LineRenderer.SetLength"></a><h3>Draw.LineRenderer.SetLength( line, length, draw )</h3></dt>
<dd>
Set the line renderer's length. It also updates line renderer's end position.
<br><br>

    <strong>Parameters:</strong>
    <ul>
        
        <li>
          line (LineRenderer) The line renderer.
        </li>
        
        <li>
          length (number) The length (in scene units).
        </li>
        
        <li>
          draw (boolean) [default=true] Tell whether to re-draw immediately the line renderer.
        </li>
        
    </ul>


</dd>
<hr>
    
        
<dt><a name="Draw.LineRenderer.SetWidth"></a><h3>Draw.LineRenderer.SetWidth( line, width, draw )</h3></dt>
<dd>
Set the line renderer's width (and height).
<br><br>

    <strong>Parameters:</strong>
    <ul>
        
        <li>
          line (LineRenderer) The line renderer.
        </li>
        
        <li>
          width (number) The width (in scene units).
        </li>
        
        <li>
          draw (boolean) [default=true] Tell whether to re-draw immediately the line renderer.
        </li>
        
    </ul>


</dd>
<hr>
    
</dl>

