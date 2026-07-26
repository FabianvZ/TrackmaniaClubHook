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
        Medal = Medal::GetReachedMedal(Map, score);
        PreviousScore = previousScore;
        _score = score;
        Score = IsSecretTime(map, score) ? -1 : score;
    }

    private bool IsSecretTime(Map@ map, uint score)
    {
        if (score <= Map.AuthorMedalTime && Campaign::WeeklyShorts.IsCurrentCampaignMap(map))
            return true;

        // seemingly there's no nice global way of determining whether your pb is secret. if a record belongs to the authenticated account, the time is revealed.
        // to work around that, check if the time below our pb is secret. if yes, then ours is too
        if (Leaderboard::IsLeaderboardTimeBelowSecret(map.Uid, score))
            return true;

        return false;
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
        return json["zones"].Length > index ? json["zones"][index]["ranking"]["position"] : 0;
    }

}
