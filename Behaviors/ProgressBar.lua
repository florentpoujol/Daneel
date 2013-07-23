-- Last modified for :
-- version 1.2.0
-- released 29th July 2013

-- Behavior for Daneel.GUI.ProgressBar component.

--[[PublicProperties
minValue number 0
maxValue number 100
minLength string "0"
maxLength string "5"
height string "1"
progress string "100%"
/PublicProperties]]

function Behavior:Awake()
    if self.gameObject.progressBar == nil then
        self.gameObject:AddComponent("ProgressBar", { 
            minValue = self.minValue,
            maxValue = self.maxValue,
            minLength = self.minLength,
            maxLength = self.maxLength,
            height = self.height,
            progress = self.progress,
        })
    end
end