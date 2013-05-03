
-- public property :
-- layers

function Behavior:Start()
	self.layers = self.layers:split(",")
	local tgos = Daneel.Config.Get("triggerableGameObjects")
	for i, layer in ipairs(self.) do
		if tgos[layer] == nil then
			tgos[layer] = {}
		end
		table.insert(tgos[layer], self.gameObject)
	end
end
