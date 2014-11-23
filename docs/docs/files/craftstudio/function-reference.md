# CraftStudio Function reference

<table class="function_list">
    
        <tr>
            <td class="name"><a href="#Asset.Get">Asset.Get</a>( assetPath, assetType, errorIfAssetNotFound )</td>
            <td class="summary">Alias of CraftStudio.FindAsset( assetPath[, assetType] ).</td>
        </tr>
    
        <tr>
            <td class="name"><a href="#Asset.GetId">Asset.GetId</a>( asset )</td>
            <td class="summary">Returns the asset's internal unique identifier.</td>
        </tr>
    
        <tr>
            <td class="name"><a href="#Asset.GetName">Asset.GetName</a>( asset )</td>
            <td class="summary">Returns the name of the provided asset.</td>
        </tr>
    
        <tr>
            <td class="name"><a href="#Asset.GetPath">Asset.GetPath</a>( asset )</td>
            <td class="summary">Returns the path of the provided asset.</td>
        </tr>
    
        <tr>
            <td class="name"><a href="#Camera.Set">Camera.Set</a>( camera, params )</td>
            <td class="summary">Apply the content of the params argument to the provided camera.</td>
        </tr>
    
        <tr>
            <td class="name"><a href="#Camera.SetProjectionMode">Camera.SetProjectionMode</a>( camera, projectionMode )</td>
            <td class="summary">Sets the camera projection mode.</td>
        </tr>
    
        <tr>
            <td class="name"><a href="#Component.Destroy">Component.Destroy</a>( component )</td>
            <td class="summary">Destroy the provided component, removing it from the game object.</td>
        </tr>
    
        <tr>
            <td class="name"><a href="#Component.GetId">Component.GetId</a>( component )</td>
            <td class="summary">Returns the component's internal unique identifier.</td>
        </tr>
    
        <tr>
            <td class="name"><a href="#Component.Set">Component.Set</a>( component, params )</td>
            <td class="summary">Apply the content of the params argument to the provided component.</td>
        </tr>
    
        <tr>
            <td class="name"><a href="#CraftStudio.Destroy">CraftStudio.Destroy</a>( object )</td>
            <td class="summary">Removes the specified game object (and all of its descendants) or the specified component from its game object.</td>
        </tr>
    
        <tr>
            <td class="name"><a href="#CraftStudio.Input.ToggleMouseLock">CraftStudio.Input.ToggleMouseLock</a>(  )</td>
            <td class="summary">Toggle the locked state of the mouse, which can be accessed via the CraftStudio.Input.isMouseLocked property.</td>
        </tr>
    
        <tr>
            <td class="name"><a href="#CraftStudio.LoadScene">CraftStudio.LoadScene</a>( sceneNameOrAsset )</td>
            <td class="summary">Schedules loading the specified scene after the current tick (1/60th of a second) has completed.</td>
        </tr>
    
        <tr>
            <td class="name"><a href="#GameObject.AddComponent">GameObject.AddComponent</a>( gameObject, componentType, params )</td>
            <td class="summary">Add a component to the game object and optionally initialize it.</td>
        </tr>
    
        <tr>
            <td class="name"><a href="#GameObject.AddTag">GameObject.AddTag</a>( gameObject, tag )</td>
            <td class="summary">Add the provided tag(s) to the provided game object.</td>
        </tr>
    
        <tr>
            <td class="name"><a href="#GameObject.BroadcastMessage">GameObject.BroadcastMessage</a>( gameObject, functionName, data )</td>
            <td class="summary">Tries to call a method with the provided name on all the scriptedBehaviors attached to the game object or any of its descendants.</td>
        </tr>
    
        <tr>
            <td class="name"><a href="#GameObject.Destroy">GameObject.Destroy</a>( gameObject )</td>
            <td class="summary">Destroy the game object at the end of this frame.</td>
        </tr>
    
        <tr>
            <td class="name"><a href="#GameObject.Get">GameObject.Get</a>( name, errorIfGameObjectNotFound )</td>
            <td class="summary">Alias of CraftStudio.FindGameObject(name).</td>
        </tr>
    
        <tr>
            <td class="name"><a href="#GameObject.GetChild">GameObject.GetChild</a>( gameObject, name, recursive )</td>
            <td class="summary">Alias of GameObject.FindChild().</td>
        </tr>
    
        <tr>
            <td class="name"><a href="#GameObject.GetChildren">GameObject.GetChildren</a>( gameObject, recursive, includeSelf )</td>
            <td class="summary">Get all descendants of the game object.</td>
        </tr>
    
        <tr>
            <td class="name"><a href="#GameObject.GetComponent">GameObject.GetComponent</a>( gameObject, componentType )</td>
            <td class="summary">Get the first component of the provided type attached to the game object.</td>
        </tr>
    
        <tr>
            <td class="name"><a href="#GameObject.GetId">GameObject.GetId</a>( gameObject )</td>
            <td class="summary">Returns the game object's internal unique identifier.</td>
        </tr>
    
        <tr>
            <td class="name"><a href="#GameObject.GetScriptedBehavior">GameObject.GetScriptedBehavior</a>( gameObject, scriptNameOrAsset )</td>
            <td class="summary">Get the provided scripted behavior instance attached to the game object.</td>
        </tr>
    
        <tr>
            <td class="name"><a href="#GameObject.GetTags">GameObject.GetTags</a>( gameObject )</td>
            <td class="summary">Returns the tag(s) of the provided game object.</td>
        </tr>
    
        <tr>
            <td class="name"><a href="#GameObject.GetWithTag">GameObject.GetWithTag</a>( tag )</td>
            <td class="summary">Returns the game object(s) that have all the provided tag(s).</td>
        </tr>
    
        <tr>
            <td class="name"><a href="#GameObject.HasTag">GameObject.HasTag</a>( gameObject, tag, atLeastOneTag )</td>
            <td class="summary">Tell whether the provided game object has all (or at least one of) the provided tag(s).</td>
        </tr>
    
        <tr>
            <td class="name"><a href="#GameObject.Instantiate">GameObject.Instantiate</a>( gameObjectName, sceneNameOrAsset, params )</td>
            <td class="summary">Create a new game object with the content of the provided scene and optionally initialize it.</td>
        </tr>
    
        <tr>
            <td class="name"><a href="#GameObject.New">GameObject.New</a>( name, params )</td>
            <td class="summary">Create a new game object and optionally initialize it.</td>
        </tr>
    
        <tr>
            <td class="name"><a href="#GameObject.RemoveTag">GameObject.RemoveTag</a>( gameObject, tag )</td>
            <td class="summary">Remove the provided tag(s) from the provided game object.</td>
        </tr>
    
        <tr>
            <td class="name"><a href="#GameObject.SendMessage">GameObject.SendMessage</a>( gameObject, functionName, data )</td>
            <td class="summary">Tries to call a method with the provided name on all the scriptedBehaviors attached to the game object.</td>
        </tr>
    
        <tr>
            <td class="name"><a href="#GameObject.Set">GameObject.Set</a>( gameObject, params )</td>
            <td class="summary">Apply the content of the params argument to the provided game object.</td>
        </tr>
    
        <tr>
            <td class="name"><a href="#GameObject.SetParent">GameObject.SetParent</a>( gameObject, parentNameOrInstance, keepLocalTransform )</td>
            <td class="summary">Set the game object's parent.</td>
        </tr>
    
        <tr>
            <td class="name"><a href="#MapRenderer.Set">MapRenderer.Set</a>( mapRenderer, params )</td>
            <td class="summary">Apply the content of the params argument to the provided map renderer.</td>
        </tr>
    
        <tr>
            <td class="name"><a href="#MapRenderer.SetMap">MapRenderer.SetMap</a>( mapRenderer, mapNameOrAsset, replaceTileSet )</td>
            <td class="summary">Attach the provided map to the provided map renderer.</td>
        </tr>
    
        <tr>
            <td class="name"><a href="#MapRenderer.SetTileSet">MapRenderer.SetTileSet</a>( mapRenderer, tileSetNameOrAsset )</td>
            <td class="summary">Set the specified tileSet for the mapRenderer's map.</td>
        </tr>
    
        <tr>
            <td class="name"><a href="#ModelRenderer.Set">ModelRenderer.Set</a>( modelRenderer, params )</td>
            <td class="summary">Apply the content of the params argument to the provided model renderer.</td>
        </tr>
    
        <tr>
            <td class="name"><a href="#ModelRenderer.SetAnimation">ModelRenderer.SetAnimation</a>( modelRenderer, animationNameOrAsset )</td>
            <td class="summary">Set the specified animation for the modelRenderer's current model.</td>
        </tr>
    
        <tr>
            <td class="name"><a href="#ModelRenderer.SetModel">ModelRenderer.SetModel</a>( modelRenderer, modelNameOrAsset )</td>
            <td class="summary">Attach the provided model to the provided modelRenderer.</td>
        </tr>
    
        <tr>
            <td class="name"><a href="#Ray.Cast">Ray.Cast</a>( ray, gameObjects, sortByDistance )</td>
            <td class="summary">Check the collision of the ray against the provided set of game objects.</td>
        </tr>
    
        <tr>
            <td class="name"><a href="#Ray.IntersectsGameObject">Ray.IntersectsGameObject</a>( ray, gameObjectNameOrInstance )</td>
            <td class="summary">Check if the ray intersect the specified game object.</td>
        </tr>
    
        <tr>
            <td class="name"><a href="#RaycastHit.New">RaycastHit.New</a>( params )</td>
            <td class="summary">Create a new RaycastHit </td>
        </tr>
    
        <tr>
            <td class="name"><a href="#Scene.Append">Scene.Append</a>( sceneNameOrAsset, parentNameOrInstance )</td>
            <td class="summary">Alias of CraftStudio.AppendScene().</td>
        </tr>
    
        <tr>
            <td class="name"><a href="#Scene.Load">Scene.Load</a>( sceneNameOrAsset )</td>
            <td class="summary">Alias of CraftStudio.LoadScene().</td>
        </tr>
    
        <tr>
            <td class="name"><a href="#TextRenderer.SetAlignment">TextRenderer.SetAlignment</a>( textRenderer, alignment )</td>
            <td class="summary">Set the text's alignment.</td>
        </tr>
    
        <tr>
            <td class="name"><a href="#TextRenderer.SetFont">TextRenderer.SetFont</a>( textRenderer, fontNameOrAsset )</td>
            <td class="summary">Set the provided font to the provided text renderer.</td>
        </tr>
    
        <tr>
            <td class="name"><a href="#TextRenderer.SetTextWidth">TextRenderer.SetTextWidth</a>( textRenderer, width )</td>
            <td class="summary">Update the game object's scale to make the text appear the provided width.</td>
        </tr>
    
        <tr>
            <td class="name"><a href="#Transform.GetScale">Transform.GetScale</a>( transform )</td>
            <td class="summary">Get the transform's global scale.</td>
        </tr>
    
        <tr>
            <td class="name"><a href="#Transform.SetLocalScale">Transform.SetLocalScale</a>( transform, scale )</td>
            <td class="summary">Set the transform's local scale.</td>
        </tr>
    
        <tr>
            <td class="name"><a href="#Transform.SetScale">Transform.SetScale</a>( transform, scale )</td>
            <td class="summary">Set the transform's global scale.</td>
        </tr>
    
