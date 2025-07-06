class WeeklyShortsFilter : CampaignFilter {

        WeeklyShortsFilter(Json::Value@ data, const string &in label) {
        super(Campaign::WeeklyShorts, data, label);
    }

}