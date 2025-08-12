namespace WebhookSettings {

    [Setting hidden]
    string settings_webhooks = "[]";	    
    Json::Value@ _webhooks;
    array<WebhookSetting@> webhooks;

    Json::Value clubs = Json::Object();
    bool reloadclubs = true;

    bool showImportPopup = false;
    string import_webhook = "", import_error_message = "";

    [SettingsTab name="Discord webhooks" icon="DiscordAlt" order=1]
    void RenderDiscordWebhookSettings() {

        UI::BeginTabBar("DiscordPBMessageSettings", UI::TabBarFlags::FittingPolicyResizeDown);
        for (uint i = 0; i < webhooks.Length; i++) {
            if (UI::BeginTabItem(Icons::Trophy + i))
            {
                if (webhooks[i].Draw()){
                    webhooks.RemoveAt(i);
                    _webhooks.Remove(i);
                }
                UI::EndTabItem();
            }   
        }
        UI::EndTabBar();
    
        UI::Separator();
        if (UI::Button(Icons::Plus + " Add a webhook"))
        {
            Json::Value@ newWebhook = Json::Object();
            _webhooks.Add(@newWebhook);
            webhooks.InsertLast(@WebhookSetting(@newWebhook));
        }

        UI::SameLine();
        if (UI::Button(Icons::ArrowCircleDown + " Import webhook")) {
            showImportPopup = true;
        }

        if (showImportPopup) {
            UI::Begin("Import webhook", showImportPopup, UI::WindowFlags::NoResize | UI::WindowFlags::AlwaysAutoResize);
            import_webhook = UI::InputTextMultiline("##webhook_import", import_webhook);
            UI::Text(import_error_message);

            if (UI::Button("Import")) {
                Json::Value@ import_webhook_json = Json::Parse(import_webhook);
                if (@import_webhook_json == null || import_webhook_json.GetType() != Json::Type::Object) {
                    import_error_message = "Import text not valid";
                } else {
                    showImportPopup = false;
                    import_webhook = "";
                    import_error_message = "";  
                    _webhooks.Add(@import_webhook_json);
                    webhooks.InsertLast(@WebhookSetting(@import_webhook_json));
                }

            }
            if (UI::Button("Close")) {
                showImportPopup = false;
            }

            UI::End();
        } 

        settings_webhooks = Json::Write(_webhooks);
    }

    WebhookFilter@ GetFilter(Json::Value@ data, const string &in label = "") {
        switch (uint(data.HasKey("Type")? data["Type"] : FilterType::Time)) {
            case FilterType::Comparison:
                return Comparison(data, label);
            case FilterType::MapName:
                return MapNameFilter(data, label);
            case FilterType::Medal:
                return MedalFilter(data, label);
            case FilterType::CurrentCampaign:
                return CurrentCampaignFilter(data, label);
            case FilterType::WeeklyShorts:
                return WeeklyShortsFilter(data, label);
            case FilterType::Rank:
                return RankFilter(data, label);
            case FilterType::TrackOfTheDay:
                return TrackOfTheDayFilter(data, label);
            default:
                return TimeFilter(data, label);
        }
    } 

}