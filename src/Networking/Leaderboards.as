namespace Leaderboards {

    dictionary cache;

    Json::Value@ Get(const string &in mapUid, uint clubId, int length = 100, int offset = 0) {
        if (cache.Exists("" + clubId)) {
            return cache["" + clubId];
        }

        Json::Value@ leaderboard = Nadeo::LiveServiceRequest("/api/token/leaderboard/group/Personal_Best/map/" + mapUid + "/club/" + clubId + "/top?length=" + length + "&offset=" + offset);
        Log("Leaderboard fetched: " + Json::Write(leaderboard));

        cache["" + clubId] = leaderboard;
        return leaderboard;
    }

}