using osu.Framework.Allocation;
using osu.Framework.Graphics;
using osu.Framework.Screens;

using Rit.Game.Overlay;

namespace Rit.Game
{
    public partial class RitGame : RitGameBase
    {
        private ScreenStack screenStack;

        [BackgroundDependencyLoader]
        private void load()
        {
            // Add your top-level game components here.
            // A screen stack and sample screen has been provided for convenience, but you can replace it if you don't want to use screens.
            Child = screenStack = new ScreenStack { RelativeSizeAxes = Axes.Both };
            // print to console to show we got here
            System.Console.WriteLine("RitGame.load()");
        }

        protected override void LoadComplete()
        {
            base.LoadComplete();

            screenStack.Push(new Screens.MainScreen());

            // Add the FPS overlay
            Add(new FPSOverlay());
        }
    }
}
