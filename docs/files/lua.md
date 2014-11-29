# Lua

__This script is mandatory.__  
It must be the top-most script in Daneel's folder, just above the `Daneel` script.

The functions in this file extends Lua's built-in `math`, `string` and `table` libraries.

## Function Reference

<table class="function_list">
    
        <tr>
            <td class="name"><a href="#math.isinteger">math.isinteger</a>( number )</td>
            <td class="summary">Tell whether the provided number is an integer.</td>
        </tr>
    
        <tr>
            <td class="name"><a href="#math.lerp">math.lerp</a>( a, b, factor, easing )</td>
            <td class="summary">Returns the value resulting of the linear interpolation between value a and b by the specified factor.</td>
        </tr>
    
        <tr>
            <td class="name"><a href="#math.round">math.round</a>( value, decimal )</td>
            <td class="summary">Return the value rounded to the closest integer or decimal.</td>
        </tr>
    
        <tr>
            <td class="name"><a href="#math.warpangle">math.warpangle</a>( angle )</td>
            <td class="summary">Wrap the provided angle between -180 and 180.</td>
        </tr>
    
        <tr>
            <td class="name"><a href="#string.endswith">string.endswith</a>( s, chunk )</td>
            <td class="summary">Tell whether the provided string ends by the provided chunk or not.</td>
        </tr>
    
        <tr>
            <td class="name"><a href="#string.lcfirst">string.lcfirst</a>( s )</td>
            <td class="summary">Turn the first letter of the string lowercase.</td>
        </tr>
    
        <tr>
            <td class="name"><a href="#string.split">string.split</a>( s, delimiter, delimiterIsPattern )</td>
            <td class="summary">Split the provided string in several chunks, using the provided delimiter.</td>
        </tr>
    
        <tr>
            <td class="name"><a href="#string.startswith">string.startswith</a>( s, chunk )</td>
            <td class="summary">Tell whether the provided string begins by the provided chunk or not.</td>
        </tr>
    
        <tr>
            <td class="name"><a href="#string.totable">string.totable</a>( s )</td>
            <td class="summary">Turn a string into a table, one character per index.</td>
        </tr>
    
        <tr>
            <td class="name"><a href="#string.trim">string.trim</a>( s )</td>
            <td class="summary">Removes the white spaces at the beginning and the end of the provided string.</td>
        </tr>
    
        <tr>
            <td class="name"><a href="#string.trimend">string.trimend</a>( s )</td>
            <td class="summary">Removes the white spaces at the end of the provided string.</td>
        </tr>
    
        <tr>
            <td class="name"><a href="#string.trimstart">string.trimstart</a>( s )</td>
            <td class="summary">Removes the white spaces at the beginning of the provided string.</td>
        </tr>
    
        <tr>
            <td class="name"><a href="#string.ucfirst">string.ucfirst</a>( s )</td>
            <td class="summary">Turn the first letter of the string uppercase.</td>
        </tr>
    
        <tr>
            <td class="name"><a href="#table.combine">table.combine</a>( keys, values )</td>
            <td class="summary">Create an associative table with the provided keys and values tables.</td>
        </tr>
    
        <tr>
            <td class="name"><a href="#table.containsvalue">table.containsvalue</a>( t, value, ignoreCase )</td>
            <td class="summary">Tell whether the provided value is found within the provided table.</td>
        </tr>
    
        <tr>
            <td class="name"><a href="#table.copy">table.copy</a>( t, recursive )</td>
            <td class="summary">Return a copy of the provided table.</td>
        </tr>
    
        <tr>
            <td class="name"><a href="#table.getkey">table.getkey</a>( t, value )</td>
            <td class="summary">Get the key associated with the first occurrence of the provided value.</td>
        </tr>
    
        <tr>
            <td class="name"><a href="#table.getkeys">table.getkeys</a>( t )</td>
            <td class="summary">Return all the keys of the provided table.</td>
        </tr>
    
        <tr>
            <td class="name"><a href="#table.getlength">table.getlength</a>( t, keyType )</td>
            <td class="summary">Returns the length of a table, which is the numbers of keys of the provided type (or of any type), for which the value is not nil.</td>
        </tr>
    
        <tr>
            <td class="name"><a href="#table.getvalue">table.getvalue</a>( t, keys )</td>
            <td class="summary">Safely search several levels down inside nested tables.</td>
        </tr>
    
        <tr>
            <td class="name"><a href="#table.getvalues">table.getvalues</a>( t )</td>
            <td class="summary">Return all the values of the provided table.</td>
        </tr>
    
        <tr>
            <td class="name"><a href="#table.havesamecontent">table.havesamecontent</a>( table1, table2 )</td>
            <td class="summary">Compare table1 and table2.</td>
        </tr>
    
        <tr>
            <td class="name"><a href="#table.isarray">table.isarray</a>( t, strict )</td>
            <td class="summary">Tell whether he provided table is an array (has only integer keys).</td>
        </tr>
    
        <tr>
            <td class="name"><a href="#table.merge">table.merge</a>( ..., recursive )</td>
            <td class="summary">Merge two or more tables into one new table.</td>
        </tr>
    
        <tr>
            <td class="name"><a href="#table.mergein">table.mergein</a>( ..., recursive )</td>
            <td class="summary">Merge two or more tables in place, into the first provided table.</td>
        </tr>
    
        <tr>
            <td class="name"><a href="#table.print">table.print</a>( t )</td>
            <td class="summary">Print all key/value pairs within the provided table.</td>
        </tr>
    
        <tr>
            <td class="name"><a href="#table.reindex">table.reindex</a>( t )</td>
            <td class="summary">Turn the provided table (with only integer keys) in a proper sequence (with consecutive integer key beginning at 1).</td>
        </tr>
    
        <tr>
            <td class="name"><a href="#table.removevalue">table.removevalue</a>( t, value, maxRemoveCount )</td>
            <td class="summary">Remove the provided value from the provided table.</td>
        </tr>
    
        <tr>
            <td class="name"><a href="#table.reverse">table.reverse</a>( t )</td>
            <td class="summary">Reverse the order of the provided table's values.</td>
        </tr>
    
        <tr>
            <td class="name"><a href="#table.setvalue">table.setvalue</a>( t, keys, value )</td>
            <td class="summary">Safely set a value several levels down inside nested tables.</td>
        </tr>
    
        <tr>
            <td class="name"><a href="#table.shift">table.shift</a>( t, returnKey )</td>
            <td class="summary">Remove and returns the first value found in the table.</td>
        </tr>
    
        <tr>
            <td class="name"><a href="#table.sortby">table.sortby</a>( t, property, orderBy )</td>
            <td class="summary">Sort a list of table using one of the tables property as criteria.</td>
        </tr>
    
