
function Behavior:Awake()
    table.insert(Daneel.config.triggerableGameObjects, self.gameObject)
end
