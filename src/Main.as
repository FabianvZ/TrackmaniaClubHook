void Main()
{
#if TURBO
	startnew(CoroutineFunc(TurboSTM::LoadSuperTimes));
#endif
#if DEPENDENCY_NADEOSERVICES
	NadeoServices::AddAudience("NadeoLiveServices");
#endif
	if (setting_recap_show_menu && !recap.started)
		recap.start();

	migrateOldData();
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
    startnew(PBLoop);
}

void PBLoop()
{
    auto app = cast<CTrackMania@>(GetApp());
    auto currentMap = app.RootMap;
    string lastMapUid;
    Map@ map;
    User@ user = User(app.LocalPlayerInfo);
    uint previousPB;
    Leaderboard@ leaderboard;

    while (true)
    {
        // Wait until player is on a map
        while (!IsValidMap(currentMap))
        {
            sleep(3000);
            @app = cast<CTrackMania@>(GetApp());
            @currentMap = app.RootMap;
        }

        // Map changed
        if (currentMap.MapInfo.MapUid != lastMapUid)
        {
            lastMapUid = currentMap.MapInfo.MapUid;
            @map = Map(currentMap);
            @leaderboard = Leaderboard(user, map);
            previousPB = GetCurrBestTime(app, map.Uid);
            continue;
        }

        uint currentPB = GetCurrBestTime(app, map.Uid);

        if (force_send_pb) {
            currentPB = 1;
        }

        // New club leaderboard place
        if (currentPB < previousPB) {
            Log("New PB: " + previousPB + " -> " + currentPB);
            if (leaderboard.getPosition(currentPB) < leaderboard.getLeaderboardPosition()) {
                Log("New leaderboard position: " + leaderboard.getLeaderboardPosition() + " -> " + leaderboard.getPosition(currentPB));
                PB @pb = PB(user, map, currentPB, leaderboard);

                if (settings_SendPB && FilterSolver::FromSettings().Solve(pb))
                    SendDiscordWebHook(pb);

                @leaderboard = Leaderboard(user, map);
                previousPB = currentPB;
                force_send_pb = false;
            }
        }
        sleep(1000);
    }
}

bool IsValidMap(CGameCtnChallenge@ map)
{
    return !(map is null || map.MapInfo is null);
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


