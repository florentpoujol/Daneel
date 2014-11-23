# Changelog

## v1.5.0

- Daneel :

    - Renamed `Daneel.functionsDebugInfo` object into `Daneel.Debug.functionArgumentsInfo`.
    - Added possibility to check for an argument's value via the `value` properties in function arguments info. 
    - Allowed arguments with default value to have multiple expected type in function arguments info.
    - Deprecated `Daneel.Utilities.ToNumber()` in favor of `tonumber2()` (in `Lua` file).
    - Deprecated `Daneel.Utilities.CaseProof()` in favor of `string.fixcase()` (in `Lua` file).
    - Deprecated `Daneel.Cache` object, renamed `Daneel.Cache.GetId()` in `Daneel.Utilities.GetId()`.
    - Removed notion of script aliases.
    - Removed hotkeys events.
    - Added `Daneel.Event.AddEventListener()`, `GameObject.AddEventListener()`, `Daneel.Event.RemoveEventListener()`, `GameObject.RemoveEventListener()` and `GameObject.FireEvent()`.
    - Remove possibility to change the name of the message sent when a event is fired at a game object.
- Extension of Lua's built-in libraries :
    - Added `tonumber2()` (replace `Daneel.Utilities.ToNumber()`).
    - Added `math.clamp()`.
    - Added `string.fixcase()` (replace `Daneel.Utilities.CaseProof()`).
    - Added `table.insertonce()`.
    - Added `table.rprint()`.
    - Fixed `table.sortby()` when several entries had the same value.
- Extension of CraftStudio's API :
    - Added `Camera.GetPixelsToUnits()`, `Camera.GetUnitsToPixels()`, `Camera.GetBaseDistance()`, `Camera.IsPositionInFrustum()`, `Camera.WorldToScreenPoint()`, `Camera.Project()`, `Camera.GetFOV()`, `Camera.GetFov()` and `Camera.SetFov()`. `Camera.GetFOV()` rounds the returned value at two digits after the coma.
    - Added `GameObject.GetInAncestors()`.
    - Added `Vector3.GetLength()`, `Vector3.GetSqrLength()`, `Vector3.ToString()` and `Vector3.New()` which accepts a `Vector3` or `Vector2` as first argument.
    - Allowed `Vector3.__tostring()` to round the vector's components' values following the value of the `Vector3.tostringRoundValue` property (default is 3 digits after the coma).
    - Added `string.tovector()`.
    - Added `Transform.WorldToLocal()` and `Transform.LocalToWorld()`.
    - Added `MapRenderer.LoadNewMap()`.
    - Allowed `Map.GetBlockIDAt()`, `Map.GetBlockOrientationAt()` and `Map.SetBlockAt()` to have the location provided as a Vector3.
    - Moved `Vector2` object, `CS.Input.GetMousePosition()`, `CS.Input.GetMouseDelta()` and `CS.Screen.GetSize()` from `GUI` to `CraftStudio` file.
    - Updated `Vector2.New()` to accepts a regular table as first argument.
    - Renamed raycastHit's `hitLocation` property to `hitPosition` (`hitLocation` can still be accessed).
    - Added `GameObject.Display()`.
    - Updated `CS.Screen.GetSize()` to set the `CS.Screen.aspectRatio` property.
    - Allowed `CS.Screen.SetSize()` to receive a table as first argument and sets the new aspect ratio in the `CS.Screen.aspectRatio` property. 
- GUI module:
    - Added `GUI.Hud.CreateOriginGO()`.
    - Added `GUI.TextArea.AddLine()`.
    - Allowed to filter the text's lines before a textArea component is rendered by a function as the value of the `linesFilter` property.
    - Allowed the `areaWidth` argument of `GUI.TextArea.SetAreaWidth()` to be `nil`.
    - Updated `GUI.TextArea.SetText()` to cut lines on a space character, instead of in the middle of words.
    - Renamed `GUI.Hud.ToPixel()` in `GUI.ToPixel()`. `GUI.ToPixel()` and `GUI.ToSceneUnit()` now accept a camera component or game object as second argument.
    - Moved `Vector2` object, `CS.Input.GetMousePosition()`, `CS.Input.GetMouseDelta()` and `CS.Screen.GetSize()` from `GUI` to `CraftStudio` file. 
- Tween module:
    - Added `GameObject.Animate()` and `GameObject.AnimateAndDestroy()`.
    - Updated `Tween.Tweener.New()` to accept an optional `onCompleteCallback` argument.
    - Updated `Tween.Tweener.New()` to allow the `startValue` argument to be of type `string`, `Vector2` or `Vector3` (in addition to `number`).
    - Allowed tweeners to work with text values and text renderers (to create the one-letter-at-a-time effect).
