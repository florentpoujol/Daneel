
local daneel_exists = false
for key, value in pairs(_G) do
    if key == "Daneel" then
        daneel_exists = true
        break
    end
end
if daneel_exists == false then
    Daneel = {}
end


----------------------------------------------------------------------------------
-- Tween

Daneel.Tween = { 
    tweens = {},
}


local function GetTweenerProperty(tweener)
    local value = nil
    if tweener.target ~= nil then
        value = tweener.target[tweener.property]
        if value == nil then
            local functionName = "Get"..tweener.property:ucfirst()
            if tweener.target[functionName] ~= nil then
                value = tweener.target[functionName]()
            end
        end
    end
    return value
end

local function SetTweenerProperty(tweener, value)
    if tweener.target ~= nil then
        if tweener.target[tweener.property] == nil then
            local functionName = "Set"..tweener.property:ucfirst()
            if tweener.target[functionName] ~= nil then
                tweener.target[functionName](property)
            end
        end
    end
end


-- called from Daneel.Update()
function Daneel.Tween.Update()
    for id, tweener in pairs(Daneel.Tween.Tweener.tweeners) do
        if  tweener.isEnabled == true and tweener.isPaused == false and tweener.isCompleted == false and tweener.duration > 0 then

            local deltaDuration = Daneel.Time.deltaTime
            if tweener.durationType == "realTime" then
                deltaDuration = Daneel.Time.realDeltaTime
            elseif tweener.durationType == "frame" then
                deltaDuration = 1
            end


            if tweener.delay <= 0 then
                -- no more delay before starting the tweener, update the tweener
                
                if tweener.hasStarted == false then
                    -- firt loop for this tweener
                    tweener.hasStarted = true

                    if tweener.startValue == nil then
                        if tweener.target ~= nil then
                            tweener.startValue = GetTweenerProperty(tweener)
                        else
                            error("ERROR : startValue is nil by not target is set")
                        end
                    elseif tweener.target ~= nil then
                        -- when start value and a target are set move the target to startValue before updating the tweener
                        SetTweenerProperty(tweener, tweener.startValue)
                    end
                    tweener.value = tweener.startValue

                    if tweener.isRelative == true then
                        tweener.diffValue = tweener.endValue
                    else
                        tweener.diffValue = tweener.endValue - tweener.startValue
                    end

                    Daneel.Event.Fire(tweener, "OnStart", tweener)
                end
                
                -- update the tweener
                tweener:Update(deltaDuration)
            else
                tweener.delay = tweener.delay - deltaDuration
            end -- end if tweener.delay <= 0


            if tweener.isCompleted == true then
                tweener.completedLoops = tweener.completedLoops + 1
                if tweener.loops == -1 or tweener.completedLoops < tweener.loops then
                    tweener.isCompleted = false
                    tweener.elapsed = 0

                    if tweener.loopType:lower() == "yoyo" then
                        local startValue = tweener.startValue
                        tweener.startValue = tweener.endValue
                        tweener.endValue = startValue
                        tweener.diffValue = -tweener.diffValue
                    elseif tweener.target ~= nil then
                        SetTweenerProperty(tweener, tweener.startValue)
                    end

                    tweener.value = tweener.startValue
                    Daneel.Event.Fire(tweener, "OnLoopComplete", tweener)

                else
                    Daneel.Event.Fire(tweener, "OnComplete", tweener)
                    tweener:Destroy()
                end
            end
        end -- end if tweener.isEnabled == true
    end -- end for tweens
end


----------------------------------------------------------------------------------
-- Tweener

Daneel.Tween.Tweener = { tweeners = {} }
Daneel.Tween.Tweener.__index = Daneel.Tween.Tweener
setmetatable(Daneel.Tween.Tweener, { __call = function(Object, ...) return Object.New(...) end })

function Daneel.Tween.Tweener.__tostring(tweener)
    return "Tweener id:'"..tweener.id.."'"
end

local tweenerId = 0

