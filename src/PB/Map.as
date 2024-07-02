class Map
{
    string Uid;
    string Name;
    string AuthorName;
    string AuthorLogin;
    string CleansedName;
    uint BronzeMedalTime;
    uint SilverMedalTime;
    uint GoldMedalTime;
    uint AuthorMedalTime;
    uint ChampionMedalTime;

    int TrackId;

    Map(CGameCtnChallenge@ map)
    {
        Uid = map.MapInfo.MapUid;
        Name = map.MapInfo.Name;
        AuthorName = map.MapInfo.AuthorNickName;
        AuthorLogin = map.MapInfo.AuthorLogin;
        CleansedName = GetCleansedTrackmaniaStyledString(Name);

        BronzeMedalTime = map.TMObjective_BronzeTime;
        SilverMedalTime = map.TMObjective_SilverTime;
        GoldMedalTime = map.TMObjective_GoldTime;
        AuthorMedalTime = map.TMObjective_AuthorTime;
#if DEPENDENCY_CHAMPIONMEDALS
        ChampionMedalTime = ChampionMedals::GetCMTime();
#endif

        WebRequest webRequest = 
        WebRequest(Net::HttpMethod::Get, URL::TrackmaniaExchangeGetMapInfo + Uid, Json::Parse("""{"User-Agent":"TrackManiaWebhook/0.0.1"}"""), "", true, false);
        auto response = webRequest.Send();
        if (response.ResponseCode() != 200) return;

        if (response.Json().GetType() != Json::Type::Object) return;
        if (response.Json().HasKey("TrackID"))
            TrackId = response.Json().Get("TrackID");
    }

    string GetCleansedTrackmaniaStyledString(string _dirty)
    {
        string pattern = """\$[oiwntsgzOIWNTSGZ]|\$[0-9a-fA-F]{3}""";

        array<string> parts = _dirty.Split("$$");
        for (uint i = 0; i < parts.Length; i++)
            parts[i] = Regex::Replace(parts[i], pattern, "");

        return string::Join(parts, "$");
    }
}
