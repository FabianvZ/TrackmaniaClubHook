class WebhookFilter : JsonSetting {

    protected string label;

    WebhookFilter(Json::Value@ data, const string &in label = "") {
        super(data);
        this.label = label;
    }

    bool Solve(ClubPB@ pb) {
        throw("Not implemented - Solve");
        return false;
    }

}