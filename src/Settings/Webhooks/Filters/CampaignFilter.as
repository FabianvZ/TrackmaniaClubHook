class CampaignFilter : WebhookFilter {

    CampaignFilter(Json::Value@ data, string label) {
        super(data, label);
    }

    bool Solve(PB@ pb) override {
        return Campaign::Official.IsCurrentCampaignMap(pb.Map);
    }

}