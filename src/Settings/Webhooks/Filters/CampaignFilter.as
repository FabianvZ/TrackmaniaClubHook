class CampaignFilter : WebhookFilter {

    string Campaign {
        get {
            if (Data.HasKey("Campaign"))
            {
                return Data["Campaign"];
            }
            return "";
        }
        set {
            Data["Campaign"] = value;
        }
    }

    CampaignFilter(Json::Value@ data, string label) {
        super(data, label);
    }

}