</table>

<dl class="function">
    
        
<dt><a name="Asset.Get"></a><h3>Asset.Get( assetPath, assetType, errorIfAssetNotFound )</h3></dt>
<dd>
Alias of CraftStudio.FindAsset( assetPath[, assetType] ). Get the asset of the specified name and type. The first argument may be an asset object, so that you can check if a variable was an asset object or name (and get the corresponding object).
<br><br>

    <strong>Parameters:</strong>
    <ul>
        
        <li>
          assetPath (string or one of the asset type) The fully-qualified asset name or asset object.
        </li>
        
        <li>
          assetType [optional] (string) The asset type as a case-insensitive string.
        </li>
        
        <li>
          errorIfAssetNotFound [default=false] Throw an error if the asset was not found (instead of returning nil).
        </li>
        
    </ul>


    <strong>Return value:</strong>
    <ul>(One of the asset type) The asset, or nil if none is found.</ul>

</dd>
<hr>
    
        
<dt><a name="Asset.GetId"></a><h3>Asset.GetId( asset )</h3></dt>
<dd>
Returns the asset's internal unique identifier.
<br><br>

    <strong>Parameters:</strong>
    <ul>
        
        <li>
          asset (any asset type) The asset.
        </li>
        
    </ul>


    <strong>Return value:</strong>
    <ul>(number) The id.</ul>

