class WebhookSetting : JsonSetting {

    string WebhookUrl {
        get { return Data.HasKey("WebhookUrl")? Data["WebhookUrl"] : DiscordDefaults::URL; }
        set { Data["WebhookUrl"] = value; }
    }

    string Name {
        get { return Data.HasKey("Name")? Data["Name"] : "New Webhook";  }
        set { Data["Name"] = value; }
    }

    int ClubId {
        get { return Data.HasKey("ClubId")? Data["ClubId"] : -1; }
        set { Data["ClubId"] = value; }
    }

    Triggers Trigger {
        get { return Data.HasKey("Trigger")? Triggers::FromValue(int(Data["Trigger"])) : send_when_beating_noone? Triggers::Time : Triggers::Club; }
        set { Data["Trigger"] = int(value); }
    }

    uint previousPosition;

    WebhookSetting(Json::Value@ data) {
        super(@data);
    }

    bool Draw() override {
        if (UI::ButtonColored(Icons::Trash, 0.0f))
        {
            return true;
        }

        UI::SameLine();
        if (UI::Button(Icons::Clipboard + " Export webhook to clipboard")) {
            Json::Value@ newData = Json::Object();
            IO::SetClipboard(Json::Write(Data));
        }

        Name = UI::InputText("Name", Name);
        WebhookUrl = UI::InputText("WebhookUrl", WebhookUrl);

        if (UI::BeginCombo("Trigger to send", Triggers::ToString(Trigger))) {
            for (int i = 0; i < 3; i++) {
                Triggers t = Triggers::FromValue(i);
                if (UI::Selectable(Triggers::ToString(t), Trigger == t))
                {
                    Trigger = t;
                    break;
                }
            }
            UI::EndCombo();
        }

        string currentClub;
        for (uint i = 0; WebhookSettings::clubs.HasKey("clubList") &&  i < WebhookSettings::clubs["clubList"].Length; i++)
        {
            if (WebhookSettings::clubs["clubList"][i]["id"] == ClubId)
            {
                string clubname = WebhookSettings::clubs["clubList"][i]["name"];
                int clubID = WebhookSettings::clubs["clubList"][i]["id"];
                currentClub = clubname + " (ClubId: " + clubID + ")";
            }
        }
        if (UI::BeginCombo("Club##ClubComboBox", currentClub))
        {
            for (uint i = 0; WebhookSettings::clubs.HasKey("clubList") && i < WebhookSettings::clubs["clubList"].Length; i++)
            {
                string clubName = WebhookSettings::clubs["clubList"][i]["name"];
                int clubID = WebhookSettings::clubs["clubList"][i]["id"];
                if (UI::Selectable( clubName + " (ClubId: " + clubID + ")", 
                                WebhookSettings::clubs["clubList"][i]["id"] == ClubId))
                {
                    ClubId = clubID;
                }
            }
            UI::EndCombo();
        }
        UI::SameLine();
        if (UI::Button("Reload clubs")) 
        {
            WebhookSettings::reloadclubs = true;
        }

        UI::SeparatorText("Filters");
        if (Data.HasKey("Filters"))
        {
            if (WebhookSettings::GetFilter(Data["Filters"]).Draw()){
                Data.Remove("Filters");
            }
        }
        else if (UI::Button(Icons::Plus + " Add a filter"))
        {
            Data["Filters"] = Json::Object();
        }

        return false;
    }

    void UpdatePosition(Map@ map, uint score) {
        if (ClubId == -1) {
            Notifications::ShowError("ClubId is not set for webhook " + Name);
            return;
        }
        previousPosition = GetClubLeaderboardPosition(map.Uid, score)["position"];
    }

    void Send(ClubPB@ pb, bool force = false) {
        if (WebhookUrl == "" || WebhookUrl == DiscordDefaults::URL) {
            Notifications::ShowError("Webhook URL is not set for webhook " + Name);
            return;
        }

        if (force || !Data.HasKey("Filters") || WebhookSettings::GetFilter(Data["Filters"]).Solve(pb)) {
            Net::HttpRequest@ response = DiscordWebHook(pb, WebhookUrl).Send();

            if (response.ResponseCode() < 200 || response.ResponseCode() >= 300)
            {
                Notifications::ShowError("Sending message to hook was not successfull. Status:" + response.ResponseCode());
                Log(response.Body);
            }
            else
            {
                Log("Sent webhook " + Name + " to Discord");
            }
        }
    }

    Json::Value@ GetClubLeaderboardPosition(const string &in mapUid, uint score) 
    {   
        Json::Value@ requestbody = Json::Object();
        requestbody["maps"] = Json::Array();
        Json::Value mapJson = Json::Object();
        mapJson["mapUid"] = mapUid;
        mapJson["groupUid"] = "Personal_Best";
        requestbody["maps"].Add(mapJson);
        Json::Value@ personalBest = Nadeo::LiveServicePostRequest("/api/token/leaderboard/group/map/club/" + ClubId + "?scores[" + mapUid +  "]=" + score, requestbody)[0];
        Log(Json::Write(personalBest));
        return personalBest;
    }

}