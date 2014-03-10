-- CircleRenderer.lua
-- Scripted behavior for Draw.CircleRenderer component.
--
-- Last modified for v1.4.0
-- Copyright © 2013-2014 Florent POUJOL, published under the MIT license.

--[[PublicProperties
segmentCount number 6
radius number 1
width number 1
/PublicProperties]]

function Behavior:Awake()
    local model = nil
    if self.gameObject.modelRenderer then
        model = self.gameObject.modelRenderer:GetModel()
        self.gameObject.modelRenderer:SetOpacity( 0 )
    end
    if self.gameObject.circleRenderer == nil then
        Draw.CircleRenderer.New( self.gameObject, {
            segmentCount = self.segmentCount,
            radius = self.radius,
            width = self.width,
            model = model,
        } )
    end
end
