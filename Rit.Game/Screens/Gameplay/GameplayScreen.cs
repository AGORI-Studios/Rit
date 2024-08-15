using System;
using osu.Framework.Allocation;
using osu.Framework.Graphics;
using osu.Framework.Graphics.Shapes;
using osu.Framework.Graphics.Sprites;
using osu.Framework.Screens;
using osuTK.Graphics;
using Rit.Game.Base;

using Rit.Game.Map;

namespace Rit.Game.Screens.Gameplay
{
    public partial class GameplayScreen : BaseScreen
    {
        public MapData MapData { get; private set; }
        private string mapPath = "purpleeater/map.ritc";
        [BackgroundDependencyLoader]
        private void load()
        {
            Anchor = Anchor.Centre;
            Origin = Anchor.Centre;

            MapData = new MapData(mapPath);
        }
    }
}
