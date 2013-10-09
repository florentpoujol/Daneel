function Behavior:Awake()
    local r = nil
    print( "~~~~~ Asset ~~~~~" )
    
    r = Asset.Get( "Daneel Core" )
    if r ~= nil then
        print( "Asset.Get 1", r )
    end
    
    r = Asset.Get( "Scene1", "sCeNe" )
    if r ~= CS.FindAsset( "Scene1" ) then
        print( "Asset.Get 2", r )
    end
    
    local script = CS.FindAsset( "Daneel/Daneel Core", "Script" )
    r = Asset.Get( "Daneel/Daneel Core" )
    if r ~= script then
        print( "Asset.Get 3", r )
    end
    
    r = Asset.Get( script )
    if r ~= script then
        print( "Asset.Get 4", r )
    end 
    
    r = script:GetPath()
    if r ~= "Daneel/Daneel Core" then
        print( "Asset.GetPath 1", r )
    end
    
    -----
    print( "~~~~~ Component ~~~~~" )
    r = self.gameObject.transform.id
    if type( r ) ~= "number" then
        print( "Component.GetId 1", r )
    end
    if self.gameObject.transform.Id == nil then
        print( "Component.GetId 2" )
    end
    
    -----
    print( "~~~~~ Transform Scale ~~~~~" )
    local go = GameObject.Get( "LocalScale" )
    local child = GameObject.Get( "LocalScale.LocalScaleChild" )
    
    go.transform.localScale = 0.1
    child.transform.scale = 0.15
    
    -- expected value :   go :"0.1 0.1"   child "1.5 0.2"
    go.textRenderer.text = math.round( go.transform.localScale.x, 1 ) .. " ".. math.round( go.transform.scale.x, 1 )
    child.textRenderer.text = math.round( child.transform.localScale.x, 1 ) .. " ".. math.round( child.transform.scale.x, 1 )
    
    
    ------
    print( "~~~~~ Ray ~~~~~" )
    
    local screenSize = CS.Screen.GetSize()
    if getmetatable( screenSize ) ~= Vector2 then
        -- issue with GUI module (not loaded)
        print( "CS.Screen.GetSize() dans script 'CS API Extension'" )
    end
    
    local cameraGO = GameObject.Get( "Daneel Core" )
    local ray = cameraGO.camera:CreateRay( screenSize / 2 )
    -- Create ray return des vector3 buggés
    ray.position = cameraGO.transform.position
    ray.direction = Vector3(0,0,-1)
    --print("ray", ray)
    r = ray:IntersectsGameObject( cameraGO )
    if r ~= nil then
        print( "ray:IntersectsGameObject 1", r )
    end
    
    r = ray:IntersectsGameObject( "Daneel Core.Test Ray.Model" )
    if r == nil then
        print( "ray:IntersectsGameObject 2", r )
    end
    
    go = GameObject.Get( "Daneel Core.Test Ray.Model" )
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
    go = GameObject.Get( "Daneel Core.Test Ray.Map" )
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
    go = GameObject.Get( "Daneel Core.Test Ray.Text" )
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
end


function Behavior:Start()
    --[[local screenSize = CS.Screen.GetSize()
    local go = GameObject.Get( "Daneel Core" )
    local ray = go.camera:CreateRay( screenSize / 2 )
    print("ray2", ray, screenSize, screenSize/2)]]
end
