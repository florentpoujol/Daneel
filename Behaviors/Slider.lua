

-- when the handle is dragged
function Behavior:OnDrag()
	-- prendre la position de la souris
	-- = position 2D du handle

	-- cnvertir en position 3D le long du path


	-- delta donne la variation en pixel
	self.gameObject.hud.position = CraftStudio.Input.GetMousePosition()

end
