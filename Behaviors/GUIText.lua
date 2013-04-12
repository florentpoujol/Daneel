
-- Behavior for Daneel.GUI.Text that are also buttons

function Behavior:Start()
	Daneel.Events.Listen("OnLeftMouseButtonJustReleased", self.gameObject)
end

function Behavior:OnLeftMouseButtonJustReleased()
	if self.gameObject.onMouseOver == true then
		self.gameObject:SendMessage("OnClick")

		if type(self.element.onClick) == "function"then
			self.element:onClick()
		end
    end
end

-- call the mouse hoverable callbacks
function Behavior:OnMouseEnter()
	if type(self.element.onMouseEnter) == "function" then
		self.element:onMouseEnter()
	end
end

function Behavior:OnMouseOver()
	if type(self.element.onMouseOver) == "function" then
		self.element:onMouseOver()
	end
end

function Behavior:OnMouseExit()
	if type(self.element.onMouseExit) == "function" then
		self.element:onMouseExit()
	end
end
