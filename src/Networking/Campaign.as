namespace Campaign {

    class Campaign
    {

        Campaign(const string &in uri)
        {
            _uri = uri;
        }

        string _uri;
        Json::Value@ _campaign;
        
        bool IsCurrentCampaignMap(Map@ map)
        {
            if (_campaign is null || uint(_campaign["endTimestamp"]) < Time::get_Now())
            {
                @_campaign = Nadeo::LiveServiceRequest("/api/campaign/" + _uri + "?length=1&offset=0")["campaignList"][0];
            }
            for (uint i = 0; i < _campaign["playlist"].Length; i++)
            {
                if (_campaign["playlist"][i]["mapUid"] == map.Uid)
                {
                    return true;
                }
            }
            return false;
        }

    }

    Campaign@ Official = Campaign("official");
    Campaign@ WeeklyShorts = Campaign("weekly-shorts");

}