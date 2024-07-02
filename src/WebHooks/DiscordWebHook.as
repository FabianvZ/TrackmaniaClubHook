class DiscordWebHook: WebHook
{
    DiscordWebHook(const string &in url, const string &in body)
    {
        //if (!Regex::Match(url, """(https://)?(\\w+\.)*discord\.com\/api\/webhooks\/\d+\/\w+\/?""")) return;
        super(Net::HttpMethod::Post, url, Json::Parse(DiscordDefaults::Header), body, true, true);
    }
}
