class DiscordWebHook : WebRequest
{

    DiscordWebHook(PB@ pb)
    {
        super(Net::HttpMethod::Post, settings_discord_URL, Json::Parse(DiscordDefaults::Header), GetInterpolatedBody(pb), true, true);
    }

    string GetInterpolatedBody(PB@ pb)
{
    Map@ map = pb.Map;
    bool IsWeeklyShorts = WeeklyShorts::IsWeeklyShorts(map);

    array<string> parts = settings_Body.Split("[[");
    for (uint i = 0; i < parts.Length; i++)
    {
        parts[i] = Regex::Replace(parts[i], "\\[UserName\\]", pb.User.Name);
        parts[i] = Regex::Replace(parts[i], "\\[UserLink\\]", URL::TrackmaniaIOPlayer + pb.User.Id);
        parts[i] = Regex::Replace(parts[i], "\\[UserDiscordId\\]", settings_discord_user_id);
        parts[i] = Regex::Replace(parts[i], "\\[Time\\]", IsWeeklyShorts? "Secret" : Time::Format(pb.Leaderboard.getScore()));
        parts[i] = Regex::Replace(parts[i], "\\[TimeDelta\\]", pb.PreviousScore != uint(-1) ? " (-" + Time::Format(pb.PreviousScore - pb.Leaderboard.getScore()) + ")" : "");
        parts[i] = Regex::Replace(parts[i], "\\[Rank\\]", "" + pb.Position);
        parts[i] = Regex::Replace(parts[i], "\\[Medal\\]", Medal::ToDiscordString(pb.Medal));
        parts[i] = Regex::Replace(parts[i], "\\[MapName\\]", map.CleansedName);
        parts[i] = Regex::Replace(parts[i], "\\[MapLink\\]", URL::TrackmaniaIOLeaderboard + map.Uid);
        parts[i] = Regex::Replace(parts[i], "\\[MapAuthorName\\]", map.AuthorName);
        parts[i] = Regex::Replace(parts[i], "\\[MapAuthorLink\\]", URL::TrackmaniaIOPlayer + map.AuthorLogin);
        parts[i] = Regex::Replace(parts[i], "\\[ThumbnailLink\\]", map.TrackId != 0 ? URL::TrackmaniaExchangeThumbnail + map.TrackId : "");
        parts[i] = Regex::Replace(parts[i], "\\[GrindTime\\]", Time::Format(GrindingStats::GetSessionTime()) +  " / " + Time::Format(GrindingStats::GetTotalTime()));
        parts[i] = Regex::Replace(parts[i], "\\[Finishes\\]", GrindingStats::GetSessionFinishes() +  " / " + GrindingStats::GetTotalFinishes());
        parts[i] = Regex::Replace(parts[i], "\\[Resets\\]", GrindingStats::GetSessionResets() + " / " + GrindingStats::GetTotalResets());
        parts[i] = Regex::Replace(parts[i], "\\[ClubLeaderboard\\]", pb.Leaderboard.toString());
        parts[i] = Regex::Replace(parts[i], "\\[Losers\\]", pb.Leaderboard.getLosers(pb.PreviousScore));
    }

    return string::Join(parts, "[");
}

}
