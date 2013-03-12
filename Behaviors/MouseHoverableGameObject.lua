
function Behavior:Awake()
    table.insert(Daneel.config.mousehoverableGameObjects, self.gameObject)
end
