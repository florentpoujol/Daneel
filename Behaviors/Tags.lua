
-- Add this Script to a gameObject to add tags while still in the scene editor

-- Public property :
-- tags (string) [default=""]

function Behavior:Start()
	if self.tags ~= "" then
		local tags = self.tags:split(",")
		self.gameObject:AddTag(tags)
	end
end
