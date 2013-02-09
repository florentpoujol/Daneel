

local rayCallSyntaxError = "Function not called from a Ray. Your must use a colon ( : ) between the Ray instance and the method name. Ie : ray:"


-- list of castable gameObjects  that are checked for collision with a ray by Ray:Cast()
Ray.catablesGameObjects = table.new()

-- Add a gameObject to the castableGameObject list.
-- @param gameObject (GameObject) The gameObject to ass to the list.
function Ray.RegisterCastableGameObject(gameObject, g)
    if gameObject == Ray then
        gameObject = g
    end

    local errorHead = "Ray.RegisterCastableGameObject(gameObject) : "

    local argType = type(GameObject)
    if argType ~= "GameObject" then
        error(errorHead.."Argument 'gameObject' is of type '"..argType.."' with value '"..tostring(gameObject).."' instead of 'GameObject'.")
    end

    Ray.catablesGameObjects:insert(gameObject)
end


-- check the collision of the ray against all castable gameObject
-- @return (table) The table of RaycastHits (will be empty if the ray didn't intersects anything)
function Ray:Cast()
    local errorHead = "Ray:Cast() : "

    local argType = type(self)
    if argType ~= "Ray" then
        error(errorHead..rayCallSyntaxError.."Cast()")
    end

    local hits = table.new()

    for i, gameObject in ipairs(Ray.catablesGameObjects) do
        local distance, normal, hitBlockLocation, adjacentBlockLocation = ray:IntersectsGameObject(gameObject)

        if distance ~= nil then
            hits:insert(RaycastHit.New(distance, normal, hitBlockLocation, adjacentBlockLocation, gameObject))
        end
    end

    return hits
end


-- check if the ray intersect the specified gameObject
-- @param gameObject (string or GameObject) The gameObject name or instance
function Ray:IntersectsGameObject(gameObject)
    local errorHead = "Ray:IntersectsGameObject(gameObject) : "

    local argType = type(self)
    if argType ~= "Ray" then
        error(errorHead..rayCallSyntaxError.."Cast()")
    end

    local component = gameObject:GetComponent("ModelRenderer")
    if component ~= nil then
        return self:IntersectsModelRenderer(component)
    end

    component = gameObject:GetComponent("MapRenderer")
    if component ~= nil then
        return self:IntersectsMapRenderer(component)
    end
end


----------------------------------------------------------------------------------
-- RaycastHit
-- keys : distance, normal, hitBlockLocation, adjacentBlockLocation, gameObject, component

RaycastHit = {}
RaycastHit.__index = RaycastHit
RaycastHit.__tostring = function() return "RaycastHit" end

function RaycastHit.New(distance, normal, hitBlockLocation, adjacentBlockLocation, gameObject)
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

    return raycastHit
end


