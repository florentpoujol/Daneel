# Daneel Function reference

<table class="function_list">
    
        <tr>
            <td class="name"><a href="#Daneel.Cache.GetId">Daneel.Cache.GetId</a>( object )</td>
            <td class="summary">Returns an interger greater than 0 and incremented by 1 from the last time the funciton was called.</td>
        </tr>
    
        <tr>
            <td class="name"><a href="#Daneel.Debug.CheckArgType">Daneel.Debug.CheckArgType</a>( argument, argumentName, expectedArgumentTypes, p_errorHead )</td>
            <td class="summary">Check the provided argument's type against the provided type(s) and display error if they don't match.</td>
        </tr>
    
        <tr>
            <td class="name"><a href="#Daneel.Debug.CheckArgValue">Daneel.Debug.CheckArgValue</a>( argument, argumentName, expectedArgumentValues, p_errorHead, defaultValue )</td>
            <td class="summary">Check if the provided argument's value is in the provided expected value(s).</td>
        </tr>
    
        <tr>
            <td class="name"><a href="#Daneel.Debug.CheckOptionalArgType">Daneel.Debug.CheckOptionalArgType</a>( argument, argumentName, expectedArgumentTypes, p_errorHead, defaultValue )</td>
            <td class="summary">If the provided argument is not nil, check the provided argument's type against the provided type(s) and display error if they don't match.</td>
        </tr>
    
        <tr>
            <td class="name"><a href="#Daneel.Debug.Disable">Daneel.Debug.Disable</a>( info )</td>
            <td class="summary">Disable the debug from this point onward.</td>
        </tr>
    
        <tr>
            <td class="name"><a href="#Daneel.Debug.GetNameFromValue">Daneel.Debug.GetNameFromValue</a>( value )</td>
            <td class="summary">Returns the name as a string of the global variable (including nested tables) whose value is provided.</td>
        </tr>
    
        <tr>
            <td class="name"><a href="#Daneel.Debug.RegisterFunction">Daneel.Debug.RegisterFunction</a>( name, argsData )</td>
            <td class="summary">Overload a function to call debug functions before and after it is itself called.</td>
        </tr>
    
        <tr>
            <td class="name"><a href="#Daneel.Debug.StackTrace.BeginFunction">Daneel.Debug.StackTrace.BeginFunction</a>( functionName, ... )</td>
            <td class="summary">Register a function call in the stack trace.</td>
        </tr>
    
        <tr>
            <td class="name"><a href="#Daneel.Debug.StackTrace.EndFunction">Daneel.Debug.StackTrace.EndFunction</a>(  )</td>
            <td class="summary">Closes a successful function call, removing it from the stacktrace.</td>
        </tr>
    
        <tr>
            <td class="name"><a href="#Daneel.Debug.StackTrace.Print">Daneel.Debug.StackTrace.Print</a>(  )</td>
            <td class="summary">Prints the StackTrace.</td>
        </tr>
    
        <tr>
            <td class="name"><a href="#Daneel.Debug.ToRawString">Daneel.Debug.ToRawString</a>( data )</td>
            <td class="summary">Bypass the __tostring() function that may exists on the data's metatable.</td>
        </tr>
    
        <tr>
            <td class="name"><a href="#Daneel.Debug.Try">Daneel.Debug.Try</a>( _function )</td>
            <td class="summary">Allow to test out a piece of code without killing the script if the code throws an error.</td>
        </tr>
    
        <tr>
            <td class="name"><a href="#Daneel.Event.Fire">Daneel.Event.Fire</a>( object, eventName, ... )</td>
            <td class="summary">Fire the provided event at the provided object or the one that listen to it, transmitting along all subsequent arguments if some exists.</td>
        </tr>
    
        <tr>
            <td class="name"><a href="#Daneel.Event.Listen">Daneel.Event.Listen</a>( eventName, functionOrObject, isPersistent )</td>
            <td class="summary">Make the provided function or object listen to the provided event(s).</td>
        </tr>
    
        <tr>
            <td class="name"><a href="#Daneel.Event.StopListen">Daneel.Event.StopListen</a>( eventName, functionOrObject )</td>
            <td class="summary">Make the provided function or object to stop listen to the provided event(s).</td>
        </tr>
    
        <tr>
            <td class="name"><a href="#Daneel.Utilities.AllowDynamicGettersAndSetters">Daneel.Utilities.AllowDynamicGettersAndSetters</a>( Object, ancestors )</td>
            <td class="summary">Allow to call getters and setters as if they were variable on the instance of the provided object.</td>
        </tr>
    
        <tr>
            <td class="name"><a href="#Daneel.Utilities.ButtonExists">Daneel.Utilities.ButtonExists</a>( buttonName )</td>
            <td class="summary">Tell whether the provided button name exists amongst the Game Controls, or not.</td>
        </tr>
    
        <tr>
            <td class="name"><a href="#Daneel.Utilities.CaseProof">Daneel.Utilities.CaseProof</a>( name, set )</td>
            <td class="summary">Make sure that the case of the provided name is correct by checking it against the values in the provided set.</td>
        </tr>
    
        <tr>
            <td class="name"><a href="#Daneel.Utilities.ReplaceInString">Daneel.Utilities.ReplaceInString</a>( string, replacements )</td>
            <td class="summary">Replace placeholders in the provided string with their corresponding provided replacements.</td>
        </tr>
    
        <tr>
            <td class="name"><a href="#Daneel.Utilities.ToNumber">Daneel.Utilities.ToNumber</a>( data )</td>
            <td class="summary">A more flexible version of Lua's built-in tonumber() function.</td>
        </tr>
    
        <tr>
            <td class="name"><a href="#error">error</a>( message, doNotPrintStacktrace )</td>
            <td class="summary">Print the stackTrace unless told otherwise then the provided error in the console.</td>
        </tr>
    
        <tr>
            <td class="name"><a href="#string.split">string.split</a>( s, delimiter, delimiterIsPattern )</td>
            <td class="summary">Some Lua functions are overridden here with some Daneel-specific stuffs </td>
        </tr>
    
