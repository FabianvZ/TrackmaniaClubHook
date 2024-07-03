class PB
{
    User@ User;
    Map@ Map;
    uint CurrentPB;
    uint PreviousPB;
    int Position;
    Medal Medal;
    Leaderboard@ PreviousLeaderboard;
    Leaderboard@ CurrentLeaderboard;

    PB(User@ user, Map@ map, uint currentPB, Leaderboard@ previousLeaderboard)
    {
        @User = user;
        @Map = map;
        CurrentPB = currentPB;
        Position = GetPBPosition(Map.Uid, CurrentPB);
        Medal = GetReachedMedal(CurrentPB, Map);
        @PreviousLeaderboard = previousLeaderboard;
        PreviousPB = previousLeaderboard.getPB();
        @CurrentLeaderboard = GetLeaderboard();
    }

    int GetPBPosition(const string &in mapUid, uint time)
    {
        for (int tries = 0; tries < 10; tries++)
        {
            try
            {
                auto info = Nadeo::LiveServiceRequest("/api/token/leaderboard/group/Personal_Best/map/" + mapUid + "/surround/0/0?onlyWorld=true");

                if (info.HasKey("tops"))
                {
                    auto tops = info["tops"];
                    if (tops.GetType() == Json::Type::Array)
                    {
                        auto top = tops[0]["top"];
                        auto score = top[0]["score"];
                        auto position = top[0]["position"];
                        // If wrong time/leaderboard entry was fetched => try again
                        if(int(time) != score)
                        {
                            sleep(100 * tries);
                            continue;
                        }

                        return position;
                    }
                }
            }
            catch {}
        }

        return -1;
    }

    Leaderboard@ GetLeaderboard()
    {
        for (int tries = 0; tries < 10; tries++)
        {
            try
            {
               Leaderboard@ newLeaderboard = Leaderboard(User, Map);

                if(newLeaderboard.getLeaderboardPosition() == PreviousLeaderboard.getLeaderboardPosition())
                {
                    sleep(100 * tries);
                    continue;
                }

                return newLeaderboard;
            }
            catch {}
        }

        return Leaderboard(User, Map);
    }
    
    private Medal GetReachedMedal(uint currentPB, Map@ map)
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
