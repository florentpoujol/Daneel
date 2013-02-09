
function Behavior:Awake()


    -- merge project config with config
    if Daneel.projectConfig ~= nil and type(Daneel.projectConfig) == "table" then
        Daneel.config = table.join(Daneel.config, Daneel.projectConfig)
    end

    if Daneel.config.screenSize ~= nil then
        CraftStudio.Screen.SetSize(Daneel.config.screenSize.x, Daneel.config.screenSize.y)
    else
        Daneel.config.screenSize = CraftStudio.Screen.GetSize()
    end

    Daneel.config.hudCameraGo = GameObject.Get(Daneel.config.hudCameraName)
end

function Daneel.Awake()

end



function Behavior:Start()
    --Daneel.core.InitDynamicGameObjects()
end





function Behavior:Update()
    --Daneel.core.UpdateDynamicGameObjects()
    --GUI.CheckRayFromCamera()
end

