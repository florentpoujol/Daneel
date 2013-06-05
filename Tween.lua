
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

Daneel.Tween.__index = Daneel.Tween
Daneel.Tween.__tostring = function(tween)
    return "Tween id:'"..tween.id.."'"
end


local function Callback(tween, callback, ...)
    if arg == nil then arg = {} end
    local callbackType = type(callback)
    
    if callbackType == "function" then
        callback(tween, unpack(arg))
    
    elseif callbackType == "string" and tween.gameObject ~= nil then
        arg.tween = tween
        if tween.broadcastCallbacks == true then
            gameObject:BroadcastMessage(callback, arg)
        else
            gameObject:SendMessage(callback, arg)
        end
    end
end


-- called from Daneel.Update()
function Daneel.Tween.Update()
    for id, tweener in pairs(Daneel.Tween.Tweener.tweeners) do
        if tweener.isEnabled == true and tweener.isPaused ~= true and tweener.isCompleted ~= true then

            local deltaDuration = Daneel.Time.deltaTime
            if tweener.durationType == "RealTime" then
                deltaDuration = Daneel.Time.realDeltaTime
            elseif tweener.durationType == "Frame" then
                deltaDuration = 1
            end


            if tweener.delay <= 0 then
                -- no more delay before starting the tweener, update the tweener
                
                if tweener.hasStarted == false then
                    -- firt loop for this tweener
                    tweener.hasStarted = true

                    if tweener.startValue == nil then
                        tweener.startValue = tweener.target[tweener.property]
                    else
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
                if tweener.elapsed > tweener.duration then
                    tweener.isCompleted = true
                    tweener.elapsed = tweener.duration
                    newValue = tweener.endValue
                
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

                Callback(tweener, tweener.OnUpdate, newValue)
            else
                tweener.delay = tweener.delay - deltaDuration
            end -- end if tweener.delay <= 0

            if tweener.isCompleted == true then
                Callback(tweener, tweener.OnComplete)

                -- set loop if any

                tweener:Destroy()
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
    local tweener = config.tween.defaultTweenerParams
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
    -- faire avancer valeur au bout
    tweener.target[tweener.property] = tweener.endValue
    Callback(tweener, tweener.OnComplete)
end

function Daneel.Tween.Tweener.Restart(tweener)
    if tweener.isEnabled == false then return end
    tweener.elapsed = 0
    tweener.fullElapsed = 0
    tweener.isCompleted = false
    tweener.hasStarted = false
    tweener.position = 0
    -- faire revenir la valeur au début
    tweener.target[tweener.property] = tweener.startValue
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