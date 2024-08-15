using System;
using System.Collections.Generic;
using osu.Framework.Allocation;
using osu.Framework.Graphics;
using osu.Framework.Graphics.Containers;
using osu.Framework.Graphics.Textures;
using Rit.Game.Drawables.Map;
using Rit.Game.Structures.Map;

namespace Rit.Game.Managers;

public partial class HitObjectManager : Container<DrawableHitObject> {
    public List<StructureHitObject> HitObjects { get; set; } = new List<StructureHitObject>();
    public List<DrawableHitObject> DrawableHitObjects { get; } = new List<DrawableHitObject>();
    public double CurrentTime { get; private set; }
    private double enteredClock { get; set; }

    [BackgroundDependencyLoader]
    private void load(TextureStore texture)
    {
        RelativeSizeAxes = Axes.Both;

        enteredClock = Clock.CurrentTime;
    }

    protected override void LoadComplete()
    {
        base.LoadComplete();
    }

    public bool IsOnScreen(double time) {
        return time - CurrentTime <= DrawHeight;
    }

    private void updateTime() {
        CurrentTime = Clock.CurrentTime - enteredClock;
    }

    protected override void Update() {
        updateTime();
        while (HitObjects.Count > 0 && IsOnScreen(HitObjects[0].StartTime)) {
            var hitObject = new DrawableHitObject(HitObjects[0], this);

            Console.WriteLine($"Adding DrawableHitObject for: {HitObjects[0].StartTime}");

            AddInternal(hitObject);

            HitObjects.RemoveAt(0);
        }

        base.Update();
    }

    public float GetNotePosition(double time) => (float)(time - CurrentTime);
}
