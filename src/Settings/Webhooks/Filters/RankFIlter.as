class RankFilter : OrdinalWebhookFilter {

    RankZones RankZone {
        get { return Data.HasKey("RankZone")? RankZones::FromValue(Data["RankZone"]) : RankZones::World; }
        set { Data["RankZone"] = value; }
    }

    RankFilter(Json::Value@ data, const string &in label) {
        super(data, label);
    }

    void DrawOrdinalValue() override {
        UI::SetNextItemWidth(110.0f);
        Value = UI::InputInt("##Rank" + label, Value);
    }

    void DrawOrdinalType() override {
        UI::Text("In the");
        UI::SameLine();

        UI::SetNextItemWidth(110.0f);
        if (UI::BeginCombo("##RankZone" + label, RankZones::ToString(RankZone))) {
            if (UI::Selectable(RankZones::ToString(RankZones::Club), RankZone == RankZones::Club))
            {
                RankZone = RankZones::Club;
            } else if (UI::Selectable(RankZones::ToString(RankZones::World), RankZone == RankZones::World))
            {
                RankZone = RankZones::World;
            } else if (UI::Selectable(RankZones::ToString(RankZones::Continent), RankZone == RankZones::Continent))
            {
                RankZone = RankZones::Continent;
            } else if (UI::Selectable(RankZones::ToString(RankZones::Country), RankZone == RankZones::Country))
            {
                RankZone = RankZones::Country;
            } else if (UI::Selectable(RankZones::ToString(RankZones::Province), RankZone == RankZones::Province))
            {
                RankZone = RankZones::Province;
            }
            UI::EndCombo();
        }
        UI::SameLine();

        UI::Text("Leaderboard");
    }

    int GetValue(ClubPB@ pb) override {
        if (RankZone == RankZones::Club) {
            return pb.ClubPosition;
        } else if (RankZone == RankZones::World) {
            return pb.pb.WorldPosition;
        } else if (RankZone == RankZones::Continent) {
            return pb.pb.ContinentPosition;
        } else if (RankZone == RankZones::Country) {
            return pb.pb.CountryPosition;
        } else if (RankZone == RankZones::Province) {
            return pb.pb.ProvincePosition;
        }
        return 0;
    }

}