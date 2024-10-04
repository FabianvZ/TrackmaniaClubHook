class DiscordWebHook : WebRequest
{

    DiscordWebHook(const string &in url, const string &in body)
    {
        super(Net::HttpMethod::Post, url, Json::Parse(DiscordDefaults::Header), body, true, true);
    }

}