</table>

<dl class="function">
    
        
<dt><a name="math.isinteger"></a><h3>math.isinteger( number )</h3></dt>
<dd>
Tell whether the provided number is an integer. That include numbers that have one or several zeros as decimals (1.0, 2.000, ...).
<br><br>

    <strong>Parameters:</strong>
    <ul>
        
        <li>
          number (number) The number to check.
        </li>
        
    </ul>


    <strong>Return value:</strong>
    <ul>(boolean) True if the provided number is an integer, false otherwise.</ul>

</dd>
<hr>
    
        
<dt><a name="math.lerp"></a><h3>math.lerp( a, b, factor, easing )</h3></dt>
<dd>
Returns the value resulting of the linear interpolation between value a and b by the specified factor.
<br><br>

    <strong>Parameters:</strong>
    <ul>
        
        <li>
          a (number)
        </li>
        
        <li>
          b (number)
        </li>
        
        <li>
          factor (number) Should be between 0.0 and 1.0.
        </li>
        
        <li>
          easing (string) [optional] The easing of the factor, can be "smooth", "smooth in", "smooth out".
        </li>
        
    </ul>


    <strong>Return value:</strong>
    <ul>(number) The interpolated value.</ul>

</dd>
<hr>
    
        
<dt><a name="math.round"></a><h3>math.round( value, decimal )</h3></dt>
<dd>
Return the value rounded to the closest integer or decimal.
<br><br>

    <strong>Parameters:</strong>
    <ul>
        
        <li>
          value (number) The value.
        </li>
        
        <li>
          decimal (number) [default=0] The decimal at which to round the value.
        </li>
        
    </ul>


    <strong>Return value:</strong>
    <ul>(number) The new value.</ul>

