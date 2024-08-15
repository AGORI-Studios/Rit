using System;
using System.IO;
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
            Child = screenStack = new ScreenStack { RelativeSizeAxes = Axes.Both };

            Console.WriteLine("RitGame.load()");
        }

        protected override void LoadComplete()
        {
            base.LoadComplete();

            screenStack.Push(new Screens.PreloadScreen());

            // Add the FPS overlay
            Add(new FPSOverlay());
        }
    }
}
