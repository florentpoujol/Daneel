# Setup

- [Installation](#installation)
- [Loading](#loading)
- [Configuration](#configuration)
- [How to update](#update)


<a name="installation"></a>
## Installation 

[Get Daneel on GitHub](https://github.com/florentpoujol/Daneel).

Copy and paste the `build/Daneel.lua` (or its minified version) in a script at the top of the script's hierarchy.  

Be advised that upon pasting the script's content, __CraftStudio will freeze for several dozens of seconds__.  
Don't worry, this is expected due to the big size of the script. CraftStudio will unfreeze on its own.

You can also get some scripted behaviors helpers in the `src/scripted behaviors` folder that allows you to adds features or components while working in the scene editor.

### Using Daneel in the Web Player

If your project is targeted for the webplayer, you need to use the provided `webplayer/player.html` file instead of the one created when you export your game.


<a name="loading"></a>
## Loading

Loading Daneel means adding the `Daneel` script as a scripted behavior on a game object at the top of the hierarchy in every of your "main" scenes, the ones that are meant to be levels or menus for instance (a scene that you would load with `CS.LoadScene()`, not the scenes meant to be instantiated several times or inside other scenes).  

![Loading Daneel](img/loading_daneel.jpg)

<a name="configuration"></a>
## Configuration

Daneel and some [modules](modules) expose configuration properties. User configuration may be set by setting up a `Daneel.UserConfig()` function  that returns a table.

Any existing key/value pairs in the user configuration overrides (or completes) the default value that can be found in `Daneel.DefaultConfig()`.  
At runtime, the configuration can be found in the `Daneel.Config` tables.

Ie :

    function Daneel.UserConfig()
        return {
            debug = {
                enableDebug = true, -- override the default value for that conf key
                -- enabledStackTrace is not set in the user config, so its value will stay at its default (false)
            },
        }
    end


<a name="update"></a>
## How to update

__DO NOT delete a script used as scripted behavior__ because you would loose the connection between the script and the game objects. You would then need to re-add the behavior and re-configure its properties on all game objects it was added on.  

Your only choice to update a scripted behavior is to replace the old code by copy/pasting the new one. You also need to change the properties manually (if they have changed).

Note that all scripts in v1.5.0 are scripted behaviors.

### From v1.4.0

In v1.4.0, the script that _are not_ scripted behaviors are : `Lua`, `CraftStudio`, `Tween`, `GUI` and `Draw`.  
You can safely delete these scripts as they are now all included in the sole `Daneel` script.

Now you have to manually update the remaining scripts : `Daneel`, `Tags`, `MouseInput`, `Trigger`, `Lang` and the GUI component's scripted behaviors.
