// Implemented from https://www.shadertoy.com/view/Xltfzj
extern float blurIntensity;

float DIRECTIONS = 16.0;
float Quality = 3.0; // Higher quality = better looking blur, but slower performance
float Size = 8.0;

vec2 gameScale = vec2(1920, 1080);

vec4 effect(vec4 color, Image image, vec2 pos, vec2 screen_coords)
{
    vec4 sum = vec4(0);
    vec2 dir = vec2(1.0, 0.0);
    float blurSize = blurIntensity * Size / gameScale.x;
    float quality = Quality / gameScale.x;
    float ratio = 1.0;
    float offset = 1.0 / gameScale.x;

    for (float i = 0.0; i < DIRECTIONS; i++)
    {
        vec2 offset = vec2(cos(i * 6.2831853 / DIRECTIONS), sin(i * 6.2831853 / DIRECTIONS)) * blurSize;
        for (float j = 0.0; j < quality; j++)
        {
            sum += Texel(image, pos + dir * offset * (j / quality)) / DIRECTIONS;
        }
    }

    return sum;
}