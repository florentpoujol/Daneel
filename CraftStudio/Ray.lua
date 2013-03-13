


-- Add a gameObject to the castableGameObject list.
-- @param gameObject (GameObject) The gameObject to add to the list.
function Ray.RegisterCastableGameObject(gameObject)
    Daneel.Debug.StackTrace.BeginFunction("Ray.RegisterCastableGameObject", gameObject)
    local errorHead = "Ray.RegisterCastableGameObject(gameObject) : "
    Daneel.Debug.CheckArgType(gameObject, "gameObject", "GameObject", errorHead)

    table.insert(Daneel.config.castableGameObjects, gameObject)
    Daneel.Debug.StackTrace.EndFunction("Ray.RegisterCastableGameObject")
end


-- check the collision of the ray against all castable gameObject
-- @param ray (Ray) The ray
-- @param gameObjects (table) [optional default=Daneel.config.castableGameObjects] The set of gameObjects to cast the ray against
-- @return (table) The table of RaycastHits (will be empty if the ray didn't intersects anything)
function Ray.Cast(ray, gameObjects)
    Daneel.Debug.StackTrace.BeginFunction("Ray.Cast", ray, gameObjects)
    local errorHead = "Ray.Cast(ray) : "
    Daneel.Debug.CheckArgType(ray, "ray", "Ray", errorHead)

    if gameObjects == nil then
        gameObjects = Daneel.config.castableGameObjects
    else
        gameObjects = Daneel.Debug.CheckArgType(gameObjects, "gameObjects", "table", errorHead)
    end

    local hits = table.new()

    for i, gameObject in ipairs(gameObjects) do
        local distance, normal, hitBlockLocation, adjacentBlockLocation = ray:IntersectsGameObject(gameObject)

        if distance ~= nil then
            hits:insert(RaycastHit.New(distance, normal, hitBlockLocation, adjacentBlockLocation, gameObject))
        end
    end

    Daneel.Debug.StackTrace.EndFunction("Ray.Cast", hits)
    return hits
end


-- check if the ray intersect the specified gameObject
-- @param ray (Ray) The ray
-- @param gameObject (GameObject) The gameObject instance
-- @return
function Ray.IntersectsGameObject(ray, gameObject)
    Daneel.Debug.StackTrace.BeginFunction("Ray.IntersectsGameObject", ray, gameObject)
    local errorHead = "Ray.IntersectsGameObject(ray, gameObject) : "
    Daneel.Debug.CheckArgType(ray, "ray", "Ray", errorHead)
    Daneel.Debug.CheckArgType(gameObject, "gameObject", "GameObject", errorHead)

    local component = gameObject:GetComponent("ModelRenderer")
    if component ~= nil then
        local distance, normal = ray:IntersectsModelRenderer(component)
        Daneel.Debug.StackTrace.EndFunction("Ray.IntersectsGameObject", distance, normal)
        return distance, normal
    end

    component = gameObject:GetComponent("MapRenderer")
    if component ~= nil then
        local distance, normal, hitBlockLocation, adjacentBlockLocation = ray:IntersectsMapRenderer(component)
        Daneel.Debug.StackTrace.EndFunction("Ray.IntersectsGameObject", distance, normal, hitBlockLocation, adjacentBlockLocation)
        return distance, normal, hitBlockLocation, adjacentBlockLocation
    end

    Daneel.Debug.StackTrace.EndFunction("Ray.IntersectsGameObject")
end


----------------------------------------------------------------------------------
-- RaycastHit
-- keys : distance, normal, hitBlockLocation, adjacentBlockLocation, gameObject, component

RaycastHit = {}
RaycastHit.__index = RaycastHit

function RaycastHit.__tostring() 
    return "RaycastHit"
end

function RaycastHit.New(distance, normal, hitBlockLocation, adjacentBlockLocation, gameObject)
    Daneel.Debug.StackTrace.BeginFunction("RaycastHit.New", distance, normal, hitBlockLocation, adjacentBlockLocation, gameObject)

    local raycastHit = table.new({
        distance = distance,
        normal = normal,
        hitBlockLocation = hitBlockLocation,
        adjacentBlockLocation = adjacentBlockLocation,
        gameObject = gameObject,
    })

    if raycastHit.hitBlockLocation ~= nil then
        raycastHit.component = "MapRenderer"
    else
        raycastHit.component = "ModelRenderer"
    end

    Daneel.Debug.StackTrace.EndFunction("RaycastHit.New", raycastHit)
    return raycastHit
end

