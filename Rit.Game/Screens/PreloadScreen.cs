using System;
using System.IO;
using osu.Framework.Allocation;
using osu.Framework.Graphics;
using osu.Framework.Graphics.Containers;
using osu.Framework.Graphics.Shapes;
using osu.Framework.Graphics.Sprites;
using osu.Framework.Screens;
using osuTK.Graphics;
using osuTK.Graphics.ES11;
using Rit.Game.Base;

namespace Rit.Game.Screens;

public partial class PreloadScreen : BaseScreen {
    private void setupFolders() {
        /* Console.WriteLine($"Application Data: {Environment.GetFolderPath(Environment.SpecialFolder.ApplicationData)}"); */

        if (!Directory.Exists(BaseGamePath))
            Directory.CreateDirectory(BaseGamePath);

        // Now for the rest of our folders !! yay!!!

        string mapsPath = Path.Combine(BaseGamePath, "Maps");
        if (!Directory.Exists(mapsPath))
            Directory.CreateDirectory(mapsPath);

        string cachePath = Path.Combine(BaseGamePath, "Cache");
        if (!Directory.Exists(cachePath))
            Directory.CreateDirectory(cachePath);
    }

    [BackgroundDependencyLoader]
    private void load() {
        Anchor = Anchor.Centre;
        Origin = Anchor.Centre;
        setupFolders();

        InternalChildren = new Drawable[]
            {
                new Box
                {
                    Colour = Color4.Violet,
                    RelativeSizeAxes = Axes.Both,
                },
                new SpriteText
                {
                    Y = 20,
                    Text = "Preload Screen",
                    Anchor = Anchor.TopCentre,
                    Origin = Anchor.TopCentre,
                    Font = FontUsage.Default.With(size: 40)
                },
                new SpinningBox
                {
                    Anchor = Anchor.Centre,
                },
                new ClickableContainer
                {
                    RelativeSizeAxes = Axes.Both,
                    Action = () => this.Push(new Gameplay.GameplayScreen()),
                    X = 100,
                    Y = 100,
                    Width = 0.1f,
                    Height = 0.1f,
                    Children = new Drawable[]
                    {
                        new Box
                        {
                            Colour = Color4.Blue,
                            RelativeSizeAxes = Axes.Both,
                        },
                        new SpriteText
                        {
                            Text = "Go to GameplayScreen",
                            Anchor = Anchor.Centre,
                            Origin = Anchor.Centre,
                            Font = FontUsage.Default.With(size: 20)
                        }
                    }
                }
            };
    }
}
