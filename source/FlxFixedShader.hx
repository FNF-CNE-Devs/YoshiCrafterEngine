import flixel.system.FlxAssets.FlxShader;

// goddamn prefix
class FlxFixedShader extends FlxShader {
    @:noCompletion private override function __initGL():Void
    {
        if (__glSourceDirty || __paramBool == null)
        {
            __glSourceDirty = false;
            program = null;

            __inputBitmapData = new Array();
            __paramBool = new Array();
            __paramFloat = new Array();
            __paramInt = new Array();

            __processGLData(glVertexSource, "attribute");
            __processGLData(glVertexSource, "uniform");
            __processGLData(glFragmentSource, "uniform");
        }

        if (__context != null && program == null)
        {
            initGLforce();
        }
    }

    public function initGLforce() {
        @:privateAccess
        var gl = __context.gl;

        #if (js && html5)
        var prefix = (precisionHint == FULL ? "precision mediump float;\n" : "precision lowp float;\n");
        #else
        var prefix = "#version 120\n#ifdef GL_ES\n"
            + (precisionHint == FULL ? "#ifdef GL_FRAGMENT_PRECISION_HIGH\n"
                + "precision highp float;\n"
                + "#else\n"
                + "precision mediump float;\n"
                + "#endif\n" : "precision lowp float;\n")
            + "#endif\n\n";
        #end

        var vertex = prefix + glVertexSource;
        var fragment = prefix + glFragmentSource;

        var id = vertex + fragment;
        @:privateAccess
        if (__context.__programs.exists(id))
        {   
            @:privateAccess
            program = __context.__programs.get(id);
        }
        else
        {
            program = __context.createProgram(GLSL);

            // TODO
            // program.uploadSources (vertex, fragment);
            @:privateAccess
            program.__glProgram = __createGLProgram(vertex, fragment);

            @:privateAccess
            __context.__programs.set(id, program);
        }

        if (program != null)
        {
            @:privateAccess
            glProgram = program.__glProgram;

            for (input in __inputBitmapData)
            {
                @:privateAccess
                if (input.__isUniform)
                {
                    @:privateAccess
                    input.index = gl.getUniformLocation(glProgram, input.name);
                }
                else
                {
                    @:privateAccess
                    input.index = gl.getAttribLocation(glProgram, input.name);
                }
            }

            for (parameter in __paramBool)
            {
                @:privateAccess
                if (parameter.__isUniform)
                {
                    @:privateAccess
                    parameter.index = gl.getUniformLocation(glProgram, parameter.name);
                }
                else
                {
                    @:privateAccess
                    parameter.index = gl.getAttribLocation(glProgram, parameter.name);
                }
            }

            for (parameter in __paramFloat)
            {
                @:privateAccess
                if (parameter.__isUniform)
                {
                    @:privateAccess
                    parameter.index = gl.getUniformLocation(glProgram, parameter.name);
                }
                else
                {
                    @:privateAccess
                    parameter.index = gl.getAttribLocation(glProgram, parameter.name);
                }
            }

            for (parameter in __paramInt)
            {
                @:privateAccess
                if (parameter.__isUniform)
                {
                    @:privateAccess
                    parameter.index = gl.getUniformLocation(glProgram, parameter.name);
                }
                else
                {
                    @:privateAccess
                    parameter.index = gl.getAttribLocation(glProgram, parameter.name);
                }
            }
        }
    }
}