</table>

<dl class="function">
    
        
<dt><a name="Daneel.Cache.GetId"></a><h3>Daneel.Cache.GetId( object )</h3></dt>
<dd>
Returns an interger greater than 0 and incremented by 1 from the last time the funciton was called. If an object is provided, returns the object's id (if no id is found, it is set).
<br><br>

    <strong>Parameters:</strong>
    <ul>
        
        <li>
          object (table) [optional] An object.
        </li>
        
    </ul>


    <strong>Return value:</strong>
    <ul>(number) The id.</ul>

</dd>
<hr>
    
        
<dt><a name="Daneel.Debug.CheckArgType"></a><h3>Daneel.Debug.CheckArgType( argument, argumentName, expectedArgumentTypes, p_errorHead )</h3></dt>
<dd>
Check the provided argument's type against the provided type(s) and display error if they don't match.
<br><br>

    <strong>Parameters:</strong>
    <ul>
        
        <li>
          argument (mixed) The argument to check.
        </li>
        
        <li>
          argumentName (string) The argument name.
        </li>
        
        <li>
          expectedArgumentTypes (string or table) The expected argument type(s).
        </li>
        
        <li>
          p_errorHead [optional] (string) The beginning of the error message.
        </li>
        
    </ul>


    <strong>Return value:</strong>
    <ul>(mixed) The argument's type.</ul>

