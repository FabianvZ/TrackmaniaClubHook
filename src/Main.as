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
				UI::HSV(0.10f, 1.0f, 1.0f), 7500);
    }
    startnew(PBLoop);
}

void PBLoop()
{
    auto app = cast<CTrackMania@>(GetApp());
    auto currentMap = app.RootMap;
    string lastMapUid;
    Map@ map;
    User@ user = User(app.LocalPlayerInfo);
    uint previousScore;

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

        // Map is not published
        if (currentMap.MapInfo.MapUid.Length == 0)
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
            continue;
        }

        uint currentPB = force_send_pb? 0 : GetCurrBestTime(app, map.Uid);
        force_send_pb = false;

        if (previousScore > currentPB) {
            Leaderboard@ leaderboard = Leaderboard(user, map, currentPB);
            
            if (leaderboard.getPosition(currentPB) < leaderboard.getPosition(previousScore)) {
                Log("New leaderboard position: " + leaderboard.getPosition(previousScore) + " -> " + (leaderboard.getPosition(currentPB) - 1));
                PB @pb = PB(user, map, previousScore, leaderboard);

                if (settings_SendPB && FilterSolver::FromSettings().Solve(pb))
                    SendDiscordWebHook(pb);

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

void SendDiscordWebHook(PB@ pb)
{
    Log("Sending Message to DiscordWebHook");
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


