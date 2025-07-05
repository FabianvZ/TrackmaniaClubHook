class MedalFilter : OrdinalWebhookFilter {

    Medal Medal {
        get { return Medal::FromValue(Value); }
        set { Value = value; }
    }

    MedalFilter(Json::Value@ data, const string &in label) {
        super(data, label);
    }

    void DrawOrdinalValue() override {
        UI::SetNextItemWidth(120.0f);
        if (UI::BeginCombo("##Medal" + label, Medal::ToString(Medal))) {
#if DEPENDENCY_CHAMPIONMEDALS
            if (UI::Selectable(Medal::ToString(Medal::Champion), Medal == Medal::Champion))
            {
                Medal = Medal::Champion;
            } else
#endif
            if (UI::Selectable(Medal::ToString(Medal::Author), Medal == Medal::Author))
            {
                Medal = Medal::Author;
            } else if (UI::Selectable(Medal::ToString(Medal::Gold), Medal == Medal::Gold))
            {
                Medal = Medal::Gold;
            } else if (UI::Selectable(Medal::ToString(Medal::Silver), Medal == Medal::Silver))
            {
                Medal = Medal::Silver;
            } else if (UI::Selectable(Medal::ToString(Medal::Bronze), Medal == Medal::Bronze))
            {
                Medal = Medal::Bronze;
            } else if (UI::Selectable(Medal::ToString(Medal::No), Medal == Medal::No))
            {
                Medal = Medal::No;
            } 
            UI::EndCombo();
        }
    }

    int GetValue(PB@ pb) override {
        return pb.Medal;
    }

}