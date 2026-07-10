shader_type canvas_item;

uniform float pixelation = 320.0;
uniform float color_depth = 8.0;
uniform float jitter = 0.01;

void fragment() {
    vec2 uv = SCREEN_UV;
    uv = floor(uv * pixelation) / pixelation;
    uv.x += sin(TIME * 10.0 + uv.y * 10.0) * jitter * 0.1;
    vec4 color = texture(SCREEN_TEXTURE, uv);
    color.rgb = floor(color.rgb * color_depth) / color_depth;
    float scanline = sin(uv.y * pixelation * 2.0) * 0.1;
    color.rgb -= scanline;
    COLOR = color;
}
