void Main()
{
#if TURBO
	startnew(CoroutineFunc(TurboSTM::LoadSuperTimes));
#endif
#if DEPENDENCY_NADEOSERVICES
	NadeoServices::AddAudience("NadeoLiveServices");
#endif

#if DEPENDENCY_DISCORD
    if (settings_discord_user_id == "")
    {
        for (uint tries = 0; tries < 10; tries++)
        {
            if (Discord::IsReady())
            {
                string discordUserId = Discord::GetUser().ID;
                DiscordDefaults::UserId = discordUserId;
                settings_discord_user_id = discordUserId;
                Log("Got Discord User!");
                break;
            }
            Log("Tried to get Discord User - was not ready!");

            sleep(500);
        }
    }
#endif
    if (clubId == -1)
    {
        clubId = Nadeo::LiveServiceRequest("/api/token/club/player/info")["pinnedClub"];
    }    
    if (settings_discord_URL == DiscordDefaults::URL)
    {
        UI::ShowNotification(
				"Discord Rivalry Ping",
				"Discord webhook is not set in settings. This is needed to send leaderboards!",
				UI::HSV(0.55f, 1.0f, 1.0f), 7500);
    }
    migrateOldData();
    startnew(PBLoop);
}

bool shortcutPressed;

void OnKeyPress(bool down, VirtualKey key)
{      
    if (recordShortcut) {
        shortcutKey = key;
        recordShortcut = false;
        shortcutPressed = true;
    }

    if (key == shortcutKey) {
        if (down && !shortcutPressed) {
            shortcutPressed = true;
            settings_SendPB = !settings_SendPB;
            UI::ShowNotification(
                "Discord Rivalry Ping",
                "Toggled sending PBs to Discord: " + (settings_SendPB ? "Enabled" : "Disabled"),
                UI::HSV(0.55f, 1.0f, 1.0f), 7500);
        } 
        else if (!down) {
            shortcutPressed = false;
        }
    }
}

void PBLoop()
{
    auto app = cast<CTrackMania@>(GetApp());
    auto currentMap = app.RootMap;
    string lastMapUid;
    Map@ map;
    User@ user = User(app.LocalPlayerInfo);
    uint previousScore, previousPosition;

    while (true)
    {

        if (reloadclubs)
        {
            clubs = Nadeo::LiveServiceRequest("/api/token/club/mine?length=100&offset=0");
            reloadclubs = false;
        }

        // Wait until player is on a map
        if (currentMap is null || currentMap.MapInfo is null)
        {
            sleep(3000);
            @currentMap = app.RootMap;
            continue;
        }

        // Map is not published or should not send pb (as set in settings)
        if (currentMap.MapInfo.MapUid.Length == 0 || !settings_SendPB)
        {
            sleep(3000);
            continue;
        }

        // Map changed
        if (currentMap.MapInfo.MapUid != lastMapUid)
        {
            lastMapUid = currentMap.MapInfo.MapUid;
            @map = Map(currentMap);
            previousScore = GetCurrBestTime(app, map.Uid);
            previousPosition = GetClubLeaderboardPosition(map.Uid, previousScore);
            continue;
        }

        uint currentPB = force_send_pb? force_send_pb_time : GetCurrBestTime(app, map.Uid);
        force_send_pb = false;

        if (previousScore > currentPB) {
            Log("New PB: " + previousScore + " -> " + currentPB);

            uint position = GetClubLeaderboardPosition(map.Uid, currentPB);
            Log("Club Position: " + previousPosition + " -> " + position);
            if (position < previousPosition) {

                PB @pb = PB(user, map, previousScore, currentPB, previousPosition, position);

                if (FilterSolver::FromSettings().Solve(pb))
                    Log("Passed filters");
                    SendDiscordWebHook(pb);

                previousPosition = position;
            }
            previousScore = currentPB;
        }
        sleep(1000);
    }
}

uint GetCurrBestTime(CTrackMania@ app, const string &in mapUid)
{
    auto user_manager = app.Network.ClientManiaAppPlayground.UserMgr;
    auto score_manager = app.Network.ClientManiaAppPlayground.ScoreMgr;
    auto user = user_manager.Users[0];
    return score_manager.Map_GetRecord_v2(user.Id, mapUid, "PersonalBest", "", "TimeAttack", "");
}

uint GetClubLeaderboardPosition(const string &in mapUid, uint score) 
{
    Json::Value@ requestbody = Json::Object();
    requestbody["maps"] = Json::Array();
    Json::Value mapJson = Json::Object();
    mapJson["mapUid"] = mapUid;
    mapJson["groupUid"] = "Personal_Best";
    requestbody["maps"].Add(mapJson);
    Json::Value@ personalBest = Nadeo::LiveServicePostRequest("/api/token/leaderboard/group/map/club/" + clubId + "?scores[" + mapUid +  "]=" + score, requestbody);
    return personalBest[0]["position"];
}

