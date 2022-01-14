import flixel.system.FlxAssets.FlxShader;

class ColoredNoteShader extends FlxShader {
    @:glFragmentSource('
        #pragma header

        uniform float r;
        uniform float g;
        uniform float b;
        uniform bool enabled = true;
        
        
        void main() {
            vec2 coordinates = openfl_TextureCoordv;
            vec4 finalColor = flixel_texture2D(bitmap, openfl_TextureCoordv);
            if (enabled) {
                
        
                float diff = finalColor.r - ((finalColor.g + finalColor.b) / 2);
                gl_FragColor = vec4(((finalColor.g + finalColor.b) / 2) + (r * diff), finalColor.g + (g * diff), finalColor.b + (b * diff), finalColor.a);
            } else {
                gl_FragColor = finalColor;
            }
        }
    ')
    public function new(r:Int, g:Int, b:Int) {
        super();
        setColors(r, g, b);
        this.enabled.value = [true];
    }

    public function setColors(r:Int, g:Int, b:Int) {
        this.r.value = [r / 255];
        this.g.value = [g / 255];
        this.b.value = [b / 255];
    }
}