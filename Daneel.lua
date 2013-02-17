
if Daneel == nil then
    Daneel = {}
end

function Daneel.Awake()
    Daneel.StackTrace.BeginFunction("Daneel.Awake")

    -- Config
    if Daneel.config == nil then
        Daneel.config = table.new()
    end

    setmetatable(Daneel.config, { __index = Daneel.defaultConfig })
    

    if Daneel.config.screenSize ~= nil then
        CraftStudio.Screen.SetSize(Daneel.config.screenSize.x, Daneel.config.screenSize.y)
    else
        Daneel.config.screenSize = CraftStudio.Screen.GetSize()
    end

    Daneel.config.hudCameraGo = GameObject.Get(Daneel.config.hudCameraName)

    Daneel.StackTrace.EndFunction("Daneel.Awake")
end

function Daneel.Start()

end 

function Daneel.Update()

end


