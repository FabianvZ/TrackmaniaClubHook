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

    sendPBShortcut.key = togglePBKey;
    forceSendShortcut.key = forceSendKey;
    Legacy::migrateOldWebhookSettings();
    WebhookSettings::Initialize();
    Legacy::migrateOldGrindingStatsData();
    startnew(PBLoop);
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

        if (WebhookSettings::reloadclubs)
        {
            WebhookSettings::clubs = Nadeo::LiveServiceRequest("/api/token/club/mine?length=100&offset=0");
            WebhookSettings::reloadclubs = false;
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
            previousPosition = GetClubLeaderboardPosition(map.Uid, previousScore)["position"];
            continue;
        }

        uint currentPB = Testing::force_send_pb? Testing::force_send_pb_time : GetCurrBestTime(app, map.Uid);
        Testing::force_send_pb = false;

        if (send_pb_manual) {
            send_pb_manual = false;
            PB @pb = PB(user, map, previousScore, currentPB, previousPosition, previousPosition);
            SendDiscordWebHook(pb);
        }

        if (previousScore > currentPB) {
            Log("New PB: " + previousScore + " -> " + currentPB);

            uint position;
            Json::Value@ positionRequest = GetClubLeaderboardPosition(map.Uid, previousScore);
            if (uint(positionRequest["score"]) == previousScore) {
                previousPosition = positionRequest["position"];
                position = GetClubLeaderboardPosition(map.Uid, currentPB)["position"];
            } else {
                position = positionRequest["position"];
            }
            Log("Club Position: " + previousPosition + " -> " + position);
            if (position < previousPosition) {

                PB @pb = PB(user, map, previousScore, currentPB, previousPosition, position);
                SendDiscordWebHook(pb);
            }
            previousPosition = position;
            previousScore = currentPB;
        }
        sleep(1000);
    }
}

void SendDiscordWebHook(PB@ pb)
{
    for (uint i = 0; i < WebhookSettings::webhooks.Length; i++)
    {
        WebhookSettings::webhooks[i].Send(pb);
    }
}

uint GetCurrBestTime(CTrackMania@ app, const string &in mapUid)
{
    auto user_manager = app.Network.ClientManiaAppPlayground.UserMgr;
    auto score_manager = app.Network.ClientManiaAppPlayground.ScoreMgr;
    auto user = user_manager.Users[0];
    return score_manager.Map_GetRecord_v2(user.Id, mapUid, "PersonalBest", "", "TimeAttack", "");
}

Json::Value@ GetClubLeaderboardPosition(const string &in mapUid, uint score) 
{
    Json::Value@ requestbody = Json::Object();
    requestbody["maps"] = Json::Array();
    Json::Value mapJson = Json::Object();
    mapJson["mapUid"] = mapUid;
    mapJson["groupUid"] = "Personal_Best";
    requestbody["maps"].Add(mapJson);
    Json::Value@ personalBest = Nadeo::LiveServicePostRequest("/api/token/leaderboard/group/map/club/" + clubId + "?scores[" + mapUid +  "]=" + score, requestbody)[0];
    Log(Json::Write(personalBest));
    return personalBest;
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