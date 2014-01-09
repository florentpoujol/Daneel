-- Timer.lua
-- Scripted behavior for Timers.
--
-- Last modified for v1.3.0
-- Copyright © 2013-2014 Florent POUJOL, published under the MIT license.

--[[PublicProperties
duration number 0
callback string ""
isInfiniteLoop boolean false
/PublicProperties]]

function Behavior:Awake()
    if string.trim( self.callback ) ~= "" then
        local callback = self.callback
        self.callback = table.getvalue( _G, self.callback )
        if self.callback == nil then
            error( "Timer:Awake() : Callback with name '" .. callback .. "' was not found. Scripted behavior is on " .. tostring( self.gameObject ) )
        end
    else
        self.callback = nil
    end

    self.gameObject.timer = Tween.Timer.New( self.duration, self.callback, self.isInfiniteLoop )
end
