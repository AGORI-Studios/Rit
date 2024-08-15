using System;
using osu.Framework.Allocation;
using osu.Framework.Graphics;
using osu.Framework.Screens;
using osu.Framework.Configuration;
using Rit.Game.Overlay;

namespace Rit.Game
{
    public partial class RitGame : RitGameBase
    {
        private ScreenStack screenStack;

        [BackgroundDependencyLoader]
        private void load(FrameworkConfigManager config)
        {
            Child = screenStack = new ScreenStack { RelativeSizeAxes = Axes.Both };

            Console.WriteLine("RitGame.load()");

            // Set FPS cap to unlimited
            config.GetBindable<FrameSync>(FrameworkSetting.FrameSync).Value = FrameSync.Unlimited;
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
