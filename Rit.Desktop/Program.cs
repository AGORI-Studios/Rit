using osu.Framework.Platform;
using osu.Framework;
using Rit.Game;

using osu;

namespace Rit.Desktop
{
    public static class Program
    {
        public static void Main()
        {
            /* using (GameHost host = Host.GetSuitableDesktopHost(@"Rit"))
            using (osu.Framework.Game game = new RitGame())
                host.Run(game); */

            using GameHost host = Host.GetSuitableDesktopHost(@"Rit", new HostOptions { IPCPort = 24000 });

            using (osu.Framework.Game game = new RitGame()) {
                host.Run(game);
            }
        }
    }
}
