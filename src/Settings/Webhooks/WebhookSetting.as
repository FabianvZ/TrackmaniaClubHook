class WebhookSetting : JsonSetting {

    string WebhookUrl {
        get { return Data.HasKey("WebhookUrl")? Data["WebhookUrl"] : settings_discord_URL; }
        set { Data["WebhookUrl"] = value; }
    }

    string Name {
        get { return Data.HasKey("Name")? Data["Name"] : "New Webhook";  }
        set { Data["Name"] = value; }
    }

    int ClubId {
        get { return Data.HasKey("ClubId")? Data["ClubId"] : clubId; }
        set { Data["ClubId"] = value; }
    }

    WebhookSetting(Json::Value@ data) {
        super(data);
    }

    bool Draw() override {
        if (UI::ButtonColored(Icons::Trash, 0.0f))
        {
            return true;
        }

        Name = UI::InputText("Name", Name);
        WebhookUrl = UI::InputText("WebhookUrl", WebhookUrl);

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
                                WebhookSettings::clubs["clubList"][i]["id"] == clubId))
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

    void Send(PB@ pb) {
        if (Data.HasKey("Filters") && WebhookSettings::GetFilter(Data["Filters"]).Solve(pb)) {
            Net::HttpRequest@ response = DiscordWebHook(pb).Send();

            if (response.ResponseCode() != 204)
            {
                UI::ShowNotification(
                        "Discord Rivalry Ping",
                        "Sending to discord webhook failed.",
                        UI::HSV(0.10f, 1.0f, 1.0f), 7500);
                error("Sending message to hook was not successfull. Status:" + response.ResponseCode());
                Log(response.Body);
                Log("Length: " + response.Body.Length);
                Log(response.Error());
                Log(response.String());
            }
            else
            {
                Log("Sent " + Name + " to Discord");
            }
        }
    }

}