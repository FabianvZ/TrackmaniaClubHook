class DiscordWebHook : WebRequest
{

    DiscordWebHook(ClubPB@ clubPB, const string &in discordURL)
    {
        super(Net::HttpMethod::Post, discordURL, Json::Parse(DiscordDefaults::Header), GetInterpolatedBody(clubPB), true, true);
    }

    string GetInterpolatedBody(ClubPB@ clubPB)
    {
        Map@ map = clubPB.pb.Map;
        bool improved = clubPB.ClubPosition != clubPB.PreviousClubPosition;

        Json::Value@ body = Json::Object();
        body["username"] = "Trackmania";
        body["avatar_url"] = "https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcQCHBYTbusq8rivJAHP59YQbUtiqoqpbiPUS2Mdxi_pDgiYqGtttj0sS3EO05JS6Xama2A&usqp=CAU";
        body["flags"] = 4096;
        body["content"] = "## [" + clubPB.pb.User.Name + "](" + URL::TrackmaniaIOPlayer + clubPB.pb.User.Id + ") (<@" + settings_discord_user_id + ">) got a " + ((improved)? "new" : "") + " PB " + Medal::ToDiscordString(clubPB.pb.Medal) + "###" + (improved? " beating " + clubPB.Losers : "");

        body["embeds"] = Json::Array();
        body["embeds"].Add(Json::Object());
        body["embeds"][0]["color"] = 65290;
        body["embeds"][0]["thumbnail"] = Json::Object();
        body["embeds"][0]["thumbnail"]["url"] = map.TrackId != 0 ? URL::TrackmaniaExchangeThumbnail + map.TrackId : "";

        Json::Value@ fields = Json::Array();
        AddField(fields, "Map", "[" + map.CleansedName + "](" + URL::TrackmaniaIOLeaderboard + map.Uid + ") by [" + map.AuthorName + "](" + URL::TrackmaniaIOPlayer + map.AuthorLogin + ")");
        AddField(fields, "Time", "" + (clubPB.pb.Score == uint(-1) ? "Secret" : Time::Format(clubPB.pb.Score)) + (clubPB.pb.PreviousScore == uint(-1) || clubPB.pb.Score == uint(-1) ? "" : " (-" + Time::Format(clubPB.pb.PreviousScore - clubPB.pb.Score) + ")"), true);
        AddField(fields, "Rank", "" + clubPB.pb.WorldPosition, true);
#if DEPENDENCY_GRINDINGSTATS
        if (send_grinding_stats) {
            AddField(fields, "GrindTime", Time::Format(GrindingStats::GetSessionTime()) +  " / " + Time::Format(GrindingStats::GetTotalTime()));
            AddField(fields, "Finishes", GrindingStats::GetSessionFinishes() +  " / " + GrindingStats::GetTotalFinishes(), true);
            AddField(fields, "Resets", GrindingStats::GetSessionResets() + " / " + GrindingStats::GetTotalResets(), true);
        }
#endif
        AddField(fields, "Club Position", clubPB.PreviousClubPosition + (improved? " -> " + clubPB.ClubPosition : ""));
        for (uint i = 0; i < clubPB.LeaderboardFragments.Length; i++) {
            AddField(fields, i == 0? "Leaderboard" : "\u200B", "```" + clubPB.LeaderboardFragments[i] + "```", settings_inline_columns);
        }
        body["embeds"][0]["fields"] = fields;

        return Json::Write(body);
    }

    private void AddField(Json::Value@ &in jsonObject, const string &in name, const string &in value, bool inline = false)
    {
        Json::Value@ field = Json::Object();
        field["name"] = name;
        field["value"] = value;
        field["inline"] = inline;
        jsonObject.Add(field);
    }

}
