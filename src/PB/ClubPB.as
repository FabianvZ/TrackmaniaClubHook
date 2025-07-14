class ClubPB {

    PB@ pb;
    uint ClubId, ClubPosition, PreviousClubPosition;
    array<string> LeaderboardFragments;
    string Losers = "";
    
    ClubPB(PB@ pb, uint previousPosition, uint position, uint clubId) {
        @this.pb = pb;
        PreviousClubPosition = previousPosition;
        ClubPosition = position;
        ClubId = clubId;
        BuildLeaderboard();
    }

    private void BuildLeaderboard()
    {
        Json::Value@ leaderboard = Nadeo::LiveServiceRequest("/api/token/leaderboard/group/Personal_Best/map/" + pb.Map.Uid + "/club/" + ClubId + "/top?length=100&offset=0")["top"];
        auto ums = GetApp().UserManagerScript;
        MwFastBuffer<wstring> playerIds = MwFastBuffer<wstring>();
        for (uint i = 0; i < leaderboard.Length; i++) {
            playerIds.Add(wstring(leaderboard[i]["accountId"]));
        }

        auto req = ums.GetDisplayName(GetMainUserId(), playerIds);
        while (req.IsProcessing)
        {
            yield();
        }

        for (uint i = 0; i < playerIds.Length; i++)
        {
            leaderboard[i]["username"] = string(req.GetDisplayName(wstring(playerIds[i])));
        }

        int maxUsernameLength = 0;
        for (uint i = 0; i < leaderboard.Length; i++) {
            maxUsernameLength = Math::Max(maxUsernameLength, leaderboard[i]["username"].Length);
        }

        uint position = 0;
        array<string> beatenPlayers = {};
        for (uint i = 0; i < leaderboard.Length; i++) {
            if (i == ClubPosition - 1) {
                InsertLeaderBoardEntry(position++, pb.User.Name, pb.Score, maxUsernameLength);
            }

            if (leaderboard[i]["accountId"] == pb.User.Id) {
                continue;
            }

            InsertLeaderBoardEntry(position++, leaderboard[i]["username"], leaderboard[i]["score"], maxUsernameLength);

            if (i >= ClubPosition - 1 && i < PreviousClubPosition) {
                beatenPlayers.InsertLast(GetDiscordUserId(leaderboard[i]["username"]));
            }
        }

        Losers = beatenPlayers[beatenPlayers.Length - 1];
        if (beatenPlayers.Length > 1) {
            beatenPlayers.RemoveLast();
            Losers = string::Join(beatenPlayers, ", ") + " & " + Losers;
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

}