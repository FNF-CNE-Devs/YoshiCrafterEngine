import EngineSettings.Settings;
import flixel.system.FlxAssets.FlxShader;

class ColoredNoteShader extends FlxFixedShader {
    @:glFragmentSource('#pragma header

        uniform float r;
        uniform float g;
        uniform float b;
        uniform bool enabled;
        
        uniform bool blurEnabled;
        uniform float x;
        uniform float y;
        uniform int passes;
        
        void main() {
            vec2 coordinates = openfl_TextureCoordv;
            vec4 finalColor = flixel_texture2D(bitmap, openfl_TextureCoordv);
            if (enabled) {
                if (blurEnabled) {
                    // real stuff
                    float r = 0;
                    float g = 0;
                    float b = 0;
                    float a = 0;
                    float t = 0;
            
                    float realX = x / openfl_TextureSize.x;
                    float realY = y / openfl_TextureSize.y;
                    for (int i = -passes; i < passes; ++i) {
                        vec4 color = flixel_texture2D(bitmap, vec2(openfl_TextureCoordv.x + (i * realX / passes), openfl_TextureCoordv.y + (i * realY / passes)));
                        r += color.r;
                        g += color.g;
                        b += color.b;
                        a += color.a;
                        ++t;
                    }
            
                    finalColor = vec4(r / t, g / t, b / t, a / t);
                }

                float diff = finalColor.r - ((finalColor.g + finalColor.b) / 2.0);
                gl_FragColor = vec4(((finalColor.g + finalColor.b) / 2.0) + (r * diff), finalColor.g + (g * diff), finalColor.b + (b * diff), finalColor.a);
                
            } else {
                if (blurEnabled) {
                    // real stuff
                    float r = 0;
                    float g = 0;
                    float b = 0;
                    float a = 0;
                    float t = 0;
            
                    float realX = x / openfl_TextureSize.x;
                    float realY = y / openfl_TextureSize.y;
                    for (int i = -passes; i < passes; ++i) {
                        vec4 color = flixel_texture2D(bitmap, vec2(openfl_TextureCoordv.x + (i * realX / passes), openfl_TextureCoordv.y + (i * realY / passes)));
                        r += color.r;
                        g += color.g;
                        b += color.b;
                        a += color.a;
                        ++t;
                    }
                    finalColor = vec4(r / t, g / t, b / t, a / t);
                }
                gl_FragColor = finalColor;
            }
            
        }
    ')
    public function new(r:Int, g:Int, b:Int, motion_blur:Null<Bool> = null, passes:Int = 10) {
        super();
        setColors(r, g, b);
        if (motion_blur == null) motion_blur = (PlayState.current != null ? PlayState.current.engineSettings.noteMotionBlurEnabled : Settings.engineSettings.data.noteMotionBlurEnabled);
        this.enabled.value = [true];
        this.blurEnabled.value = [motion_blur];
        this.y.value = [0.0075];
        this.passes.value = [passes];
    }

    public function setColors(r:Int, g:Int, b:Int) {
        this.r.value = [r / 255];
        this.g.value = [g / 255];
        this.b.value = [b / 255];
    }
}