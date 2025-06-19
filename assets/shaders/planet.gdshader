shader_type canvas_item;

uniform float seed = 0.0;
uniform float water = 0.5;
uniform float plants = 0.5;
uniform float grid_size = 10.0;

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
    vec2 cell = floor(UV * grid_size);
    float rnd = fract(sin(dot(cell + seed, vec2(12.9898, 78.233))) * 43758.5453);
    vec3 color = (rnd < water) ? get_water_color() : get_land_color();
    COLOR = vec4(color, 1.0);
}
