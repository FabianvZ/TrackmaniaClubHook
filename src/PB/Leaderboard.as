class Leaderboard {

    private Json::Value leaderboard;
    private uint score;

    Leaderboard(User@ user, Map@ map, uint score)
    {
        this.score = score;
        leaderboard = Nadeo::LiveServiceRequest("/api/token/leaderboard/group/Personal_Best/map/" + map.Uid + "/club/" + clubId + "/top?length=100&offset=0");
        // Replace trackmania user ids with trackmania usernames
        for(uint i = 0; i < leaderboard["top"].Length; i++) {
            leaderboard["top"][i]["accountId"] = GetPlayerDisplayName(leaderboard["top"][i]["accountId"]);
        }
        // Insert new time into leaderboard without waiting for it to update
        uint currentPosition = getPosition(user.Name);
        if (currentPosition == leaderboard["top"].Length) 
        {
            Json::Value myRecord = Json::Object();
            myRecord["accountId"] = user.Name;
            leaderboard["top"].Add(myRecord);
        }
        leaderboard["top"][currentPosition]["score"] = score;
        for (uint i = currentPosition; i > getPosition(score); i--)
        {
            Json::Value temp = leaderboard["top"][i - 1];
            leaderboard["top"][i - 1] = leaderboard["top"][i];
            leaderboard["top"][i] = temp;
        }
    }  

    string getLosers(uint oldScore) {
        string result = "";
        uint startPos = getPosition(score);
        uint endPos = getPosition(oldScore);
        for (uint i = startPos; i < endPos; i++) {
            result += GetDiscordUserId(leaderboard["top"][i]["accountId"]);

            if (i != endPos && endPos - 1 != startPos) {
                if (i == endPos - 2) {
                    result += " & ";
                } else {
                    result += ", ";
                }
            }
        }
        return result;
    }

    string toString() {
        string result = "";
        for(uint i = 0; i < leaderboard["top"].Length; i++) {
            string username = leaderboard["top"][i]["accountId"];
            string time = Time::Format(leaderboard["top"][i]["score"]);
            result += (i + 1) + ": " + username + " : " + time;
            if (i != leaderboard["top"].Length - 1) {
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

    uint getPosition(uint pb) 
    {
        for(uint n = 0; n < leaderboard["top"].Length; n++) {
            uint score = leaderboard["top"][n]["score"];
            if (pb < score) {
                return n;
            }
        }
        return leaderboard["top"].Length;
    }

    uint getPosition(const string &in name) 
    {
        for(uint n = 0; n < leaderboard["top"].Length; n++) {
            if (leaderboard["top"][n]["accountId"] == name) {
                return n;
            }
        }
        return leaderboard["top"].Length;
    }

    uint getScore() {
        return score;
    }

}