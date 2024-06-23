extern float alpha = 1;

vec4 effect(vec4 color, Image image, vec2 pos, vec2 screen_coords) {
    vec4 pixel = Texel(image, pos);

    pixel.r *= color.r;
    pixel.g *= color.g;
    pixel.b *= color.g;
    pixel.a *= alpha;

    return pixel;
}