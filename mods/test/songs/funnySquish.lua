local tweens = {
    nil,
    nil,
    nil,
    nil
}

function squish(direction)
    local receptor = parent.playerStrums.members[direction + 1]
    receptor.scale:set(receptor.initialScale * 2.5, receptor.initialScale * 0.1)

    local tween = tweens[direction + 1]
    if tween ~= nil then
        tween:cancel()
    end

    tweens[direction + 1] = FlxTween:tween(
        receptor, 
        {["scale.x"] = receptor.initialScale, ["scale.y"] = receptor.initialScale},
        0.2,
        {ease = FlxEase.cubeOut}
    )
end

function onKeyPress(event)
    squish(event.direction)
end

function onPlayerHit(event)
    if not event.note.isSustainNote then return end
    squish(event.note.noteData)
end