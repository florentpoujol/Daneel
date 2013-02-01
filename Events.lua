Event = { events = {} }

--
-- Register the specified function to be called whenever the specified event will be fired.
--
function Event.Listen(eventName, func, g) -- g for garbage
    if eventName == Event then -- when users call the function with a colon, script = EventName, eventName = script, ...
        eventName = func
        func = g
    end
    
    if eventName == nil or type(eventName) ~= "string" then
        error("Event.Listen(eventName, function) : Argument 'eventName' is nil or not a string. Must be the event name.")
    end

    if func == nil or type(func) ~= "function" then
        error("Event.Listen(eventName, function) : Argument 'function' is nil or not a function. Must be the function.")
    end

    if Event.events[eventName] == nil then
        Event.events[eventName] = {}
    end

    table.insert(Event.events[eventName], func)
end

--
-- Make a function to stop listen any event
--
function Event.StopListen(func, g)
    if func == Event then
        func = g
    end
    
    if func == nil or type(func) ~= "function" then
        error("Event.StopListen(function) : Argument 'function' is nil or not a function. Must be the function.")
    end

    for eventName, functions in pairs(Event.events) do
        for i, storedFunc in ipairs(functions) do
            if func == storedFunc then
                table.remove(Event.events[eventName], i)
            end
        end
    end
end

--
-- Fire the specified event transmitting along all subsequent parameters to 'eventName' if some exists. 
-- All functions that listen to this event with EventManager.Listen() will be called and receive all parameters.
--
function Event.Fire(eventName, ...)
    if eventName == Event then
        if arg ~= nill then
            eventName = arg[1]
            table.remove(arg, 1)
        else
            eventName = nil
        end
    end
    
    if eventName == nil or type(eventName) ~= "string" then
        error("Event.Fire(eventName[, parameters]) : Argument 'eventName' is nil or not a string. Must be the event name.")
    end
    
    if Event.events[eventName] == nil then return end
    
    for i, func in ipairs(Event.events[eventName]) do
        func(unpack(arg))
    end
end
