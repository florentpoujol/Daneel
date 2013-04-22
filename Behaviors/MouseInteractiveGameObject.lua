
-- for interactions between the mouse and the element

function Behavior:Start()
    table.insert(config.default.interactiveGameObjects, self.gameObject)
end
