package macros;

import haxe.crypto.Md5;
import sys.io.File;

class Coconut {
    public static macro function getCoconutMD5():haxe.macro.Expr.ExprOf<String> {
        #if !display
        var hash = Md5.encode(File.getContent("assets/preload/images/coconut.png"));
        trace("coconut md5: " + hash);
        return macro $v{hash};
        #else
        return macro $v{""};
        #end
    }
}