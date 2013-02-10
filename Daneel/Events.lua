
if Daneel == nil then Daneel = {} end

Daneel.Events = { events = {} }

-- Make the specified function listen to the specified event.
-- The function will be called whenever the specified event will be fired.
-- @param eventName (string) The event name.
-- @param _function (function) The function, not the function name.
function Daneel.Events.Listen(eventName, _function, g) -- g for garbage
    if eventName == Daneel.Events then 
        eventName = func
        func = g
    end

    local errorHead = "Daneel.Events.Listen(eventName, function) : "
    
    local varType = type(eventName)
    if eventName == nil or varType ~= "string" then
        error(errorHead .. "Argument 'eventName' is of type '" .. varType .. "' instead of 'string'. Must be the event name.")
    end

    local varType = type(_function)
    if _function == nil or type(func) ~= "function" then
        error(errorHead .. "Argument 'function' is of type '" .. varType .. "' instead of 'function'. Must be the function, not the function name.")
    end

    if Daneel.Events.events[eventName] == nil then
        Daneel.Events.events[eventName] = {}
    end

    table.insert(Daneel.Events.events[eventName], _function)
end
-- TODO check if a global function, registered several times for the same event is called several times

-- Make the specified function to stop listen to the specified event.
-- @param eventName (string) The event name.
-- @param _function (function) The function, not the function name.
function Daneel.Events.StopListen(eventName, _function, g)
    if eventName == Daneel.Events then
        eventName = func
        func = g
    end

    local errorHead = "Daneel.Events.StopListen(eventName, function) : "
    
    local varType = type(eventName)
    if eventName == nil or type(eventName) ~= "string" then
        error(errorHead .. "Argument 'eventName' is of type '" .. varType .. "' instead of 'string'. Must be the event name.")
    end

    local varType = type(_function)
    if _function == nil or type(func) ~= "function" then
        error(errorHead .. "Argument '_function' is of type '" .. varType .. "' instead of 'function'. Must be the function, not the function name.")
    end

    --

    for i, storedFunc in ipairs(Daneel.Events.events[eventName]) do
        if func == storedFunc then
            table.remove(Daneel.Events.events[eventName], i)
        end
    end
end

-- Fire the specified event transmitting along all subsequent parameters to 'eventName' if some exists. 
-- All functions that listen to this event with Daneel.Events.Listen() will be called and receive all parameters.
-- @param eventName (string) The event name.
-- @param ... [optionnal] a list of parameters to pass along.
function Daneel.Events.Fire(eventName, ...)
    if eventName == Daneel.Events then
        if arg ~= nill then
            eventName = arg[1]
            table.remove(arg, 1)
        else
            eventName = nil
        end
    end
    
    local varType = type(eventName)
    if eventName == nil or type(eventName) ~= "string" then
        error("Daneel.Events.Fire(eventName[, parameters]) : Argument 'eventName' is of type '" .. varType .. "' instead of 'string'. Must be the event name.")
    end
    
    if Daneel.Events.events[eventName] == nil then return end
    
    for i, func in ipairs(Daneel.Events.events[eventName]) do
        func(unpack(arg))
    end
end
-- TODO check proper arguments passing with behavior functions
