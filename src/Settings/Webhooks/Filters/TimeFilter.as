class TimeFilter : WebhookFilter {

    string TimeUnit {
        get {
            if (Data.HasKey("TimeUnit"))
            {
                return Data["TimeUnit"];
            }
            return "Seconds";
        }
        set {
            Data["TimeUnit"] = value;
        }
    }

    int Value {
        get {
            if (Data.HasKey("Value"))
            {
                return Data["Value"];
            }
            return 0;
        }
        set {
            Data["Value"] = value;
        }
    }

    TimeFilter(Json::Value@ data, string label) {
        super(data, label);
    }

    bool Draw() override {
        return false;
    }

}