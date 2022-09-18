package macros;

import ZipUtils;
import haxe.macro.Compiler;
import sys.io.File;
import sys.FileSystem;

class TemplateMod {
    #if macro
    public macro function zipDefaultMod() {
        trace("Zipping template mod...");
        var zipWriter = ZipUtils.createZipFile("template_mod.zip");
        ZipUtils.writeFolderToZip(zipWriter, "./template_mod/", "", null, ["readme.txt"]);
        zipWriter.flush();
        zipWriter.close();
        trace("Template mod successfully zipped.");

        var folder = '${Compiler.getOutput()}/../bin/assets/misc';
        FileSystem.createDirectory(folder);
        File.copy('template_mod.zip', '$folder/template_mod.zip');
        return $v{null};
    }
    #end
}