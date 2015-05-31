# Modules

A module is a particular object that Daneel works with when it is loaded and during runtime.  
Modules are mostly used to provide user configuration and create custom components.

- [Registering a module](#registering)
- [Configurationn](#config)
- [Loading](#loading)
- [Runtime](#runtime)
- [Creating components](#components)

<a name="registering"></a>
## Registering a module

Registering a module is no difficult than adding the module name and object to the `Daneel.modules` global object :

    ModuleObject = {}
    Daneel.modules.ModuleName = ModuleObject


<a name="config"></a>
## Configuration

The first point of a module is to expose some configuration that can be overridden by the user.

The module object may provide a `ModuleObject.DefaultConfig()` function that returns a table (the default config).  
In a similar way, users may setup a `ModuleObject.UserConfig()` function that returns a table (the user config), containing only the configuration key/values they want to override (or add).

Upon loading, Daneel will merge the user config into the default config and put the resulting object in the `Config` property on the module object.

Daneel's config is set before the module's config, so the `Daneel.Config` property is accessible.

    function ModuleObject.DefaultConfig()
        return {
            key = value,

            key2 = {
                key = "value",
                otherKey = "module value"
            }
        }
    end

    -- you may set the default value for the Config property, it will be overridden when Daneel loads
    ModuleObject.Config = ModuleObject.DefaultConfig()

    function ModuleObject.UserConfig()
        return {
            key2 = {
                key = "user value" -- this value will override the default value set in the default config
            },

            userKey = "user value",
        }
    end

    -- Upon loading, the ModuleObject.Config object has this content :

    {
        key = value,
        userKey = "user value",
        
        key2 = {
            key = "user value",
            otherKey = "module value"
        }
    }



<a name="loading"></a>
## Loading

Daneel may call a `Load()` function if it exists on the module object whenever it loads.  
It is only called once, after all of the config have been set and before `Daneel.Awake()` (and all the module's `Awake()` functions) gets called.


<a name="runtime"></a>
## Runtime

During runtime, Daneel may call the functions `Awake()`, `Start()` and `Update()` if any of them are found on the module object.  
As with regular scripts, `Awake()` and `Start()` are called in sequence at the beginning of a scene, while `Update()` is called every frames.


<a name="components"></a>
## Creating custom components

A component is a specialized object that works closely with a game object (game object are said to be composed of components), modifying its properties and purpose.

Daneel provide these properties to components (built-in and custom ones) :

- Can be created via `gameObject:AddComponent( componentType[, params] )`.
- Can be created/mass-set via `gameObject:Set( { componentType = {} } )`.
- Getters and setters of the component [can be accessed dynamically](features#dynamic-functions).
- Extend the `Component` object : you can call `component:GetId()`, `component:Set(params)` and `component:Destroy()`.
- `Daneel.Debug.GetType()` returns the component type whenever passed a component instance.

But component also have these requirement :

- Component objects must provide a `New()` function that accept the game object as first argument, accept a second optional `params` argument of type table and returns the component instance.
- Component objects must be the metatable of the component instances.
- The component instances must be accessible on the game object through a property named after the component's type with the first letter lowercase. Ie : `gameObject.modelRenderer`, `gameObject.progressBar`.
- The game object should be accessible on the component instance through a `gameObject` property.

A typical (and minimal) component constructor looks like this :

    MyComponent = {}

    --- Create a new MyComponent component.
    -- @param gameObject (GameObject) The game object.
    -- @param params (table) [optional] A table of parameters.
    -- @return (MyComponent) The new component.
    function MyComponent.New( gameObject, params )
        local component = setmetatable( {}, MyComponent )
        
        component.gameObject = gameObject
        gameObject.myComponent = component

        if params ~= nil then
            component:Set( params )
        end
        return component
    end

You register a component by setting a `componentObjects` property in a module default config.  
Note that the component object may also be the module object itself.
    
    function ModuleObject.DefaultConfig()
        return {
            -- register the object as a component
            componentObjects = {
                MyComponent = MyComponent,
            }
            -- the component type will also be added to Daneel.Config.componentTypes
            -- the component object will also be added to Daneel.Config.objects
        }
    end
