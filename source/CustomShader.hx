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
import openfl.display.DisplayObject;
import openfl.events.EventDispatcher;

using StringTools;

// DOESNT WORKS !!!!

 /* abstract CustomShader(FlxFixedShader) from FlxFixedShader {
    public function new(frag:String, vert:String, values:Map<String, Any>) {
        this = new FlxFixedShader(false);
        var mPath = Paths.modsPath;

        var fragPath = "";
        var vertPath = "";
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
    
            if (Path.extension(fragPath) == "") fragPath += '.frag';
        }

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
        this.glVertexSource = "#pragma header


        attribute float alpha;
        attribute vec4 colorMultiplier;
        attribute vec4 colorOffset;
        uniform bool hasColorTransform;
        
        void main(void)
        {
            openfl_Alphav = openfl_Alpha;
            openfl_TextureCoordv = openfl_TextureCoord;

            if (openfl_HasColorTransform) {

                    openfl_ColorMultiplierv = openfl_ColorMultiplier;
                    openfl_ColorOffsetv = openfl_ColorOffset / 255.0;

            }

            gl_Position = openfl_Matrix * openfl_Position;


            openfl_Alphav = openfl_Alpha * alpha;

            if (hasColorTransform)
            {
                    openfl_ColorOffsetv = colorOffset / 255.0;
                    openfl_ColorMultiplierv = colorMultiplier;
            }
        }".replace("#pragma body", Templates.entireFuckingCustomVertexBody).replace("#pragma header", Templates.entireFuckingCustomVertexHeader);

        this.glFragmentSource = "
        #pragma header
    
        void main(void)
        {
            gl_FragColor = flixel_texture2D(bitmap, openfl_TextureCoordv);
        }".replace("#pragma body", Templates.entireFuckingCustomFragmentBody).replace("#pragma header", Templates.entireFuckingCustomFragmentHeader).replace(" attribute ", " uniform ");

        if (fragPath.trim() != "" && FileSystem.exists(fragPath)) this.glFragmentSource = File.getContent(fragPath).replace("#pragma body", Templates.entireFuckingCustomFragmentBody).replace("#pragma header", Templates.entireFuckingCustomFragmentHeader).replace(" attribute ", " uniform ");
        
        if (vertPath.trim() != "" && FileSystem.exists(vertPath)) {
            var vert = File.getContent(vertPath);
            this.glVertexSource = (vert.replace("#pragma body", Templates.entireFuckingCustomVertexBody).replace("#pragma header", Templates.entireFuckingCustomVertexHeader));
        }

        trace("vertex source");
        trace(this.glVertexSource);
        trace("\n");
        trace("fragment source");
        trace(this.glFragmentSource);

    }

    // @:op(a.b) public function fieldRead(name:String):Any {
    //     @:privateAccess
    //     for (b in this.__inputBitmapData) {
    //         @:privateAccess
    //         var n = b.name;
    //         #if trace_everything trace(n); #end
    //         if (name == n) {
    //             return b;
    //         }
    //     }
    //     @:privateAccess
    //     for (b in this.__paramBool) {
    //         @:privateAccess
    //         var n = b.name;
    //         #if trace_everything trace(n); #end
    //         if (name == n) {
    //             return b;
    //         }
    //     }
    //     @:privateAccess
    //     for (b in this.__paramInt) {
    //         @:privateAccess
    //         var n = b.name;
    //         #if trace_everything trace(n); #end
    //         if (name == n) {
    //             return b;
    //         }
    //     }
    //     @:privateAccess
    //     for (b in this.__paramFloat) {
    //         @:privateAccess
    //         var n = b.name;
    //         #if trace_everything trace(n); #end
    //         if (name == n) {
    //             return b;
    //         }
    //     }
    //     var pro = null;
    //     if ((pro = Reflect.getProperty(this, name)) != null) {
    //         return pro;
    //     }
    //     return null;
    // }

    // @:op(a.b) public function fieldWrite(name:String, value:Any) {
    //     if (Std.isOfType(value, openfl.display.ShaderInput_openfl_display_BitmapData)) {
    //         var val = cast(value, openfl.display.ShaderInput_openfl_display_BitmapData);
    //         @:privateAccess
    //         for (e in this.__inputBitmapData) {
    //             @:privateAccess
    //             if (e.name == name) {
    //                 this.__inputBitmapData.remove(e);
    //                 break;
    //             }
    //         }
    //         @:privateAccess
    //         val.name = name;
    //         @:privateAccess
    //         this.__inputBitmapData.push(value);
    //         return;
    //     }

    //     if (Std.isOfType(value, openfl.display.ShaderParameter_Bool)) {
    //         var val = cast(value, openfl.display.ShaderParameter_Bool);
    //         @:privateAccess
    //         for (e in this.__paramBool) {
    //             @:privateAccess
    //             if (e.name == name) {
    //                 this.__paramBool.remove(e);
    //                 break;
    //             }
    //         }
    //         @:privateAccess
    //         val.name = name;
    //         @:privateAccess
    //         this.__paramBool.push(value);
    //         return;
    //     }

    //     if (Std.isOfType(value, openfl.display.ShaderParameter_Int)) {
    //         var val = cast(value, openfl.display.ShaderParameter_Int);
    //         @:privateAccess
    //         for (e in this.__paramInt) {
    //             @:privateAccess
    //             if (e.name == name) {
    //                 this.__paramInt.remove(e);
    //                 break;
    //             }
    //         }
    //         @:privateAccess
    //         val.name = name;
    //         @:privateAccess
    //         this.__paramInt.push(value);
    //         return;
    //     }

    //     if (Std.isOfType(value, openfl.display.ShaderParameter_Float)) {
    //         var val = cast(value, openfl.display.ShaderParameter_Float);
    //         @:privateAccess
    //         for (e in this.__paramFloat) {
    //             @:privateAccess
    //             if (e.name == name) {
    //                 this.__paramFloat.remove(e);
    //                 break;
    //             }
    //         }
    //         @:privateAccess
    //         val.name = name;
    //         @:privateAccess
    //         this.__paramFloat.push(value);
    //         return;
    //     }

    //     Reflect.setField(this, name, value);
    // }
} */