</dd>
<hr>
    
        
<dt><a name="math.warpangle"></a><h3>math.warpangle( angle )</h3></dt>
<dd>
Wrap the provided angle between -180 and 180.
<br><br>

    <strong>Parameters:</strong>
    <ul>
        
        <li>
          angle (number) The angle.
        </li>
        
    </ul>


    <strong>Return value:</strong>
    <ul>(number) The angle.</ul>

</dd>
<hr>
    
        
<dt><a name="string.endswith"></a><h3>string.endswith( s, chunk )</h3></dt>
<dd>
Tell whether the provided string ends by the provided chunk or not.
<br><br>

    <strong>Parameters:</strong>
    <ul>
        
        <li>
          s (string) The string.
        </li>
        
        <li>
          chunk (string) The searched chunk.
        </li>
        
    </ul>


    <strong>Return value:</strong>
    <ul>(boolean) True or false.</ul>

</dd>
<hr>
    
        
<dt><a name="string.lcfirst"></a><h3>string.lcfirst( s )</h3></dt>
<dd>
Turn the first letter of the string lowercase.
<br><br>

    <strong>Parameters:</strong>
    <ul>
        
        <li>
          s (string) The string.
        </li>
        
    </ul>


    <strong>Return value:</strong>
    <ul>(string) The string.</ul>

</dd>
<hr>
    
        
<dt><a name="string.split"></a><h3>string.split( s, delimiter, delimiterIsPattern )</h3></dt>
<dd>
Split the provided string in several chunks, using the provided delimiter. The delimiter can be a pattern and can be several characters long. If the string does not contain the delimiter, a table containing only the whole string is returned.
<br><br>

    <strong>Parameters:</strong>
    <ul>
        
        <li>
          s (string) The string.
        </li>
        
        <li>
          delimiter (string) The delimiter.
        </li>
        
        <li>
          delimiterIsPattern (boolean) [default=false] Interpret the delimiter as pattern instead of as plain text. The function's behavior is not garanteed if true and in the webplayer.
        </li>
        
    </ul>


    <strong>Return value:</strong>
    <ul>(table) The chunks.</ul>

</dd>
<hr>
    
        
<dt><a name="string.startswith"></a><h3>string.startswith( s, chunk )</h3></dt>
<dd>
Tell whether the provided string begins by the provided chunk or not.
<br><br>

    <strong>Parameters:</strong>
    <ul>
        
        <li>
          s (string) The string.
        </li>
        
        <li>
          chunk (string) The searched chunk.
        </li>
        
    </ul>


    <strong>Return value:</strong>
    <ul>(boolean) True or false.</ul>

</dd>
<hr>
    
        
<dt><a name="string.totable"></a><h3>string.totable( s )</h3></dt>
<dd>
Turn a string into a table, one character per index.
<br><br>

    <strong>Parameters:</strong>
    <ul>
        
        <li>
          s (string) The string.
        </li>
        
    </ul>


    <strong>Return value:</strong>
    <ul>(table) The table.</ul>

</dd>
<hr>
    
        
<dt><a name="string.trim"></a><h3>string.trim( s )</h3></dt>
<dd>
Removes the white spaces at the beginning and the end of the provided string.
<br><br>

    <strong>Parameters:</strong>
    <ul>
        
        <li>
          s (string) The string.
        </li>
        
    </ul>


    <strong>Return value:</strong>
    <ul>(string) The trimmed string.</ul>

</dd>
<hr>
    
        
<dt><a name="string.trimend"></a><h3>string.trimend( s )</h3></dt>
<dd>
Removes the white spaces at the end of the provided string.
<br><br>

    <strong>Parameters:</strong>
    <ul>
        
        <li>
          s (string) The string.
        </li>
        
    </ul>


    <strong>Return value:</strong>
    <ul>(string) The trimmed string.</ul>

