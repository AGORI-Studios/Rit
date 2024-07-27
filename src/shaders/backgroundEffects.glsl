// Implemented from https://www.shadertoy.com/view/Xltfzj
extern float dim = 0.5;
uniform float blur_radius = 1.0;
extern vec2 tex_size = vec2(1920, 1080); // 1920x1080

vec4 effect(vec4 color, Image image, vec2 pos, vec2 screen_coords)
{
    vec2 uv = screen_coords.xy / love_ScreenSize.xy;
    vec4 texcolor = Texel(image, uv);
    
    vec2 offset = 1.0 / tex_size;
    float sigma = blur_radius / 3.0;
    int num_samples = int(blur_radius * 2.0);

    vec4 sum = vec4(0.0);
    vec4 blurred_pixel = vec4(0.0);

    for (int i = -num_samples; i <= num_samples; i++) {
        vec2 offset_i = vec2(float(i) * offset.x, float(i) * offset.y);
        float weight = exp(-0.5 * pow(length(offset_i) / sigma, 2.0));
        sum += Texel(image, pos + offset_i) * weight;
    }
    blurred_pixel = sum / (float(num_samples) * 2.0 + 1.0);

    return blurred_pixel * color * dim;
}
