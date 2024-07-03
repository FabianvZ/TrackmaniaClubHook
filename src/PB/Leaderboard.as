class Leaderboard {

    Json::Value leaderboard;
    User@ User;
    Map@ Map;

    Leaderboard(User@ user, Map@ map) {
        @User = user;
        @Map = map;
        leaderboard = GetMapLeaderboard();
    }

    string getLosers(PB@ pb) {
        string result = "";
        uint startPos = getPosition(pb.CurrentPB);
        uint endPos = getLeaderboardPosition();
        for (uint i = startPos; i < endPos; i++) {
            result += leaderboard["top"][i]["accountId"];
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
        for(uint i = 0; i < leaderboard["top"].get_Length(); i++) {
            string username = leaderboard["top"][i]["accountId"];
            string time = Timer::to_string(leaderboard["top"][i]["score"]);
            result += (i + 1) + ": " + username + " : " + time;
            if (i != leaderboard["top"].get_Length() - 1) {
                result += "\\n";
            }
        }
        return result;
    }

    Json::Value GetMapLeaderboard(){
        Log("Getting map Leaderboard for club");
        auto newleaderboard = Nadeo::LiveServiceRequest("/api/token/leaderboard/group/Personal_Best/map/" + Map.Uid + "/club/" + User.PinnedClub + "/top?length=100&offset=0");

        for(uint i = 0; i < newleaderboard["top"].get_Length(); i++) {
            newleaderboard["top"][i]["accountId"] = GetPlayerDisplayName(newleaderboard["top"][i]["accountId"]);
            string username = newleaderboard["top"][i]["accountId"];
            Log("Place: " + i + " : " + username);
        }
        return newleaderboard;
    }

    uint getPosition(uint pb) {
        for(uint n = 0; n < leaderboard["top"].get_Length(); n++) {
            uint score = leaderboard["top"][n]["score"];
            if (pb < score) {
                return n;
            }
        }
        return leaderboard["top"].get_Length();
    }

    uint getLeaderboardPosition() {
        for(uint i = 0; i < leaderboard["top"].get_Length(); i++) {
            if (leaderboard["top"][i]["accountId"] == User.Id) {
                return i;
            }
        }
        return leaderboard["top"].get_Length();
    }

    uint getPB() {
        for(uint i = 0; i < leaderboard["top"].get_Length(); i++) {
            if (leaderboard["top"][i]["accountId"] == User.Name) {
                return leaderboard["top"][i]["score"];
            }
        }
        return uint(-1);
    }

}