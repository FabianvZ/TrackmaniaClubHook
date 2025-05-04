class CampaignFilter : WebhookFilterElement {

    CampaignFilters CampaignFilters {
        get { return Data.HasKey("CampaignFilters")? CampaignFilters::FromValue(Data["CampaignFilters"]) : CampaignFilters::Contains; }
        set { Data["CampaignFilters"] = value; }
    }

    Campaign::Campaign@ Campaign;

    CampaignFilter(Campaign::Campaign@ Campaign, Json::Value@ data, const string &in label) {
        super(data, label);
        @this.Campaign = Campaign;
    }

    void DrawSettings() override {
        UI::SetNextItemWidth(150.0f);
        if (UI::BeginCombo("##CampaignFilters" + label, CampaignFilters::ToString(CampaignFilters))) {
            if (UI::Selectable(CampaignFilters::ToString(CampaignFilters::Contains), CampaignFilters == CampaignFilters::Contains))
            {
                CampaignFilters = CampaignFilters::Contains;
            } else if (UI::Selectable(CampaignFilters::ToString(CampaignFilters::DoesNotContain), CampaignFilters == CampaignFilters::DoesNotContain))
            {
                CampaignFilters = CampaignFilters::DoesNotContain;
            } 
            UI::EndCombo();
        }
        UI::SameLine();
        UI::Text("Map");
    } 

    bool Solve(PB@ pb) override {
        return (CampaignFilters == CampaignFilters::Contains) == Campaign.IsCurrentCampaignMap(pb.Map);
    }

}