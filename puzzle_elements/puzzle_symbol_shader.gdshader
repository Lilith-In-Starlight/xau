shader_type canvas_item;

// Texture must have 'Linear filter' enabled!

// Automatic smoothing
// independent of geometry and perspective

varying flat vec4 modulate;
uniform bool outline = false;

void vertex() {
	modulate = COLOR;
}

vec4 texturePointSmooth(sampler2D smp, vec2 uv, vec2 pixel_size)
{
	vec2 ddx = dFdx(uv);
	vec2 ddy = dFdy(uv);
	vec2 lxy = sqrt(ddx * ddx + ddy * ddy);
	
	vec2 uv_pixels = uv / pixel_size;
	
	vec2 uv_pixels_floor = round(uv_pixels) - vec2(0.5f);
	vec2 uv_dxy_pixels = uv_pixels - uv_pixels_floor;
	
	uv_dxy_pixels = clamp((uv_dxy_pixels - vec2(0.5f)) * pixel_size / lxy + vec2(0.5f), 0.0f, 1.0f);
	
	uv = uv_pixels_floor * pixel_size;
	
	return textureGrad(smp, uv + uv_dxy_pixels * pixel_size, ddx, ddy);
}

void fragment()
{
	COLOR = texturePointSmooth(TEXTURE, UV, TEXTURE_PIXEL_SIZE) * modulate;	
	if (COLOR.a <= 0.0001 && outline) {
		for (float x = -1.0; x <= 1.0; x++) {
			for(float y = -1.0; y <= 1.0; y++){
				if (abs(x - y) < 0.0001 && x < 0.0001) {
				}
				if (texturePointSmooth(TEXTURE, UV + vec2(x, y) * TEXTURE_PIXEL_SIZE * 0.5, TEXTURE_PIXEL_SIZE).a > 0.0) {
					COLOR = modulate * 0.5;
					COLOR.a = 1.0;
				}
			}
		}
	}
}