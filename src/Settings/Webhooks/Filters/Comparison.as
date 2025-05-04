class Comparison : WebhookFilter {

    WebhookFilter FirstFilter {
        get { return WebhookSettings::GetFilter(Data["FirstFilter"], label + 1); }
    }

    WebhookFilter SecondFilter {
        get {
            if (!Data.HasKey("SecondFilter"))
            {
                Data["SecondFilter"] = Json::Object();
            }
            return WebhookSettings::GetFilter(Data["SecondFilter"], label + 2);
        }
    }

    Comparisons Comparison {
        get { return Data.HasKey("Comparison")? Comparisons::FromValue(Data["Comparison"]) : Comparisons::And; }
        set { Data["Comparison"] = value; }
    }

    Comparison(Json::Value@ data, const string &in label) {
        super(data);
        this.label = label;
    }

    bool Draw() override {
        UI::Indent();
        if (FirstFilter.Draw()) {
            RevertToFilter(SecondFilter);
            UI::Unindent();
            return false;
        }  
        
        UI::Unindent();
        UI::SetNextItemWidth(60.0f);
        if (UI::BeginCombo("##Comparison" + label, Comparisons::ToString(Comparison))) {
            if (UI::Selectable(Comparisons::ToString(Comparisons::And), Comparison == Comparisons::And))
            {
                Comparison = Comparisons::And;
            } else if (UI::Selectable(Comparisons::ToString(Comparisons::Or), Comparison == Comparisons::Or))
            {
                Comparison = Comparisons::Or;
            } 
            UI::EndCombo();
        }

        UI::Indent();
        if (SecondFilter.Draw()) {
            RevertToFilter(FirstFilter);
        }
        UI::Unindent();
        return false;
    }

    void RevertToFilter(WebhookFilter filter) {
        for (uint i = 0; i < Data.GetKeys().Length; i++)
        {
            Data.Remove(Data.GetKeys()[i]);
        }
        for (uint i = 0; i < filter.Data.GetKeys().Length; i++)
        {
            string key = filter.Data.GetKeys()[i];
            Data[key] = filter.Data[key];
        }
    }

    bool Solve(PB@ pb) override {
        if (Comparison == Comparisons::And)
        {
            return FirstFilter.Solve(pb) && SecondFilter.Solve(pb);
        } else if (Comparison == Comparisons::Or)
        {
            return FirstFilter.Solve(pb) || SecondFilter.Solve(pb);
        }
        return false;
    }

}