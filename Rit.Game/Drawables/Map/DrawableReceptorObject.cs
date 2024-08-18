using System;
using System.Collections.Generic;
using osu.Framework.Allocation;
using osu.Framework.Graphics;
using osu.Framework.Graphics.Containers;
using osu.Framework.Graphics.Rendering;
using osu.Framework.Graphics.Shapes;
using osu.Framework.Graphics.Sprites;
using osu.Framework.Graphics.Textures;
using osu.Framework.IO.Stores;
using osu.Framework.Platform;
using osuTK.Graphics.ES11;
using Rit.Game.Managers;
using Rit.Game.Structures.Map;

namespace Rit.Game.Drawables.Map;

public partial class DrawableReceptor : CompositeDrawable {
    public int Data;

    protected HitObjectManager Manager { get; private set; }

    private static readonly Dictionary<string, Texture> tex_cache = new Dictionary<string, Texture>();

    public DrawableReceptor(int data, HitObjectManager manager) {
        Data = data;
        Manager = manager;
    }

    [BackgroundDependencyLoader]
    private void load(TextureStore textureStore) {
        Origin = Anchor.TopLeft;

        string notePath = "Skins/tempSkin/notes/4K/note1.png";

        if (Manager.Storage.Exists(notePath)) {
            Console.WriteLine("GOATED");

            if (!tex_cache.TryGetValue(notePath, out var texture))
            {
                var customStore = new ResourceStore<byte[]>(new StorageBackedResourceStore(Manager.Storage.GetStorageForDirectory("Skins/tempSkin/notes/4K")));
                var textureLoaderStore = new TextureLoaderStore(customStore);
                var textureUpload = textureLoaderStore.Get($"receptor{Data}-unpressed.png");

                if (textureUpload != null)
                {
                    var renderer = Dependencies.Get<IRenderer>();

                    texture = renderer.CreateTexture(textureUpload.Width, textureUpload.Height);
                    texture.SetData(textureUpload);

                    tex_cache[notePath] = texture;
                }
            }

            if (texture != null) {
                InternalChild = new Container {
                    AutoSizeAxes = Axes.Both,
                    /* Anchor = Anchor.Centre,
                    Origin = Anchor.Centre, */
                    Children = new Drawable[] {
                        new Sprite {
                            Texture = texture
                        }
                    }
                };
            }

            X += 100 + texture.Width * Data;
            Y = Manager.STRUM_Y;
        }
    }
}
