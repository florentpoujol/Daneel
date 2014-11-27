# Setup

- [Installation](#installation)
- [Loading](#loading)
- [Configuration](#configuration)
- [How to update](#update)


<a name="installation"></a>
## Installation 

[Download Daneel's package](/download/Daneel_v1.4.0.zip) 

Extract the `.cspack` then import in your project the `Daneel` script and whatever other scripts you may need.  
Except for the `Daneel` script, they are all optionnal. They are scripted behaviors used to add features to game objects while in the scene editor. 

A folder `Daneel v1.5.0` must have been created in the list of scripts assets. Make sure that the folder is at the top of the list.

You can also add the template project to your server.  
Put the file `Daneel v1.5.0 Template.zip` (inside the `.zip` you just downloaded) in `CraftStudio/CraftStudioServer/Templates` (do not unzip the content).  
Whenever you create a new project, you can now select `Daneel v1.5.0` from the project template dropdown list.   
The template will add all the scripts as well as five game controls `"LeftMouse"`, `"RightMouse"`, `"WheelUp"`, `"WheelDown"` and `"ValidateInput"`.

### Using Daneel in the Web Player

If your project is targeted for the webplayer, you need to use the provided `player.html` file instead of the one created when you export your game.

The `Daneel.min` script that you may find in Daneel's `.cspack` is a minified version of Daneel's main script.  
It makes the game load and run slightly faster and is required if you want your game to load in the webplayer (the non minified version is too big, it just doesn't load in the webplayer).

<a name="loading"></a>
## Loading

Loading Daneel means adding the `Daneel` script as a scripted behavior on a game object at the top of the hierarchy in every of your "main" scenes, the ones that are meant to be levels or menus for instance (a scene that you would load with `CS.LoadScene()`, not the scenes meant to be instantiated several times or inside other scenes).  

![Loading Daneel](img/loading_daneel.jpg)

<a name="configuration"></a>
## Configuration

Daneel and some [modules](/docs/modules) expose configuration properties. User configuration may be set by setting up a `Daneel.UserConfig()` function  that returns a table.

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

The script used as scripted behavior are : `Daneel` (or `DaneelComplete`), `Mouse Input`, `Trigger`, `Lang`, `Tweener`, `Timer`, plus all components scripted behavior : `Hud`, `ProgressBar`, `LineRenderer` ... 

You can safely delete the scripts that are not scripted behaviors and replace them by the new version imported from a `.cspack`.

[Read the changelog](changelog) to have an overview of what's new and what has changed.

### From v1.4.0

New file : `Color`

### From v1.3.0

New files: `Lua`, `CraftStudio`, `Draw`, `LineRenderer`, `CircleRenderer`.  
Modified files : `Daneel`, `Mouse Input`, `Trigger`, `Lang`, `GUI`, `Hud`, `Tween` ( /!\ except for `GUI` and `Tween`, they are all scripted behaviors, __do not delete them__ !).

Make sure that the folder all the scripts are in is at the top of the script's hierarchy and that the two top-most scripts are `Lua`, then `Daneel`. If you have the `CraftStudio` script, it should be just below `Daneel`. See the image at the top of the page.

Rename your user config global functions (if you did set up some of them) from `Daneel.UserConfig()` or `[Module].UserConfig()` to `Daneel.UserConfig()` and `[ModuleObject].UserConfig()` (add a dot between the object name and `UserConfig`).

Finally, rename the `updateInterval` property of the `Mouse Input` script to `OnMouseOverInterval`.


