
if Daneel == nil then
    Daneel = {}
end

Daneel.Events = { events = {} }

-- Make the specified function listen to the specified event.
-- The function will be called whenever the specified event will be fired.
-- @param eventName (string) The event name.
-- @param _function (function, string or GameObject) The function or the gameObject name or instance.
-- @param functionName [optional default="On[eventName]"] (string) If '_function' is a gameObject name or instance, the name of the function to send the message to
-- @param broadcast [optional default=false] (boolean) If '_function' is a gameObject name or instance, broadcast the message to all the gameObject's childrens
function Daneel.Events.Listen(eventName, _function, functionName, broadcast)
    Daneel.StackTrace.BeginFunction("Daneel.Events.Listen", eventName, _function)
    local errorHead = "Daneel.Events.Listen(eventName, function) : "
    Daneel.Debug.CheckArgType(eventName, "eventName", "string", errorHead)

    if Daneel.Events.events[eventName] == nil then
        Daneel.Events.events[eventName] = {}
    end

    local functionType = type(_function)
    if functionType == "function" then
        table.insert(Daneel.Events.events[eventName], _function)
    else
        Daneel.Debug.CheckArgType(_function, "_function", {"string", "GameObject"}, errorHead)
        Daneel.Debug.CheckOptionalArgType(functionName, "functionName", "string", errorHead)
        Daneel.Debug.CheckOptionalArgType(broadcast, "broadcast", "boolean", errorHead)

        local gameObject = _function
        if functionType == "string" then
            gameObject = GameObject.Find(_function)
            if gameObject == nil then
                Daneel.Debug.PrintError(errorHead.."Argument '_function' : gameObject with name '".._function.."' was not found in the scene.")
            end
        end

        if functionName == nil then
            functionName = "On"..eventName
        end

        if broadcast == nil then
            broadcast = false
        end

        table.insert(Daneel.Events.events[eventName], {
            gameObject = gameObject,
            functionName = functionName,
            broadcast = broadcast
        })
    end

    Daneel.StackTrace.EndFunction("Daneel.Events.Listen")
end
-- TODO check if a global function, registered several times for the same event is called several times

-- Make the specified function to stop listen to the specified event.
-- @param eventName (string) The event name.
-- @param functionOrGameObject (function, string or GameObject) The function, or the gameObject name or instance.
function Daneel.Events.StopListen(eventName, functionOrGameObject)
    Daneel.StackTrace.BeginFunction("Daneel.Events.StopListen", eventName, functionOrGameObject)
    local errorHead = "Daneel.Events.StopListen(eventName, functionOrGameObject) : "
    Daneel.Debug.CheckArgType(eventName, "eventName", "string", errorHead)
    
    local functionType = type(functionOrGameObject)
    if functionType == "function" then
        for i, storedFunc in ipairs(Daneel.Events.events[eventName]) do
            if functionOrGameObject == storedFunc then
                table.remove(Daneel.Events.events[eventName], i)
                break
            end
        end
    else
        local gameObject = functionOrGameObject
        if functionType == "string" then
            gameObject = GameObject.Find(functionOrGameObject)
            if gameObject == nil then
                Daneel.Debug.PrintError(errorHead.."Argument 'functionOrGameObject' : gameObject with name '".._function.."' was not found in the scene.")
            end
        end
        
        for i, storedFunc in ipairs(Daneel.Events.events[eventName]) do
            if gameObject == storedFunc.gameObject then
                table.remove(Daneel.Events.events[eventName], i)
                break
            end
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
        arg = {}
    else
        Daneel.StackTrace.BeginFunction("Daneel.Events.Fire", eventName, unpack(arg))
    end
    
    Daneel.Debug.CheckArgType(eventName, "eventName", "string", "Daneel.Events.Fire(eventName[, parameters]) : ")
    
    if Daneel.Events.events[eventName] == nil then 
        Daneel.StackTrace.EndFunction("Daneel.Events.Fire")
        return
    end
    
    for i, func in ipairs(Daneel.Events.events[eventName]) do
        local functionType = type(func)
        if functionType == "function" then
            func(unpack(arg))
        elseif functionType == "table" then
            if func.gameObject ~= nil then
                if func.broadcast then
                    gameObject:BroadcastMessage(func.functionName, arg)
                else
                    gameObject:SendMessage(func.functionName, arg)
                end
            else
                table.remove(Daneel.Events.events[eventName], i)
            end
        else
            -- func is nil (a priori), function has been destroyed (probably was a public function on a destroyed ScriptedBehavior)
            table.remove(Daneel.Events.events[eventName], i)
        end
    end

    Daneel.StackTrace.EndFunction("Daneel.Events.Fire")
end
-- TODO check proper arguments passing with behavior functions

