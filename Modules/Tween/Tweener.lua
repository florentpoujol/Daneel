-- Tweener.lua
-- Scripted behavior for Tweeners.
--
-- Since v1.2.1
-- Last modified for v1.2.1
-- Copyright © 2013 Florent POUJOL, published under the MIT licence.

--[[PublicProperties
target string ""
property string ""
duration number 0
durationType string "time"
delay number 0
startValue string ""
endValue string ""
loops number 1
loopType string "simple"
easeType string "linear"
destroyOnComplete boolean true
isPaused boolean false
OnComplete string ""
OnLoopComplete string ""
PublicProperties]]

function Behavior:Awake()
    if self.target:trim() ~= "" then
        self.target = self.gameObject[self.target]
    else
        self.target = nil
    end

    if self.startValue:trim() == "" then
        self.startValue = nil
    end

    if self.endValue:trim() ~= "" then
        local values = self.endValue:split( ",", true )
        for i, value in ipairs( values ) do
            values[i] = tonumber( value )
        end

        if #values == 1 then
            self.endValue = values[1]
        elseif #values == 2 then
            self.endValue = Vector2.New( values[1], values[2] )
        elseif #values == 3 then
            self.endValue = Vector3:New( values[1], values[2], values[3] )
        elseif #values == 4 then
            self.endValue = Quaternion:New( values[1], values[2], values[3], values[4] )
        end
    else
        -- will cause error
    end

    if self.OnComplete:trim() ~= "" then
        self.OnComplete = Daneel.Utilities.GetValueFromName( self.OnComplete )
    else
        self.OnComplete = nil
    end

    if self.OnLoopComplete:trim() ~= "" then
        self.OnLoopComplete = Daneel.Utilities.GetValueFromName( self.OnLoopComplete )
    else
        self.OnLoopComplete = nil
    end

    self.gameObject.tweener = Daneel.Tween.Tweener.New( table.copy( self, true ) )
    self.OnComplete = nil
    self.OnLoopComplete = nil
end