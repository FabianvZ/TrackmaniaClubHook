namespace TrackOfTheDay {
    Json::Value@ _monthData;

    bool IsTrackOfTheDay(Map@ map) {
        uint64 now = Time::get_Stamp();
        if (_monthData is null || _monthData["nextRequestTimestamp"] <= now) {
            @_monthData = Nadeo::LiveServiceRequest("/api/token/campaign/month?offset=0&length=1");
        }

        if (!_monthData.HasKey("monthList") || _monthData["monthList"].Length == 0)
            return false;

        auto month = _monthData["monthList"][0];
        auto days = month["days"];
        if (days is null) 
            return false;

        for (uint i = 0; i < days.Length; i++) {
            auto day = days[i];
            if (map.Uid == string(day["mapUid"])) {
                uint start = day["startTimestamp"];
                uint end   = day["endTimestamp"];
                if (now >= start && now < end) {
                    return true;
                }
            }
        }

        return false;
    }
}
