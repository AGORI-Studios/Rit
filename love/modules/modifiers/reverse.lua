local reverse = {}
-- Ok so like uhhhh
-- I gotta rewrite how notes scroll before i can add this properly, else it'll look like... really bad
function reverse:apply(amount)
    -- Apply the reverse mod
    -- Flips the note receptors & notes
    table.insert(modifiers.curEnabled, {"reverse", amount}) 

    if modifiers.tweens.reverse then 
        Timer.cancel(modifiers.tweens.reverse)
    end
    if modifiers.tweens.strumlineY then 
        Timer.cancel(modifiers.tweens.strumlineY)
    end
    if modifiers.tweens.whereNotesHit then 
        Timer.cancel(modifiers.tweens.whereNotesHit)
    end
    --modifiers.reverseScale = amount
    modifiers.tweens.reverse = Timer.tween(0.5, modifiers, {reverseScale = amount}, "out-quad")

    -- strumlineY is usually -35, we need it to go to -700 while its tweening
    if amount == -1 then
        modifiers.tweens.strumlineY = Timer.tween(0.5, strumlineY, {700}, "out-quad")
        modifiers.tweens.whereNotesHit = Timer.tween(0.5, whereNotesHit, {-700}, "out-quad")
    else
        modifiers.tweens.strumlineY = Timer.tween(0.5, strumlineY, {-35}, "out-quad")
        modifiers.tweens.whereNotesHit = Timer.tween(0.5, whereNotesHit, {-35}, "out-quad")
    end
    
end

function reverse:update(dt, beat, amount)
    -- theres nothing to update lol!!!!
    --[[
    for i = 1, #receptors do
        receptors[i][1].sizeY = amount * receptors[i][1].sizeY
        receptors[i][2].sizeY = amount * receptors[i][2].sizeY

        noteImgs[i][1].sizeY = amount * noteImgs[i][1].sizeY
        noteImgs[i][2].sizeY = amount * noteImgs[i][2].sizeY
        noteImgs[i][3].sizeY = amount * noteImgs[i][3].sizeY
    end
    --]]
end

return reverse