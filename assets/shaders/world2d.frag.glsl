#version 330

in vec2 vert_uv;

layout(location=0) out vec4 col;
layout(location=1) out uint id;

uniform sampler2D tex;
uniform uint u_id;

// position (top left corner) and size: (x, y, width, height)
uniform vec4 tile_params;

void main() {
	// Compute UV inside main(); macOS GLSL Core 4.1 rejects globals that
	// reference `in`/`uniform` storage qualifiers.
	vec2 uv = vec2(
		vert_uv.x * tile_params.z + tile_params.x,
		vert_uv.y * tile_params.w + tile_params.y
	);
	vec4 tex_val = texture(tex, uv);
	int alpha = int(round(tex_val.a * 255));
	if (alpha == 0) {
		col = tex_val;
		discard;
	}
	else if (alpha == 254) {
		col = vec4(1.0, 0.0, 0.0, 1.0);
	}
	else if (alpha == 252) {
		col = vec4(0.0, 1.0, 0.0, 1.0);
	}
	else if (alpha == 250) {
		col = vec4(0.0, 0.0, 1.0, 1.0);
	}
	else {
		col = tex_val;
	}
	id = u_id;
}
