#if windows
@:buildXml('
<target id="haxe">
    <lib name="dwmapi.lib" if="windows" />
    <lib name="shell32.lib" if="windows" />
</target>
')

@:headerCode('
#pragma comment(linker,"/manifestdependency:\\"type=\'win32\' name=\'Microsoft.Windows.Common-Controls\' " "version=\'6.0.0.0\' processorArchitecture=\'*\' publicKeyToken=\'6595b64144ccf1df\' language=\'*\'\\"")
#include <Windows.h>
#include <cstdio>
#include <iostream>
#include <tchar.h>
#include <dwmapi.h>
#include <winuser.h>
#include <Shlobj.h>
')
@:cppFileCode('
bool transparencyEnabled = false;
')
#end
class WindowsAPI {
    // i have now learned the power of the windows api, FEAR ME!!!
    #if windows
    @:functionCode('
    HKEY hKey;
    LPCTSTR data;

    RegCreateKeyEx(HKEY_CURRENT_USER, "SOFTWARE\\\\Classes\\\\YoshiCrafterEngineMod", 0, NULL, REG_OPTION_NON_VOLATILE, KEY_WRITE, NULL, &hKey, NULL);

    char const *name = "YoshiCrafter Engine Mod";
    RegSetValueEx(hKey, "", 0, REG_SZ, (BYTE*)name, strlen(name));
    RegSetValueEx(hKey, "FriendlyTypeName", 0, REG_SZ, (BYTE*)name, strlen(name));


    RegCreateKeyEx(HKEY_CURRENT_USER, "SOFTWARE\\\\Classes\\\\YoshiCrafterEngineMod\\\\shell\\\\open\\\\command", 0, NULL, REG_OPTION_NON_VOLATILE, KEY_WRITE, NULL, &hKey, NULL);

    std::string value;
    value.append("\\"");
    value.append(path);
    value.append("\\" -install-mod \\"%1\\"");

    char const *val = value.c_str();
    RegSetValueEx(hKey, "", 0, REG_SZ, (BYTE*)val, strlen(val));

    HKEY ycemodKey = nullptr;
    if (RegOpenKeyEx(HKEY_CURRENT_USER, "SOFTWARE\\\\Classes\\\\.ycemod", 0, KEY_READ, &ycemodKey) != ERROR_SUCCESS) {
        RegCreateKeyEx(HKEY_CURRENT_USER, "SOFTWARE\\\\Classes\\\\.ycemod", 0, NULL, REG_OPTION_NON_VOLATILE, KEY_WRITE, NULL, &ycemodKey, NULL);

        char const *name = "YoshiCrafterEngineMod";
        RegSetValueEx(ycemodKey, "", 0, REG_SZ, (BYTE*)name, strlen(name));
        SHChangeNotify(0x08000000, 0x0000, nullptr, nullptr);
    }

    ')
    #end
    public static function addFileAssoc(path:String):Int {
        return 0;
    }
    #if windows
    @:functionCode('
    // https://stackoverflow.com/questions/15543571/allocconsole-not-displaying-cout

    if (!AllocConsole())
        return;

    FILE* fDummy;
    freopen_s(&fDummy, "CONOUT$", "w", stdout);
    freopen_s(&fDummy, "CONOUT$", "w", stderr);
    freopen_s(&fDummy, "CONIN$", "r", stdin);
    std::cout.clear();
    std::clog.clear();
    std::cerr.clear();
    std::cin.clear();

    // std::wcout, std::wclog, std::wcerr, std::wcin
    HANDLE hConOut = CreateFile(_T("CONOUT$"), GENERIC_READ | GENERIC_WRITE, FILE_SHARE_READ | FILE_SHARE_WRITE, NULL, OPEN_EXISTING, FILE_ATTRIBUTE_NORMAL, NULL);
    HANDLE hConIn = CreateFile(_T("CONIN$"), GENERIC_READ | GENERIC_WRITE, FILE_SHARE_READ | FILE_SHARE_WRITE, NULL, OPEN_EXISTING, FILE_ATTRIBUTE_NORMAL, NULL);
    SetStdHandle(STD_OUTPUT_HANDLE, hConOut);
    SetStdHandle(STD_ERROR_HANDLE, hConOut);
    SetStdHandle(STD_INPUT_HANDLE, hConIn);
    std::wcout.clear();
    std::wclog.clear();
    std::wcerr.clear();
    std::wcin.clear();
    ')
    public static function allocConsole() {
        LogsOverlay.consoleOpened = LogsOverlay.consoleVisible = true;
        haxe.Log.trace = function(v:Dynamic, ?infos:haxe.PosInfos) {
            // nothing here so that it keeps shit clean
        }
    }
    #else
    public static function allocConsole() {}
    #end


    #if windows
    @:functionCode('
        ShowWindow(GetConsoleWindow(), show ? 5 : 0);
    ')
    #end
    public static function showConsole(show:Bool) {
        haxe.Log.trace = show ? function(v:Dynamic, ?infos:haxe.PosInfos) {} : Main.baseTrace;
        LogsOverlay.consoleVisible = show;
    }
    #if windows
    @:functionCode('
        int darkMode = 1;
        HWND window = GetActiveWindow();
        if (S_OK != DwmSetWindowAttribute(window, 19, &darkMode, sizeof(darkMode))) {
            DwmSetWindowAttribute(window, 20, &darkMode, sizeof(darkMode));
        }
        UpdateWindow(window);
    ')
    #end
    public static function setWindowToDarkMode() {}


    #if windows
    @:functionCode('
        HWND window = GetActiveWindow();

        if (transparencyEnabled) {
            SetWindowLong(window, GWL_EXSTYLE, GetWindowLong(window, GWL_EXSTYLE) ^ WS_EX_LAYERED);
            SetLayeredWindowAttributes(window, RGB(0, 0, 0), 255, LWA_COLORKEY | LWA_ALPHA);
        }
        // make window layered
        int result = SetWindowLong(window, GWL_EXSTYLE, GetWindowLong(window, GWL_EXSTYLE) | WS_EX_LAYERED);
        if (alpha > 255) alpha = 255;
        if (alpha < 0) alpha = 0;
        SetLayeredWindowAttributes(window, RGB(red, green, blue), alpha, LWA_COLORKEY | LWA_ALPHA);
        alpha = result;
        transparencyEnabled = true;
    ')
    #end
    public static function setWindowTransparencyColor(red:Int, green:Int, blue:Int, alpha:Int = 255) {
        return alpha;
    }

    #if windows
    @:functionCode('
        if (!transparencyEnabled) return false;
        
        HWND window = GetActiveWindow();
        SetWindowLong(window, GWL_EXSTYLE, GetWindowLong(window, GWL_EXSTYLE) ^ WS_EX_LAYERED);
        SetLayeredWindowAttributes(window, RGB(0, 0, 0), 255, LWA_COLORKEY | LWA_ALPHA);
        transparencyEnabled = false;
    ')
    #end
    public static function disableWindowTransparency(result:Bool = true) {
        return result;
    }

    #if windows
    @:functionCode('
    HWND window = GetActiveWindow();
    HICON smallIcon = (HICON) LoadImage(NULL, path, IMAGE_ICON, 16, 16, LR_LOADFROMFILE);
    HICON icon = (HICON) LoadImage(NULL, path, IMAGE_ICON, 0, 0, LR_LOADFROMFILE | LR_DEFAULTSIZE);
    SendMessage(window, WM_SETICON, ICON_SMALL, (LPARAM)smallIcon);
    SendMessage(window, WM_SETICON, ICON_BIG, (LPARAM)icon);
    ')
    #end
    public static function setWindowIcon(path:String) {

    }

    #if windows
    @:functionCode('
        HANDLE console = GetStdHandle(STD_OUTPUT_HANDLE); 
        SetConsoleTextAttribute(console, color);
    ')
    #end
    public static function __setConsoleColors(color:Int) {

    }

    public static function setConsoleColors(foregroundColor:ConsoleColor = LIGHTGRAY, ?backgroundColor:ConsoleColor = BLACK) {
        var fg = cast(foregroundColor, Int);
        var bg = cast(backgroundColor, Int);
        __setConsoleColors((bg * 16) + fg);
    }

    #if windows
    @:functionCode('
        system("CLS");
        std::cout<< "" <<std::flush;
    ')
    #end
    public static function clearScreen() {

    }

    #if windows
    @:functionCode('
        return MessageBox(GetActiveWindow(), text, title, icon | MB_SETFOREGROUND);
    ')
    #end
    public static function showMessagePopup(title:String, text:String, icon:MessageBoxIcon):Int {
        lime.app.Application.current.window.alert(title, text);
        return 0;
    }

    #if windows
    @:functionCode('
        // https://stackoverflow.com/questions/4308503/how-to-enable-visual-styles-without-a-manifest
        // dumbass windows

        TCHAR dir[MAX_PATH];
        ULONG_PTR ulpActivationCookie = FALSE;
        ACTCTX actCtx =
        {
            sizeof(actCtx),
            ACTCTX_FLAG_RESOURCE_NAME_VALID
                | ACTCTX_FLAG_SET_PROCESS_DEFAULT
                | ACTCTX_FLAG_ASSEMBLY_DIRECTORY_VALID,
            TEXT("shell32.dll"), 0, 0, dir, (LPCTSTR)124
        };
        UINT cch = GetSystemDirectory(dir, sizeof(dir) / sizeof(*dir));
        if (cch >= sizeof(dir) / sizeof(*dir)) { return FALSE; /*shouldn\'t happen*/ }
        dir[cch] = TEXT(\'\\0\');
        ActivateActCtx(CreateActCtx(&actCtx), &ulpActivationCookie);
        return ulpActivationCookie;
    ')
    #end
    public static function enableVisualStyles() {
        return false;
    }

    
    public static function consoleColorToOpenFL(color:ConsoleColor) {
        return switch(color) {
            case BLACK:         0xFF000000;
            case DARKBLUE:      0xFF000088;
            case DARKGREEN:     0xFF008800;
            case DARKCYAN:      0xFF008888;
            case DARKRED:       0xFF880000;
            case DARKMAGENTA:   0xFF880000;
            case DARKYELLOW:    0xFF888800;
            case LIGHTGRAY:     0xFFBBBBBB;
            case GRAY:          0xFF888888;
            case BLUE:          0xFF0000FF;
            case GREEN:         0xFF00FF00;
            case CYAN:          0xFF00FFFF;
            case RED:           0xFFFF0000;
            case MAGENTA:       0xFFFF00FF;
            case YELLOW:        0xFFFFFF00;
            case WHITE | _:     0xFFFFFFFF;
        }
    }
}

@:enum abstract MessageBoxIcon(Int) {
    var MSG_ERROR = 0x00000010;
    var MSG_QUESTION = 0x00000020;
    var MSG_WARNING = 0x00000030;
    var MSG_INFORMATION = 0x00000040;
}
@:enum abstract ConsoleColor(Int) {
    var BLACK:ConsoleColor = 0;
    var DARKBLUE:ConsoleColor = 1;
    var DARKGREEN:ConsoleColor = 2;
    var DARKCYAN:ConsoleColor = 3;
    var DARKRED:ConsoleColor = 4;
    var DARKMAGENTA:ConsoleColor = 5;
    var DARKYELLOW:ConsoleColor = 6;
    var LIGHTGRAY:ConsoleColor = 7;
    var GRAY:ConsoleColor = 8;
    var BLUE:ConsoleColor = 9;
    var GREEN:ConsoleColor = 10;
    var CYAN:ConsoleColor = 11;
    var RED:ConsoleColor = 12;
    var MAGENTA:ConsoleColor = 13;
    var YELLOW:ConsoleColor = 14;
    var WHITE:ConsoleColor = 15;
}