</dd>
<hr>
    
        
<dt><a name="Daneel.Debug.CheckArgValue"></a><h3>Daneel.Debug.CheckArgValue( argument, argumentName, expectedArgumentValues, p_errorHead, defaultValue )</h3></dt>
<dd>
Check if the provided argument's value is in the provided expected value(s). When that's not the case, return the value of the 'defaultValue' argument, or throws an error when it is nil. Arguments of type string are considered case-insensitive. The case will be corrected but no error will be thrown. When 'expectedArgumentValues' is of type table, it is always considered as a table of several expected values.
<br><br>

    <strong>Parameters:</strong>
    <ul>
        
        <li>
          argument (mixed) The argument to check.
        </li>
        
        <li>
          argumentName (string) The argument name.
        </li>
        
        <li>
          expectedArgumentValues (mixed) The expected argument values(s).
        </li>
        
        <li>
          p_errorHead [optional] (string) The beginning of the error message.
        </li>
        
        <li>
          defaultValue [optional] (mixed) The optional default value.
        </li>
        
    </ul>


    <strong>Return value:</strong>
    <ul>(mixed) The argument's value (one of the expected argument values or default value)</ul>

</dd>
<hr>
    
        
<dt><a name="Daneel.Debug.CheckOptionalArgType"></a><h3>Daneel.Debug.CheckOptionalArgType( argument, argumentName, expectedArgumentTypes, p_errorHead, defaultValue )</h3></dt>
<dd>
If the provided argument is not nil, check the provided argument's type against the provided type(s) and display error if they don't match.
<br><br>

    <strong>Parameters:</strong>
    <ul>
        
        <li>
          argument (mixed) The argument to check.
        </li>
        
        <li>
          argumentName (string) The argument name.
        </li>
        
        <li>
          expectedArgumentTypes (string or table) The expected argument type(s).
        </li>
        
        <li>
          p_errorHead [optional] (string) The beginning of the error message.
        </li>
        
        <li>
          defaultValue [optional] (mixed) The default value to return if 'argument' is nil.
        </li>
        
    </ul>


    <strong>Return value:</strong>
    <ul>(mixed) The value of 'argument' if it's non-nil, or the value of 'defaultValue'.</ul>

</dd>
<hr>
    
        
<dt><a name="Daneel.Debug.Disable"></a><h3>Daneel.Debug.Disable( info )</h3></dt>
<dd>
Disable the debug from this point onward.
<br><br>

    <strong>Parameters:</strong>
    <ul>
        
        <li>
          info [optional] (string) Some info about why or where you disabled the debug. Will be printed in the Runtime Report.
        </li>
        
    </ul>


</dd>
<hr>
    
        
<dt><a name="Daneel.Debug.GetNameFromValue"></a><h3>Daneel.Debug.GetNameFromValue( value )</h3></dt>
<dd>
Returns the name as a string of the global variable (including nested tables) whose value is provided. This only works if the value of the variable is a table or a function. When the variable is nested in one or several tables (like GUI.Hud), it must have been set in the 'objects' table in the config.
<br><br>

    <strong>Parameters:</strong>
    <ul>
        
        <li>
          value (table or function) Any global variable, any object from CraftStudio or Daneel or objects whose name is set in 'userObjects' in the Daneel.Config.
        </li>
        
    </ul>


    <strong>Return value:</strong>
    <ul>(string) The name, or nil.</ul>

</dd>
<hr>
    
        
<dt><a name="Daneel.Debug.RegisterFunction"></a><h3>Daneel.Debug.RegisterFunction( name, argsData )</h3></dt>
<dd>
Overload a function to call debug functions before and after it is itself called. Called from Daneel.Load()
<br><br>

    <strong>Parameters:</strong>
    <ul>
        
        <li>
          name (string) The function name
        </li>
        
        <li>
          argsData (table) Mostly the list of arguments. may contains the 'includeInStackTrace' key.
        </li>
        
    </ul>


</dd>
<hr>
    
        
<dt><a name="Daneel.Debug.StackTrace.BeginFunction"></a><h3>Daneel.Debug.StackTrace.BeginFunction( functionName, ... )</h3></dt>
<dd>
Register a function call in the stack trace.
<br><br>

    <strong>Parameters:</strong>
    <ul>
        
        <li>
          functionName (string) The function name.
        </li>
        
        <li>
          ... [optional] (mixed) Arguments received by the function.
        </li>
        
    </ul>


