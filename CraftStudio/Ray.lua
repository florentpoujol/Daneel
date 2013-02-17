

local rayCallSyntaxError = "Function not called from a Ray. Your must use a colon ( : ) between the Ray instance and the method name. Ie : ray:"


-- list of castable gameObjects  that are checked for collision with a ray by Ray:Cast()
Ray.catablesGameObjects = table.new()

-- Add a gameObject to the castableGameObject list.
-- @param gameObject (GameObject) The gameObject to add to the list.
function Ray.RegisterCastableGameObject(gameObject)
    Daneel.StackTrace.BeginFunction("Ray.RegisterCastableGameObject", gameObject)
    local errorHead = "Ray.RegisterCastableGameObject(gameObject) : "

    local argType = cstype(GameObject)
    if argType ~= "GameObject" then
        error(errorHead.."Argument 'gameObject' is of type '"..argType.."' with value '"..tostring(gameObject).."' instead of 'GameObject'.")
    end

    Ray.catablesGameObjects:insert(gameObject)
    Daneel.StackTrace.EndFunction("Ray.RegisterCastableGameObject")
end


-- check the collision of the ray against all castable gameObject
-- @param ray (Ray) The ray
-- @return (table) The table of RaycastHits (will be empty if the ray didn't intersects anything)
function Ray.Cast(ray)
    Daneel.StackTrace.BeginFunction("Ray.Cast", ray)
    local errorHead = "Ray.Cast(ray) : "

    local argType = cstype(ray)
    if argType ~= "Ray" then
        error(errorHead.."Argument 'ray' is of type '"..argType.."' with value '"..tostring(ray).."' instead of 'Ray'.")
        --error(errorHead..rayCallSyntaxError.."Cast()")
    end

    local hits = table.new()

    for i, gameObject in ipairs(Ray.catablesGameObjects) do
        local distance, normal, hitBlockLocation, adjacentBlockLocation = ray:IntersectsGameObject(gameObject)

        if distance ~= nil then
            hits:insert(RaycastHit.New(distance, normal, hitBlockLocation, adjacentBlockLocation, gameObject))
        end
    end

    Daneel.StackTrace.EndFunction("Ray.RegisterCastableGameObject", hits)
    return hits
end


-- check if the ray intersect the specified gameObject
-- @param ray (Ray) The ray
-- @param gameObject (GameObject) The gameObject instance
function Ray.IntersectsGameObject(ray, gameObject)
    Daneel.StackTrace.BeginFunction("Ray.IntersectsGameObject", ray, gameObject)
    local errorHead = "Ray.IntersectsGameObject(ray, gameObject) : "

    local argType = cstype(ray)
    if argType ~= "Ray" then
        error(errorHead.."Argument 'ray' is of type '"..argType.."' with value '"..tostring(ray).."' instead of 'Ray'.")
        --error(errorHead..rayCallSyntaxError.."Cast()")
    end

    local component = gameObject:GetComponent("ModelRenderer")
    if component ~= nil then
        local distance, normal = ray:IntersectsModelRenderer(component)
        Daneel.StackTrace.EndFunction("Ray.IntersectsGameObject", distance, normal)
        return distance, normal
    end

    component = gameObject:GetComponent("MapRenderer")
    if component ~= nil then
        local distance, normal, hitBlockLocation, adjacentBlockLocation = ray:IntersectsMapRenderer(component)
        Daneel.StackTrace.EndFunction("Ray.IntersectsGameObject", distance, normal, hitBlockLocation, adjacentBlockLocation)
        return distance, normal, hitBlockLocation, adjacentBlockLocation
    end
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
    Daneel.StackTrace.BeginFunction("RaycastHit.New", distance, normal, hitBlockLocation, adjacentBlockLocation, gameObject)

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

    Daneel.StackTrace.EndFunction("RaycastHit.New", raycastHit)
    return raycastHit
end

