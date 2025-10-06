shader_type canvas_item;

uniform float strength : hint_range(0.0, 1.0) = 0.5;
uniform float radius : hint_range(0.0, 2.0) = 1.5;
uniform float softness : hint_range(0.0, 1.0) = 0.5;
uniform vec4 vignette_color : source_color = vec4(0.75, 0.15, 0.0, 1.0);

void fragment() {
    vec2 uv = UV - 0.5;
    float dist = length(uv) * 2.0;
    float vignette = smoothstep(radius, radius - softness, dist);
    COLOR = vignette_color;
    COLOR.a = (1.0 - vignette) * strength;
}
