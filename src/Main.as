void Main()
{
#if TURBO
	startnew(CoroutineFunc(TurboSTM::LoadSuperTimes));
#endif
#if DEPENDENCY_NADEOSERVICES
	NadeoServices::AddAudience("NadeoLiveServices");
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
    uint previousScore;

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
            Testing::force_send_pb_time = previousScore;
            for (uint i = 0; i < WebhookSettings::webhooks.Length; i++)
            {
                WebhookSettings::webhooks[i].UpdatePosition(map, previousScore);
            }
            continue;
        }

        uint currentPB = Testing::force_send_pb? Testing::force_send_pb_time : GetCurrBestTime(app, map.Uid);
        Testing::force_send_pb = false;

        if (send_pb_manual || previousScore > currentPB) {
            Log("New PB: " + previousScore + " -> " + currentPB);
            PB@ pb = PB(user, map, previousScore, currentPB);
            dictionary cache = dictionary();

            for (uint i = 0; i < WebhookSettings::webhooks.Length; i++)
            {
                WebhookSetting@ webhook = WebhookSettings::webhooks[i];
                if (cache.Exists(webhook.ClubId + "")) {
                    if (cast<ClubPB@>(cache[webhook.ClubId + ""]) is null) {
                        continue;  // Skipping because the clubpb is not improved
                    }
                } else {
                    uint position;
                    Json::Value@ positionRequest = webhook.GetClubLeaderboardPosition(map.Uid, previousScore);
                    if (uint(positionRequest["score"]) == previousScore) {
                        webhook.previousPosition = positionRequest["position"];
                        position = webhook.GetClubLeaderboardPosition(map.Uid, currentPB)["position"];
                    } else {
                        position = positionRequest["position"];
                    }

                    Log("Club " + webhook.Name + " Position: " + webhook.previousPosition + " -> " + position);
                    if (send_pb_manual || send_when_beating_noone || position < webhook.previousPosition) {
                        cache[webhook.ClubId + ""] = @ClubPB(pb, webhook.previousPosition, position, webhook.ClubId);
                    } else {
                        cache[webhook.ClubId + ""] = null;
                        continue; // Skipping because the clubpb is not improved
                    }
                    webhook.previousPosition = position;
                }

                webhook.Send(cast<ClubPB@>(cache[webhook.ClubId + ""]));
            }

            send_pb_manual = false;
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