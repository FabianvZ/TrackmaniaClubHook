enum CampaignFilters {
    Contains,
    DoesNotContain,
}

namespace CampaignFilters {

    string ToString(CampaignFilters op) {
        switch (op) {
            case CampaignFilters::Contains:
                return "Contains";
            case CampaignFilters::DoesNotContain:
                return "Does Not Contain";
        }

        throw("Not implemented - Comparison: " + op);
        return "";
    }

    CampaignFilters FromValue(int op) {
        switch (op) {
            case 0:
                return CampaignFilters::Contains;
            case 1:
                return CampaignFilters::DoesNotContain;
        }

        throw("Not implemented - Comparison: " + op);
        return CampaignFilters::Contains;
    }

}
