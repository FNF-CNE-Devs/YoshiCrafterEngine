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
    public static var template:String = '
#version 120
#ifdef GL_ES
    #ifdef GL_FRAGMENT_PRECISION_HIGH
        precision highp float;
    #else
        precision mediump float;
    #endif
#endif

#pragma header
		
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
}

#version 120
#ifdef GL_ES
    #ifdef GL_FRAGMENT_PRECISION_HIGH
        precision highp float;
    #else
        precision mediump float;
    #endif
#endif

uniform bool hasTransform;
uniform bool hasColorTransform;
vec4 flixel_texture2D(sampler2D bitmap, vec2 coord)
{
    vec4 color = texture2D(bitmap, coord);
    if (!hasTransform)
    {
        return color;
    }
    if (color.a == 0.0)
    {
        return vec4(0.0, 0.0, 0.0, 0.0);
    }
    if (!hasColorTransform)
    {
        return color * openfl_Alphav;
    }
    color = vec4(color.rgb / color.a, color.a);
    mat4 colorMultiplier = mat4(0);
    colorMultiplier[0][0] = openfl_ColorMultiplierv.x;
    colorMultiplier[1][1] = openfl_ColorMultiplierv.y;
    colorMultiplier[2][2] = openfl_ColorMultiplierv.z;
    colorMultiplier[3][3] = openfl_ColorMultiplierv.w;
    color = clamp(openfl_ColorOffsetv + (color * colorMultiplier), 0.0, 1.0);
    if (color.a > 0.0)
    {
        return vec4(color.rgb * color.a * openfl_Alphav, color.a * openfl_Alphav);
    }
    return vec4(0.0, 0.0, 0.0, 0.0);
}

{0}';
    public function new(shader:String, values:Map<String, Any>) {
        var splittedShaderPath = shader.split(":");
        if (splittedShaderPath.length == 1) {
            splittedShaderPath.insert(0, "Friday Night Funkin'");
        } else if (splittedShaderPath.length == 0) {
            splittedShaderPath = ["Friday Night Funkin'", "blammed"];
        }
        var mod = splittedShaderPath[0];
        var shader = splittedShaderPath[1];
        var mPath = Paths.getModsFolder();
        var path = '$mPath/$mod/shaders/$shader';

        if (Path.extension(path) == "") path += '.glsl';
        if (FileSystem.exists(path)) {
            var c = template.replace("{0}", File.getContent(path));
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
        if (Reflect.hasField(data, name)) {
            var d:ShaderParameter<Dynamic> = Reflect.field(data, name);
            Reflect.setField(d, "value", [value]);
        }
    }

    public function setValues(values:Map<String, Any>) {
        if (values == null) return;
        
        var kInt = values.keys();
        while(kInt.hasNext()) {
            var key = kInt.next();
            Reflect.setField(Reflect.field(data, key), "value", [values[key]]);
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