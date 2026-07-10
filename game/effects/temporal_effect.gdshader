shader_type canvas_item;

uniform sampler2D screen_texture : hint_screen_texture, repeat_disable, filter_linear;
uniform float intensity : hint_range(0.0, 1.0) = 0.0;

void fragment() {
    vec2 wave = vec2(
        sin(SCREEN_UV.y * 90.0 + TIME * 18.0),
        cos(SCREEN_UV.x * 55.0 - TIME * 13.0)
    ) * 0.0035 * intensity;
    vec2 split = vec2(0.006 * intensity, 0.0);
    float red = texture(screen_texture, SCREEN_UV + wave + split).r;
    float green = texture(screen_texture, SCREEN_UV + wave).g;
    float blue = texture(screen_texture, SCREEN_UV + wave - split).b;
    float alpha = smoothstep(0.0, 0.15, intensity) * 0.82;
    COLOR = vec4(red, green, blue, alpha);
}
