# Debug

For an easier debugging during development, Daneel provides extensive, flexible and easy to setup error reporting, and a stack trace.

Debugging is turned off by default, so be sure to enable it via [Daneel's user config](setup#configuration) :

    function Daneel.UserConfig()
        return {
            debug = {
                enableDebug = true
            }
        }
    end

Be advised that having the debug enabled seriously lowers the performances, so be sure to disable it before exporting your game.

- [Error reporting](#error-reporting)
- [Stack Trace](#stack-trace)
- [Data Types](#data-types)


<a name="error-reporting"></a>
## Error reporting

In every functions introduced or modified by Daneel, every arguments are checked for type and value and a comprehensive error message is thrown if needed.  
For instance, passing a `Vector2` instead of a `Vector3` to `transform:SetPosition()` would trigger the following error :  

    Transform.SetPosition( transform, position ) : Argument 'position' is of type 'Vector2' with value 'Vector2: { x=1, y=2 }' instead of 'Vector3'.


<a name="setup-error-reporting"></a>
### Setting up error reporting for your functions

Be sure to [check the function reference](function-reference) to learn about all the functions of the `Daneel.Debug` object you can use to setup error reporting in your scripts.

The simplest way to setup error reporting is to set information about the function's arguments in the `Daneel.Debug.functionArgumentsInfo` table.  
Ie:

    function Scene.Append( sceneNameOrAsset, parentNameOrInstance )
        local scene = Asset.Get( sceneNameOrAsset, "Scene", true )
        local parent = nil
        if parentNameOrInstance ~= nil then
            parent = GameObject.Get( parentNameOrInstance, true )
        end
        return CraftStudio.AppendScene( scene, parent )
    end

    Daneel.Debug.functionArgumentsInfo["Scene.Append"] = { 
        { "sceneNameOrAsset", {"string", "Scene"} },
        { "parentNameOrInstance", {"string", "GameObject"}, isOptional = true },
    }
    

The keys are the full, global function's names (including the object(s) the functions are nested in).  
Which means that you can not set error reporting for local (or anonymous) functions. They must be globally accessible.

The values are the argument's lists as a table. Arguments must be formatted as follow :

- The first entry in the table must be the argument's name.
- The second entry may be the argument's type(s) as a string or a table of strings (when the argument's type may be one of several). Omit this entry when the argument can be of any type.
- The `isOptional` property must be `true` when the argument is optional.

Ie:

    { "value", "number" }
    { "alignment", {"string", "userdata", "number"} }
    
    { "decimal", "number", isOptional = true }
    { "modelNameOrAsset", { "string", "Model" }, isOptional = true }


This works for public behavior functions too, provided that you set the script asset as the value of the `script` property in the argument's list

    -- in a script named "Folder/MyScript"
    function Behavior:ReceiveDamage( damageCount )
        ...
    end

    Daneel.Debug.functionArgumentsInfo["ReceiveDamage"] = { { "damageCount", "number" }, script = Behavior }

An error in the argument's type (a string instead of a number is passed for instance) would trigger the following error:

    Folder/MyScript.ReceiveDamage( self, damageCount ) : Argument 'damageCount' is of type 'string' with value '"10"' instead of 'number'.

Note that the first argument of a behavior function is always the scripted behavior instance, but that argument is automatically added to the argument's list if it's not found.

<a name="stack-trace"></a>
## Stack Trace

If you enabled it in the config (set the `debug.enableStackTrace` property to `true` as you did for `debug.enableDebug`), Daneel prints a "stack trace" in the Runtime Report when an error is triggered.  
The stack trace nicely shows the history of function calls within the framework and your code that lead to the error and display the values received as argument.  
It reads from top to bottom, the last function called -where the error occurred _a priori_- at the bottom.  

For instance, when trying to set the model of a `ModelRenderer` to a `Model` that does not exists via `gameObject:Set()` :

    ~~~~~ Daneel.Debug.StackTrace ~~~~~
    #01 GameObject.Set( GameObject: 14476932: 'Object1', table: 04DAC148 )
    #02 Component.Set( ModelRenderer: 31780825, table: 04DAC238 )
    #03 ModelRenderer.SetModel( ModelRenderer: 31780825, "UnknowModel" )
    [string "Behavior Daneel/Daneel (0)"]:1302: ModelRenderer.SetModel( modelRenderer, modelNameOrAsset ) : Argument 'modelNameOrAsset' : model with name 'UnknowModel' was not found.

When the stack trace is enabled, the location of the error shown in the Runtime Report will always be in the `Daneel` script, so pay attention to the stack trace and the error message to locate the actual source of the error.  

When error reporting is setup via the `Daneel.Debug.functionArgumentsInfo` table, the functions are added to the stacktrace by default.  
You can prevent this by setting an `includeInStackTrace` property to `false` in the argument's list :

    Daneel.Debug.functionArgumentsInfo["Scene.Append"] = { 
        includeInStackTrace = false,
        { "sceneNameOrAsset", {"string", "Scene"} },
        ...
    }

This also works for any behavior functions you set in the `functionArgumentsInfo` table.

If you want all your functions script's to be easily included in the stack trace, you can just pass the script asset to the `Daneel.Debug.RegisterScript(scriptAsset)` function __at the end of the script__.

Note that because of CrafStudio's inner working, the `Awake()` functions can't be included automatically in the stacktrace.  
You can however include it manually in two ways :

With `Daneel.Debug.StackTrace.BeginFunction(functionName)` and `EndFunction()`,

    function Behavior:Awake()
        Daneel.Debug.StackTrace.BeginFunction("Folder/MyScript.Awake")
        ...
        Daneel.Debug.StackTrace.EndFunction()
    end

Or like this (provided that the script has been registered via `Daneel.Debug.RegisterScript(scriptAsset)`) :

    function Behavior:Awake( calledBySelf )
        if calledBySelf ~= true then
            self:Awake( true )
            return
        end

        ...
    end

You can also include quickly many functions in the stack trace by passing the object they are nested in to the `Daneel.Debug.RegisterObject(object)` function.


<a name="data-types"></a>
## Data types

The function `Daneel.Debug.GetType(value)` may returns any of the built-in Lua types or the name of any of the objects introduced by CraftStudio or Daneel : `GameObject`, `ModelRenderer`, `RaycastHit`, ...

`GetType()` actually returns the name as a string of the provided table's metatable (or the Lua type in every other cases), instead of returning `"table"`.  
This automatically works when the metatable is a first-level global variable but it can work for nested objects too as you define them in the `objects` table in Daneel's or any module's config.

Ie : the function will return `"ObjectName"` when a table with `MyObject` as a metatable is provided

	function Daneel.UserConfig()
		return {
            debug = { ... },

			objects = {
				ObjectName = MyObject
			}
		}
	end

    MyObject = {}

    function MyObject.New()
        return setmetatable( {}, MyObject )
    end

    local instance = MyObject.New()
    Daneel.Debug.GetType( instance ) -- returns "ObjectName"
