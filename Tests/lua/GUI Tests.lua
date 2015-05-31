
function Behavior:Start()
    print( "~~~~~ GUI.Hud ~~~~~" )
    local screenSize = CS.Screen.GetSize()
    print( "screen size", screenSize )
    local r = nil
    local go = nil
    
    
    go = GameObject.Get( "HUD 1" )
    
    r = go.hud.position
    if r ~= Vector2.New(100) then
        print("GUI.Hud 1", r )
    end 
    
    go = GameObject.Get( "HUD 11" )
    r = go.hud.localLayer
    if r ~= 1 then
        print("GUI.Hud 4", r)
    end
    
    r = go.hud.layer
    if r ~= 2 then
        print("GUI.Hud 4.5", r)
    end
    
    
    go = GameObject.New( "HUD 12", {
        parent = "HUD 1",
        
        hud = {
            localLayer = -1,
            localPosition = Vector2(35,0)
        },
        
        modelRenderer = { model = "Model2" },
        transform = { localScale = Vector3(5.4,6.3,1) }
    } )
    
    r = go.hud.localLayer
    if r ~= -1 then
        print("GUI.Hud 5", r)
    end
    
    r = go.hud.layer
    if r ~= 0 then
        print("GUI.Hud 6", r)
    end
    
    
    go = GameObject.Get( "HUD 2" )
    r = go.hud.position
    local e = Vector2( screenSize.x*5/100, screenSize.y-10 )
    if r ~= e then
        print("GUI.Hud 3", r, e )    
    end
    
    
    print( "~~~~~ GUI.Toggle ~~~~~" )
    
    go = GameObject.Get("Radios")
    for i=1, 3 do
        GameObject.New("Radio"..i, {
            parent = go,
            toggle = {
                group = "radio1",
                checkedModel = "Model",
                uncheckedModel = "Model2",             
            },
            modelRenderer = { model = "Model"},
            transform = { localPosition = Vector3(i,0,0) },
        } )
    end
    go.child.toggle:Check( true, true )
    
    
    print( "~~~~~ GUI.ProgressBar ~~~~~" )
    -- PB1 default, length = 5 height = 1
    -- PB 2  length = 1,  height = 2
    
    local go = GameObject.Get("PB4")
    go:Set( {
        progressbar = {
            minLength = "2u",
            value = "50%"
        }
    } )
    
    
    print( "~~~~~ GUI.Slider ~~~~~" )
    
    go = GameObject.Get( "Slider 1" )
    local handle = go:GetChild( "Handle" )
    local valueGO = go:GetChild( "Value" )
    handle.slider.OnUpdate = function( slider )
        valueGO.textRenderer.text = math.round( slider.value, 1 )
    end
    
    go = GameObject.Get( "Slider 2" )
    local handle = go:GetChild( "Handle" )
    local valueGO2 = go:GetChild( "Value" ) -- can't use the same valueGO variable in the webplayer because they all points to the last one (the one on Slider 3)
    handle.slider.OnUpdate = function( slider )
        valueGO2.textRenderer.text = math.round( slider.value, 1 )
    end
    
    go = GameObject.Get( "Slider 3" )
    local handle = go:GetChild( "Handle" )
    handle:AddComponent( "Slider", {
        minValue = -50,
        maxValue = 50,
        value = 0,
        axis = "y"
    } )
    local valueGO3 = go:GetChild( "Value" )
    handle.slider.OnUpdate = function( slider )
        valueGO3.textRenderer.text = math.round( slider.value, 1 )
    end


    print( "~~~~~ GUI.TextArea ~~~~~" )
    
    go = GameObject.Get( "TextArea 1" )
    go.textArea.text = "abcdefghijkl1;abcdefghijkl2"
    
    go = GameObject.Get( "TextArea 2" )
    go.textArea.text = [[abcdefghijkl1\nabcdefghijkl2]]
    
    go = GameObject.Get( "TextArea 3" )
    
    go:AddComponent( "TextArea", {
        font = "Calibri",
        alignment = "RiGhT",        
        lineHeight = 0.2,
        verticalAlignment = "bOtToM",
        newLine = "<br>",

        areaWidth = 7,
        wordWrap = true,
        text = "abcdefghijkl1<br>abcdefghijkl2"
    } )
end

