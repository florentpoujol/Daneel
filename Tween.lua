
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


local function Callback(tweener, callback, ...)
    if arg == nil then arg = {} end
    local callbackType = type(callback)
    
    if callbackType == "function" then
        callback(tweener, unpack(arg))
    
    elseif callbackType == "string" and tweener.gameObject ~= nil then
        if tweener.broadcastCallbacks == true then
            tweener.gameObject:BroadcastMessage(callback, tweener)
        else
            tweener.gameObject:SendMessage(callback, tweener)
        end
    end
end


-- called from Daneel.Update()
function Daneel.Tween.Update()
    for id, tweener in pairs(Daneel.Tween.Tweener.tweeners) do
        if tweener.isEnabled == true and tweener.isPaused ~= true and tweener.isCompleted ~= true then

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
                            tweener.startValue = tweener.target[tweener.property]
                        else
                            error("ERROR : startValue is nil by not target is set")
                        end
                    elseif tweener.target ~= nil then
                        -- when start value and a target are set move the target to startValue before updating the tweener
                        tweener.target[tweener.property] = tweener.startValue
                    end
                    tweener.value = tweener.startValue

                    if tweener.isRelative == true then
                        tweener.diffValue = tweener.endValue
                    else
                        tweener.diffValue = tweener.endValue - tweener.startValue
                    end

                    Callback(tweener, tweener.OnStart)
                end
                
                -- update the tweener
                local newValue = nil

                tweener.elapsed = tweener.elapsed + deltaDuration
                tweener.fullElapsed = tweener.fullElapsed + deltaDuration

                if tweener.elapsed > tweener.duration then
                    tweener.isCompleted = true
                    tweener.elapsed = tweener.duration
                    if tweener.isRelative == true then
                        newValue = tweener.startValue + tweener.endValue
                    else
                        newValue = tweener.endValue
                    end
                
                else
                    if Daneel.Tween.Ease[tweener.easeType] == nil then
                        if DEBUG == true then
                            print("Daneel.Tween.Update() : Easing '"..tostring(tweener.easeType).."' for tweener ID '"..tween.id.."' does not exists. Setting it back for the default easing '"..config.tween.defaultTweenerParams.."'.")
                        end
                        tweener.easeType = config.tween.defaultTweenerParams.easeType
                    end
                    newValue = Daneel.Tween.Ease[tweener.easeType](tweener.elapsed, tweener.startValue, tweener.diffValue, tweener.duration)
                end

                if tweener.target ~= nil then
                    tweener.target[tweener.property] = newValue
                end
                tweener.value = newValue

                Callback(tweener, tweener.OnUpdate)
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
                        tweener.target[tweener.property] = tweener.startValue
                    end

                    tweener.value = tweener.startValue

                else
                    Callback(tweener, tweener.OnComplete)
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
Daneel.Tween.Tweener.__tostring = function(tweener)
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
    Callback(tweener, tweener.OnPlay)
end

function Daneel.Tween.Tweener.Pause(tweener)
    if tweener.isEnabled == false then return end
    tweener.isPaused = true
    Callback(tweener, tweener.OnPause)
end

function Daneel.Tween.Tweener.Complete(tweener)
    if tweener.isEnabled == false then return end
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
        tweener.target[tweener.property] = endValue
    end
    tweener.value = endValue
    Callback(tweener, tweener.OnComplete)
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
        tweener.target[tweener.property] = startValue
    end
    tweener.value = startValue
end

function Daneel.Tween.Tweener.Destroy(tweener)
    if tweener.isEnabled == false then return end
    tweener.isEnabled = false
    Daneel.Tween.Tweener.tweeners[tweener.id] = nil
end





----------------------------------------------------------------------------------
-- Easing equation

 
Daneel.Tween.Ease = {}
-- filled with the easing equations from the "Lib/Easing" script in Daneel.Awake() 


----------------------------------------------------------------------------------
-- Sequences

Daneel.Tween.Sequence = { sequences = {} }
Daneel.Tween.Sequence.__index = Daneel.Tween.Sequence

function Daneel.Tween.Sequence.New()
    local sequence = {}
    setmetatable(sequence, Daneel.Tween.Sequence)

    table.insert(Daneel.Tween.Sequence.sequences, sequence)
    return sequence
end

function Daneel.Tween.Sequence.Insert(tweenOrSequence, place)
    if place ~= nil then
        table.insert(Daneel.Tween.Sequence.sequences, place, tweenOrSequence)
    else
        table.insert(Daneel.Tween.Sequence.sequences, tweenOrSequence)
    end
end