extern vec2 screen_res;
extern float time;

vec4 effect(vec4 color, Image texture, vec2 texture_coords, vec2 screen_coords) {
    vec2 uv = texture_coords - 0.5;
    float r = uv.x * uv.x + uv.y * uv.y;
    // uv *= 1.0 + r * 0.1; 
    uv += 0.5; 

    if (uv.x < 0.0 || uv.x > 1.0 || uv.y < 0.0 || uv.y > 1.0) {
        return vec4(0.0, 0.0, 0.0, 1.0);
    }

    float aberration = 0.001;
    vec4 tex;
    tex.r = Texel(texture, vec2(uv.x - aberration, uv.y)).r;
    tex.g = Texel(texture, uv).g;
    tex.b = Texel(texture, vec2(uv.x + aberration, uv.y)).b;
    tex.a = 1.0;

    float static_scanline = sin((uv.y * screen_res.y * 1.5) + (time * 10.0)) * 0.05;
    tex.rgb -= static_scanline;
    float scroll_speed = 0.2; 
    float strip_sharpness = 50.0; 
    float strip_intensity = 0.02;
    float moving_strip = fract(uv.y - time * scroll_speed);
    moving_strip = pow(moving_strip, strip_sharpness) * strip_intensity;
    tex.rgb += moving_strip;

    return tex * color;
}