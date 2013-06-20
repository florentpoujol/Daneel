

-- when the handle is dragged
function Behavior:OnDrag()
	
	local mousePos = CraftStudio.Input.GetMousePosition()
	local curHudPos = self.gameObject.hud.position
	local start =
	local size = self.gameObject.slider.length / Daneel.GUI.pixelsToUnits
	local percentage = self.gameObject.slider:GetValue(true)/100
	
	local start = _end

    self.gameObject.hud.position = Vector2(CraftStudio.Input.GetMousePosition().x, self.gameObject.hud.position.y)
    
    Daneel.Event.Fire(self.gameObject.slider, "OnUpdate")
end
