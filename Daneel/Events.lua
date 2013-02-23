
if Daneel == nil then
    Daneel = {}
end

Daneel.Events = { events = {} }

-- Make the specified function listen to the specified event.
-- The function will be called whenever the specified event will be fired.
-- @param eventName (string) The event name.
-- @param _function (function) The function, not the function name.
function Daneel.Events.Listen(eventName, _function) -- g for garbage
    Daneel.StackTrace.BeginFunction("Daneel.Events.Listen", eventName, _function)
    local errorHead = "Daneel.Events.Listen(eventName, function) : "
    Daneel.Debug.CheckArgType(eventName, "eventName", "string", errorHead)
    Daneel.Debug.CheckArgType(_function, "_function", "function", errorHead, "Must be the function, not the function name.")

    if Daneel.Events.events[eventName] == nil then
        Daneel.Events.events[eventName] = {}
    end

    table.insert(Daneel.Events.events[eventName], _function)
    Daneel.StackTrace.EndFunction("Daneel.Events.Listen")
end
-- TODO check if a global function, registered several times for the same event is called several times

-- Make the specified function to stop listen to the specified event.
-- @param eventName (string) The event name.
-- @param _function (function) The function, not the function name.
function Daneel.Events.StopListen(eventName, _function)
    Daneel.StackTrace.BeginFunction("Daneel.Events.StopListen", eventName, _function)
    local errorHead = "Daneel.Events.StopListen(eventName, function) : "
    Daneel.Debug.CheckArgType(eventName, "eventName", "string", errorHead)
    Daneel.Debug.CheckArgType(_function, "_function", "function", errorHead, "Must be the function, not the function name.")

    for i, storedFunc in ipairs(Daneel.Events.events[eventName]) do
        if func == storedFunc then
            table.remove(Daneel.Events.events[eventName], i)
        end
    end

    Daneel.StackTrace.EndFunction("Daneel.Events.StopListen")
end

-- Fire the specified event transmitting along all subsequent parameters to 'eventName' if some exists. 
-- All functions that listen to this event with Daneel.Events.Listen() will be called and receive all parameters.
-- @param eventName (string) The event name.
-- @param ... [optional] a list of parameters to pass along.
function Daneel.Events.Fire(eventName, ...)
    if arg == nil then
        Daneel.StackTrace.BeginFunction("Daneel.Events.Fire", eventName, nil)
    else
        Daneel.StackTrace.BeginFunction("Daneel.Events.Fire", eventName, unpack(arg))
    end
    
    Daneel.Debug.CheckArgType(eventName, "eventName", "string", "Daneel.Events.Fire(eventName[, parameters]) : ")
    
    if Daneel.Events.events[eventName] == nil then 
        Daneel.StackTrace.EndFunction("Daneel.Events.Fire")
        return
    end
    
    for i, func in ipairs(Daneel.Events.events[eventName]) do
        func(unpack(arg))
    end

    Daneel.StackTrace.EndFunction("Daneel.Events.Fire")
end
-- TODO check proper arguments passing with behavior functions

