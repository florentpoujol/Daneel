
-- Behavior for Daneel.GUI.Hud component.
-- Only add to a gameObject while in the scene editor.

-- Public properties :
-- positionX (number) [default=-1]
-- positionY (number) [default=-1]
-- localPositionX (number) [default=-1]
-- localPositionY (number) [default=-1]
-- layer (number) [default=-1]
-- localLayer (number) [default=-1]

function Behavior:Start()
	if self.gameObject.checkBox == nil then
		local params = {}
		if self.positionX >= 0 and self.positionY >= 0 then
			params.position = Vector2.New(self.positionX, self.positionY)
		end
		if self.localPositionX >= 0 and self.localPositionY >= 0 then
			params.localPosition = Vector2.New(self.localPositionX, self.localPositionY)
		end
		if self.layer >= 0  then
			params.layer = self.layer
		end
		if self.localLayer >= 0  then
			params.localLayer = self.localLayer
		end

		self.gameObject:AddComponent("CheckBox", params)
	end
end
