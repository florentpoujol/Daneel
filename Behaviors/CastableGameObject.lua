
function Behavior:Awake()
	if not table.containsvalue(config.castableGameObjects, self.gameObject) then
    	table.insert(config.castableGameObjects, self.gameObject)
    end
end
