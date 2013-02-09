


Daneel.config = table.new({

    hudCameraName = "HUD Camera",
    hudCameraGo = nil, -- set in DaneelBehavior.Start()
    hudCameraOrthographicScale = "10",
    guiLabelMapName = "Daneel/GUILabelMap",

    --charactersModelPath = "Daneel/Characters",

    

    componentTypes = table.new({
        "ScriptedBehavior",
        "ModelRenderer",
        "MapRenderer",
        "Camera",
        "Transform"
    }),

    componentObjects = table.new({
        ScriptedBehavior,
        ModelRenderer,
        MapRenderer,
        Camera,
        Transform,
    }),


    assetTypes = table.new({
        "Script",
        "Model",
        "ModelAnimation",
        "Map",
        "TileSet",
        "Scene",
        "Sound",
        "Document"
    }),

    assetObjects = table.new({
        Script,
        Model,
        ModelAnimation,
        Map,
        TileSet,
        Sound,
        Scene,
    }),

    -- Correspondance between the component type (the keys) and the asset type (the values)
    componentTypeToAssetType = table.new({
        ScriptedBehavior = "Script",
        ModelRenderer = "Model",
        MapRenderer = "Map",
    }),


    craftStudioCoreTypes = table.new({
        "GameObject",
        "Vector3",
        "Ray",
        "Plane",
        "Quaternion",
    }),

    craftStudioCoreObjects = table.new({
        GameObject,
        Vector3,
        Quaternion,
        Plane,
        Ray,
    }),
    

    daneelTypes = table.new({
        "GUILabel",
    }),

    daneelObjects = table.new({
        GUILabel,
    }),
    
})



