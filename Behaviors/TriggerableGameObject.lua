
-- Public property :
-- layers

function Behavior:Awake()
	local tgos = config.triggerableGameObjects
	self.layers = self.layers:split(",")
	for i, layer in ipairs(self.layers) do
		if tgos[layer] == nil then
			tgos[layer] = {}
		end
		if not table.containsvalue(tgos[layer], self.gameObject) then
			table.insert(tgos[layer], self.gameObject)
		end
	end
end
