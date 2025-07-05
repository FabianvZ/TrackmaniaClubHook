class PB
{
    Map@ Map;
    User@ User;
    Medal Medal;
    uint PreviousScore, _score, Score, WorldPosition, ContinentPosition, CountryPosition, ProvincePosition;

    PB(User@ user, Map@ map, uint previousScore, uint score)
    {
        @User = user;
        @Map = map;
        SetPBPosition(map.Uid, score);
        Medal = GetReachedMedal(Map, score);
        PreviousScore = previousScore;
        _score = score;
        Score = (score <= Map.AuthorMedalTime && Campaign::WeeklyShorts.IsCurrentCampaignMap(map)) ? -1 : score;
    }

    private void SetPBPosition(const string &in mapUid, uint time)
    {
        Json::Value@ requestbody = Json::Object();
        requestbody["maps"] = Json::Array();
        Json::Value mapJson = Json::Object();
        mapJson["mapUid"] = mapUid;
        mapJson["groupUid"] = "Personal_Best";
        requestbody["maps"].Add(mapJson);
        Json::Value@ personalBest = Nadeo::LiveServicePostRequest("/api/token/leaderboard/group/map?scores[" + mapUid +  "]=" + time, requestbody)[0];
        Log(Json::Write(personalBest));
        WorldPosition = personalBest["zones"][0]["ranking"]["position"];
        ContinentPosition = personalBest["zones"][1]["ranking"]["position"];   
        CountryPosition = personalBest["zones"][2]["ranking"]["position"];
        ProvincePosition = personalBest["zones"][3]["ranking"]["position"]; 
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
