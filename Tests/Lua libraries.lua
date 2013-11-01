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
    
    ---------------------
    
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
    
    s = " un, deux ,trois "
    r = string.split( s, "," )
    local t = { " un", " deux ", "trois " }
    if not table.havesamecontent( r , t ) then
        print( "string.split 1" )
        table.print( r )
    end
    
    r = string.split( s, " ", false )
    local t = { "un,", "deux", ",trois" }
    if not table.havesamecontent( r , t ) then
        print( "string.split 2" )
        table.print( r )
    end
    
    s = " un. deux .trois "
    r = string.split( s, ".", true )
    local t = { "un", "deux", "trois" }
    if not table.havesamecontent( r , t ) then
        print( "string.split 3" )
        table.print( r )
    end
    s = " un.] deux .]trois "
    r = string.split( s, ".]" )
    local t = { " un", " deux ", "trois " }
    if not table.havesamecontent( r , t ) then
        print( "string.split 4" )
        table.print( r )
    end
    
    s = " un<br> deux <br>trois "
    r = string.split( s, "<br>", true )
    local t = { "un", "deux", "trois" }
    if not table.havesamecontent( r , t ) then
        print( "string.split 5" )
        table.print( r )
    end
    
    r = string.split( s, "<br>" )
    local t = { " un", " deux ", "trois " }
    if not table.havesamecontent( r , t ) then
        print( "string.split 6" )
        table.print( r )
    end
    
    -----
    
    s = "start end"
    r = s:startswith( "s" )
    if r ~= true then
        print( "string.startswith 1", r )
    end
    r = s:startswith( "a" )
    if r ~= false then
        print( "string.startswith 2", r )
    end
    r = s:startswith( "start e" )
    if r ~= true then
        print( "string.startswith 3", r )
    end
    
    r = s:endswith( "d" )
    if r ~= true then
        print( "string.endswith 1", r )
    end
    r = s:endswith( "a" )
    if r ~= false then
        print( "string.endswith 2", r )
    end
    r = s:endswith( "t end" )
    if r ~= true then
        print( "string.endswith 3", r )
    end
    
    -----
    s = "  text "
    
    r = string.trimstart( s )
    if r ~= "text " then
        print( "string.trimstart", r )
    end
    r = string.trimend( s, " " )
    if r ~= "  text" then
        print( "string.trimend", r )
    end
    r = string.trim( s, " " )
    if r ~= "text" then
        print( "string.trim", r )
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
    
    r = table.copy( self.gameObject )
    if not table.havesamecontent( self.gameObject, r ) or getmetatable( r ) ~= GameObject then
        print( "table.copy 3" )
        table.print( r )
        table.print( self.gameObject )
    end
    
    r = table.copy( self.gameObject, nil, true )
    if not table.havesamecontent( self.gameObject, r ) or getmetatable( r ) ~= nil then
        print( "table.copy 4" )
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
        [self.gameObject] = "Lua libs", [GameObject.Get("Daneel Core")] = "Daneel Core"
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
    
    table.insert( ks, "quatre" )
    if Daneel.Config.debug.enableDebug then
        print( "table.combine : two warning messages expected below" )
    end
    
    r = table.combine( ks, vs, false )
    if not table.havesamecontent( r, t ) then
        print( "table.combine 2" )
        table.print( r )
    end
    
    r = table.combine( ks, vs, true )
    if r ~= false then
        print( "table.combine 3", r )
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
end
