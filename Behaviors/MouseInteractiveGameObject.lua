
-- for interactions between the mouse and the element

function Behavior:Start()
    table.insert(config.mouseInteractiveGameObjects, self.gameObject)
end
