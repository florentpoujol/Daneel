# Mass-setting

The `Set(params)` function that you may call on game objects, components and [tweeners](tween) accept a `params` argument of type table which allow to set variables or call setters in mass.  
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
