class WebhookSetting : JsonSetting {

    string WebhookUrl {
        get { 
            if (Data.HasKey("WebhookUrl"))
            {
                return Data["WebhookUrl"];
            }
            return settings_discord_URL;
            }
        set { Data["WebhookUrl"] = value; }
    }

    int ClubId {
        get 
        { 
            if (Data.HasKey("ClubId"))
            {
                return Data["ClubId"];
            }
            return clubId; 
        }
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

        UI::Text("Url");
        WebhookUrl = UI::InputText("WebhookUrl", WebhookUrl);

        UI::Text("Club");
        string currentClub;
        for (uint i = 0; clubs.HasKey("clubList") &&  i < clubs["clubList"].Length; i++)
        {
            if (clubs["clubList"][i]["id"] == ClubId)
            {
                string clubname = clubs["clubList"][i]["name"];
                int clubID = clubs["clubList"][i]["id"];
                currentClub = clubname + " (ClubId: " + clubID + ")";
            }
        }
        if (UI::BeginCombo("##ClubComboBox", currentClub))
        {
            for (uint i = 0; clubs.HasKey("clubList") && i < clubs["clubList"].Length; i++)
            {
                string clubName = clubs["clubList"][i]["name"];
                int clubID = clubs["clubList"][i]["id"];
                if (UI::Selectable( clubName + " (ClubId: " + clubID + ")", 
                                clubs["clubList"][i]["id"] == clubId))
                {
                    ClubId = clubID;
                }
            }
            UI::EndCombo();
        }
        UI::SameLine();
        if (UI::Button("Reload clubs")) 
        {
            reloadclubs = true;
        }

        UI::SeparatorText("Filters");
        if (Data.HasKey("Filters"))
        {
            if (WebhookFilter(Data["Filters"]).Draw()){
                Data.Remove("Filters");
            }
        }
        else if (UI::Button(Icons::Plus + " Add a filter"))
        {
            Data["Filters"] = Json::Object();
        }

        return false;
    }

}