class TimeFilter : OrdinalWebhookFilter {

    TimeUnit timeUnit {
        get { return Data.HasKey("TimeUnit")? TimeUnit::FromValue(Data["TimeUnit"]) : TimeUnit::Milliseconds; }
        set { Data["TimeUnit"] = value; }
    }

    TimeFilter(Json::Value@ data, const string &in label) {
        super(data, label);
    }

    void DrawOrdinalValue() override {
        UI::SetNextItemWidth(120.0f);
        Value = UI::InputInt("##TimeValue" + label, Value);
    }

    void DrawOrdinalType() override {
        UI::SetNextItemWidth(110.0f);
        if (UI::BeginCombo("##TimeUnit" + label, TimeUnit::ToString(timeUnit))) {
            if (UI::Selectable(TimeUnit::ToString(TimeUnit::Milliseconds), timeUnit == TimeUnit::Milliseconds))
            {
                timeUnit = TimeUnit::Milliseconds;
            } else if (UI::Selectable(TimeUnit::ToString(TimeUnit::Seconds), timeUnit == TimeUnit::Seconds))
            {
                timeUnit = TimeUnit::Seconds;
            } else if (UI::Selectable(TimeUnit::ToString(TimeUnit::Minutes), timeUnit == TimeUnit::Minutes))
            {
                timeUnit = TimeUnit::Minutes;
            }
            UI::EndCombo();
        }
    }

    int GetValue(ClubPB@ pb) override {
        if (timeUnit == TimeUnit::Milliseconds) {
            return pb.pb._score;
        } else if (timeUnit == TimeUnit::Seconds) {
            return pb.pb._score / 1000;
        } else if (timeUnit == TimeUnit::Minutes) {
            return pb.pb._score / 60000;
        }
        return 0;
    }

}