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
            for (int i = 0; i < 5; i++)
            {
                RankZones t = RankZones::FromValue(i);
                if (UI::Selectable(RankZones::ToString(t), RankZone == t))
                {
                    RankZone = t;
                    break;
                }
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