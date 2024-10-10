class PB
{
    Map@ Map;
    User@ User;
    Medal Medal;
    Leaderboard@ Leaderboard;
    uint PreviousScore;
    int Position;

    PB(User@ user, Map@ map, uint previousScore, Leaderboard@ leaderboard)
    {
        @User = user;
        @Map = map;
        Position = GetPBPosition(Map.Uid, leaderboard.getScore());
        Medal = GetReachedMedal(Map, leaderboard.getScore());
        PreviousScore = previousScore;
        @Leaderboard = leaderboard;
    }

    int GetPBPosition(const string &in mapUid, uint time)
    {
        int position = -1;
        for (int tries = 0; tries < 10; tries++)
        {
            try
            {
                Json::Value info = Nadeo::LiveServiceRequest("/api/token/leaderboard/group/Personal_Best/map/" + mapUid + "/surround/0/0?onlyWorld=true");

                if (info.HasKey("tops"))
                {
                    Json::Value tops = info["tops"];
                    if (tops.GetType() == Json::Type::Array)
                    {
                        Json::Value top = tops[0]["top"];
                        Json::Value score = top[0]["score"];
                        position = top[0]["position"];
                        if(int(time) == score)
                        {
                            break;
                        }
                            
                        // If wrong time/leaderboard entry was fetched => try again
                        sleep(100 * tries);
                    }
                }
            }
            catch {}
        }

        return position;
    }

    private Medal GetReachedMedal(Map@ map, uint currentPB)
    {
#if DEPENDENCY_CHAMPIONMEDALS
        if (currentPB <= map.ChampionMedalTime) return Medal::Champion;
#endif
        if (currentPB <= map.AuthorMedalTime) return Medal::Author;
        if (currentPB <= map.GoldMedalTime) return Medal::Gold;
        if (currentPB <= map.SilverMedalTime) return Medal::Silver;
        if (currentPB <= map.BronzeMedalTime) return Medal::Bronze;
        return Medal::No;
    }
}
