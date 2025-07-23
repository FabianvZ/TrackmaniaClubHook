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
        WorldPosition = getScore(personalBest, 0);
        ContinentPosition = getScore(personalBest, 1);   
        CountryPosition = getScore(personalBest, 2);
        ProvincePosition = getScore(personalBest, 3); 
    }

    private uint getScore(Json::Value@ json, uint index) {
        return json.Length >= index ? json["zones"][index]["ranking"]["position"] : 0;
    }

    private Medal GetReachedMedal(Map@ map, uint currentPB)
    {
#if DEPENDENCY_CHAMPIONMEDALS
        if (currentPB <= map.ChampionMedalTime) return Medal::Champion;
#endif
#if DEPENDENCY_WARRIORMEDALS
        if (currentPB <= map.WarriorMedalTime) return Medal::Warrior;
#endif
        if (currentPB <= map.AuthorMedalTime) return Medal::Author;
        if (currentPB <= map.GoldMedalTime) return Medal::Gold;
        if (currentPB <= map.SilverMedalTime) return Medal::Silver;
        if (currentPB <= map.BronzeMedalTime) return Medal::Bronze;
        return Medal::No;
    }
}
