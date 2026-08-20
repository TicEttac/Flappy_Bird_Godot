shader_type canvas_item;

uniform float scroll_offset = 0.0;

void vertex() {
		UV.x += scroll_offset;
}
