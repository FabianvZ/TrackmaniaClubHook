namespace Testing {

    bool force_send_pb = false;
    int force_send_pb_time;

#if SIG_DEVELOPER
    [SettingsTab name="Testing" icon="Cog" order=0]
    void RenderTestingPage() {
        UI::Text("Test the plugin by sending a score with a given time.");
        force_send_pb_time = UI::InputInt("Time", force_send_pb_time);
        UI::SameLine();
        force_send_pb = UI::Button("Send PB");
    }
#endif

}