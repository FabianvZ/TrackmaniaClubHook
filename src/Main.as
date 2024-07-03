MessageHistory@ messageHistory;

void Main()
{
#if DEPENDENCY_NADEOSERVICES
    NadeoServices::AddAudience("NadeoLiveServices");
#endif
    if (setting_recap_show_menu && !recap.started) recap.start();
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
    ImportUsernames(settings_usernames);

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
    uint currentPB;
    uint previousPB;

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
            previousPB = GetCurrBestTime(app, map.Uid);
            continue;
        }

        currentPB = GetCurrBestTime(app, map.Uid);

        // New PB
        if (currentPB < previousPB)
        {
            Log("New PB: " + currentPB + " (" + Time::Format(currentPB - previousPB) + ")");
            PB@ pb = PB(user, map, previousPB, currentPB);
            Message@ message = CreateDiscordPBMessage(pb);
            messageHistory.Add(message);

            if (settings_SendPB && FilterSolver::FromSettings().Solve(pb))
                SendDiscordWebHook(message);

            previousPB = currentPB;
        }
        
        sleep(1000);
    }
}

bool IsValidMap(CGameCtnChallenge@ map)
{
    if (map is null || map.MapInfo is null) return false;

    return true;
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

string GetInterpolatedBody(PB@ pb, string _body)
{
    Map@ map = pb.Map;

    string discordUserId = getDiscordUserId(pb.User.Name);

    array<string> parts = _body.Split("[[");
    for (uint i = 0; i < parts.Length; i++)
    {
        parts[i] = Regex::Replace(parts[i], "\\[UserName\\]", pb.User.Name);
        parts[i] = Regex::Replace(parts[i], "\\[UserLink\\]", URL::TrackmaniaIOPlayer + pb.User.Id);
        //parts[i] = Regex::Replace(parts[i], "\\[UserDiscordId\\]", settings_discord_user_id);
        parts[i] = Regex::Replace(parts[i], "\\[UserDiscordId\\]", discordUserId);
        parts[i] = Regex::Replace(parts[i], "\\[Time\\]", Time::Format(pb.CurrentPB));
            parts[i] = Regex::Replace(parts[i], "\\[TimeDelta\\]", pb.PreviousPB != uint(-1) ? " (-" + Time::Format(pb.PreviousPB - pb.CurrentPB) + ")" : "");
        parts[i] = Regex::Replace(parts[i], "\\[Rank\\]", "" + pb.Position);
        parts[i] = Regex::Replace(parts[i], "\\[Medal\\]", Medal::ToDiscordString(pb.Medal));
        parts[i] = Regex::Replace(parts[i], "\\[MapName\\]", map.CleansedName);
        parts[i] = Regex::Replace(parts[i], "\\[MapLink\\]", URL::TrackmaniaIOLeaderboard + map.Uid);
        parts[i] = Regex::Replace(parts[i], "\\[MapAuthorName\\]", map.AuthorName);
        parts[i] = Regex::Replace(parts[i], "\\[MapAuthorLink\\]", URL::TrackmaniaIOPlayer + map.AuthorLogin);
        parts[i] = Regex::Replace(parts[i], "\\[ThumbnailLink\\]", map.TrackId != 0 ? URL::TrackmaniaExchangeThumbnail + map.TrackId : "");
        parts[i] = Regex::Replace(parts[i], "\\[GrindTime\\]", Timer::to_string(data.timer.session) +  " / " + Timer::to_string(data.timer.total));
        parts[i] = Regex::Replace(parts[i], "\\[Finishes\\]", data.finishes.session +  " / " + data.finishes.total);
        parts[i] = Regex::Replace(parts[i], "\\[Resets\\]", data.resets.session + " / " + data.resets.total);
    }

    return string::Join(parts, "[");
}