</dd>
<hr>
    
        
<dt><a name="Daneel.Debug.StackTrace.EndFunction"></a><h3>Daneel.Debug.StackTrace.EndFunction(  )</h3></dt>
<dd>
Closes a successful function call, removing it from the stacktrace.
<br><br>


</dd>
<hr>
    
        
<dt><a name="Daneel.Debug.StackTrace.Print"></a><h3>Daneel.Debug.StackTrace.Print(  )</h3></dt>
<dd>
Prints the StackTrace.
<br><br>


</dd>
<hr>
    
        
<dt><a name="Daneel.Debug.ToRawString"></a><h3>Daneel.Debug.ToRawString( data )</h3></dt>
<dd>
Bypass the __tostring() function that may exists on the data's metatable.
<br><br>

    <strong>Parameters:</strong>
    <ul>
        
        <li>
          data (mixed) The data to be converted to string.
        </li>
        
    </ul>


    <strong>Return value:</strong>
    <ul>(string) The string.</ul>

</dd>
<hr>
    
        
<dt><a name="Daneel.Debug.Try"></a><h3>Daneel.Debug.Try( _function )</h3></dt>
<dd>
Allow to test out a piece of code without killing the script if the code throws an error. If the code throw an error, it will be printed in the Runtime Report but it won't kill the script that calls Daneel.Debug.Try(). Does not protect against exceptions thrown by CraftStudio.
<br><br>

    <strong>Parameters:</strong>
    <ul>
        
        <li>
          _function (function or userdata) The function containing the code to try out.
        </li>
        
    </ul>


    <strong>Return value:</strong>
    <ul>(boolean) True if the code runs without errors, false otherwise.</ul>

</dd>
<hr>
    
        
<dt><a name="Daneel.Event.Fire"></a><h3>Daneel.Event.Fire( object, eventName, ... )</h3></dt>
<dd>
Fire the provided event at the provided object or the one that listen to it, transmitting along all subsequent arguments if some exists. <br> Allowed set of arguments are : <br> (eventName[, ...]) <br> (object, eventName[, ...]) <br>
<br><br>

    <strong>Parameters:</strong>
    <ul>
        
        <li>
          object [optional] (table) The object to which fire the event at. If nil or abscent, will send the event to its listeners.
        </li>
        
        <li>
          eventName (string) The event name.
        </li>
        
        <li>
          ... [optional] Some arguments to pass along.
        </li>
        
    </ul>


</dd>
<hr>
    
        
<dt><a name="Daneel.Event.Listen"></a><h3>Daneel.Event.Listen( eventName, functionOrObject, isPersistent )</h3></dt>
<dd>
Make the provided function or object listen to the provided event(s). The function will be called whenever the provided event will be fired.
<br><br>

    <strong>Parameters:</strong>
    <ul>
        
        <li>
          eventName (string or table) The event name (or names in a table).
        </li>
        
        <li>
          functionOrObject (function or table) The function (not the function name) or the object.
        </li>
        
        <li>
          isPersistent (boolean) [default=false] Tell whether the listener automatically stops to listen to any event when a new scene is loaded. Always false when the listener is a game object or a component.
        </li>
        
    </ul>


</dd>
<hr>
    
        
<dt><a name="Daneel.Event.StopListen"></a><h3>Daneel.Event.StopListen( eventName, functionOrObject )</h3></dt>
<dd>
Make the provided function or object to stop listen to the provided event(s).
<br><br>

    <strong>Parameters:</strong>
    <ul>
        
        <li>
          eventName (string or table) [optional] The event name or names in a table or nil to stop listen to every events.
        </li>
        
        <li>
          functionOrObject (function, string or GameObject) The function, or the game object name or instance.
        </li>
        
    </ul>


