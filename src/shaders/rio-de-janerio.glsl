#define PI 3.1415926538

extern number xrot = 0.0;
extern number yrot = -0.24;
extern number zrot = 0.05;
extern number xpos = 0.05;
extern number ypos = 0.0;
extern number zpos = -0.13;

float alph = 0;
float plane( in vec3 norm, in vec3 po, in vec3 ro, in vec3 rd ) {
    float de = dot(norm, rd);
    de = sign(de)*max( abs(de), 0.001);
    return dot(norm, po-ro)/de;
}

vec2 raytraceTexturedQuad(in vec3 rayOrigin, in vec3 rayDirection, in vec3 quadCenter, in vec3 quadRotation, in vec2 quadDimensions) {
    //Rotations ------------------
    float a = sin(quadRotation.x); float b = cos(quadRotation.x); 
    float c = sin(quadRotation.y); float d = cos(quadRotation.y); 
    float e = sin(quadRotation.z); float f = cos(quadRotation.z); 
    float ac = a*c;   float bc = b*c;
	
	mat3 RotationMatrix  = 
			mat3(	  d*f,      d*e,  -c,
                 ac*f-b*e, ac*e+b*f, a*d,
                 bc*f+a*e, bc*e-a*f, b*d );
    //--------------------------------------
    
    vec3 right = RotationMatrix * vec3(quadDimensions.x, 0.0, 0.0);
    vec3 up = RotationMatrix * vec3(0, quadDimensions.y, 0);
    vec3 normal = cross(right, up);
    normal /= length(normal);
    
    //Find the plane hit point in space
    vec3 pos = (rayDirection * plane(normal, quadCenter, rayOrigin, rayDirection)) - quadCenter;
    
    //Find the texture UV by projecting the hit point along the plane dirs
    return vec2(dot(pos, right) / dot(right, right),
                dot(pos, up)    / dot(up,    up)) + 0.5;
}

vec4 effect(vec4 color, Image image, vec2 uv2, vec2 screen_coords) {
    vec2 screenUV = screen_coords / vec2(1920, 1080);  // This line still normalizes coordinates
    vec2 p = (2.0 * uv2) - 1.0;
    
    vec3 dir = vec3(p.x, p.y, 1.0);
    dir /= length(dir);
    
    vec3 planePosition = vec3(xpos, ypos, zpos + 0.5);
    vec3 planeRotation = vec3(xrot, yrot + 3.14159265, zrot);
    vec2 planeDimension = vec2(-1.0, 1.0);  // Removed aspect ratio adjustment
    
    vec2 uv = raytraceTexturedQuad(vec3(0.0), dir, planePosition, planeRotation, planeDimension);
    
    // Define gradient colors
    vec4 gradientTop = vec4(1.0, 0.8, 0.6, 0.25); // Purple
    vec4 gradientBottom = vec4(0.5, 0.0, 0.5, 0.25); // Peach
    
    // Calculate gradient factor based on UV y-coordinate
    float gradientFactor = uv.y;
    
    // Blend gradient color with texture color
    vec4 gradientColor = mix(gradientBottom, gradientTop, gradientFactor);
    
    // Return the final color with gradient and texture
    if (abs(uv.x - 0.5) < 0.5 && abs(uv.y - 0.5) < 0.5) {
        return mix(Texel(image, uv), gradientColor, 0.5); // Mix with 50% gradient and 50% texture
    }
    
    return gradientColor; // Return gradient color for areas outside the texture
}