</dd>
<hr>
    
        
<dt><a name="string.trimstart"></a><h3>string.trimstart( s )</h3></dt>
<dd>
Removes the white spaces at the beginning of the provided string.
<br><br>

    <strong>Parameters:</strong>
    <ul>
        
        <li>
          s (string) The string.
        </li>
        
    </ul>


    <strong>Return value:</strong>
    <ul>(string) The trimmed string.</ul>

</dd>
<hr>
    
        
<dt><a name="string.ucfirst"></a><h3>string.ucfirst( s )</h3></dt>
<dd>
Turn the first letter of the string uppercase.
<br><br>

    <strong>Parameters:</strong>
    <ul>
        
        <li>
          s (string) The string.
        </li>
        
    </ul>


    <strong>Return value:</strong>
    <ul>(string) The string.</ul>

</dd>
<hr>
    
        
<dt><a name="table.combine"></a><h3>table.combine( keys, values )</h3></dt>
<dd>
Create an associative table with the provided keys and values tables.
<br><br>

    <strong>Parameters:</strong>
    <ul>
        
        <li>
          keys (table) The keys of the future table.
        </li>
        
        <li>
          values (table) The values of the future table.
        </li>
        
    </ul>


    <strong>Return value:</strong>
    <ul>(table or boolean) The combined table or false if the tables have different length.</ul>

</dd>
<hr>
    
        
<dt><a name="table.containsvalue"></a><h3>table.containsvalue( t, value, ignoreCase )</h3></dt>
<dd>
Tell whether the provided value is found within the provided table.
<br><br>

    <strong>Parameters:</strong>
    <ul>
        
        <li>
          t (table) The table to search in.
        </li>
        
        <li>
          value (mixed) The value to search for.
        </li>
        
        <li>
          ignoreCase (boolean) [default=false] Ignore the case of the value. If true, the value must be of type 'string'.
        </li>
        
    </ul>


    <strong>Return value:</strong>
    <ul>(boolean) True if the value is found in the table, false otherwise.</ul>

</dd>
<hr>
    
        
<dt><a name="table.copy"></a><h3>table.copy( t, recursive )</h3></dt>
<dd>
Return a copy of the provided table.
<br><br>

    <strong>Parameters:</strong>
    <ul>
        
        <li>
          t (table) The table to copy.
        </li>
        
        <li>
          recursive (boolean) [default=false] Tell whether to also copy the tables found as value (true), or just leave the same table as value (false).
        </li>
        
    </ul>


    <strong>Return value:</strong>
    <ul>(table) The copied table.</ul>

</dd>
<hr>
    
        
<dt><a name="table.getkey"></a><h3>table.getkey( t, value )</h3></dt>
<dd>
Get the key associated with the first occurrence of the provided value.
<br><br>

    <strong>Parameters:</strong>
    <ul>
        
        <li>
          t (table) The table.
        </li>
        
        <li>
          value (mixed) The value.
        </li>
        
    </ul>


    <strong>Return value:</strong>
    <ul>(mixed) The value's key or nil if the value is not found.</ul>

</dd>
<hr>
    
        
<dt><a name="table.getkeys"></a><h3>table.getkeys( t )</h3></dt>
<dd>
Return all the keys of the provided table.
<br><br>

    <strong>Parameters:</strong>
    <ul>
        
        <li>
          t (table) The table.
        </li>
        
    </ul>


    <strong>Return value:</strong>
    <ul>(table) The keys.</ul>

</dd>
<hr>
    
        
<dt><a name="table.getlength"></a><h3>table.getlength( t, keyType )</h3></dt>
<dd>
Returns the length of a table, which is the numbers of keys of the provided type (or of any type), for which the value is not nil.
<br><br>

    <strong>Parameters:</strong>
    <ul>
        
        <li>
          t (table) The table.
        </li>
        
        <li>
          keyType (string) [optional] Any Lua or CraftStudio type ('string', 'GameObject', ...), case insensitive.
        </li>
        
    </ul>


    <strong>Return value:</strong>
    <ul>(number) The table length.</ul>

