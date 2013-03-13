
if Daneel == nil then
    Daneel = {}
end

function Daneel.Awake()
    Daneel.Debug.StackTrace.BeginFunction("Daneel.Awake")


    -- Config
    Daneel.defaultConfig.Init()
        

    -- Helpers functions
    Asset.Init()
    Component.Init()
    GameObject.Init()
    


    Daneel.Debug.StackTrace.EndFunction("Daneel.Awake")
end

function Daneel.Start()

end 

function Daneel.Update()
    -- fire an event whenever a registered button is pressed
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

