shader_type canvas_item;

uniform sampler2D noise : repeat_enable;

uniform vec2 scroll = vec2(.05,.05);

void fragment() {
	vec4 noise_col = texture(noise,UV + scroll * TIME);
	COLOR = noise_col;
}
