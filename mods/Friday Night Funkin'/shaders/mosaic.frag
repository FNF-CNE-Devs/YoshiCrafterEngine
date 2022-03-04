#pragma header
uniform vec2 uBlocksize;

void main()
{
	// was taken from the mosaic effect but was edited to prevent blur
    // pain
    vec2 blocks = openfl_TextureSize / uBlocksize;
    gl_FragColor = texture2D(bitmap, floor(openfl_TextureCoordv * blocks) / blocks - (uBlocksize / openfl_TextureSize / 2));
}