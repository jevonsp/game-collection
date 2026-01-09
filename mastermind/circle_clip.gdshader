// circular_clip.shader
shader_type canvas_item;

uniform float radius = 0.3;

void fragment() {
	// Simple circular mask
	float dist = distance(UV, vec2(0.5));
	if (dist > radius) {
		discard;
	}
	// Keep the ColorRect's assigned color
}