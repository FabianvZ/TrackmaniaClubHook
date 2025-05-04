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
            if (UI::Selectable(StringComparisons::ToString(StringComparisons::Contains), MapFilters == StringComparisons::Contains))
            {
                MapFilters = StringComparisons::Contains;
            } else if (UI::Selectable(StringComparisons::ToString(StringComparisons::DoesNotContain), MapFilters == StringComparisons::DoesNotContain))
            {
                MapFilters = StringComparisons::DoesNotContain;
            } else if (UI::Selectable(StringComparisons::ToString(StringComparisons::Is), MapFilters == StringComparisons::Is))
            {
                MapFilters = StringComparisons::Is;
            } else if (UI::Selectable(StringComparisons::ToString(StringComparisons::IsNot), MapFilters == StringComparisons::IsNot))
            {
                MapFilters = StringComparisons::IsNot;
            } 
            UI::EndCombo();
        }
        UI::SameLine();

        UI::SetNextItemWidth(200.0f);
        Map = UI::InputText("##" + label, Map);
    }

    bool Solve(PB@ pb) override {
        if (MapFilters == StringComparisons::Contains) {
            return pb.Map.Name.Contains(Map);
        } else if (MapFilters == StringComparisons::DoesNotContain) {
            return !pb.Map.Name.Contains(Map);
        } else if (MapFilters == StringComparisons::Is) {
            return pb.Map.Name == Map;
        } else if (MapFilters == StringComparisons::IsNot) {
            return pb.Map.Name != Map;
        }
        return false;
    }

}