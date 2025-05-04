class WebhookFilterElement : WebhookFilter {

    FilterType FilterType {
        get { return Data.HasKey("Type")? FilterType::FromValue(Data["Type"]) : FilterType::Time; }
        set { Data["Type"] = value; }
    }

    WebhookFilterElement(Json::Value@ data, const string &in label) {
        super(data, label);
    }

    bool Draw() override {
        UI::SetNextItemWidth(150.0f);
        if (UI::BeginCombo("##FilterType" + label, FilterType::ToString(FilterType)))
        {
            if (UI::Selectable(FilterType::ToString(FilterType::Time), FilterType == FilterType::Time))
            {
                FilterType = FilterType::Time;
            } else if (UI::Selectable(FilterType::ToString(FilterType::MapName), FilterType == FilterType::MapName))
            {
                FilterType = FilterType::MapName;
            } else if (UI::Selectable(FilterType::ToString(FilterType::Medal), FilterType == FilterType::Medal))
            {
                FilterType = FilterType::Medal;
            } else if (UI::Selectable(FilterType::ToString(FilterType::CurrentCampaign), FilterType == FilterType::CurrentCampaign))
            {
                FilterType = FilterType::CurrentCampaign;
            } else if (UI::Selectable(FilterType::ToString(FilterType::Rank), FilterType == FilterType::Rank))
            {
                FilterType = FilterType::Rank;
            } else if (UI::Selectable(FilterType::ToString(FilterType::TrackOfTheDay), FilterType == FilterType::TrackOfTheDay))
            {
                FilterType = FilterType::TrackOfTheDay;
            } else if (UI::Selectable(FilterType::ToString(FilterType::WeeklyShorts), FilterType == FilterType::WeeklyShorts))
            {
                FilterType = FilterType::WeeklyShorts;
            } 
            UI::EndCombo();
        }
        UI::SameLine();

        DrawSettings();
        UI::SameLine();
        
        if (UI::ButtonColored(Icons::Trash + "##" + label, 0.0f))
        {
            return true;
        }
        UI::SameLine();
        if (UI::Button(Icons::Plus + " Add a filter##" + label))
        {
            Json::Value filter = Data;
            array<string> keys = Data.GetKeys();
            for (uint i = 0; i < keys.Length; i++)
            {
                Data.Remove(keys[i]);
            }            
            FilterType = FilterType::Comparison;
            Data["FirstFilter"] = filter;
        }
        return false;
    }

    void DrawSettings() {
    }

}