</dd>
<hr>
    
        
<dt><a name="Asset.GetName"></a><h3>Asset.GetName( asset )</h3></dt>
<dd>
Returns the name of the provided asset.
<br><br>

    <strong>Parameters:</strong>
    <ul>
        
        <li>
          asset (One of the asset types) The asset instance.
        </li>
        
    </ul>


    <strong>Return value:</strong>
    <ul>(string) The name (the last segment of the fully-qualified path).</ul>

</dd>
<hr>
    
        
<dt><a name="Asset.GetPath"></a><h3>Asset.GetPath( asset )</h3></dt>
<dd>
Returns the path of the provided asset.
<br><br>

    <strong>Parameters:</strong>
    <ul>
        
        <li>
          asset (One of the asset types) The asset instance.
        </li>
        
    </ul>


    <strong>Return value:</strong>
    <ul>(string) The fully-qualified asset path.</ul>

</dd>
<hr>
    
        
<dt><a name="Camera.Set"></a><h3>Camera.Set( camera, params )</h3></dt>
<dd>
Apply the content of the params argument to the provided camera.
<br><br>

    <strong>Parameters:</strong>
    <ul>
        
        <li>
          camera (Camera) The camera.
        </li>
        
        <li>
          params (table) A table of parameters to set the component with.
        </li>
        
    </ul>


</dd>
<hr>
    
        
<dt><a name="Camera.SetProjectionMode"></a><h3>Camera.SetProjectionMode( camera, projectionMode )</h3></dt>
<dd>
Sets the camera projection mode.
<br><br>

    <strong>Parameters:</strong>
    <ul>
        
        <li>
          camera (Camera) The camera.
        </li>
        
        <li>
          projectionMode (string or Camera.ProjectionMode) The projection mode. Possible values are "perspective", "orthographic" (as a case-insensitive string), Camera.ProjectionMode.Perspective or Camera.ProjectionMode.Orthographic.
        </li>
        
    </ul>


