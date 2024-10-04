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
        parts[i] = Regex::Replace(parts[i], "\\[UserName\\]", pb.User.Name);
        parts[i] = Regex::Replace(parts[i], "\\[UserLink\\]", URL::TrackmaniaIOPlayer + pb.User.Id);
        parts[i] = Regex::Replace(parts[i], "\\[UserDiscordId\\]", settings_discord_user_id);
        parts[i] = Regex::Replace(parts[i], "\\[Time\\]", Time::Format(pb.CurrentPB));
        parts[i] = Regex::Replace(parts[i], "\\[TimeDelta\\]", pb.PreviousPB != uint(-1) ? " (-" + Time::Format(pb.PreviousPB - pb.CurrentPB) + ")" : "");
        parts[i] = Regex::Replace(parts[i], "\\[Rank\\]", "" + pb.Position);
        parts[i] = Regex::Replace(parts[i], "\\[Medal\\]", Medal::ToDiscordString(pb.Medal));
        parts[i] = Regex::Replace(parts[i], "\\[MapName\\]", map.CleansedName);
        parts[i] = Regex::Replace(parts[i], "\\[MapLink\\]", URL::TrackmaniaIOLeaderboard + map.Uid);
        parts[i] = Regex::Replace(parts[i], "\\[MapAuthorName\\]", map.AuthorName);
        parts[i] = Regex::Replace(parts[i], "\\[MapAuthorLink\\]", URL::TrackmaniaIOPlayer + map.AuthorLogin);
        parts[i] = Regex::Replace(parts[i], "\\[ThumbnailLink\\]", map.TrackId != 0 ? URL::TrackmaniaExchangeThumbnail + map.TrackId : "");
        parts[i] = Regex::Replace(parts[i], "\\[GrindTime\\]", Time::Format(data.get_timer().session) +  " / " + Time::Format(data.get_timer().total));
        parts[i] = Regex::Replace(parts[i], "\\[Finishes\\]", data.finishes.session +  " / " + data.finishes.total);
        parts[i] = Regex::Replace(parts[i], "\\[Resets\\]", data.resets.session + " / " + data.resets.total);
        parts[i] = Regex::Replace(parts[i], "\\[ClubLeaderboard\\]", pb.CurrentLeaderboard.toString());
        parts[i] = Regex::Replace(parts[i], "\\[Losers\\]", pb.PreviousLeaderboard.getLosers(pb));
    }

    return string::Join(parts, "[");
}

}
