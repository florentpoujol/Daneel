
function LangUserConfig()
    return {
        
    }
end

function LangEnglish()
    return {
        
        greetings = {
            welcome = "Welcome :playername !"
        }
    }
end

function LangFrench()
    return {
        gamename = "Nom du jeu",
        greetings = {
            welcome = "Bienvenu :playername !"
        }
    }
end

function Behavior:Awake()
    print( "~~~~~ Lang ~~~~~" )
    local r = nil
    
       
    Lang.Config.searchInDefault = true
    r = Lang.Get("English.gamename")
    if r ~= Lang.lines[ Lang.Config.default ].gamename then
        print( "Lang.Get 1", r )
    end
    
    Lang.Config.searchInDefault = false
    r = Lang.Get("English.gamename")
    if r ~= Lang.Config.keyNotFound then
        print( "Lang.Get 1.5", r )
    end
    
    r = Lang.Get("French.gamename")
    if r ~= Lang.lines.french.gamename then
        print( "Lang.Get 2", r )
    end
    
    
    r = Lang.Get("greetings.welcome")
    if r ~= Lang.lines[ Lang.Config.current ].greetings.welcome then
        print( "Lang.Get 3", r )
    end
    
    r = Lang.Get("foobar")
    if r ~= Lang.Config.keyNotFound then
        print( "Lang.Get 4", r )
    end
    
    r = Lang.Get("greetings.welcome", { playername = "John" } )
    if r ~= Lang.lines[ Lang.Config.current ].greetings.welcome:gsub( ":playername", "John" ) then
        print( "Lang.Get 5", r )
    end
    
    r = Lang.Get("English.greetings.welcome", { playername = "Max" } )
    if r ~= Lang.lines.english.greetings.welcome:gsub( ":playername", "Max" ) then
        print( "Lang.Get 6", r )
    end
    
    self.gameObject.textRenderer.text = "initial text"
    Lang.RegisterForUpdate( self.gameObject, "greetings.welcome", { playername = "Charlie" } )
    
    Lang.Update( "English" )
    r = self.gameObject.textRenderer.text
    if r ~= Lang.lines.english.greetings.welcome:gsub( ":playername", "Charlie" ) then
        print( "Lang.Get 7", r )
    end

end

