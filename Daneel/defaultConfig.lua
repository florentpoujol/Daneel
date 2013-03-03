
if Daneel == nil then
    Daneel = {}
end

Daneel.defaultConfig = {

    hudCameraName = "HUD Camera",
    hudCameraGo = nil, -- set in DaneelBehavior.Start()
    hudCameraOrthographicScale = "10",
    guiLabelMapName = "Daneel/GUILabelMap",

    --charactersModelPath = "Daneel/Characters",


    -- StackTrace
    stackTraceLength = 10,
    

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

    components = {
        ScriptedBehavior = ScriptedBehavior,
        ModelRenderer = ModelRenderer,
        MapRenderer = MapRenderer,
        Camera = Camera,
        Transform = Transform,
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
        Document
    },

    assets = {
        Script = Script,
        Model = Model,
        ModelAnimation = ModelAnimation,
        Map = Map,
        TileSet = TileSet,
        Sound = Sound,
        Scene = Scene,
        Document = Document
    },

    -- Correspondance between the component type (the keys) and the asset type (the values)
    componentTypeToAssetType = {
        ScriptedBehavior = "Script",
        ModelRenderer = "Model",
        MapRenderer = "Map",
    },


    craftStudioCoreTypes = {
        "GameObject",
        "Vector3",
        "Ray",
        "Plane",
        "Quaternion",
    },

    craftStudioCoreObjects = {
        GameObject,
        Vector3,
        Quaternion,
        Plane,
        Ray,
    },
    

    daneelTypes = {
        "GUILabel",
    },

    daneelObjects = {
        GUILabel,
    },
    
}
