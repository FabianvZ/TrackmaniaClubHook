namespace Nadeo
{
    Json::Value LiveServiceRequest(const string &in route)
    {
        while (!NadeoServices::IsAuthenticated("NadeoLiveServices")) yield();

        auto req = NadeoServices::Get("NadeoLiveServices", NadeoServices::BaseURLLive() + route);

        req.Start();

        while(!req.Finished()) yield();

        return Json::Parse(req.String());
    }

    Json::Value LiveServicePostRequest(const string &in route, const Json::Value &in body)
    {
        while (!NadeoServices::IsAuthenticated("NadeoLiveServices")) yield();
        
        auto req = NadeoServices::Post("NadeoLiveServices", NadeoServices::BaseURLLive() + route, Json::Write(body));

        req.Start();

        while(!req.Finished()) yield();

        return Json::Parse(req.String());
    }
}
