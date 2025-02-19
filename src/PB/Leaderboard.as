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
        leaderboard = Nadeo::LiveServiceRequest("/api/token/leaderboard/group/Personal_Best/map/" + map.Uid + "/club/" + clubId + "/top?length=100&offset=0")["top"];

        Json::Value@ requestbody = Json::Object();
        requestbody["listPlayer"] = Json::Array();
        // Replace trackmania user ids with trackmania usernames
        for(uint i = 0; i < leaderboard.Length; i++) {
            Json::Value myRecord = Json::Object();
            myRecord["accountId"] = leaderboard[i]["accountId"];
            requestbody["listPlayer"].Add(myRecord);

            leaderboard[i]["username"] = GetPlayerDisplayName(leaderboard[i]["accountId"]);
        }
        
        // Insert global leaderboards into leaderboard
        Json::Value@ positions = Nadeo::LiveServicePostRequest("/api/token/leaderboard/trophy/player", requestbody)["rankings"];
        for (uint i = 0; i < positions.Length; i++) {
            string accountId = positions[i]["accountId"];
            {
                uint position = positions[i]["zones"][0]["ranking"]["position"];
                for (uint j = 0; j < leaderboard.Length; j++) {
                    if (leaderboard[j]["accountId"] == accountId) {
                        leaderboard[j]["GlobalPosition"] = position;
                        break;
                    }
                }
            }
        }

        // Insert Global position for personal best into leaderboard
        @requestbody = Json::Object();
        requestbody["maps"] = Json::Array();
        Json::Value mapJson = Json::Object();
        mapJson["mapUid"] = map.Uid;
        mapJson["groupUid"] = "Personal_Best";
        requestbody["maps"].Add(mapJson);
        for (uint i = 0; i <= leaderboard.Length; i++) {
            if (i == leaderboard.Length) {
                Json::Value myRecord = Json::Object();
                myRecord["accountId"] = user.Id;
                myRecord["username"] = user.Name;
                myRecord["score"] = score;
                leaderboard.Add(myRecord);
            }

            if (leaderboard[i]["accountId"] == user.Id) {
                leaderboard[i]["GlobalPosition"] = Nadeo::LiveServicePostRequest("/api/token/leaderboard/group/map?scores[" + map.Uid +  "]=" + score, requestbody)[0]["zones"][0]["ranking"]["position"];
                if (WeeklyShorts::IsWeeklyShorts(map)) {
                    leaderboard[i]["score"] = -1;
                }

                for (int j = i; j > 0; j--) {
                    if (uint(leaderboard[j]["GlobalPosition"]) < uint(leaderboard[j - 1]["GlobalPosition"])) {
                        Log("Beating: " + string(leaderboard[j - 1]["username"]));
                        losers.InsertLast(leaderboard[j - 1]["username"]);

                        Json::Value temp = leaderboard[j];
                        leaderboard[j] = leaderboard[j - 1];
                        leaderboard[j - 1] = temp;
                    }
                }                 
                break;
            }
        
        }
    }  

    string toString() {
        string result = "";
        for(uint i = 0; i < leaderboard.Length; i++) {
            string username = leaderboard[i]["username"];
            string time = leaderboard[i]["score"] == -1? "Secret" : Time::Format(leaderboard[i]["score"]);
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