
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

    components = {
        ScriptedBehavior = ScriptedBehavior,
        ModelRenderer = ModelRenderer,
        MapRenderer = MapRenderer,
        Camera = Camera,
        Transform = Transform,
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

-- called from Daneel.Awake()
function Daneel.defaultConfig.Init()
    Daneel.config = table.new(Daneel.config)
    setmetatable(Daneel.config, Daneel.defaultConfig)

   
    -- allow dynamic getters on Daneel.defaultConfig
    function Daneel.defaultConfig.__index(t, key)
        local funcName = "Get"..key:ucfirst()
        
        if Daneel.defaultConfig[funcName] ~= nil then
            return Daneel.defaultConfig[funcName](t)
        elseif Daneel.defaultConfig[key] ~= nil then
            return Daneel.defaultConfig[key] -- have to return the function here, not the function return value !
        end
        
        return rawget(t, key)
    end


    -- assetTypes, assetObjects
    Daneel.defaultConfig.assetTypes = table.getkeys(Daneel.defaultConfig.assets)
    Daneel.defaultConfig.assetObjects = table.getvalues(Daneel.defaultConfig.assets)
    Daneel.defaultConfig.componentTypes = table.getkeys(Daneel.defaultConfig.components)
    Daneel.defaultConfig.componentObjects = table.getvalues(Daneel.defaultConfig.components)

end


