-- TextArea.lua
-- Scripted behavior for Daneel.GUI.TextArea component.
--
-- Last modified for v1.2.0
-- Copyright © 2013 Florent POUJOL, published under the MIT licence.

--[[PublicProperties
areaWidth string ""
wordWrap boolean false
newLine string "\n"
lineHeight string "1"
verticalAlignment string "top"
font string ""
text string "Text\nArea"
alignment string ""
opacity number 1.0
/PublicProperties]]

-- creating a TextArea from Awake cause an exception (collecion being modified while looping on it)
-- (04/08/2013) That's because a TextArea add a TextRenderer component from New() and that is not permitted by CraftStudio
-- you can't dynamically add built-in components on gameObjects that are created in the scene
-- see : http://www.craftstudioforums.net/index.php?threads/creating-physics-component-crashes-the-game.1398/
function Behavior:Start()
    if self.gameObject.textArea == nil then
        local params = {
            wordWrap = self.wordWrap,
            opacity = self.opacity
        }
        local props = {"areaWidth", "newLine", "lineHeight", "verticalAlignment", "font", "text", "alignment"}
        for i, prop in ipairs( props ) do
            if self[ prop ]:trim() ~= "" then
                params[ prop ] = self[ prop ]
            end
        end

        GUI.TextArea.New( self.gameObject, params )
    end
end
