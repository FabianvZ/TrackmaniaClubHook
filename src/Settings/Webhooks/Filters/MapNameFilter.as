class MapNameFilter : WebhookFilterElement {

    StringComparisons MapFilters {
        get { return Data.HasKey("MapFilters")? StringComparisons::FromValue(Data["MapFilters"]) : StringComparisons::Contains; }
        set { Data["MapFilters"] = value; }
    }

    string Map {
        get { return Data.HasKey("Map")? Data["Map"] : ""; }
        set { Data["Map"] = value; }
    }

    MapNameFilter(Json::Value@ data, const string &in label) {
        super(data, label);
    }

    void DrawSettings() override {
        UI::SetNextItemWidth(145.0f);
        if (UI::BeginCombo("##MapFilters" + label, StringComparisons::ToString(MapFilters))) {
            for (int i = 0; i < 4; i++)
            {
                StringComparisons t = StringComparisons::FromValue(i);
                if (UI::Selectable(StringComparisons::ToString(t), MapFilters == t))
                {
                    MapFilters = t;
                    break;
                }
            }
            UI::EndCombo();
        }
        UI::SameLine();

        UI::SetNextItemWidth(200.0f);
        Map = UI::InputText("##" + label, Map);
    }

    bool Solve(ClubPB@ pb) override {
        if (MapFilters == StringComparisons::Contains) {
            return pb.pb.Map.Name.Contains(Map);
        } else if (MapFilters == StringComparisons::DoesNotContain) {
            return !pb.pb.Map.Name.Contains(Map);
        } else if (MapFilters == StringComparisons::Is) {
            return pb.pb.Map.Name == Map;
        } else if (MapFilters == StringComparisons::IsNot) {
            return pb.pb.Map.Name != Map;
        }
        return false;
    }

}