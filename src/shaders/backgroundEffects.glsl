// Implemented from https://www.shadertoy.com/view/Xltfzj
extern float dim = 0.5;
extern float blurIntensity = 0.5; // 0.0 - 1.0

vec4 effect(vec4 color, Image image, vec2 pos, vec2 screen_coords)
{
    vec2 uv = screen_coords.xy / love_ScreenSize.xy;
    vec4 texcolor = Texel(image, uv);
    
    vec4 sum = vec4(0.0);
    vec2 size = love_ScreenSize.xy;
    vec2 blur = vec2(size.x, size.y) * blurIntensity;

    // These numbers are the weights of the surrounding pixels.
    // Yeah,,,, i should of put them in an array.
    // But i was lazy.
    sum += Texel(image, uv) * 0.29411764705882354;
    sum += Texel(image, uv + vec2(1.0, 0.0) * blur) * 0.35294117647058826;
    sum += Texel(image, uv + vec2(-1.0, 0.0) * blur) * 0.35294117647058826;
    sum += Texel(image, uv + vec2(0.0, 1.0) * blur) * 0.35294117647058826;
    sum += Texel(image, uv + vec2(0.0, -1.0) * blur) * 0.35294117647058826;
    sum += Texel(image, uv + vec2(1.0, 1.0) * blur) * 0.11764705882352941;
    sum += Texel(image, uv + vec2(-1.0, 1.0) * blur) * 0.11764705882352941;
    sum += Texel(image, uv + vec2(1.0, -1.0) * blur) * 0.11764705882352941;
    sum += Texel(image, uv + vec2(-1.0, -1.0) * blur) * 0.11764705882352941;
    
    return sum * dim;
}
