using System;
using System.Collections.Generic;
using Rit.Game.Map.Generate;
using Rit.Game.Structures.Map;
using SixLabors.ImageSharp.PixelFormats;

namespace Rit.Game.Map;

public class MapData {
    public string AudioFile { get; set; } = string.Empty;
    public string BackgroundFile { get; set; } = string.Empty;

    public MapMeta Meta { get; set; }

    public List<StructureHitObject> HitObjects { get; set; }
    public List<int> ScrollVelocities { get; set; }
    public List<int> BPMChanges { get; set; }

    public MapData(MapMeta meta, string mapPath) : this(mapPath) {
        Meta = meta;
    }

    public MapData(string mapPath) {
        Meta = new MapMeta();
        HitObjects = new List<StructureHitObject>();
        ScrollVelocities = new List<int>();
        BPMChanges = new List<int>();

        RitMap.Generate(mapPath, this);

        Console.WriteLine($"SIZE OF HIT OBJECTS: {HitObjects.Count}");
    }
}
