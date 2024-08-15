using System;
using System.IO;
using osuTK.Graphics.OpenGL;
using Rit.Game.Structures.Map;

namespace Rit.Game.Map.Generate;

public class RitMap {
    public static void Generate(string mapPath, MapData mapData) {
        try {
            var lines = File.ReadAllLines(Path.Combine(Base.BaseScreen.BaseGamePath, "Maps/" + mapPath));
            bool inMeta = false;
            bool inTimingPoints = false;
            bool inHitObjects = false;

            foreach (var line in lines) {
                if (line.StartsWith("[Metadata]")) {
                    inMeta = true;
                    inTimingPoints = false;
                    inHitObjects = false;
                    continue;
                } else if (line.StartsWith("[TimingPoints]")) {
                    inTimingPoints = true;
                    inMeta = false;
                    inHitObjects = false;
                } else if (line.StartsWith("[HitObjects]")) {
                    inTimingPoints = false;
                    inMeta = false;
                    inHitObjects = true;
                }

                if (inMeta) {
                    if (string.IsNullOrWhiteSpace(line))
                        continue;

                    var parts = line.Split(":", 2);
                    if (parts.Length < 2) continue;

                    var key = parts[0].Trim();
                    var value = parts[1].Trim();

                    switch(key) {
                        case "Title":
                            mapData.Meta.Title = value;
                            break;
                        case "DifficultyName":
                            mapData.Meta.DifficultyName = value;
                            break;
                        case "Description":
                            mapData.Meta.Description = value;
                            break;
                        case "Artist":
                            mapData.Meta.Artist = value;
                            break;
                        case "Source":
                            mapData.Meta.Source = value;
                            break;
                        case "Creator":
                            mapData.Meta.Creator = value;
                            break;
                        case "Tags":
                            mapData.Meta.Tags = value;
                            break;
                        case "AudioFile":
                            mapData.AudioFile = value;
                            break;
                        case "BackgroundFile":
                            mapData.BackgroundFile = value;
                            break;
                        case "Keys":

                            break;
                        case "MapSetID":

                            break;
                        case "InitialSV":

                            break;
                    }
                }

                if (inTimingPoints) {
                    if (string.IsNullOrWhiteSpace(line))
                        continue;

                    var parts = line.Split(":");
                    if (parts.Length < 3) continue;

                    if (parts[0] == "SV") {
                        var scrollVelocity = new StructureScrollVelocity {
                            StartTime = double.Parse(parts[1]),
                            Multiplier = double.Parse(parts[2])
                        };

                        mapData.ScrollVelocities.Add(scrollVelocity);
                    }
                }

                if (inHitObjects) {
                    if (string.IsNullOrWhiteSpace(line))
                        continue;

                    var parts = line.Split(":");
                    if (parts.Length < 4) continue;

                    if (int.TryParse(parts[1], out var hitData)) {
                        var hitObject = new StructureHitObject {
                            Data = hitData,
                            StartTime = double.Parse(parts[2])
                        };

                        mapData.HitObjects.Add(hitObject);
                    }
                }
            }
        } catch(Exception ex) {
            Console.WriteLine($"Error Generating Map Data: {ex.Message}");
        }
    }
}
