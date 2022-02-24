#pragma header

uniform float diffX = 0;
uniform float diffY = 0;

uniform float r = 0;
uniform float g = 0;
uniform float b = 0;
uniform float a = 0;

void main() {
	vec4 color = flixel_texture2D(bitmap, openfl_TextureCoordv);
	if (color.a < 0.1) {
		gl_FragColor = vec4(0.0, 0.0, 0.0, 0.0);
	} else {
		vec2 diff = vec2(diffX, diffY);
		vec4 diffColor = flixel_texture2D(bitmap, openfl_TextureCoordv + diff);
		float shadowAlpha = (1 - diffColor.a) * a;
		
		float nr = (color.r * (1 - shadowAlpha)) + (r * shadowAlpha);
		float ng = (color.g * (1 - shadowAlpha)) + (g * shadowAlpha);
		float nb = (color.b * (1 - shadowAlpha)) + (b * shadowAlpha);
		float na = color.a;
		gl_FragColor = vec4(nr, ng, nb, na);
	}
}