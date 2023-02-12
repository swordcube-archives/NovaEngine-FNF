script:import("states.menus.MainMenuState")

local brujSprite
local spinningBruj

local coolText

function onCreate()
    local bg = FlxSprite:new():loadGraphic(Paths:image("menus/base/menuBGBlue"))
    bg.alpha = 0.25
    parent:add(bg)
    
    spinningBruj = FlxSprite:new():loadGraphic(Paths:image("bruj"))
    spinningBruj:setGraphicSize(240, 240)
    spinningBruj:updateHitbox()
    spinningBruj.alpha = 0.45
    parent:add(spinningBruj)

    brujSprite = FlxSprite:new():loadGraphic(Paths:image("bruj"))
    brujSprite:setGraphicSize(240, 240)
    brujSprite:updateHitbox()
    parent:add(brujSprite)

    coolText = FlxText:new(0, 0, 0, "this text was made with lua!\ni'm so cool", 32)
    coolText:setFormat(Paths:font("vcr.ttf"), 32, FlxColor.WHITE, FlxTextAlign.CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK)
    coolText.borderSize = 3
    coolText:screenCenter(FlxAxes.XY)
    parent:add(coolText)

    local tween = FlxTween:tween(coolText, {y = FlxG.height + 30}, 10, {ease = FlxEase.cubeInOut})
    tween.onComplete = function(tween)
        print("dihe ewudhueid gu")
        print(tween.backward)
    end
end

local bitch = 0.0
function onUpdate(elapsed)
    bitch = bitch + elapsed

    spinningBruj:setPosition(
        ((FlxG.width - spinningBruj.width) * 0.5) + math.sin(bitch * 2) * 250,
        ((FlxG.height - spinningBruj.height) * 0.5) + math.cos(bitch * 3) * 250
    )
    local movementSpeed = Main:framerateAdjust(10)

    if parent.controls.BACK then
        FlxG:switchState(MainMenuState:new())
    end

    if FlxG.keys.pressed.UP then
        brujSprite.y = brujSprite.y - movementSpeed
    end

    if FlxG.keys.pressed.DOWN then
        brujSprite.y = brujSprite.y + movementSpeed
    end

    if FlxG.keys.pressed.LEFT then
        brujSprite.flipX = false
        brujSprite.x = brujSprite.x - movementSpeed
    end

    if FlxG.keys.pressed.RIGHT then
        brujSprite.flipX = true
        brujSprite.x = brujSprite.x + movementSpeed
    end
end