
function Lang.UserConfig()
    return {
        default = "french",
    }
end

Lang.dictionariesByLanguage.english = {
    greetings = {
        welcome = "Welcome :playername !"
    }
}

Lang.dictionariesByLanguage.french =
{
    gamename = "Nom du jeu",
    greetings = {
        welcome = "Bienvenu :playername !"
    }
}


function Behavior:Awake()
    print( "~~~~~ Lang ~~~~~" )
    local r = nil
    
       
    Lang.Config.searchInDefault = true
    r = Lang.Get("english.gamename")
    if r ~= Lang.dictionariesByLanguage[ Lang.Config.default ].gamename then
        print( "Lang.Get 1", r )
    end
    
    Lang.Config.searchInDefault = false
    r = Lang.Get("english.gamename")
    if r ~= Lang.Config.keyNotFound then
        print( "Lang.Get 1.5", r )
    end
    
    r = Lang.Get("french.gamename")
    if r ~= Lang.dictionariesByLanguage.french.gamename then
        print( "Lang.Get 2", r )
    end
    
    
    r = Lang.Get("greetings.welcome")
    if r ~= Lang.dictionariesByLanguage[ Lang.Config.current ].greetings.welcome then
        print( "Lang.Get 3", r )
    end
    
    r = Lang.Get("foobar")
    if r ~= Lang.Config.keyNotFound then
        print( "Lang.Get 4", r )
    end
    
    r = Lang.Get("greetings.welcome", { playername = "John" } )
    if r ~= Lang.dictionariesByLanguage[ Lang.Config.current ].greetings.welcome:gsub( ":playername", "John" ) then
        print( "Lang.Get 5", r )
    end
    
    r = Lang.Get("english.greetings.welcome", { playername = "Max" } )
    if r ~= Lang.dictionariesByLanguage.english.greetings.welcome:gsub( ":playername", "Max" ) then
        print( "Lang.Get 6", r )
    end
    
    self.gameObject.textRenderer.text = "initial text"
    Lang.RegisterForUpdate( self.gameObject, "greetings.welcome", { playername = "Charlie" } )
    
    Lang.Update( "english" )
    r = self.gameObject.textRenderer.text
    if r ~= Lang.dictionariesByLanguage.english.greetings.welcome:gsub( ":playername", "Charlie" ) then
        print( "Lang.Get 7", r )
    end

end

