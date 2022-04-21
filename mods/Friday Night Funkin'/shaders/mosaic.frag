#pragma header
uniform vec2 uBlocksize = vec2(3, 3);
uniform bool small = false;

void main()
{
	// was taken from the mosaic effect but was edited to prevent blur
    // pain
    vec2 blocks = openfl_TextureSize / uBlocksize;
    if (small)
        // fuck you
        gl_FragColor = texture2D(bitmap, openfl_TextureCoordv);
    else
        gl_FragColor = texture2D(bitmap, floor(openfl_TextureCoordv * blocks) / blocks);
}