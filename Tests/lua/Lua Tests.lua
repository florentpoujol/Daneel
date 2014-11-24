-- test rig for functions added to Lua's libraries

function Behavior:Awake()
    local r = nil
    
    print("~~~~~ Lua libraries ~~~~~")
    
    if math.isinteger( 1.5 ) ~= false then
        print("math.isinteger 1.5")
    end
    if math.isinteger( 2.00 ) ~= true then
        print("math.isinteger 2.00")
    end
    
    if math.isinteger( 3 ) ~= true then
        print("math.isinteger 3")
    end
    if math.isinteger( "5" ) ~= false then
        print("math.isinteger '5'")
    end
    
    --
    r = math.lerp( 0,1,0.5)
    if r ~= 0.5 then
        print("math.lerp 1", r )
    end
    
    r = math.lerp( 50,150,0.75)
    if r ~= 125 then
        print("math.lerp 2", r )
    end
    
    --
    r = math.warpangle( 90 )
    if r ~= 90 then
        print("math.warpangle 1", r )
    end
    
    r = math.warpangle( -285 )
    if r ~= 75 then
        print("math.warpangle 2", r )
    end
    
    --
    if math.round( 150.2 ) ~= 150 then
        print("math.round 150.2")
    end
    if math.round( 150.5 ) ~= 151 then
        print("math.round 150.5")
    end
    if math.round( 150.8 ) ~= 151 then
        print("math.round 150.8")
    end
    if math.round( 1.123456789, 2 ) ~= 1.12 then
        print("math.round( 1.123456789, 2 )")
    end
    if math.round( 1.123456789, 5 ) ~= 1.12346 then
        print( "math.round( 1.123456789, 5 )" )
    end
    
    --
    r = tonumber2( "123 foo" )
    if r ~= 123 then
        print( "tonumber2 1", r )
    end
    
    r = tonumber2( "foo 123.5" )
    if r ~= 123.5 then
        print( "tonumber2 2", r )
    end
    
    r = tonumber2( "bar 123.00 foo" )
    if r ~= 123 then
        print( "tonumber2 3", r )
    end
    
    --
    r = math.clamp( -52, 0, 50 )
    if r ~= 0 then
        print( "math.clamp 1", r )
    end
    
    r = math.clamp( -52, -85.2, -10.0 )
    if r ~= -52 then
        print( "math.clamp 1", r )
    end 
    
    r = math.clamp( 52, 22, 40 )
    if r ~= 40 then
        print( "math.clamp 1", r )
    end 
    
    
    ---------------------
    -- string
    
    local s = nil
    local r = string.totable( "123" )
    local t = {"1", "2", "3"}
    if not table.havesamecontent( r, t ) then
        print( "string.totable( '123' )" )
        table.print( r )
    end
    
    -----
    local s1 = "123456789"
    local s2 = "sTrInG"

    -----
    local s4 = "ucfirst"
    local s5 = "LCFIRST"
    
    r = string.ucfirst( s4 )
    if r ~= "Ucfirst" then
        print( "string.ucfirst 1", r )
    end

    r = string.ucfirst( s5 )
    if r ~= "LCFIRST" then
        print( "string.ucfirst 2", r )
    end
    
    r = string.lcfirst( s5 )
    if r ~= "lCFIRST" then
        print( "string.lcfirst 1", r )
    end

    r = string.lcfirst( s4 )
    if r ~= "ucfirst" then
        print( "string.lcfirst 2", r )
    end
    
    -----
    
    -- delimiter is no pattern
    s = "un,deux,trois"
    r = string.split( s, "," )
    local t = { "un", "deux", "trois" }
    if not table.havesamecontent( r , t ) then
        print( "string.split 1" )
        table.print( r )
    end   
    
    s = "un<br>deux<br>trois"
    r = string.split( s, "<br>", false )
    if not table.havesamecontent( r , t ) then
        print( "string.split 3" )
        table.print( r )
    end
    
    if not CS.IsWebPlayer then
        r = string.split( s, "<br>", true ) -- fails in the webplayer because "trois" has a "r", like "<br>"
        if not table.havesamecontent( r , t ) then
            print( "string.split 4" )
            table.print( r )
        end
    end
    
    s = "un.deux.trois"
    r = string.split( s, "." ) -- dot is supposed to be escaped
    if not table.havesamecontent( r , t ) then
        print( "string.split 5" )
        table.print( r )
    end
       
    r = string.split( s, "bla" )
    if not table.havesamecontent( r , {s} ) then
        print( "string.split 6" )
        table.print( r )
    end
    
    -- delimiter is pattern
    s = " un deux trois "
    r = string.split( s, "%s" ) -- plain text
    if not table.havesamecontent( r , {s} ) then
        print( "string.split 7" )
        table.print( r )
    end
    
    r = string.split( s, "%s", true ) -- delimter is pattern
    t = { "un", "deux", "trois" }
    if not table.havesamecontent( r , t ) then
        print( "string.split 8" )
        table.print( r )
    end
    
    s =  "un %sdeux%s trois "
    t = { "un ", "deux", " trois " }
    r = string.split( s, "%s" ) -- plain text
    if not table.havesamecontent( r , t ) then
        print( "string.split 9" )
        table.print( r )
    end
    
    r = string.split( s, "%s", true ) -- pattern
    t = { "un", "%sdeux%s", "trois" }
    if not table.havesamecontent( r , t ) then
        print( "string.split 10" )
        table.print( r )
    end
    
    -----
    
    s = "start end"
    r = string.startswith( s, "s" )
    if r ~= true then
        print( "string.startswith 1", r )
    end
    r = string.startswith( s, "a" )
    if r ~= false then
        print( "string.startswith 2", r )
    end
    r = string.startswith( s, "start e" )
    if r ~= true then
        print( "string.startswith 3", r )
    end
    
    r = string.endswith( s, "d" )
    if r ~= true then
        print( "string.endswith 1", r )
    end
    r = string.endswith( s, "a" )
    if r ~= false then
        print( "string.endswith 2", r )
    end
    r = string.endswith( s, "t end" )
    if r ~= true then
        print( "string.endswith 3", r )
    end
    
    -----
    s = "  text "
    
    r = string.trimstart( s )
    if r ~= "text " then
        print( "string.trimstart", r )
    end
    r = string.trimend( s )
    if r ~= "  text" then
        print( "string.trimend", r )
    end
    r = string.trim( s )
    if r ~= "text" then
        print( "string.trim", r )
    end
    
    --
    r = string.reverse( "123456" )
    if r ~= "654321" then
        print("string.reverse 1", r)
    end
    
    r = string.reverse( "aJfv 5Y-)c3" )
    if r ~= "3c)-Y5 vfJa" then
        print("string.reverse 2", r)
    end
    
    --
    r = string.fixcase( "sTrInG", {} )
    if r ~= "sTrInG" then
        print( "string.fixcase 1", r )
    end
    
    r = string.fixcase( "sTrInG", { "string" } )
    if r ~= "string" then
        print( "string.fixcase 2", r )
    end
    
    r = string.fixcase( "StrInG", "String" )
    if r ~= "String" then
        print( "string.fixcase 3", r )
    end
    

    --------------------------------------------------
    -- table
    
    local t = {"1", deux = "2", ["tr ois"] = function() end, [4] = {} }
    
    r = table.copy( t )
    if not table.havesamecontent( t, r ) or r[4] ~= t[4] then
        print( "table.copy 1", r[4], t[4] )
        table.print( r )
    end
    
    r = table.copy( t, true )
    if r[4] == t[4] then
        print( "table.copy 2", r[4], t[4] )
        table.print( r )
    end
        
    
    --------
    
    local v = t[4]
    
    r = table.containsvalue( t, t[4] )
    if r ~= true then
        print( "table.containsvalue 1", r )
    end
    
    r = table.containsvalue( t, 5 )
    if r ~= false then
        print( "table.containsvalue 2", r )
    end
    
    t.cinq = "CiNq"
    
    r = table.containsvalue( t, "CiNq", false )
    if r ~= true then
        print( "table.containsvalue 3", r )
    end
    
    r = table.containsvalue( t, "cinq", false )
    if r ~= false then
        print( "table.containsvalue 4", r )
    end
    
    r = table.containsvalue( t, "cinq", true )
    if r ~= true then
        print( "table.containsvalue 5", r )
    end
    
    -----
    t = {
        un = "un", deux = "deux", 
        3, 4, [4.5] = 4.5, 
        [self.gameObject] = "Lua libs", [GameObject.Get("Perspective Camera")] = "Perspective Camera"
    }
    
    r = table.getlength( t )
    if r ~= 7 then
        print( "tabl.getlength 1", r )
    end
    
    r = table.getlength( t, "numBer" )
    if r ~= 3 then
        print( "tabl.getlength 2", r )
    end
    
    r = table.getlength( t, "string" )
    if r ~= 2 then
        print( "tabl.getlength 3", r )
    end
    
    r = table.getlength( t, "GameObject" )
    if r ~= 2 then
        print( "tabl.getlength 4", r )
    end
    
    -----
    t = {  trois = 3, quatre = 4,  }
    local t2 = {  trois = 33, cinq = 5 }
    local t3 = {  trois = 333, quatre = 44 }
    local t4 = { trois = 333,  quatre = 44, cinq = 5 }
    
    r = table.merge( t, t2, t3 )
    if not table.havesamecontent( r, t4 ) then
        print( "table.merge 1" )
        table.print( r )
        table.print( t4 )
    end
    
    -----
    local ks = { "un", "deux", "trois" }
    local vs = {1,2,3}
    t = { un=1, deux=2, trois=3}
    
    r = table.combine( ks, vs )
    if not table.havesamecontent( r, t ) then
        print( "table.combine 1" )
        table.print( r )
    end
    
    -----
    local t = { 
        key = "value t",
        t1 = { 
            key = "value t1",
            t2 = { 
                key = "value t2",
            }
        }
    }
    
    r = table.getvalue( t, "key" )
    if r ~= t.key then
        print( "table.getvalue 1", r )
    end
    
    r = table.getvalue( t, "t1.key" )
    if r ~= t.t1.key then
        print( "table.getvalue 2", r )
    end
    
    r = table.getvalue( t, "t1.t2.key" )
    if r ~= t.t1.t2.key then
        print( "table.getvalue 3", r )
    end
    
    r = table.getvalue( t, "foobar" )
    if r ~= t.fooBar then
        print( "table.getvalue 4", r )
    end
    
    r = table.getvalue( t, "foo.bar" )
    if r ~= nil then
        print( "table.getvalue 5", r )
    end
    
    r = table.getvalue( t, "t1.foo.bar" )
    if r ~= nil then
        print( "table.getvalue 6", r )
    end
    
    r = table.getvalue( t, "t1.t2.Foo" )
    if r ~= nil then
        print( "table.getvalue 7", r )
    end
    
    r = table.getvalue( _G, "Daneel.Utilities" )
    if r ~= Daneel.Utilities then
        print( "table.getvalue 8", r )
    end

    r = table.getvalue( _G, "foobar" )
    if r ~= nil then
        print( "table.getvalue 9", r )
    end

    ----
    local t = { "1", "2", "3"}
    local rt = { "3", "2", "1"}

    r = table.reverse( t )
    if not table.havesamecontent( r, rt ) then
        print( "tabl.reverse 1", r )
        table.print( r )
    end
    
    --
    r = table.isarray({})
    if r ~= true then
        print("table.isarray 1", r)
    end
    
    r = table.isarray( { 1, 2, 3})
    if r ~= true then
        print("table.isarray 2", r)
    end
    r = table.isarray( { 1, 2, 3}, false)
    if r ~= true then
        print("table.isarray 3", r)
    end
    
    r = table.isarray( { 1, 2, [4] = 4 }, true)
    if r ~= false then
        print("table.isarray 4", r)
    end
    
    r = table.isarray( { 1, 2, 3, key = "value" })
    if r ~= false then
        print("table.isarray 5", r)
    end
    
    --
    local a = { 1,"2",3 }
    local t = { key1 = "value1", key2 = "value2" }
    

    r = table.shift( a )
    if r ~= 1 then
        print("table.shift 1", r)
    end

    local r, r2 = table.shift( a, true )
    if r ~= 1 or r2 ~= "2" then
        print("table.shift 2", r, r2)
    end
    
    r = table.shift( t )
    if r ~= "value1" then
        print("table.shift 3", r)
    end
    
    r, r2 = table.shift( t, true )
    if r ~= "key2" or r2 ~= "value2" then
        print("table.shift 4", r, r2)
    end
    
    --
    local a = { 1, 2, [4] = 3, [6] = 4 }
    local a = table.reindex( a )
    r = table.isarray( a )
    if r ~= true and #a ~= 4 then
        print("table.reindex 1", r)
    end
    
    --
    t = {}
    
    table.insertonce( t, 1 )
    table.insertonce( t, 1 )
    table.insertonce( t, 1 )
    if #t > 1 then
        print("table insertonce 1", #t)
        table.print(t)
    end
    
    table.insertonce( t, 2 )
    table.insertonce( t, 3 )
    
    table.insertonce( t, 2, "value1" )
    table.insertonce( t, 2, "value1" )
    if #t ~= 4 or t[2] ~= "value1" then
        print("table insertonce 2", #t)
        table.print(t)
    end
end
