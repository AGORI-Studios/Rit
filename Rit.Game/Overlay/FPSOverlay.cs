using osu.Framework.Allocation;
using osu.Framework.Bindables;
using osu.Framework.Graphics;
using osu.Framework.Graphics.Containers;
using osu.Framework.Graphics.Shapes;
using osu.Framework.Platform;
using osuTK.Graphics;
using osuTK;
using osu.Framework.Graphics.Sprites;
using osu.Framework.Graphics.Textures;
using osu.Framework.Graphics.Effects;
using osu.Framework.Graphics.UserInterface;
using Rit.Game.Graphics.Text;

namespace Rit.Game.Overlay;

public partial class FPSOverlay : Container {
    [Resolved]
    private GameHost host { get; set; }

    private double lastTime;
    /* private bool visible = true;*/

    private TextFlowObj textFlow;/*  = new TextFlowObj{
        FontSize = 20,
        AutoSizeAxes = Axes.Both,
        TextAnchor = Anchor.TopRight
    }; */

    [BackgroundDependencyLoader]
    private void load() {
        AutoSizeAxes = Axes.Both;
        Anchor = Anchor.BottomRight;
        Origin = Anchor.BottomRight;
        AlwaysPresent = true;
        Margin = new MarginPadding(20);
        CornerRadius = 5;
        Y = -40;
        Masking = true;
        EdgeEffect = new EdgeEffectParameters {
            Type = EdgeEffectType.Shadow,
            Radius = 5,
            Colour = Colour4.Black.Opacity(0.5f),
        };

        InternalChildren = new Drawable[] {
            new Box {
                RelativeSizeAxes = Axes.Both,
                Colour = Colour4.Black.Opacity(0.5f),
            },
            new Container {
                AutoSizeAxes = Axes.Both,
                Padding = new MarginPadding(5),
                Child = textFlow = new TextFlowObj {
                    FontSize = 16,
                    AutoSizeAxes = Axes.Both,
                    TextAnchor = Anchor.TopRight,
                }
            }
        };

        System.Console.WriteLine("FPSOverlay.load()");
    }

    protected override void LoadComplete() {

    }

    protected override void Update() {
        base.Update();

        if (Time.Current - lastTime < 1000) return;

        lastTime = Time.Current;

        textFlow.Clear();

        foreach (var thread in host.Threads) {
            var clock = thread.Clock;
            // convert str to char and get the first char
            var firstChar = thread.Name[0].ToString();
            firstChar = firstChar.ToUpper().ToCharArray()[0].ToString();

            if (firstChar is "U" or "D" or "A" or "I") {
                var fps = clock.FramesPerSecond;
                // print to console to show we got here
                textFlow.AddParagraph($"{fps:0} {firstChar}PS");
            }
        }
    }
}
