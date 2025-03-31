[Setting hidden]
VirtualKey togglePBKey;

[Setting hidden]
VirtualKey forceSendKey;
bool send_pb_manual;

class Shortcut {
    VirtualKey key;
    private bool record = false;
    private bool pressed = false;
    private string notificationMessage;

    Shortcut(const string &in message) {
        this.notificationMessage = message;
    }

    bool KeyPressed(bool down, VirtualKey pressedKey, VirtualKey &out shortcutKey) {
        if (record) {
            key = pressedKey;
            record = false;
            pressed = true;
        }

        if (pressedKey == key) {
            if (down && !pressed) {
                pressed = true;
                return true;
            } 
            else if (!down) {
                pressed = false;
            }
        }

        shortcutKey = key;
        return false;
    }

    void RenderUI() {  // Pass the setting as reference
        UI::Text("Shortcut to " + notificationMessage + ": " + ((key != 0) ? tostring(key) : "None"));
        UI::SameLine();
        if (UI::Button("Change " + notificationMessage)) {
            record = true;
        }
        UI::SameLine();
        if (UI::Button("Clear " + notificationMessage)) {
            key = VirtualKey(0);
        }
    }
}

Shortcut sendPBShortcut("toggle sending PBs to Discord");
Shortcut forceSendShortcut("force a message to Discord");

void OnKeyPress(bool down, VirtualKey key) {
    if (sendPBShortcut.KeyPressed(down, key, togglePBKey)) {
        settings_SendPB = !settings_SendPB;
        UI::ShowNotification(
            "Discord Rivalry Ping",
            "Toggled sending PBs to Discord: " + (settings_SendPB ? "Enabled" : "Disabled"),
            UI::HSV(0.55f, 1.0f, 1.0f), 7500);
    }
    if (forceSendShortcut.KeyPressed(down, key, forceSendKey)) {
        send_pb_manual = true;
                UI::ShowNotification(
            "Discord Rivalry Ping",
            "Sending manual PB to Discord",
            UI::HSV(0.55f, 1.0f, 1.0f), 7500);
    }
}

void RenderUI() {
    sendPBShortcut.RenderUI();
    forceSendShortcut.RenderUI();
}
