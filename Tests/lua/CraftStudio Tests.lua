function Behavior:Awake()
    local r = nil
    print( "~~~~~ Asset ~~~~~" )
       
    r = Asset.Get( "whatever" )
    if r ~= nil then
        print( "Asset.Get 1", r )
    end
    
    r = Asset.Get( "Scene1", "sCeNe" )
    if r ~= CS.FindAsset( "Scene1" ) then
        print( "Asset.Get 2", r )
    end

    local daneelScriptPath = "Daneel v1.5.0/Daneel"
    local script = CS.FindAsset( daneelScriptPath, "Script" )
    local daneelScriptName = script.name

    r = Asset.Get( daneelScriptPath )
    if r ~= script then
        print( "Asset.Get 3", r )
    end

    r = Asset.Get( script )
    if r ~= script then
        print( "Asset.Get 4", r )
    end 
    
    r = script:GetPath()
    if r ~= daneelScriptPath then
        print( "Asset.GetPath 1", r )
    end

    r = script:GetName()
    if r ~= daneelScriptName then
        print( "Asset.GetName 1", r )
    end

    r = script.name
    if r ~= daneelScriptName then
        print( "Asset.GetName 2", r )
    end

    -----
    print( "~~~~~ Component ~~~~~" )
    r = self.gameObject.transform:GetId()
    if type( r ) ~= "number" then
        print( "Component.GetId 1", r )
    end
    if self.gameObject.transform.id == nil then
        print( "Component.GetId 2" )
    end
    
    -----
    print( "~~~~~ Transform ~~~~~" )
    local go = GameObject.Get( "LocalScale" )
    local child = GameObject.Get( "LocalScale.LocalScaleChild" )
    
    go.transform.localScale = 0.1
    child.transform.scale = 0.15
    
    -- expected value :   go :"0.1 0.1"   child "1.5 0.2"
    go.textRenderer.text = math.round( go.transform.localScale.x, 1 ) .. " ".. math.round( go.transform.scale.x, 1 )
    child.textRenderer.text = math.round( child.transform.localScale.x, 1 ) .. " ".. math.round( child.transform.scale.x, 1 )
    
    --
    local worldGO = GameObject.Get("World")
    local localGO = GameObject.Get("World.Local")
    
    r = worldGO.transform:WorldToLocal( worldGO.transform.position )
    if r ~= Vector3(0) then
        print("transform:WorldToLocal 1", r, worldGO.transform.position)
    end
    
    r = worldGO.transform:WorldToLocal( localGO.transform.position ) -- Vector3(-8.5,0,-6)
    if r ~= localGO.transform.localPosition then
        print("transform:WorldToLocal 2", r, localGO.transform.position, localGO.transform.localPosition)
    end
    
    r = worldGO.transform:LocalToWorld( Vector3(0) )
    if r ~= worldGO.transform.position then
        print("transform:LocalToWorld 1", r, worldGO.transform.position)
    end
    
    r = worldGO.transform:LocalToWorld( localGO.transform.localPosition )
    if r ~= localGO.transform.position then
        print("transform:LocalToWorld 2", r, localGO.transform.position)
    end

    ------
    print( "~~~~~ ModelRenderer ~~~~~" )
    
    local go = GameObject("", { transform={ position = Vector3(2,0,-5) } } )
    
    go:AddComponent( "moDelRendeRer" )
    
    go.modelRenderer.model = "Model"
    r = go.modelRenderer.model
    if Daneel.Debug.GetType( r ) ~= "Model" or r:GetPath() ~= "Model" then
        print( "ModelRenderer.SetModel 1", r )
    end
    
    go.modelRenderer.model = nil
    --[[r = go.modelRenderer.model
    if r ~= nil then
        print( "ModelRenderer.SetModel 2", r )
    end
    ]]
    -- remove comment when getter won't throw error when asset is nil
    
    go.modelRenderer.animation = Asset.Get("ModelAnimationFolder/Animation")
    r = go.modelRenderer.animation
    if Daneel.Debug.GetType( r ) ~= "ModelAnimation" or r:GetPath() ~= "ModelAnimationFolder/Animation" then
        print( "ModelRenderer.SetAnimation 1", r )
    end
    
    go.modelRenderer.animation = nil
    --[[r = go.modelRenderer.animation
    if r ~= nil then
        print( "ModelRenderer.SetAnimation 2", r )
    end]]
    
    
    ------
    print( "~~~~~ MapRenderer ~~~~~" )
    --go.modelRenderer.model = nil
    
    go:AddComponent( "MApRendeRer" )
    
    go.mapRenderer.map = "Map"
    r = go.mapRenderer.map
    if Daneel.Debug.GetType( r ) ~= "Map" or r.path ~= "Map" then
        print( "MapRenderer.SetMap 1", r )
    end
    
    --go.mapRenderer.map = nil -- throws the error too 
    --[[r = go.mapRenderer.map
    if r ~= nil then
        print( "MapRenderer.SetMap 2", r )
    end]]
    
    
    go.mapRenderer.map = "Map"
    --go.mapRenderer.tileSet = "Tile Set1" -- FIXME : to be removed, the map should have its tile set
    
    r = go.mapRenderer.tileSet
    if Daneel.Debug.GetType( r ) ~= "TileSet" or r:GetPath() ~= "Tile Set1" then
        print( "MapRenderer.GetTileSet 1", r )
    end
    
    --go.mapRenderer.tileSet = nil -- throws error
    --[[r = go.mapRenderer.tileSet
    if r ~= nil then
        print( "MapRenderer.SetTileSet 2", r )
    end]]
        
    go.mapRenderer.tileSet = Asset.Get("Tile Set2", "tileset")
    r = go.mapRenderer.tileSet
    if Daneel.Debug.GetType( r ) ~= "TileSet" or r:GetPath() ~= "Tile Set2" then
        print( "MapRenderer.SetTileSet 3", r )
    end
    
    ------
    print( "~~~~~ TextRenderer ~~~~~" )
    
    go:CreateComponent( "TextRenderer" )
    
    go.textRenderer.font = CS.FindAsset("Calibri")
    r = go.textRenderer.font
    if Daneel.Debug.GetType( r ) ~= "Font" or r.path ~= "Calibri" then
        print( "TextRenderer.SetFont 1", r )
    end
    
    --go.textRenderer.font =  nil
    --[[r = go.textRenderer.font
    if r ~= nil then
        print( "textRenderer.SetFont 2", r )
    end
    ]] 
    
    go.textRenderer.alignment = "LeFt"
    r = go.textRenderer.alignment
    if r ~= TextRenderer.Alignment.Left then
        print( "TextRenderer.SetAlignment 1", r )
    end
    
    go.textRenderer.text = "  text width = 5 units"
    go.textRenderer.textWidth = 5
    -- this is a visual test, GetTextWidth() returns the width as if the GO had a scale of 1
    
    
    ------
    print( "~~~~~~ Camera ~~~~~~" )

    go = GameObject.Get( "Perspective Camera" )

    go.camera:Set({
        projectionMode = "orthographic"
    });
    if go.camera.projectionMode ~= Camera.ProjectionMode.Orthographic then
        print( "Camera.SetProjectionMode 1", go.camera.projectionMode )
    end
    go.camera:SetProjectionMode( "PersPecTive" )
    go.camera.fOV = 70
    
    
    ------
    print( "~~~~~ Ray ~~~~~" )
    
    local screenSize = CS.Screen.GetSize()
    if getmetatable( screenSize ) ~= Vector2 then
        -- issue with GUI module (not loaded)
        print( "CS.Screen.GetSize() dans script 'CS API Extension'" )
    end
    
    local cameraGO = GameObject.Get( "Perspective Camera" )
    local ray = cameraGO.camera:CreateRay( screenSize / 2 )
    -- Create ray return des vector3 buggés
    ray.position = cameraGO.transform.position
    ray.direction = Vector3(0,0,-1)
    --print("ray", ray)
    r = ray:IntersectsGameObject( cameraGO )
    if r ~= nil then
        print( "ray:IntersectsGameObject 1", r )
    end
    
    r = ray:IntersectsGameObject( "Perspective Camera.Test Ray.Model" )
    if r == nil then
        print( "ray:IntersectsGameObject 2", r )
    end
    
    go = GameObject.Get( "Perspective Camera.Test Ray.Model" )
    r = ray:IntersectsModelRenderer( go.modelRenderer )
    if type( r ) ~= "number" then
        print( "ray:IntersectsModelRenderer 1", r )
    end
    
    r = ray:IntersectsModelRenderer( go.modelRenderer, true )
    if Daneel.Debug.GetType( r ) ~= "RaycastHit" then
        print( "ray:IntersectsModelRenderer 2", r )
    end
    
    go = GameObject.Get( "Test Ray2.Model" )
    r = ray:IntersectsModelRenderer( go.modelRenderer, false )
    if r ~= nil then
        print( "ray:IntersectsModelRenderer 3", r )
    end
    
    --
    go = GameObject.Get( "Perspective Camera.Test Ray.Map" )
    r = ray:IntersectsMapRenderer( go.mapRenderer )
    if type( r ) ~= "number" then
        print( "ray:IntersectsMapRenderer 1", r )
    end
    
    r = ray:IntersectsMapRenderer( go.mapRenderer, true )
    if Daneel.Debug.GetType( r ) ~= "RaycastHit" then
        print( "ray:IntersectsMapRenderer 2", r )
    end
    
    go = GameObject.Get( "Test Ray2.Map" )
    r = ray:IntersectsMapRenderer( go.mapRenderer )
    if r ~= nil then
        print( "ray:IntersectsMapRenderer 3", r )
    end
    
    --
    go = GameObject.Get( "Perspective Camera.Test Ray.Text" )
    r = ray:IntersectsTextRenderer( go.textRenderer )
    if type( r ) ~= "number" then
        print( "ray:IntersectsTextRenderer 1", r )
    end
    
    r = ray:IntersectsTextRenderer( go.textRenderer, true )
    if Daneel.Debug.GetType( r ) ~= "RaycastHit" then
        print( "ray:IntersectsTextRenderer 2", r )
    end
    
    go = GameObject.Get( "Test Ray2.Text" )
    r = ray:IntersectsTextRenderer( go.textRenderer, true )
    if r ~= nil then
        print( "ray:IntersectsTextRenderer 3", r )
    end
    
    --

    local gos = {
        GameObject.Get( "Test Ray.Text" ),
        GameObject.Get( "Test Ray2.Model" ),
        GameObject.Get( "Test Ray2.Map" ),
        GameObject.Get( "Test Ray.Model" ),
        GameObject.Get( "Test Ray2.Text" ),
        GameObject.Get( "Test Ray.Map" ),
    }

    local hits = ray:Cast( gos )
    if #hits ~= 3 then
        print( "ray:Cast 1" )
        table.print( hits )
    end

    hits = ray:Cast( gos, true )
    if 
        (hits[1] == nil or hits[1].gameObject ~= GameObject.Get( "Test Ray.Model" )) or
        (hits[2] == nil or hits[2].gameObject ~= GameObject.Get( "Test Ray.Map" )) or
        (hits[3] == nil or hits[3].gameObject ~= GameObject.Get( "Test Ray.Text" ))
    then
        print( "ray:Cast 2" )
        table.print( hits )
    end
    
    
    --------
    -- Scene
    
    print( "~~~~~ Scene ~~~~~" )
    
    local go = Scene.Append( "Prefab" )
    go.transform.position = Vector3(0,-2,-5)
    if go == nil or go.name ~= "PrefabGameObject" then
        print( "Scene.Append 1", go )
    end
    
    local parent = GameObject.Get("LocalScaleChild")
    Scene.Append( "MultiPrefab", parent )
    
    if #parent.children ~= 2 then
        print( "Scene.Append 2" )
        table.print( parent.children )
    end
    
    
    --------
    -- OnDestroy

    self.goToDestroy = go
    go.OnDestroy = function()
        print( tostring(go) .. " is deing destroyed, that's OK" )
    end
    go:AddTag( "aTag" )
    Daneel.Event.Listen( "AnEvent", go )
    
    go:Destroy()


    --------------------------------------------------------------
    print("~~~~~ Storage ~~~~~")
    
    CS.Storage.Save( "Player Name", "Foo Bar", function(error) 
        if error ~= nil then
            print( "Storage.Save 1", error.message )
        end
    end )

    CS.Storage.Save( "Player Name", "John Doe", function(error) 
        if error ~= nil then
            print( "Storage.Save 2", error.message )
        end
    end )

    local data = { 42, foo = "bar" }
    CS.Storage.Save( "Some Data", data, function(error) 
        if error ~= nil then
            print( "Storage.Save 3", error.message )
        end
    end )

    CS.Storage.Load( "Player Name", "Florent", function( e, data )
        if data ~= "John Doe" then
            print( "Storage.Load 1" )
        end
    end )

    -- test default value
    CS.Storage.Load( "Player Name2", "Florent", function( e, data )
        if data ~= "Florent" then
            print( "Storage.Load 2" )
        end
    end )

    CS.Storage.Load( "Some Data", function( e, _data )
        if not table.havesamecontent( _data, data ) then
            print( "Storage.Load 3" )
            table.print( _data )
        end
    end )
    
    CS.Storage.Save( "Some Data", nil, function(error) 
        if error ~= nil then
            print( "Storage.Save 4", error.message )
        end
    end )

    CS.Storage.Load( "Some Data", nil, function( e, data ) 
        if e ~= nil or data ~= nil then
            print( "Storage.Load 4", e, data )
        end
    end )
    

    --------------------------------------------------------------------------------
    -- Game objects
    
    print("~~~~~~ GameObject ~~~~~~")

    r = GameObject( "NewGameObject", {
        transform = {
            position = Vector3(5)
        },

        modelRenderer = { 
            model = "Model",
            animation = "ModelAnimationFolder/Animation"
        },
        
        test = { test = "test" },

        parent = self.gameObject
    })
    
    if 
        r.name ~= "NewGameObject" or 
        r.transform.position ~= Vector3:New(5) or 
        r.modelRenderer.model ~= Asset("Model") or
        r.modelRenderer:GetAnimation().path ~= "ModelAnimationFolder/Animation" or
        r.parent.name ~= self.gameObject:GetName()
    then
        print( "GameObject.New 1", r )
    end
        
    r = GameObject.Instantiate( "NewGO", Asset("MultiPrefab") )
    
    if #r.children ~= 2 and r.children[2].name ~= "Object2" then
        print( "GameObject.Instanciate 1", r )
    end
    
    
    -- test scripted behavior
    go = GameObject.Get("Perspective Camera")
    local sb = go:GetScriptedBehavior( daneelScriptPath )
        
    r = go:GetScriptedBehavior( Asset( daneelScriptPath ) )
    if r ~= sb then 
        print( "GetScriptedBehavior 1", r )
    end
    
    -----

    r = go.id
    if type( r ) ~= "number" then
        print( "gameObject:GetId 1", r )
    end
    
    --
    go = GameObject.Get("Perspective Camera")
    r = go:GetChild( "Test Ray.Model" )
    if r ~= go.child.child then
        print("gameObject:GetChild 1", r )
    end
    
    r = go:GetChild( "Model", true )
    if r ~= go.child.child then
        print("gameObject:GetChild 2", r )
    end
    
    r = go:GetChild( "Test Ray.FooBar" )
    if r ~= nil then
        print("gameObject:GetChild 2", r )
    end
    
    --
    go = GameObject.Get( "Sliders" )
    r = go.children
    if #r ~= 3 then
        print("gameObject:GetChildren 1", r )
    end
    
    r = go:GetChildren( true ) -- recursive
    if #r ~= 12 then
        print("gameObject:GetChildren 2", r, #r )
        table.print( r )
    end
    
    r = go:GetChildren( true, true ) -- recursive + include self
    if #r ~= 13 then
        print("gameObject:GetChildren 3", r, #r )
        table.print( r )
    end
    
    
    -----
    local path = "Daneel v1.5.0/Tests/NewBehavior"
    
    -- go the the "Sliders"game object
    -- script asset
    r = false
    local c = go:AddComponent(Asset(path), {
        
        callback = function() r = true end
    } )
        
    if r == false then
        print( "gameObject:AddComponent 1", r )
    end
    
    -- script path
    r = false
    go:AddComponent( path, {
        callback = function() r = true end
    } )
    
    if r == false then
        print( "gameObject:AddComponent 2", r )
    end
    
    ---------
    -- get component
    
    r = go:GetComponent( "maprenderer" )
    if r ~= go.mapRenderer then
        print( "gameObject:GetComponent 1", r )
    end
    
    r = go:GetComponent( "phYsIcS" )
    if r ~= nil then
        print( "gameObject:GetComponent 2", r )
    end
    
    local sb = go:GetComponent( Asset(path) )
    if sb == nil then
        print( "gameObject:GetComponent 3", r )
    end
    
    r = go:GetComponent( path )
    if r ~= sb then
        print( "gameObject:GetComponent 4", r )
    end

    --
    local sb = go:GetScriptedBehavior( Asset.Get(path) )
    if sb == nil then
        print( "gameObject:GetScriptedBehavior 1", r )
    end
    
    r = go:GetScriptedBehavior( path )
    if r ~= sb then
        print( "gameObject:GetScriptedBehavior 2", r )
    end
    

    -----
    -- tags
    
    r = go:GetTags()
    if type( r ) ~= "table" or #r ~= 0 then
        print( "gameObject:GetTags 1", r )
    end

    go:AddTag( "Tag1" )
    go:AddTag( {"Tag1", "Tag2"} )

    r = go.tags
    if type( r ) ~= "table" or #r ~= 2 then
        print( "gameObject:AddTag 1", r )
    end

    go:RemoveTag( "Tag1" )
    r = go.tags
    if type( r ) ~= "table" or #r ~= 1 then
        print( "gameObject:RemoveTag 1", r )
    end

    go:RemoveTag( {"Tag1", "Tag2"} )
    r = go.tags
    if type( r ) ~= "table" or #r ~= 0 then
        print( "gameObject:RemoveTag 2", r )
    end

    ----
    r = go:HasTag( "whatever" )
    if r ~= false then
        print( "gameObject:HasTag 1", r )
    end

    go:AddTag( {"Tag1", "Tag2"} )

    r = go:HasTag( "Tag1" )
    if r ~= true then
        print( "gameObject:HasTag 2", r )
    end

    r = go:HasTag( {"Tag1", "whatever"}, true ) -- at least one tag
    if r ~= true then
        print( "gameObject:HasTag 2.5", r )
    end
    
    r = go:HasTag( {"Tag1", "whatever"}, false ) -- at least one tag
    if r ~= false then
        print( "gameObject:HasTag 2.6", r )
    end

    r = go:HasTag( {"Tag1", "Tag2"} )
    if r ~= true then
        print( "gameObject:HasTag 3", r )
    end

    r = go:HasTag( {"Tag1", "Tag2", "whatever"} )
    if r ~= false then
        print( "gameObject:HasTag 4", r )
    end

    --
    r = GameObject.GetWithTag( "whatever" )
    if type(r) ~= "table" or #r ~= 0 then
        print( "GameObject.GetWithTag 1", r )
        table.print( r )
    end

    r = GameObject.GetWithTag( "Tag1" )
    if type(r) ~= "table" or #r ~= 1 or r[1] ~= go then
        print( "GameObject.GetWithTag 2", r )
        table.print( r )
    end

    local go = GameObject.New( "", { tags = { "Tag1", "Tag2" } } )
    r = GameObject.GetWithTag( {"Tag1", "Tag2"} )
    if type(r) ~= "table" or #r ~= 2 then
        print( "GameObject.GetWithTag 3", r )
        table.print( r )
    end
    
end

local frameCount = 0
function Behavior:Update()
    frameCount = frameCount + 1
    if frameCount == 2 then
        print( "~~~~~ OnDestroy ~~~~~" )
    
        if 
            self.goToDestroy.transform ~= nil or
            self.goToDestroy.inner ~= nil or
            ( self.goToDestroy.inner ~= nil and self.goToDestroy:HasTag( "aTag" ) ) or
            table.containsvalue( Daneel.Event.events.AnEvent, self.goToDestroy )
        then
            print( "CS.Destroy", self.goToDestroy.transform, self.goToDestroy.inner, Daneel.Debug.GetType( self.goToDestroy ) )
            print( "has tag", self.goToDestroy:HasTag( "aTag" )  )
            print( "listen to event", table.containsvalue( Daneel.Event.events.AnEvent, self.goToDestroy ) )
            print( self.goToDestroy )
        end
        
        print( "~~~~~ End  OnDestroy ~~~~~" )
    end
end

