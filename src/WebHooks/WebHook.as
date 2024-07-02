class WebHook
{
    Net::HttpMethod Method;
    string URL;
    Json::Value Headers;
    string Body;
    bool AddHost;
    bool AddContentLength;

    WebHook(Net::HttpMethod method, const string &in url, Json::Value headers, const string &in body, bool addHost = true, bool addContentLength = true)
    {
        Method = method;
        URL = url;
        Headers = headers;
        Body = body;
        AddHost = addHost;
        AddContentLength = addContentLength;
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