</dd>
<hr>
    
        
<dt><a name="table.getvalue"></a><h3>table.getvalue( t, keys )</h3></dt>
<dd>
Safely search several levels down inside nested tables. Just returns nil if the series of keys does not leads to a value. <br> Can also be used to check if a global variable exists if the table is _G. <br> Ie for this series of nested table : table1.table2.table3.fooBar <br> table.getvalue( table1, "table2.table3.fooBar" ) would return the value of the 'fooBar' key in the 'table3' table <br> table.getvalue( table1, "table2.table3" ) would return the value of 'table3' <br> table.getvalue( table1, "table2.table3.Foo" ) would return nul because the 'table3' has no 'Foo' key <br> table.getvalue( table1, "table2.Foo.Bar.Lorem.Ipsum" ) idem <br>
<br><br>

    <strong>Parameters:</strong>
    <ul>
        
        <li>
          t (table) The table.
        </li>
        
        <li>
          keys (string) The chain of keys to looks for as a string, each keys separated by a dot.
        </li>
        
    </ul>


    <strong>Return value:</strong>
    <ul>(mixed) The value, or nil.</ul>

</dd>
<hr>
    
        
<dt><a name="table.getvalues"></a><h3>table.getvalues( t )</h3></dt>
<dd>
Return all the values of the provided table.
<br><br>

    <strong>Parameters:</strong>
    <ul>
        
        <li>
          t (table) The table.
        </li>
        
    </ul>


    <strong>Return value:</strong>
    <ul>(table) The values.</ul>

</dd>
<hr>
    
        
<dt><a name="table.havesamecontent"></a><h3>table.havesamecontent( table1, table2 )</h3></dt>
<dd>
Compare table1 and table2. Returns true if they have the exact same keys which have the exact same values.
<br><br>

    <strong>Parameters:</strong>
    <ul>
        
        <li>
          table1 (table) The first table to compare.
        </li>
        
        <li>
          table2 (table) The second table to compare to the first table.
        </li>
        
    </ul>


    <strong>Return value:</strong>
    <ul>(boolean) True if the two tables have the exact same content.</ul>

</dd>
<hr>
    
        
<dt><a name="table.isarray"></a><h3>table.isarray( t, strict )</h3></dt>
<dd>
Tell whether he provided table is an array (has only integer keys). Decimal numbers with only zeros after the coma are considered as integers.
<br><br>

    <strong>Parameters:</strong>
    <ul>
        
        <li>
          t (table) The table.
        </li>
        
        <li>
          strict (boolean) [default=true] When false, the function returns true when the table only has integer keys. When true, the function returns true when the table only has integer keys in a single and continuous set.
        </li>
        
    </ul>


    <strong>Return value:</strong>
    <ul>(boolean) True or false.</ul>

</dd>
<hr>
    
        
<dt><a name="table.merge"></a><h3>table.merge( ..., recursive )</h3></dt>
<dd>
Merge two or more tables into one new table. Table as values with a metatable are considered as instances and are not recursively merged. When the tables are arrays, the integer keys are not overridden.
<br><br>

    <strong>Parameters:</strong>
    <ul>
        
        <li>
          ... (table) Two or more tables
        </li>
        
        <li>
          recursive (boolean) [default=false] Tell whether tables as values must be merged recursively. Has no effect when the tables are arrays.
        </li>
        
    </ul>


    <strong>Return value:</strong>
    <ul>(table) The new table.</ul>

</dd>
<hr>
    
        
<dt><a name="table.mergein"></a><h3>table.mergein( ..., recursive )</h3></dt>
<dd>
Merge two or more tables in place, into the first provided table. Table as values with a metatable are considered as instances and are not recursively merged. When the tables are arrays, the integer keys are not overridden.
<br><br>

    <strong>Parameters:</strong>
    <ul>
        
        <li>
          ... (table) Two or more tables
        </li>
        
        <li>
          recursive (boolean) [default=false] Tell whether tables as values must be merged recursively. Has no effect when the tables are arrays.
        </li>
        
    </ul>


    <strong>Return value:</strong>
    <ul>(table) The first provided table.</ul>

