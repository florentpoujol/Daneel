# Modules

A module is a particular object that Daneel works with when it is loaded and during runtime.  
Modules can be used to create custom components.

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

Modules are loaded in the same order as they are added in the `Daneel.modules` object.


<a name="config"></a>
## Configuration

The first point of a module is to expose some configuration that can be overridden by the user.

The module object may provide a `DefaultConfig` key which value is a table or a function that returns a table (the default config).  
Users may create on the module object a `UserConfig` table or function that returns a table (the user config) containing only the configuration key/values they want to override.

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


    ModuleObject.UserConfig = {
        key2 = {
            key = "user value" -- this value will override the default value set in the default config
        },

        userKey = "user value",
    }

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

The `Daneel` and `CraftStudio` scripts provide these properties to components (built-in and custom ones) :

- Can be created via `gameObject:AddComponent( componentType[, params] )`.
- Can be created/mass-set via `gameObject:Set( { componentType = {} } )`.
- Getters and setters of the component [can be accessed dynamically](/docs/daneel/dynamic-getters-and-setters).
- Extend the `Component` object : you can call `component:GetId()`, `component:Set(params)` and `component:Destroy()`.
- `Daneel.Debug.GetType()` returns the component type whenever passed a component instance.

But component also have these requirement :

- Are created through a module and thus require Daneel to be loaded.
- Component objects must provide a `New()` function that accept the game object as first argument and returns the component instance.
- Component objects must be the metatable of the component instances.
- The component instances must be accessible on the game object through a property named after the component's type with the first letter lowercase. Ie : `gameObject.modelRenderer`, `gameObject.progressBar`.

And optionnaly (but strongly recommended) :

- The component constructor (the `New()` function) should allow for a second `params` argument of type table that override the default component params set in the module config.
- The game object should be accessible on the component instance through a `gameObject` property.


You register a component by setting a `componentObjects` property in a module default config.
    
    ComponentObject = {}
    ComponentObject.__index = ComponentObject

    -- This is a template for a component constructor
    function ComponentObject.New( gameObject, params )
        local instance = setmetatable( {}, ComponentObject )
        instance.gameObject = gameObject
        gameObject.componentType = instance
        instance:Set( table.merge( ModuleObject.Config.componentType, params ) ) -- not necessarily done at the end of the function
        return instance
    end 

    function ModuleObject.DefaultConfig()
        return {
            -- default component properties (overridable by the user config)
            componentType = {
                property = value,
                -- ...
            },

            -- register the object as a component
            componentObjects = {
                ComponentType = ComponentObject,
            }
            -- the component type will also be added to Daneel.Config.componentTypes
            -- the component object will also be added to Daneel.Config.objects
        }
    end

    -- replace "componentType"/"ComponentType" by the name of the component : "textRenderer"/"TextRenderer", "hud"/"Hud"


