function onCreatePost()
    print("printing test")

    local sprite = FlxSprite:new()
    sprite.scrollFactor.set(0, 0)
    sprite.screenCenter()
    sprite.loadGraphic(Paths:image("game/base/default/NOTE_assets"))
    script.parent.add(sprite)

    print("fuck sprites don't work that well, does flxkey work though?")
    print(FlxKey)
    print(FlxAxes)
    print("FUCK IT DON'T, ALSO WHY DOES FLXAXES PRINT CORE.CONTROLS WHART")
    print("NONE OF THESE WORK THAT WELL :((, I'LL FIGURE THIS SHIT OUT LATER PROBABLY MAYBE I HOPE")
end