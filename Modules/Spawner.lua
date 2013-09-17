-- Spawner.lua
-- Scripted behavior that spawn scenes.
--
-- Last modified for v1.3.0
-- Copyright © 2013 Florent POUJOL, published under the MIT licence.

--[[PublicProperties
scene string ""
spawnRate number 0
duration number 0
delay number 0
isPaused boolean  true
/PublicProperties]]

function Behavior:Awake()
    self.isCompleted = false
    self.elapsedDelay = 0
    self.elapsed = 0 -- elapsed time, delay excluded

    self.frameCount = 0
    self.lastTime = os.time()
end

function Behavior:Update()
    local currentTime = os.time()
    local deltaTime = currentTime - self.lastTime
    self.lastTime = currentTime
    
    if self.isPaused == false and self.isCompleted == false and self.duration ~= 0 then
        self.frameCount = self.frameCount + 1

        if self.elapsedDelay >= self.delay then
            self.elapsed = self.elapsed + deltaTime

            if self.duration > 0 and self.elapsed > self.duration then
                self.isComplete = true
            
            elseif self.frameCount % (60 / self.spawnRate) == 0 then
                self:Spawn()
            end
        else
            self.elapsedDelay = self.elapsedDelay + deltaTime
        end

    end
end

function Behavior:Spawn()
    if self.scene ~= nil then
        if type( self.scene ) == "string" then
            self.scene = CS.FindAsset( self.scene, "Scene" )
        end
        
        local gameObject = CS.AppendScene( self.scene )
        
        local selfPosition = self.gameObject.transform:GetPosition()
        if gameObject.physics ~= nil then
            gameObject.physics:WarpPosition( selfPosition )
        else
            gameObject.transform:SetPosition( selfPosition )
        end
    end
end
