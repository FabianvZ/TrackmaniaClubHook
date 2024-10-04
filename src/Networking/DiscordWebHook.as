class DiscordWebHook
{
    Net::HttpMethod Method;
    string URL;
    Json::Value Headers;
    string Body;
    bool AddHost;
    bool AddContentLength;

    DiscordWebHook(const string &in url, const string &in body)
    {
        Log("Body: " + body);
        Method = Net::HttpMethod::Post;
        URL = url;
        Headers = Json::Parse(DiscordDefaults::Header);
        Body = body;
        AddHost = true;
        AddContentLength = true;
    }

    private Net::HttpRequest@ CreateReq()
    {
        Net::HttpRequest@ req = Net::HttpRequest();
        req.Method = Method;
        req.Url = URL;
        if (AddHost)
            req.Headers["Host"] = Regex::Search(URL, """(\w+)\.\w{2,}(?=\/|$)""")[0];
        if (AddContentLength)
            req.Headers["Content-Length"] = "" + string(Body).Length;
        auto keys = Headers.GetKeys();
        for (uint i = 0; i < keys.Length; i++)
        {
            auto key = keys[i];
            auto value = Headers[keys[i]];
            if (value.GetType() == Json::Type::String)
                req.Headers[key] = string(value);
        }

        req.Body = Body;

        return req;
    }

    Networking::Response Send()
    {
        Net::HttpRequest@ req = CreateReq();
        req.Start();

        while (!req.Finished()) yield();

        return Networking::Response(req.ResponseCode(), req.Error());
    }
}
