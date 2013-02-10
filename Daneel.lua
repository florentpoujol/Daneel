
if Daneel == nil then Daneel = {} end

function Daneel.Awake()
    -- Config
    if Daneel.config == nil then
        Daneel.config = table.new()
    end

    setmetatable(Daneel.config, { __index = Daneel.defaultConfig })
    


    -- merge user config with config
    -- if Daneel.projectConfig ~= nil and type(Daneel.projectConfig) == "table" then
    --     Daneel.config = table.join(Daneel.config, Daneel.projectConfig)
    -- end

    if Daneel.config.screenSize ~= nil then
        CraftStudio.Screen.SetSize(Daneel.config.screenSize.x, Daneel.config.screenSize.y)
    else
        Daneel.config.screenSize = CraftStudio.Screen.GetSize()
    end

    Daneel.config.hudCameraGo = GameObject.Get(Daneel.config.hudCameraName)
end

function Daneel.Start()

end 

function Daneel.Update()

end