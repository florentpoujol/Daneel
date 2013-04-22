
--- for interactions between the mouse and the element

function Behavior:Start()
    table.insert(config.default.mouseinteractiveGameObjects, self.gameObject)
end

function Behavior:OnClick()
    if type(self.element.onClick) == "function"then
        self.element:onClick()
    end
end

function Behavior:OnDoubleClick()
    if type(self.element.onDoubleClick) == "function"then
        self.element:onDoubleClick()
    end
end

function Behavior:OnRightClick()
    if type(self.element.onRightClick) == "function"then
        self.element:onRightClick()
    end
end

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
