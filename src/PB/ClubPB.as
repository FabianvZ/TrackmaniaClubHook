class ClubPB {

    PB@ pb;
    uint ClubId, ClubPosition, PreviousClubPosition;
    array<string> LeaderboardFragments = { };
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
    array<string> playerIds = {};
    for (uint i = 0; i < leaderboard.Length; i++) {
        playerIds.InsertLast(string(leaderboard[i]["accountId"]));
    }

    dictionary usernames = NadeoServices::GetDisplayNamesAsync(playerIds);
    for (uint i = 0; i < playerIds.Length; i++)
    {
        leaderboard[i]["username"] = string(usernames[leaderboard[i]["accountId"]]);
    }

    int maxUsernameLength = pb.User.Name.Length;
    for (uint i = 0; i < leaderboard.Length; i++) {
        maxUsernameLength = Math::Max(maxUsernameLength, string(leaderboard[i]["username"]).Length);
    }

    uint position = 0;
    array<string> beatenPlayers = {};
    array<string> allEntries; 

    for (uint i = 0; i < leaderboard.Length; i++) {
        if (i == ClubPosition - 1) {
            allEntries.InsertLast(FormatLeaderBoardEntry(position++, pb.User.Name, pb.Score, maxUsernameLength));
        }

        if (leaderboard[i]["accountId"] == pb.User.Id) {
            continue;
        }

        allEntries.InsertLast(FormatLeaderBoardEntry(position++, leaderboard[i]["username"], leaderboard[i]["score"], maxUsernameLength));

        if (i >= ClubPosition - 1 && i < PreviousClubPosition) {
            beatenPlayers.InsertLast(GetDiscordUserId(leaderboard[i]["username"]));
        }
    }

    float maxLinesPerColumn = Math::Floor((1024 - 8) / (maxUsernameLength + 14));
    float columnCount = uint(Math::Ceil(allEntries.Length / maxLinesPerColumn));
    uint linesPerColumn = uint(Math::Ceil(allEntries.Length / columnCount));
    for (uint i = 0; i < allEntries.Length; i++) {
        if (i % linesPerColumn == 0) {
            LeaderboardFragments.InsertLast("");
        }
        if (allEntries[i].Length > 0) {
            LeaderboardFragments[LeaderboardFragments.Length - 1] += allEntries[i];
        }
    }

    Losers = beatenPlayers.Length > 0 ? beatenPlayers[beatenPlayers.Length - 1] : "";
    if (beatenPlayers.Length > 1) {
        beatenPlayers.RemoveLast();
        Losers = EscapeMarkdown(string::Join(beatenPlayers, ", ") + " & " + Losers);
    } 
}

private string FormatLeaderBoardEntry(int position, const string &in username, uint score, int maxUsernameLength)
{
    string paddedUsername = username;
    for (int i = username.Length; i < maxUsernameLength; i++) {
        paddedUsername += " ";
    }
    if (position < 9) {
        paddedUsername += " ";
    }
    string timeString = (score == uint(-1) ? "Secret" : Time::Format(score));
    return (position + 1) + ": " + paddedUsername + " " + timeString + "\n";
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