
GUI = {}

-- position à l'écran
-- éloignement ou scale
function printScreen(text)
    text = text:totable()
    local hudCameraName = Danel.config.hudCameraName
    local textMap = Asset.GetMap(Daneel.config.textMapName)
    local hudCam = CraftStudio.FindGameObject(hudCameraName)


    for i = 1, text do
        -- built a game Object parented to the hud camera
        local go = GameObject.New(text[i], {parent = hudCameraName})
        
    end 
end

GUI.print = printScreen


    local textMap = Asset.GetMap(Daneel.config.textMapName)
    local hudCam = CraftStudio.FindGameObject(hudCameraName)
    
    local go = CraftStudio.CreateGameObject("text", hudCam)
    local mapRnd = go:CreateComponent("MapRenderer")
    mapRnd:SetMap(hudMap)
    
    go.transform:SetLocalPosition(Vector3:New(0,0,-5))
    
    hudMap:SetBlockAt(0, 0, 0, 1, Map.BlockOrientation.North)
    hudMap:SetBlockAt(1, 0, 0, 2, Map.BlockOrientation.North)
    hudMap:SetBlockAt(2, 0, 0, 3, Map.BlockOrientation.North)


GUIText = {}

-- position
-- text
-- scale
function GUIText.New(params, g)
    local mt = {}
    mt.__index = GUIText

    guiText = {
        position = { x = 0, y = 0 },
        text = "",
        scale = 1,
        gameObject = GameObject.New("GUIText", {parent = hudCameraName})
    }

    return setmetatable(guiText, mt)
end

-- setposition
-- settext
-- setscale

function GUIText:SetPosition()

end
function GUIText:GetPosition()
    return self.position
end


function GUIText:SetText(text)
    for i = 1, text:len() do
        hudMap:SetBlockAt(i, 0, 0, text:byte(i), Map.BlockOrientation.North)
    end
end
function GUIText:GetText()
    return self.text
end


function GUIText:SetScale()

end
function GUIText:GetScale()
    return self.scale
end


function GUIText:GetGameObject()
    return self.gameObject
end
