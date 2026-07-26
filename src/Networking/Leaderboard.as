namespace Leaderboard {
    bool storedKnownSecretThreshold = false;
    uint knownSecretThreshold;
    string knownSecretThresholdMapUid;

    bool IsLeaderboardTimeBelowSecret(string mapUid, uint score) {
        if (score == -1)
            return false;

        if (storedKnownSecretThreshold) {
            if (mapUid == knownSecretThresholdMapUid) {
                if (score < knownSecretThreshold) {
                    return true;
                }
            } else {
                // changed map, reset stored threshold
                storedKnownSecretThreshold = false;
            }
        }

        Json::Value@ surroundRes = Nadeo::LiveServiceRequest("/api/token/leaderboard/group/Personal_Best/map/" + mapUid + "/surround/0/1?score=" + score + "onlyWorld=true");
        try {
            Json::Value@ surrounding = surroundRes["tops"][0]["top"];

            if (surrounding.Length != 2) {
                // the surround endpoint returns a fake entry at the requested time drove by us
                // if we just barely pbed such that our previous pb is the time below it, then only the one new fake entry will be returned, so we can't know if it's secret, since there's no time below it to check with
                return false;
            }
            
            if (surrounding[1]["score"] == -1) {
                storedKnownSecretThreshold = true;
                knownSecretThresholdMapUid = mapUid;
                knownSecretThreshold = score;
                return true;
            }
        } catch {
            Log("Error when fetching surrounding records: " + getExceptionInfo());
        }

        return false;
    }
}

