
if Daneel == nil then
    Daneel = {}
end

function Daneel.Awake()
    Daneel.Debug.StackTrace.BeginFunction("Daneel.Awake")


    -- Config
    Daneel.defaultConfig.Init()
    

    -- Screen
    if Daneel.config.screenSize ~= nil then
        CraftStudio.Screen.SetSize(Daneel.config.screenSize.x, Daneel.config.screenSize.y)
    else
        Daneel.config.screenSize = CraftStudio.Screen.GetSize()
    end

    Daneel.config.hudCameraGo = GameObject.Get(Daneel.config.hudCameraName)

    --
    if Daneel.config.input == nil then
        Daneel.config.input = {}
    end

    

    -- Helpers functions
    Asset.Init()
    Component.Init()
    GameObject.Init()
    


    Daneel.Debug.StackTrace.EndFunction("Daneel.Awake")
end

function Daneel.Start()

end 

function Daneel.Update()
    -- triger an event whenever a registered button is pressed
    for i, buttonName in ipairs(Daneel.config.buttons) do
        if CraftStudio.Input.IsButtonDown(buttonName) then
            Daneel.Events.Fire("On"..buttonName:ucfirst().."ButtonDown")
        end

        if CraftStudio.Input.WasButtonJustPressed(buttonName) then
            Daneel.Events.Fire("On"..buttonName:ucfirst().."ButtonDown")
        end

        if CraftStudio.Input.WasButtonJustPressed(buttonName) then
            Daneel.Events.Fire("On"..buttonName:ucfirst().."ButtonDown")
        end
    end
end

