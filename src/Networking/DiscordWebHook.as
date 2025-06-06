class DiscordWebHook : WebRequest
{

    DiscordWebHook(PB@ pb)
    {
        super(Net::HttpMethod::Post, settings_discord_URL, Json::Parse(DiscordDefaults::Header), GetInterpolatedBody(pb), true, true);
    }

    string GetInterpolatedBody(PB@ pb)
    {
        Map@ map = pb.Map;
        bool improved = pb.ClubPosition != pb.PreviousClubPosition;

        Json::Value@ body = Json::Object();
        body["username"] = "Trackmania";
        body["avatar_url"] = "https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcQCHBYTbusq8rivJAHP59YQbUtiqoqpbiPUS2Mdxi_pDgiYqGtttj0sS3EO05JS6Xama2A&usqp=CAU";
        body["flags"] = 4096;
        body["content"] = "#" + pb.User.Name + "(" + URL::TrackmaniaIOPlayer + pb.User.Id + ") (<@" + settings_discord_user_id + ">) got a " + improved? " new" : "" + " PB " + Medal::ToDiscordString(pb.Medal) + improved? " beating " + pb.Losers : "";

        body["embeds"] = Json::Array();
        body["embeds"].Add(Json::Object());
        body["embeds"][0]["color"] = 65290;
        body["embeds"][0]["thumbnail"] = Json::Object();
        body["embeds"][0]["thumbnail"]["url"] = map.TrackId != 0 ? URL::TrackmaniaExchangeThumbnail + map.TrackId : "";

        Json::Value@ fields = Json::Array();
        AddField(fields, "Map", "[" + map.CleansedName + "](" + URL::TrackmaniaIOLeaderboard + map.Uid + ") by [" + map.AuthorName + "](" + URL::TrackmaniaIOPlayer + map.AuthorLogin + ")");
        AddField(fields, "Time", "[" + (pb.Score == uint(-1) ? "Secret" : Time::Format(pb.Score)) + "]" + (pb.PreviousScore == uint(-1) || pb.Score == uint(-1) ? "" : " (-" + Time::Format(pb.PreviousScore - pb.Score) + ")"), true);
        AddField(fields, "Rank", "" + pb.WorldPosition, true);
        AddField(fields, "GrindTime", Time::Format(GrindingStats::GetSessionTime()) +  " / " + Time::Format(GrindingStats::GetTotalTime()));
        AddField(fields, "Finishes", GrindingStats::GetSessionFinishes() +  " / " + GrindingStats::GetTotalFinishes(), true);
        AddField(fields, "Resets", GrindingStats::GetSessionResets() + " / " + GrindingStats::GetTotalResets(), true);
        AddField(fields, "Club Position", pb.PreviousClubPosition + improved? " -> " + pb.ClubPosition : "");
        for (int i = 0; i < pb.LeaderboardFragments.Length; i++) {
            AddField(fields, i == 0? "Leaderboard" : "\u200B", "```" + pb.LeaderboardFragments[i] + "```", settings_inline_columns);
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
