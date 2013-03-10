
if Daneel == nil then
    Daneel = {}
end

Daneel.defaultConfig = {

    -- Objects (keys = name, value = object)
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
    
    craftStudioObjects = {
        GameObject = GameObject,
        Vector3 = Vector3,
        Quaternion = Quaternion,
        Plane = Plane,
        Ray = Ray,
    },
    
    daneelObjects = {
        RaycastHit = RayCastHit,
        Component = Component,
        Asset = Asset,
    },


    -- Triggers
    -- list of gameObjects check for rpoximity by the triggers
    -- filled in the TriggerableGameObject script
    triggerableGameObjects = {},
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


    -- 
    Daneel.defaultConfig.assetTypes = table.getkeys(Daneel.defaultConfig.assetObjects)
    Daneel.defaultConfig.componentTypes = table.getkeys(Daneel.defaultConfig.componentObjects)

    local t = table.new()
    t = t:merge(Daneel.defaultConfig.assetObjects)
    t = t:merge(Daneel.defaultConfig.componentObjects)
    t = t:merge(Daneel.defaultConfig.craftStudioObjects)
    t = t:merge(Daneel.defaultConfig.daneelObjects)
    Daneel.defaultConfig.allObjects = t

end


