using System;
using osu.Framework.Allocation;
using osu.Framework.Audio;
using osu.Framework.Graphics;
using osu.Framework.Graphics.Shapes;
using osu.Framework.Graphics.Sprites;
using osu.Framework.Graphics.Textures;
using osu.Framework.Screens;
using osuTK.Graphics;
using Rit.Game.Base;
using Rit.Game.Managers;
using Rit.Game.Map;

namespace Rit.Game.Screens.Gameplay
{
    public partial class GameplayScreen : BaseScreen
    {
        public MapData MapData { get; private set; }
        public HitObjectManager Manager { get; private set; }

        private string mapFolder = "svahah/";
        private string mapPath = "svahah/out.ritc";
        private DependencyContainer dependencies;
        public TextureStore Textures;

        [BackgroundDependencyLoader]
        private void load(TextureStore textures, AudioManager audioManager)
        {
            Textures = textures;
            dependencies = new DependencyContainer();
            dependencies.CacheAs(this);
            dependencies.CacheAs(audioManager);

            Anchor = Anchor.Centre;
            Origin = Anchor.Centre;

            MapData = new MapData(mapPath, mapFolder, dependencies);

            dependencies.CacheAs(Manager = new HitObjectManager {
                AlwaysPresent = true,
                Masking = true
            });

            Manager.HitObjects = MapData.HitObjects;
            Manager.ScrollVelocities = MapData.ScrollVelocities;
            Manager.InitSVMarks();

            InternalChildren = new Drawable[]
            {
                Manager
            };
        }

        protected override void Update() {
            base.Update();
        }
    }
}
