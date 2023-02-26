package backend.utilities;

import backend.native.windows.WindowsAPI;

enum abstract MessageIcon(Int) to Int from Int {
    var MSG_ERROR = 1;
    var MSG_QUESTION = 2;
    var MSG_WARNING = 3;
    var MSG_INFORMATION = 4;
}

class WindowUtil {
    // MessageBoxIcon is from WindowsAPI but it's always available so
    // why not use it

    // the function uses a custom type because easier scripting

    /**
     * Shows a message box with a title, message, and icon of your choosing.
     * @param title The title of the message
     * @param message The message of the..message...
     * @param icon [Optional] The icon of the message. Can be either: `MSG_INFORMATION`, `MSG_QUESTION`, `MSG_WARNING`, `MSG_ERROR`
     */
    public static function showMessage(title:String, message:String, ?msgIcon:MessageIcon = MSG_INFORMATION) {
        var icon:MessageBoxIcon = switch(msgIcon) {
            case MSG_ERROR: MSG_ERROR;
            case MSG_QUESTION: MSG_QUESTION;
            case MSG_WARNING: MSG_WARNING;
            default: MSG_INFORMATION;
        };

        #if windows
        WindowsAPI.showMessageBox(title, message, icon);
        #elseif linux
        switch(icon) {
            case MSG_QUESTION:  Sys.command("zenity --question --text='"+message+"'");
            case MSG_WARNING:   Sys.command("zenity --warning --text='"+message+"'");
            case MSG_ERROR:     Sys.command("zenity --error --text='"+message+"'");
            default:            Sys.command("zenity --info --text='"+message+"'");
        }
        #end

        switch(icon) {
            case MSG_QUESTION:  Logs.trace(title+" - "+message, INFO);
            case MSG_WARNING:   Logs.trace(title+" - "+message, WARNING);
            case MSG_ERROR:     Logs.trace(title+" - "+message, ERROR);
            default:            trace(title+" - "+message);
        }
    }
}