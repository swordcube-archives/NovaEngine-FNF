function onCreate()
    print("hghfhdshffdshsfdhsfdsfdsfdhkj")

    local sprite = FNFSprite:new():loadGraphic(Paths:image("bruj"))
    sprite:setGraphicSize(240, 240)
    sprite:updateHitbox()
    parent:add(sprite)

    -- gonna code later
end