void SendDiscordWebHook(PB@ pb)
{
    Net::HttpRequest@ response = DiscordWebHook(pb).Send();

    if (response.ResponseCode() != 204)
    {
        UI::ShowNotification(
				"Discord Rivalry Ping",
				"Sending to discord webhook failed.",
				UI::HSV(0.10f, 1.0f, 1.0f), 7500);
        error("Sending message to hook was not successfull. Status:" + response.ResponseCode());
        error(response.Error());
    }
    else
    {
        Log("Sent to Discord");
    }
}

string GetPlayerDisplayName(const string &in accountId)
{
    auto ums = GetApp().UserManagerScript;
    MwFastBuffer<wstring> playerIds = MwFastBuffer<wstring>();
    playerIds.Add(accountId);

    auto req = ums.GetDisplayName(GetMainUserId(), playerIds);
    while (req.IsProcessing)
    {
        yield();
    }

    string[] playerNames = array<string>(playerIds.Length);
    for (uint i = 0; i < playerIds.Length; i++)
    {
        playerNames[i] = string(req.GetDisplayName(wstring(playerIds[i])));
    }
    return playerNames[0];
}

MwId GetMainUserId() {
    auto app = cast<CTrackMania>(GetApp());
    if (app.ManiaPlanetScriptAPI.UserMgr.MainUser !is null) {
        return app.ManiaPlanetScriptAPI.UserMgr.MainUser.Id;
    }
    if (app.ManiaPlanetScriptAPI.UserMgr.Users.Length >= 1) {
        return app.ManiaPlanetScriptAPI.UserMgr.Users[0].Id;
    } else {
        return MwId();
    }
}

//{"medals":"[{\"medal\":0,\"achieved\":true,\"achieved_time\":\"          0\"},{\"medal\":1,\"achieved\":true,\"achieved_time\":\"          0\"},{\"medal\":2,\"achieved\":true,\"achieved_time\":\"          0\"},{\"medal\":3,\"achieved\":false,\"achieved_time\":\"          0\"},{\"medal\":5,\"achieved\":false,\"achieved_time\":\"          0\"}]","time":"     138230","finishes":"     2","resets":"     5","respawns":"     0"}
void migrateOldData() {
	auto old_path = IO::FromStorageFolder("data");
	if (IO::FolderExists(old_path)) {
		UI::ShowNotification("Discord Rivalry Ping", "Moving Grinding Stats data to Grinding stats plugin.", UI::HSV(0.10f, 1.0f, 1.0f), 2500);
		auto new_path = IO::FromDataFolder("PluginStorage/GrindingStats/data");
		if (IO::FolderExists(new_path)) {

            auto old = IO::IndexFolder(old_path, true);
            for (uint i = 0; i < old.Length; i++) {
                const string[] @parts = old[i].Split("/");
                const string name = new_path + "/" + parts[parts.Length - 1];
                if (IO::FileExists(name)) {
                    print("Combining " + old[i] + " and " + name);
                    Json::Value new_file = Json::FromFile(name);
                    Json::Value old_file = Json::FromFile(old[i]);

                    new_file["finishes"] = Text::Format("%6d", getValue(new_file["finishes"]) + getValue(old_file["finishes"]));
                    new_file["resets"] = Text::Format("%6d", getValue(new_file["resets"]) + getValue(old_file["resets"]));
                    new_file["time"] = Text::Format("%11d", getValue(new_file["time"]) + getValue(old_file["time"]));
                    new_file["respawns"] = Text::Format("%6d", getValue(new_file["respawns"]) + getValue(old_file["respawns"]));

                    Json::ToFile(name, new_file);
                    IO::Delete(old[i]);
                } 
                else {
                    print("moving " + old[i] + " to " + name);
                    IO::Move(old[i], name);
                }
            }
            UI::ShowNotification("Discord Rivalry Ping", "Completed Data Transfer", UI::HSV(0.35f, 1.0f, 1.0f), 10000);
            IO::DeleteFolder(old_path);
		} else {
            IO::Move(old_path, new_path);
            if (IO::IndexFolder(old_path, true).Length == 0) {
                IO::DeleteFolder(old_path);
            }
        }
	}
}

int getValue(Json::Value value) 
{
    switch (value.GetType())
    {
        case Json::Type::String:
            return Text::ParseUInt64(value);
        case Json::Type::Number:
            return value;
    }
    return 0;
}