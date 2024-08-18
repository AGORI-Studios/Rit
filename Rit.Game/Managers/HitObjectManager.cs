using System.Collections.Generic;
using osu.Framework.Allocation;
using osu.Framework.Graphics;
using osu.Framework.Graphics.Containers;
using osu.Framework.Graphics.Textures;
using osu.Framework.Platform;
using Rit.Game.Drawables.Map;
using Rit.Game.Structures.Map;

namespace Rit.Game.Managers;

public partial class HitObjectManager : Container<CompositeDrawable> {
    public List<StructureHitObject> HitObjects { get; set; } = new List<StructureHitObject>();
    public List<DrawableHitObject> DrawableHitObjects { get; } = new List<DrawableHitObject>();
    public List<StructureScrollVelocity> ScrollVelocities { get; set; } = new List<StructureScrollVelocity>();
    private List<double> scrollVelocityMarks { get; } = new List<double>();
    public double CurrentTime { get; private set; }
    private double enteredClock { get; set; }

    private int svIndex { get; set; } = 0;

    public Storage Storage { get; set; }

    public int STRUM_Y = 50;

    [BackgroundDependencyLoader]
    private void load(TextureStore texture)
    {
        RelativeSizeAxes = Axes.Both;

        enteredClock = Clock.CurrentTime;
        svIndex = 0;

        createReceptors();
    }

    private void createReceptors() {
        for (int i = 1; i <= 4; i++)
            AddInternal(new DrawableReceptor(i, this));
    }

    protected override void LoadComplete()
    {
        base.LoadComplete();
    }

    public bool IsOnScreen(double time) {
        return GetNotePosition(GetPositionFromTime(time)) <= DrawHeight;
    }

    public void InitSVMarks() {
        if (ScrollVelocities.Count == 0)
            return;

        StructureScrollVelocity first = ScrollVelocities[0];

        var time = first.StartTime;
        scrollVelocityMarks.Add(time);

        for (var i = 1; i < ScrollVelocities.Count; i++)
        {
            StructureScrollVelocity prev = ScrollVelocities[i - 1];
            StructureScrollVelocity current = ScrollVelocities[i];

            time += (int)((current.StartTime - prev.StartTime) * prev.Multiplier);
            scrollVelocityMarks.Add(time);
        }
    }

    public double GetPositionFromTime(double time, int index = -1) { // literally idk why i made it so weird in the l2d version
        if (index == -1)                                             // TWO SEPERATE FUNCTIONS WITH THE EXACT NAME??? (one had a lowercase g.)
            for (index = 0; index < ScrollVelocities.Count; index++) // Idk why i didn't just make it like this before 💀
                if (time < ScrollVelocities[index].StartTime)        // Unrelated: I FUCKING LOVE DEFAULT ARGS
                    break;

        if (index == 0)
            return time;

        StructureScrollVelocity previous = ScrollVelocities[index - 1];

        double pos = scrollVelocityMarks[index - 1];
        pos += (time - previous.StartTime) * previous.Multiplier;

        return pos;
    }

    private void updateTime() {
        while (svIndex < ScrollVelocities.Count && ScrollVelocities[svIndex].StartTime <= (Clock.CurrentTime - enteredClock))
            svIndex++;

        /* Console.WriteLine(CurrentTime); */
        CurrentTime = GetPositionFromTime(Clock.CurrentTime - enteredClock, svIndex);
    }

    protected override void Update() {
        updateTime();
        while (HitObjects.Count > 0 && IsOnScreen(HitObjects[0].StartTime)) {
            var hitObject = new DrawableHitObject(HitObjects[0], this);

           /*  Console.WriteLine($"Adding DrawableHitObject for: {HitObjects[0].StartTime}"); */

            AddInternal(hitObject);

            HitObjects.RemoveAt(0);
        }

        base.Update();
    }

    public float GetNotePosition(double time) => STRUM_Y + (float)(time - (float)CurrentTime);
}
