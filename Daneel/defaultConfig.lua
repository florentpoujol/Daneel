
if Daneel == nil then
    Daneel = {}
end

Daneel.defaultConfig = {

    -- StackTrace
    stackTraceLength = 10,
    
    assetOjects = {
        Script = Script,
        Model = Model,
        ModelAnimation = ModelAnimation,
        Map = Map,
        TileSet = TileSet,
        Sound = Sound,
        Scene = Scene,
        Document = Document
    },
    
    componentObjects = {
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
    
    craftStudioObjects = {
        GameObject = GameObject,
        Vector3 = Vector3,
        Quaternion = Quaternion,
        Plane = Plane,
        Ray = Ray,
    },
    
    daneelObjects = {
        GUILabel = GUILabel,
        RaycastHit = RayCastHit,
    },
    

    -- Triggers
    triggerableGameObjects = {},


    -- Input
    input = {
        buttons = {}
    }
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
    Daneel.defaultConfig.assetTypes = table.getkeys(Daneel.defaultConfig.assetObjects)
    --Daneel.defaultConfig.assetObjects = table.getvalues(Daneel.defaultConfig.assets)
    Daneel.defaultConfig.componentTypes = table.getkeys(Daneel.defaultConfig.componentObjects)
    --Daneel.defaultConfig.componentObjects = table.getvalues(Daneel.defaultConfig.components)

end


