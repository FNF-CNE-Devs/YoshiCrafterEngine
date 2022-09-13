package dev_toolbox;

import lime.system.BackgroundWorker;
import lime.ui.FileDialog;
import lime._internal.backend.native.NativeCFFI;

class FileDialogExt extends FileDialog {
    public function openSaveDialog(callback:String->Void, filter:String = null, defaultPath:String = null, title:String = null, type:String = "application/octet-stream"):Bool
    {
        if (callback == null)
        {
            onCancel.dispatch();
            return false;
        }

        #if desktop
        var worker = new BackgroundWorker();

        worker.doWork.add(function(_)
        {
            #if linux
            if (title == null) title = "Save File";
            #end

            @:privateAccess
            worker.sendComplete(NativeCFFI.lime_file_dialog_save_file(title, filter, defaultPath));
        });

        worker.onComplete.add(function(path:String)
        {
            if (path != null)
            {
                try
                {
                    callback(path);
                    return;
                }
                catch (e:Dynamic) {}
            }

            onCancel.dispatch();
        });

        worker.run();

        return true;
        #end
    }
}