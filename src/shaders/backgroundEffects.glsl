// Implemented from https://www.shadertoy.com/view/Xltfzj
extern float dim = 0.5;
extern float blurIntensity = 1; // 0.0 - 1.0
// TODO: Fix blurring.

float rand(float l, float h)
{
    return mix(l, h, fract(sin(dot(gl_FragCoord.xy, vec2(12.9898, 78.233))) * 43758.5453));
}

vec4 effect(vec4 color, Image image, vec2 pos, vec2 screen_coords)
{
    vec2 uv = screen_coords.xy / love_ScreenSize.xy;
    vec4 texcolor = Texel(image, uv);
    
    vec4 sum = vec4(0.0);
    vec2 size = love_ScreenSize.xy;
    vec2 blur = vec2(size.x, size.y) * (blurIntensity * 2.0);

    for (int i = 0; i < 10; i++)
    {
        vec2 offset = vec2(rand(-1.0, 1.0), rand(-1.0, 1.0));
        sum += Texel(image, uv + offset / blur) * 0.1;
    }

    return sum * dim;
}
