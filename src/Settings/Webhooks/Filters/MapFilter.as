class MapFilter : WebhookFilter {

    string Map {
        get {
            if (Data.HasKey("Map"))
            {
                return Data["Map"];
            }
            return "";
        }
        set {
            Data["Map"] = value;
        }
    }

    MapFilter(Json::Value@ data, string label) {
        super(data, label);
    }

}