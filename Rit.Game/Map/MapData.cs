using System;
using System.Collections.Generic;
using osu.Framework.Audio;
using osu.Framework.Audio.Track;
using osu.Framework.Allocation;
using osu.Framework.IO.Stores;
using Rit.Game.Map.Generate;
using Rit.Game.Structures.Map;
using osu.Framework.Platform;
using System.IO;

namespace Rit.Game.Map
{
    public class MapData
    {
        public string AudioFile { get; set; } = string.Empty;
        public string BackgroundFile { get; set; } = string.Empty;

        public MapMeta Meta { get; set; }

        public List<StructureHitObject> HitObjects { get; set; }
        public List<StructureScrollVelocity> ScrollVelocities { get; set; }
        public List<int> BPMChanges { get; set; }

        private Track track;

        private readonly DependencyContainer dependencies;

        public MapData(string mapPath, string mapFolder, DependencyContainer dependencies)
        {
            this.dependencies = dependencies;

            Meta = new MapMeta();
            HitObjects = new List<StructureHitObject>();
            ScrollVelocities = new List<StructureScrollVelocity>();
            BPMChanges = new List<int>();

            RitMap.Generate(mapPath, this);

            loadAndPlayAudio(Path.Combine(Path.Combine(Base.BaseScreen.BaseGamePath, "Maps/" + mapFolder), AudioFile));

            Console.WriteLine($"SIZE OF HIT OBJECTS: {HitObjects.Count}");
        }

        private void loadAndPlayAudio(string audioPath)
        {
            var audioManager = dependencies.Get<AudioManager>();

            if (audioManager == null)
            {
                Console.WriteLine("Failed to resolve AudioManager.");
                return;
            }

            var fileStore = new StorageBackedResourceStore(new NativeStorage(System.IO.Path.GetDirectoryName(audioPath)));
            var trackStore = audioManager.GetTrackStore(fileStore);

            track = trackStore.Get(System.IO.Path.GetFileName(audioPath));

            if (track != null)
            {
                track.Looping = false;
                track.Start();
                Console.WriteLine($"Playing audio: {audioPath}");
            }
            else
            {
                Console.WriteLine($"Failed to load audio: {audioPath}");
            }
        }
    }
}
