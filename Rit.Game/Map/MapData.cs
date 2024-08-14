using System.Collections.Generic;

namespace Rit.Game.Map;

public class MapData {
    public string AudioFile { get; set; } = string.Empty;
    public string BackgroundFile { get; set; } = string.Empty;

    public MapMeta Meta { get; set; }

    public List<int> HitObjects { get; set; }
    public List<int> ScrollVelocities { get; set; }

    public MapData(MapMeta meta) : this() {
        Meta = meta;
    }

    public MapData() {
        Meta = new MapMeta();
        HitObjects = new List<int>();
        ScrollVelocities = new List<int>();
    }
}
