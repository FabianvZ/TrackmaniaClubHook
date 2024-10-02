MessageHistory@ messageHistory;

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
    @messageHistory = MessageHistory();
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

        // New club leaderboard place
        if (currentPB < previousPB) {
            Log("New PB: " + previousPB + " -> " + currentPB);
            if (leaderboard.getPosition(currentPB) < leaderboard.getLeaderboardPosition()) {
                Log("New leaderboard position: " + leaderboard.getLeaderboardPosition() + " -> " + leaderboard.getPosition(currentPB));
                PB @pb = PB(user, map, currentPB, leaderboard);
                Message @message = CreateDiscordPBMessage(pb);
                messageHistory.Add(message);

                if (settings_SendPB && FilterSolver::FromSettings().Solve(pb))
                    SendDiscordWebHook(message);

                @leaderboard = Leaderboard(user, map);
                previousPB = currentPB;
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

Message@ CreateDiscordPBMessage(PB@ pb)
{     
    string url = settings_discord_URL;
    string body = GetInterpolatedBody(pb, settings_Body);
    DiscordWebHook@ webHook = DiscordWebHook(url, body);
    
    return Message(webHook);
}

void SendDiscordWebHook(Message@ message)
{
    Log("Sending Message to DiscordWebHook");
    Networking::Response@ response = message.Send();

    if (response.StatusCode != 204)
    {
        error("Sending message to hook was not successfull. Status:" + response.StatusCode);
        error(response.ErrorMessage);
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

string GetInterpolatedBody(PB@ pb, string _body)
{
    Map@ map = pb.Map;

    array<string> parts = _body.Split("[[");
    for (uint i = 0; i < parts.Length; i++)
    {
        parts[i] = Regex::Replace(parts[i], "\\[UserName\\]", pb.User.Name);
        parts[i] = Regex::Replace(parts[i], "\\[UserLink\\]", URL::TrackmaniaIOPlayer + pb.User.Id);
        parts[i] = Regex::Replace(parts[i], "\\[UserDiscordId\\]", settings_discord_user_id);
        parts[i] = Regex::Replace(parts[i], "\\[Time\\]", Time::Format(pb.CurrentPB));
        parts[i] = Regex::Replace(parts[i], "\\[TimeDelta\\]", pb.PreviousPB != uint(-1) ? " (-" + Time::Format(pb.PreviousPB - pb.CurrentPB) + ")" : "");
        parts[i] = Regex::Replace(parts[i], "\\[Rank\\]", "" + pb.Position);
        parts[i] = Regex::Replace(parts[i], "\\[Medal\\]", Medal::ToDiscordString(pb.Medal));
        parts[i] = Regex::Replace(parts[i], "\\[MapName\\]", map.CleansedName);
        parts[i] = Regex::Replace(parts[i], "\\[MapLink\\]", URL::TrackmaniaIOLeaderboard + map.Uid);
        parts[i] = Regex::Replace(parts[i], "\\[MapAuthorName\\]", map.AuthorName);
        parts[i] = Regex::Replace(parts[i], "\\[MapAuthorLink\\]", URL::TrackmaniaIOPlayer + map.AuthorLogin);
        parts[i] = Regex::Replace(parts[i], "\\[ThumbnailLink\\]", map.TrackId != 0 ? URL::TrackmaniaExchangeThumbnail + map.TrackId : "");
        parts[i] = Regex::Replace(parts[i], "\\[GrindTime\\]", Time::Format(data.get_timer().session) +  " / " + Time::Format(data.get_timer().total));
        parts[i] = Regex::Replace(parts[i], "\\[Finishes\\]", data.finishes.session +  " / " + data.finishes.total);
        parts[i] = Regex::Replace(parts[i], "\\[Resets\\]", data.resets.session + " / " + data.resets.total);
        parts[i] = Regex::Replace(parts[i], "\\[ClubLeaderboard\\]", pb.CurrentLeaderboard.toString());
        parts[i] = Regex::Replace(parts[i], "\\[Losers\\]", pb.PreviousLeaderboard.getLosers(pb));
    }

    return string::Join(parts, "[");
}


