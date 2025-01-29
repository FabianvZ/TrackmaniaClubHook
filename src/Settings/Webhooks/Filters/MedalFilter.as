class MedalFilter : WebhookFilter {

    string Medal {
        get {
            if (Data.HasKey("Medal"))
            {
                return Data["Medal"];
            }
            return "";
        }
        set {
            Data["Medal"] = value;
        }
    }

    MedalFilter(Json::Value@ data, string label) {
        super(data, label);
    }

}