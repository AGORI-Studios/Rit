extern vec2 tex_size = vec2(1920, 1080); // 1920x1080
uniform float blur_radius = 1.0;

vec4 effect(vec4 c, Image tex, vec2 tc, vec2 sc)
{
    vec2 offset = 1.0 / tex_size;
    float sigma = blur_radius / 3.0;
    int num_samples = int(blur_radius * 2.0);

    vec4 sum = vec4(0.0);
    vec4 blurred_pixel = vec4(0.0);

    for (int i = -num_samples; i <= num_samples; i++) {
        vec2 offset_i = vec2(float(i) * offset.x, float(i) * offset.y);
        float weight = exp(-0.5 * pow(length(offset_i) / sigma, 2.0));
        sum += Texel(tex, tc + offset_i) * weight;
    }
    blurred_pixel = sum / (float(num_samples) * 2.0 + 1.0);

    return blurred_pixel * c;
}