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
        Json::Value@ leaderboard = Leaderboards::Get(pb.Map.Uid, ClubId);
        int position = 0;
        int maxUsernameLength = 0;
        LeaderboardFragments.InsertLast("");

        // Determine max username length for padding
        for (uint i = 0; i < leaderboard.Length; i++) {
            maxUsernameLength = Math::Max(maxUsernameLength, GetPlayerDisplayName(leaderboard[i]["accountId"]).Length);
        }

        for (uint i = 0; i < leaderboard.Length; i++) {
            if (i == ClubPosition - 1) {
                InsertLeaderBoardEntry(position++, pb.User.Name, pb.Score, maxUsernameLength);
            }

            if (leaderboard[i]["accountId"] == pb.User.Id) {
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

}