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
        get { return Data.HasKey("ClubId")? Data["ClubId"] : Legacy::clubId; }
        set { Data["ClubId"] = value; }
    }

    uint previousPosition;

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
        previousPosition = GetClubLeaderboardPosition(map.Uid, score)["position"];
    }

    void Send(PB@ pb, Map@ map, uint previousScore, uint currentScore) {
        uint position;
        Json::Value@ positionRequest = GetClubLeaderboardPosition(map.Uid, previousScore);
        if (uint(positionRequest["score"]) == previousScore) {
            previousPosition = positionRequest["position"];
            position = GetClubLeaderboardPosition(map.Uid, currentScore)["position"];
        } else {
            position = positionRequest["position"];
        }

        Log("Club " + Name + " Position: " + previousPosition + " -> " + position);
        if (position < previousPosition) {

            ClubPB @clubpb = ClubPB(pb, previousPosition, position, ClubId);
            if (!Data.HasKey("Filters") || WebhookSettings::GetFilter(Data["Filters"]).Solve(clubpb)) {
                Send(clubpb);
            }
        }
        previousPosition = position;
    }

    void Send(ClubPB@ pb) {
        Net::HttpRequest@ response = DiscordWebHook(pb, WebhookUrl).Send();

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