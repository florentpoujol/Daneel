local Behavior = Behavior

function Behavior:Awake()
    print("~~~~~ Daneel.Utilities ~~~~~")
     
    local util = Daneel.Utilities
    
    local r = nil
    
    r = util.CaseProof( "sTrInG", {} )
    if r ~= "sTrInG" then
        print( "CaseProof 1", r )
    end
    
    r = util.CaseProof( "sTrInG", { "string" } )
    if r ~= "string" then
        print( "CaseProof 2", r )
    end
    
    r = util.CaseProof( "strInG", "sTrInG" )
    if r ~= "sTrInG" then
        print( "CaseProof 3", r )
    end
    
    -----
    local s = "foo :placeholder bar"
    
    local s2 = util.ReplaceInString( s, { placeholder = "replacement" } )
    if s2 ~= "foo replacement bar" then
        print( "ReplaceInString", s2 )
    end
        
    -----
    r = util.ToNumber( "123 foo" )
    if r ~= 123 then
        print( "ToNumber 1", r )
    end
    
    r = util.ToNumber( "foo 123.5" )
    if r ~= 123.5 then
        print( "ToNumber 2", r )
    end
    
    r = util.ToNumber( "bar 123.00 foo" )
    if r ~= 123 then
        print( "ToNumber 3", r )
    end
    
    -----
    r = util.ButtonExists( "LeftMouse" )
    if r ~= true then
        print( "ButtonExists 1", r )
    end
    
    if CS.IsWebPlayer then
        print("Error : 'Cannot read property 'wasJustPressed' of undefined' is OK")
    else
        print( "Error 'La clé donnée était absente du dictionnaire.' is OK" )
    end
    
    r = util.ButtonExists( "whatever" )
    if r ~= false then
        print( "ButtonExists 2", r )
    end
    
    
    --------------------------------------------------------------
    print("~~~~~ Daneel.Debug ~~~~~")
    
    local d = Daneel.Debug
        
    r = d.GetType( self.gameObject )
    if r ~= "GameObject" then
        print( "Debug.GetType 1", r )
    end
    
    r = d.GetType( self )
    if r ~= "ScriptedBehavior" then
        print( "Debug.GetType 2", r )
    end
    
    r = d.GetType( Behavior )
    if r ~= "Script" then
        print( "Debug.GetType 3", r )
    end
    
    r = d.GetType( Asset.Get( "Scene1", "Scene" ), false )
    if r ~= "Scene" then
        print( "Debug.GetType 4", r )
    end
    
    r = d.GetType( Vector3:New(0) )
    if r ~= "Vector3" then
        print( "Debug.GetType 5", r )
    end
    
    r = d.GetType( Vector3:New(0), true )
    if r ~= "table" then
        print( "Debug.GetType 5", r )
    end
    
    r = d.GetType( "string" )
    if r ~= "string" then
        print( "Debug.GetType 6", r )
    end
    
    r = d.GetType( 10 )
    if r ~= "number" then
        print( "Debug.GetType 7", r )
    end
    
    -----
    r = d.ToRawString( self.gameObject )
    if 
        ( CS.IsWebPlayer and r ~= "table" ) or
        ( not CS.IsWebPlayer and not r:find("table: %d+") ) 
    then
        print( "Debug.ToRawString", r )
        print( self.gameObject, d.ToRawString( self.gameObject ) )
    end
    
    -----
   
    r = d.GetNameFromValue( Daneel )
    if r ~= "Daneel" then
        print( "Debug.GetNameFromValue 1", r )
    end
    
    r = d.GetNameFromValue( GUI.Hud )
    if r ~= "GUI.Hud" and Daneel.isLoaded then
        print( "Debug.GetNameFromValue 2", r )
    end
    
    r = d.GetNameFromValue( ModelRenderer )
    if r ~= "ModelRenderer" then
        print( "Debug.GetNameFromValue 3", r )
    end
    
    r = d.GetNameFromValue( Vector2 )
    if r ~= "Vector2" then
        print( "Debug.GetNameFromValue 4", r )
    end
    
    -----
    local arg = "sTrInG"

    r = d.CheckArgValue( arg, "arg", {"test"}, "erorHead", "defaultValue" )
    if r ~= "defaultValue" then
        print( "Debug.CheckArgValue 1", r )
    end
    
    r = d.CheckArgValue( arg, "arg", { "string" }, "erorHead", "defaultValue" )
    if r ~= "string" then
        print( "Debug.CheckArgValue 2", r )
    end
    
    r = d.CheckArgValue( 10, "arg", { 2, 4, 10, 12 }, "erorHead", 100 )
    if r ~= 10 then
        print( "Debug.CheckArgValue 3", r )
    end
    
    -----
    -- stack trace
    local debug = Daneel.Config.debug.enableDebug
    local st = Daneel.Config.debug.enableStackTrace
    Daneel.Config.debug.enableDebug = true
    Daneel.Config.debug.enableStackTrace = true
    print( "Two messages in the StackTrace below" )
    Daneel.Debug.StackTrace.BeginFunction( "Function1", "arg1", 2 )
    Daneel.Debug.StackTrace.BeginFunction( "Function2", function()end, {} )
    Daneel.Debug.StackTrace.EndFunction()
    Daneel.Debug.StackTrace.BeginFunction( "Function3", {}, function()end )
    
    Daneel.Debug.StackTrace.Print()
    
    Daneel.Config.debug.enableDebug = debug
    Daneel.Config.debug.enableStackTrace = st
    
    
    --------------------------------------------------------------
    print("~~~~~ Daneel.Event ~~~~~")
    
    local e = Daneel.Event
    
    Daneel.Event.Listen( "OnTestEvent", function( ... ) print( "OnTestEvent event fired at anonymous function", ... ) end )
    Daneel.Event.Listen( { "OnTestEvent", "OnOtherTestEvent"}, self.gameObject )
    Daneel.Event.Listen( { "OnTestEvent", "OnThirdEvent" }, self.gameObject )
   
    self.gameObject.OnTestEvent = function( ... )
        print( "OnTestEvent event fired at gameObject, catched by anonymous function", self.gameObject, ... )
    end
    self.gameObject.OnOtherTestEvent = "NewMessageName"
    
    Daneel.Event.StopListen( "OnThirdEvent", self.gameObject )
    
    print("Fire OnTestEvent, 3 prints expecteds")
    Daneel.Event.Fire( "OnTestEvent", "arg1", 2 )
    print("Fire OnOtherTestEvent, 1 prints expecteds")
    Daneel.Event.Fire( "OnOtherTestEvent", 1, "arg2" )
    
    Daneel.Event.StopListen( self.gameObject )
    
    print("Fire OnTestEvent and OnOtherTestEvent, 1 prints expected, no arguments")
    Daneel.Event.Fire( "OnTestEvent" )
    Daneel.Event.Fire( "OnOtherTestEvent" )
    
    print("Fire OnTestEvent directly at the game object, 2 prints expected, no arguments.")
    Daneel.Event.Fire( self.gameObject, "OnTestEvent" )

    --------------------------------------------------------------
    print("~~~~~ Daneel.Storage ~~~~~")
    
    r = Daneel.Storage.Load( "Whatever" )
    if r ~= nil then
        print( "Storage.Load 1", r )
    end

    local dv = "the default value"
    r = Daneel.Storage.Load( "Whatever", dv )
    if r ~= dv then
        print( "Storage.Load 2", r )
    end

    r = Daneel.Storage.Save( "Player Name", "Foo Bar" )
    if r ~= true then
        print( "Storage.Save 1", r )
    end

    r = Daneel.Storage.Save( "Player Name", "John Doe" )
    if r ~= true then
        print( "Storage.Save 2", r )
    end

    local data = { 42, foo = "bar" }
    r = Daneel.Storage.Save( "Some Data", data )
    if r ~= true then
        print( "Storage.Save 3", r )
    end

    r = Daneel.Storage.Load( "Player Name", "Florent" )
    if r ~= "John Doe" then
        print( "Storage.Load 3", r )
    end

    r = Daneel.Storage.Load( "Some Data" )
    if not table.havesamecontent( data, r ) then
        print( "Storage.Load 4", r )
        table.print( r )
    end

    r = Daneel.Storage.Save( "Some Data", nil )
    if r ~= true then
        print( "Storage.Save 4", r )
    end

    r = Daneel.Storage.Load( "Some Data" )
    if r ~= nil then
        print( "Storage.Load 5", r )
    end
end


-- Events

function Behavior:OnTestEvent( data )
    print( "OnTestEvent event fired at gameObject, catched by Behavior function", self.gameObject, unpack( data ) )
end

function Behavior:NewMessageName( data )
    print( "OnOtherTestEvent event fired at gameObject, catched by Behavior function 'NewMessageName'", self.gameObject, unpack( data ) )
end

function Behavior:OnThirdEvent( data )
    print( "THIS NOT OK OnThirdEvent event fired at gameObject, catched by Behavior function. THIS NOT OK", self.gameObject, unpack( data ) )
end


-- Time
local frameCount = 0
function Behavior:Update()
    frameCount = frameCount + 1
    
    if frameCount == 0 then
        print("~~~~~ Daneel.Time ~~~~~")
    end
    if frameCount < 10 then
        print( "Time            ", Daneel.Time.time, Daneel.Time.deltaTime, Daneel.Time.timeScale )
        print( "real time     ", Daneel.Time.realTime, Daneel.Time.realDeltaTime )
        print( "framecount", Daneel.Time.frameCount )
    end
    if frameCount == 3 then
        print("--------- changing Daneel.Time.timeScale to 0.5 -----------")
        Daneel.Time.timeScale = 0.5
    end
end

