== DROP YOUR SHADER FILES HERE ==

Shaders files are either .vert files or .frag files depending on the type of shader.

Example Tree:
└───shaders
    │   My Custom Shader.frag
    │   My Custom Shader.vert

Shaders can be used in-game this way:

[HAXE]	new CustomShader(Paths.shader("My Custom Shader"));
[LUA]	createShader("My Custom Shader")