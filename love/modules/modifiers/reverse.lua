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
    modifiers.reverse = amount
end

function reverse:update(dt, beat, amount)
    -- theres nothing to update lol!!!!
    for i = 1, #receptors do
        receptors[i][1].sizeY = amount * receptors[i][1].sizeY
        receptors[i][2].sizeY = amount * receptors[i][2].sizeY

        noteImgs[i][1].sizeY = amount * noteImgs[i][1].sizeY
        noteImgs[i][2].sizeY = amount * noteImgs[i][2].sizeY
        noteImgs[i][3].sizeY = amount * noteImgs[i][3].sizeY
    end
end

return reverse