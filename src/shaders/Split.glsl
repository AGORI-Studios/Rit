extern number splitCount = 1;
extern number x;
extern number y;
extern bool mirrored;

vec4 effect(vec4 color, Image image, vec2 pos, vec2 screen_coords) {
    vec2 uv = screen_coords.xy / love_ScreenSize.xy;
    uv *= splitCount;
    uv.x += x;
    uv.y += y;
    if (mirrored) uv.x = 1 - uv.x;

    return Texel(image, fract(uv));
}