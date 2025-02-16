class Comparison : WebhookFilter {

    Json::Value@ FirstFilter {
        get {
            return Data["FirstFilter"];
        }
    }

    Json::Value@ SecondFilter {
        get {
            if (!Data.HasKey("SecondFilter"))
            {
                Data["SecondFilter"] = Json::Object();
            }
            return Data["SecondFilter"];
        }
    }

    string Comparison {
        get {
            if (Data.HasKey("Comparison"))
            {
                return Data["Comparison"];
            }
            return "AND";	
        }
        set {
            Data["Comparison"] = value;
        }
    }

    Comparison(Json::Value@ data, string label) {
        super(data);
        this.label = label;
    }

    bool Draw() override {
        UI::Indent();
        if (WebhookFilter(FirstFilter, label + 1).Draw()) {
            Data.Remove("FirstFilter");
            Data.Remove("Comparison");
            array<string> keys = Data["SecondFilter"].GetKeys();
            for (int i = 0; i < keys.Length; i++)
            {
                string key = keys[i];
                Data[key] = Data["SecondFilter"][key];
            }
            Data.Remove("SecondFilter");
            return false;
        }  
        
        UI::Unindent();
        Comparison = UI::InputText(Comparison, "##Comparison" + label);

        UI::Indent();
        if (WebhookFilter(Data["SecondFilter"], label + 2).Draw()) {
            Data.Remove("Comparison");
            Data.Remove("SecondFilter");
            array<string> keys = Data["FirstFilter"].GetKeys();
            for (int i = 0; i < keys.Length; i++)
            {
                string key = keys[i];
                Data[key] = Data["FirstFilter"][key];
            }
            Data.Remove("FirstFilter");
        }
        UI::Unindent();
        return false;
    }

}