</dd>
<hr>
    
        
<dt><a name="Daneel.Utilities.AllowDynamicGettersAndSetters"></a><h3>Daneel.Utilities.AllowDynamicGettersAndSetters( Object, ancestors )</h3></dt>
<dd>
Allow to call getters and setters as if they were variable on the instance of the provided object. The instances are tables that have the provided object as metatable. Optionally allow to search in a ancestry of objects.
<br><br>

    <strong>Parameters:</strong>
    <ul>
        
        <li>
          Object (mixed) The object.
        </li>
        
        <li>
          ancestors (table) [optional] A table with one or several objects the Object "inherits" from.
        </li>
        
    </ul>


</dd>
<hr>
    
        
<dt><a name="Daneel.Utilities.ButtonExists"></a><h3>Daneel.Utilities.ButtonExists( buttonName )</h3></dt>
<dd>
Tell whether the provided button name exists amongst the Game Controls, or not. If the button name does not exists, it will print an error in the Runtime Report but it won't kill the script that called the function. CS.Input.ButtonExists is an alias of Daneel.Utilities.ButtonExists.
<br><br>

    <strong>Parameters:</strong>
    <ul>
        
        <li>
          buttonName (string) The button name.
        </li>
        
    </ul>


    <strong>Return value:</strong>
    <ul>(boolean) True if the button name exists, false otherwise.</ul>

</dd>
<hr>
    
        
<dt><a name="Daneel.Utilities.CaseProof"></a><h3>Daneel.Utilities.CaseProof( name, set )</h3></dt>
<dd>
Make sure that the case of the provided name is correct by checking it against the values in the provided set.
<br><br>

    <strong>Parameters:</strong>
    <ul>
        
        <li>
          name (string) The name to check the case of.
        </li>
        
        <li>
          set (string or table) A single value or a table of values to check the name against.
        </li>
        
    </ul>


</dd>
<hr>
    
        
<dt><a name="Daneel.Utilities.ReplaceInString"></a><h3>Daneel.Utilities.ReplaceInString( string, replacements )</h3></dt>
<dd>
Replace placeholders in the provided string with their corresponding provided replacements. The placeholders are any pice of string prefixed by a semicolon.
<br><br>

    <strong>Parameters:</strong>
    <ul>
        
        <li>
          string (string) The string.
        </li>
        
        <li>
          replacements (table) The placeholders and their replacements ( { placeholder = "replacement", ... } ).
        </li>
        
    </ul>


    <strong>Return value:</strong>
    <ul>(string) The string.</ul>

</dd>
<hr>
    
        
<dt><a name="Daneel.Utilities.ToNumber"></a><h3>Daneel.Utilities.ToNumber( data )</h3></dt>
<dd>
A more flexible version of Lua's built-in tonumber() function. Returns the first continuous series of numbers found in the text version of the provided data even if it is prefixed or suffied by other characters.
<br><br>

    <strong>Parameters:</strong>
    <ul>
        
        <li>
          data (mixed) Usually string or userdata.
        </li>
        
    </ul>


    <strong>Return value:</strong>
    <ul>(number) The number, or nil.</ul>

</dd>
<hr>
    
        
<dt><a name="error"></a><h3>error( message, doNotPrintStacktrace )</h3></dt>
<dd>
Print the stackTrace unless told otherwise then the provided error in the console. Only exists when debug is enabled. When debug in disabled the built-in 'error(message)'' function exists instead.
<br><br>

    <strong>Parameters:</strong>
    <ul>
        
        <li>
          message (string) The error message.
        </li>
        
        <li>
          doNotPrintStacktrace [optional default=false] (boolean) Set to true to prevent the stacktrace to be printed before the error message.
        </li>
        
    </ul>


</dd>
<hr>
    
        
<dt><a name="string.split"></a><h3>string.split( s, delimiter, delimiterIsPattern )</h3></dt>
<dd>
Some Lua functions are overridden here with some Daneel-specific stuffs
<br><br>

    <strong>Parameters:</strong>
    <ul>
        
        <li>
          s 
        </li>
        
        <li>
          delimiter 
        </li>
        
        <li>
          delimiterIsPattern 
        </li>
        
    </ul>


</dd>
<hr>
    
</dl>

