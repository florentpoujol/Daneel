-- Timer.lua
-- Scripted behavior for Timers.
--
-- Last modified for v1.3
-- Copyright © 2013 Florent POUJOL, published under the MIT licence.

--[[PublicProperties
duration number 0
callback string ""
isInfiniteLoop boolean false
/PublicProperties]]

function Behavior:Awake()
	Daneel.Debug.AlertLoad( "Timer:Awake() : ") 

    if self.callback:trim() ~= "" then
        self.callback = Daneel.Utilities.GetValueFromName( self.callback )
    else
        self.callback = nil
    end

    self.gameObject.timer = Tween.Timer.New( self.duration, self.callback, self.isInfiniteLoop )
end
