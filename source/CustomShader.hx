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
    public function new(shader:String, values:Map<String, Any>) {
        try {
            var splittedShaderPath = shader.split(":");
            if (splittedShaderPath.length == 1) {
                splittedShaderPath.insert(0, "Friday Night Funkin'");
            } else if (splittedShaderPath.length == 0) {
                splittedShaderPath = ["Friday Night Funkin'", "blammed"];
            }
            var mod = splittedShaderPath[0];
            var shader = splittedShaderPath[1];
            var mPath = Paths.modsPath;
            var path = '$mPath/$mod/shaders/$shader';
    
            if (Path.extension(path) == "") path += '.glsl';
            if (FileSystem.exists(path)) {
                var c = (File.getContent(path));
                #if trace_everything trace(c); #end
                glFragmentSource = c;
            } else {
                trace("No file");
            }
            super();
            __glSourceDirty = true;
            program = null;
            @:privateAccess
            __initGL();
    
    
            setValues(values);
        } catch(e:Exception) {
            trace(e);
            trace(e.message);
            trace(e.stack);
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
            var d:ShaderParameter<Dynamic> = Reflect.field(data, name);
            Reflect.setProperty(d, "value", [value]);
        }
    }

    public function setValues(values:Map<String, Any>) {
        if (values == null) return;
        
        var kInt = values.keys();
        while(kInt.hasNext()) {
            var key = kInt.next();
            Reflect.setProperty(Reflect.field(data, key), "value", [values[key]]);
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