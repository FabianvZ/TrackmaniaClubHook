class Leaderboard {

    private array<string> losers;
    string Losers {
        get {
            string result = "";
            for (uint i = 0; i < losers.Length; i++) {
                result += losers[i];

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
    

    Leaderboard(User@ user, Map@ map, uint score)
    {
        this.score = score;
        @this.map = map;
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
        Log(Json::Write(positions));
        for (int i = 0; i < positions.Length; i++) {
            string accountId = positions[i]["accountId"];
            Log("Account ID: " + accountId);
            if (accountId == user.Id) {
                @requestbody = Json::Object();
                requestbody["maps"] = Json::Array();
                Json::Value map = Json::Object();
                map["mapUid"] = this.map.Uid;
                map["groupUid"] = "Personal_Best";
                requestbody["maps"].Add(map);
                Json::Value@ position =  Nadeo::LiveServicePostRequest("/api/token/leaderboard/group/map?scores[{" + this.map.Uid +  "}]={" + score + "}", requestbody);
                leaderboard[i]["GlobalPosition"] = position[0]["zones"][0]["ranking"]["position"];
                for (int j = i; j > 0; j--) {
                    Log("J: " + Json::Write(leaderboard[j]));
                    Log("J - 1: " + Json::Write(leaderboard[j - 1]));
                    if (uint(leaderboard[j]["GlobalPosition"]) < uint(leaderboard[j - 1]["GlobalPosition"])) {
                        losers.InsertLast(leaderboard[j - 1]["username"]);

                        Json::Value temp = leaderboard[j];
                        leaderboard[j] = leaderboard[j - 1];
                        leaderboard[j - 1] = temp;
                    }
                }
                break;
            }
            else
            {
                uint position = positions[i]["zones"][0]["ranking"]["position"];
                for (int j = 0; j < leaderboard.Length; j++) {
                    if (leaderboard[j]["accountId"] == accountId) {
                        Log("Setting position: " + position);
                        leaderboard[j]["GlobalPosition"] = position;
                        break;
                    }
                }
            }
        }
    }  

    string toString() {
        string result = "";
        for(uint i = 0; i < leaderboard.Length; i++) {
            string username = leaderboard[i]["username"];
            string time = Time::Format(leaderboard[i]["score"]);
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

    private uint getPosition(uint pb) 
    {
        for(uint n = 0; n < leaderboard.Length; n++) {
            uint score = leaderboard[n]["score"];
            if (score != uint(-1) && pb < score) {
                return n;
            }
        }
        return leaderboard.Length;
    }

    private uint getPosition(const string &in name) 
    {
        for(uint n = 0; n < leaderboard.Length; n++) {
            if (leaderboard[n]["username"] == name) {
                return n;
            }
        }
        return leaderboard.Length;
    }

    uint getScore() {
        return score;
    }

}