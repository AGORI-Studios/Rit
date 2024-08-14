using System;
using osu.Framework.Graphics.Containers;
using osu.Framework.Graphics.Sprites;
using Rit.Game.Graphics.Sprite;

namespace Rit.Game.Graphics.Text;

public partial class TextFlowObj : TextFlowContainer {
    public float FontSize {get; set;} = 20;
    public bool Shadow {get; init;} = true;

    public TextFlowObj(Action<SpriteText> defaultCreationParams = null) : base(defaultCreationParams) {

    }

    protected override SpriteTextObj CreateSpriteText() => new() {
        FontSize = FontSize,
        Shadow = Shadow
    };
}
