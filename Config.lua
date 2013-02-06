


Daneel.config = table.new({

    hudCameraName = "HUD Camera",
    hudCameraOrthographicScale = "10",
    guiTextMapName = "Daneel/GUITextMap",

    charactersModelPath = "Daneel/Characters",

    

    componentTypes = {
        "ScriptedBehavior",
        "ModelRenderer",
        "MapRenderer",
        "Camera",
        "Transform"
    },

    componentObjects = {
        ScriptedBehavior,
        ModelRenderer,
        MapRenderer,
        Camera,
        Transform,
    },

    assetTypes = {
        "Script",
        "Model",
        "ModelAnimation",
        "Map",
        "TileSet",
        "Scene",
        "Sound",
        "Document"
    },

    assetObjects = {
        Script,
        Model,
        ModelAnimation,
        Map,
        TileSet,
        Sound,
        Scene,
    },

    -- Correspondance between the component type (the keys) and the asset type (the values)
    componentTypeToAssetType = {
        Script = "Script",
        ScriptedBehavior = "Script",
        ModelRenderer = "Model",
        MapRenderer = "Map",
    }
})