- Draw module:
    - Added `CircleRenderer.Get/SetOpacity()`.
- Added the color module.
- Other fixes and improvements.


## v1.4.0

- Daneel :
    - Added `Daneel.Debug.RegisterFunction()`. Debug information about function arguments can now be set in a `Daneel.functionsDebugInfo` table to automatically setup stack trace and error reporting.
    - Daneel and modules user config is now set via a `UserConfig` key on the module object instead of via a global function `ModuleNameUserConfig()`.
- Extension of Lua's built-in libraries :
    - Moved functions in a separate `Lua` script.
    - Added `table.setvalue()`.
    - Added `table.mergein()` which merge two or more tables in place, into the first provided table (whereas `table.merge()` returns a new table).
    - `table.deepmerge()` is deprecated in favor of `table.mergein()` or `table.merge()` with the last argument set to true.
- Extension of CraftStudio's API :
    - Moved functions and features in a separate `CraftStudio` script.
    - Added `CS.Input.isMouseLocked` property and `CS.Input.ToggleMouseLock()` function.
- Mouse Input :
    - Added `OnWheelUp` and `OnWheelDown` events.
    - Renamed `updateInterval` property in `OnMouseOverInterval`.
    - Improved the efficiency of the script.
- Trigger :
    - Triggers now react properly when both the trigger and the game object have a model or a map. You can do proper model-to-model "collision" when the model's shapes are simples.
- Draw :
    - Added `Draw` module with the `LineRenderer` and `CircleRenderer` components.
- Various fixes/improvements.
- Added project template to the downloaded package.
- New documentation layout and system.
- Easier web player deployment.


## v1.3.0

- Core :
    - Merged files `Daneel`, `CraftStudio`, `GameObject`, `Lua` and `DaneelBehavior` into the single file `Daneel`.
    - Added `Daneel.Utilities.ButtonExists()`, `Daneel.Debug.Try()`, `Daneel.Cache.GetId()`, `Daneel.Storage.Save()` and `Daneel.Storage.Load()`.
    - Removed `Daneel.Utilities.GetValueFromName()`, `Daneel.Utilities.GlobalExists()` (they are replaced by `table.getvalue()`).
    - Added persistent listeners, replaced `Daneel.Event.Clear()` by `Daneel.Event.StopListen()` called without the event name argument. Removed scheduled events : `Daneel.Event.FireAtRealTime()`, `FireAtTime()` and `FireAtFrame()`
    - Hotkeys now work without setting anything in the config, just listen to the events.
- Extension of Lua's built-in libraries :
    - Added `math.lerp()`, `math.warpangles()`, `math.round()`, `table.getvalue()`, `table.isarray()`, `table.reverse()`, `table.shift()` and `table.reindex()`.
    - Updated `string.split()` so that it can use a Lua pattern as delimiter. The third argument has changed : it now tells if the delimiter must be considered as a pattern or plain text (the default).
    - Renamed `table.length()` in `table.getlength()`, `table.compare()` in `table.havesamecontent()`.
    - Removed `string.isoneof()` and `table.new()`.
- Extension of CraftStudio's API :
    - Added `Asset.GetName()`, `Asset.GetId()`.
    - Added `ModelRenderer.Set()`, `MapRenderer.Set()`, `Camera.Set()`, `Camera.SetProjectionMode()`
    - Updated some asset setters to accept `nil` as argument : `SetModel()`, `SetModelAnimation()`, `SetMap()`, `SetFont()`.
    - Allowed `ray:IntersectsModelRenderer()`, `ray:IntersectsMapRenderer()`, `ray:IntersectsTextRenderer()` and `ray:IntersectsPlane()` to return a `RaycastHit` instead of a serie of values if the third argument is true.
    - `Scene.Load()` or `CS.LoadScene()` now set the current scene asset as the value of the `Scene.current` property.
    - Game objects :
        - Updated `GameObject.New()` to also do the work of `GameObject.NewFromScene()` which has been removed.
        - `gameObject:SendMessage()` now fails gracefully if an error happens inside the function called and displays info about the game object, message name and data passed as argument.
        - Updated `gameObject:AddComponent()` to also do the work of `gameObject:AddScriptedBehavior()` which has been removed.
        - Added `gameObject:GetTags()`.
- Triggers :
    - Added `Trigger:IsGameObjectInRange()`, removed arguments to `Trigger:GetGameObjectsInRange()` and renamed the `checkInterval` property in `updateInterval`.
    - Triggers may now use the shape of a model or a map in addition to the distance-based sphere. 
- Mouse Input :
    - Renamed `MouseInputs` script in `Mouse Input`. Renamed the `workInterval` property in `updateInterval`.
