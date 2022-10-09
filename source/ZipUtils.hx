#if !macro
import dev_toolbox.ProgressBarWindow.IProgressObject;
import openfl.display.BitmapData;
#end

import haxe.Exception;
import haxe.Json;
import haxe.crypto.Crc32;
import haxe.zip.Writer;
import haxe.zip.Tools;
import haxe.zip.Entry;
import haxe.zip.Uncompress;
import haxe.zip.Reader;
import haxe.zip.Compress;
import sys.FileSystem;
import sys.io.File;
import sys.thread.Thread;

using StringTools;

// import ZipUtils; ZipUtils.uncompressZip(ZipUtils.openZip("E:\\Desktop\\test\\termination lua.ycemod"), "E:\\Desktop\\test\\uncompressed\\");
// import ZipUtils; var e = ZipUtils.createZipFile("gjnsdghs.ycemod"); ZipUtils.writeFolderToZip(e, "./mods/Friday Night Funkin'/", "Friday Night Funkin'/"); e.flush(); e.close();

class ZipUtils {
    public static var bannedNames:Array<String> = [".git", ".gitignore", ".github", ".vscode", ".gitattributes", "readme.txt"];

	/**
	 * [Description] Uncompresses `zip` into the `destFolder` folder
	 * @param zip 
	 * @param destFolder 
	 */
	public static function uncompressZip(zip:Reader, destFolder:String, ?prefix:String, ?prog:ZipProgress):ZipProgress {
		// we never know
		FileSystem.createDirectory(destFolder);

        var fields = zip.read();

        try {
            trace("bruh");
            if (prefix != null) {
                var f = fields;
                fields = new List<Entry>();
                for(field in f) {
                    if (field.fileName.startsWith(prefix)) {
                        fields.push(field);
                    }
                }
            }
    
            trace("bruh2");
    
            if (prog == null)
                prog = new ZipProgress();
            prog.fileCount = fields.length;
            for(k=>field in fields) {
                prog.curFile = k;
                var isFolder = field.fileName.endsWith("/") && field.fileSize == 0;
                if (isFolder) {
                    FileSystem.createDirectory('${destFolder}/${field.fileName}');
                } else {
                    var split = [for(e in field.fileName.split("/")) e.trim()];
                    split.pop();
                    FileSystem.createDirectory('${destFolder}/${split.join("/")}');
                    
                    var data = unzip(field);
                    File.saveBytes('${destFolder}/${field.fileName}', data);
                }
            }
            prog.curFile = fields.length;
            prog.done = true;
        } catch(e) {
            prog.done = true;
            prog.error = e;
        }
        return prog;
	}

    #if !macro
    public static function uncompressZipAsync(zip:Reader, destFolder:String, ?prog:ZipProgress, ?prefix:String):ZipProgress {
        if (prog == null)
            prog = new ZipProgress();
        Thread.create(function() {
            uncompressZip(zip, destFolder, prefix, prog);
        });
        return prog;
    }
    #end

    /**
     * [Description] Returns a `zip.Reader` instance from path.
     * @param zipPath 
     * @return Reader
     */
    public static function openZip(zipPath:String):Reader {
        return new ZipReader(File.read(zipPath));
    }

    #if !macro
    /**
     * [Description] Gets all mods from zip file (also works for .ycemod files)
     * @param zip Zip file
     * @return Array<ZipMod>
     */
    public static function getModsFromZip(zip:Reader):Array<ZipMod> {
        var mods:Array<ZipMod> = [];

        var fields = zip.read();
        var n = "";
        for(f in fields) {
            var splitName = [for(e in f.fileName.split("/")) if ((n = e.trim()) != "") n];
            if (splitName.length == 2 && splitName[1].toLowerCase() == "config.json" && f.fileSize > 0) {
                // config.json detected
                var mod:ZipMod = {
                    name: splitName[0],
                    config: null,
                    icon: null
                };
                var configData = unzip(f);
                var configJson = configData.getString(0, configData.length).trim();
                try {
                    mod.config = Json.parse(configJson);
                } catch(e) {
                    trace('Couldn\'t parse JSON at ${f.fileName}.');
                    trace(e.details());
                    continue;
                }
                var iconField:Entry = null;
                for(e in fields) {
                    if (e.fileName.toLowerCase() == '${splitName[0].toLowerCase()}/modicon.png') {
                        iconField = e;
                        break;
                    }
                }

                if (iconField != null)
                    mod.icon = BitmapData.fromBytes(unzip(iconField));
                
                mods.push(mod);
            }
        }

        return mods;
    }

    /**
     * [Description] Logs every file within the zip.
     * @param zip Zip reader
     */
    public static function logZipFiles(zip:Reader) {
        for(field in zip.read())
            trace('${field.fileName} - Size: ${CoolUtil.getSizeLabel(field.fileSize)} - Compressed: ${field.compressed} - Data Size: ${CoolUtil.getSizeLabel(field.dataSize)}');
    }
    #end

