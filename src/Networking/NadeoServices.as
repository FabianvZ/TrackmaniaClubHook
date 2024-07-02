namespace Nadeo
{
    Json::Value LiveServiceRequest(const string &in route)
    {
        while (!NadeoServices::IsAuthenticated("NadeoLiveServices")) yield();

        auto req = NadeoServices::Get("NadeoLiveServices", NadeoServices::BaseURLLive() + route);
        return Web::Request(req);
    }
}
