using System;
using System.Collections.Generic;
using System.Linq;
using osu.Framework.Graphics;
using osu.Framework.Input.Bindings;
using osu.Framework.Input.Events;
using Rit.Game.Input.Keybinds;
using Rit.Game.Screens.Gameplay;

namespace Rit.Game.Input;

public partial class InputGameplay : Drawable, IKeyBindingHandler {
    private static GameplayBinds[] keys4 { get; } = {
        GameplayBinds.K4Key1,
        GameplayBinds.K4Key2,
        GameplayBinds.K4Key3,
        GameplayBinds.K4Key4,
    };

    private readonly GameplayScreen screen;

    public List<GameplayBinds> Keys { get; }

    private readonly bool[] pressedStatus;
    public bool[] JustPressed { get; }
    public bool[] Pressed { get; }
    public bool[] JustReleased { get; }

    public event Action<GameplayBinds> OnPress;
    public event Action<GameplayBinds> OnRelease;

    public InputGameplay(GameplayScreen screen) {
        this.screen = screen;

        Keys = keys4.ToList();

        pressedStatus = new bool[4];
        JustPressed = new bool[4];
        Pressed = new bool[4];
        JustReleased = new bool[4];
    }

    protected override void Update()
    {
        base.Update();

        for (int i = 0; i < Keys.Count; i++) {
            switch(pressedStatus[i]) {
                case true when !Pressed[i]:
                    JustPressed[i] = true;
                    Pressed[i] = true;
                    break;
                case false when Pressed[i]:
                    JustReleased[i] = true;
                    Pressed[i] = false;
                    break;
                default:
                    JustPressed[i] = false;
                    JustReleased[i] = false;
                    break;
            }
        }
    }

    public virtual bool OnPressed(KeyBindingPressEvent<GameplayBinds> e) => !e.Repeat && PressKey(e.Action);
    public virtual void OnReleased(KeyBindingReleaseEvent<GameplayBinds> e) => ReleaseKey(e.Action);

    public bool PressKey(GameplayBinds key)
    {
        Console.WriteLine(key);
        var idx = Keys.IndexOf(key);
        if (idx == -1) return false;

        pressedStatus[idx] = true;
        OnPress?.Invoke(key);
        return true;
    }

    public void ReleaseKey(GameplayBinds key)
    {
        var idx = Keys.IndexOf(key);
        if (idx == -1) return;

        pressedStatus[idx] = false;
        OnRelease?.Invoke(key);
    }
}
