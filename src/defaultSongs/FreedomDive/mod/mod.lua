function Start()
    CreatePlayfield(-450, 0)
    SetPlayfield(1)
    MovePlayfield(450, 0)

    SetMod("Drunk", 1, 3)
    SetPlayfield(2)
    SetMod("Drunk", 1, 2)
    SetMod("Tipsy", 1, 1.75)
end