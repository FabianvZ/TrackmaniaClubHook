namespace Notifications {

    void ShowNotification(const string &in message) {
        ShowMessage(message, UI::HSV(0.55f, 1.0f, 1.0f));
    }

    void ShowError(const string &in message) {
        error(message);
        ShowMessage(message, UI::HSV(0.10f, 1.0f, 1.0f));
    }

    void ShowMessage(const string &in message, vec4 color) {
        UI::ShowNotification(
            "Discord Rivalry Ping",
            message,
            color, 
            7500);
    }

}