Event = { events = {} }

-- Make the specified function listen to the specified event.
-- The function will be called whenever the specified event will be fired.
-- @param eventName The event name
-- @param _function The function, not the function name
function Event.Listen(eventName, _function, g) -- g for garbage
    if eventName == Event then -- when users call the function with a colon, script = EventName, eventName = script, ...
        eventName = func
        func = g
    end

    local errorHead = "Event.Listen(eventName, function) : "
    
    local varType = type(eventName)
    if eventName == nil or type(eventName) ~= "string" then
        error(errorHead .. "Argument 'eventName' is of type '" .. varType .. "' instead of 'string'. Must be the event name.")
    end

    local varType = type(_function)
    if _function == nil or type(func) ~= "function" then
        error(errorHead .. "Argument '_function' is of type '" .. varType .. "' instead of 'function'. Must be the function, not the function name.")
    end

    if Event.events[eventName] == nil then
        Event.events[eventName] = {}
    end

    table.insert(Event.events[eventName], _function)
end
-- TODO check if a global function, registered several times for the same event is called several times

-- Make the specified function to stop listen to the specified event.
-- @param eventName The event name
-- @param _function The function, not the function name
function Event.StopListen(eventName, _function, g)
    if eventName == Event then
        eventName = func
        func = g
    end

    local errorHead = "Event.StopListen(eventName, function) : "
    
    local varType = type(eventName)
    if eventName == nil or type(eventName) ~= "string" then
        error(errorHead .. "Argument 'eventName' is of type '" .. varType .. "' instead of 'string'. Must be the event name.")
    end

    local varType = type(_function)
    if _function == nil or type(func) ~= "function" then
        error(errorHead .. "Argument '_function' is of type '" .. varType .. "' instead of 'function'. Must be the function, not the function name.")
    end

    --

    for i, storedFunc in ipairs(Event.events[eventName]) do
        if func == storedFunc then
            table.remove(Event.events[eventName], i)
        end
    end
end

-- Fire the specified event transmitting along all subsequent parameters to 'eventName' if some exists. 
-- All functions that listen to this event with Event.Listen() will be called and receive all parameters.
-- @param eventName The event name
-- @param ... (optionnal) a list of parameters to pass along
function Event.Fire(eventName, ...)
    if eventName == Event then
        if arg ~= nill then
            eventName = arg[1]
            table.remove(arg, 1)
        else
            eventName = nil
        end
    end
    
    local varType = type(eventName)
    if eventName == nil or type(eventName) ~= "string" then
        error("Event.Fire(eventName[, parameters]) : Argument 'eventName' is of type '" .. varType .. "' instead of 'string'. Must be the event name.")
    end
    
    if Event.events[eventName] == nil then return end
    
    for i, func in ipairs(Event.events[eventName]) do
        func(unpack(arg))
    end
end
-- TODO check proper arguments passing with behavior functions
