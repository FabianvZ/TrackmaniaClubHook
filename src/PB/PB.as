class PB
{
    Map@ Map;
    User@ User;
    Medal Medal;
    uint PreviousScore, Score, PreviousClubPosition, ClubPosition, WorldPosition;
    string Leaderboard = "", Losers = "";

    PB(User@ user, Map@ map, uint previousScore, uint score, uint previousPosition, uint position)
    {
        @User = user;
        @Map = map;
        PreviousClubPosition = previousPosition;
        ClubPosition = position;
        WorldPosition = GetPBPosition(map.Uid, score);
        Medal = GetReachedMedal(Map, score);
        PreviousScore = previousScore;
        Score = (score < Map.AuthorMedalTime && WeeklyShorts::IsWeeklyShorts(map))? -1 : score;
        BuildLeaderboard();
    }

    private int GetPBPosition(const string &in mapUid, uint time)
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

    private void BuildLeaderboard()
    {
        Json::Value leaderboard = Nadeo::LiveServiceRequest("/api/token/leaderboard/group/Personal_Best/map/" + Map.Uid + "/club/" + clubId + "/top?length=50&offset=0")["top"];
        int position = 0;

        for(uint i = 0; i < leaderboard.Length; i++) {

            if (leaderboard[i]["accountId"] == User.Id) {
                continue;
            }

            if (i == ClubPosition - 1) {
                InsertLeaderBoardEntry(position++, User.Name, Score);
                Leaderboard += "\\n";
            }

            string username = GetPlayerDisplayName(leaderboard[i]["accountId"]);

            InsertLeaderBoardEntry(position++, username, leaderboard[i]["score"]);
            if (i != leaderboard.Length - 1) {
                Leaderboard += "\\n";
            }

            if (i >= ClubPosition - 1 && i < PreviousClubPosition - 1) {
                Losers += GetDiscordUserId(username);
                if (i < PreviousClubPosition - 3) {
                    Losers += ", ";
                } else if (i == PreviousClubPosition - 3) {
                    Losers += " & ";
                }
            }
        }
    }

    private void InsertLeaderBoardEntry(int position, const string &in username, uint score) 
    {
        Leaderboard += (position + 1) + ": " + username + " : " + (score == uint(-1)? "Secret" : Time::Format(score));
    }

    private string GetDiscordUserId(const string &in TMUsername){
        array<string> parts = settings_usernames.Split("\n");

        for (uint i = 0; i < parts.Length; i++)
        {
            array<string> nameParts = parts[i].Split(";");
            if(nameParts[0] == TMUsername){
                return "<@" + nameParts[1] + ">";
            }
        }

        return TMUsername;
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
