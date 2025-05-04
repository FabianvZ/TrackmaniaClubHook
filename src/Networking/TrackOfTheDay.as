namespace TrackOfTheDay {

    Json::Value@ _data;

    bool IsTrackOfTheDay(Map@ map) {
        if (_data is null || uint(_data["endDate"]) < Time::get_Now()) {
            @_data = Nadeo::LiveServiceRequest("/api/cup-of-the-day/current", "https://meet.trackmania.nadeo.club");
        }
        Log(Json::Write(_data));
        return _data["challenge"]["uid"] == map.Uid;
    }

}