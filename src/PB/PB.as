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
        Json::Value@ requestbody = Json::Object();
        requestbody["maps"] = Json::Array();
        Json::Value mapJson = Json::Object();
        mapJson["mapUid"] = mapUid;
        mapJson["groupUid"] = "Personal_Best";
        requestbody["maps"].Add(mapJson);
        Json::Value@ personalBest = Nadeo::LiveServicePostRequest("/api/token/leaderboard/group/map?scores[" + mapUid +  "]=" + time, requestbody);
        Log(Json::Write(personalBest));
        return personalBest[0]['zones'][0]["ranking"]["position"];
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
