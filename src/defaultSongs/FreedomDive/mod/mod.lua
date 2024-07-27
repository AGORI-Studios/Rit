local playfieldSprs = {}

function Start()
    CreatePlayfield(0, 0)
    playfieldSprs[1] = CreatePlayfieldVertSprite(1)
    playfieldSprs[2] = CreatePlayfieldVertSprite(2)
    SetPlayfield(2)
    set {0, 1, "reverse"}
end

function Update(dt)

end