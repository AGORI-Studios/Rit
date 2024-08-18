using System.Collections.Generic;
using System.Linq;
using osu.Framework.Input.Bindings;
/* using Rit.Game.Input.Keybinds.Realms; */

namespace Rit.Game.Input.Keybinds;

public partial class KeybindsGameplay : KeyBindingContainer
{
    public override IEnumerable<IKeyBinding> DefaultKeyBindings { get; }

    public IEnumerable<KeyBinding> K4Bindings = new[] {
        new KeyBinding(InputKey.D, GameplayBinds.K4Key1),
        new KeyBinding(InputKey.F, GameplayBinds.K4Key2),
        new KeyBinding(InputKey.J, GameplayBinds.K4Key3),
        new KeyBinding(InputKey.K, GameplayBinds.K4Key4)
    };

    public KeybindsGameplay()
    {
        DefaultKeyBindings = K4Bindings;
    }
}

public enum GameplayBinds {
    K4Key1,
    K4Key2,
    K4Key3,
    K4Key4
}