</dd>
<hr>
    
        
<dt><a name="table.print"></a><h3>table.print( t )</h3></dt>
<dd>
Print all key/value pairs within the provided table.
<br><br>

    <strong>Parameters:</strong>
    <ul>
        
        <li>
          t (table) The table to print.
        </li>
        
    </ul>


</dd>
<hr>
    
        
<dt><a name="table.reindex"></a><h3>table.reindex( t )</h3></dt>
<dd>
Turn the provided table (with only integer keys) in a proper sequence (with consecutive integer key beginning at 1).
<br><br>

    <strong>Parameters:</strong>
    <ul>
        
        <li>
          t (table) The table.
        </li>
        
    </ul>


    <strong>Return value:</strong>
    <ul>(table) The sequence.</ul>

</dd>
<hr>
    
        
<dt><a name="table.removevalue"></a><h3>table.removevalue( t, value, maxRemoveCount )</h3></dt>
<dd>
Remove the provided value from the provided table. If the index of the value is an integer, the value is nicely removed with table.remove(). /!\ Do not use this function on tables which have integer keys but that are not arrays (whose keys are not contiguous). /!\
<br><br>

    <strong>Parameters:</strong>
    <ul>
        
        <li>
          t (table) The table.
        </li>
        
        <li>
          value (mixed) The value to remove.
        </li>
        
        <li>
          maxRemoveCount (number) [optional] Maximum number of occurrences of the value to be removed. If nil : remove all occurrences.
        </li>
        
    </ul>


    <strong>Return value:</strong>
    <ul>(number) The number of occurrence removed.</ul>

</dd>
<hr>
    
        
<dt><a name="table.reverse"></a><h3>table.reverse( t )</h3></dt>
<dd>
Reverse the order of the provided table's values.
<br><br>

    <strong>Parameters:</strong>
    <ul>
        
        <li>
          t (table) The table.
        </li>
        
    </ul>


    <strong>Return value:</strong>
    <ul>(table) The new table.</ul>

</dd>
<hr>
    
        
<dt><a name="table.setvalue"></a><h3>table.setvalue( t, keys, value )</h3></dt>
<dd>
Safely set a value several levels down inside nested tables. Creates the missing levels if the series of keys is incomplete. <br> Ie for this series of nested table : table1.table2.fooBar <br> table.setvalue( table1, "table2.fooBar", true ) would set true as the value of the 'fooBar' key in the 'table1.table2' table. if table2 does not exists, it is created <br>
<br><br>

    <strong>Parameters:</strong>
    <ul>
        
        <li>
          t (table) The table.
        </li>
        
        <li>
          keys (string) The chain of keys to looks for as a string, each keys separated by a dot.
        </li>
        
        <li>
          value (mixed) The value (nil is ok).
        </li>
        
    </ul>


</dd>
<hr>
    
        
<dt><a name="table.shift"></a><h3>table.shift( t, returnKey )</h3></dt>
<dd>
Remove and returns the first value found in the table. Works for arrays as well as associative tables.
<br><br>

    <strong>Parameters:</strong>
    <ul>
        
        <li>
          t (table) The table.
        </li>
        
        <li>
          returnKey (boolean) [default=false] If true, return the key and the value instead of just the value.
        </li>
        
    </ul>


    <strong>Return value:</strong>
    <ul>(mixed) The value, or the key and the value (if the returnKey argument is true), or nil.</ul>

</dd>
<hr>
    
        
<dt><a name="table.sortby"></a><h3>table.sortby( t, property, orderBy )</h3></dt>
<dd>
Sort a list of table using one of the tables property as criteria.
<br><br>

    <strong>Parameters:</strong>
    <ul>
        
        <li>
          t (table) The table.
        </li>
        
        <li>
          property (string) The property used as criteria to sort the table.
        </li>
        
        <li>
          orderBy (string) [default="asc"] How the sort should be made. Can be "asc" or "desc". Asc means small values first.
        </li>
        
    </ul>


    <strong>Return value:</strong>
    <ul>(table) The ordered table.</ul>

</dd>
<hr>
    
</dl>

