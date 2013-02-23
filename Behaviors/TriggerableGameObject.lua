
function Behavior:Awake()
    Daneel.Triggers.RegisterTriggerableGameObject(self.gameObject)
end

function Behavior:OnTriggerEnter(trigger)
    -- trigger.gameObject is the trigger gameObject

end

function Behavior:OnTriggerStay(trigger)

end

function Behavior:OnTriggerExit(trigger)

end