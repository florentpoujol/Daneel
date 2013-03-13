
function Behavior:Awake()
    table.insert(Daneel.config.castableGameObjects, self.gameObject)
end
