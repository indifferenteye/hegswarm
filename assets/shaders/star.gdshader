shader_type canvas_item;

uniform float seed = 0.0;
uniform float grid_size = 10.0;

void fragment() {
    vec2 cell = floor(UV * grid_size);
    float rnd = fract(sin(dot(cell + seed, vec2(12.9898, 78.233))) * 43758.5453);
    vec3 color = vec3(1.0);
    if (rnd < 0.33) {
        color = vec3(1.0, 0.0, 0.0); // red
    } else if (rnd < 0.66) {
        color = vec3(1.0, 1.0, 0.0); // yellow
    }
    float radius = 0.5;
    float mask = step(distance(UV, vec2(0.5)), radius);
    COLOR = vec4(color, mask);
}
