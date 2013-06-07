
-- for interactions between the mouse and the element

function Behavior:Start()
	if not table.containsvalue(config.mouseInteractiveGameObjects, self.gameObject) then
    	table.insert(config.mouseInteractiveGameObjects, self.gameObject)
    end
end
