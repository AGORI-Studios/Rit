local NoteHelper = {}

function NoteHelper:initializePositionMarkers(sliderVelocities, initialSV)
    local velocityPositionMarkers = {}

    if #sliderVelocities == 0 then return end

    local position = sliderVelocities[1].startTime * initialSV * 100

    table.insert(velocityPositionMarkers, position)

    for i = 2, #sliderVelocities do
        local velocity = sliderVelocities[i]

        position = position + (velocity.startTime - sliderVelocities[i - 1].startTime) * sliderVelocities[i - 1].multiplier * 100
        table.insert(velocityPositionMarkers, position)
    end

    return velocityPositionMarkers
end

function NoteHelper:initPositions(unspawnNotes)
    for _, hitObject in ipairs(unspawnNotes) do
        hitObject.initialTrackPosition = states.game.Gameplay:getPositionFromTime(hitObject.time)
        hitObject.latestTrackPosition = hitObject.initialTrackPosition
        if hitObject.endTime then
            hitObject.endTrackPosition = states.game.Gameplay:getPositionFromTime(hitObject.endTime)
        end
    end

    return unspawnNotes
end

function NoteHelper:getNotePosition(offset, initialPos, scrollSpeed, downscroll)
    if not downscroll then
        return strumY + (((initialPos or 0) - offset) * scrollSpeed / 100)
    else  
        return strumY - (((initialPos or 0) - offset) * scrollSpeed / 100)
    end
end

function NoteHelper:updateNotePosition(offset, hitObjects, scrollSpeed, downscroll)
    local spritePosition = 0

    for _, hitObject in ipairs(hitObjects.members) do
        spritePosition = self:getNotePosition(offset, hitObject.initialTrackPosition, scrollSpeed, downscroll)
        if not hitObject.moveWithScroll then
            -- go to strumY (it's a hold)
            spritePosition = strumY
        end
        hitObject.y = spritePosition
        if #hitObject.children > 0 then
            -- Determine the hold notes position and scale
            hitObject.children[1].y = spritePosition + 95/2
            hitObject.children[2].y = spritePosition + 95/2

            hitObject.endY = NoteHelper:getNotePosition(offset, hitObject.endTrackPosition, scrollSpeed, downscroll)
            local pixelDistance = hitObject.endY - hitObject.children[1].y + 95-- the distance of start and end we need
            hitObject.children[1].dimensions = {width = 200, height = pixelDistance}
            hitObject.children[2].dimensions = {width = 200, height = 95 * (Settings.options["General"].skin.flippedEnd and -1 or 1)}

            if Modscript.downscroll then
                hitObject.children[2].y = hitObject.children[2].y + pixelDistance - 95
            else
                hitObject.children[2].y = hitObject.children[2].y + pixelDistance + 95
            end
        end
    end

    return hitObjects
end

return NoteHelper