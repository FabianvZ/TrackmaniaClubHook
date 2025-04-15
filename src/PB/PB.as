class PB
{
    Map@ Map;
    User@ User;
    Medal Medal;
    uint PreviousScore, Score, PreviousClubPosition, ClubPosition, WorldPosition;
    array<string> LeaderboardFragments;
    string Losers = "";

    PB(User@ user, Map@ map, uint previousScore, uint score, uint previousPosition, uint position)
    {
        @User = user;
        @Map = map;
        PreviousClubPosition = previousPosition;
        ClubPosition = position;
        WorldPosition = GetPBPosition(map.Uid, score);
        Medal = GetReachedMedal(Map, score);
        PreviousScore = previousScore;
        Score = (score < Map.AuthorMedalTime && WeeklyShorts::IsWeeklyShorts(map)) ? -1 : score;
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
        Log(Json::Write(personalBest[0]));
        return personalBest[0]['zones'][0]["ranking"]["position"];
    }

    private void BuildLeaderboard()
    {
        Json::Value leaderboard = Nadeo::LiveServiceRequest("/api/token/leaderboard/group/Personal_Best/map/" + Map.Uid + "/club/" + clubId + "/top?length=100&offset=0")["top"];
        Log(Json::Write(leaderboard));
        int position = 0;
        int maxUsernameLength = 0;
        LeaderboardFragments.InsertLast("");

        // Determine max username length for padding
        for (uint i = 0; i < leaderboard.Length; i++) {
            maxUsernameLength = Math::Max(maxUsernameLength, GetPlayerDisplayName(leaderboard[i]["accountId"]).Length);
        }

        for (uint i = 0; i < leaderboard.Length; i++) {
            if (i == ClubPosition - 1) {
                InsertLeaderBoardEntry(position++, User.Name, Score, maxUsernameLength);
            }

            if (leaderboard[i]["accountId"] == User.Id) {
                continue;
            }

            string username = GetPlayerDisplayName(leaderboard[i]["accountId"]);
            InsertLeaderBoardEntry(position++, username, leaderboard[i]["score"], maxUsernameLength);

            if (i >= ClubPosition - 1 && i < PreviousClubPosition) {
                Losers += GetDiscordUserId(username);
                if (i + 3 < PreviousClubPosition) {
                    Losers += ", ";
                } else if (i + 3 == PreviousClubPosition) {
                    Losers += " & ";
                }
            }
        }
    }

    private void InsertLeaderBoardEntry(int position, const string &in username, uint score, int maxUsernameLength)
    {
        string paddedUsername = username;
        for (int i = username.Length; i < maxUsernameLength; i++) {
            paddedUsername += " ";
        }
        if (position < 9) {
            paddedUsername += " ";
        }
        string timeString = (score == uint(-1) ? "Secret" : Time::Format(score));
        string entry = (position + 1) + ": " + paddedUsername + " " + timeString + "\n";
        if (LeaderboardFragments[LeaderboardFragments.Length - 1].Length + entry.Length > 1024) {
            LeaderboardFragments.InsertLast(entry);
        } else {
            LeaderboardFragments[LeaderboardFragments.Length - 1] += entry;
        }
    }

    private string GetDiscordUserId(const string &in TMUsername)
    {
        array<string> parts = settings_usernames.Split("\n");
        for (uint i = 0; i < parts.Length; i++)
        {
            array<string> nameParts = parts[i].Split(";");
            if (nameParts[0] == TMUsername)
            {
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
