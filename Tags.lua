-- Tags.lua
-- Scripted behavior to add tags to game objects while in the scene editor.
--
-- Last modified for v1.3.0
-- Copyright © 2013-2014 Florent POUJOL, published under the MIT license.


GameObject.Tags = {}
-- GameObject.Tags is emptied in Tag.Awake() below

local _go = { name = "gameObject", type = "GameObject" }
local _t = { name = "tag", type = {"string", "table"} }
local functionsDebugInfo = {}

functionsDebugInfo["GameObject.GetWithTag"] = { _t }
--- Returns the game object(s) that have all the provided tag(s).
-- @param tag (string or table) One or several tag(s) (as a string or table of strings).
-- @return (table) The game object(s) (empty if none is found).
function GameObject.GetWithTag( tag )
    local tags = tag
    if type( tags ) == "string" then
        tags = { tags }
    end

    local gameObjectsWithTag = {}
    local reindex = false

    for i, tag in pairs( tags ) do
        local gameObjects = GameObject.Tags[ tag ]
        if gameObjects ~= nil then
            for j, gameObject in pairs( gameObjects ) do
                if gameObject.inner ~= nil then
                    if gameObject:HasTag( tags ) and not table.containsvalue( gameObjectsWithTag, gameObject ) then
                        table.insert( gameObjectsWithTag, gameObject )
                    end
                else
                    gameObjects[ j ] = nil
                    reindex = true
                end
            end
            if reindex then
                GameObject.Tags[ tag ] = table.reindex( gameObjects )
                reindex = false
            end
        end
    end

    return gameObjectsWithTag
end

functionsDebugInfo["GameObject.GetTags"] = { _go }
--- Returns the tag(s) of the provided game object.
-- @param gameObject (GameObject) The game object.
-- @return (table) The tag(s) (empty if the game object has no tag).
function GameObject.GetTags( gameObject )
    local tags = {}
    for tag, gameObjects in pairs( GameObject.Tags ) do
        if table.containsvalue( gameObjects, gameObject ) then
            table.insert( tags, tag )
        end
    end
    return tags
end

functionsDebugInfo["GameObject.AddTag"] = { _go, _t }
--- Add the provided tag(s) to the provided game object.
-- @param gameObject (GameObject) The game object.
-- @param tag (string or table) One or several tag(s) (as a string or table of strings).
function GameObject.AddTag( gameObject, tag )
    local tags = tag
    if type( tags ) == "string" then
        tags = { tags }
    end

    for i, tag in pairs( tags ) do
        if GameObject.Tags[ tag ] == nil then
            GameObject.Tags[ tag ] = { gameObject }
        elseif not table.containsvalue( GameObject.Tags[ tag ], gameObject ) then
            table.insert( GameObject.Tags[ tag ], gameObject )
        end
    end
end

functionsDebugInfo["GameObject.RemoveTag"] = { _go, { name = "tag", type = {"string", "table"}, isOptional = true } }
--- Remove the provided tag(s) from the provided game object.
-- If the 'tag' argument is not provided, all tag of the game object will be removed.
-- @param gameObject (GameObject) The game object.
-- @param tag [optional] (string or table) One or several tag(s) (as a string or table of strings).
function GameObject.RemoveTag( gameObject, tag )
    local tags = tag
    if type( tags ) == "string" then
        tags = { tags }
    end

    for tag, gameObjects in pairs( GameObject.Tags ) do
        if tags == nil or table.containsvalue( tags, tag ) then
            table.removevalue( GameObject.Tags[ tag ], gameObject )
        end
    end
end

functionsDebugInfo["GameObject.HasTag"] = { _go, _t, { name = "atLeastOneTag", defaultValue = false } }
--- Tell whether the provided game object has all (or at least one of) the provided tag(s).
-- @param gameObject (GameObject) The game object.
-- @param tag (string or table) One or several tag (as a string or table of strings).
-- @param atLeastOneTag [default=false] (boolean) If true, returns true if the game object has AT LEAST one of the tag (instead of ALL the tag).
-- @return (boolean) True
function GameObject.HasTag( gameObject, tag, atLeastOneTag )
    local tags = tag
    if type(tags) == "string" then
        tags = { tags }
    end
    local hasTags = false
    if atLeastOneTag == true then
        for i, tag in pairs( tags ) do
            if GameObject.Tags[ tag ] ~= nil and table.containsvalue( GameObject.Tags[ tag ], gameObject ) then
                hasTags = true
                break
            end
        end
    else
        hasTags = true
        for i, tag in pairs( tags ) do
            if GameObject.Tags[ tag ] == nil or not table.containsvalue( GameObject.Tags[ tag ], gameObject ) then
                hasTags = false
                break
            end
        end
    end

    Daneel.Debug.StackTrace.EndFunction()
    return hasTags
end


----------------------------------------------------------------------------------
-- Config 

Daneel.modules.Tags = {
    DefaultConfig = {
        functionsDebugInfo = functionsDebugInfo
    },

    Awake = function()
        -- remove all dead game objects from GameObject.Tags
        if Daneel.isLateLoading then
            -- can't do GameObject.Tags = {} because of Daneel late loading, it would discard alive game objects that are already added as tags
            for tag, gameObjects in pairs( GameObject.Tags ) do
                for i, gameObject in pairs( gameObjects ) do
                    if gameObject.inner == nil then
                        gameObjects[i] = nil
                    end
                end
                
                GameObject.Tags[ tag ] = table.reindex( gameObjects )
            end
        else
            GameObject.Tags = {}
        end
    end
}


----------------------------------------------------------------------------------
-- Runtime

--[[PublicProperties
tags string ""
/PublicProperties]]

function Behavior:Awake()
    if self.tags ~= "" then
        local tags = string.split( self.tags, "," )
        self.gameObject:AddTag( tags )
    end
end
