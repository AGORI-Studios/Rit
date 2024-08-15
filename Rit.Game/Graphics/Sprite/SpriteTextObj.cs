using System;
using osu.Framework.Graphics.Sprites;

namespace Rit.Game.Graphics.Sprite;

public partial class SpriteTextObj : SpriteText {
    public float FontSize {
        get => base.Font.Size;
        set => base.Font = base.Font.With(size: value);
    }

    // the font
    public new string Font {
        get => base.Font.Family;
        set => base.Font = base.Font.With(family: value);
    }

    public bool FixedWidth {
        get => base.Font.FixedWidth;
        set => base.Font = base.Font.With(fixedWidth: value);
    }

    public SpriteTextObj() {
        Font = "Arial";
    }

    public static FontUsage GetFont(string font = "Arial", float size = 20, bool fixedWidth = false) {
        return new(font, size, fixedWidth: fixedWidth);
    }
}
