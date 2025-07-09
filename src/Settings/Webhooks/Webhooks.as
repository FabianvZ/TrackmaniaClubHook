namespace WebhookSettings {

    [Setting hidden]
    string settings_webhooks = "[{}]";	    
    Json::Value@ _webhooks;
    array<WebhookSetting@> webhooks;

    Json::Value clubs = Json::Object();
    bool reloadclubs = true;

    [SettingsTab name="Discord webhooks" icon="DiscordAlt" order=1]
    void RenderDiscordWebhookSettings() {

        UI::BeginTabBar("DiscordPBMessageSettings", UI::TabBarFlags::FittingPolicyResizeDown);
        for (uint i = 0; i < webhooks.Length; i++) {
            if (UI::BeginTabItem(Icons::Trophy + " " + webhooks[i].Name +"##" + i))
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
            _webhooks.Add(newWebhook);
            webhooks.InsertLast(WebhookSetting(newWebhook));
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
    
    void Initialize() {
        @_webhooks = Json::Parse(settings_webhooks);
        if (_webhooks.GetType() != Json::Type::Array)
        {
            @_webhooks = Json::Array();
        }
        for (uint i = 0; i < _webhooks.Length; i++)
        {
            webhooks.InsertLast(@WebhookSetting(_webhooks[i]));
        }
    }

}