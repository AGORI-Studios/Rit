using System;
using System.IO;
using osu.Framework.Allocation;
using osu.Framework.Bindables;
using osu.Framework.Graphics;
using osu.Framework.Screens;
using Rit.Game.Screens;

namespace Rit.Game.Base;

public partial class BaseScreen : Screen {
    // Variables
    public virtual float Zoom => 1f;
    public virtual float ParallaxStrength => 0.05f;
    public virtual float BackgroundDim => 0.25f;
    public virtual float BackgroundBlur => 0f;
    public virtual bool ShowCursor => true;
    public virtual bool AllowExit => true;

    // Transitions
    public const float MOVE_DURATION = 500;
    public const float FADE_DURATION = 250;
    public const float ENTER_DELAY = 100;

    protected new RitGame Game => (RitGame)base.Game;

    public static string BaseGamePath => Path.Combine(Environment.GetFolderPath(Environment.SpecialFolder.ApplicationData), "Rit");

    protected BaseScreen() {
        Anchor = Anchor.Centre;
        Origin = Anchor.Centre;
    }

    public override bool OnExiting(ScreenExitEvent e) {
        /* if (!AllowExit) {
            e.Cancel();
            return true;
        }
 */
        return base.OnExiting(e);
    }
}
