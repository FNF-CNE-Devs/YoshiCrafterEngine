package dev_toolbox.sparrow_optimization;

import sys.thread.Thread;
import ZipUtils.ZipProgress;
import haxe.Exception;
import openfl.display.PNGEncoderOptions;
import openfl.geom.Rectangle;
import sys.io.File;
import openfl.display.BitmapData;
import flixel.graphics.frames.FlxAtlasFrames;
import haxe.io.Path;
import sys.FileSystem;

class SparrowOptimization {
    public static function optimizeAsync(parentPath:String):ZipProgress {
        var prog = new ZipProgress();
        Thread.create(function() {
            optimize(parentPath, prog);
        });
        return prog;
    }
    public static function optimize(parentPath:String, ?prog:ZipProgress):ZipProgress {
        if (prog == null)
            prog = new ZipProgress();

        var paths = [parentPath];
        var files = [];
        
        var doFolder:Void->Void = null; (doFolder = function() {
            var path = paths.join("/");
            for(p in FileSystem.readDirectory(path)) {
                if (FileSystem.isDirectory('$path/$p')) {
                    paths.push(p);
                    doFolder();
                    paths.pop();
                } else {
                    var ext = Path.extension(p).toLowerCase();
                    if (ext.toLowerCase() == "png") {
                        var withoutExt = Path.withoutExtension(p);
                        if (FileSystem.exists('$path/$withoutExt.xml')) 
                            files.push('$path/$withoutExt');
                    }
                }
            }
        })();

        prog.fileCount = files.length;

        for(k=>f in files) {
            prog.curFile = k;
            try {
                // will get the furthest bottom right corner then resize the image so that it doesnt go further than it
                var bmap = BitmapData.fromFile('$f.png');
                var frames = FlxAtlasFrames.fromSparrow(bmap, File.getContent('$f.xml'), false);

                var maxWidth:Float = 0;
                var maxHeight:Float = 0;
                for(f in frames.frames) {
                    var w = f.frame.x + f.frame.width;
                    var h = f.frame.y + f.frame.height;
                    if (w > maxWidth) maxWidth = w;
                    if (h > maxHeight) maxHeight = h;
                }

                var width:Int = Math.ceil(maxWidth);
                var height:Int = Math.ceil(maxHeight);

                File.saveBytes('$f.png', bmap.encode(new Rectangle(0, 0, maxWidth, maxHeight), new PNGEncoderOptions(false)));

                // free memory
                frames.destroy();
            } catch(e) {
                trace(e.details());
            }
        }

        prog.done = true;
        return prog;
    }
}