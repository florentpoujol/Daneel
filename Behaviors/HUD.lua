-- Last modified for :
-- version 1.2.0
-- released 29th July 2013

-- Behavior for Daneel.GUI.Hud component.
-- Only add to a gameObject while in the scene editor.

-- Public properties :
-- positionX (string) [default=""]
-- positionY (string) [default=""]
-- localPositionX (string) [default=""]
-- localPositionY (string) [default=""]
-- layer (string) [default=""]
-- localLayer (string) [default=""]

function Behavior:Awake()
	if self.gameObject.hud == nil then
		local params = {}
		if self.positionX ~= "" and self.positionY ~= "" then
			params.position = Vector2.New(tonumber(self.positionX), tonumber(self.positionY))
		end
		if self.localPositionX ~= "" and self.localPositionY ~= "" then
			params.localPosition = Vector2.New(tonumber(self.localPositionX), tonumber(self.localPositionY))
		end
		if self.layer ~= "" then
			params.layer = tonumber(self.layer)
		end
		if self.localLayer ~= "" then
			params.localLayer = tonumber(self.localLayer)
		end

		-- allow the gameObject to stay at the same position than defined in the scene
		local position, layer = Daneel.GUI.Hud.ToHudPosition(self.gameObject.transform.position)
		if params.position == nil and params.localPosition == nil then
			params.position = position
		end
		if params.layer == nil and params.localLayer == nil then
			params.layer = layer
		end

		self.gameObject:AddComponent("Hud", params)
	end
end