</dd>
<hr>
    
        
<dt><a name="Component.Destroy"></a><h3>Component.Destroy( component )</h3></dt>
<dd>
Destroy the provided component, removing it from the game object. Note that the component is removed only at the end of the current frame.
<br><br>

    <strong>Parameters:</strong>
    <ul>
        
        <li>
          component (any component type) The component.
        </li>
        
    </ul>


</dd>
<hr>
    
        
<dt><a name="Component.GetId"></a><h3>Component.GetId( component )</h3></dt>
<dd>
Returns the component's internal unique identifier.
<br><br>

    <strong>Parameters:</strong>
    <ul>
        
        <li>
          component (any component type) The component.
        </li>
        
    </ul>


    <strong>Return value:</strong>
    <ul>(number) The id.</ul>

</dd>
<hr>
    
        
<dt><a name="Component.Set"></a><h3>Component.Set( component, params )</h3></dt>
<dd>
Apply the content of the params argument to the provided component.
<br><br>

    <strong>Parameters:</strong>
    <ul>
        
        <li>
          component (any component's type) The component.
        </li>
        
        <li>
          params (table) A table of parameters to set the component with.
        </li>
        
    </ul>


</dd>
<hr>
    
        
<dt><a name="CraftStudio.Destroy"></a><h3>CraftStudio.Destroy( object )</h3></dt>
<dd>
Removes the specified game object (and all of its descendants) or the specified component from its game object. You can also optionally specify a dynamically loaded asset for unloading (See Map.LoadFromPackage ). Sets the 'isDestroyed' property to 'true' and fires the 'OnDestroy' event on the object.
<br><br>

    <strong>Parameters:</strong>
    <ul>
        
        <li>
          object (GameObject, a component or a dynamically loaded asset) The game object, component or a dynamically loaded asset (like a map loaded with Map.LoadFromPackage).
        </li>
        
    </ul>


</dd>
<hr>
    
        
<dt><a name="CraftStudio.Input.ToggleMouseLock"></a><h3>CraftStudio.Input.ToggleMouseLock(  )</h3></dt>
<dd>
Toggle the locked state of the mouse, which can be accessed via the CraftStudio.Input.isMouseLocked property.
<br><br>


</dd>
<hr>
    
        
<dt><a name="CraftStudio.LoadScene"></a><h3>CraftStudio.LoadScene( sceneNameOrAsset )</h3></dt>
<dd>
Schedules loading the specified scene after the current tick (1/60th of a second) has completed. When the new scene is loaded, all of the current scene's game objects will be removed. Calling this function doesn't immediately stops the calling function. As such, you might want to add a return statement afterwards.
<br><br>

    <strong>Parameters:</strong>
    <ul>
        
        <li>
          sceneNameOrAsset (string or Scene) The scene name or asset.
        </li>
        
    </ul>


</dd>
<hr>
    
        
<dt><a name="GameObject.AddComponent"></a><h3>GameObject.AddComponent( gameObject, componentType, params )</h3></dt>
<dd>
Add a component to the game object and optionally initialize it.
<br><br>

    <strong>Parameters:</strong>
    <ul>
        
        <li>
          gameObject (GameObject) The game object.
        </li>
        
        <li>
          componentType (string or Script) The component type, or script asset, path or alias (can't be Transform or ScriptedBehavior).
        </li>
        
        <li>
          params [optional] (string, Script or table) A table of parameters to initialize the new component with or, if componentType is 'ScriptedBehavior', the mandatory script name or asset.
        </li>
        
    </ul>


    <strong>Return value:</strong>
    <ul>(mixed) The component.</ul>

</dd>
<hr>
    
        
<dt><a name="GameObject.AddTag"></a><h3>GameObject.AddTag( gameObject, tag )</h3></dt>
<dd>
Add the provided tag(s) to the provided game object.
<br><br>

    <strong>Parameters:</strong>
    <ul>
        
        <li>
          gameObject (GameObject) The game object.
        </li>
        
        <li>
          tag (string or table) One or several tag(s) (as a string or table of strings).
        </li>
        
    </ul>


</dd>
<hr>
    
        
<dt><a name="GameObject.BroadcastMessage"></a><h3>GameObject.BroadcastMessage( gameObject, functionName, data )</h3></dt>
<dd>
Tries to call a method with the provided name on all the scriptedBehaviors attached to the game object or any of its descendants. The data argument can be nil or a table you want the method to receive as its first (and only) argument. If none of the scripteBehaviors attached to the game object or its children have a method matching the provided name, nothing happens.
<br><br>

    <strong>Parameters:</strong>
    <ul>
        
        <li>
          gameObject (GameObject) The game object.
        </li>
        
        <li>
          functionName (string) The method name.
        </li>
        
        <li>
          data [optional] (table) The data to pass along the method call.
        </li>
        
    </ul>


</dd>
<hr>
    
        
<dt><a name="GameObject.Destroy"></a><h3>GameObject.Destroy( gameObject )</h3></dt>
<dd>
Destroy the game object at the end of this frame.
<br><br>

    <strong>Parameters:</strong>
    <ul>
        
        <li>
          gameObject (GameObject) The game object.
        </li>
        
    </ul>


</dd>
<hr>
    
        
<dt><a name="GameObject.Get"></a><h3>GameObject.Get( name, errorIfGameObjectNotFound )</h3></dt>
<dd>
Alias of CraftStudio.FindGameObject(name). Get the first game object with the provided name.
<br><br>

    <strong>Parameters:</strong>
    <ul>
        
        <li>
          name (string) The game object name.
        </li>
        
        <li>
          errorIfGameObjectNotFound [default=false] (boolean) Throw an error if the game object was not found (instead of returning nil).
        </li>
        
    </ul>


    <strong>Return value:</strong>
    <ul>(GameObject) The game object or nil if none is found.</ul>

</dd>
<hr>
    
        
<dt><a name="GameObject.GetChild"></a><h3>GameObject.GetChild( gameObject, name, recursive )</h3></dt>
<dd>
Alias of GameObject.FindChild(). Find the first game object's child with the provided name. If the name is not provided, it returns the first child.
<br><br>

    <strong>Parameters:</strong>
    <ul>
        
        <li>
          gameObject (GameObject) The game object.
        </li>
        
        <li>
          name [optional] (string) The child name (may be hyerarchy of names separated by dots).
        </li>
        
        <li>
          recursive [default=false] (boolean) Search for the child in all descendants instead of just the first generation.
        </li>
        
    </ul>


    <strong>Return value:</strong>
    <ul>(GameObject) The child or nil if none is found.</ul>

</dd>
<hr>
    
        
<dt><a name="GameObject.GetChildren"></a><h3>GameObject.GetChildren( gameObject, recursive, includeSelf )</h3></dt>
<dd>
Get all descendants of the game object.
<br><br>

    <strong>Parameters:</strong>
    <ul>
        
        <li>
          gameObject (GameObject) The game object.
        </li>
        
        <li>
          recursive [default=false] (boolean) Look for all descendants instead of just the first generation.
        </li>
        
        <li>
          includeSelf [default=false] (boolean) Include the game object in the children.
        </li>
        
    </ul>


    <strong>Return value:</strong>
    <ul>(table) The children.</ul>

</dd>
<hr>
    
        
<dt><a name="GameObject.GetComponent"></a><h3>GameObject.GetComponent( gameObject, componentType )</h3></dt>
<dd>
Get the first component of the provided type attached to the game object.
<br><br>

    <strong>Parameters:</strong>
    <ul>
        
        <li>
          gameObject (GameObject) The game object.
        </li>
        
        <li>
          componentType (string or Script) The component type, or script asset, path or alias.
        </li>
        
    </ul>


    <strong>Return value:</strong>
    <ul>(One of the component types) The component instance, or nil if none is found.</ul>

</dd>
<hr>
    
        
<dt><a name="GameObject.GetId"></a><h3>GameObject.GetId( gameObject )</h3></dt>
<dd>
Returns the game object's internal unique identifier.
<br><br>

    <strong>Parameters:</strong>
    <ul>
        
        <li>
          gameObject (GameObject) The game object.
        </li>
        
    </ul>


    <strong>Return value:</strong>
    <ul>(number) The id.</ul>

</dd>
<hr>
    
        
<dt><a name="GameObject.GetScriptedBehavior"></a><h3>GameObject.GetScriptedBehavior( gameObject, scriptNameOrAsset )</h3></dt>
<dd>
Get the provided scripted behavior instance attached to the game object.
<br><br>

    <strong>Parameters:</strong>
    <ul>
        
        <li>
          gameObject (GameObject) The game object.
        </li>
        
        <li>
          scriptNameOrAsset (string or Script) The script name or asset.
        </li>
        
    </ul>


    <strong>Return value:</strong>
    <ul>(ScriptedBehavior) The ScriptedBehavior instance.</ul>

</dd>
<hr>
    
        
<dt><a name="GameObject.GetTags"></a><h3>GameObject.GetTags( gameObject )</h3></dt>
<dd>
Returns the tag(s) of the provided game object.
<br><br>

    <strong>Parameters:</strong>
    <ul>
        
        <li>
          gameObject (GameObject) The game object.
        </li>
        
    </ul>


    <strong>Return value:</strong>
    <ul>(table) The tag(s) (empty if the game object has no tag).</ul>

</dd>
<hr>
    
        
<dt><a name="GameObject.GetWithTag"></a><h3>GameObject.GetWithTag( tag )</h3></dt>
<dd>
Returns the game object(s) that have all the provided tag(s).
<br><br>

    <strong>Parameters:</strong>
    <ul>
        
        <li>
          tag (string or table) One or several tag(s) (as a string or table of strings).
        </li>
        
    </ul>


    <strong>Return value:</strong>
    <ul>(table) The game object(s) (empty if none is found).</ul>

</dd>
<hr>
    
        
<dt><a name="GameObject.HasTag"></a><h3>GameObject.HasTag( gameObject, tag, atLeastOneTag )</h3></dt>
<dd>
Tell whether the provided game object has all (or at least one of) the provided tag(s).
<br><br>

    <strong>Parameters:</strong>
    <ul>
        
        <li>
          gameObject (GameObject) The game object.
        </li>
        
        <li>
          tag (string or table) One or several tag (as a string or table of strings).
        </li>
        
        <li>
          atLeastOneTag [default=false] (boolean) If true, returns true if the game object has AT LEAST one of the tag (instead of ALL the tag).
        </li>
        
    </ul>


    <strong>Return value:</strong>
    <ul>(boolean) True</ul>

</dd>
<hr>
    
        
<dt><a name="GameObject.Instantiate"></a><h3>GameObject.Instantiate( gameObjectName, sceneNameOrAsset, params )</h3></dt>
<dd>
Create a new game object with the content of the provided scene and optionally initialize it.
<br><br>

    <strong>Parameters:</strong>
    <ul>
        
        <li>
          gameObjectName (string) The game object name.
        </li>
        
        <li>
          sceneNameOrAsset (string or Scene) The scene name or scene asset.
        </li>
        
        <li>
          params [optional] (table) A table with parameters to initialize the new game object with.
        </li>
        
    </ul>


    <strong>Return value:</strong>
    <ul>(GameObject) The new game object.</ul>

</dd>
<hr>
    
        
<dt><a name="GameObject.New"></a><h3>GameObject.New( name, params )</h3></dt>
<dd>
Create a new game object and optionally initialize it. When the first argument is a scene name or asset, the scene may contains only one top-level game object. If it's not the case, the function won't return any game object yet some may have been created (depending on the behavior of CS.AppendScene()).
<br><br>

    <strong>Parameters:</strong>
    <ul>
        
        <li>
          name (string or Scene) The game object name or scene name or scene asset.
        </li>
        
        <li>
          params (table) [optional] A table with parameters to initialize the new game object with.
        </li>
        
    </ul>


    <strong>Return value:</strong>
    <ul>(GameObject) The new game object.</ul>

</dd>
<hr>
    
        
<dt><a name="GameObject.RemoveTag"></a><h3>GameObject.RemoveTag( gameObject, tag )</h3></dt>
<dd>
Remove the provided tag(s) from the provided game object. If the 'tag' argument is not provided, all tag of the game object will be removed.
<br><br>

    <strong>Parameters:</strong>
    <ul>
        
        <li>
          gameObject (GameObject) The game object.
        </li>
        
        <li>
          tag [optional] (string or table) One or several tag(s) (as a string or table of strings).
        </li>
        
    </ul>


</dd>
<hr>
    
        
<dt><a name="GameObject.SendMessage"></a><h3>GameObject.SendMessage( gameObject, functionName, data )</h3></dt>
<dd>
Tries to call a method with the provided name on all the scriptedBehaviors attached to the game object. The data argument can be nil or a table you want the method to receive as its first (and only) argument. If none of the scripteBehaviors attached to the game object or its children have a method matching the provided name, nothing happens.
<br><br>

    <strong>Parameters:</strong>
    <ul>
        
        <li>
          gameObject (GameObject) The game object.
        </li>
        
        <li>
          functionName (string) The method name.
        </li>
        
        <li>
          data [optional] (table) The data to pass along the method call.
        </li>
        
    </ul>


</dd>
<hr>
    
        
<dt><a name="GameObject.Set"></a><h3>GameObject.Set( gameObject, params )</h3></dt>
<dd>
Apply the content of the params argument to the provided game object.
<br><br>

    <strong>Parameters:</strong>
    <ul>
        
        <li>
          gameObject (GameObject) The game object.
        </li>
        
        <li>
          params (table) A table of parameters to set the game object with.
        </li>
        
    </ul>


</dd>
<hr>
    
        
<dt><a name="GameObject.SetParent"></a><h3>GameObject.SetParent( gameObject, parentNameOrInstance, keepLocalTransform )</h3></dt>
<dd>
Set the game object's parent. Optionaly carry over the game object's local transform instead of the global one.
<br><br>

    <strong>Parameters:</strong>
    <ul>
        
        <li>
          gameObject (GameObject) The game object.
        </li>
        
        <li>
          parentNameOrInstance [optional] (string or GameObject) The parent name or game object (or nil to remove the parent).
        </li>
        
        <li>
          keepLocalTransform [default=false] (boolean) Carry over the game object's local transform instead of the global one.
        </li>
        
    </ul>


</dd>
<hr>
    
        
<dt><a name="MapRenderer.Set"></a><h3>MapRenderer.Set( mapRenderer, params )</h3></dt>
<dd>
Apply the content of the params argument to the provided map renderer.
<br><br>

    <strong>Parameters:</strong>
    <ul>
        
        <li>
          mapRenderer (MapRenderer) The map renderer.
        </li>
        
        <li>
          params (table) A table of parameters to set the component with.
        </li>
        
    </ul>


</dd>
<hr>
    
        
<dt><a name="MapRenderer.SetMap"></a><h3>MapRenderer.SetMap( mapRenderer, mapNameOrAsset, replaceTileSet )</h3></dt>
<dd>
Attach the provided map to the provided map renderer.
<br><br>

    <strong>Parameters:</strong>
    <ul>
        
        <li>
          mapRenderer (MapRenderer) The map renderer.
        </li>
        
        <li>
          mapNameOrAsset (string or Map) [optional] The map name or asset, or nil.
        </li>
        
        <li>
          replaceTileSet (boolean) [default=true] Replace the current TileSet by the one set for the provided map in the map editor.
        </li>
        
    </ul>


</dd>
<hr>
    
        
<dt><a name="MapRenderer.SetTileSet"></a><h3>MapRenderer.SetTileSet( mapRenderer, tileSetNameOrAsset )</h3></dt>
<dd>
Set the specified tileSet for the mapRenderer's map.
<br><br>

    <strong>Parameters:</strong>
    <ul>
        
        <li>
          mapRenderer (MapRenderer) The mapRenderer.
        </li>
        
        <li>
          tileSetNameOrAsset (string or TileSet) [optional] The tileSet name or asset, or nil.
        </li>
        
    </ul>


</dd>
<hr>
    
        
<dt><a name="ModelRenderer.Set"></a><h3>ModelRenderer.Set( modelRenderer, params )</h3></dt>
<dd>
Apply the content of the params argument to the provided model renderer.
<br><br>

    <strong>Parameters:</strong>
    <ul>
        
        <li>
          modelRenderer (ModelRenderer) The model renderer.
        </li>
        
        <li>
          params (table) A table of parameters to set the component with.
        </li>
        
    </ul>


</dd>
<hr>
    
        
<dt><a name="ModelRenderer.SetAnimation"></a><h3>ModelRenderer.SetAnimation( modelRenderer, animationNameOrAsset )</h3></dt>
<dd>
Set the specified animation for the modelRenderer's current model.
<br><br>

    <strong>Parameters:</strong>
    <ul>
        
        <li>
          modelRenderer (ModelRenderer) The modelRenderer.
        </li>
        
        <li>
          animationNameOrAsset (string or ModelAnimation) [optional] The animation name or asset, or nil.
        </li>
        
    </ul>


</dd>
<hr>
    
        
<dt><a name="ModelRenderer.SetModel"></a><h3>ModelRenderer.SetModel( modelRenderer, modelNameOrAsset )</h3></dt>
<dd>
Attach the provided model to the provided modelRenderer.
<br><br>

    <strong>Parameters:</strong>
    <ul>
        
        <li>
          modelRenderer (ModelRenderer) The modelRenderer.
        </li>
        
        <li>
          modelNameOrAsset (string or Model) [optional] The model name or asset, or nil.
        </li>
        
    </ul>


</dd>
<hr>
    
        
<dt><a name="Ray.Cast"></a><h3>Ray.Cast( ray, gameObjects, sortByDistance )</h3></dt>
<dd>
Check the collision of the ray against the provided set of game objects.
<br><br>

    <strong>Parameters:</strong>
    <ul>
        
        <li>
          ray (Ray) The ray.
        </li>
        
        <li>
          gameObjects (table) The set of game objects to cast the ray against.
        </li>
        
        <li>
          sortByDistance [default=false] (boolean) Sort the raycastHit by increasing distance in the returned table.
        </li>
        
    </ul>


    <strong>Return value:</strong>
    <ul>(table) A table of RaycastHits (will be empty if the ray didn't intersects anything).</ul>

</dd>
<hr>
    
        
<dt><a name="Ray.IntersectsGameObject"></a><h3>Ray.IntersectsGameObject( ray, gameObjectNameOrInstance )</h3></dt>
<dd>
Check if the ray intersect the specified game object.
<br><br>

    <strong>Parameters:</strong>
    <ul>
        
        <li>
          ray (Ray) The ray.
        </li>
        
        <li>
          gameObjectNameOrInstance (string or GameObject) The game object instance or name.
        </li>
        
    </ul>


    <strong>Return value:</strong>
    <ul>(RaycastHit) A raycastHit with the if there was a collision, or nil.</ul>

</dd>
<hr>
    
        
<dt><a name="RaycastHit.New"></a><h3>RaycastHit.New( params )</h3></dt>
<dd>
Create a new RaycastHit
<br><br>

    <strong>Parameters:</strong>
    <ul>
        
        <li>
          params 
        </li>
        
    </ul>


    <strong>Return value:</strong>
    <ul>(RaycastHit) The raycastHit.</ul>

</dd>
<hr>
    
        
<dt><a name="Scene.Append"></a><h3>Scene.Append( sceneNameOrAsset, parentNameOrInstance )</h3></dt>
<dd>
Alias of CraftStudio.AppendScene(). Appends the specified scene to the game by instantiating all of its game objects. Contrary to CraftStudio.LoadScene, this doesn't unload the current scene nor waits for the next tick: it happens right away. You can optionally specify a parent game object which will be used as a root for adding all game objects. Returns the game object appended if there was only one root game object in the provided scene.
<br><br>

    <strong>Parameters:</strong>
    <ul>
        
        <li>
          sceneNameOrAsset (string or Scene) The scene name or asset.
        </li>
        
        <li>
          parentNameOrInstance (string or GameObject) [optional] The parent game object name or instance.
        </li>
        
    </ul>


    <strong>Return value:</strong>
    <ul>(GameObject) The appended game object, or nil.</ul>

</dd>
<hr>
    
        
<dt><a name="Scene.Load"></a><h3>Scene.Load( sceneNameOrAsset )</h3></dt>
<dd>
Alias of CraftStudio.LoadScene(). Schedules loading the specified scene after the current tick (frame) (1/60th of a second) has completed. When the new scene is loaded, all of the current scene's game objects will be removed. Calling this function doesn't immediately stops the calling function. As such, you might want to add a return statement afterwards.
<br><br>

    <strong>Parameters:</strong>
    <ul>
        
        <li>
          sceneNameOrAsset (string or Scene) The scene name or asset.
        </li>
        
    </ul>


</dd>
<hr>
    
        
<dt><a name="TextRenderer.SetAlignment"></a><h3>TextRenderer.SetAlignment( textRenderer, alignment )</h3></dt>
<dd>
Set the text's alignment.
<br><br>

    <strong>Parameters:</strong>
    <ul>
        
        <li>
          textRenderer (TextRenderer) The textRenderer.
        </li>
        
        <li>
          alignment (string or TextRenderer.Alignment) The alignment. Values (case-insensitive when of type string) may be "left", "center", "right", TextRenderer.Alignment.Left, TextRenderer.Alignment.Center or TextRenderer.Alignment.Right.
        </li>
        
    </ul>


</dd>
<hr>
    
        
<dt><a name="TextRenderer.SetFont"></a><h3>TextRenderer.SetFont( textRenderer, fontNameOrAsset )</h3></dt>
<dd>
Set the provided font to the provided text renderer.
<br><br>

    <strong>Parameters:</strong>
    <ul>
        
        <li>
          textRenderer (TextRenderer) The text renderer.
        </li>
        
        <li>
          fontNameOrAsset (string or Font) [optional] The font name or asset, or nil.
        </li>
        
    </ul>


</dd>
<hr>
    
        
<dt><a name="TextRenderer.SetTextWidth"></a><h3>TextRenderer.SetTextWidth( textRenderer, width )</h3></dt>
<dd>
Update the game object's scale to make the text appear the provided width.
<br><br>

    <strong>Parameters:</strong>
    <ul>
        
        <li>
          textRenderer (TextRenderer) The textRenderer.
        </li>
        
        <li>
          width (number) The text's width in scene units.
        </li>
        
    </ul>


</dd>
<hr>
    
        
<dt><a name="Transform.GetScale"></a><h3>Transform.GetScale( transform )</h3></dt>
<dd>
Get the transform's global scale.
<br><br>

    <strong>Parameters:</strong>
    <ul>
        
        <li>
          transform (Transform) The transform component.
        </li>
        
    </ul>


    <strong>Return value:</strong>
    <ul>(Vector3) The global scale.</ul>

</dd>
<hr>
    
        
<dt><a name="Transform.SetLocalScale"></a><h3>Transform.SetLocalScale( transform, scale )</h3></dt>
<dd>
Set the transform's local scale.
<br><br>

    <strong>Parameters:</strong>
    <ul>
        
        <li>
          transform (Transform) The transform component.
        </li>
        
        <li>
          scale (number or Vector3) The global scale.
        </li>
        
    </ul>


</dd>
<hr>
    
        
<dt><a name="Transform.SetScale"></a><h3>Transform.SetScale( transform, scale )</h3></dt>
<dd>
Set the transform's global scale.
<br><br>

    <strong>Parameters:</strong>
    <ul>
        
        <li>
          transform (Transform) The transform component.
        </li>
        
        <li>
          scale (number or Vector3) The global scale.
        </li>
        
    </ul>


</dd>
<hr>
    
</dl>

