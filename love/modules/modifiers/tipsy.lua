local tipsy = {}
function tipsy:apply(amount)
    -- Apply the tipsy mod
    -- causes the note receptors to go up and down depending on its modifier
    table.insert(modifiers.curEnabled, {"tipsy", amount})
end

function tipsy:update(dt, beat, amount)
    for i = 1, 4 do
        local ypos = 0

        ypos = ypos + amount * (math.cos(musicTime*0.001+i*(1.2)+1*(1.2))*receptors[i][1]:getHeight()*0.5)

        receptors[i][1].offsetY = ypos
        receptors[i][2].offsetY = ypos

        noteImgs[i][1].offsetY = ypos
        noteImgs[i][2].offsetY = ypos
        noteImgs[i][3].offsetY = ypos
    end
end

return tipsy