function Daneel.Tween.Tweener.New(target, property, endValue, duration, params)
    local tweener = table.copy(config.tween.defaultTweenerParams)
    setmetatable(tweener, Daneel.Tween.Tweener)

    tweenerId = tweenerId + 1
    tweener.id = tweenerId

    -- three constructors :
    -- target, property, endvalue, duration[, params]
    -- startvalue, endvalue, duration[, params]
    -- params

    if type(target) == "number" then
        -- constructor n°2
        tweener.startValue = target
        tweener.endValue = property
        tweener.duration = endValue
        if type(duration) == "table" then
            tweener:Set(duration)
        end
    elseif property == nil then
        -- constructor n°3
        tweener:Set(target)
    else
        -- constructor n°1
        tweener.gameObject = target.gameObject -- if target is a component
        if tweener.gameObject == nil and getmetatable(target) == GameObject then
            tweener.gameObject = target
        end

        tweener.target = target
        tweener.property = property
        tweener.endValue = endValue
        tweener.duration = duration
        if type(params) == "table" then
            tweener:Set(params)
        end
    end
    
    Daneel.Tween.Tweener.tweeners[tweener.id] = tweener
    return tweener
end

function Daneel.Tween.Tweener.Set(tweener, params)
    for key, value in pairs(params) do
        tweener[key] = value
    end
    return tweener
end

function Daneel.Tween.Tweener.Play(tweener)
    if tweener.isEnabled == false then return end
    tweener.isPaused = false
    Daneel.Event.Fire(tweener, "OnPlay", tweener)
end

function Daneel.Tween.Tweener.Pause(tweener)
    if tweener.isEnabled == false then return end
    tweener.isPaused = true
    Daneel.Event.Fire(tweener, "OnPause", tweener)
end

function Daneel.Tween.Tweener.Complete(tweener)
    if tweener.isEnabled == false or tweener.loops == -1 then return end
    tweener.isCompleted = true
    local endValue = tweener.endValue
    if tweener.loopType == "yoyo" then
        if
            (tweener.loops % 2 == 0 and tweener.completedLoops % 2 == 0) or -- endValue must be original startValue (because of even number of loops) | current X to Y loop, 
            (tweener.loops % 2 ~= 0 and tweener.completedLoops % 2 ~= 0) -- endValue must be the original endValue but the current loop is Y to X, so endValue and startValue are inversed
        then
            endValue = tweener.startValue
        end
    end
    if tweener.target ~= nil then
        SetTweenerProperty(tweener, endValue)
    end
    tweener.value = endValue
    Daneel.Event.Fire(tweener, "OnComplete", tweener)
end

function Daneel.Tween.Tweener.Restart(tweener)
    if tweener.isEnabled == false then return end
    tweener.elapsed = 0
    tweener.fullElapsed = 0
    tweener.completedLoops = 0
    tweener.isCompleted = false
    tweener.hasStarted = false
    local startValue = tweener.startValue
    if tweener.loopType == "yoyo" and tweener.completedLoops % 2 ~= 0 then -- the current loop is Y to X, so endValue and startValue are inversed
        startValue = tweener.endValue
    end
    if tweener.target ~= nil then
        SetTweenerProperty(tweener, startValue)
    end
    tweener.value = startValue
end

function Daneel.Tween.Tweener.Destroy(tweener)
    if tweener.isEnabled == false then return end
    tweener.isEnabled = false
    Daneel.Tween.Tweener.tweeners[tweener.id] = nil
end


function Daneel.Tween.Tweener.Update(tweener, deltaDuration)
    if tweener.isEnabled == false then return end

    if Daneel.Tween.Ease[tweener.easeType] == nil then
        if DEBUG == true then
            print("Daneel.Tween.Tweener.Update() : Easing '"..tostring(tweener.easeType).."' for tweener ID '"..tween.id.."' does not exists. Setting it back for the default easing '"..config.tween.defaultTweenerParams.."'.")
        end
        tweener.easeType = config.tween.defaultTweenerParams.easeType
    end


    if deltaDuration ~= nil then
        tweener.elapsed = tweener.elapsed + deltaDuration
        tweener.fullElapsed = tweener.fullElapsed + deltaDuration
    end
    local value = nil

    if tweener.elapsed > tweener.duration then
        tweener.isCompleted = true
        tweener.elapsed = tweener.duration
        if tweener.isRelative == true then
            value = tweener.startValue + tweener.endValue
        else
            value = tweener.endValue
        end
    else
        value = Daneel.Tween.Ease[tweener.easeType](tweener.elapsed, tweener.startValue, tweener.diffValue, tweener.duration)
    end


    if tweener.target ~= nil then
        SetTweenerProperty(tweener, value)
    end
    tweener.value = value

    Daneel.Event.Fire(tweener, "OnUpdate", tweener)
end

----------------------------------------------------------------------------------
-- Easing equations

Daneel.Tween.Ease = {}
-- filled with the easing equations from the "Lib/Easing" script in Daneel.Awake() 