// class CustomShader_old extends FlxFixedShader {
class CustomShader extends FlxFixedShader {
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
        var mPath = Paths.modsPath;

        var fragPath = "";
        var vertPath = "";
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
    
            if (Path.extension(fragPath) == "") fragPath += '.frag';
        }

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
        this.glVertexSource = "#pragma header


        attribute float alpha;
        attribute vec4 colorMultiplier;
        attribute vec4 colorOffset;
        uniform bool hasColorTransform;
        
        void main(void)
        {
            openfl_Alphav = openfl_Alpha;
            openfl_TextureCoordv = openfl_TextureCoord;

            if (openfl_HasColorTransform) {

                    openfl_ColorMultiplierv = openfl_ColorMultiplier;
                    openfl_ColorOffsetv = openfl_ColorOffset / 255.0;

            }

            gl_Position = openfl_Matrix * openfl_Position;


            openfl_Alphav = openfl_Alpha * alpha;

            if (hasColorTransform)
            {
                    openfl_ColorOffsetv = colorOffset / 255.0;
                    openfl_ColorMultiplierv = colorMultiplier;
            }
        }".replace("#pragma body", Templates.entireFuckingCustomVertexBody).replace("#pragma header", Templates.entireFuckingCustomVertexHeader);

        this.glFragmentSource = "
        #pragma header
    
        void main(void)
        {
            gl_FragColor = flixel_texture2D(bitmap, openfl_TextureCoordv);
        }".replace("#pragma body", Templates.entireFuckingCustomFragmentBody).replace("#pragma header", Templates.entireFuckingCustomFragmentHeader).replace(" attribute ", " uniform ");

        if (fragPath.trim() != "" && FileSystem.exists(fragPath)) this.glFragmentSource = File.getContent(fragPath).replace("#pragma body", Templates.entireFuckingCustomFragmentBody).replace("#pragma header", Templates.entireFuckingCustomFragmentHeader).replace(" attribute ", " uniform ");
        
        if (vertPath.trim() != "" && FileSystem.exists(vertPath)) {
            var vert = File.getContent(vertPath);
            this.glVertexSource = (vert.replace("#pragma body", Templates.entireFuckingCustomVertexBody).replace("#pragma header", Templates.entireFuckingCustomVertexHeader));
        }

            super();


            // custom = true;
            // var glVertexSource = "#pragma header
		
            // attribute float alpha;
            // attribute vec4 colorMultiplier;
            // attribute vec4 colorOffset;
            // uniform bool hasColorTransform;
            
            // void main(void)
            // {
            //     #pragma body
                
            //     openfl_Alphav = openfl_Alpha * alpha;
                
            //     if (hasColorTransform)
            //     {
            //         openfl_ColorOffsetv = colorOffset / 255.0;
            //         openfl_ColorMultiplierv = colorMultiplier;
            //     }
            // }";

            // var glFragmentSource = "#pragma header
		
            // void main(void)
            // {
            //     gl_FragColor = flixel_texture2D(bitmap, openfl_TextureCoordv);
            // }";

            // if (vertPath.trim() != "" && FileSystem.exists(vertPath)) glVertexSource = File.getContent(vertPath);
            // if (fragPath.trim() != "" && FileSystem.exists(fragPath)) glFragmentSource = File.getContent(fragPath);
            
            // // __glSourceDirty = true;
            // // if (__glSourceDirty || __paramBool == null)
            // // {
            //     __glSourceDirty = false;
            //     program = null;
    
            //     __inputBitmapData = new Array();
            //     __paramBool = new Array();
            //     __paramFloat = new Array();
            //     __paramInt = new Array();
    
            //     __processGLData(glVertexSource, "attribute");
            //     __processGLData(glVertexSource, "uniform");
            //     __processGLData(glFragmentSource, "uniform");
            // // }
            // initGood(glFragmentSource, glVertexSource);

            // // setValues(values);
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