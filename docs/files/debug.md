# Debug

For an easy debugging during development, Daneel provides extensive error reporting, a stack trace and several usefull functions. Debugging is turned off by default, so be sure to set the value of the `debug.enableDebug` property [in the config](/docs/setup#configuration) to `true` to turn it on.    
Be advised that having the debug enabled seriously lowers the performances, so be sure to disable debug before exporting your game.


Because it may sometimes helps you locate the actual source of an error, you may turn off all of the debug features at runtime with `Daneel.Debug.Disable()`.

- [Error reporting](#error-reporting)
- [Stack Trace](#stack-trace)
- [Data Types](#data-types)
- [Setting up error reporting for you functions](#setup-error-reportingp)


<a name="error-reporting"></a>
## Error reporting

In every functions introduced or modified by Daneel, every arguments are checked for type and value and a comprehensive error message is thrown if needed.  
For instance, passing false instead of the game object's name with `gameObject:GetChild()` would trigger the following error :  

    GameObject.GetChild( gameObject, name[, recursive] ) : Argument 'name' is of type 'boolean' with value 'false' instead of 'string'.


<a name="stack-trace"></a>
## Stack Trace

If you enabled it in the config (set `debug.enableStackTrace` to `true`), Daneel prints a "stack trace" in the Runtime Report when an error is triggered.  
The stack trace nicely shows the history of function calls within the framework that lead to the error and display the values received as argument.  
It reads from top to bottom, the last function called -where the error occurred- at the bottom.  
For instance, when trying to set the model of a `ModelRenderer` to a `Model` that does not exists via `gameObject:Set()` :

    ~~~~~ Daneel.Debug.StackTrace ~~~~~
    #01 GameObject.Set( GameObject: 14476932: 'Object1', table: 04DAC148 )
    #02 Component.Set( ModelRenderer: 31780825, table: 04DAC238 )
    #03 ModelRenderer.SetModel( ModelRenderer: 31780825, "UnknowModel" )
    [string "Behavior Daneel/Daneel (0)"]:293: ModelRenderer.SetModel( modelRenderer, modelNameOrAsset ) : Argument 'modelNameOrAsset' : model with name 'UnknowModel' was not found.

When the stack trace is enabled, the location of the error shown in the Runtime Report will always be in the `Daneel` script, so pay attention to the stack trace and the error message to locate the actual source of the error.  

**But sometimes it won't help you.** In this case, disable the debug from the piece of code that seems to cause the error with `Daneel.Debug.Disable()`.


<a name="data-types"></a>
## Data types

The function `Daneel.Debug.GetType(object)` may returns any of the built-in Lua types or the name of any of the objects introduced by CraftStudio or Daneel : `GameObject`, `ModelRenderer`, `RaycastHit`, ...

`GetType()` actually returns the name as a string of the provided table's metatable (or the Lua type in every other cases), instead of returning `"table"`.  
This automatically works when the metatable is a first-level global variable but it can work for nested objects too as you define them in the `objects` table in the config.

Ie :

	GUI = { Hud = {} }
	function GUI.Hud.New()
		return setmetatable( {}, GUI.Hud )
	end

	Vector2 = {}
	function Vector2.New()
		return setmetatable( {}, Vector2 )
	end

	function Daneel.UserConfig()
		return {
			debug = {
				enableDebug = true,
			}, -- the error reporting is enabled but not the stack trace

			objects = {
				ObjectName = MyObject
				-- Debug.GetType() will return "ObjectName" when a table with MyObject as a metatable is provided
			}
		}
	end

You may also set the objects table in the default config of modules.

    function GUI.DefaultConfig()
        return {
            -- ...

            objects = {
                Vector2 = Vector2
            }
        }
    end


<a name="setup-error-reporting"></a>
## Setting up error reporting for your functions

You can use the functions in the `Daneel.Debug` object to setup stack trace and error reporting in your own scripts.  
Be sure to [check the function reference](../daneel/function-reference) and the example below to learn how to use them.

    function Scene.Append( sceneNameOrAsset, parentNameOrInstance )
        Daneel.Debug.StackTrace.BeginFunction( "Scene.Append", sceneNameOrAsset, parentNameOrInstance )
        local errorHead = "Scene.Append( sceneNameOrAsset[, parentNameOrInstance] ) : "
        Daneel.Debug.CheckArgType( sceneNameOrAsset, "sceneNameOrAsset", {"string", "Scene"}, errorHead )
        Daneel.Debug.CheckOptionalArgType( parentNameOrInstance, "parentNameOrInstance", {"string", "GameObject"}, errorHead )

        local scene = Asset.Get( sceneNameOrAsset, "Scene", true )
        local parent = nil
        if parentNameOrInstance ~= nil then
            parent = GameObject.Get( parentNameOrInstance, true )
        end
        local gameObject = CraftStudio.AppendScene( scene, parent )

        Daneel.Debug.StackTrace.EndFunction()
        return gameObject
    end

This works but it's also quite verbose.

Thankfully there is another way : setting the function's arguments information in the `Daneel.Debug.functionArgumentsInfo` object.
Here is the same example as above :
    
    Daneel.Debug.functionArgumentsInfo["Scene.Append"] = { 
        { "sceneNameOrAsset", {"string", "Scene"} },
        { "parentNameOrInstance", {"string", "GameObject"}, isOptional = true },
    }

    function Scene.Append( sceneNameOrAsset, parentNameOrInstance )
        local scene = Asset.Get( sceneNameOrAsset, "Scene", true )
        local parent = nil
        if parentNameOrInstance ~= nil then
            parent = GameObject.Get( parentNameOrInstance, true )
        end
        return CraftStudio.AppendScene( scene, parent )
    end

The keys in the `Daneel.Debug.functionArgumentsInfo` object are the full function's names, including the object(s) the functions are nested in.  

The values are the argument's lists as a table. Arguments must be formatted as follow :

- The first entry in the table must be the argument's name.
- The second entry may be the argument's type(s) as a string or a table of strings (when the argument's type may be one of several). Omit this entry when the argument can be of any type.

When the argument is optional :

- Set the `isOptional` property to `true`.
- Or set the argument's default value as the value of the `defaultValue` property. You can also omit the argument's type because it will be inferred from the default value's type (but an argument with a default value may have several expected types).

Ie :

    { "value", "number" }
    { "alignment", {"string", "userdata", "number"} }
    
    { "decimal", "number", isOptional = true }
    { "modelNameOrAsset", { "string", "Model" }, isOptional = true }
    
    { "replaceTileSet", defaultValue = true },
    { "params", defaultValue = {} }


The function will also be included in the stack trace by default.  
You may prevent this by setting the `includeInStackTrace` property to `false` in the argument's list :

    Daneel.Debug.functionArgumentsInfo["Scene.Append"] = { 
        includeInStackTrace = false,

        { "sceneNameOrAsset", {"string", "Scene"} },
        ...
    }

Instead of setting this data in the `Daneel.Debug.functionArgumentsInfo` object, you may call the `Daneel.Debug.RegisterFunction( functionName, argumentsData )` function directly.
