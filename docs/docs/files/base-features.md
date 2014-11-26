
In no particular order, a list of Daneel base features 


- [Dynamic functions](#dynamic-functions)
- [Instances Id](#instances-id)
- [Printing out instances](#printing-out-instances)
- [Time object](#time-object)
- [Web Player](#webplayer)


<a name="dynamic-functions"></a>
# Dynamic functions

Getters and setters functions can be accessed in a dynamic way, as if they were simple variables on game objects, components and assets.

Their names must begin by `Get` or `Set` and have the forth letter upper-case (underscore is allowed).  
Ie : `GetSomething()` and `Get_something()` will work, but `Getsomething()` or `getSomething()` won't work.

    local pos = self.gameObject.transform.localPosition
    -- is the same as
    local pos = self.gameObject.transform:GetLocalPosition()

    self.gameObject.name = "a new name"
    -- is the same as 
    self.gameObject:SetName( "a new name" )
    -- note that only one argument (in addition to the object the function works on) can be passed to the function.

You can enable this behavior on any of your objects with `Daneel.Utilities.AllowDynamicGettersAndSetters(Object[, ancestors])`. The `Object` argument should be the metatable of the instances you want to use this feature on. 


<a name="instances-id"></a>
## Instances Id

Game objects, components and other object instances (like [tweeners](/docs/tween)) have a unique Id that you can get via `instance:GetId()`.

If you need to generate such unique Id, `Daneel.Utilities.GetId()` returns a strictly positive integer incremented every times.


<a name="printing-out-instances"></a>
## Printing out instances

Game objects, components, assets and other objects will nicely prints themselves in the Runtime Report when passed to the `print()` function. The type of the instance is followed by its Id and other relevant data like a game object name or an asset path. Ie :
    
    GameObject: 123456789: 'MyObject'
    ModelRenderer: 123456789
    Model: 123456789: 'Folder/ModelName'

You can use `Daneel.Debug.ToRawString()` to bypass this behavior and return the memory address of the table instead.




<a name="tags"></a>
### Tags

Tags are a way to group game objects.  
Manage tags on game objects with `gameObject:AddTag()`, `gameObject:GetTags()`, `gameObject:RemoveTag()`, `gameObject:HasTag()`.
A game object may have several tags and a same tag may be used by several game objects.  

Game objects that have tags are referenced in the `GameObject.Tags[tagName]` table. When getting game objects directly from `GameObject.Tags` and looping on them, **always make sure** that the game objects are alive by searching for the `inner` property.  
Get all game object(s) that have all of the provided tag(s) with `GameObject.GetWithTag()`.

Add the `Tags` script as a scripted behavior to game objects to add tags while in the scene editor (concatenate several tags with a coma).  

The tags on a game object are automatically removed when it is destroyed with `gameObject:Destroy()`. 


# Mass-setting

The `Set(params)` function that you may call on game objects, components and [tweeners](/docs/tween) accept a `params` argument of type table which allow to set variables or call setters in mass.  
Mass-setting is used by every functions that have a `params` argument.

    gameObject:Set({
        parent = "my parent name", -- Set the parent via GameObject.SetParent()
        modelRenderer = {
            opacity = 0.5 -- Set the  model renderer's opacity to 0.5 via ModelRenderer.SetOpacity()
        }
    })

    textRenderer:Set({
        alignment = "right", -- Set the text renderer's alignmet via TextRenderer.SetAlignment()
        randomVariable = "random value"
    })

`component:Set()` can not be accessed on scripted behaviors like this: `behaviorInstance:Set(params)`. But you can write `Component.Set(behaviorInstance, params)` instead.

## Component mass-creation and setting on game objects

With `gameObject:Set()`, you can easily create new components then optionally initialize them or set existing components (including scripted behaviors).  

    gameObject:Set({
        modelRenderer = {
            model = "Model name"
        }, -- will create a modelRenderer if it does not exists yet, then set its model

        camera = {}, -- will create a camera component then do nothing, or just do nothing
    })


Just set the variable of the same name as the component with the first letter lower case. Set the value as a table of parameters. If the component does not exists yet, it will be created. If you want to create a component without initializing it, just leave the table empty.

<a name="objects-as-function"></a>
## Using objects as functions to create instances

You may create instances of `GameObject`, `Vector3`, `Quaternion`, `Plane`, `Ray` and `RaycastHit` without the `New()` function, just by using the object as if it was a function :

    Vector3( 10 ) -- same as  Vector3:New( 10 )
    GameObject( "MyObject" ) -- same as GameObject.New( "MyObject" ) or CS.CreateGameObject( "MyObject" )
