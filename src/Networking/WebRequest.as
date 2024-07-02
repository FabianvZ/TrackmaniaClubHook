class WebRequest
{
    private Net::HttpMethod _method;
    private string _url;
    private Json::Value _headers;
    private string _body;
    bool AddHost;
    bool AddContentLength;

    WebRequest(){}

    WebRequest(Net::HttpMethod method, const string &in url, Json::Value headers, const string &in body, bool addHost = true, bool addContentLength = true)
    {
        _method = method;
        _url = url;
        _headers = headers;
        _body = body;
        AddHost = addHost;
        AddContentLength = addContentLength;
    }

    private Net::HttpRequest@ CreateReq()
    {
        Net::HttpRequest@ req = Net::HttpRequest();
        req.Method = _method;
        req.Url = _url;
        if (AddHost)
            req.Headers["Host"] = Regex::Search(_url, """(\w+)\.\w{2,}(?=\/|$)""")[0];
        if (AddContentLength)
            req.Headers["Content-Length"] = "" + string(_body).Length;
        auto keys = _headers.GetKeys();
        for (uint i = 0; i < keys.Length; i++)
        {
            auto key = keys[i];
            auto value = _headers[keys[i]];
            if (value.GetType() == Json::Type::String)
                req.Headers[key] = string(value);
        }

        req.Body = _body;

        return req;
    }

    Net::HttpRequest@ Send()
    {
        Net::HttpRequest@ req = CreateReq();
        req.Start();

        while (!req.Finished()) yield();

        return req;
    }
}