    /**
     * [Description] Copy of haxe's Zip unzip function cause lime replaced it.
     * @param f Zip entry
     */
    public static function unzip(f:Entry) {
		if (!f.compressed)
			return f.data;
		var c = new haxe.zip.Uncompress(-15);
		var s = haxe.io.Bytes.alloc(f.fileSize);
		var r = c.execute(f.data, 0, s, 0);
		c.close();
		if (!r.done || r.read != f.data.length || r.write != f.fileSize)
			throw "Invalid compressed data for " + f.fileName;
		f.compressed = false;
		f.dataSize = f.fileSize;
		f.data = s;
		return f.data;
	}

    /**
     * [Description] Creates a ZIP file at the specified location and returns the Writer.
     * @param path 
     * @return Writer
     */
    public static function createZipFile(path:String):ZipWriter {
        var output = File.write(path);
        return new ZipWriter(output);
    }

    /**
        [Description] Writes the entirety of a folder to a zip file.
        @param zip ZIP file to write to
        @param path Folder path
        @param prefix (Additional) allows you to set a prefix in the zip itself.
    **/
    public static function writeFolderToZip(zip:ZipWriter, path:String, ?prefix:String, ?prog:ZipProgress, ?whitelist:Array<String>):ZipProgress {
        if (prefix == null) prefix = "";
        if (whitelist == null) whitelist = [];
        if (prog == null) prog = new ZipProgress();

        try {
            var curPath:Array<String> = ['$path'];
            var destPath:Array<String> = [];
            if (prefix != "") {
                prefix = prefix.replace("\\", "/");
                while(prefix.charAt(0) == "/") prefix = prefix.substr(1);
                while(prefix.charAt(prefix.length-1) == "/") prefix = prefix.substr(0, prefix.length-1);
                destPath.push(prefix);
            }
    
            var files:Array<StrNameLabel> = [];
    
            var doFolder:Void->Void = null;
            (doFolder = function() {
                var path = curPath.join("/");
                var zipPath = destPath.join("/");
                for(e in FileSystem.readDirectory(path)) {
                    if (bannedNames.contains(e.toLowerCase()) && !whitelist.contains(e.toLowerCase())) continue;
                    if (FileSystem.isDirectory('$path/$e')) {
                        // is directory, so loop into that function again
                        for(p in [curPath, destPath]) p.push(e);
                        doFolder();
                        for(p in [curPath, destPath]) p.pop();
                    } else {
                        // is file, put it in the list
                        var zipPath = '$zipPath/$e';
                        while(zipPath.charAt(0) == "/") zipPath = zipPath.substr(1);
                        files.push(new StrNameLabel('$path/$e', zipPath));
                    }
                }
            })();
    
            prog.fileCount = files.length;
            for(k=>file in files) {
                prog.curFile = k;
    
                var fileContent = File.getBytes(file.name);
                var fileInfo = FileSystem.stat(file.name);
                var entry:Entry = {
                    fileName: file.label,
                    fileSize: fileInfo.size,
                    fileTime: Date.now(),
                    dataSize: 0,
                    data: fileContent,
                    crc32: Crc32.make(fileContent), // TODO???
                    compressed: false
                };
                Tools.compress(entry, 1);
                zip.writeFile(entry);
            }
            zip.writeCDR();
        } catch(e) {
            prog.error = e;
        }
        prog.done = true;
        return prog;
    }

    public static function writeFolderToZipAsync(zip:ZipWriter, path:String, ?prefix:String):ZipProgress {
        var zipProg = new ZipProgress();
        Thread.create(function() {
            writeFolderToZip(zip, path, prefix, zipProg);
        });
        return zipProg;
    }

    /**
     * [Description] Converts an `Array<Entry>` to a `List<Entry>`.
     * @param array 
     * @return List<Entry>
     */
    public static function arrayToList(array:Array<Entry>):List<Entry> {
        var list = new List<Entry>();
        for(e in array) list.push(e);
        return list;
    }
}

#if !macro
typedef ZipMod = {
    var name:String;
    var config:ModConfig;
    var icon:BitmapData;
}
class ZipProgress implements IProgressObject {
#else
class ZipProgress {
#end
    public var error:Exception = null;
    
    public var curFile:Int = 0;
    public var fileCount:Int = 0;
    public var done:Bool = false;
    public var percentage(get, null):Float;

    private function get_percentage() {
        return fileCount <= 0 ? 0 : curFile / fileCount;
    }

    public function new() {}
}

class ZipReader extends Reader {
    public var files:List<Entry>;

    public override function read() {
        if (files != null) return files;
        try {
            var files = super.read();
            return this.files = files;
        } catch(e) {
        }
        return new List<Entry>();
    }
}

class ZipWriter extends Writer {
    public function flush() {
        o.flush();
    }

    public function writeFile(entry:Entry) {
        writeEntryHeader(entry);
        o.writeFullBytes(entry.data, 0, entry.data.length);
    }

    public function close() {
        o.close();
    }
}

class StrNameLabel {
    public var name:String;
    public var label:String;

    public function new(name:String, label:String) {
        this.name = name;
        this.label = label;
    }
}