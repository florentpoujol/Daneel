-- Tweener.lua
-- Scripted behavior for Tweeners.
--
-- Last modified for v1.3
-- Copyright © 2013 Florent POUJOL, published under the MIT license.

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
isPaused boolean false
OnComplete string ""
OnLoopComplete string ""
/PublicProperties]]

local function getvalue( value )
    local values = string.split( value, ",", true )
    value = nil
    for i, value in ipairs( values ) do
        values[i] = tonumber( value )
    end

    if #values == 1 then
        value = values[1]
    elseif #values == 2 then
        if not Daneel.Utilities.GlobalExists( "Vector2" ) then
            error( "Tweener:Awake() : The Vector2 object is unknow, probably because the GUI module is absent from your project." )
        end
        value = Vector2.New( values[1], values[2] )
    elseif #values == 3 then
        value = Vector3:New( values[1], values[2], values[3] )
    elseif #values == 4 then
        value = Quaternion:New( values[1], values[2], values[3], values[4] )
    end

    return value
end

function Behavior:Awake()
    if string.trim( self.target ) ~= "" then
        self.target = self.gameObject[self.target]
    else
        self.target = nil
    end

    if string.trim( self.startValue ) ~= "" then
        self.startValue = getvalue( self.startValue )
    else
        self.startValue = nil
    end

    if string.trim( self.endValue ) ~= "" then
        self.endValue = getvalue( self.endValue )
    else
        self.endValue = nil
    end

    if string.trim( self.OnComplete ) ~= "" then
        local onComplete = self.OnComplete
        self.OnComplete = Daneel.Utilities.GetValueFromName( self.OnComplete )
        if self.OnComplete == nil then
            error( "Tweener:Awake() : OnComplete callback with name '" .. onComplete .. "' was not found. Scripted behavior is on " .. tostring( self.gameObject ) )
        end
    else
        self.OnComplete = nil
    end

    if string.trim( self.OnLoopComplete ) ~= "" then
        local onLoopComplete = self.OnLoopComplete
        self.OnLoopComplete = Daneel.Utilities.GetValueFromName( self.OnLoopComplete )
        if self.OnLoopComplete == nil then
            error( "Tweener:Awake() : OnLoopComplete callback with name '" .. onLoopComplete .. "' was not found. Scripted behavior is on " .. tostring( self.gameObject ) )
        end
    else
        self.OnLoopComplete = nil
    end

    self.gameObject.tweener = Tween.Tweener.New( table.copy( self, true ) )
    self.OnComplete = nil
    self.OnLoopComplete = nil
end
