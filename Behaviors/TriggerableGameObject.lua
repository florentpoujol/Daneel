
-- public property :
-- layers

function Behavior:Start()
	local tgos = Daneel.Config.Get("triggerableGameObjects")
	self.layers = self.layers:split(",")
	for i, layer in ipairs(self.layers) do
		if tgos[layer] == nil then
			tgos[layer] = {}
		end
		table.insert(tgos[layer], self.gameObject)
	end
end
