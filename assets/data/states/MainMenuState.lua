script:import("flixel.tweens.FlxTween")
script:import("flixel.tweens.FlxEase")

function onCreate()
    print("ham brugeerrbg")

    -- uncomment the code below to see what object oriented lua does

    -- parent.runDefaultCode = false

    -- local sprite = FlxSprite:new():loadGraphic(Paths:image("game/base/default/NOTE_assets"))
    -- sprite.scrollFactor:set(0, 0)
    -- sprite:screenCenter(FlxAxes.X)
    -- sprite.color = FlxColor:fromString("#FF0000")
    -- parent:add(sprite)

    -- FlxTween:tween(sprite, {x = 10}, 10, {ease = FlxEase.cubeInOut})

    FlxG:switchState(ModState:new("testicular"))
end