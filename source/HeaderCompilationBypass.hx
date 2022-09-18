// CLASS USED TO BYPASS HEADER COMPILATION SHIT! (cause hxcpp is dumb)
import WindowsAPI.MessageBoxIcon;
class HeaderCompilationBypass {
    public static function darkMode() {
        WindowsAPI.setWindowToDarkMode();
    }
    public static function enableVisualStyles() {
        WindowsAPI.enableVisualStyles();
    }
    public static function addFileAssoc() {
        WindowsAPI.addFileAssoc(Sys.programPath());
    }
    public static function setWindowIcon(icon:String) {
        WindowsAPI.setWindowIcon(icon);
    }
    public static function showMessagePopup(title:String, text:String, icon:MessageBoxIcon) {
        WindowsAPI.showMessagePopup(text, title, icon);
    }
    public static function showErrorHandler(_caption:String, _silly:String, _exception:String, _stack:String) {
        WindowsAPI.showErrorHandler(_caption, _silly, _exception, _stack);
    }
}