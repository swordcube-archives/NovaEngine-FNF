local tweensDad = {
    nil,
    nil,
    nil,
    nil
}

local tweens = {
    nil,
    nil,
    nil,
    nil
}

function squish(direction, opponent)
    local receptor = nil
    local tween = nil

    -- no direction + 1 here becaus haxe arrays work differently now!
    if opponent == true then
        receptor = parent.cpuStrums.members[direction]
    else
        receptor = parent.playerStrums.members[direction]
    end

    receptor.scale:set(receptor.initialScale * 2.5, receptor.initialScale * 0.1)

    if opponent == true then
        tween = tweensDad[direction + 1]
    else
        tween = tweens[direction + 1]
    end

    if tween ~= nil then
        tween:cancel()
    end

    local piss = FlxTween:tween(
        receptor, 
        {["scale.x"] = receptor.initialScale, ["scale.y"] = receptor.initialScale},
        0.2,
        {ease = FlxEase.cubeOut}
    )
    if opponent == true then
        tweensDad[direction + 1] = piss
    else
        tweens[direction + 1] = piss
    end
end

function onKeyPress(event)
    squish(event.direction)
end

function onPlayerHit(event)
    if not event.note.isSustainNote then return end
    squish(event.note.noteData, false)
end

function onOpponentHit(event)
    squish(event.note.noteData, true)
end