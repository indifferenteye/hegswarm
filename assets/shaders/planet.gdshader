shader_type canvas_item;

uniform float seed = 0.0;
uniform float water = 0.5;
uniform float plants = 0.5;
uniform float grid_size = 10.0;

float rand(vec2 p) {
    return fract(sin(dot(p, vec2(12.9898, 78.233))) * 43758.5453);
}

float noise(vec2 p) {
    vec2 i = floor(p);
    vec2 f = fract(p);
    float a = rand(i + seed);
    float b = rand(i + vec2(1.0, 0.0) + seed);
    float c = rand(i + vec2(0.0, 1.0) + seed);
    float d = rand(i + vec2(1.0, 1.0) + seed);
    vec2 u = f * f * (3.0 - 2.0 * f);
    return mix(a, b, u.x) +
           (c - a) * u.y * (1.0 - u.x) +
           (d - b) * u.x * u.y;
}

vec3 get_land_color() {
    float r = max(0.0, 1.0 - water - plants);
    float g = plants;
    float b = 0.2 * (1.0 - water);
    return vec3(r, g, b);
}

vec3 get_water_color() {
    return vec3(0.0, 0.0, water);
}

void fragment() {
    float n = noise(UV * grid_size);
    vec3 land = get_land_color();
    vec3 water_col = get_water_color();
    vec3 color = mix(land, water_col, smoothstep(water - 0.1, water + 0.1, n));

    float radius = 0.5;
    float mask = step(distance(UV, vec2(0.5)), radius);
    COLOR = vec4(color, mask);
}
