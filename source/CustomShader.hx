import openfl.display.GraphicsShader;
import flixel.graphics.tile.FlxGraphicsShader;
import openfl.display.Shader;
import haxe.io.Bytes;
import openfl.display.ShaderParameter;
import haxe.Exception;
import sys.FileSystem;
import sys.io.File;
import flixel.system.FlxAssets.FlxShader;
import haxe.io.Path;

using StringTools;

// DOESNT WORKS !!!!
class CustomShader extends FlxFixedShader {
// class CustomShader {
    // public static function create() {
    //     var shader = new GraphicsShader([
    //         {
    //             src: null,
    //             fragment: false
    //         },
    //         {
    //             src: text,
    //             fragment: true
    //         }
    //     ]);
    // }
    public function new(frag:String, vert:String, values:Map<String, Any>) {
        try {
            var mPath = Paths.modsPath;

            var fragPath = "";
            if (frag != null) {
                var splittedFragPath = frag.split(":");
                if (splittedFragPath.length == 1) {
                    splittedFragPath.insert(0, "Friday Night Funkin'");
                } else if (splittedFragPath.length == 0) {
                    splittedFragPath = ["Friday Night Funkin'", "blammed"];
                }
                var fragMod = splittedFragPath[0];
                var fragName = splittedFragPath[1];
                fragPath = '$mPath/$fragMod/shaders/$fragName';
        
                if (Path.extension(fragPath) == "") fragPath += '.vert';
            }

            var vertPath = "";
            if (vert != null) {
                var splittedVertPath = vert.split(":");
                if (splittedVertPath.length == 1) {
                    splittedVertPath.insert(0, "Friday Night Funkin'");
                } else if (splittedVertPath.length == 0) {
                    splittedVertPath = ["Friday Night Funkin'", "blammed"];
                }
                var vertMod = splittedVertPath[0];
                var vertName = splittedVertPath[1];
                vertPath = '$mPath/$vertMod/shaders/$vertName';
        
                if (Path.extension(vertPath) == "") vertPath += '.vert';
            }
            


            super();
            var glVertexSource = "#pragma header
		
            attribute float alpha;
            attribute vec4 colorMultiplier;
            attribute vec4 colorOffset;
            uniform bool hasColorTransform;
            
            void main(void)
            {
                #pragma body
                
                openfl_Alphav = openfl_Alpha * alpha;
                
                if (hasColorTransform)
                {
                    openfl_ColorOffsetv = colorOffset / 255.0;
                    openfl_ColorMultiplierv = colorMultiplier;
                }
            }";

            var glFragmentSource = "#pragma header
		
            void main(void)
            {
                gl_FragColor = flixel_texture2D(bitmap, openfl_TextureCoordv);
            }";

            if (FileSystem.exists(vertPath)) glVertexSource = File.getContent(vertPath);
            if (FileSystem.exists(fragPath)) glFragmentSource = File.getContent(fragPath);
            
            initGood(glFragmentSource, glVertexSource);

            setValues(values);

        } catch(e:Exception) {
            trace(e);
            trace(e.message);
            trace(e.stack);
            trace(e.details());
        }
    }

    public function setValue(name:String, value:Dynamic) {
        // if (Reflect.hasField(this, name)) {
        //     var field = Reflect.field(this, name);
        //     trace("Field :");
        //     trace(field);
        //     if (Reflect.hasField(field, "value")) {
        //         Reflect.setField(field, "value", value);
        //     }
        // }
        if (Reflect.getProperty(data, name) != null) {
            var d:ShaderParameter<Dynamic> = Reflect.getProperty(data, name);
            Reflect.setProperty(d, "value", [value]);
        }
    }

    public function setValues(values:Map<String, Any>) {
        if (values == null) return;
        
        var kInt = values.keys();
        while(kInt.hasNext()) {
            var key = kInt.next();
            Reflect.setProperty(Reflect.getProperty(data, key), "value", [values[key]]);
        }

        /*
        this.
        for(value in Reflect.fields(values)) {
            if (Reflect.hasField(this, value)) {
                var field = Reflect.field(this, value);
                if (Reflect.hasField(field, "value")) {
                    Reflect.setField(field, "value", [Reflect.field(values, value)]);
                }
            }
        }
        */
        
    }
}