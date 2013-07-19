-- Last modified for :
-- version 1.2.0
-- released 29th July 2013

-- Add this Script to a gameObject to add tags while still in the scene editor

-- Public property :
-- tags (string) [default=""]

function Behavior:Awake()
	if self.tags ~= "" then
		local tags = self.tags:split(",", true)
		self.gameObject:AddTag(tags)
	end
end
