class TrackOfTheDayFilter : WebhookFilterElement {

    TotDStatus TotDStatus {
        get { return Data.HasKey("TotDStatus")? TotDStatus::FromValue(Data["TotDStatus"]) : TotDStatus::Is; }
        set { Data["TotDStatus"] = value; }
    }

    TrackOfTheDayFilter(Json::Value@ data, const string &in label) {
        super(data, label);
    }

    void DrawSettings() override {
        UI::SetNextItemWidth(75.0f);
        if (UI::BeginCombo("##TotDStatus" + label, TotDStatus::ToString(TotDStatus))) {
            if (UI::Selectable(TotDStatus::ToString(TotDStatus::Is), TotDStatus == TotDStatus::Is))
            {
                TotDStatus = TotDStatus::Is;
            } else if (UI::Selectable(TotDStatus::ToString(TotDStatus::IsNot), TotDStatus == TotDStatus::IsNot))
            {
                TotDStatus = TotDStatus::IsNot;
            } 
            UI::EndCombo();
        }
    } 

    bool Solve(ClubPB@ pb) override {
        return (TotDStatus == TotDStatus::Is) == TrackOfTheDay::IsTrackOfTheDay(pb.pb.Map);
    }

}