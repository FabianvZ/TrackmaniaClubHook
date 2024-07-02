namespace Web
{
    Json::Value Request(Net::HttpRequest@ req)
    {
        req.Start();

        while(!req.Finished()) yield();

        return Json::Parse(req.String());
    }
}
