script:import("flixel.tweens.FlxTween")
script:import("flixel.tweens.FlxEase")

local easterEggKeys = {"LUATEST"}
local allowedKeys = "ABCDEFGHIJKLMNOPQRSTUVWXYZ"
local easterEggKeysBuffer = ""

function onUpdate(elapsed)
    local pressedKey = FlxG.keys:firstJustPressed()
    if pressedKey ~= FlxKey.NONE then

        local keyName = FlxKey:toString(pressedKey)
        if string:contains(allowedKeys, keyName) then
            easterEggKeysBuffer = easterEggKeysBuffer .. keyName
            if #easterEggKeysBuffer >= 32 then
                easterEggKeysBuffer = string:substr(easterEggKeysBuffer, 1)             
            end

            for i = 1, #easterEggKeys do
                local word = string:upper(easterEggKeys[i])
                if string:contains(easterEggKeysBuffer, word) then
                    doEasterEggWord(word)
                end
            end
        end
    end
end

function doEasterEggWord(word)
    if word == easterEggKeys[1] then
        FlxG:switchState(ModState:new("LuaState"))
    end
end