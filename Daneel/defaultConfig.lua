
if Daneel == nil then
    Daneel = {}
end

Daneel.defaultConfig = {

    -- Objects (keys = name, value = object)
    assetObjects = {
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

    -- Cast
    castableGameObjects = {},
    
    -- Triggers
    -- list of gameObjects check for rpoximity by the triggers
    -- filled in the TriggerableGameObject script
    triggerableGameObjects = {},

    -- list of gameObject that react to the mouse input
    mousehoverableGameObjects = {},


    ----------------------------------------------------------------------------------
    -- user config
    
    -- list of the Scripts path as value and optionaly the script alias as the key
    -- It enabled dynamic getters and setters on these ScriptedBehaviors
    -- and if the alias is set, allows to acces the ScriptedBehavior as a variable on the gameObjects
    scripts = {
        -- "fully-qualified Script path"
        -- or
        -- alias = "fully-qualified Script path"
    },

    -- list of the button name you defined in the Administration>Game Controls tab of your project
    buttons = {
        
    },
}

Daneel.defaultConfig.__index = Daneel.defaultConfig


-- called from Daneel.Awake()
function Daneel.defaultConfig.Init()
    Daneel.Debug.StackTrace.BeginFunction("Daneel.defaultConfig.Init")
    Daneel.config = table.new(Daneel.config)
    setmetatable(Daneel.config, Daneel.defaultConfig)

    -- 
    Daneel.defaultConfig.assetTypes = table.getkeys(Daneel.defaultConfig.assetObjects)
    Daneel.defaultConfig.componentTypes = table.getkeys(Daneel.defaultConfig.componentObjects)

    local t = table.new()
    t = t:merge(Daneel.defaultConfig.assetObjects)
    t = t:merge(Daneel.defaultConfig.componentObjects)
    t = t:merge(Daneel.defaultConfig.craftStudioObjects)
    t = t:merge(Daneel.defaultConfig.daneelObjects)
    Daneel.defaultConfig.allObjects = t
    
    Daneel.Debug.StackTrace.EndFunction("Daneel.defaultConfig.Init")
end


