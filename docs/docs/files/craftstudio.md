# CraftStudio's API extension

The `CraftStudio` script adds new objects, new functions on existing objects and sometimes allow to pass different argument types and new arguments on existing functions. 

- [Mass-setting](/docs/craftstudio/mass-setting)
- [Function Reference](/docs/craftstudio/function-reference)

---

- [Using objects as functions to create instances](#objects-as-function)
- [Game objects](#game-objects)
    - [Getting game objects](#getting-game-objects)
    - [Tags](#tags)
- [Components](#components)
- [Destroying objects](#destroying-objects)
- [Asset](#asset)
- [Scene](#scene)
- [Raycasting](#raycasting)
- [Input](#input)
- [Screen](#screen)


<a name="objects-as-function"></a>
## Using objects as functions to create instances

You may create instances of `GameObject`, `Vector3`, `Quaternion`, `Plane`, `Ray` and `RaycastHit` without the `New()` function, just by using the object as if it was a function :

    Vector3( 10 ) -- same as  Vector3:New( 10 )
    GameObject( "MyObject" ) -- same as GameObject.New( "MyObject" ) or CS.CreateGameObject( "MyObject" )


<a name="game-objects"></a>
## Game objects

Create a game object with `GameObject.New()` (also works as an alias of `CS.AppendScene()`) or `GameObject.Instantiate()`.

Add a component on a game object with `gameObject:AddComponent(componentType[, params])` (also works for scripted behaviors and components introduced by modules).  
Unlike `CS.CreateScriptedBehavior()`, the values in the params argument of `AddComponent()` (when the component is a scripted behavior) are applied **after** the `Awake()` function has been called.

Send a message to a game object and all of its descendants with `gameObject:BroadcastMessage()`.

<a name="getting-game-objects"></a>
### Getting game objects

Get a game object with `GameObject.Get(name)` and get a child with `gameObject:GetChild([name, recursive])`. The `name` argument in `GetChild()` is optional so that writing `gameObject.child` returns the first child (if any) of the game object (thanks to the [dynamic getters and setters](/docs/daneel/dynamic-getters-and-setters)).   
The `name` argument in these functions may be a hierarchy of game objects (several names separated by dots). The functions will return the lowest child in the hierarchy (the last name) that has the specified ancestry.  

With `GameObject.Get()`, the hierarchy must be continuous but you may skip levels with `GetChild()` when the `recursive` argument is `true`.
    
    -- Suppose we have the following hierarchy : World > Map > Background > Model

    local gameObject = GameObject.Get( "Wold" ) -- returns the first game object named "World"

    GameObject.Get( "Map" ) -- returns the first game object named "Map"
    -- is equivalent to :
    gameObject:GetChild( "Map" )

    GameObject.Get( "Map.Background" ) -- return the first child named "Background" of the first game object named "Map"
    -- is equivalent to :
    GameObject.Get( "Map" ):GetChild( "Background" )
    gameObject:GetChild( "Background", true ) -- gameObject:GetChild( "Background" ) returns nil
    gameObject:GetChild( "Map.Background" )

    
    GameObject.Get( "Map.Background.Model" )
    -- is equivalent to : 
    gameObject:GetChild( "Map.Background.Model" )
    gameObject:GetChild( "Map.Model", true )
    gameObject:GetChild( "Model", true )


<a name="tags"></a>
### Tags

Tags are a way to group game objects.  
Manage tags on game objects with `gameObject:AddTag()`, `gameObject:GetTags()`, `gameObject:RemoveTag()`, `gameObject:HasTag()`.
A game object may have several tags and a same tag may be used by several game objects.  

Game objects that have tags are referenced in the `GameObject.Tags[tagName]` table. When getting game objects directly from `GameObject.Tags` and looping on them, **always make sure** that the game objects are alive by searching for the `inner` property.  
Get all game object(s) that have all of the provided tag(s) with `GameObject.GetWithTag()`.

Add the `Tags` script as a scripted behavior to game objects to add tags while in the scene editor (concatenate several tags with a coma).  

The tags on a game object are automatically removed when it is destroyed with `gameObject:Destroy()`. 


<a name="components"></a>
## Components

You may define default values for any of the CraftStudio component's properties/setters (except `Transform`) in the config.
Those default values are applied when the component is added via `gameObject:AddComponent()` or `gameObject:Set()`.
    
    function Daneel.UserConfig()
        return {
            debug = {},

            -- this sets the default font and alignment, for all new textRenderers :
            texRenderer = {
                font = "MyFont",
                alignment = "right",
            }
        }
    end
        
Remember that all asset setters on components may now accept the asset name as argument instead of the asset object.

You may call `component:Set(params)`, `component:Destroy()` and `component:GetId()`.

    self.gameObject.transform:Set({
        eulerAngles = Vector3(0),
        position = self.gameObject.transform.position + Vector3(0,5,0)
    })


`transform:GetScale()`, `transform:SetScale()` may be used to get/set the game object's global scale.  
The global or local scale may be set as a `number` instead of a `Vector3`.

You may scale a `TextRenderer` based on the desired text's length (in scene units) with `textRenderer:SetTextWidth()`.  
The alignment of a `TextRenderer` may be set with the `"left"`, `"center"` or `"right"` values as case-insensitive strings, instead of a `TextRenderer.Alignment` enumeration.


<a name="destroying-objects"></a>
## Destroying objects

All destroyed objects (with `object:Destroy()` or `CS.Destroy()`) gets the `isDestroyed` property set to `true` and the `OnDestroy` event fired at.


<a name="asset"></a>
## Asset 

Get an asset with `Asset.Get( path[, type] )`.  
You can use the asset object as a function, it is a shortcut for the `Get` function`:
    
    Asset( "my asset name" )
    -- is the same as
    Asset.Get( "my asset name" )
    CS.FindAsset( "my asset name" )

Get an asset path with `asset:GetPath()`.  
Get an asset name with `asset:GetName()`. The name is the last segment of the path.

    -- for an asset whose path is "folder/folder 2/asset name"
    asset:GetPath() -- returns "folder/folder 2/asset name"
    -- remember you can also use the dynamic functions with assets, so 'asset.path' would works too

    asset.name -- (or asset:GetName()) returns "asset name"


<a name="scene"></a>
## Scene

Load a scene with `Scene.Load()`, append a scene with `Scene.Append()`.  
Loading a scene fires the global event `OnSceneLoad` before the scene is actually loaded.  
The `Scene.current` property holds the current scene's asset (it isn't set for the first scene).


<a name="raycasting"></a>
## Raycasting

The `RaycastHit` object stores the information regarding the collision between a ray and a game object. It may contains the keys `distance`, `normal`, `hitBlockLocation`, `adjacentBlockLocation`, `hitPosition` (the coordinates in scene units), `hitObject` (the component or the plane that has been hit) and `gameObject`.

The function `ray:IntersectsGameObject(gameObjectNameOrInstance)` returns a raycastHit (a `RaycastHit` instance) if the ray intersects the game object, or nil.  

The function `ray:Cast(gameObjects[, sortByDistance])` cast the ray against the provided set of game objects and returns a table of raycastHits (which will be empty if no game object has been hit).  
The table may be sorted by distance, the closest hit being the first item in the returned table.

The functions `ray:IntersectsModelRenderer()`, `ray:IntersectsMapRenderer()`, `ray:IntersectsTextRenderer()` and `ray:IntersectsPlane()` may return a raycastHit instead of several values if their third argument is `true`.


<a name="input"></a>
## Input

You can check if the mouse is locked or not via the `CS.Input.isMouseLocked` property (a boolean).  
You may toggle the locked state of the mouse with the `CS.Input.ToggleMouseLock()` function.

<a name="screen"></a>
## Screen

`CraftStudio.Screen.aspectRatio` is the screen's aspect ratio.

