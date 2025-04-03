class DiscordWebHook : WebRequest
{

    DiscordWebHook(PB@ pb)
    {
        super(Net::HttpMethod::Post, settings_discord_URL, Json::Parse(DiscordDefaults::Header), GetInterpolatedBody(pb), true, true);
    }

    string GetInterpolatedBody(PB@ pb)
{
    Map@ map = pb.Map;

    array<string> parts = settings_Body.Split("[[");
    for (uint i = 0; i < parts.Length; i++)
    {
        if (pb.PreviousClubPosition == pb.ClubPosition) {
            parts[i] = Regex::Replace(parts[i], "beating", "");
            parts[i] = Regex::Replace(parts[i], "new ", "");
        }
        parts[i] = Regex::Replace(parts[i], "\\[UserName\\]", pb.User.Name);
        parts[i] = Regex::Replace(parts[i], "\\[UserLink\\]", URL::TrackmaniaIOPlayer + pb.User.Id);
        parts[i] = Regex::Replace(parts[i], "\\[UserDiscordId\\]", settings_discord_user_id);
        parts[i] = Regex::Replace(parts[i], "\\[Time\\]", pb.Score == uint(-1)? "Secret" : Time::Format(pb.Score));
        parts[i] = Regex::Replace(parts[i], "\\[TimeDelta\\]",  (pb.PreviousScore == uint(-1) || pb.Score == uint(-1)) ?  "" : " (-" + Time::Format(pb.PreviousScore - pb.Score) + ")");
        parts[i] = Regex::Replace(parts[i], "\\[Rank\\]", "" + pb.WorldPosition);
        parts[i] = Regex::Replace(parts[i], "\\[Medal\\]", Medal::ToDiscordString(pb.Medal));
        parts[i] = Regex::Replace(parts[i], "\\[MapName\\]", map.CleansedName);
        parts[i] = Regex::Replace(parts[i], "\\[MapLink\\]", URL::TrackmaniaIOLeaderboard + map.Uid);
        parts[i] = Regex::Replace(parts[i], "\\[MapAuthorName\\]", map.AuthorName);
        parts[i] = Regex::Replace(parts[i], "\\[MapAuthorLink\\]", URL::TrackmaniaIOPlayer + map.AuthorLogin);
        parts[i] = Regex::Replace(parts[i], "\\[ThumbnailLink\\]", map.TrackId != 0 ? URL::TrackmaniaExchangeThumbnail + map.TrackId : "");
        parts[i] = Regex::Replace(parts[i], "\\[GrindTime\\]", Time::Format(GrindingStats::GetSessionTime()) +  " / " + Time::Format(GrindingStats::GetTotalTime()));
        parts[i] = Regex::Replace(parts[i], "\\[Finishes\\]", GrindingStats::GetSessionFinishes() +  " / " + GrindingStats::GetTotalFinishes());
        parts[i] = Regex::Replace(parts[i], "\\[Resets\\]", GrindingStats::GetSessionResets() + " / " + GrindingStats::GetTotalResets());
        parts[i] = Regex::Replace(parts[i], "\\[ClubLeaderboard\\]", pb.Leaderboard);
        parts[i] = Regex::Replace(parts[i], "\\[Losers\\]", pb.Losers);
    }

    return string::Join(parts, "[");
}

}
