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
            for (int i = 1; i < 7; i++)
            {
                FilterType t = FilterType::FromValue(i);
                if (UI::Selectable(FilterType::ToString(t), FilterType == t))
                {
                    FilterType = t;
                    break;
                }
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