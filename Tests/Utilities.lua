
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
    r = util.GetValueFromName( "Daneel" )
    if r ~= Daneel then
        print( "GetValueFromName 1", r )
    end
    
    r = util.GetValueFromName( "Daneel.Utilities" )
    if r ~= Daneel.Utilities then
        print( "GetValueFromName 2", r )
    end
    
    r = util.GetValueFromName( "" )
    if r ~= nil then
        print( "GetValueFromName 3", r )
    end
    
    -----
    r = util.GlobalExists( "Daneel" )
    if r ~= true then
        print( "GlobalExists 1", r )
    end
    
    r = util.GlobalExists( "" )
    if r ~= false then
        print( "GlobalExists 2", r )
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
    
    print( "Error 'La clé donnée était absente du dictionnaire.' is OK" )
    r = util.ButtonExists( "whatever" )
    if r == false then
        print( "ButtonExists 2 SUCCESS", r )
    else
        print( "ButtonExists 2 WRONG VALUE", r )
    end
end






