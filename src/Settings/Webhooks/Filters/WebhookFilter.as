class WebhookFilter : JsonSetting {

    protected string label;

    WebhookFilter Filter {
        get {
            if (Data.HasKey("FirstFilter"))
            {
                int type = Data["Type"];
                switch (type)
                {
                    case 0:
                        return Comparison(Data, label);
                    case 2:
                        return MapFilter(Data, label);
                    case 3:
                        return MedalFilter(Data, label);
                    case 4:
                        return CampaignFilter(Data, label);
                    default:
                        return TimeFilter(Data, label);
                }
            }
            return TimeFilter(Data, label); 
        }
    }

    WebhookFilter(Json::Value@ data, string label = "") {
        super(data);
        this.label = label;
    }

    bool Draw() override {
        if (Filter.Draw()){
            return true;
        }
        UI::SameLine();
        if (UI::Button(Icons::Minus + " Remove a filter##" + label))
        {
            return true;
        }
        UI::SameLine();
        if (UI::Button(Icons::Plus + " Add a filter##" + label))
        {
            Json::Value filter = Data;
            array<string> keys = Data.GetKeys();
            for (int i = 0; i < keys.Length; i++)
            {
                Data.Remove(keys[i]);
            }
            Data["FirstFilter"] = filter;
            Data["Type"] = FilterType::Comparison;
        }
        return false;
    }

}