- Lang : 
    - The `Lang` object is now a first-level global variable (`Daneel.Lang` doesn't work any more).
    - Moved `Lang` object into its own script that can also be used as a scripted behavior. Language functions must now be named `Lang[language name]()`. 
- Tween :
    - The `Tween` object is now a first-level global variable (`Daneel.Tween` doesn't work any more).
    - Added the `updateInterval` property for tweeners. 
    - Added the `Tweener` and `Timer` scripted behaviors.
- GUI :
    - The `GUI` object is now a first-level global variable (`Daneel.GUI` doesn't work any more).
    - Added `Vector2.GetLength()` and `Vector2.GetSqrLength()`
    - Added `GUI.ToSceneUnit()`, `GUI.Hud.ToPixels()`, `GUI.Hud.FixPosition()`.
    - Allowed position of `GUI.Hud` to be set in percentage or relative to the screen sides size.
    - `GUI.Sliders` now position themselves vis-à-vis of their parent game object. `GUI.Sliders` and `GUI.Toggle` don't require their scripted behavior to work properly any more.
    - `GUI.Input` may now be focused via a background model and have a cursor.
    - Renamed `GUI.ProgressBar.*Progress()` functions and the `progress` property in `SetValue()`, `UpdateValue()`, `GetValue()` and the `value` property. 
- Introduced the notion of Core vs Modules and separate user configuration for the core and each module : `DaneelUserConfig()` and `[Module name]UserConfig()`.
- Fixed many bugs, improved a lot of code and ensured that Daneel fully works in the webplayer.


## v1.2.0

- Added `Tween` object (tweeners, timers)
- Added `GUI` object (`Hud`, `Toggle`, `ProgressBar`, `Slider`, `Input`, `TextArea` components and corresponding scripted behaviors) and `Vector2` object
- Added `Time` object
- Added `Lang` object (localization capablities)
- Added `Cache` object
- Added `Event.Clear()` and scheduled events : `Event.FireAtRealTime()`, `Event.FireAtTime()`, `Event.FireAtFrame()`
- Added `Utilities.ReplaceInString()`, `Utilities.AllowDynamicGettersAndSetters()`, `Utilities.GetValueFromName()`, `Utilities.GlobalExists()`, `Utilities.ToNumber()`
- Added `Debug.GetNameFromValue()`, `Debug.Disable()`, `Debug.CheckArgValue()`
- Added `string.lcfirst()`, `string.split()`, `string.startswith()`, `string.endswith()`, `string.trimstart()`, `string.trimend()`, `string.trim()`, `table.deepmerge()`, `table.sortby()`
- Added `GameObject.NewFromScene()`, `GameObject.GetWithTag()`, `gameObject:AddTag()`, `gameObject:RemoveTag()`, `gameObject:HasTag()`, `gameObject:GetId()` and `component:GetId()`
- Added support for `Font` asset as well as `Physics`, `TextRenderer` and `NetworkSync` components 
- Added option for `ray:Cast()` to sort the `RaycastHit`s by distance, added support for `TextRenderer` in `ray:IntersectsGameObject()` and removed notion of 'castable gameObject'
- Added `transform:SetScale()` and `transform:GetScale()`
- Added `textRenderer:SetTextWidth()`
- Added `Asset.GetPath()`

---

- Updated triggers to use tags
- Updated `CS.Screen.GetSize()`, `CS.Input.GetMousePosition()`, `CS.Input.GetMouseDelta()` to return a Vector2 instance
- Updated how the config is handled
- Updated how scripted behaviors are added to game objects with `gameObject:Set()`
- Updated `Debug.CheckOptionalArgType()` to return the argument's value or a default value
- Updated `textRenderer:SetFont()` to also accept the Font asset name as argument (in addition of the asset object), `textRenderer:SetAlignment()` to also accept the alignment as a case-insensitive string (in addition of an entry in the `TextRenderer.Alignment` enum)
- Updated `gameObject:SetParent()` to allow nil as argument, `GameObject.Get()` and `gameObject:GetChild()` to search for nested objects

---

- Removed `GameObject.AddComponent()` helpers (`AddModelRenderer()`, ...), `GameObject.GetComponent()` helpers (`GetModelRenderer()`, ...), `GameObject.SetComponent()` and `GameObject.SetScriptedBehavior()`
- Removed `Asset.Get()` helpers (`AddModel()`, ...)


## v1.1.0

- Separated the user config from the "Daneel" script
- Dynamic getters and setters works on assets too
- Daneel.Debug.GetType() may now also return user-defined types
- The error() function now prints the StackTrace, unless told otherwise (Daneel.Debug.PrintError() is removed)
- Default function names when registering a game object to an event are not prefixed by "On" anymore
- Fixed various bugs
