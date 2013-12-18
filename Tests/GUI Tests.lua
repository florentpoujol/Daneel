
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
    
    r = go.hud.layer
    if r ~= GUI.Config.hud.layer then
        print("GUI.Hud 2", r )
    end
    
    go = GameObject.Get( "HUD 2" )
    r = go.hud.position
    local e = Vector2( screenSize.x*5/100, screenSize.y-10 )
    if r ~= e then
        print("GUI.Hud 3", r, e )    
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
    
    go = GameObject.Get( "HUD 12" )
    r = go.hud.localLayer
    if r ~= -1 then
        print("GUI.Hud 5", r)
    end
    
    r = go.hud.layer
    if r ~= 0 then
        print("GUI.Hud 6", r)
    end
end
