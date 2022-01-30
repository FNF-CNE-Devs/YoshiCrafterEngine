import llua.LuaL;
import flixel.FlxState;
import Script.LuaScript;

class LuaTest extends FlxState {
    public override function new() {
        super();
        var l = new LuaScript();
        // LuaL.dostring(l.state, "print(\"hey\")");
        trace("load file");
        l.loadFile("test.lua");
        trace("exec func");
        l.setVariable("test", "lol");
        trace(l.executeFunc("re"));
    }
}