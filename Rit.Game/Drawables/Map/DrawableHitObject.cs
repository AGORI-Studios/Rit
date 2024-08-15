using System;
using osu.Framework.Allocation;
using osu.Framework.Graphics;
using osu.Framework.Graphics.Containers;
using osu.Framework.Graphics.Shapes;
using osu.Framework.Graphics.Sprites;
using osu.Framework.Graphics.Textures;
using Rit.Game.Managers;
using Rit.Game.Structures.Map;

namespace Rit.Game.Drawables.Map;

public partial class DrawableHitObject : CompositeDrawable {
    public StructureHitObject Data { get; }

    protected HitObjectManager Manager { get; private set; }

    public DrawableHitObject(StructureHitObject data, HitObjectManager manager) {
        Data = data;
        Manager = manager;
    }

    [BackgroundDependencyLoader]
    private void load(TextureStore texture) {
        Origin = Anchor.TopLeft;

        X = 25 + 60 * Data.Data;
        Y = (float)Data.StartTime;
        Height = 50;
        Width = 50;

        InternalChild = new Box {
            RelativeSizeAxes = Axes.Both,
            Colour = Colour4.AliceBlue
        };

        Console.WriteLine($"Created Hit Object at: X{X}:Y{Y}");
    }

    protected override void Update()
    {
        base.Update();

        Y = Manager.GetNotePosition(Data.StartTime);
    }
}
