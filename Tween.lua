
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

local tweenId = 0

function Daneel.Tween.New(target, property, endValue, duration, params)
    local tween = config.tween.defaultTweenParams
    setmetatable(tween, Daneel.Tween)

    tweenId = tweenId + 1
    tween.id = tweenId

    -- three constructors :
    -- target, property, endvalue, duration[, params]
    -- startvalue, endvalue, duration[, params]
    -- params

    if type(target) == "number" then
        -- constructor n°2
        tween.startValue = target
        tween.endValue = property
        tween.duration = endValue
        if type(duration) == "table" then
            tween:Set(duration)
        end
    elseif property == nil then
        -- constructor n°3
        tween:Set(target)
    else
        -- constructor n°1
        tween.gameObject = target.gameObject -- if target is a component
        if tween.gameObject == nil and getmetatable(target) == GameObject then
            tween.gameObject = target
        end

        tween.target = target
        tween.property = property
        tween.endValue = endValue
        tween.duration = duration
        if type(params) == "table" then
            tween:Set(params)
        end
    end
    
    Daneel.Tween.tweens[tween.id] = tween
    return tween
end

function Daneel.Tween.Set(tween, params)
    for key, value in pairs(params) do
        tween[key] = value
    end
    return tween
end

function Daneel.Tween.Play(tween)
    if tween.enabled == false then return end
    tween.isPaused = false
    Callback(tween, tween.OnPlay)
end

function Daneel.Tween.Pause(tween)
    if tween.enabled == false then return end
    tween.isPaused = true
    Callback(tween, tween.OnPause)
end

function Daneel.Tween.Complete(tween)
    if tween.enabled == false then return end
    tween.isComplete = true
    -- faire avancer valeur au bout
    tween.target[tween.property] = tween.endValue
    Callback(tween, tween.OnComplete)
end

function Daneel.Tween.Restart(tween)
    if tween.enabled == false then return end
    tween.elapsed = 0
    tween.hasStarted = false
    tween.position = 0
    -- faire revenir la valeur au début
    tween.target[tween.property] = tween.startValue
end

function Daneel.Tween.Destroy(tween)
    if tween.enabled == false then return end
    tween.enabled = false
    Callback(tween, tween.OnDestroy)
end


-- called from Daneel.Update()
function Daneel.Tween.Update()
    for id, tween in pairs(Daneel.Tween.tweens) do
        if tween.enabled == true and tween.isPaused ~= true and tween.isComplete ~= true then

            local deltaDuration = Daneel.Time.deltaTime
            if tween.durationType == "RealTime" then
                deltaDuration = Daneel.Time.realDeltaTime
            elseif tween.durationType == "Frame" then
                deltaDuration = 1
            end


            if tween.delay <= 0 then
                -- no more delay before starting the tween, update the tween
                
                if tween.hasStarted == false then
                    -- firt loop for this tween
                    tween.hasStarted = true

                    if tween.startValue == nil then
                        tween.startValue = tween.target[tween.property]
                    else
                        -- when start value and a target are set move the target to startValue before updating the tween
                        tween.target[tween.property] = tween.startValue
                    end
                    tween.value = tween.startValue

                    if tween.isRelative == true then
                        tween.diffValue = tween.endValue
                    else
                        tween.diffValue = tween.endValue - tween.startValue
                    end

                    Callback(tween, tween.OnStart)
                end
                
                -- update the tween
                local newValue = nil

                tween.elapsed = tween.elapsed + deltaDuration
                if tween.elapsed > tween.duration then
                    tween.isComplete = true
                    tween.elapsed = tween.duration
                    newValue = tween.endValue
                
                else
                    if Daneel.Tween.Ease[tween.easeType] == nil then
                        if DEBUG == true then
                            print("Daneel.tween.Update() : Easing '"..tostring(tween.easeType).."' for tween ID '"..tween.id.."' does not exists. Setting it back for the default easing '"..config.tween.defaultTweenParams.."'.")
                        end
                        tween.easeType = config.tween.defaultTweenParams.easeType
                    end
                    newValue = Daneel.Tween.Ease[tween.easeType](tween.elapsed, tween.startValue, tween.diffValue, tween.duration)
                end

                if tween.target ~= nil then
                    tween.target[tween.property] = newValue
                end
                tween.value = newValue

                Callback(tween, tween.OnUpdate, newValue)
            else
                tween.delay = tween.delay - deltaDuration
            end -- end if tween.delay <= 0

            if tween.isComplete == true then
                Callback(tween, tween.OnComplete)

                -- set loop if any

                tween:Destroy()
            end
        end -- end if tween.enabled == true
    end -- end for tweens
end


----------------------------------------------------------------------------------
-- Easing equation

 
Daneel.Tween.Ease = {}
-- filled with the easing equations in Daneel.Awake


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