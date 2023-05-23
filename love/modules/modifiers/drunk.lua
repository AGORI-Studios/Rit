local drunk = {}
-- Drunk is a notig mod. It's a modifier that makes the notes look drunk.
function drunk:apply(amount)
    -- Apply the drunk mod
    -- causes the note receptors to go left and right depending on its modifier
    table.insert(modifiers.curEnabled, {"drunk", amount})

end

function drunk:update(dt, beat, amount)
    --print("drunkIsEnabled")
    for i = 1, 4 do
        local xpos = 0

        xpos = xpos + amount * (math.cos(musicTime*0.001+i*(0.2)+1*(0.2))*receptors[i][1]:getWidth()*0.5)

        receptors[i][1].offsetX = xpos
        receptors[i][2].offsetX = xpos

        noteImgs[i][1].offsetX = xpos
        noteImgs[i][2].offsetX = xpos
        noteImgs[i][3].offsetX = xpos
    end
end

return drunk