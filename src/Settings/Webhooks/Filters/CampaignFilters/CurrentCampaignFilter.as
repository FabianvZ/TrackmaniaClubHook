class CurrentCampaignFilter : CampaignFilter {

        CurrentCampaignFilter(Json::Value@ data, const string &in label) {
        super(Campaign::Official, data, label);
    }

}