class Leaderboard {

    private array<string> losers;
    string Losers {
        get {
            string result = "";
            for (uint i = 0; i < losers.Length; i++) {
                result += GetDiscordUserId(losers[i]);

                if (i != losers.Length && losers.Length - 1 != 0) {
                    if (i == losers.Length - 2) {
                        result += " & ";
                    } else {
                        result += ", ";
                    }
                }
            }
            return result;
        }
    }

    bool HasBeatenClubMember {
        get {
            return losers.Length > 0;
        }
    }

    private Json::Value leaderboard;
    private uint score;
    private Map@ map;
    private User@ user;

    Leaderboard(User@ user, Map@ map, uint score)
    {
        this.score = score;
        @this.map = map;
        @this.user = user;
        leaderboard = Nadeo::LiveServiceRequest("/api/token/leaderboard/group/Personal_Best/map/" + map.Uid + "/club/" + clubId + "/top?length=50&offset=0")["top"];

        for(uint i = 0; i < leaderboard.Length; i++) {
            leaderboard[i]["username"] = GetPlayerDisplayName(leaderboard[i]["accountId"]);
        }

        Json::Value@ requestbody = Json::Object();
        requestbody["maps"] = Json::Array();
        Json::Value mapJson = Json::Object();
        mapJson["mapUid"] = map.Uid;
        mapJson["groupUid"] = "Personal_Best";
        requestbody["maps"].Add(mapJson);
        Json::Value@ personalBest = Nadeo::LiveServicePostRequest("/api/token/leaderboard/group/map/club/" + clubId + "?scores[" + map.Uid +  "]=" + score, requestbody);
        int leaderboardPosition = personalBest[0]["position"];
        Log("New leaderboard position: " + leaderboardPosition);

        for(uint i = 0; i <= leaderboard.Length; i++) {
            if (i == leaderboard.Length) {
                leaderboard.Add(Json::Object());
                leaderboard[i]["accountId"] = user.Id;
                leaderboard[i]["score"] = score;
                leaderboard[i]["username"] = GetPlayerDisplayName(leaderboard[i]["accountId"]);
            }    

            if (leaderboard[i]["accountId"] == user.Id) {
                Log("Old leaderboard position " + i);
                leaderboard[i]["score"] = (score < map.AuthorMedalTime && WeeklyShorts::IsWeeklyShorts(map))? -1 : score;

                for (int j = i; j >= leaderboardPosition; j--) {
                    Json::Value temp = leaderboard[j];
                    leaderboard[j] = leaderboard[j - 1];
                    leaderboard[j - 1] = temp;

                    losers.InsertLast(leaderboard[j]["username"]);
                    Log("Beaten club member: " + string(leaderboard[j]["username"]));
                }   
                break;
            }
        }
    }  

    string toString() {
        string result = "";
        for(uint i = 0; i < leaderboard.Length; i++) {
            string username = leaderboard[i]["username"];
            string time = uint(leaderboard[i]["score"]) == uint(-1)? "Secret" : Time::Format(leaderboard[i]["score"]);
            result += (i + 1) + ": " + username + " : " + time;
            if (i != leaderboard.Length - 1) {
                result += "\\n";
            }
        }
        return result;
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

    uint getScore() {
        return score;
    }

}