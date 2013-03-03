
if Daneel == nil then
    Daneel = {}
end

function Daneel.Awake()
    Daneel.StackTrace.BeginFunction("Daneel.Awake")


    -- Config
    Daneel.defaultConfig.Init()
    

    -- Screen
    if Daneel.config.screenSize ~= nil then
        CraftStudio.Screen.SetSize(Daneel.config.screenSize.x, Daneel.config.screenSize.y)
    else
        Daneel.config.screenSize = CraftStudio.Screen.GetSize()
    end

    Daneel.config.hudCameraGo = GameObject.Get(Daneel.config.hudCameraName)


    -- Helpers functions
    Asset.Init()
    Component.Init()
    GameObject.Init()
    


    Daneel.StackTrace.EndFunction("Daneel.Awake")
end

function Daneel.Start()

end 

function Daneel.Update()
    
end


