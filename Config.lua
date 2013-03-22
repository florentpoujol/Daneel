-- v1.1.0
-- 21/03/2013

if Daneel == nil then 
    Daneel = {}
end


Daneel.config = {

    -- List of the Scripts paths as values and optionally the script alias as the keys
    scripts = {
        -- "fully-qualified Script path"
        -- alias = "fully-qualified Script path"
    },

    
    -- List of the button names you defined in the "Administration > Game Controls" tab of your project
    buttons = {

    },


    -- Set to true to enable the framework's advanced debugging capabilities.
    -- Set to false when you ship the game.
    debug = false,
}


if Daneel.InitConfig ~= nil then -- Daneel.lua has already been read
    Daneel.InitConfig()
end
